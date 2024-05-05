local utils = require('nvimawscli.utils.buffer')
local config = require('nvimawscli.config')
local itertools = require('nvimawscli.utils.itertools')

local table_renderer = require('nvimawscli.utils.tables')

---@type Ec2Handler
local command = require(config.commands .. '.ec2')

---@class TargetGroupsManager
local self = {}

---Sort the rows based on the column and direction
---@param column string: the name of the column header name to use as key for sorting
function self.sort_rows(column, direction)
    table.sort(self.rows, function(a, b)
        if direction == 1 then
            return a[column] < b[column]
        end
        return a[column] > b[column]
    end)
end

function self.load()
    print("loading target groups functionality")

    if not self.bufnr then
        self.bufnr = utils.create_buffer('ec2')
    end

    if not self.winnr or not utils.check_if_window_exists(self.winnr) then
        self.winnr = utils.create_window(self.bufnr, config.menu.split)
    end

    vim.api.nvim_set_current_win(self.winnr)

    self.fetch()

    vim.api.nvim_buf_set_keymap(self.bufnr, 'n', '<CR', '', {
        callback = function()
            if not self.ready then
                return
            end

            local position = vim.fn.getcursorcharpos()
            local line_number = position[2]
            local column_number = position[3]

            local item_number = table_renderer.get_item_number_from_row(line_number)
            if item_number > 0 and item_number < #self.rows then
                -- To be implemente 
            else
                local column_index = table_renderer.get_column_index_from_position(
                    column_number, self.widths
                )
                if self.sorted_by_column_index == column_index then
                    self.sorted_direction = self.sorted_direction * -1
                else
                    self.sorted_by_column_index = column_index
                    self.sorted_direction = 1
                end

                if column_index then
                    local column_value = config.ec2.get_attribute_name(
                        config.ec2.preferred_target_groups_attributes[column_index]
                    )
                    self.sort_rows(column_value, self.sorted_direction)
                    self.render(self.rows)
                end
            end
        end
    })
end

---@private
---Fetch ec2 target groups from aws clia and parse the result
function self.fetch()
    self.ready = false
    utils.write_lines_string(self.bufnr, 'Fetching...')
    command.describe_target_groups(function(result, error)
        if error then
            utils.write_lines_string(self.bufnr, error)
        elseif result then
            local target_groups = vim.json.decode(result).TargetGroups
            self.rows = self.parse(target_groups)
            local allowed_positions = self.render(self.rows)
            utils.set_allowed_positions(self.bufnr, allowed_positions)
        else
            utils.write_lines_string(self.bufnr, 'Result was nil')
        end
        self.ready = true
    end)
end

---@private
---Parse target groups result and store in rows
---@param target_groups table: the raw json target groups
function self.parse(target_groups)
    return itertools.imap(target_groups,
        function(target_group)
            return itertools.associate(config.ec2.preferred_target_groups_attributes,
                function(attribute)
                    return config.ec2.get_attribute_name_and_value(attribute, target_group)
                end
            )
        end
    )
end

---@private
---Render the table containing ec2 target groups into the buffer
---@return number[][][]: the position the cursor is allows to be at
function self.render(rows)
    local column_names = itertools.imap(config.ec2.preferred_target_groups_attributes,
        function(attribute)
            return config.ec2.get_attribute_name(attribute)
        end
    )
    local lines, allowed_positions, widths = table_renderer.render(
        column_names,
        rows,
        self.sorted_by_column_index,
        self.sorted_direction,
        config.table
    )
    self.widths = widths
    utils.write_lines(self.bufnr, lines)
    return allowed_positions
end

return self