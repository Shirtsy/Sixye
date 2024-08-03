local Vector2D = {}
Vector2D.__index = Vector2D

function Vector2D.new(x, y)
    local vec = {}
    setmetatable(vec, Vector2D.metatable)
    vec.x = x
    vec.y = y
    return vec
end

function Vector2D.add(vec1, vec2)
    local x = vec1.x + vec2.x
    local y = vec1.y + vec2.y
    return Vector2D.new(x, y)
end

function Vector2D.sub(vec1, vec2)
    local x = vec1.x - vec2.x
    local y = vec1.y - vec2.y
    return Vector2D.new(x, y)
end

function Vector2D.mul(vec, value)
    local x = vec.x * value
    local y = vec.y * value
    return Vector2D.new(x, y)
end

function Vector2D.div(vec, value)
    local x = vec.x / value
    local y = vec.y / value
    return Vector2D.new(x, y)
end

Vector2D.metatable = {
    __add = Vector2D.add,
    __sub = Vector2D.sub,
    __mul = Vector2D.mul,
    __div = Vector2D.div,
}

return Vector2D