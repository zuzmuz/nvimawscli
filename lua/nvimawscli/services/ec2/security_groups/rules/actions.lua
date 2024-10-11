local config = require('nvimawscli.config')

---@type ActionManager
return {
    get = function(_)
        return { "edit" }
    end,
    actions = {
        edit = {
            ask_for_confirmation = false,
            action = function(security_group_rule, group_data)
                print('modify ' .. group_data.group_id .. ' ' .. security_group_rule.Id)
                local edit_view = require('nvimawscli.services.ec2.security_groups.rules.edit')
                edit_view:show(config.details.split, {
                    group_id = group_data.group_id,
                    rule = security_group_rule
                })
            end,
        },
    },
}
