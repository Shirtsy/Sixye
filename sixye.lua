local basalt = require("dependencies.basalt")
local get_point_canvas = require("dependencies.hex_render")
local hexLookup = require("dependencies.hex_lookup")
local SmolCanvas = require("dependencies.smol_canvas")

local function get_running_path()
    local runningProgram = shell.getRunningProgram()
    local programName = fs.getName(runningProgram)
    return runningProgram:sub( 1, #runningProgram - #programName )
end

local lookup = hexLookup.new(get_running_path() .. "dependencies/symbol-registry.json")
local focus = require("dummy_focus")

local get_iota_type = (function()
    local iota_types = {
        number = "number",
        boolean = "boolean",
        string = "string",
        null = "null",
        garbage = "garbage",
        vector = "x",
        entity = "uuid",
        pattern = "startDir",
        iota_type = "iotaType",
        entity_type = "entityType",
        gate = "gate",
        mote = "moteUuid",
        item_type = "item_type",
        list = 1,
    }
    return function(iota)
        local lua_type = type(iota)
        for k, v in pairs(iota_types) do
            if v == lua_type then
                return k
            elseif type(iota) == "table" and iota[v] then
                return k
            end
        end
    end
end)()

local get_iota_text = (function()
    local function first_to_upper(str)
        return (str:gsub("^%l", string.upper))
    end
    local format_table = {
        number = function(iota) return tostring(iota) end,
        boolean = function(iota) return first_to_upper(tostring(iota)) end,
        string = function(iota) return '"'..iota..'"' end,
        null = function(iota) return "Null" end,
        garbage = function(iota) return "Garbage" end,
        vector = function(iota) return "("..iota.x..","..iota.y..","..iota.z..")" end,
        entity = function(iota) return "Entity" end,
        pattern = function(iota) return iota.angles.." | "..iota.startDir end,
        iota_type = function(iota) return "Iota Type:"..iota.iotaType end,
        entity_type = function(iota) return "Entity Type:"..iota.entityType end,
        gate = function(iota) return "Gate" end,
        mote = function(iota) return "Mote" end,
        item_type = function(iota) return "Item Type:"..iota.itemType end,
        list = function(iota) return "List" end,
    }
    return function(iota)
        local iota_type = get_iota_type(iota)
        if iota_type == "pattern" and #lookup:get_pattern_name(iota.angles) > 0 then
            return lookup:get_pattern_name(iota.angles)
        else
            return format_table[iota_type](iota)
        end
    end
end)()

local get_iota_color = (function()
    local iota_colors = {
        number = colors.yellow,
        boolean = colors.green,
        string = colors.red,
        null = colors.white,
        garbage = colors.white,
        vector = colors.yellow,
        entity = colors.white,
        pattern = colors.lightBlue,
        iota_type = colors.white,
        entity_type = colors.white,
        gate = colors.white,
        mote = colors.white,
        item_type = colors.white,
        list = colors.orange,
    }
    return function(iota) 
        return iota_colors[get_iota_type(iota)]
    end
end)()

local main = basalt.createFrame()
if not main then
    error("Main is nil")
end

local function create_iota_menu(self, iota)
    local right_menu = main:addScrollableFrame():setSize(20, 17):setPosition(27, 2)

    

    --local function inputChange(self)
    --    local checked = self:getValue()
    --    basalt.debug("The value got changed into ", checked)
    --end

    --local anInput = right_menu:addInput():setPosition(2, 3):setSize(18, 1)
    --anInput:setInputType("text")
    --anInput:setDefaultText("Username")
    --anInput:onChange(inputChange)
end

local right_menu = main:addScrollableFrame()
    :setSize(20, 17)
    :setPosition(27, 2)

    local aLabel = right_menu:addLabel()
        :setPosition(2, 2)
        :setSize(18, 1)
        :setText("Select an Iota")

local hex_list = main:addList()
    :setSize(24, 17)
    :setPosition(2, 2)
    :onSelect(
        function(self, event, item)
            local hex_index = self:getItemIndex()
            right_menu = main:addScrollableFrame()
                :setSize(20, 17)
                :setPosition(27, 2)
                aLabel = right_menu:addLabel()
                    :setPosition(2, 2)
                    :setSize(18, 1)
                    :setText("X: ")
            basalt.debug("The value got changed to " .. hex_index)
        end
    )
for i = 1, #focus do
    hex_list:addItem(tostring(i) .. " " .. get_iota_text(focus[i]), colors.grey, get_iota_color(focus[i]))
end

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