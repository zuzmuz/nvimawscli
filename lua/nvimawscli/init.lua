local config = require("nvimawscli.config")

---@class Dashboard
local M = {}

M.launched = false

function M.setup(c)
    config.setup(c)

    vim.api.nvim_create_user_command('Aws', function (options)
        M.launch()
        if options.args then
            require("nvimawscli.menu").show("topleft")
        end
    end, {
        nargs = '?',
    })

    M.is_setup = true
end

--- Launch the Dashboard
function M.launch()
    if M.launched then
        return
    end
    if not M.is_setup then
        config.setup({})
    end

    M.launched = true
    if config.startup_service then
        local status, service = pcall(require, "nvimawscli.services." .. config.startup_service)
        if status then
            service.load("inplace")
            return
        else
            vim.api.nvim_err_writeln("startup service " .. config.startup_service .. " not supported")
        end
    end
    require("nvimawscli.menu").show("inplace")
end

return M
