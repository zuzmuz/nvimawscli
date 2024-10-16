local utils = require('nvimawscli.utils.buffer')
local config = require('nvimawscli.config')
local itertools = require("nvimawscli.utils.itertools")
local table_renderer = require('nvimawscli.utils.tables')
local popup = require('nvimawscli.ui.popup')
local View = require('nvimawscli.ui.views.view')

---@class TableView: View
local M = setmetatable({}, { __index = View })

M.name = 'tableview'

---@class Attribute
---@field name string: The name of the attribute
---@field value string: The aws query function for the attribute
---
---The table column headers titles
---@type Attribute[]
M.column_headers = {}

M.loading_text = 'Loading...'
function M:fetch_rows(callback)
    callback(nil, 'Nothing to display')
end


---@class ActionManager
---List of actions to perform on the table rows
---@field get fun(row: table): string[]: returns list of legal actions on the row
---@field actions table<string, Action>: list of actions to perform on the row
M.action_manager = {}

---@class Action
---@field ask_for_confirmation boolean if true the user should be prompted for confirmation
---@field action fun(row: table, data: table) the action to be executed

---Show text describing the table row
---@param row table the data representing the row
---@return string the text describing the row
function M:describe(row)
    return vim.inspect(row)
end

function M:set_keymaps()
    vim.api.nvim_buf_set_keymap(self.bufnr, 'n', '<CR>', '', {
        callback = function()
            if not self.ready then
                return
            end
            local position = vim.fn.getcursorcharpos()
            local line_number = position[2]
            local column_number = position[3]

            local item_number = table_renderer.get_item_number_from_row(line_number)

            if item_number > 0 and item_number <= #self.rows then
                -- open floating window for instance functions
                local row = self.rows[item_number]
                local available_actions = self.action_manager.get(row)

                popup.create_floating_select(nil, nil, available_actions, config.table,
                    function(selected_action)
                        local action = available_actions[selected_action]
                        if self.action_manager.actions[action].ask_for_confirmation then
                            popup.create_floating_select(
                                action .. ' instance ' .. self:describe(row),
                                nil,
                                { 'yes', 'no' },
                                config.table,
                                function(confirmation)
                                    if confirmation == 1 then -- yes selected
                                        self.action_manager.actions[action].action(row, self.data)
                                    end
                                end)
                        else
                            self.action_manager.actions[action].action(row, self.data)
                        end
                    end)
            else -- perform sorting based on column selection
                self:handle_sort_event(column_number)
            end
        end
    })
end

function M:handle_sort_event(column_number)
    local column_index = table_renderer.get_column_index_from_position(column_number, self.widths)
    if self.sorted_by_column_index == column_index then
        self.sorted_direction = self.sorted_direction * -1
    else
        self.sorted_by_column_index = column_index
        self.sorted_direction = 1
    end
    if column_index then
        local column_value = self.column_headers[column_index].name
        table.sort(self.rows, function(a, b)
            -- WARN: we might need to deal with different types of values (strings, integers)
            if self.sorted_direction == 1 then
                return a[column_value] < b[column_value]
            end
            return a[column_value] > b[column_value]
        end)
        self:render()
    end
end

function M:load_content()
    self.ready = false
    utils.write_lines(self.bufnr, { self.loading_text })
    self:fetch_rows(function(rows, error)
        if error then
            utils.write_lines(self.bufnr, { error })
        elseif rows then
            self.rows = rows
            self.ready = true
            local allowed_positions = self:render()
            utils.set_allowed_positions(self.bufnr, allowed_positions)
        end
    end)
end


---Render the rows in self onto the buffer in a table
---@return number[][][]: The cursor's allowed positions
function M:render()
    local column_names = itertools.imap_values(self.column_headers, function(attribute)
        return attribute.name
    end)

    local lines, allowed_positions, widths = table_renderer.render(
        column_names,
        self.rows,
        self.sorted_by_column_index,
        self.sorted_direction,
        config.table)
    self.widths = widths
    utils.write_lines(self.bufnr, lines)
    return allowed_positions
end

return M
