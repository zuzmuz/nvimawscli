local Iterable = require('nvimawscli.utils.itertools').Iterable

---@alias LegalLine integer[]

---@class LegalGrid
---@field legal_lines LegalLine[]
---@field last_position integer[]
---@field bufnr integer
---@field legal_line_indices integer[]
---@field legal_line_lookup_table table
local M = {}

function M.new()
    return setmetatable({}, { __index = M })
end

---@param legal_lines LegalLine[]
function M:set_legal_lines(legal_lines)
    self.legal_lines = legal_lines

    self.legal_line_indices = Iterable(legal_lines):associate(
        function(index, value)
            if value and #value > 0 then
                return index, value
            end
            return index, nil
        end
    ):map(
        function(key, _)
            return key
        end
    ).table

    self.legal_line_lookup_table = Iterable(self.legal_line_indices):associate(
        function(key, value)
            return value, key
        end
    ).table

    print('legal line indices', vim.inspect(self.legal_line_indices))
    print('legal line lookup table', vim.inspect(self.legal_line_lookup_table))
end

local function find_allowed_column(allowed_line, current_position, last_position)
    for i, allowed_column in ipairs(allowed_line) do
        if allowed_column > current_position[2] then
            if i > 1 then
                local column_direction_to_left = last_position[2] > current_position[2]
                local column_same = last_position[2] == current_position[2]
                if column_direction_to_left then
                    return allowed_line[i - 1]
                elseif column_same and current_position[2] - allowed_line[i - 1] <
                    allowed_column - current_position[2] then
                    return allowed_line[i - 1]
                end -- last condition is covered by the outside return
            end
            return allowed_column
        elseif allowed_column == current_position[2] then
            return allowed_column
        end
    end
    -- if current position is to the right of all allowed columns get last column
    return allowed_line[#allowed_line]
end

function M:get_legal_position(current_position)
    if not self.legal_lines or #self.legal_lines == 0 then
        return current_position
    end

    print('current position ' .. vim.inspect(current_position) .. ' ' .. 'last position ' .. vim.inspect(self.last_position))

    self.last_position = self.last_position or current_position

    local allowed_line = self.legal_lines[current_position[1]]

    if allowed_line and #allowed_line > 0 then -- if current line is valid find valid column
        self.last_position = {
            current_position[1],
            find_allowed_column(allowed_line, current_position, self.last_position)
        }
        return self.last_position
    else                                       -- current line is not valid
        for i, line in ipairs(self.legal_line_indices) do
            if line > current_position[1] then
                if i > 1 then
                    local line_direction_up = self.last_position[1] > current_position[1]
                    local line_same = self.last_position[1] == current_position[1]
                    if line_direction_up then
                        self.last_position = {
                            self.legal_line_indices[i - 1],
                            find_allowed_column(
                                self.legal_lines[self.legal_line_indices[i - 1]],
                                current_position,
                                self.last_position)
                            }
                        return self.last_position
                    elseif line_same and current_position[1] - self.legal_line_indices[i - 1] <
                        line - current_position[1] then

                        self.last_position = {
                            self.legal_lines[self.legal_line_indices[i - 1]],
                            find_allowed_column(
                                self.legal_lines[line],
                                current_position,
                                self.last_position)
                            }
                        return self.last_position
                    end
                end
                return line,
                    find_allowed_column(
                        self.legal_lines[line],
                        current_position,
                        last_position)
            elseif line == current_position[1] then
                return line, find_allowed_column(
                    self.legal_lines[line],
                    current_position,
                    last_position)
            end
        end
        local line = self.legal_line_indices[#self.legal_line_indices]
        return line, find_allowed_column(
            self.legal_lines[line],
            current_position,
            last_position)
    end
end

return M
