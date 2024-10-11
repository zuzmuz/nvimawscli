return {
    get = function(_)
        return { "modify" }
    end,
    actions = {
        modify = {
            ask_for_confirmation = false,
            action = function(security_group_rule, group_data)
                print('modify ' .. group_data.group_id .. ' ' .. security_group_rule.Id)
            end,
        },
    },
}
