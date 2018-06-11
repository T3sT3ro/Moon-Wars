-- embedded global pseudo-love module

require "debug/loveDebug"
ResourceManager = require "ResourceManager"
local UI = require "UI/UI"
local UIWidget = require "UI/UIWidget"
local Color = require "UI/Color"
local AABB = require "UI/AABB"

local min, max = math.min, math.max

local white = Color(255, 255, 255)
local red = Color(200, 0, 0, 15)
local ocean = Color("#20a59fff")

print "----------COLORS----------"
local r2 = Color(red)
print(red, r2, r2:toHex())
print(Color(30, 30, 30, 120):toHex())
print(Color(0, 0, 0, 0):toHex())
print(Color(0, 0, 0, 0):toRGBA())
print(Color(0, 0, 0, 0):normalized())
print(Color(255, 255, 255, 255):toHex())
print(Color(255, 255, 255, 255):toRGBA())
print(Color(255, 255, 255, 255):normalized())
print(Color("#abcdef"):toRGBA())

print "------UI DEBUG STATE------"

local _UDB = require "debug/UIDebugState"
local UDB =
    setmetatable(
    {},
    {
        __index = function(t, k)
            print("-----------------------------")
            print("UIDebugState: " .. k)
            return _UDB[k]
        end
    }
)

UDB.init()
UDB.update(5)
UDB.draw()
love.mouse.x, love.mouse.y = 488, 318
love.keyboard["left"] = true

UDB.update(5)
UDB.draw()
UDB.update(5)
UDB.draw()

UDB.update()
UDB.draw()
UDB.update()
UDB.draw()
UDB.update()
UDB.draw()
UDB.update()
UDB.draw()
