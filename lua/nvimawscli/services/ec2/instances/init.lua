local utils = require('nvimawscli.utils.buffer')
local itertools = require("nvimawscli.utils.itertools")
local config = require('nvimawscli.config')
---@type Ec2Handler
local command = require(config.commands .. '.ec2.instances')
local ui = require('nvimawscli.utils.ui')
local table_renderer = require('nvimawscli.utils.tables')
local TableView = require('nvimawscli.ui.views.tableview')

---@class Ec2InstanceView: TableView
local M = setmetatable({}, { __index = TableView })

---@class Instance
---@field InstanceId string
---@field Name string
---@field PrivateIpAddress string
---@field State string
---@field InstanceType string
---@field KeyName string

M.column_headers = config.ec2.instances.preferred_attributes
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

M.actions = require('nvimawscli.services.ec2.instances.actions')

return M
