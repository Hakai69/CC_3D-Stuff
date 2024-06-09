---Creates a shallow copy of an array
---@param t table
---@return table
function table.icopy(t)
    local new = {}
    for k, v in ipairs(t) do
        new[k] = v
    end
    return new
end

---Creates a shallow copy of a table
---@param t table
---@return table
function table.copy(t)
    local new = {}
    for k, v in pairs(t) do
        new[k] = v
    end
    return new
end

---Creates a deepcopy of a table
---@param t table
---@return table
function table.deepcopy(t)
    local new = {}
    for k, v in pairs(t) do
        if type(k) == 'table' then
            k = table.deepcopy(k)
        end
        if type(v) == 'table' then
            v = table.deepcopy(v)
        end
        new[k] = v
    end
    return new
end

---Shuffles a table in place
---@param t table
---@return table
function table.shuffle(t)
    for i=1, #t do
        local new = math.random(i, #t)
        t[i], t[new] = t[new], t[i]
    end
    return t
end