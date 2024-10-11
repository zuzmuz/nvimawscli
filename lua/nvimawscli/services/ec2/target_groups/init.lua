local utils = require('nvimawscli.utils.buffer')
local config = require('nvimawscli.config')
local itertools = require('nvimawscli.utils.itertools')
local table_renderer = require('nvimawscli.utils.tables')

---@type Ec2Handler
local command = require(config.commands .. '.ec2')

---@class TargetGroupsManager
local M = {}

---Sort the rows based on the column and direction
---@param column string: the name of the column header name to use as key for sorting
function M.sort_rows(column, direction)
    table.sort(M.rows, function(a, b)
        if direction == 1 then
            return a[column] < b[column]
        end
        return a[column] > b[column]
    end)
end

-- TODO: review target groups when the time comes

function M.load()
    print("loading target groups functionality")

    if not M.bufnr then
        M.bufnr = utils.create_buffer('ec2.target_groups')
    end

    if not M.winnr or not utils.check_if_window_exists(M.winnr) then
        M.winnr = utils.create_window(M.bufnr, config.menu.split)
    end

    vim.api.nvim_set_current_win(M.winnr)

    M.fetch()

    vim.api.nvim_buf_set_keymap(M.bufnr, 'n', '<CR>', '', {
        callback = function()
            if not M.ready then
                return
            end

            local position = vim.fn.getcursorcharpos()
            local line_number = position[2]
            local column_number = position[3]

            local item_number = table_renderer.get_item_number_from_row(line_number)
            if item_number > 0 and item_number < #M.rows then
                -- To be implemente 
            else
                local column_index = table_renderer.get_column_index_from_position(
                    column_number, M.widths
                )
                if M.sorted_by_column_index == column_index then
                    M.sorted_direction = M.sorted_direction * -1
                else
                    M.sorted_by_column_index = column_index
                    M.sorted_direction = 1
                end

                if column_index then
                    local column_value = config.ec2.get_attribute_name(
                        config.ec2.target_groups.attributes[column_index]
                    )
                    M.sort_rows(column_value, M.sorted_direction)
                    M.render(M.rows)
                end
            end
        end
    })
end

---@private
---Fetch ec2 target groups from aws clia and parse the result
function M.fetch()
    M.ready = false
    utils.write_lines_string(M.bufnr, 'Fetching...')
    command.describe_target_groups(function(result, error)
        if error then
            utils.write_lines_string(M.bufnr, error)
        elseif result then
            local target_groups = vim.json.decode(result).TargetGroups
            M.rows = M.parse(target_groups)
            local allowed_positions = M.render(M.rows)
            utils.set_allowed_positions(M.bufnr, allowed_positions)
        else
            utils.write_lines_string(M.bufnr, 'Result was nil')
        end
        M.ready = true
    end)
end

---@private
---Parse target groups result and store in rows
---@param target_groups table: the raw json target groups
function M.parse(target_groups)
    return itertools.imap_values(target_groups,
        function(target_group)
            return itertools.associate_values(config.ec2.target_groups.attributes,
                function(attribute)
                    return config.ec2.get_attribute_name_and_value(attribute, target_group)
                end
            )
        end
    )
end

---@private
---Render the table containing ec2 target groups into the buffer
---@return number[][][]: the position the cursor is allows to be at
function M.render(rows)
    local column_names = itertools.imap_values(config.ec2.target_groups.attributes,
        function(attribute)
            return config.ec2.get_attribute_name(attribute)
        end
    )
    local lines, allowed_positions, widths = table_renderer.render(
        column_names,
        rows,
        M.sorted_by_column_index,
        M.sorted_direction,
        config.table
    )
    M.widths = widths
    utils.write_lines(M.bufnr, lines)
    return allowed_positions
end

return M
