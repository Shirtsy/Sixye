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

local function first_to_upper(str)
    return (str:gsub("^%l", string.upper))
end

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

local build_iota_menu = (function()
    local function add_label(frame, y_pos, text)
        local label = frame:addLabel()
            :setPosition(2, y_pos)
            :setSize(18, 1)
            :setForeground(colors.white)
            :setText(text)
        return label
    end
    local function add_input(frame, y_pos)
        local input = frame:addInput()
            :setPosition(2, y_pos)
            :setSize(18, 1)
            :setForeground(colors.white)
        return input
    end
    local menu_table = {
        number = function(frame, iota)
            add_label(frame, 2, "Number:")
            add_input(frame, 3)
                :setInputType("number")
                :setDefaultText(tostring(iota))
                :onChange(
                    function(self)
                        basalt.debug(self:getValue())
                    end
                )
        end,
        boolean = function(frame, iota)
            add_label(frame, 2, "Boolean:")
            frame:addDropdown()
                :setPosition(2, 3)
                :setSize(18, 1)
                :setForeground(colors.white)
                :setBackground(colors.black)
                :addItem(first_to_upper(tostring(iota)), colors.black, colors.white)
                :addItem(first_to_upper(tostring(not iota)), colors.black, colors.white)
                :onChange(
                    function(self, event, item)
                        basalt.debug(item.text)
                    end
                )
        end,
        string = function(frame, iota)
            add_label(frame, 2, "String:")
            add_input(frame, 3)
                :setInputType("text")
                :setDefaultText(tostring(iota))
                :onChange(
                    function(self)
                        basalt.debug(self:getValue())
                    end
                )
        end,
        null = function(frame, iota)
            add_label(frame, 2, "Null")
        end,
        garbage = function(frame, iota)
            add_label(frame, 2, "Garbage")
        end,
        vector = function(frame, iota)
            add_label(frame, 2, "Vector")
            add_label(frame, 4, "X:")
            add_input(frame, 5)
                :setInputType("number")
                :setDefaultText(tostring(iota.x))
                :onChange(
                    function(self)
                        basalt.debug(self:getValue())
                    end
                )
            add_label(frame, 7, "Y:")
            add_input(frame, 8)
                :setInputType("number")
                :setDefaultText(tostring(iota.y))
                :onChange(
                    function(self)
                        basalt.debug(self:getValue())
                    end
                )
            add_label(frame, 10, "Z:")
            add_input(frame, 11)
                :setInputType("number")
                :setDefaultText(tostring(iota.z))
                :onChange(
                    function(self)
                        basalt.debug(self:getValue())
                    end
                )
        end,
        entity = function(frame, iota)
            add_label(frame, 2, "Entity")
            add_label(frame, 4, "UUID:")
            add_input(frame, 5)
                :setInputType("text")
                :setDefaultText(tostring(iota.uuid))
                :onChange(
                    function(self)
                        basalt.debug(self:getValue())
                    end
                )
            add_label(frame, 7, "Name:")
            add_input(frame, 8)
                :setInputType("text")
                :setDefaultText(tostring(iota.name))
                :onChange(
                    function(self)
                        basalt.debug(self:getValue())
                    end
                )
        end,
        pattern = function(frame, iota)
            local start_directions = {
                "EAST",
                "NORTH_EAST",
                "NORTH_WEST",
                "WEST",
                "SOUTH_WEST",
                "SOUTH_EAST"
            }
            add_label(frame, 2, "Pattern")
            add_label(frame, 4, "Angles:")
            add_input(frame, 5)
                :setInputType("text")
                :setDefaultText(tostring(iota.angles))
                :onChange(
                    function(self)
                        basalt.debug(self:getValue())
                    end
                )
            add_label(frame, 7, "Direction:")
            local dropdown = frame:addDropdown()
                :setPosition(2, 8)
                :setSize(18, 1)
                :setForeground(colors.white)
                :setBackground(colors.black)
                :addItem(iota.startDir, colors.black, colors.white)
                :onChange(
                    function(self, event, item)
                        basalt.debug(item.text)
                    end
                )
                for _, v in pairs(start_directions) do
                    if v ~= iota.startDir then
                        dropdown:addItem(v, colors.black, colors.white)
                    end
                end
        end,
        iota_type = function(frame, iota)
            add_label(frame, 2, "Iota Type")
            add_label(frame, 4, "Type:")
            add_input(frame, 5)
                :setInputType("text")
                :setDefaultText(tostring(iota.iotaType))
                :onChange(
                    function(self)
                        basalt.debug(self:getValue())
                    end
                )
        end,
        entity_type = function(frame, iota)
            add_label(frame, 2, "Entity Type")
            add_label(frame, 4, "Type:")
            add_input(frame, 5)
                :setInputType("text")
                :setDefaultText(tostring(iota.entityType))
                :onChange(
                    function(self)
                        basalt.debug(self:getValue())
                    end
                )
        end,
        gate = function(frame, iota)
            add_label(frame, 2, "Gate")
            add_label(frame, 4, "Gate UUID:")
            add_input(frame, 5)
                :setInputType("text")
                :setDefaultText(tostring(iota.gate))
                :onChange(
                    function(self)
                        basalt.debug(self:getValue())
                    end
                )
        end,
        mote = function(frame, iota)
            add_label(frame, 2, "Mote")
            add_label(frame, 4, "Mote UUID:")
            add_input(frame, 5)
                :setInputType("text")
                :setDefaultText(tostring(iota.moteUuid))
                :onChange(
                    function(self)
                        basalt.debug(self:getValue())
                    end
                )
            add_label(frame, 7, "Item ID:")
            add_input(frame, 8)
                :setInputType("text")
                :setDefaultText(tostring(iota.itemID))
                :onChange(
                    function(self)
                        basalt.debug(self:getValue())
                    end
                )
            add_label(frame, 10, "Nexus UUID:")
            add_input(frame, 11)
                :setInputType("text")
                :setDefaultText(tostring(iota.nexusUuid))
                :onChange(
                    function(self)
                        basalt.debug(self:getValue())
                    end
                )
        end,
        item_type = function(frame, iota)

        end,
        list = function(frame, iota)

        end,
    }
    return function(frame, iota)
        local iota_type = get_iota_type(iota)
        menu_table[iota_type](frame, iota)
    end
end)()

local main = basalt.createFrame()
if not main then
    error("Main is nil")
end

local build_right_menu = function()
    main:addScrollableFrame()
        :setSize(20, 17)
        :setPosition(31, 2)
        :setForeground(colors.white)
        :addLabel()
            :setPosition(2, 2)
            :setSize(18, 1)
            :setText("Select an Iota")
end
local right_menu = build_right_menu()

local hex_list = main:addList()
    :setSize(24, 17)
    :setPosition(2, 2)
    :onSelect(
        function(self, event, item)
            local hex_index = self:getItemIndex()
            right_menu = main:addScrollableFrame()
                :setSize(20, 17)
                :setPosition(31, 2)
                build_iota_menu(right_menu, focus[hex_index])
            basalt.debug("The value got changed to " .. hex_index)
        end
    )
for i = 1, #focus do
    local padded_num = string.format("%" .. #tostring(#focus) .. "d", i)
    hex_list:addItem(padded_num .. " " .. get_iota_text(focus[i]), colors.grey, get_iota_color(focus[i]))
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

--draw_splash_screen(0.2, 0.1)

basalt.autoUpdate()