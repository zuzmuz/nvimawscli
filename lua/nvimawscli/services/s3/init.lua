local utils = require('nvimawscli.utils.buffer')
local itertools = require("nvimawscli.utils.itertools")
local config = require('nvimawscli.config')
---@type S3Handler
local command = require(config.commands .. '.s3')

---@class S3
local M = {}

function M.show(split)
    if not M.bufnr then
        M.load()
    end
    if not M.winnr or not utils.check_if_window_exists(M.winnr) then
        M.winnr = utils.create_window(M.bufnr, split)
    end

    vim.api.nvim_set_current_win(M.winnr)
    M.fetch()
end

function M.load()
    M.bufnr = utils.create_buffer('s3')

    vim.api.nvim_buf_set_keymap(M.bufnr, 'n', '<CR>', '', {
        callback = function()
            local position = vim.api.nvim_win_get_cursor(M.winnr)

            local bucket_name = utils.get_line(M.bufnr, position[1])

            if not bucket_name then
                return
            end

            print('Bucket name: ' .. bucket_name)

            command.show_bucket(bucket_name, function (result, error)
                if error then
                    utils.write_lines_string(M.bufnr, error)
                elseif result then
                    local rows = vim.json.decode(result)
                    print(vim.inspect(rows))
                else
                    utils.write_lines_string(M.bufnr, 'Result was nil')
                end
            end)
        end
    })
end

function M.fetch()
    M.ready = false
    utils.write_lines(M.bufnr, { 'Fetching buckets...' })
    command.list_buckets(function(result, error)
        if error then
            utils.write_lines_string(M.bufnr, error)
        elseif result then
            M.rows = vim.json.decode(result)
            local allowed_positions = M.render(M.rows)
            utils.set_allowed_positions(M.bufnr, allowed_positions)
        else
            utils.write_lines_string(M.bufnr, 'Result was nil')
        end
        M.ready = true
    end)
end

function M.render(rows)
    utils.write_lines(M.bufnr, rows)
    return itertools.imap(rows, function(i, _)
        return { { i, 1 } }
    end)
end


return M
