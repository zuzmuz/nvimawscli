---@class CommandHandler
local self = {}

---@alias OnResult fun(result: string|nil, error: string|nil): nil

---Execute a terminal command asynchronously
---@param command string: The command to execute
---@param on_result OnResult callback function
function self.async(command, on_result)
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
function self.group_async(commands, on_result)
    local results = {}
    local errors = {}
    local count = 0
    for _, command in ipairs(commands) do
        self.async(command, function(result, error)
            count = count + 1
            if result then
                print(count, command)
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
function self.interactive(command)
    vim.fn.termopen(command)
end


return self
