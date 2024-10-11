local utils = require('nvimawscli.utils.buffer')
local itertools = require("nvimawscli.utils.itertools")
local config = require('nvimawscli.config')
---@type Ec2Command
local command = require(config.commands .. '.ec2.instances')
local graphs = require("nvimawscli.utils.graphs")

---@class InstanceMonitoringManager
local M = {}

-- NOTE: this will be refactored

function M.show(instance_id, split)
    M.instance_id = instance_id

    if not M.bufnr then
        M.bufnr = utils.create_buffer('ec2.instances.monitoring')
    end

    if not M.winnr or not utils.check_if_window_exists(M.winnr) then
        M.winnr = utils.create_window(M.bufnr, split)
    end

    vim.api.nvim_set_current_win(M.winnr)

    M.fetch()
end

function M.fetch()
    utils.write_lines_string(M.bufnr, 'Fetching monitoring...')

    command.describe_instance_monitoring(M.instance_id, os.time(), 10, 600,
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
    local lines = itertools.flatten(itertools.map_values(response.MetricDataResults,
        function(metric)
            local graph = graphs.render(metric.Values, 10, 0, 'block', 1)
            table.insert(graph, 1, metric.Label)
            table.insert(graph, 2, tostring(math.max(unpack(metric.Values))))
            return graph
        end))
    utils.write_lines(M.bufnr, lines)
end

return M
