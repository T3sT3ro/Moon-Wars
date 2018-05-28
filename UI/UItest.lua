local UI = require "UI/UI"

local white = UI.Color(255, 255, 255)
local red = UI.Color(200, 0, 0, 15)
local ocean = UI.Color("#20a59fff")

local GUI =
    UI(
    {0, 0, 800, 600},
    {
        margin = {left = 15, up = 3, right = 15, down = 3},
        origin = {x = 100, y = 20},
        size = {x = 200, y = 200},
        color = UI.Color("#FFAABBCC")
    },
    {
        keepFocus = true,
        clickThru = true,
        allowOverflow = true,
        draggable = true
    },
    {
        x = 250,
        y = 12,
        color1 = UI.Color("#FFAABBCC"),
        color2 = UI.Color("#FFAABB")
    }
)

GUI.updater = function(self, ...)
    local t = {...}
    self.data.x = self.data.x + t[1]
    self.data.y = self.data.y + t[2]
end

GUI.renderer = function(self, ...)
    print(self.data.x, self.data.y)
end

GUI:update(1, 1)
GUI:draw()
GUI:update(200, 200)
GUI:draw()

print "----------COLORS----------"
local r2 = UI.Color(red)
print(red, r2, r2:toHex())
print(UI.Color(1, 2, 3, 4):toHex())
print(UI.Color("#abcdef"):toRGBA())

print "----------FRAMES----------"
local w_width = 1200
local w_height = 800
local GUIBox = {15, 15, w_width - 30, w_height - 30}
local f1 = UI(GUIBox, {size = {x = 500, y = 500}, margin = {x = 60, y = 20}}, nil, nil)
local f2 = UI(f1, {origin = {x = 50, y = 50}, size = {x = 200, y = 850}, margin = 15}, nil, nil)
local f3 = UI(f2, {origin = {x = -50, y = 100}, size = {x = 100, y = 60}, margin = 3}, {allowOverflow = true})
local f4 = UI(f3, {origin = {x = 25, y = 25}, size = {x = 80, y = 80}})

GUIBox = f1.toplevel

local function drawAABB(AABB, c)
    print(AABB:getValues())
end

local function drawCursor(cursor, text)
    print(text or "Cursor: ", cursor.x, cursor.y)
end

drawAABB(f1:getAvailAABB(), avail)
drawAABB(f1:getAABB(), inside)
drawAABB(f2:getAvailAABB(), avail)
drawAABB(f2:getAABB(), inside)
drawAABB(f3:getAvailAABB(), avail)
drawAABB(f3:getAABB(), inside)
drawAABB(f4:getAvailAABB(), avail)
drawAABB(f4:getAABB(), inside)

f1:setCursor(0, 0)      drawCursor(f1:getRawCursor(), "F1_cursor")
f1:setRawCursor((f1:getAvailAABB())[1])     drawCursor(f1:getRawCursor(), "F1_avail_cursor")
f2:setCursor(0, 0)      drawCursor(f2:getRawCursor(), "F2_cursor")
f2:setRawCursor((f2:getAvailAABB())[1])     drawCursor(f2:getRawCursor(), "F2_avail_cursor")
f3:setCursor(0, 0)      drawCursor(f3:getRawCursor(), "F3_cursor")
f3:setRawCursor((f3:getAvailAABB())[1])     drawCursor(f3:getRawCursor(), "F3_avail_cursor")
f4:setCursor(0, 0)      drawCursor(f4:getRawCursor(), "F4_cursor")
f4:setRawCursor((f4:getAvailAABB())[1])     drawCursor(f4:getRawCursor(), "F4_avail_cursor")
