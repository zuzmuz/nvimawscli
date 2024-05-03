local utils = require('nvimawscli.utils.buffer')
local config = require('nvimawscli.config')
print('config', config.commands)
---@type Ec2Handler
local command = require(config.commands .. '.ec2')
local ui = require('nvimawscli.utils.ui')
local table_renderer = require('nvimawscli.utils.tables')
local instance_actions = require('nvimawscli.services.ec2.instances.instance_actions')

---@class InstanceManager
local self = {}



---@class Instance
---@field Name string
---@field PrivateIpAddress string
---@field State string
---@field Type string
---@field KeyName string


---Sort the rows based on the column and direction
---@param column string: the name of the column header name to use as key for sorting
function self.sort_rows(column, direction)
    table.sort(self.rows, function(a, b)
        if direction == 1 then
            return a[column] < b[column]
        end
        return a[column] > b[column]
    end)
end

function self.load()
    if not self.bufnr then
        self.bufnr = utils.create_buffer('ec2')
    end

    if not self.winnr or not utils.check_if_window_exists(self.winnr) then
        self.winnr = utils.create_window(self.bufnr, config.menu.split)
    end

    vim.api.nvim_set_current_win(self.winnr)

    self.fetch()

    vim.api.nvim_buf_set_keymap(self.bufnr, 'n', '<CR>', '', {
        callback = function()
            if not self.ready then
                return
            end
            local position = vim.fn.getcursorcharpos()
            local line_number = position[2]
            local column_number = position[3]

            local item_number = table_renderer.get_item_number_from_row(line_number)

            if item_number > 0 and item_number <= #self.rows then -- open floating window for instance functions
                local instance = self.rows[item_number]
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
                                        instance_actions[action].action(instance)
                                    end
                                end)
                        else
                            instance_actions[action].action(instance)
                        end
                    end)
            else -- perform sorting based on column selection
                local column_index = table_renderer.get_column_index_from_position(
                    column_number, self.widths)
                if self.sorted_by_column_index == column_index then
                    self.sorted_direction = self.sorted_direction * -1
                else
                    self.sorted_by_column_index = column_index
                    self.sorted_direction = 1
                end
                if column_index then
                    local column_value = config.ec2.get_attribute_name(
                        config.ec2.preferred_attributes[column_index]
                    )
                    self.sort_rows(column_value, self.sorted_direction)
                    self.render(self.rows)
                end
            end
        end
    })
end

---@private
---Fetch the ec2 instances from aws cli and parse the result
function self.fetch()
    self.ready = false
    self.sorted_by_column_index = nil
    utils.write_lines_string(self.bufnr, 'Fetching...')
    command.describe_instances(function(result, error)
        if error then
            utils.write_lines_string(self.bufnr, error)
        elseif result then
            local reservations = vim.json.decode(result).Reservations
            self.rows = self.parse(reservations)
            self.render(self.rows)
        else
            utils.write_lines_string(self.bufnr, 'Result was nil')
        end
        self.ready = true
    end)
end

---@private
---Parse the ec2 instances and store the rows
---@param reservations table: the raw json reservations received from aws ec2 command
---@return Instance[]
function self.parse(reservations)
    local rows = {}
    for reservation_index, reservation in ipairs(reservations) do
        local instance = reservation.Instances[1]
        local row = {}

        for _, column in ipairs(config.ec2.preferred_attributes) do
            local name, value = config.ec2.get_attribute_name_and_value(column, instance)
            row[name] = value
            if not row[name] then
                row[name] = ''
            end
        end

        rows[reservation_index] = row
    end
    return rows
end

---@private
---Render the table containing the ec2 instances into the buffer
---@param rows Instance[]
function self.render(rows)
    local column_names = {}
    for i, column in ipairs(config.ec2.preferred_attributes) do
        if type(column) == 'table' then
            column_names[i] = column[1]
        else
            column_names[i] = column
        end
    end

    local lines, allowed_positions, widths = table_renderer.render(
        column_names,
        rows,
        self.sorted_by_column_index,
        self.sorted_direction,
        config.table)

    self.widths = widths
    utils.write_lines(self.bufnr, lines)
    utils.set_allowed_positions(self.bufnr, allowed_positions)
end

return self
