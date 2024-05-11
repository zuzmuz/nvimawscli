local utils = require('nvimawscli.utils.buffer')


---@class InstanceDetailsManager
local self = {}


function self.load(instance_id)
    if not self.bufnr then
        self.bufnr = utils.create_buffer('ec2.instance_details')
    end
end
