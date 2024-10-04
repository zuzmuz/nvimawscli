local config = require('nvimawscli.config')
local itertools = require('nvimawscli.utils.itertools')
local handler = require('nvimawscli.commands')

---@class SecurityGroupsHandler
local M = {}

---Fetch the list of security groups
---@param on_result OnResult
function M.describe_security_groups(on_result)
    local query_strings = itertools.imap_values(config.ec2.security_groups.preferred_attributes,
        function(value)
            return value.name .. ': ' .. value.value
        end)
    local query_string = table.concat(query_strings, ', ')
    handler.async("aws ec2 describe-security-groups --query 'SecurityGroups[].{" ..
                  query_string ..
                  "}'", on_result)
end


return M
