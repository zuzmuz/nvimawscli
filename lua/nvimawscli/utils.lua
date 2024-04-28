local utils = {}

function utils.create_buffer()
    local bufnr = vim.api.nvim_create_buf(false, true)
    vim.api.nvim_buf_set_option(bufnr, 'bufhidden', 'wipe')
    vim.api.nvim_buf_set_option(bufnr, 'buftype', 'nofile')
    vim.api.nvim_buf_set_option(bufnr, 'swapfile', false)
    vim.api.nvim_buf_set_option(bufnr, 'modifiable', false)
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

function utils.create_table_output(lines_table)

    if #lines_table == 0 then
        return {}
    end

    local lines = {}

    local widths = {}

    for i, _ in ipairs(lines_table[1]) do
        widths[i] = 0
    end

    -- calculating the max width of every column
    for _, line in ipairs(lines_table) do
        for i, value in ipairs(line) do
            if #value > widths[i] then
                widths[i] = #value
            end
        end
    end

    for _, line in ipairs(lines_table) do
        local i = #lines + 1
        lines[i] = '| '
        for j, value in ipairs(line) do
            lines[i] = lines[i] .. value
            lines[i] = lines[i] .. string.rep(' ', widths[j] - #value + 5) .. ' | '
        end

        if i == 1 then
            lines[i+1] = '| '
            for j, _ in ipairs(line) do
                lines[i+1] = lines[i+1] .. string.rep('-', widths[j] + 5) .. ' | '
            end
        end
    end

    return lines
end


function utils.async_command(command, on_result)
    vim.fn.jobstart(command, {
        stdout_buffered = true,
        on_stdout = function(_, result)
            on_result(table.concat(result, '\n'))
        end,
    })
end

return utils
