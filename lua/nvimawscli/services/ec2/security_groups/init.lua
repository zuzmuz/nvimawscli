local config = require('nvimawscli.config')
local TableView = require('nvimawscli.ui.views.tableview')

---@type SecurityGroupsCommand
local command = require(config.commands .. '.ec2.security_groups')

---@class SecurityGroupsView: TableView
local M = setmetatable({}, { __index = TableView })

M.name = 'ec2.security_groups'

---@class SecurityGroup
---@field Name string
---@field GroupId string
---@field GroupName string

M.column_headers = config.ec2.security_groups.attributes
M.loading_text = 'Loading ec2 security groups...'

function M:describe(row)
    return row.Name
end

---Fetch the ec2 instances from aws cli and parse the result
function M:fetch_rows(callback)
    command.describe_security_groups(function(result, error)
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

M.action_manager = require('nvimawscli.services.ec2.security_groups.actions')

return M
