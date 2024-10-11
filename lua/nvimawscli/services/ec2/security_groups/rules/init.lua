local config = require('nvimawscli.config')
local TableView = require('nvimawscli.ui.views.tableview')

---@type SecurityGroupsCommand
local command = require(config.commands .. '.ec2.security_groups')

---@class SecurityGroupRulesView: TableView
local M = setmetatable({}, { __index = TableView })

M.name = 'ec2.security_groups.rules'

---@class SecurityGroupRule
---@field Id string
---@field SecurityGroupRuleId string
---@field Description string

M.column_headers = config.ec2.security_group_rules.attributes
M.loading_text = 'Loading ec2 security group rules ...'

function M:describe(row)
    return row.Id
end

function M:fetch_rows(callback)
    command.describe_security_group_rules(self.data.group_id,
        function(result, error)
        if error then
            callback(nil, error)
        elseif result then
            local rows = vim.json.decode(result)
            callback(rows, nil)
        else
            callback(nil, 'Result was nil')
        end
    end)
end

M.action_manager = require('nvimawscli.services.ec2.security_groups.rules.actions')

return M
