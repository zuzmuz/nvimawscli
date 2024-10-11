local utils = require('nvimawscli.utils.buffer')
local config = require('nvimawscli.config')
local display = require('nvimawscli.utils.display')
local View = require('nvimawscli.ui.views.view')

---@type Ec2Command
local command = require(config.commands .. '.ec2.instances')

---@class InstanceDetailsView: View
local M = setmetatable({}, { __index = View })

function M:load_content()
    utils.write_lines_string(self.bufnr, 'Fetching details...')
    command.describe_instance_details(self.data.instance_id,
        function(result, error)
            if error then
                utils.write_lines_string(M.bufnr, error)
            end
            if result then
                local response = vim.json.decode(result)
                self:render(response)
            end
        end)
end

function M:render(response)
    local new_response = vim.tbl_deep_extend('keep', unpack(response))
    utils.write_lines(self.bufnr, display.render(new_response))
end

return M
