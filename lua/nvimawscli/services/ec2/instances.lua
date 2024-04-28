local utils = require('nvimawscli.utils')

local self = {}


function self.load(bufnr, winnr, config)
    self.bufnr = bufnr
    self.winnr = winnr

    vim.api.nvim_set_current_win(self.winnr)

    local result = vim.fn.system({
        'aws', 'ec2', 'describe-instances',
    })

    self.reservations = vim.json.decode(result).Reservations

    self.lines_table= {
        { 'name', 'instanceID' }
    }

    for i, reservation in ipairs(self.reservations) do
        local instance = reservation.Instances[1]
        local name = ''
        for _, tag in ipairs(instance.Tags) do
            if tag.Key == 'Name' then
                name = tag.Value
            end
        end
        self.lines_table[i+1] = { name, instance.InstanceId }
    end


    self.lines = {}
    self.widths = { 0, 0 }

    for _, line in ipairs(self.lines_table) do
        for i, value in ipairs(line) do
            if #value > self.widths[i] then
                self.widths[i] = #value
            end
        end
    end

    for i, line in ipairs(self.lines_table) do
        self.lines[i] = ''
        for j, value in ipairs(line) do
            self.lines[i] = self.lines[i] .. value
            self.lines[i] = self.lines[i] .. string.rep(' ', self.widths[j] - #value + 1)
        end
    end

    utils.write_lines(self.bufnr, self.lines)

end

return self
