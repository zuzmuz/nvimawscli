local utils = require('nvimawscli.utils.buffer')
local itertools = require("nvimawscli.utils.itertools")
local config = require('nvimawscli.config')
local instance = require('nvimawscli.services.rds.instance')
local table_renderer = require('nvimawscli.utils.tables')

---@type RdsHandler
local command = require(config.commands .. '.rds')

---@class Rds
local M = {}

-- TODO: this should inherit from tableview

function M.show(split)
    if not M.bufnr then
        M.load()
    end
    if not M.winnr or not utils.check_if_window_exists(M.winnr) then
        M.winnr = utils.create_window(M.bufnr, split)
    end

    vim.api.nvim_set_current_win(M.winnr)
    M.fetch()
end

function M.load()
    M.bufnr = utils.create_buffer('rds')

    vim.api.nvim_buf_set_keymap(M.bufnr, 'n', '<CR>', '', {
        callback = function()
            if not M.ready then
                return
            end
            local position = vim.api.nvim_win_get_cursor(M.winnr)

            local rds_instance_name = utils.get_line(M.bufnr, position[1])

            if not rds_instance_name then
                return
            end
            print('Rds Instance name: ' .. rds_instance_name)
            instance.show(rds_instance_name, config.menu.split)
            vim.api.nvim_win_set_width(M.winnr, config.menu.width)
        end
    })
end

function M.fetch()
    M.ready = false
    M.sorted_by_column_index = nil
    utils.write_lines(M.bufnr, { 'Fetching databases...' })
    command.list_databases(function(result, error)
        if error then
            utils.write_lines_string(M.bufnr, error)
        elseif result then
            M.rows = vim.json.decode(result)
            local allowed_positions = M.render(M.rows)
            utils.set_allowed_positions(M.bufnr, allowed_positions)
        else
            utils.write_lines_string(M.bufnr, 'Result was nil')
        end
        M.ready = true
    end)
end

---@private
---Render the table containing the ec2 instances into the buffer
---@param rows Instance[]
---@return number[][][]: The positions the cursor is allowed to be at
function M.render(rows)
    local column_names = itertools.Iterable(config.rds.attributes):imap_values(
        function(attribute)
            return attribute.name
        end).table
    local lines, allowed_positions, widths = table_renderer.render(
        column_names,
        rows,
        M.sorted_by_column_index,
        M.sorted_direction,
        config.table)

    M.widths = widths
    utils.write_lines(M.bufnr, lines)
    return allowed_positions
end


return M
