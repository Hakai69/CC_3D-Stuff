local Vector = require('.vector')

local cardinal_direction_handler = {}

---@enum direction_names
cardinal_direction_handler.direction_names = {
    x = {
        [-1] = 'west',
        [1] = 'east'
    },
    y = {
        [-1] = 'down',
        [1] = 'up'
    },
    z = {
        [-1] = 'north',
        [1] = 'south'
    },
}



local cardinal_direction_identifier = {
    [1] = cardinal_direction_handler.direction_names.x[1],
    [-1] = cardinal_direction_handler.direction_names.x[-1],
    [2] = cardinal_direction_handler.direction_names.y[1],
    [-2] = cardinal_direction_handler.direction_names.y[-1],
    [3] = cardinal_direction_handler.direction_names.z[1],
    [-3] = cardinal_direction_handler.direction_names.z[-1],
}

---Identify a cardinal direction from a unit vector
---@param direction_vector Vector
---@return string?
function cardinal_direction_handler.identify(direction_vector)
    assert(direction_vector:norm() == 1, tostring(direction_vector) .. ' is not a canonical vector')
    assert(math.abs(direction_vector[1]) == 1 or math.abs(direction_vector[2]) == 1 or math.abs(direction_vector[3]) == 1, tostring(direction_vector) .. ' is not a canonical vector')

    local id = direction_vector[1] + direction_vector[2]*2 + direction_vector[3]*3
    return cardinal_direction_identifier[id]
end


local cardinal_direction_vectors = {
    [cardinal_direction_handler.direction_names.x[1]] = Vector.new(1,0,0),
    [cardinal_direction_handler.direction_names.x[-1]] = Vector.new(-1,0,0),
    [cardinal_direction_handler.direction_names.y[1]] = Vector.new(0,1,0),
    [cardinal_direction_handler.direction_names.y[-1]] = Vector.new(0,-1,0),
    [cardinal_direction_handler.direction_names.z[1]] = Vector.new(0,0,1),
    [cardinal_direction_handler.direction_names.z[-1]] = Vector.new(0,0,-1)
}
---Returns the direction vector associated to a given cardinal direction
---@param cardinal_direction string
---@return Vector
function cardinal_direction_handler.to_vector(cardinal_direction)
    local base_vector = cardinal_direction_vectors[cardinal_direction]
    assert(base_vector, tostring(cardinal_direction) .. ' is an unvalid cardinal direction')

    return Vector.new(base_vector)
end

---Returns opposite_direction
---@param cardinal_direction string
---@return string?
function cardinal_direction_handler.opposite_direction(cardinal_direction)
    local v = cardinal_direction_handler.to_vector(cardinal_direction)
    ---Diagnostic isn't working <3
    ---@diagnostic disable-next-line: param-type-mismatch
    return cardinal_direction_handler.identify(-v)
end


return cardinal_direction_handler