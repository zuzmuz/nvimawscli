local config = require('nvimawscli.config')
local utils = require('nvimawscli.utils.buffer')
local View = require('nvimawscli.ui.views.view')

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
            self:submit()
        end
    })
end

function M:render()
    local lines = {
        "IpProtocol : " .. tostring(self.rule_details.IpProtocol),
        "FromPort : " .. tostring(self.rule_details.FromPort),
        "ToPort : " .. tostring(self.rule_details.ToPort),
        "Source : " .. tostring(self.rule_details.CidrIpv4 or
                                self.rule_details.CidrIpv6 or
                                self.rule_details.ReferencedGroupId or
                                self.rule_details.PrefixListId),
        "Description : " .. tostring(self.rule_details.Description),
    }
    utils.write_lines(self.bufnr, lines, true)
end

function M:submit()
    -- read content of buffer
    local lines = utils.get_lines(self.bufnr)
    print(vim.inspect(lines))
    -- WARN: should do sanity checks here
    local new_rule = {
        IpProtocol = lines[1]:match('IpProtocol : (.*)'),
        FromPort = tonumber(lines[2]:match('FromPort : (.*)')),
        ToPort = tonumber(lines[3]:match('ToPort : (.*)')),
        Source = lines[4]:match('Source : (.*)'),
        Description = lines[5]:match('Description : (.*)'),
    }

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
