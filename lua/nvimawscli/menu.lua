local utils = require('nvimawscli.utils')
local services = require('nvimawscli.services')
local self = {}


self.header_section_length = 4

self.header =
    "AWS CLI\n" ..
    "========\n"

self.services_header =
    "Services\n" ..
    "--------\n"

self.services = table.concat(services.names, '\n')

function self.load(bufnr, winnr, config)
    self.bufnr = bufnr
    self.winnr = winnr

    vim.api.nvim_win_set_buf(self.winnr, self.bufnr)

    vim.api.nvim_buf_set_keymap(self.bufnr, 'n', '<CR>', '', {
        callback = function()
            local position = vim.api.nvim_win_get_cursor(self.winnr)

            if position[1] <= self.header_section_length then
                return
            end

            local service = utils.get_line(self.bufnr, position[1])

            if not self.service_bufnr then
                self.service_bufnr = utils.create_buffer()
            end

            if not self.service_winnr then
                self.service_winnr = utils.create_window(self.service_bufnr, config.services)
                vim.api.nvim_win_set_width(self.winnr, config.menu.width)
            end

            services.load(service, self.service_bufnr, self.service_winnr, config)
        end
    })

    utils.write_lines_string(self.bufnr, self.header .. self.services_header .. self.services)
end

return self
