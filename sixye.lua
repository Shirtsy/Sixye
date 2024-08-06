---@diagnostic disable: need-check-nil
local basalt = require("dependencies.basalt")
local get_point_canvas = require("dependencies.hex_render")
local SmolCanvas = require("dependencies.smol_canvas")
local t = require("iota_templating")


local focus = require("dummy_focus")

local function build_right_menu(frame)
    local right_menu = frame:addScrollableFrame()
        :setSize(20, 17)
        :setPosition(31, 2)
        :setForeground(colors.white)
        :addLabel()
            :setPosition(2, 2)
            :setSize(18, 1)
            :setText("Select an Iota")
    return right_menu
end

local function build_hex_list(frame, list)
    local selection = 1
    local offset = 0
    if list then
        selection = list:getItemIndex()
        offset = list:getOffset()
    end

    local hex_list = frame:addList()
    :setSize(24, 17)
    :setPosition(2, 2)
    :onSelect(
        function(self, event, item)
            local hex_index = self:getItemIndex()
            local right_menu = frame:addScrollableFrame()
                :setSize(20, 17)
                :setPosition(31, 2)
            local callback = function() return build_hex_list(frame, self) end
            t.build_iota_menu(right_menu, focus, hex_index, callback)
            --basalt.debug("Selected iota #" .. hex_index)
        end
    )
    for i = 1, #focus do
        local padded_num = string.format("%" .. #tostring(#focus) .. "d", i)
        hex_list:addItem(padded_num .. " " .. t.get_iota_text(focus[i]), colors.grey, t.get_iota_color(focus[i]))
    end

    hex_list:selectItem(selection)
    hex_list:setOffset(offset)
    return hex_list
end

local main = basalt.createFrame()

local right_menu = build_right_menu(main)

local hex_list = build_hex_list(main)

local function draw_splash_screen(animation_duration, delay_duration)
    local function generate_hexagon_points(size)
        local points = {}
        local angle = math.pi / 3  -- 60 degrees in radians
        for i = 0, 5 do
            local x = size * math.cos(i * angle)
            local y = size * math.sin(i * angle)
            -- Rotate by 30 degrees (pi/6 radians) to have flat sides on top and bottom
            local rotatedX = x * math.cos(math.pi/6) - y * math.sin(math.pi/6)
            local rotatedY = x * math.sin(math.pi/6) + y * math.cos(math.pi/6)
            table.insert(points, {x = rotatedX, y = rotatedY})
        end
        return points
    end
    local splash_screen = SmolCanvas.new(51,19)
    splash_screen:set_background_color(colors.black)
    splash_screen:set_foreground_color(colors.gray)
    --splash_screen:draw_pixel(51, 28)
    local coords = generate_hexagon_points(20)
    for i = 1, 10 do
        for _,v in ipairs(coords) do
            local x_size = 13
            local y_size = 8
            local x_pos = v.x-x_size/2 + 51
            local y_pos = v.y-y_size/2 + 27
            local px_size = 3
            local py_size = 5
            local px_pos = v.x-px_size/2 + 51
            local py_pos = v.y-py_size/2 + 27
            splash_screen:draw_ellipse(x_pos, y_pos , x_pos + x_size, y_pos+y_size)
            splash_screen:erase_ellipse(x_pos, y_pos - i, x_pos + x_size, y_pos + y_size - i)
            splash_screen:erase_ellipse(px_pos, py_pos, px_pos + px_size, py_pos + py_size)
        end
        sleep(animation_duration/10)
        splash_screen:render_canvas(1,1)
    end
    sleep(delay_duration)
end

draw_splash_screen(0.2, 0.1)

basalt.autoUpdate()