local utils = require('nvimawscli.utils.buffer')
local legal_grid = require('nvimawscli.utils.legal_grid')
local Iterable = require("nvimawscli.utils.itertools").Iterable
local View = require('nvimawscli.ui.views.view')
local border = require('nvimawscli.utils.borders')

---@class ListView: View
---@field lines Line[]
---@field content Content
local M = setmetatable({}, { __index = View })

---@class Content
---@field title string? The title of the list view
---@field sections Section[]? the list view sections

---@class Section
---@field title string?
---@field lines string[]
---@field unselectable boolean?

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
        local legal_lines = self:render()
        self.legal_grid = legal_grid.new()
        self.legal_grid:set_legal_lines(legal_lines)
    end)
end

---Render the rows in self onto the buffer in a simple list
---@return LegalLine: The cursor's legal lines
function M:render()
    self.lines = {}

    if self.content.title then
        self.lines[#self.lines + 1] = { text = self.content.title, selectable = false }
        local width = vim.fn.strdisplaywidth(self.content.title)
        self.lines[#self.lines + 1] = {
            text = string.rep(border.double.horizontal, width),
            selectable = false
        }
    end

    for section_index, section in ipairs(self.content.sections) do
        if section.title then
            self.lines[#self.lines + 1] = { text = section.title, selectable = false }
            local width = vim.fn.strdisplaywidth(section.title)
            self.lines[#self.lines + 1] = {
                text = string.rep(border.rounded.horizontal, width),
                selectable = false
            }
        end
        for line_index, line in ipairs(section.lines) do
            self.lines[#self.lines + 1] = {
                text = line,
                selectable = section.unselectable or true,
                position = { section_index, line_index }
            }
        end
        self.lines[#self.lines + 1] = {
            text = ' ',
            selectable = false
        }
    end

    -- vim.api.nvim_out_write(vim.inspect(self.lines))

    local drawables = Iterable(self.lines):imap_values(function(line)
        return line.text
    end).table

    utils.write_lines(self.bufnr, drawables)
    local allowed_positions = {}
    for i, line in ipairs(self.lines) do
        if line.selectable then
            allowed_positions[i] = { 1 }
        else
            allowed_positions[i] = {}
        end
    end
    return allowed_positions
end

return M
