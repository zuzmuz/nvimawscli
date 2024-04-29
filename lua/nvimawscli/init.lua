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

function self.launch()
    if self.launched then
        print("Dashboard already launched")
        return
    end
    self.launched = true
    require("nvimawscli.menu").load(self.config)
end

return self
