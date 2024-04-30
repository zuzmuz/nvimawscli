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
            -- "PublicIpAddress",
            "KeyName",
        },
    },
    table = {
        border = 'rounded',
        relative = 'cursor',
        spacing = 5,
    },
    test = false,
}


---Setup the configurations
---@param config table: The configuration to setup
function self.setup(config)

    local new_config = vim.tbl_deep_extend('keep', config or {}, default_config)

    for key, value in pairs(new_config) do
        self[key] = value
    end
end

return self
