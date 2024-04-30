local self = {}

self.launched = false

function self.setup(config)
    require('nvimawscli.config').setup(config)
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
