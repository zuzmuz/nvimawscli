local config = require('nvimawscli.config')
local data = require('nvimawscli.utils.data')
local Iterable = require('nvimawscli.utils.itertools').Iterable
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

---Prompt user to enter a new profile name
---@param self MenuView
local function prompt_for_new_profile(self)
    if not data.store.profiles then
        data.store.profiles = {}
    end
    popup.create_floating_input(
        "Enter Profile Name:",
        20, 1,
        data.store.current_profile or 'default',
        config.table,
        function(input)
            if input and input ~= "" then
                data.store.profiles[input] = true
                data.store.current_profile = input
                data.save()
                self:load_content()
                vim.notify(
                    "Profile set to: " .. input,
                    vim.log.levels.INFO
                )
            else
                vim.notify(
                    "Profile not changed.",
                    vim.log.levels.WARN
                )
            end
        end
    )
end

---Prompt user to select profile from stored profiles or enter a new one.
---Whenever a new profile is stored it will be available for selection
---@param self MenuView
local function prompt_for_profile_select(self)
    local actions = Iterable(data.store.profiles):keys().table
    actions[#actions + 1] = "Enter new profile name"
    popup.create_floating_select(
        "Select Profile Name:",
        nil,
        actions,
        config.table,
        function(selected_action)
            if selected_action < #actions then
                -- Choose existing profile
                local profile = actions[selected_action]
                data.store.current_profile = profile
                data.save()
                self:load_content()
                vim.notify(
                    "Profile set to: " .. profile,
                    vim.log.levels.INFO
                )
            else
                -- Enter new profile
                prompt_for_new_profile(self)
            end
        end
    )
end


---@param item Line
function M:did_select_item(item)
    if item.position[1] == 1 then
        -- Selection profile
        if data.store.profiles then
            prompt_for_profile_select(self)
        else
            prompt_for_new_profile(self)
        end
    else
        -- Selecting service
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
end

function M:hide()
    vim.api.nvim_win_hide(self.winnr)
end

return M
