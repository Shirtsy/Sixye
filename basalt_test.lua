local basalt = require("../basalt")

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

local aDropdown = sub1:addDropdown():setPosition(2, 22):setSize(18, 1)
aDropdown:addItem("Null")
aDropdown:addItem("Vector", colors.yellow)
aDropdown:addItem("Number", colors.yellow, colors.green)
local function dropChange(self)
    local checked = self:getValue().text
    basalt.debug("The value got changed into ", checked)
end
aDropdown:onChange(dropChange)

local anInput = sub1:addInput():setPosition(2, 20):setSize(18, 1)
anInput:setInputType("text")
anInput:setDefaultText("Username")
local function inputChange(self)
    local checked = self:getValue()
    basalt.debug("The value got changed into ", checked)
end
anInput:onChange(inputChange)
  

basalt.autoUpdate()
