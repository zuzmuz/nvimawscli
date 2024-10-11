local utils = require('nvimawscli.utils.buffer')
local itertools = require("nvimawscli.utils.itertools")
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
            callback({ { text = error, selectable = false } })
        elseif result then
            local buckets = vim.json.decode(result)
            local lines = itertools.imap_values(buckets, function(bucket_name)
                return { text = bucket_name, selectable = true }
            end)
            callback(lines)
        else
            callback({ { text = 'Result was nil', selectable = false } })
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
