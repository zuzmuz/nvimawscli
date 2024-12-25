local config = require('nvimawscli.config')
local ListView = require('nvimawscli.ui.views.listview')

---@class CodeDeployView: ListView
local M = setmetatable({}, { __index = ListView })

M.name = 'codedeploy'

function M:fetch_lines(callback)
    callback {
        { text = "applications", selectable = true },
        { text = "deployment_groups", selectable = true },
        { text = "deployments", selectable = true },
    }
end

function M:did_select_item(item)
    if item.selectable then
        local subservice_name = item.text
        local status, subservice = pcall(require, 'nvimawscli.services.codedeploy.' .. subservice_name)
        if status then
            subservice:show(config.menu.split)
            vim.api.nvim_win_set_width(M.winnr, config.menu.width)
        else
            vim.api.nvim_err_writeln('Ec2 subservice not found: ' .. subservice_name)
        end
    end
end

return M
