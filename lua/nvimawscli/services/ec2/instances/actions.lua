local config = require('nvimawscli.config')
local command = require(config.commands .. '.ec2.instances')

---@type ActionManager
return {
    get = function(instance)
        if instance.State == "running" then
            return { "details", "monitor", "stop", "terminate", "connect" }
        elseif instance.State == "stopped" then
            return { "details", "monitor", "start", "terminate" }
        end
        return { "details", "terminate" }
    end,

    actions = {

        details = {
            ask_for_confirmation = false,
            action = function(instance)
                local details = require('nvimawscli.services.ec2.instances.details')
                details:show(config.details.split, {
                    instance_id = instance.InstanceId
                })
            end,
        },

        monitor = {
            ask_for_confirmation = false,
            action = function(instance)
                local monitoring = require('nvimawscli.services.ec2.instances.monitoring')
                monitoring.show(instance.InstanceId, config.details.split)
            end,
        },

        start = {
            ask_for_confirmation = true,
            action = function(instance)
                vim.notify('starting ' .. instance.InstanceId)
                command.start_instance(instance.InstanceId,
                    function(result, error)
                        if error then
                            vim.notify(
                                error,
                                vim.log.levels.WARN
                            )
                            return
                        end
                        if result then
                            local decoded = vim.json.decode(result)
                            vim.notify('instance ' ..
                                instance.InstanceId .. ' is ' ..
                                decoded.StartingInstances[1].CurrentState.Name)
                            return
                        end
                        vim.notify(
                            'Result was nil',
                            vim.log.levels.WARN
                        )
                    end)
            end,
        },

        stop = {
            ask_for_confirmation = true,
            action = function(instance)
                vim.notify('stopping ' .. instance.InstanceId)
                command.stop_instance(instance.InstanceId,
                    function(result, error)
                        if error then
                            vim.notify(
                                error,
                                vim.log.levels.WARN
                            )
                            return
                        end
                        if result then
                            local decoded = vim.json.decode(result)
                            vim.notify('instance ' ..
                                instance.InstanceId .. ' is ' ..
                                decoded.StoppingInstances[1].CurrentState.Name)
                            return
                        end
                        vim.notify(
                            'Result was nil',
                            vim.log.levels.WARN
                        )
                    end)
            end,
        },

        terminate = {
            ask_for_confirmation = true,
            action = function(instance)
                vim.notify('terminating ' .. instance.InstanceId)
                command.terminate_instance(instance.InstanceId,
                    function(result, error)
                        if error then
                            vim.notify(
                                error,
                                vim.log.levels.WARN
                            )
                            return
                        end
                        if result then
                            local decoded = vim.json.decode(result)
                            vim.notify('instance ' ..
                                instance.InstanceId .. ' is ' ..
                                decoded.TerminatingInstances[1].CurrentState.Name)
                        end
                        vim.notify(
                            'Result was nil',
                            vim.log.levels.WARN
                        )
                    end)
            end,
        },

        connect = {
            ask_for_confirmation = true,
            action = function(instance)
                vim.notify('connecting ' .. instance.InstanceId)
                vim.cmd("bel new")
                command.connect_instance(instance.KeyName .. '.pem', 'ubuntu', instance.InstanceId)
            end,
        },
    }
}
