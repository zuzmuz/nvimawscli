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

function self.load(bufnr, winnr, config)
    self.bufnr = bufnr
    self.winnr = winnr

    vim.api.nvim_set_current_win(self.winnr)
    vim.api.nvim_set_current_buf(self.bufnr)

    vim.api.nvim_buf_set_keymap(self.bufnr, 'n', '<CR>', '', {
        callback = function()
            local position = vim.api.nvim_win_get_cursor(self.winnr)

            local subservice_name = utils.get_line(self.bufnr, position[1])

            if not self.subservice_bufnr then
                self.subservice_bufnr = utils.create_buffer()
            end

            if not self.subservice_winnr then
                self.subservice_winnr = utils.create_window(self.subservice_bufnr, config.services)
                vim.api.nvim_win_set_width(self.winnr, config.services.width)
            end

            local status, subservice = pcall(require, 'nvimawscli.services.ec2.' .. subservice_name)

            if status then
                subservice.load(self.subservice_bufnr, self.subservice_winnr, config)
            else
                print('Subservice not found: ' .. subservice_name)
                return
            end
        end
    })

    utils.write_lines(self.bufnr, self.subservices)
end

return self