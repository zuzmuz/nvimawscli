local config = require('nvimawscli.config')
local data = require('nvimawscli.utils.data')
local ListView = require('nvimawscli.ui.views.listview')
local popup = require('nvimawscli.ui.popup')

---@class MenuView: ListView
local M = setmetatable({}, { __index = ListView })


M.header                    = "AWS            CLI"

M.profile                   = "Selected   Profile"

M.preferred_services_header = "Preferred Services"

M.all_services_header       = "All       Services"

M.all_services              = {
    "ec2",
    "s3",
    "rds",
    "codedeploy",
}

M.name                      = 'menu'

function M:fetch_lines(callback)
    ---@type Content
    local content = {
        title = M.header
    }

    content.sections = {}

    if data.store.current_profile then
        content.sections[#content.sections + 1] = {
            title = M.profile,
            lines = { data.store.current_profile }
        }
    else
        content.sections[#content.sections + 1] = {
            title = M.profile,
            lines = { "default" }
        }
    end

    if config.preferred_services then
        content.sections[#content.sections + 1] = {
            title = M.preferred_services_header,
            lines = config.preferred_services
        }
    end
    content.sections[#content.sections + 1] = {
        title = M.all_services_header,
        lines = M.all_services
    }
    callback(content)
end

---@param item Line
function M:did_select_item(item)
    if item.position[1] == 1 then
        popup.create_floating_input(
            "Enter Profile Name:",
            20, 1,
            data.store.current_profile or 'default',
            config.table,
            function(input)
                if input and input ~= "" then
                    data.store.current_profile = input
                    data.save()
                    vim.notify(
                        "Profile set to: " .. input,
                        vim.log.levels.INFO
                    )
                    self:load_content()
                else
                    vim.notify(
                        "Profile not changed.",
                        vim.log.levels.WARN
                    )
                end
            end)
    end
    local service_name = item.text
    local status, service = pcall(require, 'nvimawscli.services.' .. service_name)
    ---@cast service View
    if status then
        service:show(config.menu.split)
        vim.api.nvim_win_set_width(self.winnr, config.menu.width)
    else
        vim.notify(
            "Service not implemented yet: " .. service_name,
            vim.log.levels.WARN
        )
    end
end

function M:hide()
    vim.api.nvim_win_hide(self.winnr)
end

return M
