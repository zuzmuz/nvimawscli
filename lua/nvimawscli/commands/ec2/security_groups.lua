local config = require('nvimawscli.config')
local regex = require('nvimawscli.utils.regex')
local itertools = require('nvimawscli.utils.itertools')
local handler = require('nvimawscli.commands')

---@class SecurityGroupsCommand
local M = {}

---Fetch the list of security groups
---@param on_result OnResult
function M.describe_security_groups(on_result)
    local query_strings = itertools.imap_values(config.ec2.security_groups.attributes,
        function(value)
            return value.name .. ': ' .. value.value
        end)
    local query_string = table.concat(query_strings, ', ')
    handler.async("aws ec2 describe-security-groups --query 'SecurityGroups[].{" ..
                  query_string ..
                  "}'", on_result)
end

---Fetch security group rules
---@param group_id string
---@param on_result OnResult
function M.describe_security_group_rules(group_id, on_result)
    local query_strings = itertools.imap_values(config.ec2.security_group_rules.attributes,
        function(value)
            return value.name .. ': ' .. value.value
        end)
    local query_string = table.concat(query_strings, ', ')
    handler.async("aws ec2 describe-security-group-rules " ..
                  "--filters 'Name=group-id,Values=" .. group_id .. "' " ..
                  "--query 'SecurityGroupRules[].{" ..
                  query_string ..
                  "}'", on_result)
end

---Fetch security group rule
function M.describe_security_group_rule(group_id, rule_id, on_result)
    handler.async("aws ec2 describe-security-group-rules" ..
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
            -- NOTE: maybe I need to verify
            rule_details.ReferenceGroupId = rule_details.Source
        end
    end
    rule_details.Source = nil

    local security_group_rules = itertools.map(rule_details,
        function(key, value)
            return key .. '=' .. value
        end)
    local security_group_rule = table.concat(security_group_rules, ',')
    local command = "aws ec2 modify-security-group-rules " ..
                    "--group-id " .. group_id .. " " ..
                    "--security-group-rules " .. "'SecurityGroupRuleId=" .. rule_id ..
                    ",SecurityGroupRule={" .. security_group_rule .. "}'"
    print(command)
    handler.async(command, on_result)
end

return M
