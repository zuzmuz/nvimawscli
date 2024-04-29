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


function self.load(bufnr, winnr, config)
    self.bufnr = bufnr
    self.winnr = winnr

    vim.api.nvim_set_current_win(self.winnr)

    self.refresh(config)

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

                vim.api.nvim_buf_set_keymap(floating_bufnr, 'n', '<CR>', '', {
                    callback = function()
                        local position = vim.api.nvim_win_get_cursor(floating_winnr)
                        local item_number = utils.get_item_number_from_row(position[1])

                        if item_number > 0 and item_number <= #self.get_instance_functions(state) then
                            local function_name = self.get_instance_functions(state)[item_number]
                            if function_name == "details" then
                                utils.async_command('aws ec2 describe-instances --instance-ids ' .. instance_id, function (result, error)
                                    if error ~= nil then
                                        utils.write_lines_string(floating_bufnr, error)
                                    else
                                        utils.write_lines_string(floating_bufnr, result)
                                    end
                                end)
                                utils.write_lines_string(floating_bufnr, 'Fetching...')
                            elseif function_name == "stop instance" then
                                utils.async_command('aws ec2 stop-instances --instance-ids ' .. instance_id, function (result, error)
                                    if error ~= nil then
                                        utils.write_lines_string(floating_bufnr, error)
                                    else
                                        utils.write_lines_string(floating_bufnr, result)
                                    end
                                end)
                                utils.write_lines_string(floating_bufnr, 'Stopping...')
                            elseif function_name == "start instance" then
                                utils.async_command('aws ec2 start-instances --instance-ids ' .. instance_id, function (result, error)
                                    if error ~= nil then
                                        utils.write_lines_string(floating_bufnr, error)
                                    else
                                        utils.write_lines_string(floating_bufnr, result)
                                    end
                                end)
                                utils.write_lines_string(floating_bufnr, 'Starting...')
                            elseif function_name == "terminate instance" then
                                utils.async_command('aws ec2 terminate-instances --instance-ids ' .. instance_id, function (result, error)
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


            elseif position[1] == 1 then
                local column = utils.get_column_index_from_position(position[2], self.widths)
                if self.sorted_by == column then
                    self.sorted_direction = self.sorted_direction * -1
                else
                    self.sorted_by = column
                    self.sorted_direction = 1
                end
                self.sort_lines_table(column)
                self.render(config)
            end
        end
    })
end

function self.refresh(config)
    utils.async_command('aws ec2 describe-instances', function (result, error)
        if error ~= nil then
            utils.write_lines_string(self.bufnr, error)
        else
            self.reservations = vim.json.decode(result).Reservations
            self.handle(config)
        end
    end)

    utils.write_lines_string(self.bufnr, 'Fetching...')
end

function self.sort_lines_table(column, direction)
    table.sort(self.lines_table, function(a, b)
        if direction == 1 then
            return a[column] < b[column]
        end
        return a[column] > b[column]
    end)
end

function self.handle(config)
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
    self.render(config)
end

function self.render(config)
    local output = utils.create_table_output(config.ec2.columns, self.lines_table)
    self.lines = output.lines
    self.widths = output.widths

    utils.write_lines(self.bufnr, self.lines)
end

return self
