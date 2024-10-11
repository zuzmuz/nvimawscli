local config = require('nvimawscli.config')

---@type ActionManager
return {
    get = function(_)
        return { "rules" }
    end,
    actions = {
        rules = {
            ask_for_confirmation = false,
            action = function(security_group)
                local details = require('nvimawscli.services.ec2.security_groups.rules')
                details:show(config.details.split, {
                    group_id = security_group.GroupId
                })
            end,
        },
    },
}
