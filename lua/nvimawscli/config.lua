---@class Config
---@field preferred_services string[]: list of most used services to be shown on top
---@field all_services string[]: list of all the services
---@field menu table: menu window config
---@field table table: rendered tables config
local self = {
    preferred_services = {
        "ec2",
    },
    all_services = {
        "ec2",
        "cloudwatch",
        "s3",
        "codedeploy",
        "rds",
        "iam",
        "vpc",
    },
    menu = {
        split = "vertical",
        width = 15,
    },
    details = {
        split = "horizontal"
    },
    ec2 = {
        preferred_services = {
            'instances',
            'target_groups',
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
        instances = {
            ---@type table<table|string>
            preferred_attributes = {
                {
                    name = "Name",
                    value = "Tags[?Key==`Name`].Value | [0]",
                },
                {
                    name = "InstanceId",
                    value = "InstanceId",
                },
                {
                    name = "State",
                    value = "State.Name",
                },
                {
                    name = "InstanceType",
                    value = "InstanceType",
                },
                {
                    name = "PrivateIpAddress",
                    value = "PrivateIpAddress",
                },
                {
                    name = "KeyName",
                    value = "KeyName",
                },
            },
            preferred_details = {
                "InstanceStatuses",
                "InstanceId",
                "InstanceType",
                "KeyName",
                "LaunchTime",
                "IamInstanceProfile",
                "PrivateDnsName",
                "PrivateIpAddress",
                "StateTransitionReason",
                "SubnetId",
                "VpcId",
                "Architecture",
                "SecurityGroups",
                "Tags",
            },
        },
        target_groups = {
            preferred_attributes = {
                "TargetGroupName",
                "Protocol",
                "Port",
                "TargetType"
            },
            all_attributes = {
                "TargetGroupName",
                "Protocol",
                "Port",
                "HealthCheckEnabled",
                "HealthCheckPath",
                "HealthCheckIntervalSeconds",
                "HealthCheckTimeoutSeconds",
                "TargetType"
            },
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
