--[[
I need to rethink this
I shouldn't be returning names for directions generally, it should be handled inside, potentially using matrices to represent rotations and vectors for direction, then correlating them to the turtle commands
Using enums is a scuffed way of doing it
]]


local Vector = require('.vector')

local direction_handler = {}

local cardinal_direction_identifier = {
    [Vector.new{ 1, 0, 0}:id()] = 'east',
    [Vector.new{-1, 0, 0}:id()] = 'west',
    [Vector.new{ 0, 1, 0}:id()] = 'up',
    [Vector.new{ 0,-1, 0}:id()] = 'down',
    [Vector.new{ 0, 0, 1}:id()] = 'south',
    [Vector.new{ 0, 0,-1}:id()] = 'north',
}

direction_handler.current_direction = Vector.new{1,0,0}

---Identify a cardinal direction from a unit vector
---@param direction_vector Vector
---@return string?
function direction_handler.identify(direction_vector)
    return cardinal_direction_identifier[direction_vector:id()]
end


local direction_vectors = {
    [direction_handler.direction_names.x[1]] = Vector.new{1,0,0},
    [direction_handler.direction_names.x[-1]] = Vector.new{-1,0,0},
    [direction_handler.direction_names.y[1]] = Vector.new{0,1,0},
    [direction_handler.direction_names.y[-1]] = Vector.new{0,-1,0},
    [direction_handler.direction_names.z[1]] = Vector.new{0,0,1},
    [direction_handler.direction_names.z[-1]] = Vector.new{0,0,-1}
}
---Returns the direction vector associated to a given cardinal direction
---@param cardinal_direction string
---@return Vector
function direction_handler.to_vector(cardinal_direction)
    local base_vector = direction_vectors[cardinal_direction]
    assert(base_vector, tostring(cardinal_direction) .. ' is an unvalid cardinal direction')

    return Vector.new(base_vector)
end

---Returns opposite_direction
---@param cardinal_direction string
---@return string?
function direction_handler.opposite_direction(cardinal_direction)
    local v = direction_handler.to_vector(cardinal_direction)
    ---Diagnostic isn't working <3
    ---@diagnostic disable-next-line: param-type-mismatch 
    return direction_handler.identify(-v)
end


function direction_handler.turn_to(direction_name)
    if direction_name == direction_handler.direction_names.y[1] or direction_name == direction_handler.direction_names.y[-1] then
        return true
    end


end


return direction_handler