local utils = require("nvimawscli.utils.buffer")
local itertools = require("nvimawscli.utils.itertools")

local M = {}

---@alias floating_popup_border 'rounded' | 'single' | 'double'
---@alias floating_popup_relative 'cursor' | 'win' | 'editor'

---@class floating_popup_config
---@field border floating_popup_border
---@field relative floating_popup_relative

---@class floating_popup
---@field winnr number
---@field bufnr number


---Create a floating popup with a title and a list of selectable actions
---@param title string?: title of flowing popup, can be nil if no title needed
---@param message string[]?: the message to display below the title
---@param actions string[]: the list of selectable options in the buffer of the popup
---@param config floating_popup_config: the popup ui config
---@param selected fun(line_number: number): nil callback function when an option is selected
---@return floating_popup
function M.create_floating_select(title, message, actions, config, selected)
    local winnr = 0
    local height = #actions
    if message then
        height = height + #message
    end

    local bufnr = utils.create_buffer("floating_window", true)

    local width = 0
    if title then
        width = vim.fn.strdisplaywidth(title)
    end
    for _, value in ipairs(actions) do
        if vim.fn.strdisplaywidth(value) > width then
            width = vim.fn.strdisplaywidth(value)
        end
    end

    if message then
        for _, value in ipairs(message) do
            if vim.fn.strdisplaywidth(value) > width then
                width = vim.fn.strdisplaywidth(value)
            end
        end
    end

    local options = {
        relative = config.relative or 'cursor',
        row = -1,
        col = 0,
        height = height,
        width = width + 4,
        style = 'minimal',
        border = config.border or 'rounded',
        title = title,
        title_pos = title and 'center' or nil
    }

    winnr = vim.api.nvim_open_win(bufnr, true, options)

    vim.api.nvim_buf_set_keymap(bufnr, 'n', 'q', '', {
        callback = function()
            vim.api.nvim_win_close(0, true)
        end
    })

    vim.api.nvim_buf_set_keymap(bufnr, 'n', '<CR>', '', {
        callback = function ()
            local position = vim.api.nvim_win_get_cursor(0)
            vim.api.nvim_win_close(0, true)
            if message then
                selected(position[1] - #message)
            else
                selected(position[1])
            end
        end
    })


    if message then
        local content = itertools.iextend(message, actions)
        utils.write_lines(bufnr, content)
        local allowed_positions = itertools.imap(actions, function(index, _)
            return { { index + #message, 1 } }
        end)
        print(vim.inspect(allowed_positions))
        utils.set_allowed_positions(bufnr, allowed_positions)
    else
        utils.write_lines(bufnr, actions)
        local allowed_positions = itertools.imap(actions, function(index, _)
            return { { index, 1 } }
        end)
        utils.set_allowed_positions(bufnr, allowed_positions)
    end

    return { winnr = winnr, bufnr = bufnr }
end

---Create a floating modifiable popup with a title to get text from
---@param title string: title of flowing popup
---@param width number: width of the popup
---@param height number: height of the popup
---@param config floating_popup_config: the popup ui config
---@param input fun(text: string): nil callback function when the text is entered
function M.create_floating_input(title, width, height, config, input)
    local winnr = 0
    local bufnr = utils.create_buffer("floating_window", true, true)

    local options = {
        relative = config.relative or 'cursor',
        row = -1,
        col = 0,
        height = height,
        width = width,
        style = 'minimal',
        border = config.border or 'rounded',
        title = title,
        title_pos = title and 'center' or nil
    }

    winnr = vim.api.nvim_open_win(bufnr, true, options)

    vim.api.nvim_buf_set_keymap(bufnr, 'n', 'q', '', {
        callback = function()
            vim.api.nvim_win_close(0, true)
        end
    })

    vim.api.nvim_buf_set_keymap(bufnr, 'n', '<CR>', '', {
        callback = function ()
            local text = vim.api.nvim_buf_get_lines(bufnr, 0, -1, false)[1]
            vim.api.nvim_win_close(0, true)
            input(text)
        end
    })

    return { winnr = winnr, bufnr = bufnr }
end

return M
