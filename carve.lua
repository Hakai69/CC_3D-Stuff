local schematic = loadfile("compiler.lua")('huge_schematic.txt')

---@module 'spatial_explorer'
local spacial_explorer = require 'spatial_explorer'
---@module 'cardinal_directions_handler'
local direction_handler = require 'direction_handler'
---@module 'spatial_explorer'
local se = spacial_explorer.new(schematic)

local path = se:find_path{0,0,0}

for _, direction in ipairs(path) do

end