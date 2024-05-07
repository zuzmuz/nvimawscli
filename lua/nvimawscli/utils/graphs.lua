local itertools = require('nvimawscli.utils.itertools')
local self = {}

self.blocks = {'▁', '▂', '▃', '▄', '▅', '▆', '▇', '█'}

local function get_block_for(value)
    local block_index = math.ceil(value * #self.blocks)
    if block_index < 1 then
        return ' '
    elseif block_index > #self.blocks then
        return self.blocks[#self.blocks]
    end
    return self.blocks[block_index]
end


---Generate a multiline text that represent positive numerical data in a graph
---@param values number[]: a table contanining positive numerical data
---@param height number: an integer defining the number of lines to use when generating the graph
---@param scale number?: the max value for adjusting the scale for normalizing the values, if nil then the max of values is the scale
function self.render(values, height, scale)

    if #values == 0 then
        return {}
    end
    local _, max = itertools.max_with_index(values)
    if scale and scale > max then
        max = scale
    end
    local columns = itertools.imap_values(values,
        function (value)
            local ratio = value/max
            local ratio_height = ratio * height
            local blocks = {}
            for i = 1, height do
                blocks[i] = get_block_for(ratio_height + i - height)
            end
            return blocks
        end)

    local rows = itertools.imap(columns[1],
        function (index, _)
            return table.concat(itertools.imap_values(columns,
                function (column)
                    return column[index]
                end), '')
        end)
    return rows
end

return self
