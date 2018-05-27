local UI = require "UI/UI"

local white = UI.Color(255, 255, 255)
local red = UI.Color(200, 0, 0, 15)
local ocean = UI.Color("#20a59fff")

local GUI =
    UI(
    {origin = {x = 0, y = 0}, size = {x = 800, y = 600}},
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

print '----------COLORS----------'
local r2 = UI.Color(red)
print(red, r2, r2:toHex())
print(UI.Color(1, 2, 3, 4):toHex())
print(UI.Color("#abcdef"):toRGBA())


print '----------FRAMES----------'
f1 =
    UI(
    {origin = {x = 0, y = 0}, size = {x = 800, y = 600}},
    {size = {x = 500, y = 500}, margin = {x = 60, y = 20}},
    nil,
    nil
)

f2 = UI(f1, {size = {x = 200, y = 150}, margin = 15}, nil, nil)
f3 = UI(f2, {size = {x = 60, y = 30}, margin = 3}, nil, nil)

local function drawAABB(AABB, c)
    print(AABB:getValues())
end

drawAABB(f1:getAvailAABB(), avail)
drawAABB(f1:getAABB(), inside)
drawAABB(f2:getAvailAABB(), avail)
drawAABB(f2:getAABB(), inside)
drawAABB(f3:getAvailAABB(), avail)
drawAABB(f3:getAABB(), inside)

drawAABB(f1:getAvailAABB(), avail)
drawAABB(f1:getAABB(), inside)
drawAABB(f2:getAvailAABB(), avail)
drawAABB(f2:getAABB(), inside)
drawAABB(f3:getAvailAABB(), avail)
drawAABB(f3:getAABB(), inside)