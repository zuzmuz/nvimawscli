local Iterable = require('nvimawscli.utils.itertools').Iterable
local profile = require('nvimawscli.utils.data').store.current_profile or 'default'

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

function M.aws_command(command, arguments, on_result)
    local cmd_string = ''
    if profile == 'default' then
        cmd_string = command .. ' ' .. arguments
    else
        cmd_string = command .. ' --profile ' .. profile .. ' ' .. arguments
    end
    M.async(cmd_string, on_result)
end


function M.aws_group_command(commands, on_result)
    local cmd_strings = Iterable(commands):imap_values(
        function (command_argument)
            if profile == 'default' then
                return command_argument[1] .. ' ' .. command_argument[2]
            else
                return command_argument[1] .. ' --profile ' .. profile .. ' ' .. command_argument[2]
            end
        end
    ).table
    M.group_async(cmd_strings, on_result)
end
return M
