local self = {}


---Create a new buffer
---@param name string|nil: The name of the buffer
---@param deletable boolean|nil: If the buffer should be removed if it's hidden
---@return number: The buffer number
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

---@alias split "vertical"|"horizontal"

---Create a new large window
---@param bufnr number: The buffer number to associate with the window
---@param split split: The split direction
function self.create_window(bufnr, split)
    local winnr = 0
    if split == "vertical" then
        vim.cmd("rightbelow vnew")
    elseif split == "horizontal" then
        vim.cmd("below new")
    else
        vim.api.nvim_err_writeln("Invalid split direction: " .. split)
        return
    end
    winnr = vim.api.nvim_get_current_win()
    vim.api.nvim_win_set_buf(winnr, bufnr)
    return winnr
end

function self.check_if_window_exists(winnr)
    return vim.api.nvim_win_is_valid(winnr)
end

---Get the line from the buffer
---@param bufnr number: The buffer number
---@param line_number number: The line number
---@return string|nil: The line content
function self.get_line(bufnr, line_number)
    local lines = vim.api.nvim_buf_get_lines(bufnr, line_number - 1, line_number, false)
    if #lines > 0 then
        return lines[1]
    end
    return nil
end


---Overwrite the buffer with the given lines
---@param bufnr number: The buffer number
---@param lines string: The lines to write, the lines are split by '\n'
function self.write_lines_string(bufnr, lines)
    local table_lines = vim.split(lines, "\n")
    self.write_lines(bufnr, table_lines)
end

---Overwrite the buffer with the given lines
---@param bufnr number: The buffer number
---@param lines table<string>: The lines to write
function self.write_lines(bufnr, lines)
    vim.api.nvim_buf_set_option(bufnr, 'modifiable', true)
    vim.api.nvim_buf_set_lines(bufnr, 0, -1, false, lines)
    vim.api.nvim_buf_set_option(bufnr, 'modifiable', false)
end

return self
