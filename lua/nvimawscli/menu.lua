
local menu = {}

menu.services = {
    "ec2",
    "codedeploy",
    "s3",
    "rds",
    "iam",
    "vpc",
}

menu.header = {
    "AWS CLI",
    "========",
}

menu.services_header = {
    "Services",
    "--------",
}


function menu:load(config)
    self.bufnr = vim.api.nvim_create_buf(false, true)

    vim.api.nvim_buf_set_option(self.bufnr, 'bufhidden', 'wipe')
    vim.api.nvim_buf_set_option(self.bufnr, 'buftype', 'nofile')
    vim.api.nvim_buf_set_option(self.bufnr, 'swapfile', false)
    vim.api.nvim_buf_set_option(self.bufnr, 'modifiable', false)

    self.winnr = vim.api.nvim_get_current_win()

    vim.api.nvim_win_set_buf(self.winnr, self.bufnr)

    vim.api.nvim_buf_set_keymap(self.bufnr, 'n', '<CR>', '', { callback = function()
        local position = vim.api.nvim_win_get_cursor(self.winnr)
        print(position[1], position[2])
    end})

    vim.api.nvim_buf_set_option(self.bufnr, 'modifiable', true)
    vim.api.nvim_buf_set_lines(self.bufnr, 0, -1, false, {
        unpack(self.header),
        unpack(self.services),
        unpack(self.services_header),
    })
    vim.api.nvim_buf_set_option(self.bufnr, 'modifiable', false)

end


return menu
