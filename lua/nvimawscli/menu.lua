local utils = require('nvimawscli.utils.buffer')
local config = require('nvimawscli.config')



---@class Menu
---@field buffnr number
local M = {}


M.header = {
    "AWS            CLI",
    "==================",
}

M.preferred_services_header = {
    "Preferred Services",
    "------------------",
}

M.all_services_header = {
    "All       Services",
    "------------------",
}

---Show the menu
---@param split Split
function M.show(split)
    if not M.bufnr then
        M.load()
    end

    if not M.winnr or not vim.api.nvim_win_is_valid(M.winnr) then
        M.winnr = utils.create_window(M.bufnr, split)
        vim.api.nvim_win_set_width(M.winnr, config.menu.width)
    end
    vim.api.nvim_set_current_win(M.winnr)
end

---Load the menu
---The menu is the initial buffer and contain the list of aws services available
function M.load()

    M.bufnr = utils.create_buffer('menu')

    vim.api.nvim_buf_set_keymap(M.bufnr, 'n', '<CR>', '', {
        callback = function()
            local line_number = vim.api.nvim_win_get_cursor(M.winnr)[1]
            if line_number <= #M.header + #M.preferred_services_header then
                return
            end
            local service_name = utils.get_line(M.bufnr, line_number)
            local status, service = pcall(require, 'nvimawscli.services.' .. service_name)
            if status then
                service.show(config.menu.split)
                vim.api.nvim_win_set_width(M.winnr, config.menu.width)
            else
                vim.api.nvim_err_writeln("Service not implemented yet: " .. service_name)
            end
        end
    })
    utils.write_lines_string(M.bufnr,
        table.concat(M.header, '\n') .. '\n' ..
        table.concat(M.preferred_services_header, '\n') .. '\n' ..
        table.concat(config.preferred_services, '\n'))


    local allowed_positions = {}

    for i, _ in ipairs(config.preferred_services) do
        allowed_positions[#allowed_positions+1] = {
            { #M.header + #M.preferred_services_header + i, 1 }
        }
    end

    utils.set_allowed_positions(M.bufnr, allowed_positions)
end

function M.hide()
    vim.api.nvim_win_hide(M.winnr)
end

return M
