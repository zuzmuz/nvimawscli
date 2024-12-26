local config = require("nvimawscli.config")
local Iterable = require("nvimawscli.utils.itertools").Iterable
local handler = require("nvimawscli.commands")

---@class Ec2Command
local M = {}

---Fecth ec2 instances details
---@param on_result OnResult
function M.describe_instances(on_result)
    local query_string = Iterable(config.ec2.instances.attributes):imap_values(
        function(value)
            return value.name .. ': ' .. value.value
        end):join(', ')
    handler.async("aws ec2 describe-instances " ..
                  "--query 'Reservations[].Instances[].{" ..
                  query_string ..
                  "}'", on_result)
end


---Fetch details about ec2 instance
---@param instance_id string
---@param on_result OnResult
function M.describe_instance_details(instance_id, on_result)
    handler.group_async({
        "aws ec2 describe-instance-status --query 'InstanceStatuses[] | [0]' --instance-ids  " .. instance_id,
        "aws ec2 describe-instances --query 'Reservations[].Instances[] | [0]' --instance-ids " .. instance_id,
    }, on_result)
end


---Fetch ec2 instance monitoring details
---@param instance_id string the instance id
---@param current_time number the current timestamp
---@param hours number the number of hours to fetch monitoring data
---@param interval number the granularity of the fetch monitoring data in seconds
---@param on_result OnResult
function M.describe_instance_monitoring(instance_id, current_time, hours, interval, on_result)

    ---@type table<string>
    local metrics = config.ec2.instances.metrics

    local metric_data_queries = Iterable(metrics):imap_values(
        function(metric)
            return '{"Id":"' .. string.lower(metric) .. '", "MetricStat":{' ..
            '"Metric":{"Namespace":"AWS/EC2", ' ..
            '"MetricName":"' .. metric .. '", ' ..
            '"Dimensions":[{"Name":"InstanceId",' ..
            '"Value": "' .. instance_id .. '"' ..
            '}]},"Period":' .. interval ..
            ',"Stat":"Average"}}'
        end):join(', ')
    local metric_data_queries_string = '[' .. metric_data_queries .. ']'
    local end_time = os.date("!%Y-%m-%dT%H:%M:%S", current_time)
    local start_time = os.date("!%Y-%m-%dT%H:%M:%S", current_time - (hours * 3600))
    ---@cast end_time string
    ---@cast start_time string

    handler.async("aws cloudwatch get-metric-data --metric-data-queries " ..
        "'" .. metric_data_queries_string .. "' " ..
        "--start-time " .. start_time ..
        " --end-time " .. end_time,
        on_result)
end

---Start ec2 instance
---@param instance_id string
---@param on_result OnResult
function M.start_instance(instance_id, on_result)
    handler.async("aws ec2 start-instances --instance-ids " .. instance_id, on_result)
end

---Stop ec2 instance
---@param instance_id string
---@param on_result OnResult
function M.stop_instance(instance_id, on_result)
    handler.async('aws ec2 stop-instances --instance-ids ' .. instance_id, on_result)
end


---Terminate ec2 instance
---@param instance_id string
---@param on_result OnResult
function M.terminate_instance(instance_id, on_result)
    handler.async('aws ec2 terminate-instance --instances-ids ' .. instance_id, on_result)
end

---Connect to ec2 instance in new terminal
---@param private_key_file_path string
---@param os_user string
---@param instance_id string
function M.connect_instance(private_key_file_path, os_user, instance_id)
    handler.interactive('aws ec2-instance-connect ssh --instance-id ' ..
                         instance_id ..
                        ' --private-key-file ' .. private_key_file_path ..
                        ' --os-user ' .. os_user)
end



-- Fetch all target groups details
---@param on_result OnResult
function M.describe_target_groups(on_result)
    handler.async("aws elbv2 describe-target-groups", on_result)
end

-- we can have basic cloudwatch ecw metrics here
--
-- aws cloudwatch get-metric-data
-- aws cloudwatch list-metric-data
-- aws cloudwatch list-dashboard (maybe creating dashbords would be interesting)
return M
