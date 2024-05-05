


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
        "elb",
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
    ec2 = {
        get_attribute_name = function(attribute)
            if type(attribute) == 'table' then
                return attribute[1]
            end
            return attribute
        end,
        get_attribute_name_and_value = function(attribute, instance)
            if type(attribute) == 'table' then
                return attribute[1], attribute.get_from(instance) or ''
            else
                return attribute, instance[attribute] or ''
            end
        end,
        ---@type table<table|string>
        preferred_attributes = {
            {
                "Name",
                get_from = function(instance)
                    for _, tag in ipairs(instance.Tags) do
                        if tag.Key == "Name" then
                            return tag.Value
                        end
                    end
                    return ""
                end,
            },
            "InstanceId",
            {
                "State",
                get_from = function(instance)
                    return instance.State.Name
                end,
            },
            "InstanceType",
            "PrivateIpAddress",
            "KeyName",
        },
        all_attributes = {
            "ImageId",
            "InstanceId",
            "InstanceType",
            "KeyName",
            "LaunchTime",
            {
                "Monitoring",
                attributes = {
                    "State",
                },
            },
            "PrivateDnsName",
            "PrivateIpAddress",
            {
                "State",
                attributes = {
                    "Code",
                    "Name",
                },
            },
            "StateTransitionReason",
            "SubnetId",
            "VpcId",
            "Architecture",
            {
                "IamInstanceProfile",
                attributes = {
                    "Arn",
                    "Id",
                },
            },
            {
                "SecurityGroups",
                list = {
                    {
                        "GroupId",
                        "GroupName",
                    },
                },
            },
            {
                "Tags",
                list = {
                    {
                        "Key",
                        "Value",
                    },
                },
            },
        },
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
        preferred_target_groups_attributes = {
            "TargetGroupName",
            "Protocol",
            "Port",
            "HealthCheckEnabled",
            "HealthCheckPath",
            "HealthCheckIntervalSeconds",
            "HealthCheckTimeoutSeconds",
            "TargetType"
        },
        all_target_groups_attributes = {
            "TargetGroupName",
            "Protocol",
            "Port",
            "HealthCheckEnabled",
            "HealthCheckPath",
            "HealthCheckIntervalSeconds",
            "HealthCheckTimeoutSeconds",
            "TargetType"
        }
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
