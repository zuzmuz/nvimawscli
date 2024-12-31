---@class Config
local M = {
    startup_service = nil,
    preferred_services = nil,
    menu = {
        split = "vertical",
        width = 15,
    },
    details = {
        split = "horizontal"
    },
    table = {
        border = 'rounded',
        relative = 'cursor',
        spacing = 5,
    },
    commands = "nvimawscli.commands",
    ec2 = require('nvimawscli.config.ec2'),
    s3 = require('nvimawscli.config.s3'),
    rds = require('nvimawscli.config.rds'),
}

---Setup the configurations
---@param config table: The configuration to setup
function M.setup(config)
    local new_config = vim.tbl_deep_extend('keep', config or {}, M)

    for key, value in pairs(new_config) do
        M[key] = value
    end
end

return M
