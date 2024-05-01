local handler = require("nvimawscli.commands")

---@class Ec2Handler
local self = {}

---Fecth ec2 instances details
---@param on_result OnResult
function self.describe_instance(on_result)
    handler.async("aws ec2 describe-instances", on_result)
end

---Start ec2 instance
---@param instance_id string
---@param on_result OnResult
function self.start_instance(instance_id, on_result)
    handler.async("aws ec2 start-instances --instance-is " .. instance_id, on_result)
end

---Stop ec2 instance
---@param instance_id string
---@param on_result OnResult
function self.stop_instance(instance_id, on_result)
    handler.async('aws ec2 stop-instances --instance-ids ' .. instance_id, on_result)
end


---Terminate ec2 instance
---@param instance_id string
---@param on_result OnResult
function self.terminate_instance(instance_id, on_result)
    handler.async('aws ec2 terminate-instance --instances-ids ' .. instance_id, on_result)
end

---Connect to ec2 instance in new terminal
---@param private_key_file_path string
---@param os_user string
---@param instance_id string
function self.connect_instance(private_key_file_path, os_user, instance_id)
    handler.interactive('aws ec2-instance-connect ssh --instance-id ' ..
                         instance_id ..
                        ' --private-key-file ' .. private_key_file_path ..
                        ' --os-user ' .. os_user)
end

return self
