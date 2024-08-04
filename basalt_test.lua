local basalt = require("../basalt")
local get_point_canvas = require("dependencies.hex_render")
local hexLookup = require("dependencies.hex_lookup")

local function get_running_path()
    local runningProgram = shell.getRunningProgram()
    local programName = fs.getName(runningProgram)
    return runningProgram:sub( 1, #runningProgram - #programName )
end

local lookup = hexLookup.new(get_running_path() .. "dependencies/symbol-registry.json")
local focus = require("dummy_focus")

local function get_iota_type(iota)
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
    local lua_type = type(iota)
    for k, v in pairs(iota_types) do
        if v == lua_type then
            return k
        elseif type(iota) == "table" and iota[v] then
            return k
        end
    end
end

local function get_iota_text(iota)
    local function first_to_upper(str)
        return (str:gsub("^%l", string.upper))
    end
    local format_table = {
        number = function() return tostring(iota) end,
        boolean = function() return first_to_upper(tostring(iota)) end,
        string = function() return '"'..iota..'"' end,
        null = function() return "Null" end,
        garbage = function() return "Garbage" end,
        vector = function() return "("..iota.x..","..iota.y..","..iota.z..")" end,
        entity = function() return "Entity" end,
        pattern = function() return iota.angles.." | "..iota.startDir end,
        iota_type = function() return "Iota Type:"..iota.iotaType end,
        entity_type = function() return "Entity Type:"..iota.entityType end,
        gate = function() return "Gate" end,
        mote = function() return "Mote" end,
        item_type = function() return "Item Type:"..iota.itemType end,
        list = function() return "List" end,
    }
    local iota_type = get_iota_type(iota)
    if iota_type == "pattern" and #lookup:get_pattern_name(iota.angles) > 0 then
        return lookup:get_pattern_name(iota.angles)
    else
        return format_table[iota_type]()
    end
end

local function get_iota_color(iota)
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
    return iota_colors[get_iota_type(iota)]
end

local main = basalt.createFrame()

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

basalt.autoUpdate()
