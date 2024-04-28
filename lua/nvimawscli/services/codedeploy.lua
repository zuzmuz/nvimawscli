local self = {}

local utils = require('nvimawscli.utils')


self.subservices = {
    'Applications',
    'Deployments',
}

function self.load(bufnr, winnr, config)

    self.bufnr = bufnr
    self.winnr = winnr

    -- vim.api.nvim_set_current_buf(self.bufnr)
    vim.api.nvim_set_current_win(self.winnr)

    utils.write_lines(self.bufnr, self.subservices)



    -- local result = vim.fn.system({'aws', 'ec2', 'describe-instances'})
    -- local lines = vim.split(result, "\n")
    -- if #lines > 0 then
    --     vim.api.nvim_buf_set_option(self.bufnr, 'modifiable', true)
    --     vim.api.nvim_buf_set_lines(self.bufnr, 0, -1, false, lines)
    --     vim.api.nvim_buf_set_option(self.bufnr, 'modifiable', false)
    -- end
end


return self
