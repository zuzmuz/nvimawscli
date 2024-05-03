---@class CommandHandler
local self = {}

---@alias OnResult fun(result: string|nil, error: string|nil): nil

---Execute a terminal command asynchronously
---@param command string: The command to execute
---@param on_result fun(result: string|nil, error: string|nil): nil callback function
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

-- function self.sync()

-- end

---Run a terminal in the window and execute the command interactively
---@param command string: The command to execute
function self.interactive(command)
    vim.fn.termopen(command)
end


return self
