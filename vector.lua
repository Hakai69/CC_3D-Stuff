---@class Vector
local Vector = {}
Vector.__index = Vector

---Determines whether an object is a vector
---@param x any
---@return boolean
function Vector.isvector(x)
	return getmetatable(x) == Vector
end

---Creates a new vector
---@param coordinates table <integer, integer>
---@return Vector
function Vector.new(coordinates)
	local vector = {}
	for coordinate, value in ipairs(coordinates) do
		assert(type(value) == 'number', 'Elements of a vector must be numbers not ' .. type(value))
		vector[coordinate] = value
	end

	setmetatable(vector, Vector)

	return vector
end

---Returns the addition of two vectors
---@param v Vector
---@return Vector
function Vector:__add(v)
	if #self ~= #v then error(string.format('Attempted to sum vectors of length %d and %d', #self, #v)) end

	local coords = {}
	for i=1, #self do
		coords[i] = self[i] + v[i]
	end
	return Vector.new(coords)
end

---Returns the opposite vector
---@return Vector
function Vector:__unm()
	local coords = {}
	for i=1, #self do
		coords[i] = self[i] == 0 and 0 or -self[i] --The fact that there's a -0 messes up with indexing tables
	end
	return Vector.new(coords)
end

---Returns the subtraction of two vectors
---@param v Vector
---@return Vector
function Vector:__sub(v)
	return self + (-v)
end

---Returns the string representation of a vector
---@return string
function Vector:__tostring()
	return '<' .. table.concat(self, ', ') .. '>'
end

---Calculates the norm of a vector
---@return number
function Vector:norm()
	local sum = 0
	for i=1,#self do
		sum = sum + self[i]^2
	end
	return math.sqrt(sum)
end

---To be used as keys in tables, since I don't think lua supports unmutable objects.
---It uses the string representation, so it isn't guaranteed to be different from a normal string.
---@return string
function Vector:id()
	return tostring(self)
end

---Equality between two vectors
---@param v Vector
---@return boolean
function Vector:__eq(v)
	local result = #self == #v and Vector.isvector(v)
	local i = 1
	while result and i <= #v do
		result = self[i] == v[i]
		i = i + 1
	end

	return result
end

---Vector dot product
---@param v Vector
---@return Vector
function Vector:__mul(v)
	local coords = {}
	for i=1, #self do
		local result = self[i] * v[i]
		coords[i] = result == -0 and 0 or result  --The fact that there's a -0 messes up with indexing tables
	end
	return Vector.new(coords)
end


return Vector