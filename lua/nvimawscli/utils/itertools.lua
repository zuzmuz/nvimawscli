
local M = {}

-- The difference between the methods with the same name but with an i,
-- is that the i only works for numerical contiguous keys, and ensure the order
-- whereas without the i, the order is not guaranteed and the keys can be non numerical

---Returns keys of table
function M.keys(t)
    local keys = {}
    for key, _ in pairs(t) do
        keys[#keys+1] = key
    end
    return keys
end

---Extends a list with the values of another list
---@param t any[]: the table to extend
---@param other any[]: the table to extend with
---@return table: the extended table
function M.extend(t, other)
    local new = {}
    for _, value in pairs(t) do
        new[#new+1] = value
    end
    for _, value in pairs(other) do
        new[#new+1] = value
    end
    return new
end

---Extends a list with the values of another list
---@param t any[]: the table to extend
---@param other any[]: the table to extend with
---@return table: the extended table
function M.iextend(t, other)
    local new = {}
    for _, value in ipairs(t) do
        new[#new+1] = value
    end
    for _, value in ipairs(other) do
        new[#new+1] = value
    end
    return new
end

---Filters and return new array by performing the callback on the keys of the original array
---@generic T
---@generic U
---@param t `T`[]: the input array
---@param callback fun(t: `T`): `U`: the transformation function
---@return `U`[]: the new array
function M.ifilter_values(t, callback)
    local new = {}
    for _, value in ipairs(t) do
        if callback(value) then
            new[#new+1] = value
        end
    end
    return new
end

---Returns new array by performing the callback on the keys of the original array
---@generic T
---@generic U
---@param t `T`[]: the input array
---@param callback fun(t: `T`): `U`: the transformation function
---@return `U`[]: the new array
function M.map_keys(t, callback)
    local new = {}
    for key, value in pairs(t) do
        new[callback(key)] = value
    end
    return new
end

---Returns new array by performing the callback on the values of the original array
---@generic T
---@generic U
---@param t `T`[]: the input array
---@param callback fun(t: `T`): `U`: the transformation function
---@return `U`[]: the new array
function M.map_values(t, callback)
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
function M.imap_values(t, callback)
    local new = {}
    for key, value in ipairs(t) do
        new[key] = callback(value)
    end
    return new
end

function M.imap_values_grouped(t, step, padding, callback)
    if step == 1 then
        return M.imap_values(t, callback)
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
function M.map(t, callback)
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
function M.imap(t, callback)
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
function M.associate_values(t, callback)
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
function M.associate(t, callback)
    local new = {}
    for key, value in pairs(t) do
        local v1, v2 = callback(key, value)
        new[v1] = v2
    end
    return new
end


---Flattens a list of lists into 1 list
---@param t table[]: the input array
---@return table: the new array
function M.flatten(t)
    local new = {}
    for _, value in ipairs(t) do
        for _, v in ipairs(value) do
            new[#new+1] = v
        end
    end
    return new
end

---Flattens a list of lists into 1 lists and inserts a separator between each list
---@param t table[]: the input array
---@param separator table: the separator to insert between each list
---@return table: the new array
function M.flatten_with_separator(t, separator)
    local new = {}
    for _, value in ipairs(t) do
        for _, sep in ipairs(separator) do
            new[#new+1] = sep
        end
        for _, v in ipairs(value) do
            new[#new+1] = v
        end
    end
    return new
end


---Returns the maximum value in the table
function M.max_with_index(t)
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
function M.min_with_index(t)
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
function M.max_with_index_by(t, callback)
    local max_key, max = 1, t[1]
    for key, value in pairs(t) do
        if callback(value, max) then
            max = value
            max_key = key
        end
    end
    return max_key, max
end

return M
