local itertools = require('nvimawscli.utils.itertools')

---@class GraphRenderer
local M = {}

---@alias graph_type 'block' | 'braille' | 'line'

---@class SymbolMapping
---@field block string[]|string[][]|nil: a table of symbols for block graph
---@field braille string[]|string[][]|nil: a table of symbols for block graph
---@field line string[]|string[][]|nil: a table of symbols for block graph
---@field get_symbol fun(a,b,c): string?: table of symbols for block graph

---Symbol mapping returns the symbols for graphing a table of values.
---It supports 2 resolutions, 1 and 2. Resolution 1 represents one value per character, while 2 represents 2 values per character.
---It supports 3 types of graphs: block, braille and line.
---The symbols for resolution 1 is a 1D array, the symbols for resolution 2 is a 2D array.
---@type table<number, SymbolMapping>>
local symbol_mapping = {}

symbol_mapping[1] = {
    block = {' ', ' ', '▁', '▂', '▃', '▄', '▅', '▆', '▇', '█', '█'},
    braille = {' ', ' ', '⣀', '⣤', '⣶', '⣿', '⣿'},
    line = {' ', '⣀', '⠤', '⠒', '⠉', ' ' },

    ---Returns the graph symbol that maps to a value
    ---If the value is less than 0, it returns the first symbol, if the value is greater than 1, it returns the last symbol.
    ---A value between 0 and 1 will be mapped to the symbols from index 2 to #symbols-1.
    ---@param value number: the value will be multiplied by the number of symbols minus 2 and rounded to the nearest integer to get the index of the symbol
    ---@param graph_type graph_type: the type of graph to use
    ---@return string?: the symbol that represents the value, if the graph type is not supported, it returns nil
    get_symbol = function (value, graph_type)
        local symbols = symbol_mapping[1][graph_type]
        if symbols then
            local i = math.max(math.min(#symbols, math.ceil((value * (#symbols-2)) + 0.5)), 1)
            return symbols[i]
        end
        return nil
    end,
}

symbol_mapping[2] = {
    braille = {
        {' ', ' ', '⢀', '⢠', '⢰', '⢸', '⢸'},
        {' ', ' ', '⢀', '⢠', '⢰', '⢸', '⢸'},
        {'⡀', '⡀', '⣀', '⣠', '⣰', '⣸', '⣸'},
        {'⡄', '⡄', '⣄', '⣤', '⣴', '⣼', '⣼'},
        {'⡆', '⡆', '⣆', '⣦', '⣶', '⣾', '⣾'},
        {'⡇', '⡇', '⣇', '⣧', '⣷', '⣿', '⣿'},
        {'⡇', '⡇', '⣇', '⣧', '⣷', '⣿', '⣿'},
    },
    line = {
        {' ', '⢀', '⠠', '⠐', '⠈', ' '},
        {'⡀', '⣀', '⡠', '⡐', '⡈', '⡀'},
        {'⠄', '⢄', '⠤', '⠔', '⠌', '⠄'},
        {'⠂', '⢂', '⠢', '⠒', '⠊', '⠂'},
        {'⠁', '⢁', '⠡', '⠑', '⠉', '⠁'},
        {' ', '⢀', '⠠', '⠐', '⠈', ' '},
    },
    block = nil,
    ---Returns the graph symbol that maps and represents two values
    ---If the graph type suppors representing two values, the first part of the symbol represents the first value and the second part represents the second value.
    ---The table of symbold to map from is in this case a 2D array, rows represent the first value and columns represent the second value.
    ---If the value is less than 0, it will be mapped to the first index, if the value is greater than 1, it will be mapped the last index.
    ---A value between 0 and 1 will be mapped to the symbols from index 2 to #symbols-1.
    ---@param value1 number: the value 1 
    ---@param value2 number: the value 2 
    ---@param graph_type graph_type: the type of graph to use
    ---@return string?: the symbol that represents the value, if the graph type is not supported, it returns nil
    get_symbol = function (value1, value2, graph_type)
        local symbols = symbol_mapping[2][graph_type]
        if symbols then
            local i = math.max(math.min(#symbols, math.ceil((value1 * (#symbols-2)) + 0.5)), 1)
            local j = math.max(math.min(#symbols[1], math.ceil((value2 * (#symbols[1]-2)) + 0.5)), 1)
            return symbols[i][j]
        end
        return nil
    end,
}

-- ⠰⢾⡷⠆⠠⠄⠤⠶⢸⡇⡧⢼ 


---Generate a multiline text that represent positive numerical data in a graph
---@param values number[]: a table contanining positive numerical data
---@param height number: an integer defining the number of lines to use when generating the graph
---@param scale number?: the max value for adjusting the scale for normalizing the values, if nil then the max of values is the scale
---@param graph_type graph_type: the type of graph to use
---@param resolution number: the resolution of the graph, 1 or 2
function M.render(values, height, scale, graph_type, resolution)

    if #values == 0 then
        return {}
    end

    local _, max = itertools.max_with_index(values)
    if scale and scale > max then
        max = scale
    end
    local columns = nil
    if resolution == 1 then
        columns = itertools.imap_values(values,
            function (value)
                local ratio = value/max
                local ratio_height = ratio * height
                local blocks = {}
                for i = 1, height do
                    blocks[i] = symbol_mapping[1].get_symbol(ratio_height + i - height, graph_type)
                end
                return blocks
            end)
    elseif resolution == 2 then
        columns = itertools.imap_values_grouped(values, resolution, 0,
            function (value1, value2)
                local ratio1 = value1/max
                local ratio2 = value2/max
                local ratio_height1 = ratio1 * height
                local ratio_height2 = ratio2 * height
                local blocks = {}
                for i = 1, height do
                    blocks[i] = symbol_mapping[2].get_symbol(ratio_height1 + i - height,
                                                             ratio_height2 + i - height,
                                                             graph_type)
                end
                return blocks
            end)
    else
        return {}
    end

    local rows = itertools.imap(columns[1],
        function (index, _)
            return table.concat(itertools.imap_values(columns,
                function (column)
                    return column[index]
                end), '')
        end)
    return rows
end

return M
