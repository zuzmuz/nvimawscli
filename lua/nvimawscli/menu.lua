local utils = require('nvimawscli.utils.buffer')
local config = require('nvimawscli.config')



---@class Menu
---@field private header string[]
---@field private preferred_services_header string[]
---@field private all_services_header string[]
local self = {}


self.header = {
    "AWS            CLI",
    "==================",
}

self.preferred_services_header = {
    "Preferred Services",
    "------------------",
}

self.all_services_header = {
    "All       Services",
    "------------------",
}

---Load the menu
---The menu is the initial buffer and contain the list of aws services available
function self.load()
    self.bufnr = utils.create_buffer('menu')
    self.winnr = vim.api.nvim_get_current_win()

    vim.api.nvim_win_set_buf(self.winnr, self.bufnr)

    vim.api.nvim_buf_set_keymap(self.bufnr, 'n', '<CR>', '', {
        callback = function()
            local line_number = vim.api.nvim_win_get_cursor(self.winnr)[1]
            if line_number <= #self.header + #self.preferred_services_header then
                return
            end
            local service_name = utils.get_line(self.bufnr, line_number)

            local status, service = pcall(require, 'nvimawscli.services.' .. service_name)
            if status then
                service.load()
                vim.api.nvim_win_set_width(self.winnr, config.menu.width)
            else
                vim.api.nvim_err_writeln("Service not implemented yet: " .. service_name)
            end
        end
    })
    utils.write_lines_string(self.bufnr,
        table.concat(self.header, '\n') .. '\n' ..
        table.concat(self.preferred_services_header, '\n') .. '\n' ..
        table.concat(config.preferred_services, '\n'))


    local allowed_positions = {}

    for i, _ in ipairs(config.preferred_services) do
        allowed_positions[#allowed_positions+1] = {
            { #self.header + #self.preferred_services_header + i, 1 }
        }
    end
    utils.set_allowed_positions(self.bufnr, allowed_positions)
end

function self.hide()
    vim.api.nvim_win_hide(self.winnr)
end

function self.show()
end

return self
