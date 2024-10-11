local config = require('nvimawscli.config')
local TableView = require('nvimawscli.ui.views.tableview')

---@type Ec2Command
local command = require(config.commands .. '.ec2.instances')


---@class Ec2InstanceView: TableView
local M = setmetatable({}, { __index = TableView })

M.name = 'ec2.instances'

---@class Instance
---@field InstanceId string
---@field Name string
---@field PrivateIpAddress string
---@field State string
---@field InstanceType string
---@field KeyName string

M.column_headers = config.ec2.instances.attributes
M.loading_text = 'Loading ec2 instances...'

function M:describe(row)
    return row.Name
end

function M:fetch_rows(callback)
    command.describe_instances(function(result, error)
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

M.action_manager = require('nvimawscli.services.ec2.instances.actions')

return M
