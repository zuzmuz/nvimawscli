local utils = require('nvimawscli.utils')

local self = {}

function self.get_instance_functions(state)
    if state == "running" then
        return { "details", "stop instance", "terminate instance", "connect" }
    elseif state == "stopped" then
        return { "details", "start instance", "terminate instance" }
    end
    return { "details", "terminate instance" }
end

function self.whatev(floating_winnr, floating_bufnr, state, instance_id)
    vim.api.nvim_buf_set_keymap(floating_bufnr, 'n', '<CR>', '', {
        callback = function()
            local position = vim.api.nvim_win_get_cursor(floating_winnr)
            local item_number = utils.get_item_number_from_row(position[1])

            if item_number > 0 and item_number <= #self.get_instance_functions(state) then
                local function_name = self.get_instance_functions(state)[item_number]
                if function_name == "details" then
                    utils.async_command('aws ec2 describe-instances --instance-ids ' .. instance_id,
                        function(result, error)
                            if error ~= nil then
                                utils.write_lines_string(floating_bufnr, error)
                            else
                                utils.write_lines_string(floating_bufnr, result)
                            end
                        end)
                    utils.write_lines_string(floating_bufnr, 'Fetching...')
                elseif function_name == "stop instance" then
                    utils.async_command('aws ec2 stop-instances --instance-ids ' .. instance_id,
                        function(result, error)
                            if error ~= nil then
                                utils.write_lines_string(floating_bufnr, error)
                            else
                                utils.write_lines_string(floating_bufnr, result)
                            end
                        end)
                    utils.write_lines_string(floating_bufnr, 'Stopping...')
                elseif function_name == "start instance" then
                    utils.async_command('aws ec2 start-instances --instance-ids ' .. instance_id,
                        function(result, error)
                            if error ~= nil then
                                utils.write_lines_string(floating_bufnr, error)
                            else
                                utils.write_lines_string(floating_bufnr, result)
                            end
                        end)
                    utils.write_lines_string(floating_bufnr, 'Starting...')
                elseif function_name == "terminate instance" then
                    utils.async_command('aws ec2 terminate-instances --instance-ids ' .. instance_id,
                        function(result, error)
                            if error ~= nil then
                                utils.write_lines_string(floating_bufnr, error)
                            else
                                utils.write_lines_string(floating_bufnr, result)
                            end
                        end)
                    utils.write_lines_string(floating_bufnr, 'Terminating...')
                end
            end
        end
    })
end

function self.sort_lines_table(column, direction)
    table.sort(self.lines_table, function(a, b)
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
        self.winnr = utils.create_window(self.bufnr, config.services)
        vim.api.nvim_win_set_width(self.winnr, config.services.width)
    end

    vim.api.nvim_set_current_win(self.winnr)

    self.fetch(config)

    vim.api.nvim_buf_set_keymap(self.bufnr, 'n', '<CR>', '', {
        callback = function()
            local position = vim.api.nvim_win_get_cursor(self.winnr)

            local item_number = utils.get_item_number_from_row(position[1])

            if item_number > 0 and item_number <= #self.reservations then
                local instance = self.reservations[item_number].Instances[1]
                local instance_id = instance.InstanceId
                local state = instance.State.Name

                local floating_window = utils.create_floating_window(self.get_instance_functions(state), config)
                local floating_bufnr = floating_window.bufnr
                local floating_winnr = floating_window.winnr

            elseif position[1] == 1 then -- perform sorting based on column selection
                local column_index = utils.get_column_index_from_position(position[2], self.widths)
                if self.sorted_by_column_index == column_index then
                    self.sorted_direction = self.sorted_direction * -1
                else
                    self.sorted_by_column_index = column_index
                    self.sorted_direction = 1
                end
                self.sort_lines_table(column_index, self.sorted_direction)
                self.render(config)
            end
        end
    })
end

function self.fetch(config)
    print("fetching")
    utils.async_command('aws ec2 describe-instances', function(result, error)
        if error ~= nil then
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
    print("parsing")

    self.lines_table = {}
    for reservation_index, reservation in ipairs(self.reservations) do
        local instance = reservation.Instances[1]
        local line_table = {}

        for i, column in ipairs(config.ec2.columns) do
            if column == 'Name' then
                local name = ''
                for _, tag in ipairs(instance.Tags) do
                    if tag.Key == 'Name' then
                        name = tag.Value
                    end
                end
                line_table[i] = name
            elseif column == 'PublicIpAddress' then
                local public_ip = instance.PublicIpAddress
                if not public_ip then
                    public_ip = ''
                end
                line_table[i] = public_ip
            elseif column == 'State' then
                line_table[i] = instance.State.Name
            elseif column == 'Type' then
                line_table[i] = instance.InstanceType
            else
                line_table[i] = instance[column]
                if not line_table[i] then
                    line_table[i] = ''
                end
            end
        end

        self.lines_table[reservation_index] = line_table
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

    local output = utils.create_table_output(column_names, self.lines_table)
    self.lines = output.lines
    self.widths = output.widths

    utils.write_lines(self.bufnr, self.lines)
end

return self
