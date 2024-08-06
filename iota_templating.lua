local hexLookup = require("dependencies.hex_lookup")
local basalt = require("dependencies.basalt")
local get_point_canvas = require("dependencies.hex_render")

local function get_running_path()
    local runningProgram = shell.getRunningProgram()
    local programName = fs.getName(runningProgram)
    return runningProgram:sub( 1, #runningProgram - #programName )
end

local lookup = hexLookup.new(get_running_path() .. "dependencies/symbol-registry.json")

local function first_to_upper(str)
    return (str:gsub("^%l", string.upper))
end

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
local function get_iota_type(iota)
    local lua_type = type(iota)
    for k, v in pairs(iota_types) do
        if v == lua_type then
            return k
        elseif type(iota) == "table" and iota[v] then
            return k
        end
    end
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
local function get_iota_text(iota)
        local iota_type = get_iota_type(iota)
        if iota_type == "pattern" and #lookup:get_pattern_name(iota.angles) > 0 then
            return lookup:get_pattern_name(iota.angles)
        else
            return format_table[iota_type](iota)
        end
end

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
    item_type = colors.yellow,
    list = colors.orange,
}
local function get_iota_color(iota) 
    return iota_colors[get_iota_type(iota)]
end

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
    number = function(frame, focus, index, callback)
        local iota = focus[index]
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
    boolean = function(frame, focus, index, callback)
        local iota = focus[index]
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
                    if item.text == "True" then
                        focus[index] = true
                    else
                        focus[index] = false
                    end
                    callback()
                end
            )
    end,
    string = function(frame, focus, index, callback)
        local iota = focus[index]
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
    null = function(frame, focus, index, callback)
        local iota = focus[index]
        add_label(frame, 2, "Null")
    end,
    garbage = function(frame, focus, index, callback)
        local iota = focus[index]
        add_label(frame, 2, "Garbage")
    end,
    vector = function(frame, focus, index, callback)
        local iota = focus[index]
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
    entity = function(frame, focus, index, callback)
        local iota = focus[index]
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
    pattern = function(frame, focus, index, callback)
        local iota = focus[index]
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
    iota_type = function(frame, focus, index, callback)
        local iota = focus[index]
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
    entity_type = function(frame, focus, index, callback)
        local iota = focus[index]
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
    gate = function(frame, focus, index, callback)
        local iota = focus[index]
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
    mote = function(frame, focus, index, callback)
        local iota = focus[index]
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
    item_type = function(frame, focus, index, callback)
        local iota = focus[index]
        add_label(frame, 2, "Item Type")
        add_label(frame, 4, "Item:")
        add_input(frame, 5)
            :setInputType("text")
            :setDefaultText(tostring(iota.itemType))
            :onChange(
                function(self)
                    basalt.debug(self:getValue())
                end
            )
        add_label(frame, 7, "Is item?")
        frame:addDropdown()
            :setPosition(2, 8)
            :setSize(18, 1)
            :setForeground(colors.white)
            :setBackground(colors.black)
            :addItem(first_to_upper(tostring(iota.isItem)), colors.black, colors.white)
            :addItem(first_to_upper(tostring(not iota.isItem)), colors.black, colors.white)
            :onChange(
                function(self, event, item)
                    basalt.debug(item.text)
                end
            )
    end,
    list = function(frame, focus, index, callback)

    end,
}
local function build_iota_menu(frame, focus, index, callback_func)
        local iota_type = get_iota_type(focus[index])
        menu_table[iota_type](frame, focus, index, callback_func)
end

return {
    get_iota_type = get_iota_type,
    get_iota_text = get_iota_text,
    get_iota_color = get_iota_color,
    build_iota_menu = build_iota_menu
}