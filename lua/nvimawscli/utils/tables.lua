local self = {}


function self.render(headers, rows, config)
    if #rows == 0 then
        return {}
    end

    self.spacing = config.table.spacing

    self.widths = {}

    for i, header in ipairs(headers) do
        self.widths[i] = vim.fn.strdisplaywidth(header)
    end

    for _, row in ipairs(rows) do
        for i, value in ipairs(row) do
            if vim.fn.strdisplaywidth(value) > self.widths[i] then
                self.widths[i] = vim.fn.strdisplaywidth(value)
            end
        end
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
                            string.rep(style.horizontal, self.widths[j] + self.spacing) ..
                            (j == #headers and style.top_right or style.top_tee)

            -- print(header, self.widths[j], vim.fn.strdisplaywidth(header), style.horizontal, style.top_right, style.top_tee, style.top_left, style.left_tee, style.vertical, style.right_tee, style.cross, style.bottom_left, style.bottom_right, style.bottom_tee)
            self.lines[2] = self.lines[2] .. header ..
                            string.rep(' ',
                                       self.widths[j] - vim.fn.strdisplaywidth(header) + self.spacing) ..
                                       style.vertical

            self.lines[3] = self.lines[3] ..
                            string.rep(style.horizontal, self.widths[j] + self.spacing) ..
                            (j == #headers and style.right_tee or style.cross)
        end

        for _, row in ipairs(rows) do
            local line_index = #self.lines + 1
            self.lines[line_index] = style.vertical
            for j, value in ipairs(row) do
                self.lines[line_index] = self.lines[line_index] .. value ..
                                         string.rep(' ',
                                                    self.widths[j] - vim.fn.strdisplaywidth(value) +
                                                    self.spacing) ..
                                         style.vertical
            end
        end
        self.lines[#self.lines+1] = style.bottom_left
        for j, _ in ipairs(headers) do
            self.lines[#self.lines] = self.lines[#self.lines] ..
                                     string.rep(style.horizontal, self.widths[j] + self.spacing) ..
                                     (j == #headers and style.bottom_right or style.bottom_tee)
        end

    else
        vim.api.nvim_err_writeln("Table style not found")
        return {}
    end

    print(vim.inspect(self.lines))

    return self.lines
end

function self.get_item_number_from_row(row)
    return row - 3
end

function self.get_column_index_from_position(position)
    local accumulated_width = 0
    for i, width in ipairs(self.widths) do
        accumulated_width = accumulated_width + width + self.spacing + 1
        if position <= accumulated_width then
            return i
        end
    end
end

return self