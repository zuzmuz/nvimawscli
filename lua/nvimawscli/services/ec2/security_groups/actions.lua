local config = require('nvimawscli.config')
local command = require(config.commands .. '.ec2.security_groups')

---@class SecurityGroupActionsManage
local M = {}

---@param security_group_item 'security_group' | 'security_group_rule'
function M.get(security_group_item)
    if security_group_item == 'security_group' then
        return { "rules" }
    elseif security_group_item == 'security_group_rule' then
        return { "modify" }
    end
end

M.rules = {
    ask_for_confirmation = false,
    action = function(security_group)
        local details = require('nvimawscli.services.ec2.security_groups.rules')
        details.show(security_group.GroupId, config.details.split)
    end,
}

M.modify = {
    ask_for_confirmation = false,
    action = function(group_id, security_group_rule)
        print('modify ' .. group_id .. ' ' .. security_group_rule.Id)
    end,
}

return M
