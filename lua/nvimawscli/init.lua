local utils = require('nvimawscli.utils')
local dashboard = {}

dashboard.config = {
    menu = {
        prefered_services = {
            "ec2",
            "codedeply",
            "s3",
            "rds",
            "iam",
            "vpc",
        },
        split = "vertical",
        width = 20,
        height = 20,
    },
    services = {
        split = "vertical",
        width = 20,
        height = 20,
    }
}

function dashboard.setup(config)
    print("Setting up dashboard")
    dashboard.config = config
end

function dashboard.launch()
    local menu = require("nvimawscli.menu")

    local bufnr = utils.create_buffer()
    local winnr = vim.api.nvim_get_current_win()

    menu.load(bufnr, winnr, dashboard.config)
end

return dashboard
