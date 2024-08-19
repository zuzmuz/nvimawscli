local command = require('nvimawscli.commands.s3')


---@class S3BucketActionsManage
local M = {}

function M.get(bucket_object)
    return { "download", "delete", "download+delete" } --, "make public", "make private" }
end

---@class S3BucketAction
---@field ask_for_confirmation boolean
---@field action fun(bucket_name: string, bucket_object: S3BucketObject)


---@type S3BucketAction
M.download = {
    ask_for_confirmation = false,
    action = function(bucket_name, bucket_object)
        command.download_bucket_object(bucket_name, bucket_object.Key)
    end,
}

return M
