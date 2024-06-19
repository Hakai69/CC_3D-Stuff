if not table.shuffle then
    ---@module 'table_extras'
    require 'table_extras'
end
---@module 'tensor'
local Tensor = require 'spatial_tensor'
---@module 'vector'
local Vector = require 'vector'
---@module 'cardinal_directions_handler'
local direction_handler = require 'direction_handler'

local my_module = {}

---@class spatial_explorer
---@field tensor Tensor
---@field explored_tensor Tensor
---@field path table
---@field private stack table
local spatial_explorer = {}
spatial_explorer.__index = spatial_explorer

---Initializes a spatial_explorer for a tensor
---@param tensor Tensor
---@return spatial_explorer
function my_module.new(tensor)
    local new_instance = {
        tensor=tensor,
        explored_tensor=Tensor.new(tensor.dimensions, tensor.min, tensor.max),
        path = {},
        stack = {}
    }
    setmetatable(new_instance, spatial_explorer)
    return new_instance
end

---Finds all positions adyacent to the parameter position
---@param position Vector
---@return table?
function spatial_explorer:find_all_conexions(position)
    local conexions = {}
    local new_position = Vector.new(position)

    for i=1, self.tensor.dimensions do
        for ii=-1, 1, 2 do
            new_position[i] = position[i] + ii
            if self.tensor:get(new_position) ~= 0 then
                table.insert(conexions, new_position)
            end
        end
        new_position[i] = position[i]
    end
    return table.shuffle(conexions) -- Shuffled for flavour :3
end

---Finds any new position adyacent to the parameter position
---@param position table
---@return table
function spatial_explorer:find_any_new_conexion(position)
    local conexions = {}
    local new_position = Vector.new(position)

    for i=1, self.tensor.dimensions do
        for ii=-1, 1, 2 do
            new_position[i] = position[i] + ii
            if self.tensor:get(new_position) ~= 0 and self.explored_tensor:get(new_position) == 0 then
                table.insert(conexions, Vector.new(new_position))
            end
        end
        new_position[i] = position[i]
    end
    
    return table.shuffle(conexions)[1] -- Shuffled for flavour :3
end

---Finds a path that explores the entire space from a position
---@param position table | Vector
---@return table
function spatial_explorer:find_path(position)
    position = Vector.new(position)

    self.path = {}
    self.explored_tensor = Tensor.new(3)
    self.stack = {position}
    while #self.stack > 0 do
        local current_position = self.stack[#self.stack]
        self.explored_tensor:set(1, current_position)

        local next_position = self:find_any_new_conexion(current_position)
        if not next_position then
            table.insert(self.path, direction_handler.opposite_direction(self.path[#self.path]))
            self.stack[#self.stack] = nil
        else
            table.insert(self.stack, next_position)
            table.insert(self.path, direction_handler.identify(next_position - current_position))
        end
    end

    return self.path
end


return my_module