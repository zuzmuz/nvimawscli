local config = require("nvimawscli.config")

---@class Dashboard
local M = {}

M.launched = false

function M.setup(c)
    config.setup(c)

    vim.api.nvim_create_user_command('Aws', function (options)
        M.launch(#options.fargs > 0 and options.fargs[1] or nil)
    end, {
        nargs = '?',
    })

    M.is_setup = true
end

--- Launch the Dashboard
function M.launch(command_service)
    if not M.is_setup then
        config.setup({})
    end

    print("launching dashbord", command_service)
    if command_service then

        local status, service = pcall(require, "nvimawscli.services." .. command_service)
        if status then
            service:show("topleft")
            return
        else
            vim.api.nvim_err_writeln("service " .. command_service .. " not supported")
        end
    elseif config.startup_service then
        local status, service = pcall(require, "nvimawscli.services." .. config.startup_service)
        if status then

            service:show("inplace")
            return
        else
            vim.api.nvim_err_writeln("startup service " .. config.startup_service .. " not supported")
        end
    end
    require("nvimawscli.menu"):show("inplace")
end

return M
