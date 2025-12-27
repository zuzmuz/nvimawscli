local config = require('nvimawscli.config')
local regex = require('nvimawscli.utils.regex')
local Iterable = require('nvimawscli.utils.itertools').Iterable
local handler = require('nvimawscli.commands')

---@class SecurityGroupsCommand
local M = {}

---Fetch the list of security groups
---@param on_result OnResult
function M.describe_security_groups(on_result)
    local query_string = Iterable(config.ec2.security_groups.attributes):imap_values(
        function(value)
            return value.name .. ': ' .. value.value
        end):join(', ')

    handler.aws_command("ec2",
        "describe-security-groups --query 'SecurityGroups[].{" ..
        query_string ..
        "}'", on_result)
end

---Fetch security group rules
---@param group_id string
---@param on_result OnResult
function M.describe_security_group_rules(group_id, on_result)
    local query_string = Iterable(config.ec2.security_group_rules.attributes):imap_values(
        function(value)
            return value.name .. ': ' .. value.value
        end):join(', ')

    handler.aws_command("ec2",  
        "describe-security-group-rules " ..
        "--filters 'Name=group-id,Values=" .. group_id .. "' " ..
        "--query 'SecurityGroupRules[].{" ..
        query_string ..
        "}'", on_result)
end

---Fetch security group rule
function M.describe_security_group_rule(group_id, rule_id, on_result)
    handler.aws_command("ec2",
        "describe-security-group-rules" ..
        " --filters 'Name=group-id,Values=" .. group_id .. "'" ..
        " --security-group-rule-ids " .. rule_id ..
        " --query 'SecurityGroupRules[0]'", on_result)
end

---Modify security group rules
---@param group_id string
---@param rule_id string
---@param rule_details table
---@param on_result OnResult
function M.modify_security_group_rule(group_id, rule_id, rule_details, on_result)
    if rule_details.Source then
        if regex.valid_ipv4(rule_details.Source) then
            rule_details.CidrIpv4 = rule_details.Source
        else
            rule_details.ReferencedGroupId = rule_details.Source
        end
    end
    rule_details.Source = nil

    local security_group_rule = Iterable(rule_details):map(
        function(key, value)
            return key .. '=' .. value
        end):join(',')

    local arguments = "modify-security-group-rules " ..
        "--group-id " .. group_id .. " " ..
        "--security-group-rules " .. "'SecurityGroupRuleId=" .. rule_id ..
        ",SecurityGroupRule={" .. security_group_rule .. "}'"
    handler.aws_command("ec2", arguments, on_result)
end

return M
