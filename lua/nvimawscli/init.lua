local dashboard = {}

function dashboard.setup(config)
    print("Setting up dashboard")
    dashboard.config = config
end

function dashboard.launch()

    local bufnr = vim.api.nvim_create_buf(false, true)
    vim.api.nvim_buf_set_option(bufnr, 'bufhidden', 'wipe')
    vim.api.nvim_buf_set_option(bufnr, 'buftype', 'nofile')
    vim.api.nvim_buf_set_option(bufnr, 'swapfile', false)
    vim.api.nvim_buf_set_option(bufnr, 'modifiable', false)

    local cur_win_id = vim.api.nvim_get_current_win()
    vim.api.nvim_win_set_buf(cur_win_id, bufnr)

    vim.api.nvim_buf_set_option(bufnr, 'modifiable', true)
    vim.api.nvim_buf_set_lines(bufnr, 0, -1, false, {"ec2", "s3"})
    vim.api.nvim_buf_set_option(bufnr, 'modifiable', false)

end

return dashboard
