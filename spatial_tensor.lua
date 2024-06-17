local my_module = {}
local my_module_mt = {}

---@class Tensor
---@field dimensions integer
---@field min table
---@field max table
local Tensor = {}
Tensor.__index = Tensor

---Instantiates a new object
---@param dimensions integer
---@param min? table <integer, integer>
---@param max? table <integer, integer>
---@return Tensor
function my_module.new(dimensions, min, max)
    min = min or {}
    max = max or {}
    local tensor = {dimensions=dimensions, min={}, max={}}
    setmetatable(tensor, Tensor)
    return tensor
end

---Finds whether the variable is a tensor
---@param x any
function my_module.istensor(x)
    return getmetatable(x) == Tensor
end


---Sets the position of the tensor to the value
---@param value any
---@param position table <integer, integer>
function Tensor:set(value, position)
    if #position ~= self.dimensions then
        error(string.format('tensor has %d dimensions, not %d', self.dimensions, #position))
    end

    local temp = self
    for i=1, #position - 1 do
        temp[position[i]] = temp[position[i]] or {}
        temp = temp[position[i]]

        if not self.min[i] then
            self.min[i] = position[i]
            self.max[i] = position[i]
        elseif self.min[i] > position[i] then
            self.min[i] = position[i]
        elseif self.max[i] < position[i] then
            self.max[i] = position[i]
        end

    end
    temp[position[#position]] = value

    if not self.min[#position] then
        self.min[#position] = position[#position]
        self.max[#position] = position[#position]
    elseif self.min[#position] > position[#position] then
        self.min[#position] = position[#position]
    elseif self.max[#position] < position[#position] then
        self.max[#position] = position[#position]
    end

end

---Access a position in the tensor
---@param position table <integer, integer>
---@return any
function Tensor:get(position)
    local temp = self
    for i=1, #position do
        if not temp[position[i]] then
            return 0
        end
        temp = temp[position[i]]
    end
    return temp
end

---Iterator through any cordinates, integer to set static, nil to iterate
---@param set_positions table <integer, integer | nil>
---@return function
function Tensor:iter_any(set_positions)
    local co = coroutine.create(
        function ()
            local position = {}
            for i=1, self.dimensions do
                if set_positions[i] then
                    if set_positions[i] < self.min[i] or set_positions[i] > self.max[i] then
                        return
                    end
                    position[i] = set_positions[i]
                else
                    position[i] = self.min[i]
                end
            end
            local new_position
            local i
            repeat
                coroutine.yield(position, self:get(position))
                new_position = false
                i = self.dimensions
                repeat
                    if set_positions[i] then
                        i = i - 1
                    elseif position[i] + 1 > self.max[i] then
                        position[i] = self.min[i]
                        i = i - 1
                    else
                        position[i] = position[i] + 1
                        new_position = true
                    end
                until new_position or i == 0
            until i == 0
        end
    )

    return function()
        local _, pos, value = coroutine.resume(co)
        return pos, value
    end
end

---Iterator through all cordinates
---@return function
function Tensor:iter_all()
    return self:iter_any({})
end

do
    return my_module
end

---Test code
local a = my_module.new(2)
a:set(1, {2, 1})
a:set(1, {2, 2})
a:set(1, {2,-1})
a:set(1, {1, 0})
local value = a:get{2, 1}

for index, element in a:iter_all() do
    local k, v = next(index)
    io.write('{', v)
    for _, coord in next, index, k do
        io.write(', ' .. coord)
    end
    io.write('}\t')
    print(element)
end