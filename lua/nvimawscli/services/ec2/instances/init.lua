local utils = require('nvimawscli.utils.buffer')
local itertools = require("nvimawscli.utils.itertools")
local config = require('nvimawscli.config')
---@type Ec2Handler
local command = require(config.commands .. '.ec2')
local ui = require('nvimawscli.utils.ui')
local table_renderer = require('nvimawscli.utils.tables')
local instance_actions = require('nvimawscli.services.ec2.instances.actions')

---@class InstanceManager
local M = {}

---@class Instance
---@field InstanceId string
---@field Name string
---@field PrivateIpAddress string
---@field State string
---@field InstanceType string
---@field KeyName string


---Sort the rows based on the column and direction
---@param column string: the name of the column header name to use as key for sorting
---@param direction number: 1 for ascending, -1 for descending
function M.sort_rows(column, direction)
    table.sort(M.rows, function(a, b)
        if direction == 1 then
            return a[column] < b[column]
        end
        return a[column] > b[column]
    end)
end

function M.load(split)
    if not M.bufnr then
        M.bufnr = utils.create_buffer('ec2.instances')
    end

    if not M.winnr or not utils.check_if_window_exists(M.winnr) then
        M.winnr = utils.create_window(M.bufnr, split)
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

            if item_number > 0 and item_number <= #M.rows then
                -- open floating window for instance functions
                local instance = M.rows[item_number]
                local available_actions = instance_actions.get(instance)

                ui.create_floating_select_popup(nil, available_actions, config.table,
                    function(selected_action)
                        local action = available_actions[selected_action]
                        if instance_actions[action].ask_for_confirmation then
                            ui.create_floating_select_popup(
                                action .. ' instance ' .. instance.Name,
                                { 'yes', 'no' },
                                config.table,
                                function(confirmation)
                                    if confirmation == 1 then -- yes selected
                                        instance_actions[action].action(instance,
                                            function(result)
                                                print('Result: ', vim.inspect(result))
                                            end)
                                    end
                                end)
                        else
                            instance_actions[action].action(instance)
                        end
                    end)
            else -- perform sorting based on column selection
                M.handle_sort_event(column_number)
            end
        end
    })
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
        M.sort_rows(column_value, M.sorted_direction)
        M.render(M.rows)
    end
end

---@private
---Fetch the ec2 instances from aws cli and parse the result
function M.fetch()
    M.ready = false
    M.sorted_by_column_index = nil
    utils.write_lines_string(M.bufnr, 'Fetching...')
    command.describe_instances(function(result, error)
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

---@private
---Render the table containing the ec2 instances into the buffer
---@param rows Instance[]
---@return number[][][]: The positions the cursor is allowed to be at
function M.render(rows)
    local column_names = itertools.imap_values(config.ec2.instances.preferred_attributes,
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
