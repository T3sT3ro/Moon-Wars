local UIDebugState = {name = "UIDebugState"}

local min, max, floor = math.min, math.max, math.floor

local UI = require "UI/UI"
local UIWidget = require "UI/UIWidget"
local UIFrame = require "UI/UIFrame"
local UIButton = require "UI/UIButton"
local UIProgressBar = require "UI/UIProgressBar"
local UILabel = require "UI/UILabel"
local UIScrollPane = require "UI/UIScrollPane"

local Color = require "UI/Color"
local AABB = require "UI/AABB"

local blueish = Color("#5050ffa0")
local redish = Color("#ff5050a0")
local greenish = Color("#2bff1ba0")
local whiteish = Color("#ffffffa0")
local white = Color("#ffffff")
local red = Color("#ff1b2b")
local click = {start = nil, stop = nil}
ResourceManager.load("font.monospace24", "Inconsolata-Regular", "ttf", "resources/fonts", "font", 24)
ResourceManager.load("font.monospace12", "Inconsolata-Regular", "ttf", "resources/fonts", "font", 12)
ResourceManager.load("mage", "Unit", "png", "resources", "image")
font = ResourceManager.get("font.monospace24")
font12 = ResourceManager.get("font.monospace12")
mageimg = ResourceManager.get("mage")

local stateDesc
local w_width, w_height = love.graphics.getWidth(), love.graphics.getHeight()
local margin = 30

--- CONF
local printEvents = false
local GUI = UI(margin, margin, w_width - 2 * margin, w_height - 2 * margin)
local mainframe = UIFrame({ID = "mainframe", allign = {x = "left"}})
local side =
    UIFrame(
    {ID = "side", margin = {all = 5}, size = {x = "20%"}, allign = {x = "right"}, invisible = false, displayMode = "bf"}
)
local body = UIFrame({ID = "body", size = {x = "80%"}, allign = {x = "left"}})
local scroll =
    UIScrollPane(
    {ID = "scroll", virtualSize = {x = 500, y = 500}, margin = {all = 50}},
    {scroll = {x = true}, scrollInfinite = false}
)
local scrollLabel = UILabel("scroll me", {ID = "scrollMeText"})
local f0 = UIWidget({ID = "f0", size = {x = "80%", y = "80%"}, margin = {all = 30}})
local f1 = UIWidget({ID = "f1", size = {x = "80%", y = "80%"}, margin = {all = 30}})
local f2 = UIWidget({ID = "f2", allign = {x = "left", y = "up"}, size = {x = "50%", y = "80%"}, margin = {all = 30}})
local f3 = UIWidget({ID = "f3", allign = {x = "right", y = "down"}, z = -1, size = {x = "50%", y = "80%"}})
local f4 = UIWidget({ID = "f4", size = {x = "80%", y = "80%"}}, {passThru = true, allowOverflow = true})
local f5 = UIWidget({ID = "f5", origin = {x = "20%", y = "0%"}, size = {x = "50%", y = "50%"}})
local progress =
    UIProgressBar(
    {size = {y = 20}, origin = {y = -40}, direction = "x", showValue = true, format = "progress: %d%%"},
    30
)
local lore =
    UILabel("Dolor sit amet et amona magnificenti luna lua de la vista.", {ID = "lore", theme = {font = font24}})
local TEXT_1 = love.graphics.newText(font, "BTTN")
local bttn =
    UIButton(
    "normal",
    {ID = "BTTN", margin = {x = 15}, size = {x = "80%", y = TEXT_1:getHeight()}},
    TEXT_1,
    function()
        print "CLICKED"
    end
)
local imgbttn =
    UIButton(
    "normal",
    {ID = "imgbttn", size = {x = mageimg:getWidth(), y = mageimg:getHeight()}, origin = {y = "10%"}},
    mageimg,
    bttn:getCallback()
)
bttn.buttonHeld = function(self, delta)
    print("HELD for " .. delta)
end

progress.delta = 1
progress.updater = function(self, dt)
    if self.value == 120 then
        self.delta = -1
    elseif self.value == -20 then
        self.delta = 1
    end
    self.value = self.value + self.delta
end
---

GUI:setWidget(mainframe)
mainframe:addWidget(body)
mainframe:addWidget(side)
body:addWidget(scroll)
scroll:addWidget(f0)
scroll:addWidget(scrollLabel)
f0:addWidget(f1)
f1:addWidget(f2)
f1:addWidget(f3)
f3:addWidget(f4)
f4:addWidget(f5)

side:addWidget(lore)
side:addWidget(progress)
side:addWidget(bttn)
side:addWidget(imgbttn)

local widgetRenderer = function(self)
    if self:isFocused() then
        love.graphics.setColor(self.style.theme.fg_focus:normalized())
    elseif self:isHovered() then
        love.graphics.setColor(self.style.theme.fg:normalized())
    else
        love.graphics.setColor(self.style.theme.bg:normalized())
    end

    love.graphics.rectangle("fill", 0, 0, self:getWidth(), self:getHeight())
    love.graphics.setColor(red:normalized())
    love.graphics.rectangle("line", 0, 0, self:getWidth(), self:getHeight())
    love.graphics.setColor(white:normalized())
    love.graphics.print(self.style.ID, 0, 0)
    if self.info then
        love.graphics.print(self.info, 14, 0)
    end
end

f0.renderer, f0.info = widgetRenderer, "main widget"
f1.renderer, f1.info = widgetRenderer, "double container"
f2.renderer, f2.info = widgetRenderer, "left\nblink"
f3.renderer, f3.info = widgetRenderer, "right"
f4.renderer, f4.info = widgetRenderer, "pass\nover"
f5.renderer, f5.info = widgetRenderer, "shifted\nmov"

local oldHandlers = {mc, mr, wm, kp, kr, ti, fd, dd}
local function _EVTme(self)
    return printEvents and print("EVT: me", self.style.ID)
end
local function _EVTmx(self)
    return printEvents and print("EVT: mx", self.style.ID)
end
local function _EVTmc(self, x, y, button)
    return self:requestFocus() and printEvents and print("EVT: mc", self.style.ID, x, y, button)
end
local function _EVTmr(self, x, y, button)
    return printEvents and print("EVT: mr", self.style.ID, x, y, button)
end
local function _EVTwm(self, x, y)
    local _ = printEvents and print("EVT: wm", self.style.ID, x, y)
    return true
end
local function _EVTkp(self, key, scancode, isRepeat)
    return printEvents and print("EVT: kp", self.style.ID, key, scancode, isRepeat)
end
local function _EVTkr(self, key, scancode)
    return printEvents and print("EVT: kr", self.style.ID, key, scancode)
end
local function _EVTti(self, text)
    return printEvents and print("EVT: ti", self.style.ID, text)
end
local function _EVTfd(self, file)
    return printEvents and print("EVT: fd", self.style.ID, file)
end
local function _EVTdd(self, path)
    return printEvents and print("EVT: dd", self.style.ID, path)
end
local function _EVTmm(self, x, y, dx, dy)
    return printEvents and print("EVT: mm", self.style.ID, x, y, dx, dy)
end

for _, v in ipairs({f0, f1, f2, f3, f4, f5}) do
    v.mouseEntered = _EVTme
    v.mouseExited = _EVTmx
    v.mousePressed = _EVTmc
    v.mouseReleased = _EVTmr
    v.wheelMoved = _EVTwm
    v.keyPressed = _EVTkp
    v.keyReleased = _EVTkr
    v.textInput = _EVTti
    v.fileDropped = _EVTfd
    v.directoryDropped = _EVTdd
    v.mousemoved = _EVTmm
end

f0.mousePressed = function (self, x, y, button) 
    print(button, "->", self:toLocalCoordinates(x, y))
end

function UIDebugState.init()
    oldHandlers = {
        mp = love.mousepressed,
        mr = love.mousereleased,
        wm = love.wheelmoved,
        kp = love.keypressed,
        kr = love.keyreleased,
        ti = love.textinput,
        fd = love.filedropped,
        dd = love.directorydropped
    }
    local handlers = GUI:getEventHandlers()

    love.mousepressed = handlers.mousepressed
    love.mousereleased = handlers.mousereleased
    love.wheelmoved = handlers.wheelmoved
    love.keypressed = handlers.keypressed
    love.keyreleased = handlers.keyreleased
    love.textinput = handlers.textinput
    love.filedropped = handlers.filedropped
    love.directorydropped = handlers.directorydropped
    love.mousemoved = handlers.mousemoved
    stateDesc = stateDesc or love.graphics.newText(font, "UI_DEBUG_STATE")
    click.start, click.stop = nil, nil
    w_width, w_height = love.graphics.getWidth(), love.graphics.getHeight()
end

f2.updater = function(self, dt)
    self.cntr = self.cntr or 0
    self.cntr = self.cntr + 1
    if self:isHovered() and self.cntr > 50 then
        if self.style.allign.y == "up" then
            self.style.allign.y = "down"
        elseif self.style.allign.y == "down" then
            self.style.allign.y = "up"
        end
        self.cntr = 0
    end
end

f5.updater = function(self, dt)
    if self:isFocused() then
        local delta = 1
        if love.keyboard.isDown("left") then
            self.style.origin.x = self.style.origin.x - delta
        end
        if love.keyboard.isDown("right") then
            self.style.origin.x = self.style.origin.x + delta
        end
        if love.keyboard.isDown("up") then
            self.style.origin.y = self.style.origin.y - delta
        end
        if love.keyboard.isDown("down") then
            self.style.origin.y = self.style.origin.y + delta
        end
    end
end

lore.timeElapsed = 0
lore.updater = function(self, dt)
    lore.timeElapsed = lore.timeElapsed + dt
    if lore.timeElapsed > 2 then
        lore.timeElapsed = 0
        self.style.theme.hilit = UI.theme[5]
        self.style.theme.font = font12
        self:setText("longer test and wrap test test test verylongsinglewordthatshouldwrapsomehow another line here")
    elseif lore.timeElapsed > 1 then
        self.style.theme.hilit = UI.theme[3]
        self.style.theme.font = font
        self:setText("test")
    end
end

function UIDebugState.update(dt)
    GUI:update(dt)
    if w_width ~= love.graphics.getWidth() or w_height ~= love.graphics.getHeight() then
        w_width, w_height = love.graphics.getWidth(), love.graphics.getHeight()
        GUI:resize(margin, margin, w_width - 2 * margin, w_height - 2 * margin)
    end
    if love.mouse.isDown(1) and not click.start then
        click.start = {x = love.mouse.getX(), y = love.mouse.getY()}
    end
    if not love.mouse.isDown(1) and click.start then
        click.stop = {x = love.mouse.getX(), y = love.mouse.getY()}
    end

    if
        love.mouse.getX() > w_width - margin and love.mouse.getY() < margin and click.start and click.stop and
            click.start.x > w_width - margin and
            click.start.y < margin and
            click.stop.x > w_width - margin and
            click.stop.y < margin
     then
        StateManager.load(MainMenuState.name)
    end
    if click.stop then
        click.start, click.stop = nil, nil
    end
end

local function drawAABB(AABB, c, n)
    local x, y, w, h = love.graphics.getScissor()
    love.graphics.setScissor(GUI.origin.x, GUI.origin.y, GUI:getWidth(), GUI:getHeight())
    local original = Color(love.graphics.getColor())
    love.graphics.newText(ResourceManager.get("fonts.Montserrat-Regular"), "UI_DEBUG_STATE")
    love.graphics.setColor(white:normalized())
    love.graphics.print(n, AABB[1].x, AABB[1].y)
    love.graphics.setColor(c:normalized())
    love.graphics.rectangle("fill", AABB[1].x, AABB[1].y, AABB[2].x - AABB[1].x, AABB[2].y - AABB[1].y)
    love.graphics.setColor(original:normalized())
    love.graphics.setScissor(x, y, w, h)
end

function UIDebugState.draw()
    GUI:draw()
    love.graphics.setColor(red:normalized())
    love.graphics.draw(stateDesc, 0, 0)
    local mousePosText = love.graphics.newText(font, string.format("Mouse:\t(%d\t,%d)", love.mouse.getPosition()))
    love.graphics.draw(mousePosText, w_width - mousePosText:getWidth(), w_height - mousePosText:getHeight())
    local memText = love.graphics.newText(font, string.format("Memory: %04d kB", floor(collectgarbage("count"))))
    love.graphics.draw(memText, 0, w_height - memText:getHeight())
    love.graphics.rectangle("fill", w_width - margin, 0, margin, margin)
    love.graphics.rectangle("line", GUI.origin.x, GUI.origin.y, GUI.size.x, GUI.size.y)
    love.graphics.setColor(white:normalized())
    love.graphics.print("EXIT", w_width - margin)
    local _  -- trash variable
    if love.keyboard.isDown("a") then
        _ = love.keyboard.isDown("0") and drawAABB(f0:getAvailAABB(), blueish, " F0_A")
        _ = love.keyboard.isDown("1") and drawAABB(f1:getAvailAABB(), blueish, " F1_A")
        _ = love.keyboard.isDown("2") and drawAABB(f2:getAvailAABB(), blueish, " F2_A")
        _ = love.keyboard.isDown("3") and drawAABB(f3:getAvailAABB(), blueish, " F3_A")
        _ = love.keyboard.isDown("4") and drawAABB(f4:getAvailAABB(), blueish, " F4_A")
        _ = love.keyboard.isDown("5") and drawAABB(f5:getAvailAABB(), blueish, " F5_A")
    end
    if love.keyboard.isDown("i") then
        _ = love.keyboard.isDown("0") and drawAABB(f0:getAABB(), redish, " F0_I")
        _ = love.keyboard.isDown("1") and drawAABB(f1:getAABB(), redish, " F1_I")
        _ = love.keyboard.isDown("2") and drawAABB(f2:getAABB(), redish, " F2_I")
        _ = love.keyboard.isDown("3") and drawAABB(f3:getAABB(), redish, " F3_I")
        _ = love.keyboard.isDown("4") and drawAABB(f4:getAABB(), redish, " F4_I")
        _ = love.keyboard.isDown("5") and drawAABB(f5:getAABB(), redish, " F5_I")
    end
    if love.keyboard.isDown("v") then
        _ = love.keyboard.isDown("0") and drawAABB(f0:getVisibleAABB(), greenish, " F0_V")
        _ = love.keyboard.isDown("1") and drawAABB(f1:getVisibleAABB(), greenish, " F1_V")
        _ = love.keyboard.isDown("2") and drawAABB(f2:getVisibleAABB(), greenish, " F2_V")
        _ = love.keyboard.isDown("3") and drawAABB(f3:getVisibleAABB(), greenish, " F3_V")
        _ = love.keyboard.isDown("4") and drawAABB(f4:getVisibleAABB(), greenish, " F4_V")
        _ = love.keyboard.isDown("5") and drawAABB(f5:getVisibleAABB(), greenish, " F5_V")
    end
    if love.keyboard.isDown("w") then
        _ = love.keyboard.isDown("0") and drawAABB(f0:getVisibleAvailAABB(), whiteish, " F0_AV")
        _ = love.keyboard.isDown("1") and drawAABB(f1:getVisibleAvailAABB(), whiteish, " F1_AV")
        _ = love.keyboard.isDown("2") and drawAABB(f2:getVisibleAvailAABB(), whiteish, " F2_AV")
        _ = love.keyboard.isDown("3") and drawAABB(f3:getVisibleAvailAABB(), whiteish, " F3_AV")
        _ = love.keyboard.isDown("4") and drawAABB(f4:getVisibleAvailAABB(), whiteish, " F4_AV")
        _ = love.keyboard.isDown("5") and drawAABB(f5:getVisibleAvailAABB(), whiteish, " F5_AV")
    end
end

function UIDebugState.clear()
    click.start, click.stop = nil, nil
    love.mousepressed = oldHandlers.mp
    love.mousereleased = oldHandlers.mr
    love.wheelmoved = oldHandlers.wm
    love.keypressed = oldHandlers.kp
    love.keyreleased = oldHandlers.kr
    love.textinput = oldHandlers.ti
    love.filedropped = oldHandlers.fd
    love.directorydropped = oldHandlers.dd
    love.mousemoved = oldHandlers.mm
end

return UIDebugState

--[[ TODO: fixup state manager for errors
    if type(stateName) ~= 'string' then error("StateManager: passed argument is not a string.") end
    if not state then error("StateManager: no state '"..stateName.."' loaded.") end
]]
