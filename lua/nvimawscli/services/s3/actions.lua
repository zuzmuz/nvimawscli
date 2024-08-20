local command = require('nvimawscli.commands.s3')


---@class S3BucketActionsManage
local M = {}

M.actions = {
    "download",
    "delete",
    "download+delete",
    -- "make public",
    -- "make private",
}

---@class S3BucketAction
---@field ask_for_confirmation boolean
---@field action fun(bucket_name: string, bucket_objects: [S3BucketObject])


---@type S3BucketAction
M.download = {
    ask_for_confirmation = false,
    action = function(bucket_name, bucket_objects)
        for _, bucktet_object in ipairs(bucket_objects) do
            command.download_bucket_object(bucket_name, bucktet_object.Key,
                function(result, error)
                    if error then
                        vim.api.nvim_err_writeln(error)
                    elseif result then
                        vim.api.nvim_out_write(result)
                    end
                end)
        end
    end,
}

---@type S3BucketAction
M.delete = {
    ask_for_confirmation = true,
    action = function(bucket_name, bucket_objects)
        for _, bucktet_object in ipairs(bucket_objects) do
            command.delete_bucket_object(bucket_name, bucktet_object.Key,
                function(result, error)
                    if error then
                        vim.api.nvim_err_writeln(error)
                    elseif result then
                        vim.api.nvim_out_write(result)
                    end
                end)
        end
    end,
}

---@type S3BucketAction
M["download+delete"] = {
    ask_for_confirmation = true,
    action = function(bucket_name, bucket_objects)
        for _, bucktet_object in ipairs(bucket_objects) do
            command.download_bucket_object(bucket_name, bucktet_object.Key, function (copy_result, copy_error)
                if copy_error then
                    vim.api.nvim_err_writeln(copy_error)
                elseif copy_result then
                    vim.api.nvim_out_write(copy_result)
                    command.delete_bucket_object(bucket_name, bucktet_object.Key, function (result, error)
                        if error then
                            vim.api.nvim_err_writeln(error)
                        elseif result then
                            vim.api.nvim_out_write(result)
                        end
                    end)
                end
            end)
        end
    end,
}

return M
