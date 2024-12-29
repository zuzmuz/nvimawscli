local Iterable = require('nvimawscli.utils.itertools').Iterable

---@alias AllowedPositionLine integer[]

---@class AllowedPositionGrid
---@field allowed_positions AllowedPositionLine[]
---
---The structure is basically a list of all lines
local AllowedPositionGrid = {}

function AllowedPositionGrid.new()
    return setmetatable({}, { __index = AllowedPositionGrid })
end

---@class AllowedPositions
---@field allowed_positions AllowedPositionGrid[]
---@field last_position integer[]
---@field bufnr integer
---@field line_lookup integer[]
---@field allowed_lookup table
local M = {}

function M.new(bufnr)
    return setmetatable({ bufnr = bufnr }, { __index = M })
end

function M:set_allowed_positions(allowed_positions)
    self.allowed_positions = allowed_positions

    self.line_lookup = Iterable(allowed_positions):associate(
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

    self.allowed_lookup = Iterable(self.line_lookup):associate(
        function(key, value)
            return value, key
        end
    ).table
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

function M:get_next_position(current_position)
    if not self.allowed_positions or #self.allowed_positions == 0 then
        return current_position
    end

    self.last_position = self.last_position or current_position

    local allowed_line = self.allowed_positions[current_position[1]]

    if allowed_line and #allowed_line > 0 then -- if current line is valid find valid column
        return current_position[1], find_allowed_column(allowed_line, current_position, self.last_position)
    else                                       -- current line is not valid
        for i, line in self.line_lookup do
            if line >= current_position[1] then
                if i > 1 then
                    local line_direction_up = self.last_position[1] > current_position[1]
                    local line_same = self.last_position[1] == current_position[1]
                    if line_direction_up then
                        return self.line_lookup[i - 1], find_allowed_column(
                            self.allowed_positions[self.line_lookup[i - 1]],
                            current_position,
                            self.last_position)
                    elseif line_same and current_position[1] - self.line_lookup[i - 1] <
                        line - current_position[1] then
                        return line, find_allowed_column(
                            self.allowed_positions[line],
                            current_position,
                            self.last_position)
                    end
                end
            elseif line == current_position[1] then
                return line, find_allowed_column(
                    self.allowed_positions[line],
                    current_position,
                    self.last_position)
            end
        end
    end
    local line = self.line_lookup[#self.line_lookup]
    return return self.allowed_positions(line), find_allowed_column(
                    self.allowed_positions[line],
                    current_position,
                    self.last_position)
end

return M
