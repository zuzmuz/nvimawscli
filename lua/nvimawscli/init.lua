---@class Dashboard
---@field launched boolean
---@field is_setup boolean
---@field launch fun(): nil
---@field setup fun(table): nil
local self = {}

self.launched = false

function self.setup(config)
    require('nvimawscli.config').setup(config)

    vim.api.nvim_create_user_command('Aws', function (opts)
        require('nvimawscli').launch()
    end, {})

    self.is_setup = true
end

--- Launch the Dashboard
function self.launch()
    if self.launched then
        vim.api.nvim_err_writeln("Dashboard already launched")
        return
    end
    if not self.is_setup then
        vim.api.nvim_err_writeln("Dashboard not setup")
        return
    end
    self.launched = true
    require("nvimawscli.menu").load()
end

return self
