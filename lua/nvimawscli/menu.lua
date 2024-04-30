local utils = require('nvimawscli.utils.buffer')
local self = {}


self.header = {
    "AWS  CLI",
    "========",
}

self.services_header = {
    "Services",
    "--------",
}

self.services = {
    'ec2',
    'codedeploy',
    's3',
    'rds',
    'iam',
    'vpc',
}

function self.load(config)
    self.bufnr = utils.create_buffer('menu')
    self.winnr = vim.api.nvim_get_current_win()

    vim.api.nvim_win_set_buf(self.winnr, self.bufnr)

    vim.api.nvim_buf_set_keymap(self.bufnr, 'n', '<CR>', '', {
        callback = function()
            local position = vim.api.nvim_win_get_cursor(self.winnr)
            if position[1] <= #self.header + #self.services_header then
                return
            end
            local service_name = utils.get_line(self.bufnr, position[1])

            local status, service = pcall(require, 'nvimawscli.services.' .. service_name)
            if status then
                service.load(config)
                vim.api.nvim_win_set_width(self.winnr, config.menu.width)
            else
                vim.api.nvim_err_writeln("Service not implemented yet: " .. service_name)
            end
        end
    })
    utils.write_lines_string(self.bufnr,
        table.concat(self.header, '\n') .. '\n' ..
        table.concat(self.services_header, '\n') .. '\n' ..
        table.concat(self.services, '\n'))
end

function self.hide()
    vim.api.nvim_win_hide(self.winnr)
end

function self.show()
end

return self
