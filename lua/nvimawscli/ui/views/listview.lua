local utils = require('nvimawscli.utils.buffer')
local itertools = require("nvimawscli.utils.itertools")
local View = require('nvimawscli.ui.views.view')
local border = require('nvimawscli.utils.borders')

---@class ListView: View
---@field lines Line[]
---@field content Content
local M = setmetatable({}, { __index = View })

---@class Content
---@field title string The text to display as a list item
---@field sections Section[]? Whether the item can be selected

---@class Section
---@field title string
---@field lines string[]

---@class Line
---@field text string
---@field selectable boolean
---@field item integer[]? position in original content, size 2, index 1 is section index 2 is line number, nil if selectable is false

M.name = 'listview'

function M:did_select_item(_)
end

M.loading_text = 'Loading...'
---Function to be implemented by subclasses
---returns the content of that should be displayed in the list, asynchronously
---@param callback fun(content: Content) a callback function that will be called with the lines to display
function M:fetch_lines(callback)
    callback({ title = 'Nothing to display' })
end

function M:set_keymaps()
    vim.api.nvim_buf_set_keymap(self.bufnr, 'n', '<CR>', '', {
        callback = function()
            if not self.ready then
                return
            end
            local position = vim.api.nvim_win_get_cursor(self.winnr)
            local item = self.lines[position[1]]
            if item.selectable then
                self:did_select_item(item)
            end
        end
    })
end

function M:load_content()
    self.ready = false
    utils.write_lines(self.bufnr, { self.loading_text })
    self:fetch_lines(function(content)
        self.content = content
        self.ready = true
        local allowed_positions = self:render()
        utils.set_allowed_positions(self.bufnr, allowed_positions)
    end)
end


---Render the rows in self onto the buffer in a simple list
---@return number[][][]: The cursor's allowed positions
function M:render()
    self.lines = {}

    self.lines[#self.lines+1] = { text = self.content.title, selectable = false }
    local width = vim.fn.strdisplaywidth(self.content.title)
    self.lines[#self.lines+1] = {
        text = string.rep(border.double.horizontal, width),
        selectable = false
    }

    for section_index, section in ipairs(self.content.sections) do
        self.lines[#self.lines+1] = { text = section.title, selectable = false }
        width = vim.fn.strdisplaywidth(section.title)
        self.lines[#self.lines+1] = {
            text = string.rep(border.rounded.horizontal, width),
            selectable = false
        }

        for line_index, line in ipairs(section.lines) do
            self.lines[#self.lines+1] = {
                text = line,
                selectable = true,
                position = { section_index, line_index }
            }
        end
    end

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
