---@class CharacterSet
local self = {}

self.rounded = {
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

self.double = {
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

self.single = {
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

return self
