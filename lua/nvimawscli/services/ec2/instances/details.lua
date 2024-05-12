local utils = require('nvimawscli.utils.buffer')
local config = require('nvimawscli.config')
---@type Ec2Handler
local command = require(config.commands .. '.ec2')
local itertools = require('nvimawscli.utils.itertools')

---@class InstanceDetailsManager
local self = {}


function self.load(instance_id)
    self.instance_id = instance_id

    print('what the buff ', self.bufnr, self.winnr)
    if not self.bufnr then
        self.bufnr = utils.create_buffer('ec2.instances.details')
    end

    if not self.winnr or not utils.check_if_window_exists(self.winnr) then
        self.winnr = utils.create_window(self.bufnr, config.details.split)
    end

    vim.api.nvim_set_current_win(self.winnr)

    self.fetch()
end

function self.fetch()
    utils.write_lines_string(self.bufnr, 'Fetching details...')

    command.describe_instance_details(self.instance_id,
        function(result, error)
            if error then
                utils.write_lines_string(self.bufnr, error)
            end
            if result then
                local response = vim.json.decode(result)
                self.rows = self.parse(response)
                -- self.render(self.rows)
            end
        end)
end

function self.parse(response)
    local new_response = vim.tbl_deep_extend('keep', unpack(response))

    utils.write_lines_string(self.bufnr, vim.inspect(new_response))
    -- local details = itertools.imap_values(config.ec2.instances.preferred_details,
    --     function(detail_key)
    --         local detail_value = new_response[detail_key]
    --         if type(detail_value) == 'table' then
    --             return { detail_key .. ": " .. vim.inspect(detail_value) }
    --         else
    --             return { detail_key .. ": " .. tostring(detail_value) }
    --         end
    --     end)
    -- return itertools.flatten(details)
end

function self.render(rows)
    utils.write_lines(self.bufnr, rows)
end
return self
