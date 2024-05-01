local command = require('nvimawscli.utils.command')

---@class InstanceAction
local self = {}

function self.get(instance)
    if instance.State == "running" then
        return { "details", "stop", "terminate", "connect" }
    elseif instance.State == "stopped" then
        return { "details", "start", "terminate" }
    end
    return { "details", "terminate" }
end

self.details = {
    ask_for_confirmation = false,
    action = function(instance)
        print('showing details ' .. instance.InstanceId)
    end,
}

self.start = {
    ask_for_confirmation = true,
    action = function(instance)
        print('starting ' .. instance.InstanceId)
        command.async('aws ec2 start-instances --instance-ids ' .. instance.InstanceId,
            function(result, error)
                if error then
                    vim.api.nvim_err_writeln(error)
                    return
                end
                local decoded = vim.json.decode(result)
                print('instance ' .. instance.InstanceId .. ' is ' .. decoded.StartingInstances[1].CurrentState.Name)
            end)
    end,
}

self.stop = {
    ask_for_confirmation = true,
    action = function(instance)
        print('stopping ' .. instance.InstanceId)
        command.async('aws ec2 stop-instances --instance-ids ' .. instance.InstanceId,
            function(result, error)
                if error then
                    vim.api.nvim_err_writeln(error)
                    return
                end
                local decoded = vim.json.decode(result)
                print('instance ' .. instance.InstanceId .. ' is ' .. decoded.StoppingInstances[1].CurrentState.Name)
            end)
    end,
}

self.terminate = {
    ask_for_confirmation = true,
    action = function(instance)
        print('terminating ' .. instance.InstanceId)
    end,
}

self.connect = {
    ask_for_confirmation = true,
    action = function(instance)
        print('connecting ' .. instance.InstanceId)
        vim.cmd("bel new")
        vim.fn.termopen('aws ec2-instance-connect ssh --instance-id ' .. instance.InstanceId ..
                        ' --private-key-file ' .. instance.KeyName .. '.pem --os-user ubuntu')
    end,
}

return self
