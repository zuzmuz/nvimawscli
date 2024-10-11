local utils = require('nvimawscli.utils.buffer')

---@class View
---@field bufnr integer?
---@field winnr integer?
---@field name string
local M = {}

M.name = 'view'

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

    self:load_content()
end

function M:load()
    self.bufnr = utils.create_buffer(self.name)
    self:set_keymaps()
end

return M
