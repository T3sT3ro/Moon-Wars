local MainMenuState = {name = "MainMenuState"}
local UI = require "UI/UI"
local Color = UI.Color
local AABB = UI.AABB

local GUI
local AABB1 = AABB(10, 30, 500, 100)
local AABB2 = AABB(100, 10, 150, 400)

local frame1 = UI(nil, {size={x=600,y=400}, margin={}})
local margin = Color(190,20,20,60)
local inside = Color(20,190,20,60)


function MainMenuState.init()
    GUI = UI()
end

function MainMenuState.clear()
    GUI:dropFocus()
end

function MainMenuState.update(dt)
    GUI:update()
end

function MainMenuState.draw()
    love.graphics.setColor(white:normalized())
    love.graphics.rectangle("line", AABB1[1].x, AABB1[1].y, AABB1[2].x - AABB1[1].x, AABB1[2].y - AABB1[1].y)

    love.graphics.setColor(ocean:normalized())
    love.graphics.rectangle("line", AABB2[1].x, AABB2[1].y, AABB2[2].x - AABB2[1].x, AABB2[2].y - AABB2[1].y)

    local cut = AABB1:cut(AABB2)

    love.graphics.setColor(red:normalized())
    love.graphics.rectangle("fill", cut[1].x, cut[1].y, cut[2].x - cut[1].x, cut[2].y - cut[1].y)
    love.graphics.setColor(20, 20, 20)

    --love.graphics.print("MainMenu State", 500, 300)
end

return MainMenuState
