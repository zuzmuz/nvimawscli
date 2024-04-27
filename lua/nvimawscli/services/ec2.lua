local ec2 = {}

function ec2.load(bufnr, winnr, config)


    local result = vim.fn.system({'aws', 'ec2', 'describe-instances'})
    local lines = vim.split(result, "\n")
    if #lines > 0 then
        vim.api.nvim_buf_set_option(self.bufnr, 'modifiable', true)
        vim.api.nvim_buf_set_lines(self.bufnr, 0, -1, false, lines)
        vim.api.nvim_buf_set_option(self.bufnr, 'modifiable', false)
    end
end


return ec2
