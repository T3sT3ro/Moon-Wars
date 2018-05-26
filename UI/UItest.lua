local UI = require "UI/UI"

local white = UI.Color(255, 255, 255)
local red = UI.Color(200, 0, 0, 15)
local ocean = UI.Color("#20a59fff")

local GUI =
    UI({origin={x=0,x=0},size={x=800, x=600}},
    {
        keepFocus = true,
        clickThru = true,
        allowOverflow = true,
        draggable = true
    },
    {
        margin = {left = 15, top = 3, right = 15, bottom = 3},
        origin = {x = 100, y = 20},
        size = {x = 200, y = 200},
        color = UI.Color("#FFAABBCC")
    },
    {
        x = 250,
        y = 12,
        color1 = UI.Color("#FFAABBCC"),
        color2 = UI.Color("#FFAABB")
    }
)

local Frame = UI(nil, {margin = {left=20,right=20,u=50,down=50}, size={x=200, y = 50} },{marginColor=UI.Color("#15a999"), innerColor})

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

local r2 = UI.Color(red)
print(red, r2, r2:toHex())
print(UI.Color(1, 2, 3, 4):toHex())
print(UI.Color("#abcdef"):toRGBA())
