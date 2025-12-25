local config = require('nvimawscli.config')
local ListView = require('nvimawscli.ui.views.listview')

---@class CodeDeployView: ListView
local M = setmetatable({}, { __index = ListView })

M.name = 'codedeploy'

function M:fetch_lines(callback)
    callback {
        sections = {{
            lines = {
                "applications",
                "deployment_groups",
                "deployments",
            }}
        }
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
            vim.notify(
                'Ec2 subservice not found: ' .. subservice_name,
                vim.log.levels.WARN
            )
        end
    end
end

return M
