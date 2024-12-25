local config = require('nvimawscli.config')
local bucket = require('nvimawscli.services.s3.bucket')
local ListView = require('nvimawscli.ui.views.listview')

---@type S3Handler
local command = require(config.commands .. '.s3')

---@class S3: ListView
local M = setmetatable({}, { __index = ListView })

M.name = 's3'

M.loading_text = 'Loading buckets...'

function M:fetch_lines(callback)
    command.list_buckets(function(result, error)
        if error then
            callback {
                sections = {{
                    unselectable = true,
                    lines = { error },
                }}
            }
        elseif result then
            local buckets = vim.json.decode(result)
            callback {
                sections = {{
                    title = "Buckets",
                    lines = buckets,
                }}
            }
        else
            callback {
                sections = {{
                    lines = { 'Result was nil' },
                    unselectable = true
                }}
            }
        end
    end)
end

function M:did_select_item(item)
    if item.selectable then
        local bucket_name = item.text
        bucket.show(bucket_name, config.menu.split)
        vim.api.nvim_win_set_width(self.winnr, config.menu.width)
    end
end


return M
