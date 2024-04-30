local self = {}


function self.render(headers, rows, sorted_by_column_index, sorted_direction, config)
    if #rows == 0 then
        return {}
    end

    self.spacing = config.table.spacing

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

    if config.table.style then
        local style = require('nvimawscli.utils.characters')[config.table.style]
        if not style then
            vim.api.nvim_err_writeln("Invalid table style: " .. config.table.style)
            return
        end

        self.lines[1] = style.top_left
        self.lines[2] = style.vertical
        self.lines[3] = style.left_tee
        for j, header in ipairs(headers) do
            self.lines[1] = self.lines[1] ..
                            string.rep(style.horizontal, self.widths[j]) ..
                            (j == #headers and style.top_right or style.top_tee)

            local header_suffix = string.rep(' ',
                                             self.widths[j] - vim.fn.strdisplaywidth(header) - (sorted_by_column_index == j and 2 or 0)) ..
                                  (sorted_by_column_index == j and (sorted_direction == 1 and '▲ ' or '▼ ') or '')

            self.lines[2] = self.lines[2] .. header .. header_suffix .. style.vertical

            self.lines[3] = self.lines[3] ..
                            string.rep(style.horizontal, self.widths[j]) ..
                            (j == #headers and style.right_tee or style.cross)
        end

        for _, row in ipairs(rows) do
            local line_index = #self.lines + 1
            self.lines[line_index] = style.vertical
            for j, header in ipairs(headers) do
                self.lines[line_index] = self.lines[line_index] .. row[header] ..
                                         string.rep(' ',
                                                    self.widths[j] - vim.fn.strdisplaywidth(row[header])) ..
                                         style.vertical
            end
        end
        self.lines[#self.lines+1] = style.bottom_left
        for j, _ in ipairs(headers) do
            self.lines[#self.lines] = self.lines[#self.lines] ..
                                     string.rep(style.horizontal, self.widths[j]) ..
                                     (j == #headers and style.bottom_right or style.bottom_tee)
        end

    else
        vim.api.nvim_err_writeln("Table style not found")
        return {}
    end

    return self.lines
end

function self.get_item_number_from_row(line_number)
    return line_number - 3
end

function self.get_column_index_from_position(column_number)
    local accumulated_width = 0
    for i, width in ipairs(self.widths) do
        accumulated_width = accumulated_width + width + 1
        if column_number <= accumulated_width then
            return i
        end
    end
end

return self
