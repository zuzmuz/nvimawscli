local config = require('nvimawscli.config')
local ListView = require('nvimawscli.ui.views.listview')

---@class Ec2View: ListView
local M = setmetatable({}, { __index = ListView })

M.name = 'ec2'

function M:get_lines()
    local lines = {}
    for _, header in ipairs(config.ec2.preferred_services) do
        lines[#lines + 1] = { text = header, selectable = true }
    end
    return lines
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
