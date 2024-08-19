local utils = require('nvimawscli.utils.buffer')

---@class S3Bucket
local M = {}

function M.show(split)
    if not M.bufnr then
        M.load()
    end

    if not M.winnr or not vim.api.nvim_win_is_valid(M.winnr) then
        M.winnr = utils.creat_window(M.bufnr, split)
    end
    vim.api.nvim_set_current_win(M.winnr)
    M.fetch()
end


function M.load()
    M.bufnr = utils.create_buffer('s3.buckets')

end
