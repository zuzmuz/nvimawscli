local utils = require('nvimawscli.utils.buffer')
local config = require('nvimawscli.config')
---@type Ec2Handler
local command = require(config.commands .. '.ec2')
local display = require('nvimawscli.utils.display')

---@class InstanceDetailsManager
local M = {}


function M.load(instance_id)
    M.instance_id = instance_id

    if not M.bufnr then
        M.bufnr = utils.create_buffer('ec2.instances.details')
    end

    if not M.winnr or not utils.check_if_window_exists(M.winnr) then
        M.winnr = utils.create_window(M.bufnr, config.details.split)
    end

    vim.api.nvim_set_current_win(M.winnr)

    M.fetch()
end

function M.fetch()
    utils.write_lines_string(M.bufnr, 'Fetching details...')

    command.describe_instance_details(M.instance_id,
        function(result, error)
            if error then
                utils.write_lines_string(M.bufnr, error)
            end
            if result then
                local response = vim.json.decode(result)
                M.render(response)
            end
        end)
end

function M.render(response)
    local new_response = vim.tbl_deep_extend('keep', unpack(response))
    utils.write_lines(M.bufnr, display.render(new_response))
end

return M
