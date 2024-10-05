local M = {}

function M.valid_ipv4(ip)
    local parts = {ip:match("^(%d+)%.(%d+)%.(%d+)%.(%d+)/(%d+)$")}
    if #parts == 5 then
        for i, part in ipairs(parts) do
            if i == 5 and (tonumber(part) < 0 or tonumber(part) > 32) then
                return false
            elseif tonumber(part) < 0 or tonumber(part) > 255 then
                return false
            end
        end
        return true
    end
    return false
end

return M
