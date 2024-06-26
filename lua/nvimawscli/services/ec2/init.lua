local utils = require('nvimawscli.utils.buffer')
local config = require('nvimawscli.config')

---@class Ec2
local M = {}


function M.show(split)
    if not M.bufnr then
        M.load()
    end
    if not M.winnr or not utils.check_if_window_exists(M.winnr) then
        M.winnr = utils.create_window(M.bufnr, split)
    end

    vim.api.nvim_set_current_win(M.winnr)
end

function M.load()
    M.bufnr = utils.create_buffer('submenu')

    vim.api.nvim_buf_set_keymap(M.bufnr, 'n', '<CR>', '', {
        callback = function()
            local position = vim.api.nvim_win_get_cursor(M.winnr)

            local subservice_name = utils.get_line(M.bufnr, position[1])


            local status, subservice = pcall(require, 'nvimawscli.services.ec2.' .. subservice_name)

            if status then
                subservice.show(config.menu.split)
                vim.api.nvim_win_set_width(M.winnr, config.menu.width)
            else
                vim.api.nvim_err_writeln('Subservice not found: ' .. subservice_name)
            end
        end
    })

    utils.write_lines(M.bufnr, config.ec2.preferred_services)
    local allowed_positions = {}
    for i, _ in ipairs(config.ec2.preferred_services) do
        allowed_positions[#allowed_positions+1] = { { i, 1 } }
    end
    utils.set_allowed_positions(M.bufnr, allowed_positions)
end

return M
