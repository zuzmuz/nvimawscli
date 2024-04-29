local utils = {}

function utils.create_buffer(name)
    local bufnr = vim.api.nvim_create_buf(false, true)
    -- vim.api.nvim_buf_set_option(bufnr, 'bufhidden', 'wipe')
    vim.api.nvim_buf_set_option(bufnr, 'buftype', 'nofile')
    vim.api.nvim_buf_set_option(bufnr, 'swapfile', false)
    vim.api.nvim_buf_set_option(bufnr, 'modifiable', false)
    vim.api.nvim_buf_set_name(bufnr, name)
    return bufnr
end

function utils.create_window(bufnr, config)
    local winnr = 0
    if config.split == "vertical" then
        vim.cmd("rightbelow vnew")
        winnr = vim.api.nvim_get_current_win()
        vim.api.nvim_win_set_buf(winnr, bufnr)
    end
    return winnr
end

function utils.check_if_window_exists(winnr)
    return vim.api.nvim_win_is_valid(winnr)
end

function utils.create_floating_window(lines, config)
    local winnr = 0
    local height = #lines

    local bufnr = utils.create_buffer()

    local width = 0
    for _, value in ipairs(lines) do
        if #value > width then
            width = #value
        end
    end

    local opts = {
        relative = 'cursor',
        row = -1,
        col = 0,
        height = height,
        width = width,
        style = 'minimal',
        border = 'rounded',
    }

    winnr = vim.api.nvim_open_win(bufnr, true, opts)

    utils.write_lines(bufnr, lines)

    return { winnr = winnr, bufnr = bufnr }
end

function utils.get_line(bufnr, line)
    local lines = vim.api.nvim_buf_get_lines(bufnr, line - 1, line, false)
    if #lines > 0 then
        return lines[1]
    end
    return nil
end

function utils.write_lines_string(bufnr, lines)
    lines = vim.split(lines, "\n")
    utils.write_lines(bufnr, lines)
end

function utils.write_lines(bufnr, lines)
    vim.api.nvim_buf_set_option(bufnr, 'modifiable', true)
    vim.api.nvim_buf_set_lines(bufnr, 0, -1, false, lines)
    vim.api.nvim_buf_set_option(bufnr, 'modifiable', false)
end

function utils.get_item_number_from_row(row)
    return row - 2
end

function utils.get_column_index_from_position(position, widths)
    local accumulated_width = 0
    for i, width in ipairs(widths) do
        accumulated_width = accumulated_width + width + 5 + 3 -- 3 is the space between columns ' | '
        if position <= accumulated_width then
            return i
        end
    end
end

function utils.create_table_output(headers, lines_table)
    if #lines_table == 0 then
        return {}
    end

    local lines = {}

    local widths = {}

    for i, _ in ipairs(lines_table[1]) do
        widths[i] = 0
    end

    -- calculating the max width of every column

    for i, header in ipairs(headers) do
        if vim.fn.strdisplaywidth(header) > widths[i] then
            widths[i] = vim.fn.strdisplaywidth(header)
        end
    end

    for _, line in ipairs(lines_table) do
        for i, value in ipairs(line) do
            if vim.fn.strdisplaywidth(value) > widths[i] then
                widths[i] = vim.fn.strdisplaywidth(value)
            end
        end
    end

    lines[1] = '| '
    lines[2] = '| '
    for j, header in ipairs(headers) do
        lines[1] = lines[1] .. header .. string.rep(' ', widths[j] - vim.fn.strdisplaywidth(header) + 5) .. ' | '
        lines[2] = lines[2] .. string.rep('-', widths[j] + 5) .. ' | '
    end

    for _, line in ipairs(lines_table) do
        local i = #lines + 1
        lines[i] = '| '
        for j, value in ipairs(line) do
            lines[i] = lines[i] .. value .. string.rep(' ', widths[j] - vim.fn.strdisplaywidth(value) + 5) .. ' | '
        end
    end

    return { widths = widths, lines = lines }
end

function utils.async_command(command, on_result)
    vim.fn.jobstart(command, {
        stdout_buffered = true,
        stderr_buffered = true,
        on_stdout = function(_, result, _)
            if #result == 0 or #result == 1 and result[1] == '' then
                return
            end
            on_result(table.concat(result, '\n'), nil)
        end,
        on_stderr = function(_, result, _)
            if #result == 0 or #result == 1 and result[1] == '' then
                return
            end
            on_result(nil, table.concat(result, '\n'))
        end
    })
end

return utils
