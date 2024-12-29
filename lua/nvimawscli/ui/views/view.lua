local utils = require('nvimawscli.utils.buffer')

---@class View
---@field bufnr integer?
---@field winnr integer?
---@field name string
---@field legal_grid LegalGrid
local M = {}

M.name = 'view'
M.editable = false

---Initialize the view with special data
---usualy it is sent by the caller that launches the view
---@param extra_data table? special data based on view, can be nil
function M:init(extra_data)
    self.data = extra_data
end

function M:set_keymaps()
end

function M:load_content()
end

---Launch the view with a specific split
---@param split Split
---@param extra_data table? special data based on view, can be nil
function M:show(split, extra_data)
    self:init(extra_data)

    if not self.bufnr then
        self:load()
    end

    if not self.winnr or not utils.check_if_window_exists(self.winnr) then
        self.winnr = utils.create_window(self.bufnr, split)
    end

    vim.api.nvim_set_current_win(self.winnr)
    vim.opt_local.number = false
    vim.opt_local.relativenumber = false

    self:load_content()
end

function M:load()
    self.bufnr = utils.create_buffer(self.name, nil, self.editable)
    self:set_keymaps()

    self.last_cursor_position = vim.insp

    vim.api.nvim_create_autocmd({'CursorMoved'}, {
        buffer = self.bufnr,
        callback = function ()
            -- print('we are here ' .. vim.inspect(vim.fn.getcursorcharpos(0)))
            local cursor_position = vim.fn.getcursorcharpos(0)

            local legal_position = self.legal_grid:get_legal_position({ cursor_position[2], cursor_position[3] })

            print('these are the positions ' .. vim.inspect(legal_position))
            vim.fn.setcursorcharpos(legal_position[1], legal_position[2])
        end,
    })
end

return M
