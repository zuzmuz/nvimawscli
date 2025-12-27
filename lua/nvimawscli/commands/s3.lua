local config = require('nvimawscli.config')
local handler = require('nvimawscli.commands')

---@class S3Command
local M = {}

---Fetch the list of s3 buckets
---@param on_result OnResult
function M.list_buckets(on_result)
    handler.aws_command("s3api", "list-buckets --query 'Buckets[].Name'", on_result)
end

---Fetch the list of objects in a bucket
---@param bucket_name string
---@param prefix string
---@param on_result OnResult
function M.list_bucket_objects(bucket_name, prefix, on_result)
    local prefix_predicate = ""
    if prefix and prefix ~= "" then
        prefix_predicate = " --prefix " .. prefix
    end

    handler.aws_command("s3api", "list-objects-v2 --bucket " .. bucket_name ..
                  prefix_predicate ..
    -- " --query 'Contents[].[Key, Size, LastModified]
                  " --max-items " .. config.s3.max_items, on_result)
end


---Download an object from a bucket
---@param bucket_name string
---@param object_key string
---@param on_result OnResult
function M.download_bucket_object(bucket_name, object_key, on_result)

    local path_table = vim.split(object_key, "/")
    table.remove(path_table, #path_table)
    local folder = table.concat(path_table, "/")
    if folder:sub(1, 1) == "/" then
        folder = folder:sub(2)
    end

    vim.fn.mkdir(folder, "p")

    local arguments = 'cp "s3://' .. bucket_name .. '/' .. object_key .. '" ' .. folder
    handler.aws_command("s3", arguments, on_result)
end

---Delete an object from a bucket
---@param bucket_name string
---@param object_key string
---@param on_result OnResult
function M.delete_bucket_object(bucket_name, object_key, on_result)
    local arguments = 'rm "s3://' .. bucket_name .. '/' .. object_key .. '"'
    handler.aws_command("s3", arguments, on_result)
end

return M
