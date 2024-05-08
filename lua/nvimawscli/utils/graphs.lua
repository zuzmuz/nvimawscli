local itertools = require('nvimawscli.utils.itertools')

---@class GraphRenderer
local self = {}


local graph_resolution = {
    [1] = {
        block = {' ', ' ', '▁', '▂', '▃', '▄', '▅', '▆', '▇', '█', '█'},
        braille = {' ', ' ', '⣀', '⣤', '⣶', '⣿', '⣿'},
        line = {' ', '⠉', '⠒', '⠤', '⣀', ' ' },
    },
    [2] = {
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
    },
}

-- ▗⢀▁	▀◥◤

-- ⢀⢠⢰⢸⡀⣀⣠⣰⣸⡄⣄⣤⣴⣼⡆⣆⣦⣶⣾⡇⣇⣧⣷⣿
-- ⠈⠘⠸⢸⠁⠉⠙⠹⢹⠃⠋⠛⠻⢻⠇⠏⠟⠿⢿⡇⡏⡟⡿⣿
-- 
-- ⠰⢾⡷⠆⠠⠄⠤⠶⢸⡇⡧⢼ 
--
-- ⡠⠔⠊⠑⠢⢄⡐⠌⡈⢁⠡⢂⠉⠒⠤⣀   ⠈⠐⠠⢀⠁⠂⠄⡀
--
--   ⢀⣀
--  ⠔⠁ ⠡
-- ⡈    ⠂
--       ⢂
--        ⠢⣀


local function get_graph_symbol(value, graph_type)
    local graph_symbols = graph_resolution[1][graph_type]
    if graph_symbols then
        local block_index = math.max(math.min(#graph_symbols, math.ceil((value * (#graph_symbols-2)) + 0.5)), 1)
        return graph_symbols[block_index]
    end
    return nil
end

local function get_graph_symbol2(value1, value2, graph_type)
    local graph_symbols = graph_resolution[2][graph_type]
    if graph_symbols then
        local block_index1 = math.max(math.min(#graph_symbols, math.ceil((value1 * (#graph_symbols-2)) + 0.5)), 1)
        local block_index2 = math.max(math.min(#graph_symbols[1], math.ceil((value2 * (#graph_symbols[1]-2)) + 0.5)), 1)
        return graph_symbols[block_index1][block_index2]
    end
    return nil
end

---@alias graph_type 'block' | 'braille' | 'line'

---Generate a multiline text that represent positive numerical data in a graph
---@param values number[]: a table contanining positive numerical data
---@param height number: an integer defining the number of lines to use when generating the graph
---@param scale number?: the max value for adjusting the scale for normalizing the values, if nil then the max of values is the scale
function self.render(values, height, scale, graph_type, resolution)

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
                    blocks[i] = get_graph_symbol(ratio_height + i - height, graph_type)
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
                    blocks[i] = get_graph_symbol2(ratio_height1 + i - height,
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

return self
