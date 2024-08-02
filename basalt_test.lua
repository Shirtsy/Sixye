local basalt = require("dependencies.basalt")
local get_point_canvas = require("dependencies.hex_render")
local hexLookup = require("dependencies.hex_lookup")

local function get_iota_type(iota)
    local lua_type = type(iota)
    if lua_type == "number" or lua_type == "boolean" or lua_type == "string"  then
        return lua_type
    elseif iota.null then
        return "null"
    elseif iota.garbage then
        return "garbage"
    elseif iota.x then
        return "vector"
    elseif iota.uuid then
        return "entity"
    elseif iota.startDir then
        return "pattern"
    elseif iota.iotaType then
        return "iota_type"
    elseif iota.entityType then
        return "entity_type"
    elseif iota.gate then
        return "gate"
    elseif iota.moteUuid then
        return "mote"
    elseif iota.itemType then
        return "item_type"
    else
        return "list"
    end
end

local function get_running_path()
    local runningProgram = shell.getRunningProgram()
    local programName = fs.getName(runningProgram)
    return runningProgram:sub( 1, #runningProgram - #programName )
end

local lookup = hexLookup.new(get_running_path() .. "dependencies/symbol-registry.json")
local focus = require("dummy_focus")

local main = basalt.createFrame():setTheme({FrameBG = colors.purple, FrameFG = colors.black})
local hex_list = main:addList():setSize(24, 17):setPosition(2, 2)
for i = 1, #focus do
    local iota_name = get_iota_type(focus[i])
    if get_iota_type(focus[i]) == "pattern" then
        iota_name = lookup:get_pattern_name(focus[i].angles)
    end
    hex_list:addItem(tostring(i) .. " " .. iota_name, colors.black, colors.white)
end

hex_list:onSelect(
    function(self, event, item)
        --basalt.debug("Selected item: ", self:getItemIndex())

        local right_menu = main:addScrollableFrame():setSize(20, 17):setPosition(27, 2)

        local aLabel = right_menu:addLabel():setPosition(2, 2):setSize(18, 1)
        aLabel:setText("X: ")

        local anInput = right_menu:addInput():setPosition(2, 3):setSize(18, 1)
        anInput:setInputType("text")
        local function inputChange(self)
            local checked = self:getValue()
            basalt.debug("The value got changed into ", checked)
        end
        anInput:onChange(inputChange)
    end
)


basalt.autoUpdate()
