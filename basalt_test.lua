local basalt = require("../basalt")
local draw_pattern, create_pattern_string = require("hex_utils.hex_render")

local main = basalt.createFrame():setTheme({FrameBG = colors.purple, FrameFG = colors.black})

local aList = main:addList():setSize(20, 17):setPosition(23, 2)
aList:addItem("Item 1")
aList:addItem("{")
aList:addItem(" Item 3")
aList:addItem("}")
aList:addItem("Item 3")
aList:addItem("Item 3")
aList:addItem("Item 3")
aList:addItem("Item 3")
aList:addItem("Item 3")
aList:addItem("Item 3")
aList:addItem("Item 3")
aList:addItem("Item 3")
aList:addItem("Item 3")
aList:addItem("Item 3")
aList:addItem("Item 3")
aList:addItem("Item 3")
aList:addItem("Item 3")
aList:addItem("Item 3")
aList:addItem("Item 3")
aList:addItem("Item 3")
aList:addItem("Item 3")
aList:addItem("Item 3")
aList:addItem("Item 3")
aList:addItem("Item 3")
aList:addItem("Item 3")
aList:addItem("Item 3")
aList:addItem("Item 3")

aList:onSelect(function(self, event, item)
    basalt.debug("Selected item: ", item.text)
  end)

-- Vertical scrolling is pretty simple, as you can tell:
local sub1 = main:addScrollableFrame():setSize(20, 17):setPosition(2, 2)

-- Create a dropdown menu
local aDropdown = sub1:addDropdown():setPosition(2, 22):setSize(18, 1)

-- Add items to the dropdown menu
aDropdown:addItem("Null")
aDropdown:addItem("Vector", colors.yellow)
aDropdown:addItem("Number", colors.yellow, colors.green)

-- Function to handle dropdown value changes
local function dropChange(self)
    draw_pattern('NORTH_EAST', 'qeqwqwqwqwqeqaeqeaqeqaeqaqded', 20, 1, 20, colors.yellow)
    local checked = self:getValue().text
    basalt.debug("The value got changed into ", checked)
end

-- Attach the change handler to the dropdown
aDropdown:onChange(dropChange)

local anInput = sub1:addInput():setPosition(2, 20):setSize(18, 1)
anInput:setInputType("number")
anInput:setDefaultText("Username")
local function inputChange(self)
    local checked = self:getValue()
    basalt.debug("The value got changed into ", checked)
end
anInput:onChange(inputChange)
  

basalt.autoUpdate()
