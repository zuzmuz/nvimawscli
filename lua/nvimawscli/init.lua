---@class Dashboard
---@field launched boolean
---@field is_setup boolean
---@field launch fun(): nil
---@field setup fun(table): nil
local M = {}

M.launched = false

function M.setup(config)
    require('nvimawscli.config').setup(config)

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
    require("nvimawscli.menu").load()
end

return M
