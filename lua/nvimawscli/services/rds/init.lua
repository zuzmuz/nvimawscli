local config = require('nvimawscli.config')
local instance = require('nvimawscli.services.rds.instance')
local TableView = require('nvimawscli.ui.views.tableview')

---@type RdsCommand
local command = require(config.commands .. '.rds')

---@class RdsView: TableView
local M = setmetatable({}, { __index = TableView })

M.name = 'rds'

M.column_headers = config.rds.attributes
M.loading_text = 'Loading rds databases...'

function M:describe(row)
    return row.InstanceName
end

function M:fetch_rows(callback)
    command.describe_databases(function(result, error)
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

return M
