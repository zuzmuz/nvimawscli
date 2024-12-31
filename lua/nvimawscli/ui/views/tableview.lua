local utils = require('nvimawscli.utils.buffer')
local legal_grid = require('nvimawscli.utils.legal_grid')
local config = require('nvimawscli.config')
local Iterable = require("nvimawscli.utils.itertools").Iterable
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
M.filter_fields = {}
M.action_fields = {}
M.filter_text = nil
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

            local line_offset = 0
            if self.filter_fields and #self.filter_fields > 0 then
                line_offset = 1
            end

            local item_number = table_renderer.get_item_number_from_row(line_number - line_offset)

            if line_offset == 1 and line_number == 1 then -- filter
                popup.create_floating_input("input filter text", 20, 1, self.filter_text or '', config.table,
                    function(text)
                        self.filter_text = text
                        self:load_content()
                    end
                )
            elseif item_number == 0 then -- sort
                self:handle_sort_event(column_number)
            elseif item_number <= #self.rows then
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
                    end
                )
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
            utils.write_lines_string(self.bufnr, error)
        elseif rows then
            self.rows = rows
            self.ready = true
            local legal_lines = self:render()
            self.legal_grid = legal_grid.new()
            self.legal_grid:set_legal_lines(legal_lines)
        end
    end)
end

---Render the rows in self onto the buffer in a table
---@return number[][][]: The cursor's allowed positions
function M:render()
    local filter_line = {}
    local allowed_filter_line_position = {}
    if self.filter_fields and #self.filter_fields > 0 then
        local filter_text = "filter : "
        allowed_filter_line_position = { { vim.fn.strdisplaywidth(filter_text) } }
        filter_line = { filter_text .. (self.filter_text or '') }
    end

    local column_names = Iterable(self.column_headers):imap_values(function(attribute)
        return attribute.name
    end).table

    local lines, legal_lines, widths = table_renderer.render(
        column_names,
        self.rows,
        self.sorted_by_column_index,
        self.sorted_direction,
        config.table)
    self.widths = widths

    local action_lines = {}
    local allowed_action_lines = {}
    if self.action_fields and #self.action_fields > 0 then
        local action_fields_iterable = Iterable(self.action_fields)
        action_lines = action_fields_iterable:imap_values(
            function (value)
                return value.label
            end
        ).table
        allowed_action_lines = action_fields_iterable:imap_values(
            function (_)
                return { 1 }
            end
        ).table
    end

    lines = Iterable(filter_line):extend(lines):extend(action_lines).table
    legal_lines = Iterable(allowed_filter_line_position):extend(
        legal_lines):extend(allowed_action_lines).table
    utils.write_lines(self.bufnr, lines)
    return legal_lines
end

return M
