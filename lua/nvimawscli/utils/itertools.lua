
local self = {}

---Returns new array by performing th callback on the items of the original array
---@generic T
---@generic U
---@param table `T`[]: the input array
---@param callback fun(t: `T`): `U`: the transformation function
---@return `U`[]: the new array
function self.map(table, callback)
    local new = {}
    for key, value in pairs(table) do
        new[key] = callback(value)
    end
    return new
end

---Returns new array by performing th callback on the items of the original array
---@generic T
---@generic U
---@param table `T`[]: the input array
---@param callback fun(t: `T`): `U`: the transformation function
---@return `U`[]: the new array
function self.imap(table, callback)
    local new = {}
    for key, value in ipairs(table) do
        new[key] = callback(value)
    end
    return new
end

---Returns new array by performing th callback on the items of the original array
---@generic T
---@generic U
---@generic V
---@param table `T`[]: the input array
---@param callback fun(t: `T`): `U`, `V`: the transformation function
---@return table<`U`, `V`>: the new array
function self.associate(table, callback)
    local new = {}
    for _, value in pairs(table) do
        local v1, v2 = callback(value)
        new[v1] = v2
    end
    return new
end


return self
