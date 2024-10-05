local config = require('nvimawscli.config')
---@type SecurityGroupsHandler
local command = require(config.commands .. '.ec2.security_groups')
local ui = require('nvimawscli.utils.ui')

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
        ui.create_floating_input_popup('enter new value', 20, 1, config.table,
            function(new_value)
                print('new value: ' .. new_value)
                command.modify_security_group_rule(group_id, security_group_rule.Id, new_value,
                    function(result, error)
                       if error then
                            vim.api.nvim_err_writeln(error)
                            return
                        end
                        if result then
                            print('result: ' .. result)
                            return
                        end
                        vim.api.nvim_err_writeln('Result was nil')
                    end)
            end)
    end,
}

return M
