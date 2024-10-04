local config = require('nvimawscli.config')
local command = require(config.commands .. '.ec2.security_groups')

---@class SecurityGroupActionsManage
local M = {}

function M.get(security_group)
    return { "rules" }
end

---@class SecurityGroupAction
---@field ask_for_confirmation boolean
---@field action fun(instance: SecurityGroup)


---@type SecurityGroupAction
M.rules = {
    ask_for_confirmation = false,
    action = function(security_group)
        local details = require('nvimawscli.services.ec2.security_groups.rules')
        details.load(security_group.GroupId, config.details.split)
    end,
}

return M
