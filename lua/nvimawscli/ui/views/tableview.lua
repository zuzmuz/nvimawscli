local utils = require('nvimawscli.utils.buffer')
local config = require('nvimawscli.config')
local itertools = require("nvimawscli.utils.itertools")
local table_renderer = require('nvimawscli.utils.tables')
local ui = require('nvimawscli.utils.ui')
local View = require('nvimawscli.ui.views.view')

---@class TableView: View
local M = setmetatable({}, { __index = View })

M.name = 'tableview'
M.column_headers = {}

M.get_rows = nil
M.fetch_rows = nil
M.loading_text = 'Loading...'

M.actions = {}

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
                local available_actions = self.actions.get(row)

                ui.create_floating_select_popup(nil, available_actions, config.table,
                    function(selected_action)
                        local action = available_actions[selected_action]
                        if self.actions[action].ask_for_confirmation then
                            ui.create_floating_select_popup(
                                action .. ' instance ' .. self:describe(row),
                                { 'yes', 'no' },
                                config.table,
                                function(confirmation)
                                    if confirmation == 1 then -- yes selected
                                        self.actions[action].action(row)
                                    end
                                end)
                        else
                            self.actions[action].action(row)
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
    if self.get_rows then
        self.rows = self:get_rows()
        self.ready = true
        local allowed_positions = self:render()
        utils.set_allowed_positions(self.bufnr, allowed_positions)
    elseif self.fetch_rows then
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
end

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
