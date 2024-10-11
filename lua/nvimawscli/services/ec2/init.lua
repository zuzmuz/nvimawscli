local config = require('nvimawscli.config')
local ListView = require('nvimawscli.ui.views.listview')

---@class Ec2View: ListView
local M = setmetatable({}, { __index = ListView })

M.name = 'ec2'

M.preferred_services_header = {
    "Preferred Services",
    "---------------------",
}

M.all_services_header = {
    "All       Services",
    "---------------------",
}

M.all_services = {
    "instances",
    "security_groups",
    "create_instances",
    "elastic_ips",
}

function M:fetch_lines(callback)
    local lines = {}
    if config.ec2.preferred_services then
        for _, header in ipairs(M.preferred_services_header) do
            lines[#lines + 1] = { text = header, selectable = false }
        end
        for _, header in ipairs(config.ec2.preferred_services) do
            lines[#lines + 1] = { text = header, selectable = true }
        end
        lines[#lines+1] = { text = "                  ", selectable = false }
        lines[#lines+1] = { text = "------------------", selectable = false }
    end
    for _, header in ipairs(M.all_services_header) do
        lines[#lines + 1] = { text = header, selectable = false }
    end
    for _, header in ipairs(self.all_services) do
        lines[#lines + 1] = { text = header, selectable = true }
    end
    callback(lines)
end

function M:did_select_item(item)
    if item.selectable then
        local subservice_name = item.text
        local status, subservice = pcall(require, 'nvimawscli.services.ec2.' .. subservice_name)
        if status then
            subservice:show(config.menu.split)
            vim.api.nvim_win_set_width(M.winnr, config.menu.width)
        else
            vim.api.nvim_err_writeln('Ec2 subservice not found: ' .. subservice_name)
        end
    end
end

return M
