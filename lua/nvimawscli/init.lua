local config = require("nvimawscli.config")
---@class Dashboard
---@field launched boolean
---@field is_setup boolean
---@field launch fun(): nil
---@field setup fun(table): nil
local M = {}

M.launched = false

function M.setup(c)
    config.setup(c)

    vim.api.nvim_create_user_command('Aws', function (opts)
        require('nvimawscli').launch()
    end, {})

    M.is_setup = true
end

--- Launch the Dashboard
function M.launch()
    if M.launched then
        vim.api.nvim_err_writeln("Dashboard already launched")
        return
    end
    if not M.is_setup then
        vim.api.nvim_err_writeln("Dashboard not setup")
        return
    end
    M.launched = true

    if config.startup_service then
        local status, service = pcall(require, "nvimawscli.services." .. config.startup_service)
        if status then
            service.load()
            return
        else
            vim.api.nvim_err_writeln("startup service " .. config.startup_service .. " not supported")
        end
    end
    require("nvimawscli.menu").load()
end

return M
