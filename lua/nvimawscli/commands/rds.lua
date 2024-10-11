local config = require('nvimawscli.config')
local itertools = require('nvimawscli.utils.itertools')
local handler = require('nvimawscli.commands')

---@class RdsHandler
local M = {}

---Fetch the list of rds databases insances
---@param on_result OnResult
function M.list_databases(on_result)
    local query_strings = itertools.imap_values(config.rds.attributes,
        function(value)
            return value.name .. ': ' .. value.value
        end)
    local query_string = table.concat(query_strings, ', ')
    handler.async("aws rds describe-db-instances --query 'DBInstances[].{" ..
                  query_string ..
                  "}'", on_result)
end

return M
