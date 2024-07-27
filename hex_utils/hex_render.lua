local Vector2D = require("vector2d")

local pattern_angles = {
    a = 120,
    q = 60,
    w = 0,
    e = -60,
    d = -120,
    s = 180,
    EAST = 0,
    NORTH_EAST = 60,
    NORTH_WEST = 120,
    WEST = 180,
    SOUTH_WEST = 240,
    SOUTH_EAST = 300
}

local function get_endpoint(vec2d, angle, length)
    local angleRad = angle * math.pi / 180
    local newX = vec2d.x + length * (7 / math.sqrt(5^2 + 7^2)) * math.cos(angleRad)
    local newY = vec2d.y - length * (5 / math.sqrt(5^2 + 7^2)) * math.sin(angleRad)
    return Vector2D.new(newX, newY)
end

local function drawVecs(vec2d_1, vec2d_2, color)
    paintutils.drawLine(vec2d_1.x, vec2d_1.y, vec2d_2.x, vec2d_2.y, color)
end

local function get_points(direction, pattern)
    local points = {}
    table.insert(points, Vector2D.new(0,0))
    local length = 1
    local angle = pattern_angles[direction]
    local new_point = get_endpoint(Vector2D.new(0,0), angle, length)
    table.insert(points, new_point)
    for i = 1, #pattern do
        local c = pattern:sub(i,i)
        angle = angle + pattern_angles[c]
        new_point = get_endpoint(new_point, angle, length)
        table.insert(points, new_point)
    end
    return points
end

-- Function to calculate the current bounding box of the pattern
local function calculate_bounding_box(points)
    local min_x, max_x, min_y, max_y = points[1].x, points[1].x, points[1].y, points[1].y
    for _, vec in ipairs(points) do
        if vec.x < min_x then min_x = vec.x end
        if vec.x > max_x then max_x = vec.x end
        if vec.y < min_y then min_y = vec.y end
        if vec.y > max_y then max_y = vec.y end
    end
    return min_x, max_x, min_y, max_y
end

local function scale_points(points, target_size)
    local min_x, max_x, min_y, max_y = calculate_bounding_box(points)
    local current_width = max_x - min_x
    local current_height = max_y - min_y
    local scale_factor = (target_size - 1) / math.max(current_width, current_height)
    
    local scaled_points = {}
    for _, vec in ipairs(points) do
        local scaled_point = Vector2D.new(
            (vec.x - min_x) * scale_factor,
            (vec.y - min_y) * scale_factor
        )
        table.insert(scaled_points, scaled_point)
    end
    
    return scaled_points
end

local function render_points(x, y, points, size)
    local points = scale_points(points, size)
    for _, vec in ipairs(points) do
        vec.x = vec.x + x
        vec.y = vec.y + y
    end
    for i = 1, (#points - 1) do
        drawVecs(points[i], points[i+1], colors.yellow)
    end
end

local function draw_pattern(direction, pattern, x, y, size, color)
    local points = get_points(direction, pattern)
    render_points(x, y, points, size)
end

return draw_pattern