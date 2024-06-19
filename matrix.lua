---@module 'vector'
local Vector = require 'vector'

---@class Matrix
---@field rows integer
---@field columns integer
local Matrix = {}
Matrix.__index = Matrix

---Determines whether an object is a vector
---@param x any
---@return boolean
function Matrix.ismatrix(x)
	return getmetatable(x) == Matrix
end

---Creates a new vector
---@param coordinates table <integer, table<integer, number>>
---@return Matrix
function Matrix.new(coordinates)
	local matrix = {}
    matrix.rows = #coordinates
    matrix.columns = #coordinates[1]
	for row, values in ipairs(coordinates) do
		matrix[row] = {}
        assert(matrix.columns == #coordinates[row], 'Coordinates')
        for column, value in ipairs(values) do
            assert(type(value) == 'number', string.format('Elements of a matrix must be numbers and not %s (%s)', type(value), tostring(value)))
            matrix[row][column] = value
        end
	end

	setmetatable(matrix, Matrix)

	return matrix
end

---Returns the addition of two vectors
---@param m Matrix
---@return Matrix
function Matrix:__add(m)
	assert(self.rows == m.rows and self.columns == m.columns, 'Size mismatch between matrices being added')

	local coords = {}
	for i=1, self.rows do
		coords[i] = {}
		for j=1, self.columns do
			coords[i][j] = self[i][j] + m[i][j]
		end
	end
	return Matrix.new(coords)
end

---Returns the opposite vector
---@return Matrix
function Matrix:__unm()
	local coords = {}
	for i=1, self.rows do
		coords[i] = {}
		for j=1, self.columns do
			coords[i][j] = self[i][j] == 0 or 0 and -self[i][j]  --The fact that there's a -0 messes up with indexing tables
		end
	end
	return Matrix.new(coords)
end

---Returns the subtraction of two vectors
---@param m Matrix
---@return Matrix
function Matrix:__sub(m)
	return self + (-m)
end

---Returns the string representation of a vector
---@return string
function Matrix:__tostring()
	local parsedRows = {}
	for i=1, self.rows do
		parsedRows[i] = '{' .. table.concat(self[i], ', ') .. '}'
	end
	return '{\n\t' .. table.concat(parsedRows, '\n\t') ..'\n}'
end


---To be used as keys in tables, since I don't think lua supports unmutable objects.
---It uses the string representation, so it isn't guaranteed to be different from a normal string.
---@return string
function Matrix:id()
	return tostring(self)
end

---Determines equality between two matrices
---@param m Matrix
---@return boolean
function Matrix:__eq(m)
	local result = Matrix.ismatrix(m) and self.rows == m.rows and self.columns == m.columns
	local i = 1
	while result and i <= self.rows do
		local j = 1
		while result and j <= self.columns do
			result = self[i][j] == m[i][j]
			j = j + 1
		end
		i = i + 1
	end

	return result
end

---Performs multiplication between a matrix and a number, a vector or a matrix
---@param other number | Matrix
---@return Matrix
---@overload fun(self: Matrix, other: Vector): Vector
function Matrix:__mul(other)
	-- MATRIX * MATRIX
	if Matrix.ismatrix(other) then
		assert(self.columns == other.rows, 'Size mismatch between matrices being multiplied')
		local coords = {}
		for i=1, self.rows do
			coords[i] = {}
			for j=1, other.columns do
				local sum = 0
				for k=1, self.columns do
					sum = sum + self[i][k] * other[k][j]
				end
				coords[i][j] = sum == -0 and 0 or sum --The fact that there's a -0 messes up with indexing tables
			end
		end
		return Matrix.new(coords)

	-- VECTOR * MATRIX
	elseif Vector.isvector(other) then
		assert(self.columns == #other, 'Size mismatch between vector and matrix being multiplied')
		local coords = {}
		for i=1, self.rows do
			local sum = 0
			for j=1, self.columns do
				sum = sum + self[i][j] * other[j]
			end
			coords[i] = sum == -0 and 0 or sum  --The fact that there's a -0 messes up with indexing tables
		end
		return Vector.new(coords)

	-- NUMBER * MATRIX
	elseif type(other) == 'number' then
		local coords = {}
		for i=1, self.rows do
			coords[i] = {}
			for j=1, self.columns do
				local result = other * self[i][j]
				coords[i][j] = result == -0 and 0 or result  --The fact that there's a -0 messes up with indexing tables
			end
		end
		return Matrix.new(coords)
	end

	error('Invalid type in matrix multiplication, must be matrix, vector or number')
end


return Matrix