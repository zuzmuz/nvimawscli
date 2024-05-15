---@class CharacterSet
local M = {}

M.rounded = {
    horizontal = '─',
    vertical = '│',
    top_left = '╭',
    top_right = '╮',
    bottom_left = '╰',
    bottom_right = '╯',
    top_tee = '┬',
    bottom_tee = '┴',
    left_tee = '├',
    right_tee = '┤',
    cross = '┼',
}

M.double = {
    horizontal = '═',
    vertical = '║',
    top_left = '╔',
    top_right = '╗',
    bottom_left = '╚',
    bottom_right = '╝',
    top_tee = '╦',
    bottom_tee = '╩',
    left_tee = '╠',
    right_tee = '╣',
    cross = '╬',
}

M.single = {
    horizontal = '─',
    vertical = '│',
    top_left = '┌',
    top_right = '┐',
    bottom_left = '└',
    bottom_right = '┘',
    top_tee = '┬',
    bottom_tee = '┴',
    left_tee = '├',
    right_tee = '┤',
    cross = '┼',
}

return M
