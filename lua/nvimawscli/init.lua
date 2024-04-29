local utils = require('nvimawscli.utils')
local self = {}

self.config = {
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
        width = 15,
        height = 20,
    },
    services = {
        split = "vertical",
        width = 15,
        height = 20,
    },
    ec2 = {
        columns = {
            "Name",
            "InstanceId",
            "State",
            "Type",
            "PrivateIpAddress",
            "PublicIpAddress",
        },
    }
}

self.launched = false

function self.setup(config)
    print("Setting up self")
    self.config = config
end

-- should consider windown management

function self.launch()
    if self.launched then
        print("Dashboard already launched")
        return
    end

    self.launched = true

    -- self.window_manager = {}

    self.menu = require("nvimawscli.menu")

    local bufnr = utils.create_buffer('menu')
    local winnr = vim.api.nvim_get_current_win()

    self.menu.load(bufnr, winnr, self.config)
end

return self
