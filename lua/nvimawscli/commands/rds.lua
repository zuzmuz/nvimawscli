local config = require('nvimawscli.config')
local Iterable = require('nvimawscli.utils.itertools').Iterable
local handler = require('nvimawscli.commands')

---@class RdsCommand
local M = {}

---Fetch the list of rds databases insances
---@param on_result OnResult
function M.describe_databases(on_result)
    local query_string = Iterable(config.rds.attributes):imap_values(
        function(value)
            return value.name .. ': ' .. value.value
        end):join(', ')

    handler.aws_command("rds",
        "describe-db-instances --query 'DBInstances[].{" ..
        query_string ..
        "}'", on_result)
end

return M
