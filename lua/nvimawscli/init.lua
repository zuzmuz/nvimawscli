local self = {}

local default_config = {
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
    submenu = {
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
    },
    table = {
        style = 'rounded',
        spacing = 5,
    },
    test = false,
}

self.launched = false

function self.setup(config)
    self.config = vim.tbl_deep_extend('keep', config or {}, default_config)
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
