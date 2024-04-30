local utils = require("nvimawscli.utils.buffer")

local ui = {}

---@alias floating_popup_border 'rounded' | 'single' | 'double'
---@alias floating_popup_relative 'cursor' | 'win' | 'editor'

---@class floating_popup_config
---@field border floating_popup_border
---@field relative floating_popup_relative

---@class floating_popup
---@field winnr number
---@field bufnr number


---Create a floating popup with a title and a list of selectable actions
---@param title string|nil: title of flowing popup, can be nil if no title needed
---@param lines table<string>: the list of selectable options in the buffer of the popup
---@param config floating_popup_config: the popup ui config
---@param selected fun(line_number: number): nil callback function when an option is selected
---@return floating_popup
function ui.create_floating_select_popup(title, lines, config, selected)
    local winnr = 0
    local height = #lines

    local bufnr = utils.create_buffer("floating_window", true)

    local width = 0
    if title then
        width = vim.fn.strdisplaywidth(title)
    end
    for _, value in ipairs(lines) do
        if vim.fn.strdisplaywidth(value) > width then
            width = vim.fn.strdisplaywidth(value)
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
            selected(position[1])
        end
    })

    utils.write_lines(bufnr, lines)

    return { winnr = winnr, bufnr = bufnr }
end

return ui
