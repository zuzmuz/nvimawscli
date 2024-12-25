local config = require('nvimawscli.config')
local TableView = require('nvimawscli.ui.views.tableview')

---@type CodeDeployCommand
local command = require(config.commands .. '.codedeploy')


---@class CodeDeployApplicationView: TableView
local M = setmetatable({}, { __index = TableView })

M.name = 'codedeploy.applications'

---@class Application

M.column_headers = config.codedeploy.applications.attributes
M.loading_text = 'Loading codedeploy applications...'

function M:describe(row)
    return row.Name
end

function M:fetch_rows(callback)
    command.list_applications(function(result, error)
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

M.action_manager = require('nvimawscli.services.codedeploy.applications.actions')

return M
