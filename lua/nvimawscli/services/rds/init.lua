local utils = require('nvimawscli.utils.buffer')
local itertools = require("nvimawscli.utils.itertools")
local config = require('nvimawscli.config')

---@type RdsHandler
local command = require(config.commands .. '.rds')

---@class Rds
local M = {}

function M.show(split)
    if not M.bufnr then
        M.load()
    end
    if not M.winnr or not utils.check_if_window_exists(M.winnr) then
        M.winnr = utils.create_window(M.bufnr, split)
    end

    vim.api.nvim_set_current_win(M.winnr)
    M.fetch()
end

function M.load()
    M.bufnr = utils.create_buffer('rds')

    vim.api.nvim_buf_set_keymap(M.bufnr, 'n', '<CR>', '', {
        callback = function()
            local position = vim.api.nvim_win_get_cursor(M.winnr)

            local subservice_name = utils.get_line(M.bufnr, position[1])
        end
    })
end

function M.fetch()
    M.ready = false
    utils.write_lines(M.bufnr, { 'Fetching databases...' })
    command.list_databases(function(result, error)
        if error then
            utils.write_lines_string(M.bufnr, error)
        elseif result then
            M.rows = vim.json.decode(result)
            local allowed_positions = M.render(M.rows)
            utils.set_allowed_positions(M.bufnr, allowed_positions)
        else
            utils.write_lines_string(M.bufnr, 'Result was nil')
        end
        M.ready = true
    end)
end

function M.render(rows)
    utils.write_lines(M.bufnr, rows)
    return itertools.imap(rows, function(i, _)
        return { { i, 1 } }
    end)
end


return M
