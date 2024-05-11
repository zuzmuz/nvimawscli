local command = require('nvimawscli.commands.ec2')

---@class InstanceActionsManage
local self = {}

function self.get(instance)
    if instance.State == "running" then
        return { "details", "stop", "terminate", "connect" }
    elseif instance.State == "stopped" then
        return { "details", "start", "terminate" }
    end
    return { "details", "terminate" }
end

---@class InstanceAction
---@field ask_for_confirmation boolean if true the user should be prompted for confirmation
---@field action fun(instance: Instance, callback: fun(result)) the action to be executed


---@type InstanceAction
self.details = {
    ask_for_confirmation = false,
    action = function(instance, callback)
        print('showing details ' .. instance.InstanceId)
        command.describe_instance_details(instance.InstanceId,
            function(result, error)
                if error then
                    vim.api.nvim_err_writeln(error)
                    return
                end
                if result then
                    local decoded = vim.json.decode(result)
                    callback(decoded)
                    return
                end
                vim.api.nvim_err_writeln('Result was nil')
            end)
    end,
}

---@type InstanceAction
self.start = {
    ask_for_confirmation = true,
    action = function(instance)
        print('starting ' .. instance.InstanceId)
        command.start_instance(instance.InstanceId,
            function(result, error)
                if error then
                    vim.api.nvim_err_writeln(error)
                    return
                end
                if result then
                    local decoded = vim.json.decode(result)
                    print('instance ' ..
                           instance.InstanceId .. ' is ' ..
                           decoded.StartingInstances[1].CurrentState.Name)
                    return
                end
                vim.api.nvim_err_writeln('Result was nil')
            end)
    end,
}


---@type InstanceAction
self.stop = {
    ask_for_confirmation = true,
    action = function(instance)
        print('stopping ' .. instance.InstanceId)
        command.stop_instance(instance.InstanceId,
            function(result, error)
                if error then
                    vim.api.nvim_err_writeln(error)
                    return
                end
                if result then
                    local decoded = vim.json.decode(result)
                    print('instance ' ..
                           instance.InstanceId .. ' is ' ..
                           decoded.StoppingInstances[1].CurrentState.Name)
                    return
                end
                vim.api.nvim_err_writeln('Result was nil')
            end)
    end,
}


---@type InstanceAction
self.terminate = {
    ask_for_confirmation = true,
    action = function(instance)
        print('terminating ' .. instance.InstanceId)
        command.terminate_instance(instance.InstanceId,
            function(result, error)
                if error then
                    vim.api.nvim_err_writeln(error)
                    return
                end
                if result then
                    local decoded = vim.json.decode(result)
                    print('instance ' ..
                           instance.InstanceId .. ' is ' ..
                           decoded.TerminatingInstances[1].CurrentState.Name)
                end
                vim.api.nvim_err_writeln('Result was nil')
            end)
    end,
}

---@type InstanceAction
self.connect = {
    ask_for_confirmation = true,
    action = function(instance)
        print('connecting ' .. instance.InstanceId)
        vim.cmd("bel new")
        command.connect_instance(instance.KeyName .. '.pem', 'ubuntu', instance.InstanceId)
    end,
}

return self
