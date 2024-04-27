local utils = require('nvimawscli.utils')
local services = require('nvimawscli.services')
local self = {}


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
    print("Current buffer: " .. self.bufnr .. " Current window: " .. self.winnr)
    vim.api.nvim_win_set_buf(self.winnr, self.bufnr)

    vim.api.nvim_buf_set_keymap(self.bufnr, 'n', '<CR>', '', {
        callback = function()
            local position = vim.api.nvim_win_get_cursor(self.winnr)
            local service = utils.get_line(self.bufnr, position[1])

            local new_bufnr = utils.create_buffer()

            vim.api.nvim_open_win(0, false, {
                split = 'left',
                win = 0
            })
            -- local new_winnr = utils.create_window(new_bufnr, config.menu)

            vim.api.nvim_win_set_width(self.winnr, config.menu.width)



            -- print("Current buffer: " .. new_bufnr .. " Current window: " .. new_winnr)
            -- services.load(service, new_bufnr, new_winnr, config)
        end
    })

    utils.write_lines(self.bufnr, self.header .. self.services_header .. self.services)
end

return self
