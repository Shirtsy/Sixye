local Vector2D = require("dependencies.vector2d")
local math = require("math")
local SmolCanvas = require("dependencies.smol_canvas")

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

local function parse_pattern(pattern, start_angle)
    local angles = {}
    for i = 1, #pattern do
        local char = pattern:sub(i, i):lower()
        table.insert(angles, pattern_angles[char])
    end

    -- Concatenate the pattern angles to the start angle
    table.insert(angles, 1, pattern_angles[start_angle])

    return angles
end

local function plot_angles(angles)
    local points = {Vector2D.new(0, 0)}  -- Start at (0, 0)
    local current_point = Vector2D.new(0, 0)
    local current_angle = 0

    for _, angle in ipairs(angles) do
        -- Accumulate the angle
        current_angle = (current_angle + angle) % 360
        
        -- Convert angle to radians
        local rad_angle = math.rad(current_angle)
        
        -- Calculate the next point
        local dx = math.cos(rad_angle)
        local dy = math.sin(rad_angle)
        local vector = Vector2D.new(dx, dy)
        
        -- Add the new vector to the current point
        current_point = Vector2D.add(current_point, vector)
        
        -- Add the new point to our list
        table.insert(points, Vector2D.new(current_point.x, current_point.y))
    end

    return points
end


local function get_point_canvas(pattern, start_angle, width, height)
    local points = plot_angles(parse_pattern(pattern, start_angle))
    local all_x = {}
    local all_y = {}
    for _,vec in pairs(points) do
        table.insert(all_x, vec.x)
        table.insert(all_y, vec.y)
    end
    local min_x = math.min(table.unpack(all_x))
    local max_x = math.max(table.unpack(all_x))
    local min_y = math.min(table.unpack(all_y))
    local max_y = math.max(table.unpack(all_y))

    local pattern_midpoint = Vector2D.new((max_x + min_x)/2, (min_y + max_y)/2)
    local canvas = SmolCanvas.new(width, height)
    local scale_factor = 0.8 * math.min(canvas.pixel_width, canvas.pixel_height) / math.max(max_x - min_x, max_y - min_y)

    for i,vec in pairs(points) do
        vec.x = math.floor((vec.x - pattern_midpoint.x) * scale_factor + canvas.pixel_width/2)
        vec.y = math.floor((vec.y - pattern_midpoint.y) * scale_factor * -1 + canvas.pixel_height/2)
    end
    for i = 1, #points - 1 do
        canvas:draw_line(points[i].x, points[i].y, points[i+1].x, points[i+1].y)
    end

    return canvas
end

return get_point_canvas