--[[

]]

---@module 'vector'
local Vector = require 'vector'
---@module 'matrix'
local Matrix = require 'matrix'

local direction_handler = {}

local right_rotation_matrix = Matrix.new(
    {
        { 0,0,1},
        { 0,1,0},
        {-1,0,0},
    }
)

local direction_identifier = {
    [Vector.new{ 1, 0, 0}:id()] = 'east',
    [Vector.new{-1, 0, 0}:id()] = 'west',
    [Vector.new{ 0, 1, 0}:id()] = 'up',
    [Vector.new{ 0,-1, 0}:id()] = 'down',
    [Vector.new{ 0, 0, 1}:id()] = 'south',
    [Vector.new{ 0, 0,-1}:id()] = 'north',
}

local cardinal_directions = {
    [direction_identifier[Vector.new{ 1,0, 0}:id()]] = true,
    [direction_identifier[Vector.new{-1,0, 0}:id()]] = true,
    [direction_identifier[Vector.new{ 0,0, 1}:id()]] = true,
    [direction_identifier[Vector.new{ 0,0,-1}:id()]] = true,
}
---Identifies if a direction is cardinal
---@param direction_name string
---@return boolean
function direction_handler.is_cardinal(direction_name)
    return cardinal_directions[direction_name] or false --false instead of nil is tidier
end

direction_handler.current_direction = Vector.new{1,0,0}

---Identify a cardinal direction from a unit vector
---@param direction_vector Vector
---@return string?
function direction_handler.identify(direction_vector)
    return direction_identifier[direction_vector:id()]
end


local direction_vectors = {
    [direction_identifier[Vector.new{ 1, 0, 0}:id()]] = Vector.new{ 1, 0, 0},
    [direction_identifier[Vector.new{-1, 0, 0}:id()]] = Vector.new{-1, 0, 0},
    [direction_identifier[Vector.new{ 0, 1, 0}:id()]] = Vector.new{ 0, 1, 0},
    [direction_identifier[Vector.new{ 0,-1, 0}:id()]] = Vector.new{ 0,-1, 0},
    [direction_identifier[Vector.new{ 0, 0, 1}:id()]] = Vector.new{ 0, 0, 1},
    [direction_identifier[Vector.new{ 0, 0,-1}:id()]] = Vector.new{ 0, 0,-1},
}
---Returns the direction vector associated to a given cardinal direction
---@param cardinal_direction_name string
---@return Vector
function direction_handler.to_vector(cardinal_direction_name)
    local base_vector = direction_vectors[cardinal_direction_name]
    assert(base_vector, tostring(cardinal_direction_name) .. ' is an unvalid cardinal direction')

    return Vector.new(base_vector)
end

---Returns opposite_direction
---@param cardinal_direction_name string
---@return string?
function direction_handler.opposite(cardinal_direction_name)
    local v = direction_handler.to_vector(cardinal_direction_name)
    ---Diagnostic isn't working <3
    ---@diagnostic disable-next-line: param-type-mismatch 
    return direction_handler.identify(-v)
end


---Sets the facing direction to a cardinal direction vector (for all needs of absolute coordinates)
---@param direction Vector
---@return boolean success
---@return string? reason
function direction_handler.set_facing_direction_to(direction)
    if not direction_handler.is_cardinal(direction_identifier[direction:id()]) then
        return false, 'Cannot be facing a non-cardinal direction'
    end

    direction_handler.current_direction = direction
    return true
end

---A way to perform turtle turning following cardinal directions. It doesn't enforce the cardinal directions are right, they're relative from starting position (defaulted to east). If you need to use absolute directions, use direction_handler.set_facing_direction_to()
---@param direction_name string
---@return boolean success
---@return string? reason
function direction_handler.turn_to(direction_name)
    if not direction_handler.is_cardinal(direction_name) then
        return false, 'Cannot face a non-cardinal direction'
    end

    local new_direction = direction_handler.to_vector(direction_name)
    local angle = math.acos(direction_handler.current_direction * new_direction)
    local turns = math.deg(angle) / 90
    if turns == 2 then
        turtle.turnRight()
        turtle.turnRight()
    elseif turns == 1 then
        local isRightTurn = right_rotation_matrix * direction_handler.current_direction == new_direction
        if isRightTurn then
            turtle.turnRight()
        else
            turtle.turnLeft()
        end
    elseif turns ~= 0 then
        error(string.format('The number of turns is %s, should be 0, 1 or 2', tostring(turns)))
    end

    direction_handler.current_direction = new_direction
    return true
end


return direction_handler