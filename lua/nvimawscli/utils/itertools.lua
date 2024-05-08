
local self = {}

-- The difference between the methods with the same name but with an i,
-- is that the i only works for numerical contiguous keys, and ensure the order
-- whereas without the i, the order is not guaranteed and the keys can be non numerical

---Returns keys of table
function self.keys(t)
    local keys = {}
    for key, _ in pairs(t) do
        keys[#keys+1] = key
    end
    return keys
end

---Returns new array by performing th callback on the items of the original array
---@generic T
---@generic U
---@param t `T`[]: the input array
---@param callback fun(t: `T`): `U`: the transformation function
---@return `U`[]: the new array
function self.map_keys(t, callback)
    local new = {}
    for key, value in pairs(t) do
        new[callback(key)] = value
    end
    return new
end

---Returns new array by performing th callback on the items of the original array
---@generic T
---@generic U
---@param t `T`[]: the input array
---@param callback fun(t: `T`): `U`: the transformation function
---@return `U`[]: the new array
function self.map_values(t, callback)
    local new = {}
    for key, value in pairs(t) do
        new[key] = callback(value)
    end
    return new
end

---Returns new array by performing th callback on the items of the original array
---@generic T
---@generic U
---@param t `T`[]: the input array
---@param callback fun(t: `T`): `U`: the transformation function
---@return `U`[]: the new array
function self.imap_values(t, callback)
    local new = {}
    for key, value in ipairs(t) do
        new[key] = callback(value)
    end
    return new
end

function self.imap_values_grouped(t, step, padding, callback)
    if step == 1 then
        return self.imap_values(t, callback)
    end
    local new = {}
    local i = 1
    while i <= #t do
        local group = {}
        for j = 1, step do
            if i <= #t then
                group[j] = t[i]
            else
                group[j] = padding
            end
            i = i + 1
        end
        new[#new+1] = callback(unpack(group))
    end
    return new
end


---Returns new array from a table performing the callback on each entry in the original table
---@generic K
---@generic V
---@generic U
---@param t table<K, V>[]: the input array
---@param callback fun(k: `K`, v: `V`): `U`: the transformation function
---@return `U`[]: the new array
function self.map(t, callback)
    local new = {}
    for key, value in pairs(t) do
        new[#new+1] = callback(key, value)
    end
    return new
end


---Returns new array from a table performing the callback on each entry in the original table
---@generic K
---@generic V
---@generic U
---@param t table<K, V>: the input array
---@param callback fun(k: `K`, v: `V`): `U`: the transformation function
---@return `U`[]: the new array
function self.imap(t, callback)
    local new = {}
    for key, value in ipairs(t) do
        new[#new+1] = callback(key, value)
    end
    return new
end

---Returns new array by performing th callback on the items of the original array
---@generic T
---@generic U
---@generic V
---@param t `T`[]: the input array
---@param callback fun(t: `T`): `U`, `V`: the transformation function
---@return table<`U`, `V`>: the new array
function self.associate_values(t, callback)
    local new = {}
    for _, value in pairs(t) do
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
---@param t table<`K`, `V`> the input array
---@param callback fun(k: `K`, v: `V`): `R`, `S`: the transformation function
---@return table<`R`, `S`>: the new array
function self.associate(t, callback)
    local new = {}
    for key, value in pairs(t) do
        local v1, v2 = callback(key, value)
        new[v1] = v2
    end
    return new
end


---Returns the maximum value in the table
function self.max_with_index(t)
    local max_key, max = 1, t[1]
    for key, value in pairs(t) do
        if value > max then
            max = value
            max_key = key
        end
    end
    return max_key, max
end

---Returns the minimum value in the table
function self.min_with_index(t)
    local min_key, min = 1, t[1]
    for key, value in pairs(t) do
        if value < min then
            min = value
            min_key = key
        end
    end
    return min_key, min
end

---Returns the optimum of the table based on a callback comparison function
---@generic T
---@param t `T`[] the table
---@param callback fun(a: `T`, b: `T`) the comparison function
function self.max_with_index_by(t, callback)
    local max_key, max = 1, t[1]
    for key, value in pairs(t) do
        if callback(value, max) then
            max = value
            max_key = key
        end
    end
    return max_key, max
end

return self
