local utils = require('nvimawscli.utils.buffer')
local config = require('nvimawscli.config')
local itertools = require('nvimawscli.utils.itertools')

local table_renderer = require('nvimawscli.utils.tables')

---@type Ec2Handler
local command = require(config.commands .. '.ec2')

---@class TargetGroupsManager
local self = {}

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
        nil,
        1,
        config.table
    )
    self.widths = widths
    utils.write_lines(self.bufnr, lines)
    return allowed_positions
end

return self