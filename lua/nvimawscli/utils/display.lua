local Iterable = require("nvimawscli.utils.itertools").Iterable

---@class DisplayRenderer
local M = {}



local function represent(t, nesting_level)

    local indent = string.rep(" ", nesting_level-1)
    local separator = {}
    if nesting_level == 1 then
        separator = {" ", "----------------", " "}
    elseif nesting_level == 2 then
        separator = {indent .. "--------"}
    elseif nesting_level == 3 then
        separator = {" "}
    end

    return Iterable(t):map(function(key, value)
        if type(value) == "table" then
            return { indent .. tostring(key) .. ":", unpack(represent(value, nesting_level+1)) }
        else
            return { indent .. tostring(key) .. ": " .. tostring(value) }
        end
    end):flatten_with_separator(separator).table
end



---Renders a generic lua table by unfloding all its content into an array of strings
---@param t table: The table to render
---@return string[]: The lines to display
function M.render(t)
    return represent(t, 1)
end


return M
