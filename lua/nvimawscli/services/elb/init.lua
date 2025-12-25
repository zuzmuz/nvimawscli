local config = require('nvimawscli.config')
local ListView = require('nvimawscli.ui.views.listview')

---@class ElbView: ListView
local M = setmetatable({}, { __index = ListView })

M.name = 'elb'

M.preferred_services_header = "Preferred Services"

M.all_services_header       = "All       Services"

M.all_services = {
    "application_load_balancers",
    "target_groups",
}

function M:fetch_lines(callback)
    ---@type Content
  local content = {}

  content.sections = {}

  if config.elb.preferred_services then
    content.sections[#content.sections+1] = {
      title = M.preferred_services_header,
      lines = config.elb.preferred_service
    }
  end
  content.sections[#content.sections+1] = {
    title = M.all_services_header,
    lines = M.all_services
  }
  callback(content)
end

function M:did_select_item(item)
  local subservice_name = item.text
  local status, subservice = pcall(require, 'nvimawscli.services.elb.'.. subservice_name)
  if status then
    subservice:show(config.menu.split)
    vim.api.nvim_win_set_width(M.winnr, config.menu.width)
  else
    vim.notify(
        'Elb subservice not found: ' .. subservice_name,
        vim.log.levels.WARN
    )
  end
end

return M
