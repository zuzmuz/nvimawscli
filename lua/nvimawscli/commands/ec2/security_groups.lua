local config = require('nvimawscli.config')
local regex = require('nvimawscli.utils.regex')
local itertools = require('nvimawscli.utils.itertools')
local handler = require('nvimawscli.commands')

---@class SecurityGroupsHandler
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

---Modify security group rules
---@param group_id string
---@param rule_id string
---@param source string?
---@param description string?
---@param on_result OnResult
function M.modify_security_group_rule(group_id, rule_id, source, on_result)
    local security_group_rule = ""
    if source then
        if regex.valid_ipv4(source) then
            security_group_rule = security_group_rule .. "CidrIpv4=" .. source
        else
            -- NOTE: maybe I need to verify
            security_group_rule = security_group_rule .. "ReferenceGroupId=" .. source
        end
    end
    -- if description then
    --     security_group_rule.Description = description
    -- end

    local command = "aws ec2 modify-security-group-rules " ..
                    "--group-id " .. group_id .. " " ..
                    "--security-group-rules " .. "'SecurityGroupRuleId=" .. rule_id ..
                    ",SecurityGroupRule={" .. security_group_rule .. "}'"
    print(command)
    handler.async(command, on_result)
end

return M
