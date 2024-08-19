local config = require('nvimawscli.config')
local handler = require('nvimawscli.commands')

---@class S3Handler
local M = {}

---Fetch the list of s3 buckets
---@param on_result OnResult
function M.list_buckets(on_result)
    handler.async("aws s3api list-buckets --query 'Buckets[].Name'", on_result)
end

---Fetch the list of objects in a bucket
---@param bucket_name string
---@param on_result OnResult
function M.list_bucket_objects(bucket_name, on_result)
    handler.async("aws s3api list-objects-v2 --bucket " .. bucket_name ..
    -- " --query 'Contents[].[Key, Size, LastModified]
                  " --max-items " .. config.s3.max_items, on_result)
end


---Download an object from a bucket
---@param bucket_name string
---@param object_key string
function M.download_bucket_object(bucket_name, object_key)
    local command = "aws s3 cp \"s3://" .. bucket_name .. "/" .. object_key .. "\" ."
    handler.async(command,
                  function (result, error)
        if error then
            vim.api.nvim_err_writeln(error)
        else
            print(result)
        end
    end)
end

return M
