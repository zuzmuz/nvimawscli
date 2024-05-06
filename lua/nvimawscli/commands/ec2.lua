local handler = require("nvimawscli.commands")

---@class Ec2Handler
local self = {}

---Fecth ec2 instances details
---@param on_result OnResult
function self.describe_instances(on_result)
    handler.async("aws ec2 describe-instances", on_result)
end

---Fetch ec2 instance status
---@param instance_id string
---@param on_result OnResult
function self.fetch_instance_status(instance_id, on_result)
    handler.async("aws ec2 describe-instance-status --instance-ids " .. instance_id, on_result)
end


---Fetch ec2 instance metrics
---@param instance_id string
---@param start_time string: the start date for metric, format is timestamp yyyy-mm-ddThh:mm:ssss
---@param end_time string: then end date for metric, format is timestamp yyyy-mm-ddThh:mm:ssss
---@param interval number: in seconds, the granularity of the fetch metrics data in seconds
---@param on_result OnResult
function self.fetch_instance_metrics(instance_id, start_time, end_time, interval, on_result)
    handler.async("aws cloudwatch get-metric-data --metric-data-queries " ..
                      "'[{\"Id\":\"cpu\", \"MetricStat\":{" ..
                      "\"Metric\":{\"Namespace\":\"AWS/EC2\", " ..
                      "\"MetricName\":\"CPUUtilization\", \"Dimensions\":[{\"Name\":\"InstanceId\"," ..
                      "\"Value\": \"" .. instance_id .. "\"" ..
                      "}]},\"Period\":" .. interval ..
                      ",\"Stat\":\"Average\"}}]' --start-time " .. start_time ..
                      " --end-time " .. end_time,
                      on_result)
end

---Fetch ec2 instance metrics for the last number of hours
---@param instance_id string
---@param current_time number: the number of hourse past the current time to fetch metrics data
---@param hours number: the number of hourse past the current time to fetch metrics data
---@param interval number: in seconds, the granularity of the fetch metrics data in seconds
---@param on_result OnResult
function self.fetch_last_hours_instance_metrics(instance_id, current_time, hours, interval, on_result)
    local end_time = os.date("%Y-%m-%dT%H:%M:%S", current_time)
    local start_time = os.date("%Y-%m-%dT%H:%M:%S", current_time - (hours * 3600))
    ---@cast end_time string
    ---@cast start_time string

    print("start_time: " .. start_time .. " end_time: " .. end_time)
    self.fetch_instance_metrics(instance_id, start_time, end_time, interval, on_result)
end

---Start ec2 instance
---@param instance_id string
---@param on_result OnResult
function self.start_instance(instance_id, on_result)
    handler.async("aws ec2 start-instances --instance-ids " .. instance_id, on_result)
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



-- Fetch all target groups details
---@param on_result OnResult
function self.describe_target_groups(on_result)
    handler.async("aws elbv2 describe-target-groups", on_result)
end

-- we can have basic cloudwatch ecw metrics here
--
-- aws cloudwatch get-metric-data
-- aws cloudwatch list-metric-data
-- aws cloudwatch list-dashboard (maybe creating dashbords would be interesting)
return self
