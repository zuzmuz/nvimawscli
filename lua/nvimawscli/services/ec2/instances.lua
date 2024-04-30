local utils = require('nvimawscli.utils')
local ui = require('nvimawscli.ui')

local self = {}

-- consider making utils for table rendering (with sorting and stuff)



local instance_actions = {}

function instance_actions.get(state)
    if state == "running" then
        return { "details", "stop", "terminate", "connect" }
    elseif state == "stopped" then
        return { "details", "start", "terminate" }
    end
    return { "details", "terminate" }
end

instance_actions.details = {
    ask_for_confirmation = false,
    action = function(instance_id)
        print('showing details ' .. instance_id)
    end,
}

instance_actions.start = {
    ask_for_confirmation = true,
    action = function(instance_id)
        print('starting ' .. instance_id)
        -- utils.async_command('aws ec2 describe-instances --instance-ids ' .. instance_id, function(result, error) end)
    end,
}

instance_actions.stop = {
    ask_for_confirmation = true,
    action = function(instance_id)
        print('stopping ' .. instance_id)
    end,
}


instance_actions.terminate = {
    ask_for_confirmation = false,
    action = function(instance_id)
        print('terminating ' .. instance_id)
    end,
}

instance_actions.connect = {
    ask_for_confirmation = false,
    action = function(instance_id)
        print('connecting ' .. instance_id)
    end,
}

local function get_instance_name(instance)
    for _, tag in ipairs(instance.Tags) do
        if tag.Key == 'Name' then
            return tag.Value
        end
    end
    return ''
end

function self.sort_table(column, direction)
    table.sort(self.table, function(a, b)
        if direction == 1 then
            return a[column] < b[column]
        end
        return a[column] > b[column]
    end)
end

function self.load(config)
    if not self.bufnr then
        self.bufnr = utils.create_buffer('ec2')
    end

    if not self.winnr or not utils.check_if_window_exists(self.winnr) then
        self.winnr = utils.create_window(self.bufnr, config.submenu)
    end

    vim.api.nvim_set_current_win(self.winnr)

    self.fetch(config)

    vim.api.nvim_buf_set_keymap(self.bufnr, 'n', '<CR>', '', {
        callback = function()
            local position = vim.api.nvim_win_get_cursor(self.winnr)

            local item_number = utils.get_item_number_from_row(position[1])

            if item_number > 0 and item_number <= #self.reservations then -- open floating window for instance functions
                local instance = self.reservations[item_number].Instances[1]
                local instance_state = instance.State.Name
                local instance_name = get_instance_name(instance)
                local instance_functions = instance_actions.get(instance_state)

                ui.create_floating_select_popup(nil, instance_functions, config,
                    function(selected_action)
                        local action = instance_functions[selected_action]
                        ui.create_floating_select_popup(action .. ' instance ' .. instance_name, { 'yes', 'no' }, config,
                            function(confirmation)
                                if confirmation == 1 then -- yes selected
                                    instance_actions[action].action(instance.InstanceId)
                                end
                            end)
                    end)
            elseif position[1] == 1 then -- perform sorting based on column selection
                local column_index = utils.get_column_index_from_position(position[2], self.widths)
                if self.sorted_by_column_index == column_index then
                    self.sorted_direction = self.sorted_direction * -1
                else
                    self.sorted_by_column_index = column_index
                    self.sorted_direction = 1
                end
                self.sort_table(column_index, self.sorted_direction)
                self.render(config)
            end
        end
    })
end

function self.fetch(config)
    utils.async_command('aws ec2 describe-instances', function(result, error)
        if error then
            utils.write_lines_string(self.bufnr, error)
        else
            self.reservations = vim.json.decode(result).Reservations
            self.parse(config)
            self.render(config)
        end
    end)
    utils.write_lines_string(self.bufnr, 'Fetching...')
end

function self.parse(config)
    self.table = {}
    for reservation_index, reservation in ipairs(self.reservations) do
        local instance = reservation.Instances[1]
        local row = {}

        for i, column in ipairs(config.ec2.columns) do
            if column == 'Name' then
                row[i] = get_instance_name(instance)
            elseif column == 'PublicIpAddress' then
                local public_ip = instance.PublicIpAddress
                if not public_ip then
                    public_ip = ''
                end
                row[i] = public_ip
            elseif column == 'State' then
                row[i] = instance.State.Name
            elseif column == 'Type' then
                row[i] = instance.InstanceType
            else
                row[i] = instance[column]
                if not row[i] then
                    row[i] = ''
                end
            end
        end

        self.table[reservation_index] = row
    end
end

function self.render(config)
    local column_names = {}
    for i, column_name in ipairs(config.ec2.columns) do
        if self.sorted_by_column_index == i then
            column_names[i] = column_name .. ' ' .. (self.sorted_direction == 1 and '▲' or '▼')
        else
            column_names[i] = column_name
        end
    end

    local output = utils.create_table_output(column_names, self.table)
    self.lines = output.lines
    self.widths = output.widths

    utils.write_lines(self.bufnr, self.lines)
end

return self
