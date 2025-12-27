---@class TableRenderer
local M = {}




---@class table_config
---@field border string: The border style of the table
---@field spacing number: The extra spacing between the columns

---Render a table to be written in a buffer
---@param headers string[]: The headers of the table, the name of the columns
---@param rows {[string]: string}[]: The rows of the table, every row is a table, the keys are the the headers and the values are the content of the cell
---@param sorted_by_column_index number|nil: The index of the column that is sorted, nil if no column is sorted
---@param sorted_direction number: The direction of the sort, 1 for ascending, -1 for descending
---@param config table_config: The configuration of the table
---@return string[], LegalGrid, number[]: The lines of the table, the allowed positions in the window, the widths of the column
function M.render(headers, rows, sorted_by_column_index, sorted_direction, config)
    if #rows == 0 then
        return {}, {}, {}
    end

    local widths = {}

    for i, header in ipairs(headers) do
        widths[i] = vim.fn.strdisplaywidth(header)
    end

    for _, row in ipairs(rows) do
        for i, header in ipairs(headers) do
            if row[header] == nil or row[header] == vim.NIL then
                row[header] = ''
            end
            if vim.fn.strdisplaywidth(tostring(row[header])) > widths[i] then
                widths[i] = vim.fn.strdisplaywidth(tostring(row[header]))
            end
        end
    end

    for i, _ in ipairs(headers) do
        widths[i] = widths[i] + config.spacing
    end


    if config.border then
        local border = require('nvimawscli.utils.borders')[config.border]
        if not border then
            vim.notify(
                "Invalid table style: " .. config.border,
                vim.log.levels.WARN
            )
            return {}, {}, {}
        end
        local lines = {}
        local allowed_positions = {}
        allowed_positions[1] = {}

        lines[1] = border.top_left
        lines[2] = border.vertical
        lines[3] = border.left_tee

        allowed_positions[2] = {}

        local accumulated_width = 2

        for j, header in ipairs(headers) do
            lines[1] = lines[1] ..
                string.rep(border.horizontal, widths[j]) ..
                (j == #headers and border.top_right or border.top_tee)

            local header_suffix = string.rep(' ',
                    widths[j] -
                    vim.fn.strdisplaywidth(header) -
                    (sorted_by_column_index == j and 2 or 0)) ..
                (sorted_by_column_index == j and (sorted_direction == 1 and '▲ ' or '▼ ') or '')

            lines[2] = lines[2] .. header .. header_suffix .. border.vertical

            table.insert(allowed_positions[2], accumulated_width)

            accumulated_width = accumulated_width + widths[j] + 1

            lines[3] = lines[3] ..
                string.rep(border.horizontal, widths[j]) ..
                (j == #headers and border.right_tee or border.cross)
        end

        allowed_positions[3] = {}

        for i, row in pairs(rows) do
            local line_index = #lines + 1
            lines[line_index] = border.vertical

            allowed_positions[line_index] = {}
            accumulated_width = 2

            for j, header in ipairs(headers) do
                lines[line_index] = tostring(lines[line_index]) .. tostring(row[header]) ..
                    string.rep(' ',
                        widths[j] - vim.fn.strdisplaywidth(tostring(row[header]))) ..
                    tostring(border.vertical)

                table.insert(allowed_positions[i + 3], accumulated_width)
                accumulated_width = accumulated_width + widths[j] + 1
            end
        end
        lines[#lines + 1] = border.bottom_left

        allowed_positions[#lines] = {}
        for j, _ in ipairs(headers) do
            lines[#lines] = lines[#lines] ..
                string.rep(border.horizontal, widths[j]) ..
                (j == #headers and border.bottom_right or border.bottom_tee)
        end
        return lines, allowed_positions, widths
    else
        vim.notify(
            "Table style not found",
            vim.log.levels.WARN
        )
        return {}, {}, {}
    end
end

---Get the index of the row disregarding the header from the line number in the rendered table
---@param line_number number: The line number in the buffer
---@return number: The index of the row in the rows table
function M.get_item_number_from_row(line_number)
    if line_number == 2 then
        return 0
    end
    return line_number - 3
end

---Get the index of the column of the rendered table from the column position of the cursor in the window
---@param column_number number: The column number in the window at the cursor position
---@param widths table<number>: The widths of columns
---@return number|nil: The index of the column in the headers table, nil if invalid
function M.get_column_index_from_position(column_number, widths)
    local accumulated_width = 0
    for i, width in ipairs(widths) do
        accumulated_width = accumulated_width + width + 1
        if column_number <= accumulated_width then
            return i
        end
    end
    return nil
end

return M
