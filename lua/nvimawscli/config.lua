---@class Config
---@field prefered_services string[]: list of most used services to be shown on top
---@field all_services string[]: list of all the services
---@field menu table: menu window config
---@field table table: rendered tables config
local self = {
    prefered_services = {
        "ec2",
    },
    all_services = {
        "ec2",
        "elb",
        "s3",
        "codedeploy",
        "rds",
        "iam",
        "vpc",
        "cloudwatch",
    },
    menu = {
        split = "vertical",
        width = 15,
    },
    ec2 = {
        columns = {
            "Name",
            "InstanceId",
            "State",
            "Type",
            "PrivateIpAddress",
            -- "PublicIpAddress",
            "KeyName",
        },
        prefered_services = {
            'instances',
        },
        all_services = {
            'instances',
            'launch_instance',
            'ami',
            'security_groups',
            'elb',
            'target_groups',
            'elastic_ip',
        },
    },
    table = {
        border = 'rounded',
        relative = 'cursor',
        spacing = 5,
    },
    commands = "nvimawscli.commands",
}


---Setup the configurations
---@param config table: The configuration to setup
function self.setup(config)
    local new_config = vim.tbl_deep_extend('keep', config or {}, self)

    for key, value in pairs(new_config) do
        self[key] = value
    end
end

return self
