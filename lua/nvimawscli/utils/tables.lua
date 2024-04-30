local self = {}


---@class table_config
---@field border string: The border style of the table
---@field spacing number: The extra spacing between the columns

---Render a table to be written in a buffer
---@param headers table<string>: The headers of the table, the name of the columns
---@param rows table<table<string, string>>: The rows of the table, every row is a table, the keys are the the headers and the values are the content of the cell
---@param sorted_by_column_index number|nil: The index of the column that is sorted, nil if no column is sorted
---@param sorted_direction number: The direction of the sort, 1 for ascending, -1 for descending
---@param config table_config: The configuration of the table
---@return table<string>: The lines of the table
function self.render(headers, rows, sorted_by_column_index, sorted_direction, config)
    if #rows == 0 then
        return {}
    end

    self.spacing = config.spacing

    self.widths = {}

    for i, header in ipairs(headers) do
        self.widths[i] = vim.fn.strdisplaywidth(header)
    end

    for _, row in ipairs(rows) do
        for i, header in ipairs(headers) do
            if vim.fn.strdisplaywidth(row[header]) > self.widths[i] then
                self.widths[i] = vim.fn.strdisplaywidth(row[header])
            end
        end
    end

    for i, _ in ipairs(headers) do
        self.widths[i] = self.widths[i] + self.spacing
    end

    self.lines = {}

    if config.border then
        local border = require('nvimawscli.utils.characters')[config.border]
        if not border then
            vim.api.nvim_err_writeln("Invalid table style: " .. config.border)
            return {}
        end

        self.lines[1] = border.top_left
        self.lines[2] = border.vertical
        self.lines[3] = border.left_tee
        for j, header in ipairs(headers) do
            self.lines[1] = self.lines[1] ..
                            string.rep(border.horizontal, self.widths[j]) ..
                            (j == #headers and border.top_right or border.top_tee)

            local header_suffix = string.rep(' ',
                                             self.widths[j] -
                                             vim.fn.strdisplaywidth(header) -
                                             (sorted_by_column_index == j and 2 or 0)) ..
                                  (sorted_by_column_index == j and (sorted_direction == 1 and '▲ ' or '▼ ') or '')

            self.lines[2] = self.lines[2] .. header .. header_suffix .. border.vertical

            self.lines[3] = self.lines[3] ..
                            string.rep(border.horizontal, self.widths[j]) ..
                            (j == #headers and border.right_tee or border.cross)
        end

        for _, row in pairs(rows) do
            local line_index = #self.lines + 1
            self.lines[line_index] = border.vertical
            for j, header in ipairs(headers) do
                self.lines[line_index] = self.lines[line_index] .. row[header] ..
                                         string.rep(' ',
                                                    self.widths[j] - vim.fn.strdisplaywidth(row[header])) ..
                                         border.vertical
            end
        end
        self.lines[#self.lines+1] = border.bottom_left
        for j, _ in ipairs(headers) do
            self.lines[#self.lines] = self.lines[#self.lines] ..
                                     string.rep(border.horizontal, self.widths[j]) ..
                                     (j == #headers and border.bottom_right or border.bottom_tee)
        end

    else
        vim.api.nvim_err_writeln("Table style not found")
        return {}
    end

    return self.lines
end


---Get the index of the row disregarding the header from the line number in the rendered table
---@param line_number number: The line number in the buffer
---@return number: The index of the row in the rows table
function self.get_item_number_from_row(line_number)
    return line_number - 3
end

---Get the index of the column of the rendered table from the column position of the cursor in the window
---@param column_number number: The column number in the window at the cursor position
---@return number|nil: The index of the column in the headers table, nil if invalid
function self.get_column_index_from_position(column_number)
    local accumulated_width = 0
    for i, width in ipairs(self.widths) do
        accumulated_width = accumulated_width + width + 1
        if column_number <= accumulated_width then
            return i
        end
    end
    return nil
end

return self
