local config = require("nvimawscli.config")
local itertools = require("nvimawscli.utils.itertools")

local M = {}


local instances = {
    {
        Name = "Instance 1",
        InstanceId = "i-1234567890abcdef0",
        InstanceType = "t2.micro",
        State = "running",
        PrivateIpAddress = "172.31.55.208",
        KeyName = "privatekey1",
    },
    {
        Name = "Instance 2",
        InstanceId = "i-a1b2c3d4e5f6g7h8i",
        InstanceType = "t3.medium",
        State = "running",
        PrivateIpAddress = "172.31.55.210",
        KeyName = "privatekey2",
    },
    {
        Name = "Instance 3",
        InstanceId = "i-21324354657687980",
        InstanceType = "ca4.large",
        State = "stopped",
        PrivateIpAddress = "172.31.55.200",
        KeyName = "privatekey3",
    },
    {
        Name = "Instance 4",
        InstanceId = "i-f1e2d3c4b5a6g7h8i",
        InstanceType = "m1.small",
        State = "running",
        PrivateIpAddress = "172.31.55.250",
        KeyName = "privatekey4",
    },
}

---Fecth ec2 instances details
---@param on_result OnResult
function M.describe_instances(on_result)
    on_result(vim.json.encode(instances), nil)
end
return M
