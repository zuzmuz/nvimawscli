---@class BufferUtil
local M = {}


---Create a new buffer
---@param name string|nil: The name of the buffer
---@param deletable boolean|nil: If the buffer should be removed if it's hidden
---@return number: The buffer number
function M.create_buffer(name, deletable, modifiable)
    local bufnr = vim.api.nvim_create_buf(false, true)

    vim.api.nvim_set_option_value('buftype', 'nofile', { buf = bufnr })
    vim.api.nvim_set_option_value('swapfile', false, { buf = bufnr })
    if modifiable then
        vim.api.nvim_set_option_value('modifiable', true, { buf = bufnr })
    else
        vim.api.nvim_set_option_value('modifiable', false, { buf = bufnr })
    end
    if name then
        vim.api.nvim_buf_set_name(bufnr, name)
    end
    if deletable then
        vim.api.nvim_set_option_value('bufhidden', 'delete', { buf = bufnr })
    end
    return bufnr
end

---@alias Split "vertical"|"horizontal"|"inplace"|"topleft"

---Create a new large window
---@param bufnr number: The buffer number to associate with the window
---@param split Split: The split direction
function M.create_window(bufnr, split)
    local winnr = 0
    if split == "vertical" then
        vim.cmd("rightbelow vnew")
    elseif split == "topleft" then
        vim.cmd("topleft vnew")
    elseif split == "horizontal" then
        vim.cmd("below new")
    elseif split == "inplace" then
        -- use current window
    else
        vim.api.nvim_err_writeln("Invalid split direction: " .. (split or 'nil'))
        return
    end
    winnr = vim.api.nvim_get_current_win()
    vim.api.nvim_win_set_buf(winnr, bufnr)
    return winnr
end

function M.check_if_window_exists(winnr)
    return vim.api.nvim_win_is_valid(winnr)
end

---Get the line from the buffer
---@param bufnr number: The buffer number
---@param line_number number: The line number
---@return string|nil: The line content
function M.get_line(bufnr, line_number)
    local lines = vim.api.nvim_buf_get_lines(bufnr,
                                             line_number - 1,
                                             line_number,
                                             false)
    if #lines > 0 then
        return lines[1]
    end
    return nil
end

---Get the lines from the buffer
---@param bufnr number: The buffer number
---@param start_line number?: The start line number
---@param end_line number?: The end line number
---@return string[]: The lines content
function M.get_lines(bufnr, start_line, end_line)
    start_line = start_line or 0
    end_line = end_line or -1
    return vim.api.nvim_buf_get_lines(bufnr,
                                      start_line,
                                      end_line,
                                      false)
end

---Overwrite the buffer with the given lines
---@param bufnr number: The buffer number
---@param lines string: The lines to write, the lines are split by '\n'
---@param editable boolean?: If the buffer should be modifiable
function M.write_lines_string(bufnr, lines, editable)
    local table_lines = vim.split(lines, "\n")
    M.write_lines(bufnr, table_lines, editable)
end

---Overwrite the buffer with the given lines
---@param bufnr number: The buffer number
---@param lines string[]: The lines to write
---@param editable boolean?: If the buffer should be modifiable
function M.write_lines(bufnr, lines, editable)
    vim.api.nvim_set_option_value('modifiable', true, { buf = bufnr })
    vim.api.nvim_buf_set_lines(bufnr, 0, -1, false, lines)
    if not editable then
        vim.api.nvim_set_option_value('modifiable', false, { buf = bufnr })
    end
end


---Insert the given lines the buffer at the given line number
---@param bufnr number: The buffer number
---@param lines string[]: The lines to write
---@param at_line number: The line number to insert the lines
---@param editable boolean?: If the buffer should be modifiable
function M.write_lines_at(bufnr, lines, at_line, editable)
    vim.api.nvim_set_option_value('modifiable', true, { buf = bufnr })
    vim.api.nvim_buf_set_lines(bufnr, at_line, at_line + #lines, false, lines)
    if not editable then
        vim.api.nvim_set_option_value('modifiable', false, { buf = bufnr })
    end
end

---Set the allowed cursor positions of the buffer.
---The allowed positions are used to restrict the cursor movement to the allowed positions.
---The hjkl in normal mode will only move the cursor to the allowed positions.
---@param bufnr number: The buffer number
---@param allowed_positions number[][][]: The allowed positions, a matrix of 2 dimensional points
function M.set_allowed_positions(bufnr, allowed_positions)
    local current_position = { 1, 1 }
    if #allowed_positions == 0 then
        return
    end
    local new_cursor_position = allowed_positions[current_position[1]][current_position[2]]
    vim.fn.setcursorcharpos(new_cursor_position[1],
                            new_cursor_position[2])

    vim.api.nvim_buf_set_keymap(bufnr, 'n', 'h', '', {
        callback = function()
            if current_position[2] > 1 then
                current_position[2] = current_position[2] - 1
            end
            new_cursor_position = allowed_positions[current_position[1]][current_position[2]]
            if new_cursor_position then
                vim.fn.setcursorcharpos(new_cursor_position[1],
                                        new_cursor_position[2])
            end
        end
    })
    vim.api.nvim_buf_set_keymap(bufnr, 'n', 'j', '', {
        callback = function()
            if current_position[1] < #allowed_positions then
                current_position[1] = current_position[1] + 1
            end
            new_cursor_position = allowed_positions[current_position[1]][current_position[2]]
            if new_cursor_position then
                vim.fn.setcursorcharpos(new_cursor_position[1],
                                        new_cursor_position[2])
            end
        end
    })
    vim.api.nvim_buf_set_keymap(bufnr, 'n', 'k', '', {
        callback = function()
            if current_position[1] > 1 then
                current_position[1] = current_position[1] - 1
            end
            new_cursor_position = allowed_positions[current_position[1]][current_position[2]]
            if new_cursor_position then
                vim.fn.setcursorcharpos(new_cursor_position[1],
                                        new_cursor_position[2])
            end
        end
    })
    vim.api.nvim_buf_set_keymap(bufnr, 'n', 'l', '', {
        callback = function()
            if current_position[2] < #allowed_positions[1] then
                current_position[2] = current_position[2] + 1
            end
            new_cursor_position = allowed_positions[current_position[1]][current_position[2]]
            if new_cursor_position then
                vim.fn.setcursorcharpos(new_cursor_position[1],
                                        new_cursor_position[2])
            end
        end
    })
end

return M
