if not table.unpack then
	---@diagnostic disable-next-line: deprecated
	table.unpack = unpack
end

--- Vector module
local my_module = {}
local my_module_mt = {}

---@class Vector
local Vector = {}
Vector.__index = Vector

---Determines whether an object is a vector
---@param x any
---@return boolean
function my_module.isvector(x)
	return getmetatable(x) == Vector
end

---Creates a new vector
---@overload fun(coordinates: table | Vector): Vector
---@overload fun(...: number): Vector
function my_module.new(...)
	local args = {...}
	if type(args[1]) == 'table' then
		local v = args[1]
		args = {}
		for i=1, #v do
			assert(type(v[i]) == 'number', 'Elements of a vector must be numbers not ' .. type(v[i]))
			args[i] = v[i]
		end
	else
		for i=1, #args do
			assert(type(args[i]) == 'number', 'Elements of a vector must be numbers not ' .. type(args[i]))
		end
	end

	local vector = args
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
		table.insert(coords, self[i] + v[i])
	end
	return my_module(table.unpack(coords))
end

---Returns the opposite vector
---@return Vector
function Vector:__unm()
	local coords = {}
	for i=1, #self do
		if self ~= 0 then
			table.insert(coords, - self[i])
		else --The fact that there's a -0 messes up with indexing tables
			table.insert(coords, self[i])
		end
	end
	return my_module(table.unpack(coords))
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

-- Functions I don't need but I want a full implementation

---Determines equality between two vectors
---@param v Vector
---@return boolean
function Vector:__eq(v)
	local result = #self == #v and my_module.isvector(self) and my_module.isvector(v)
	local i = 1
	while result and i <= #v do
		result = self[i] == v[i]
		i = i + 1
	end

	return result
end

return my_module