local config = require('nvimawscli.config')
local utils = require('nvimawscli.utils.buffer')
local popup = require('nvimawscli.ui.popup')
local View = require('nvimawscli.ui.views.view')
local itertools = require('nvimawscli.utils.itertools')

---@type SecurityGroupsCommand
local command = require(config.commands .. '.ec2.security_groups')

---@class EditSecurityGroupRulesView: View
local M = setmetatable({}, { __index = View })

M.name = 'ec2.security_groups.rules.edit'
M.editable = true

function M:load_content()
    utils.write_lines_string(self.bufnr, 'Fetching security group rule details...')
    self.ready = false
    command.describe_security_group_rule(self.data.group_id, self.data.rule.Id,
        function(result, error)
            if error then
                utils.write_lines_string(self.bufnr, error)
            end
            if result then
                self.rule_details = vim.json.decode(result)
                self:render()
            end
            self.ready = true
        end)
end

function M:set_keymaps()
    vim.api.nvim_buf_set_keymap(self.bufnr, 'n', '<CR>', '', {
        callback = function()
            if not self.ready then
                return
            end
            local title, message, actions, new_rule = self:sanitize()
            popup.create_floating_select(
                title,
                message,
                actions,
                config.table,
                function(confirmation)
                    if confirmation == 1 and new_rule then
                        self:submit(new_rule)
                    end
                end)
        end
    })
end

---@return string, string[], string[], table?
function M:sanitize()
    local buffer_lines = utils.get_lines(self.bufnr)
    local diffs = {}
    local new_rule = {}

    if #buffer_lines ~= #self.lines then
        return 'Error', { 'Invalid data', 'Some params were removed' }, { 'ok' }, nil
    end
    for i, line in ipairs(self.lines) do
        local new_line = buffer_lines[i]

        local line_key = line:match('([^:]*) :')
        local line_value = line:match('[^:]* : (.*)')
        local new_line_key = new_line:match('([^:]*) :')
        local new_line_value = new_line:match('[^:]* : (.*)')

        if line_key ~= new_line_key then
            return 'error',
                    { 'invalid data', 'key mismatch line ' .. i .. ' expected ' .. line_key },
                    { 'ok' }, nil
        end

        if line_value ~= new_line_value then
            diffs[#diffs+1] = line_key .. ' : ' .. line_value .. ' -> ' .. new_line_value
        end
        new_rule[line_key] = new_line_value
    end
    return 'submit changes', diffs,  { 'submit', 'cancel' }, new_rule
end

function M:render()
    self.lines = {
        "IpProtocol : " .. tostring(self.rule_details.IpProtocol),
        "FromPort : " .. tostring(self.rule_details.FromPort),
        "ToPort : " .. tostring(self.rule_details.ToPort),
        "Source : " .. tostring(self.rule_details.CidrIpv4 or
            self.rule_details.CidrIpv6 or
            self.rule_details.ReferencedGroupId or
            self.rule_details.PrefixListId),
        "Description : " .. tostring(self.rule_details.Description),
    }
    utils.write_lines(self.bufnr, self.lines, true)
end

function M:submit(new_rule)
    command.modify_security_group_rule(self.data.group_id, self.data.rule.Id, new_rule,
        function(result, error)
            if error then
                utils.write_lines_string(self.bufnr, error)
            end
            if result then
                utils.write_lines_string(self.bufnr, 'Security group rule updated successfully')
            end
        end)
end

return M
