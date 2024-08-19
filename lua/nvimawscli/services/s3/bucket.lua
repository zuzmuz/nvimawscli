local utils = require('nvimawscli.utils.buffer')
local command = require('nvimawscli.commands.s3')
local table_renderer = require('nvimawscli.utils.tables')
local config = require('nvimawscli.config')
---@class S3Bucket
local M = {}

local column_headers = { 'Key', 'Size', 'Last Modified' }

function M.show(bucket_name, split)
    M.bucket_name = bucket_name
    if not M.bufnr then
        M.load()
    end

    if not M.winnr or not vim.api.nvim_win_is_valid(M.winnr) then
        M.winnr = utils.create_window(M.bufnr, split)
    end
    vim.api.nvim_set_current_win(M.winnr)
    M.fetch()
end


function M.load()
    M.bufnr = utils.create_buffer('s3.buckets')

    vim.api.nvim_buf_set_keymap(M.bufnr, 'n', '<CR>', '', {
        callback = function()
            if not M.ready then
                return
            end
            local position = vim.fn.getcursorcharpos()
            local line_number = position[2]
            local column_number = position[3]

            local item_number = table_renderer.get_item_number_from_row(line_number)

            if item_number > 0 and item_number <= #M.rows then
                local item = M.rows[item_number]
                if item then
                    print('Item: ' .. item.Key)
                end
            elseif item_number == 0 then
                M.handle_sort_event(column_number)
            end
        end
    })
end

function M.handle_sort_event(column_number)
    local column_index = table_renderer.get_column_index_from_position(column_number, M.widths)
    if M.sorted_by_column_index == column_index then
        M.sorted_direction = M.sorted_direction * -1
    else
        M.sorted_by_column_index = column_index
        M.sorted_direction = 1
    end
    if column_index then
        local column_value = column_headers[column_index]

        table.sort(M.rows, function(a, b)
            if M.sorted_direction == 1 then
                return a[column_value] < b[column_value]
            end
            return a[column_value] > b[column_value]
        end)
        M.render(M.rows)
    end
end

function M.fetch()
    M.ready = false
    M.next_token = nil
    utils.write_lines(M.bufnr, { 'Fetching content...' })
    command.list_bucket_objects(M.bucket_name, function (result, error)
        if error then
            utils.write_lines_string(M.bufnr, error)
        elseif result then
            local response = vim.json.decode(result)
            M.rows = response.Contents
            local allowed_positions = M.render(M.rows)
            utils.set_allowed_positions(M.bufnr, allowed_positions)
            M.next_token = response.NextToken
        else
            utils.write_lines_string(M.bufnr, 'Result was nil')
        end
        M.ready = true
    end)
end

function M.render(rows)
    local lines, allowed_positions, widths = table_renderer.render(
        column_headers,
        rows,
        M.sorted_by_column_index,
        M.sorted_direction,
        config.table)
    M.widths = widths
    utils.write_lines(M.bufnr, lines)
    return allowed_positions
end

return M