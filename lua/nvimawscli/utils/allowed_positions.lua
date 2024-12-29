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
local M = {}

function M.new(bufnr)
    return setmetatable({ bufnr = bufnr }, { __index = M })
end

function M:set_allowed_positions(allowed_positions)
    self.allowed_positions = allowed_positions
end

local function find_allowed_column(allowed_line, current_position, last_position)
    for i, allowed_column in ipairs(allowed_line) do
        if allowed_column >= current_position[2] then
            if i > 1 then
                local column_direction_to_left = last_position[2] > current_position[2]
                local column_same = last_position[2] == current_position[2]
                if column_direction_to_left then
                    return current_position[1], allowed_line[i-1]
                elseif column_same and current_position[2] - allowed_line[i - 1] <
                    allowed_column - current_position[2]then
                    return current_position[1], allowed_line[i - 1]
                end -- last condition is covered by the outside return
            end
            return current_position[1], allowed_column
        end
    end
    -- if current position is to the right of all allowed columns get last column
    return current_position[1], allowed_line[#allowed_line]
end

function M:set_allowed_positions(allowed_positions)
    self.allowed_positions = Iterable(allowed_positions):imap_values(
        function (value)

        end
    )
    end):to_list()
end

function M:get_next_position(current_position)
    if not self.allowed_positions or #self.allowed_positions == 0 then
        return current_position
    end

    self.last_position = self.last_position or current_position

    local allowed_line = self.allowed_positions[current_position[1]]

    if allowed_line and #allowed_line > 0 then -- if current line is valid find valid column
        return current_position[1], find_allowed_column(allowed_line, current_position, self.last_position)
    else -- current line is not valid
        if self.last_position[1] > current_position[1] then
            for i = current_position[1]-1, 1, -1 do
                if self.allowed_positions[i] then
                    return i, find_allowed_column(self.allowed_positions[i],
                                                  current_position,
                                                  self.last_position)
                end
            end
            for i = current_position[1]+1, #self.allowed_positions do
                if self.allowed_positions[i] then
                    return i, find_allowed_column(self.allowed_positions[i],
                                                  current_position,
                                                  self.last_position)
                end
            end
        elseif self.last_position[1] < current_position then
            for i = current_position[1]+1, #self.allowed_positions do
                if self.allowed_positions[i] then
                    return i, find_allowed_column(self.allowed_positions[i],
                                                  current_position,
                                                  self.last_position)
                end
            end
            for i = current_position[1]-1, 1, -1 do
                if self.allowed_positions[i] then
                    return i, find_allowed_column(self.allowed_positions[i],
                                                  current_position,
                                                  self.last_position)
                end
            end
        else
            
        end
    end
end

return M
