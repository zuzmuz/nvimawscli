local config = require('nvimawscli.config')
local ListView = require('nvimawscli.ui.views.listview')



---@class MenuView: ListView
local M = setmetatable({}, { __index = ListView })


M.header = {
    "AWS            CLI",
    "==================",
}

M.preferred_services_header = {
    "Preferred Services",
    "------------------",
}

M.all_services_header = {
    "                  ",
    "------------------",
    "All       Services",
    "------------------",
}

M.name = 'menu'

function M.fetch_lines(callback)
    local lines = {}
    for _, header in ipairs(M.header) do
        lines[#lines+1] = { text = header, selectable = false }
    end
    for _, preferred_services_header in ipairs(M.preferred_services_header) do
        lines[#lines+1] = { text = preferred_services_header, selectable = false }
    end
    for _, preferred_service in ipairs(config.preferred_services) do
        lines[#lines+1] = { text = preferred_service, selectable = true }
    end
    for _, all_services_header in ipairs(M.all_services_header) do
        lines[#lines+1] = { text = all_services_header, selectable = false }
    end
    callback(lines)
end

function M:did_select_item(item)
    if item.selectable then
        local service_name = item.text
        local status, service = pcall(require, 'nvimawscli.services.' .. service_name)
        ---@cast service View
        if status then
            service:show(config.menu.split)
            vim.api.nvim_win_set_width(self.winnr, config.menu.width)
        else
            vim.api.nvim_err_writeln("Service not implemented yet: " .. service_name)
        end
    end
end

function M.hide()
    vim.api.nvim_win_hide(M.winnr)
end

return M
