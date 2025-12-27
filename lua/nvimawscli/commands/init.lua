local Iterable = require('nvimawscli.utils.itertools').Iterable
local data = require('nvimawscli.utils.data')

---@class Command
local M = {}

---@alias OnResult fun(result: string?, error: string?)

---Execute a terminal command asynchronously
---@param command string: The command to execute
---@param on_result OnResult callback function
function M.async(command, on_result)
    vim.fn.jobstart(command, {
        stdout_buffered = true,
        stderr_buffered = true,
        on_stdout = function(_, result, _)
            if #result == 0 or #result == 1 and result[1] == '' then
                return
            end
            on_result(table.concat(result, '\n'), nil)
        end,
        on_stderr = function(_, result, _)
            if #result == 0 or #result == 1 and result[1] == '' then
                return
            end
            on_result(nil, table.concat(result, '\n'))
        end
    })
end

---Execute a group of terminal commands asynchronously and return the combined result
---@param commands string[]: The commands to Execute
---@param on_result OnResult callback function
function M.group_async(commands, on_result)
    local results = {}
    local errors = {}
    local count = 0
    for _, command in ipairs(commands) do
        M.async(command, function(result, error)
            count = count + 1
            if result then
                table.insert(results, result)
            end
            if error then
                table.insert(errors, error)
            end
            if count == #commands then
                on_result((#results > 0 and ('[' .. table.concat(results, ',\n') .. ']')) or nil,
                    (#errors > 0 and ('[' .. table.concat(errors, ',\n') .. ']')) or nil)
            end
        end)
    end
end

---Run a terminal in the window and execute the command interactively
---@param command string: The command to execute
function M.interactive(command)
    vim.fn.termopen(command)
end

---Execute an AWS CLI command asynchronously with the current profile
---@param command string: The AWS CLI command to execute
---@param arguments string: The arguments for the AWS CLI command
---@param on_result OnResult callback function
function M.aws_command(command, arguments, on_result)
    local cmd_string = ''
    if data.store.current_profile == 'default' then
        cmd_string = 'aws' .. command .. ' ' .. arguments
    else
        cmd_string = 'aws --profile ' .. data.store.current_profile .. ' ' .. command .. ' ' .. arguments
    end
    M.async(cmd_string, on_result)
end

---Execute a group of AWS CLI commands asynchronously with the current profile
---@param commands table{string, string}[]: The AWS CLI commands and their arguments
---@param on_result OnResult: callback function
function M.aws_group_command(commands, on_result)
    local aws_prefix = (data.store.current_profile == 'default') and ('aws --profile ' .. data.store.current_profile) or 'aws'
    local cmd_strings = Iterable(commands):imap_values(
        function(command_argument)
            return aws_prefix .. command_argument[1] .. ' ' .. command_argument[2]
        end
    ).table
    M.group_async(cmd_strings, on_result)
end

return M
