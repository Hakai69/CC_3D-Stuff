---@module 'tensor'
local Tensor = require('.tensor')

---@module 'term'
local term = require('.term')

local compiler_args = {...}

local schematic = Tensor.new(3)
local pieces = {}


---Splits a string by a separator
---@param str string
---@param sep? string
---@return table
local function split(str, sep)
    sep = sep or "%s"

    local t = {}
    for cut in string.gmatch(str, "([^"..sep.."]+)") do
            table.insert(t, cut)
    end
    return t
end

---Reads file with commands to make an schematic and returns the commands in a table
---@param filename string
---@return table
local function read_schematic(filename)
    local commands = {}
    for line in io.lines(filename) do
        table.insert(commands, split(line))
    end

    return commands
end

---Takes however many parameters and turns them into numbers
---@param ... any
---@return number ...
local function numeric_inputs(...)
    local arg = {...}
    local output = {}
    for _, input in ipairs(arg) do
        table.insert(output, tonumber(input))
    end
    return table.unpack(output)
end


local allign_table = {
    ["t"] = function (piece)
        return piece.y + piece.sy
    end,
    ['b'] = function (piece, new_piece_size)
        return piece.y - new_piece_size
    end,
    ['e'] = function (piece)
        return piece.x + piece.sx
    end,
    ['w'] = function (piece, new_piece_size)
        return piece.x - new_piece_size
    end,
    ['s'] = function (piece)
        return piece.z + piece.sz
    end,
    ['n'] = function (piece, new_piece_size)
        return piece.z - new_piece_size
    end,
    ['c'] = function (piece, new_piece_size, axis)
        local piece_size = piece['s' .. axis]
        local piece_position = piece[axis]
        if piece_size % 2 == new_piece_size % 2 then
            if piece_size % 2 == 1 then
                return piece_position + (piece_size + 1)/2 - (new_piece_size + 1)/2
            elseif piece_size % 2 == 0 then
                return piece_position + piece_size/2 - new_piece_size/2
            end
        else
            error('Tried to line up two pieces with different parity!')
        end
    end,
}
local alling_table_mt = {
    __index = function (t, k)
        error(k.. ' is not a valid allignment')
    end
}
setmetatable(allign_table, alling_table_mt)

---From allignment notations to coordinates
---@param parameter string Parameter to parse
---@param new_piece_size integer
---@param axis string 
---@return integer
local function allign(parameter, new_piece_size, axis)
    local allignment_type = string.sub(parameter, 1, 1)
    local piece_id = #pieces - (tonumber(string.sub(parameter,2)) or 0)

    local piece = pieces[piece_id]

    return allign_table[allignment_type](piece, new_piece_size, axis)
end

---Determines whether x, y, z need to be parsed in terms of allignment or are numbers and returns the position
---@param x string
---@param y string
---@param z string
---@param sx integer
---@param sy integer
---@param sz integer
---@return integer
---@return integer
---@return integer
local function process_position(x, y, z, sx, sy, sz)
    local processed_x = tonumber(x) or allign(x, sx, 'x')
    local processed_y = tonumber(y) or allign(y, sy, 'y')
    local processed_z = tonumber(z) or allign(z, sz, 'z')
    return processed_x, processed_y, processed_z
end


-- COMMANDS --

---Creates a cuboid at x, y, z of size sx, sy, sz of material m
---@param x_positioning string
---@param y_positioning string
---@param z_positioning string
---@param x_size string
---@param y_size string
---@param z_size string
---@param material string
local function cuboid(x_positioning, y_positioning, z_positioning, x_size, y_size, z_size, material)
    local sx, sy, sz, m = numeric_inputs(x_size, y_size, z_size, material)
    local x, y, z = process_position(x_positioning, y_positioning, z_positioning, sx, sy, sz)

    for i=x, sx + x - 1 do
        for j=y, sy + y - 1 do
            for k=z, sz + z - 1 do
                schematic:set(m, {i, j, k})
            end
        end
    end
    return {x=x, y=y, z=z, sx=sx, sy=sy, sz=sz}
end
--------------


-- REPRESENTATION --

---Converts hexadecimal notation to RGB notation
---@param h string
---@return table
local function hexToRGB(h)
    return {tonumber(string.sub(h,3,4),16), tonumber(string.sub(h,5,6),16), tonumber(string.sub(h,7,8),16)}
end

---Converts RGB notation to hexadecimal notation
---@param rgb table<integer>
---@return number?
local function RGBToHex(rgb)
    local red = string.format("%x",rgb[1])
    if string.len(red) == 1 then
        red = "0"..red
    end

    local green = string.format("%x",rgb[2])
    if string.len(green) == 1 then
        green = "0"..green
    end

    local blue = string.format("%x",rgb[3])
    if string.len(blue) == 1 then
        blue = "0"..blue
    end
    return tonumber("0x"..red..green..blue)
end

---Maps the color i as a weighted blend of rgb1 and rgb2
---@param rgb1 table
---@param rgb2 table
---@param i integer
---@return table
local function blendRGBs(rgb1, rgb2, i)
    return {math.floor(rgb1[1]*(15-i)/14 + rgb2[1]*(i-1)/14), math.floor(rgb1[2]*(15-i)/14 + rgb2[2]*(i-1)/14), math.floor(rgb1[3]*(15-i)/14 + rgb2[3]*(i-1)/14)}
end

---Sets the pallete of the terminal to be a gradient of two colors
---@param h1 string A hexadecimal string of the form "0x000000"
---@param h2 string Idem
local function colorsGradient(h1,h2)
    local rgb1 = hexToRGB(h1)
    local rgb2 = hexToRGB(h2)
    for i = 1, 15 do
        term.setPaletteColour(2^(i-1),tonumber(RGBToHex(blendRGBs(rgb1,rgb2,i))))
        term.setBackgroundColor(2^(i-1))
    end
    term.setPaletteColour(2^(15),0x000000)
    term.setBackgroundColor(2^(15))
    io.write("\n")
end

---Maps an index i to computercraft's pallete indices
---@param min integer?
---@param max integer?
---@param i integer?
---@return integer
local function mapToColor(min,max,i)
    if i and min and max then
        return 2 ^ math.floor((i-min)/(max-min) * 14 + 0.5)
    end
    return 2^15
end

---Represents a schematic using proyection views and coloring for deepness (Old function btw)
local function represent()
    colorsGradient("0x00ffff","0x000050")
    local X,Y,Z = 1,2,3

    for j = schematic.max[Y], schematic.min[Y], - 1 do
        for i = schematic.min[X], schematic.max[X] do
            local ebreak = false
            for k = schematic.max[Z], schematic.min[Z], -1 do
                if schematic:get{i,j,k} ~= 0 then
                    term.setBackgroundColor(mapToColor(schematic.max[Z], schematic.min[Z], k))
                    io.write("  ")
                    ebreak = true
                    break
                end
            end
            if not ebreak then
                term.setBackgroundColor(mapToColor())
                io.write("  ")
            end
        end
        term.setBackgroundColor(mapToColor())
        io.write("  ")
        for k = schematic.min[Z], schematic.max[Z] do
            local ebreak = false
            for i = schematic.max[X], schematic.min[X], -1 do
                if schematic:get{i,j,k} ~= 0 then
                    term.setBackgroundColor(mapToColor(schematic.max[X], schematic.min[X], i))
                    io.write("  ")
                    ebreak = true
                    break
                end
            end
            if not ebreak then
                term.setBackgroundColor(mapToColor())
                io.write("  ")
            end
        end
        term.setBackgroundColor(mapToColor())
        io.write("\n")
    end
    io.write("\n")
    for k = schematic.min[Z], schematic.max[Z] do
        for i = schematic.min[X], schematic.max[X] do
            local ebreak = false
            for j = schematic.max[Y], schematic.min[Y], -1 do
                if schematic:get{i,j,k} ~= 0 then
                    term.setBackgroundColor(mapToColor(schematic.max[Y], schematic.min[Y], j))
                    io.write("  ")
                    ebreak = true
                    break
                end
            end
            if not ebreak then
                term.setBackgroundColor(mapToColor())
                io.write("  ")
            end
        end
        term.setBackgroundColor(mapToColor())
        io.write("\n")
    end
end
--------------------

local function execute_command(command)
    if command[1] == "cuboid" then
        local b = cuboid(command[2], command[3], command[4], command[5], command[6], command[7], command[8])
        table.insert(pieces, b)
    else
        return
    end
end

compiler_args[1] = compiler_args[1] or 'schematic.txt'
print(compiler_args[1])
local commands = read_schematic(compiler_args[1])

for i = 1, #commands do
    execute_command(commands[i])
end

if compiler_args[2] then
    represent()
end

return schematic