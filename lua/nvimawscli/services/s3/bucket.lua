local config = require('nvimawscli.config')
local TableView = require('nvimawscli.ui.views.tableview')
local bucket_actions = require('nvimawscli.services.s3.actions')


---@type S3Command
local command = require(config.commands .. '.s3')

---@class S3BucketView: TableView
local M = setmetatable({}, { __index = TableView })

M.name = 's3.bucket'


---@class S3BucketObject
---@field Key string
---@field Size number
---@field LastModified string


M.column_headers = {
    { name = 'Key' },
    { name = 'Size' },
    { name = 'LastModified' }
}

M.loading_text = 'Loading Bucket content ...'

M.filter_fields = { 'Key' }

function M:describe(row)
    return row.Key
end

function M:fetch_rows(callback)
    command.list_bucket_objects(self.data.bucket_name, function (result, error)
        if error then
            callback(nil, error)
        elseif result then
            local response = vim.json.decode(result)
            self.next_token = response.NextToken
            callback(response.Contents, nil)
        else
            callback(nil, 'Result was nil')
        end
    end)

            --     local available_actions = bucket_actions.actions
            --     popup.create_floating_select(nil, nil, available_actions, config.table,
            --         function (selected_action)
            --             local action = available_actions[selected_action]
            --             if bucket_actions[action].ask_for_confirmation then
            --                 popup.create_floating_select(
            --                     action .. ' all',
            --                     nil,
            --                     { 'yes', 'no' },
            --                     config.table,
            --                     function (confirmation)
            --                         if confirmation == 1 then
            --                             bucket_actions[action].action(M.bucket_name, M.rows)
            --                         end
            --                     end)
            --             else
            --                 bucket_actions[action].action(M.bucket_name, M.rows)
            --             end
            --         end)
            -- elseif M.next_token then
            --     print('get more content')
            -- end
            -- TODO: add footers to table view
end

M.action_manager = require('nvimawscli.services.s3.actions')
M.action_fields = {
    {
        label = 'actions on selected field',
        action = nil,
    },
    {
        label = 'fetch next page',
        action = nil,
    },
}

return M
