local utils = require('nvimawscli.utils.buffer')
local itertools = require("nvimawscli.utils.itertools")
local config = require('nvimawscli.config')
---@type SecurityGroupsHandler
local command = require(config.commands .. '.ec2.security_groups')
local table_renderer = require('nvimawscli.utils.tables')

---@class SecurityGroupRulesManager
local M = {}

function M.load(group_id, split)
    M.group_id = group_id

    if not M.bufnr then
        M.bufnr = utils.create_buffer('ec2.security_groups.rules')
    end

    if not M.winnr or not utils.check_if_window_exists(M.winnr) then
        M.winnr = utils.create_window(M.bufnr, split)
    end

    vim.api.nvim_set_current_win(M.winnr)

    M.fetch()
end

---@private
---Handle the sort event when a column header is clicked
---@param column_number number: the column number clicked
function M.handle_sort_event(column_number)
    local column_index = table_renderer.get_column_index_from_position(column_number, M.widths)
    if M.sorted_by_column_index == column_index then
        M.sorted_direction = M.sorted_direction * -1
    else
        M.sorted_by_column_index = column_index
        M.sorted_direction = 1
    end
    if column_index then
        local column_value = config.ec2.instances.preferred_attributes[column_index].name
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
    utils.write_lines_string(M.bufnr, 'Fetching rules for group ' .. M.group_id .. ' ...')
    command.describe_security_group_rules(M.group_id,
        function(result, error)
            if error then
                utils.write_lines_string(M.bufnr, error)
            end
            if result then
                M.rows = vim.json.decode(result)
                local allowed_positions = M.render(M.rows)
                utils.set_allowed_positions(M.bufnr, allowed_positions)
            else
                utils.write_lines_string(M.bufnr, 'Result was nil')
            end
            M.ready = true
        end)
end

---@private
---Render the table containing the ec2 instances into the buffer
---@param rows Instance[]
---@return number[][][]: The positions the cursor is allowed to be at
function M.render(rows)
    local column_names = itertools.imap_values(config.ec2.security_group_rules.preferred_attributes,
        function(attribute)
            return attribute.name
        end)
    local lines, allowed_positions, widths = table_renderer.render(
        column_names,
        rows,
        M.sorted_by_column_index,
        M.sorted_direction,
        config.table)

    M.widths = widths
    utils.write_lines(M.bufnr, lines)
    return allowed_positions
end

return M


