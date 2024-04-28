local utils = require('nvimawscli.utils')

local self = {}


function self.load(bufnr, winnr, config)
    self.bufnr = bufnr
    self.winnr = winnr

    vim.api.nvim_set_current_win(self.winnr)


    utils.async_command('aws ec2 describe-instances', function (result)
        self.handle(result)
    end)

    utils.write_lines_string(self.bufnr, 'Fetching...')
end


function self.handle(result)
    self.reservations = vim.json.decode(result).Reservations

    self.lines_table = {
        { 'name', 'instanceID', 'state', 'type', 'privateIP', 'publicIP', }
    }

    for i, reservation in ipairs(self.reservations) do
        local instance = reservation.Instances[1]
        local name = ''
        for _, tag in ipairs(instance.Tags) do
            if tag.Key == 'Name' then
                name = tag.Value
            end
        end
        local public_ip = instance.PublicIpAddress

        if not public_ip then
            public_ip = ''
        end

        self.lines_table[i + 1] = {
            name,
            instance.InstanceId,
            instance.State.Name,
            instance.InstanceType,
            instance.PrivateIpAddress,
            public_ip,
        }
    end

    self.lines = utils.create_table_output(self.lines_table)

    utils.write_lines(self.bufnr, self.lines)
end

return self
