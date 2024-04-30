local utils = require("nvimawscli.utils.command")

local ui = {}

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
        relative = 'cursor',
        row = -1,
        col = 0,
        height = height,
        width = width + 4,
        style = 'minimal',
        border = config.table.style or 'rounded',
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
