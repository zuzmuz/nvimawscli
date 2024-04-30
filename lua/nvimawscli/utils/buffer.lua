local self = {}

function self.create_buffer(name, deletable)
    local bufnr = vim.api.nvim_create_buf(false, true)

    vim.api.nvim_buf_set_option(bufnr, 'buftype', 'nofile')
    vim.api.nvim_buf_set_option(bufnr, 'swapfile', false)
    vim.api.nvim_buf_set_option(bufnr, 'modifiable', false)
    if name then
        vim.api.nvim_buf_set_name(bufnr, name)
    end
    if deletable then
        vim.api.nvim_buf_set_option(bufnr, 'bufhidden', 'delete')
    end
    return bufnr
end

function self.create_window(bufnr, config)
    local winnr = 0
    if config.split == "vertical" then
        vim.cmd("rightbelow vnew")
        winnr = vim.api.nvim_get_current_win()
        vim.api.nvim_win_set_buf(winnr, bufnr)
    end
    return winnr
end

function self.check_if_window_exists(winnr)
    return vim.api.nvim_win_is_valid(winnr)
end

function self.get_line(bufnr, line)
    local lines = vim.api.nvim_buf_get_lines(bufnr, line - 1, line, false)
    if #lines > 0 then
        return lines[1]
    end
    return nil
end

function self.write_lines_string(bufnr, lines)
    lines = vim.split(lines, "\n")
    self.write_lines(bufnr, lines)
end

function self.write_lines(bufnr, lines)
    vim.api.nvim_buf_set_option(bufnr, 'modifiable', true)
    vim.api.nvim_buf_set_lines(bufnr, 0, -1, false, lines)
    vim.api.nvim_buf_set_option(bufnr, 'modifiable', false)
end

return self
