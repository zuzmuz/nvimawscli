
local self = {}

-- The difference between the methods with the same name but with an i,
-- is that the i only works for numerical contiguous keys, and ensure the order
-- whereas without the i, the order is not guaranteed and the keys can be non numerical

---Returns keys of table
function self.keys(table)
    local keys = {}
    for key, _ in pairs(table) do
        keys[#keys+1] = key
    end
    return keys
end

---Returns new array by performing th callback on the items of the original array
---@generic T
---@generic U
---@param table `T`[]: the input array
---@param callback fun(t: `T`): `U`: the transformation function
---@return `U`[]: the new array
function self.map_keys(table, callback)
    local new = {}
    for key, value in pairs(table) do
        new[callback(key)] = value
    end
    return new
end

---Returns new array by performing th callback on the items of the original array
---@generic T
---@generic U
---@param table `T`[]: the input array
---@param callback fun(t: `T`): `U`: the transformation function
---@return `U`[]: the new array
function self.map_values(table, callback)
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
function self.imap_values(table, callback)
    local new = {}
    for key, value in ipairs(table) do
        new[key] = callback(value)
    end
    return new
end


---Returns new array from a table performing the callback on each entry in the original table
---@generic K
---@generic V
---@generic U
---@param table table<K, V>[]: the input array
---@param callback fun(k: `K`, v: `V`): `U`: the transformation function
---@return `U`[]: the new array
function self.map(table, callback)
    local new = {}
    for key, value in pairs(table) do
        new[#new+1] = callback(key, value)
    end
    return new
end


---Returns new array from a table performing the callback on each entry in the original table
---@generic K
---@generic V
---@generic U
---@param table table<K, V>[]: the input array
---@param callback fun(k: `K`, v: `V`): `U`: the transformation function
---@return `U`[]: the new array
function self.imap(table, callback)
    local new = {}
    for key, value in ipairs(table) do
        new[#new+1] = callback(key, value)
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
function self.associate_values(table, callback)
    local new = {}
    for _, value in pairs(table) do
        local v1, v2 = callback(value)
        new[v1] = v2
    end
    return new
end

---Returns new array by performing th callback on the items of the original array
---@generic K
---@generic V
---@generic R
---@generic S
---@param table table<`K`: `V`>: the input array
---@param callback fun(k: `K`, v: `V`): `R`, `S`: the transformation function
---@return table<`U`, `V`>: the new array
function self.associate(table, callback)
    local new = {}
    for key, value in pairs(table) do
        local v1, v2 = callback(key, value)
        new[v1] = v2
    end
    return new
end



return self
