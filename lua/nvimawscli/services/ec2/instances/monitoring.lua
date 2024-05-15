local utils = require('nvimawscli.utils.buffer')
local itertools = require("nvimawscli.utils.itertools")
local config = require('nvimawscli.config')
---@type Ec2Handler
local command = require(config.commands .. '.ec2')
local graphs = require("nvimawscli.utils.graphs")

---@class InstanceMonitoringManager
local self = {}

function self.load(instance_id)
    self.instance_id = instance_id

    if not self.bufnr then
        self.bufnr = utils.create_buffer('ec2.instances.monitoring')
    end

    if not self.winnr or not utils.check_if_window_exists(self.winnr) then
        self.winnr = utils.create_window(self.bufnr, config.details.split)
    end

    vim.api.nvim_set_current_win(self.winnr)

    self.fetch()
end

function self.fetch()
    utils.write_lines_string(self.bufnr, 'Fetching monitoring...')

    command.describe_instance_monitoring(self.instance_id, os.time(), 3, 600,
        function(result, error)
            if error then
                utils.write_lines_string(self.bufnr, error)
            end
            if result then
                local response = vim.json.decode(result)
                self.render(response)
            end
        end)
end


function self.render(response)
    local lines = itertools.flatten(itertools.map_values(response.MetricDataResults,
        function(metric)
            local graph = graphs.render(metric.Values, 5, 0, 'block', 1)
            table.insert(graph, 1, metric.Label)
            table.insert(graph, 2, tostring(math.max(unpack(metric.Values))))
            return graph
        end))
    utils.write_lines(self.bufnr, lines)
end

return self
