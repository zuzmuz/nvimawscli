local utils = require('nvimawscli.utils.buffer')
local config = require('nvimawscli.config')

---@class Ec2
local self = {}

function self.load()
    if not self.bufnr then
        self.bufnr = utils.create_buffer('submenu')
    end

    if not self.winnr or not utils.check_if_window_exists(self.winnr) then
        self.winnr = utils.create_window(self.bufnr, config.menu.split)
    end

    vim.api.nvim_set_current_win(self.winnr)

    vim.api.nvim_buf_set_keymap(self.bufnr, 'n', '<CR>', '', {
        callback = function()
            local position = vim.api.nvim_win_get_cursor(self.winnr)

            local subservice_name = utils.get_line(self.bufnr, position[1])


            local status, subservice = pcall(require, 'nvimawscli.services.ec2.' .. subservice_name)

            if status then
                subservice.load(config)
                vim.api.nvim_win_set_width(self.winnr, config.menu.width)
            else
                vim.api.nvim_err_writeln('Subservice not found: ' .. subservice_name)
            end
        end
    })

    utils.write_lines(self.bufnr, config.ec2.prefered_services)
    local allowed_positions = {}
    for i, _ in ipairs(config.ec2.prefered_services) do
        allowed_positions[#allowed_positions+1] = { { i, 1 } }
    end
    utils.set_allowed_positions(self.bufnr, allowed_positions)
end

return self
