local utils = require('nvimawscli.utils.buffer')
local command = require('nvimawscli.commands.rds')
local config = require('nvimawscli.config')
local actions = require('nvimawscli.services.rds.actions')
local ui = require('nvimawscli.utils.ui')
local itertools = require('nvimawscli.utils.itertools')

---@class RdsInstance
local M = {}

function M.show(rds_instance_name, split)
    M.rds_instance_name = rds_instance_name
    if not M.bufnr then
        M.load()
    end

    if not M.winnr or not vim.api.nvim_win_is_valid(M.winnr) then
        M.winnr = utils.create_window(M.bufnr, split)
    end
    vim.api.nvim_set_current_win(M.winnr)
    M.fetch()
end
