local M = {}

local data_path = vim.fn.stdpath('data') .. '/nvimawscli.json'

function M.load()
    local file = io.open(data_path, 'r')
    vim.notify("Loading nvimawscli data from " .. data_path)
    if file then
        local content = file:read('*all')
        M.store = vim.json.decode(content)
        vim.notify("Loaded nvimawscli data from " .. data_path)
        file:close()
    else
        vim.notify("No nvimawscli data file found at " .. data_path)
        M.store = {}
        M.save()
    end
end


function M.save()
    local file = io.open(data_path, 'w')
    if file then
        print(vim.inspect(M.store))
        file:write(vim.json.encode(M.store))
        file:close()
    end
end

return M
