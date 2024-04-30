local utils = require('nvimawscli.utils.buffer')
local command = require('nvimawscli.utils.command')
local ui = require('nvimawscli.utils.ui')
local table_renderer = require('nvimawscli.utils.tables')

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
    action = function(instance)
        print('showing details ' .. instance.InstanceId)
    end,
}

instance_actions.start = {
    ask_for_confirmation = true,
    action = function(instance)
        utils.async_command('aws ec2 describe-instances --instance-ids ' .. instance.InstanceId, function(result, error) end)
    end,
}

instance_actions.stop = {
    ask_for_confirmation = true,
    action = function(instance)
        print('stopping ' .. instance.InstanceId)
    end,
}

instance_actions.terminate = {
    ask_for_confirmation = true,
    action = function(instance)
        print('terminating ' .. instance.InstanceId)
    end,
}

instance_actions.connect = {
    ask_for_confirmation = true,
    action = function(instance)
        print('connecting ' .. instance.InstanceId)
        vim.cmd("bel new")
        vim.fn.termopen('aws ec2-instance-connect ssh --instance-id ' .. instance.InstanceId ..
                        ' --private-key-file ' .. instance.KeyName .. '.pem --os-user ubuntu')
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

function self.sort_rows(column, direction)
    table.sort(self.rows, function(a, b)
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
            local position = vim.fn.getcursorcharpos()
            local line_number = position[2]
            local column_number = position[3]

            local item_number = table_renderer.get_item_number_from_row(line_number)

            if item_number > 0 and item_number <= #self.reservations then -- open floating window for instance functions
                local instance = self.reservations[item_number].Instances[1]
                local instance_state = instance.State.Name
                local instance_name = get_instance_name(instance)
                local instance_functions = instance_actions.get(instance_state)

                ui.create_floating_select_popup(nil, instance_functions, config,
                    function(selected_action)
                        local action = instance_functions[selected_action]
                        if instance_actions[action].ask_for_confirmation then
                            ui.create_floating_select_popup(action .. ' instance ' .. instance_name, { 'yes', 'no' }, config,
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
                local column_index = table_renderer.get_column_index_from_position(column_number)
                if self.sorted_by_column_index == column_index then
                    self.sorted_direction = self.sorted_direction * -1
                else
                    self.sorted_by_column_index = column_index
                    self.sorted_direction = 1
                end
                self.sort_rows(config.ec2.columns[column_index], self.sorted_direction)
                self.render(config)
            end
        end
    })
end

function self.fetch(config)
    command.async('aws ec2 describe-instances', function(result, error)
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
    self.rows = {}
    for reservation_index, reservation in ipairs(self.reservations) do
        local instance = reservation.Instances[1]
        local row = {}

        for _, column in ipairs(config.ec2.columns) do
            if column == 'Name' then
                row[column] = get_instance_name(instance)
            elseif column == 'PublicIpAddress' then
                local public_ip = instance.PublicIpAddress
                if not public_ip then
                    public_ip = ''
                end
                row[column] = public_ip
            elseif column == 'State' then
                row[column] = instance.State.Name
            elseif column == 'Type' then
                row[column] = instance.InstanceType
            else
                row[column] = instance[column]
                if not row[column] then
                    row[column] = ''
                end
            end
        end

        self.rows[reservation_index] = row
    end
end

function self.render(config)

    local lines = table_renderer.render(config.ec2.columns,
                                        self.rows,
                                        self.sorted_by_column_index,
                                        self.sorted_direction,
                                        config)
    utils.write_lines(self.bufnr, lines)
end

return self
