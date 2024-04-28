local utils = require('nvimawscli.utils')

local self = {}


function self.load(bufnr, winnr, config)
    self.bufnr = bufnr
    self.winnr = winnr

    vim.api.nvim_set_current_win(self.winnr)

    local result = vim.fn.system({'aws', 'ec2', 'describe-instances'})

    result = vim.json.decode(result)

    print(result['Reservations'][1]['Instances'][1]['InstanceId'])
end

return self
