local utils = require('nvimawscli.utils.buffer')
local itertools = require("nvimawscli.utils.itertools")
local View = require('nvimawscli.ui.views.view')

---@class ListView: View
local M = setmetatable({}, { __index = View })

M.name = 'listview'

function M:did_select_item(_)
end

M.get_lines = nil
M.fetch_lines = nil
M.loading_text = 'Loading...'

function M:set_keymaps()
    vim.api.nvim_buf_set_keymap(self.bufnr, 'n', '<CR>', '', {
        callback = function()
            if not self.ready then
                return
            end
            local position = vim.api.nvim_win_get_cursor(self.winnr)
            local item = self.lines[position[1]]
            self:did_select_item(item)
        end
    })
end

function M:load_content()
    if self.get_lines then
        self.lines = self:get_lines()
        self.ready = true
        self:render()
    elseif self.fetch_lines then
        self.ready = false
        utils.write_lines(self.bufnr, { self.loading_text })
        self:fetch_lines(function(lines)
            self.lines = lines
            print(vim.inspect(lines))
            self.ready = true
            self:render()
        end)
    end
end

function M:render()
    local drawables = itertools.imap_values(self.lines, function(line)
        return line.text
    end)
    utils.write_lines(self.bufnr, drawables)
    local allowed_positions = {}
    for i, line in ipairs(self.lines) do
        if line.selectable then
            allowed_positions[#allowed_positions + 1] = { { i, 1 } }
        end
    end
    utils.set_allowed_positions(self.bufnr, allowed_positions)
end

return M
