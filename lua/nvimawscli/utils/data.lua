local M = {}

local data_path = vim.fn.stdpath('data') .. '/nvimawscli.json'

function M.load()
    local file = io.open(data_path, 'r')
    if file then
        local content = file:read('*all')
        M.store = vim.json.decode(content)
        file:close()
    else
        M.store = {}
        M.save()
    end
end


function M.save()
    local file = io.open(data_path, 'w')
    if file then
        file:write(vim.json.encode(M.store))
        file:close()
    end
end

return M
