local self = {}

local utils = require('nvimawscli.utils')


self.subservices = {
    'instances',
    'images',
    'security_groups',
    'elastic_ips',
    'load_balancers',
    'target_groups',
}

function self.load(config)
    if not self.bufnr then
        self.bufnr = utils.create_buffer('submenu')
    end

    if not self.winnr or not utils.check_if_window_exists(self.winnr) then
        self.winnr = utils.create_window(self.bufnr, config.services)
    end

    vim.api.nvim_set_current_win(self.winnr)
    vim.api.nvim_set_current_buf(self.bufnr)

    vim.api.nvim_buf_set_keymap(self.bufnr, 'n', '<CR>', '', {
        callback = function()
            local position = vim.api.nvim_win_get_cursor(self.winnr)

            local subservice_name = utils.get_line(self.bufnr, position[1])


            local status, subservice = pcall(require, 'nvimawscli.services.ec2.' .. subservice_name)

            if status then
                subservice.load(config)
                vim.api.nvim_win_set_width(self.winnr, config.menu.width)
            else
                print('Subservice not found: ' .. subservice_name)
                return
            end
        end
    })

    utils.write_lines(self.bufnr, self.subservices)
end

return self
