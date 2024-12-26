---@class Iterable
---@field table table: the raw lua table
local M = {}

function M.Iterable(table)
    return setmetatable({
        table = table,
    }, {
        __index = M
    })
end

-- The difference between the methods with the same name but with an i,
-- is that the i only works for numerical contiguous keys, and ensure the order
-- whereas without the i, the order is not guaranteed and the keys can be non numerical

---@return Iterable: returns the keys of the table as Iterable
function M:keys()
    local keys = {}
    for key, _ in pairs(self.table) do
        keys[#keys + 1] = key
    end
    return M.Iterable(keys)
end

---Extends a list with the values of another list
---@param other any[]: the table to extend with
---@return Iterable: the extended table
function M:extend(other)
    local new = {}
    for _, value in pairs(self.table) do
        new[#new + 1] = value
    end
    for _, value in pairs(other) do
        new[#new + 1] = value
    end
    return M.Iterable(new)
end

---Extends a list with the values of another list
---@param other any[]: the table to extend with
---@return Iterable: the extended table
function M:iextend(other)
    local new = {}
    for _, value in ipairs(self.table) do
        new[#new + 1] = value
    end
    for _, value in ipairs(other) do
        new[#new + 1] = value
    end
    return M.Iterable(new)
end

---Filters and return new array by performing the callback on the keys of the original array
---@generic T
---@param callback fun(t: `T`): boolean the filtering function
---@return Iterable: the new iterable
function M:filter(callback)
    local new = {}
    for _, value in pairs(self.table) do
        if callback(value) then
            new[#new + 1] = value
        end
    end
    return M.Iterable(new)
end

---Filters and return new array by performing the callback on the keys of the original array
---@generic T
---@param callback fun(t: `T`): boolean the filtering function
---@return Iterable: the new iterable
function M:ifilter(callback)
    local new = {}
    for _, value in ipairs(self.table) do
        if callback(value) then
            new[#new + 1] = value
        end
    end
    return M.Iterable(new)
end

---Returns new array by performing the callback on the keys of the original array
---@generic T the original key type
---@generic U the mapped key type
---@param callback fun(t: `T`): `U`: the transformation function
---@return Iterable: the new mapped iterable
function M:map_keys(callback)
    local new = {}
    for key, value in pairs(self.table) do
        new[callback(key)] = value
    end
    return M.Iterable(new)
end

---Returns new array by performing the callback on the values of the original array
---@generic T the original values type
---@generic U the mapped valued type
---@param callback fun(t: `T`): `U`: the transformation function
---@return Iterable: the new iterable
function M:map_values(callback)
    local new = {}
    for key, value in pairs(self.table) do
        new[key] = callback(value)
    end
    return M.Iterable(new)
end

---Returns new array by performing the callback on the values of the original array
---@generic T the original values type
---@generic U the mapped valued type
---@param callback fun(t: `T`): `U`: the transformation function
---@return Iterable: the new iterable
function M:imap_values(callback)
    local new = {}
    for key, value in ipairs(self.table) do
        new[key] = callback(value)
    end
    return M.Iterable(new)
end



---Transforms a collection into a list of objects
---grouping the sublists based on a step
---@generic T
---@generic U
---@param step integer the size of the subgroups
---@param padding `T` the element to insert at the last group in case step does not divide
---the original collection
---@param callback fun(...): `U`: the transformation function, size of argument should be equal to step
---@return Iterable: the new array
function M:imap_values_grouped(step, padding, callback)
    if step == 1 then
        return self:imap_values(callback)
    end
    local new = {}
    local i = 1
    while i <= #self.table do
        local group = {}
        for j = 1, step do
            if i <= #self.table then
                group[j] = self.table[i]
            else
                group[j] = padding
            end
            i = i + 1
        end
        new[#new + 1] = callback(unpack(group))
    end
    return M.Iterable(new)
end

---Joins iterable into string
---@param separator string?: the separator to join the elements with
function M:join(separator)
    return table.concat(self.table, separator)
end

---Returns new array from a table performing the callback on each entry in the original table
---@generic K
---@generic V
---@generic U
---@param callback fun(k: `K`, v: `V`): `U`: the transformation function
---@return Iterable: the new array
function M:map(callback)
    local new = {}
    for key, value in pairs(self.table) do
        new[#new + 1] = callback(key, value)
    end
    return M.Iterable(new)
end

---Returns new array from a table performing the callback on each entry in the original table
---@generic K
---@generic V
---@generic U
---@param callback fun(k: `K`, v: `V`): `U`: the transformation function
---@return Iterable: the new array
function M:imap(callback)
    local new = {}
    for key, value in ipairs(self.table) do
        new[#new + 1] = callback(key, value)
    end
    return M.Iterable(new)
end

---Returns new array by performing th callback on the items of the original array
---@generic T
---@generic U
---@generic V
---@param callback fun(t: `T`): `U`, `V`: the transformation function
---@return Iterable: the new array
function M:associate_values(callback)
    local new = {}
    for _, value in pairs(self.table) do
        local v1, v2 = callback(value)
        new[v1] = v2
    end
    return M.Iterable(new)
end

---Returns new array by performing th callback on the items of the original array
---@generic K
---@generic V
---@generic R
---@generic S
---@param callback fun(k: `K`, v: `V`): `R`, `S`: the transformation function
---@return Iterable: the new array
function M:associate(callback)
    local new = {}
    for key, value in pairs(self.table) do
        local v1, v2 = callback(key, value)
        new[v1] = v2
    end
    return M.Iterable(new)
end

---Flattens a list of lists into 1 list
---@return Iterable: the new iterable
function M:flatten()
    local new = {}
    for _, value in ipairs(self.table) do
        for _, v in ipairs(value) do
            new[#new + 1] = v
        end
    end
    return M.Iterable(new)
end

---Flattens a list of lists into 1 lists and inserts a separator between each list
---@param separator table: the separator to insert between each list
---@return Iterable: the new iterable
function M:flatten_with_separator(separator)
    local new = {}
    for _, value in ipairs(self.table) do
        for _, sep in ipairs(separator) do
            new[#new + 1] = sep
        end
        for _, v in ipairs(value) do
            new[#new + 1] = v
        end
    end
    return M.Iterable(new)
end

---Returns the maximum value in the table
---@generic K
---@generic T
---@return `K`, `T`
function M:max_with_index()
    local max_key, max = 1, self.table[1]
    for key, value in pairs(self.table) do
        if value > max then
            max = value
            max_key = key
        end
    end
    return max_key, max
end

---Returns the minimum value in the table
---@generic K
---@generic T
---@return `K`, `T`
function M:min_with_index()
    local min_key, min = 1, self.table[1]
    for key, value in pairs(self.table) do
        if value < min then
            min = value
            min_key = key
        end
    end
    return min_key, min
end

---Returns the optimum of the table based on a callback comparison function
---@generic K
---@generic T
---@param callback fun(a: `T`, b: `T`) the comparison function
---@return `K`, `T`
function M:max_with_index_by(callback)
    local max_key, max = 1, self.table[1]
    for key, value in pairs(self.table) do
        if callback(value, max) then
            max = value
            max_key = key
        end
    end
    return max_key, max
end

return M
