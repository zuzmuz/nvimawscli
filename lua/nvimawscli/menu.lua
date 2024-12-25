local config = require('nvimawscli.config')
local ListView = require('nvimawscli.ui.views.listview')



---@class MenuView: ListView
local M = setmetatable({}, { __index = ListView })


M.header                    = "AWS            CLI"

M.preferred_services_header = "Preferred Services"

M.all_services_header       = "All       Services"

M.all_services = {
    "ec2",
    "s3",
    "rds",
    "codedeploy",
}

M.name = 'menu'

function M:fetch_lines(callback)
    ---@type Content
    local content = {
        title = M.header
    }

    content.sections = {}
    if config.preferred_services then
        content.sections[#content.sections+1] = {
            title = M.preferred_services_header,
            lines = config.preferred_services
        }
    end
    content.sections[#content.sections+1] = {
        title = M.all_services_header,
        lines = M.all_services
    }
    callback(content)
end

function M:did_select_item(item)
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

function M:hide()
    vim.api.nvim_win_hide(self.winnr)
end

return M
