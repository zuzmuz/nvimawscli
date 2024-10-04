local config = require('nvimawscli.config')
local handler = require('nvimawscli.commands')

---@class RdsHandler
local M = {}

---Fetch the list of rds databases insances
---@param on_result OnResult
function M.list_databases(on_result)
    handler.async("aws rds describe-db-instances --query 'DBInstances[].DBInstanceIdentifier'", on_result)
end

return M
