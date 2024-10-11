local utils = require('nvimawscli.utils.buffer')
local itertools = require("nvimawscli.utils.itertools")
local View = require('nvimawscli.ui.views.view')

---@class ListView: View
local M = setmetatable({}, { __index = View })

---@class Line
---@field text string The text to display as a list item
---@field selectable boolean Whether the item can be selected

M.name = 'listview'

function M:did_select_item(_)
end

M.loading_text = 'Loading...'
---Function to be implemented by subclasses
---returns the content of that should be displayed in the list, asynchronously
---@param callback fun(lines: Line[]) a callback function that will be called with the lines to display
function M:fetch_lines(callback)
    callback({ text = 'Nothing to display', selectable = false })
end

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
    self.ready = false
    utils.write_lines(self.bufnr, { self.loading_text })
    self:fetch_lines(function(lines)
        self.lines = lines
        self.ready = true
        local allowed_positions = self:render()
        utils.set_allowed_positions(self.bufnr, allowed_positions)
    end)
end


---Render the rows in self onto the buffer in a simple list
---@return number[][][]: The cursor's allowed positions
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
    return allowed_positions
end

return M
