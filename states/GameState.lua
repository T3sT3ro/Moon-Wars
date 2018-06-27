local ui = require "game/GameUI"
local manager = require "game/GameManager"
local MainMenuState = {name = "MainMenuState"}
local UI = require("UI/UI")
local UIButton = require("UI/UIButton")
local UIFrame = require("UI/UIFrame")
local UIWidget = require("UI/UIWidget")
local UIScrollPane = require("UI/UIScrollPane")
local UIProgressBar = require("UI/UIProgressBar")
local UILabel = require("UI/UILabel")

ResourceManager.load("font.monospace24", "Inconsolata-Regular", "ttf", "resources/fonts", "font", 24)
ResourceManager.load("stoneImg", "stone", "png", "resources", "image")
ResourceManager.load("woodImg", "wood", "png", "resources", "image")
ResourceManager.load("crystalImg", "crystal", "png", "resources", "image")

local GUI = UI(0, 0, love.graphics.getWidth(), love.graphics.getHeight())
local MainFrame = UIFrame({margin={all=2}, invisible=false, displayMode="b"})
GUI:setWidget(MainFrame)
local logic = manager.getLogic()

local Aside = UIFrame({size={x='20%'}, allign={x="left", y="up"}, margin = {all=5}, invisible=false, displayMode="fb"})
MainFrame:addWidget(Aside)

local HPBar = UIProgressBar({size = {y=20}, allign={x="left",y="up"},showValue=true, format="HP: %d"}, 0, 0, 100)
local APBar = UIProgressBar({origin={y=30}, size = {y=20}, allign={x="left",y="up"},showValue=true, format="AP: %d"}, 0, 0, 10)
HPBar.updater = function(self, dt) self.value = logic.getCurUnit().health end
APBar.updater = function(self, dt) self.value = logic.getCurActionPoints() end
Aside:addWidget(HPBar)
Aside:addWidget(APBar)

local EQFrame = UIFrame({allign={y="down"},size={y=3*64+4}, margin={all=2}, invisible = false, displayMode= "b"})
Aside:addWidget(EQFrame)
local stoneImg, woodImg, crystalImg = ResourceManager.get("stoneImg"), ResourceManager.get("woodImg"), ResourceManager.get("crystalImg")
local foo = function() end
local WoodFrame = UIFrame({size={y=woodImg:getHeight()}, allign={y="up"}})
local WoodEQ = UIButton("normal", {size={x=woodImg:getWidth(), y=woodImg:getHeight()}, allign={x="left",y="up"}}, woodImg, foo)
local woodLore = UILabel("0", nil)

local StoneFrame = UIFrame({size={y=stoneImg:getHeight()}, allign={y="center"}})
local StoneEQ = UIButton("normal", {size={x=stoneImg:getWidth(), y=stoneImg:getHeight()}, allign={x="left",y="up"}}, stoneImg, foo)
local stoneLore = UILabel("0", nil)

local CrystalFrame = UIFrame({size={y=crystalImg:getHeight()}, allign={y="down"}})
local CrystalEQ = UIButton("normal", {size={x=crystalImg:getWidth(), y=crystalImg:getHeight()}, allign={x="left",y="up"}}, crystalImg, foo)
local crystalLore = UILabel("0", nil)

EQFrame:addWidget(WoodFrame)
WoodFrame:addWidget(WoodEQ)
WoodFrame:addWidget(woodLore)

EQFrame:addWidget(StoneFrame)
StoneFrame:addWidget(StoneEQ)
StoneFrame:addWidget(stoneLore)

EQFrame:addWidget(CrystalFrame)
CrystalFrame:addWidget(CrystalEQ)
CrystalFrame:addWidget(crystalLore)

woodLore.updater = function(self, dt) 
    local howmany = 0
    for _, v in pairs(logic.getCurUnit().equipment) do 
        if v.name == "wood" then howmany = howmany + 1 end
    end
    self:setText(tostring(howmany))
end
stoneLore.updater = function(self, dt) 
    local howmany = 0
    for _, v in pairs(logic.getCurUnit().equipment) do 
        if v.name == "stone" then howmany = howmany + 1 end
    end
    self:setText(tostring(howmany))
end
crystalLore.updater = function(self, dt) 
    local howmany = 0
    for _, v in pairs(logic.getCurUnit().equipment) do 
        if v.name == "crystal" then howmany = howmany + 1 end
    end
    self:setText(tostring(howmany))
end

local ScrollMap = UIScrollPane({origin={x='20%'}, size={x='80%'},allign={x="left", y="up"}, virtualSize = {x=20*64, y=20*64}},{scroll = {x=true, y=true}})
local MapFrame = UIWidget({size = {x = 20*64, y = 20*64}})
MapFrame.renderer = manager.draw
MapFrame.mousePressed = manager.mousePressed
MainFrame:addWidget(ScrollMap)
ScrollMap:addWidget(MapFrame)
local GameState = {}
GameState.name = "GameState"
local oldResize 
function GameState.init()
    oldResize = love.resize
    oldHandlers = {
        mp = love.mousepressed,
        mr = love.mousereleased,
        mw = love.mousemoved,
        wm = love.wheelmoved,
        kp = love.keypressed,
        kr = love.keyreleased,
        ti = love.textinput,
        fd = love.filedropped,
        dd = love.directorydropped,
        mm = love.mousemoved
    }
    local handlers = GUI:getEventHandlers()

    love.resize = function(w,h)
        GUI:resize(0,0,w,h)
    end
    love.mousepressed = handlers.mousepressed
    love.mousereleased = handlers.mousereleased
    love.mousemoved = handlers.mousemoved
    love.wheelmoved = handlers.wheelmoved
    love.keypressed = handlers.keypressed
    love.keyreleased = handlers.keyreleased
    love.textinput = handlers.textinput
    love.filedropped = handlers.filedropped
    love.directorydropped = handlers.directorydropped
    love.mousemoved = handlers.mousemoved
    manager.init()
    ui.init()
end

function GameState.clear()
    love.resize = oldResize
    love.mousepressed = oldHandlers.mp
    love.mousereleased = oldHandlers.mr
    love.mousemoved = oldHandlers.mw
    love.wheelmoved = oldHandlers.wm
    love.keypressed = oldHandlers.kp
    love.keyreleased = oldHandlers.kr
    love.textinput = oldHandlers.ti
    love.filedropped = oldHandlers.fd
    love.directorydropped = oldHandlers.dd
    love.mousemoved = oldHandlers.mm
    manager.clear()
    ui.clear()
end

function GameState.update(dt)
    GUI:update(dt)
    manager.update(dt)
end

function GameState.draw()
    GUI:draw(0,0)
    --manager.draw(0)
end

return GameState