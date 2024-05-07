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

function self.render(values, height, max_optional)
    local _, max = itertools.max_with_index(values)
    if max_optional and max_optional > max then
        max = max_optional
    end

    print('max ' .. max)

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
