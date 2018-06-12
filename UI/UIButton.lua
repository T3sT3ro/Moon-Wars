local UIButton = {}

local UIWidget = require "UI/UIWidget"
local UIFrame = require "UI/UIFrame"
local Typeassert = require "utils/Typeassert"
local min, max = math.min, math.max

UIButton.__index = UIButton
function UIButton.isButton(o)
    local mt = getmetatable(o)
    while mt ~= UIFrame do
        if mt == nil then
            return false
        end
        mt = getmetatable(mt) or (mt.__index ~= mt and mt.__index)
    end
    return true
end

-- default:
---- style.*
-- extra:
---- style.contentAllign = {x='left|center|right', y='up|center|down'}
---- flags.enable = [true|false] - button behaves like checkbox

function UIButton.new(style, type, content, callback)
    style = style or {}
    local self = UIWidget(style)
    Typeassert({type, callback},{{"ANY", "nil", "R:checkbox", "R:normal"}, "nil|function"})
    self.flags.enable = type == "checkbox"
    self.clickDuration = 0
    self.pressed = false -- pressed and held
    self.enabled = false -- checkbox
    self.buttonClicked = callback -- callback setup
    self.contentFrame = UIWidget({}, {invisible = false, passThru = true})
    self:addWidget(self.contentFrame)

    setmetatable(self, UIButton)
    self:setContent(content, style.contentAllign)
    return self
end

local function contentPred(o)
    return o == nil or (o.typeOf and (o:typeOf("Image") or o:typeOf("Text")))
end

function UIButton:setContent(content, contentAllign)
    Typeassert(
        {content, contentAllign},
        {
            contentPred,
            {
                "ANY",
                "nil",
                {
                    x = {"ANY", "nil", "R:left", "R:right", "R:center"},
                    y = {"ANY", "nil", "R:left", "R:right", "R:center"}
                }
            }
        }
    )
    if content then -- FIXME: expand to drawable ?
        self.contentFrame.flags.hidden = false
        self.contentFrame.style.size.x = (contentAllign and contentAllign.x) or "center"
        self.contentFrame.style.size.y = (contentAllign and contentAllign.y) or "center"
        local width, height = max(content:getWidth(), 1), max(content:getHeight(), 1)
        self.contentFrame:resize(width, height)

        self.contentFrame.drawable = content
        self.contentFrame.renderer = function(self, ...)
            love.graphics.draw(self.drawable, self:getRawCursor())
        end
    else
        self.contentFrame.flags.hidden = true
        self.contentFrame.drawable = nil
    end
end

-- @override
function UIButton:mousePressed(x, y, button)
    if button == 1 and self:requestFocus() then
        self.pressed = true
    end
end

-- @override
function UIButton:mouseReleased(x, y, button)
    if button == 1 then
        if self:getUI():getClickBegin() == self and self:getUI():getClickEnd() == self then
            if self.flags.enable then
                self.enabled = not self.enabled
            end
            self:buttonClicked() -- emit event
        end
        self.pressed = false
        self.clickDuration = 0
        self:dropFocus()
    end
end

function UIButton:updater(dt, ...)
    if self:isPressed() then
        self.clickDuration = self.clickDuration + dt
        self:buttonHeld(self.clickDuration)
    end
end

function UIButton:renderer()
    local body
    local content
    if self:isEnabled() or self:isPressed() then
        body = self.style.theme.fg_focus
        content = self.style.theme.hilit_focus
    elseif self:isHovered() then
        body = self.style.theme.fg
        content = self.style.theme.hilit
    else
        body = self.style.theme.bg
        content = self.style.theme.fg_focus
    end
    love.graphics.setColor(body:normalized())
    love.graphics.rectangle("fill", self:getAABB():normalized())
    love.graphics.setColor(content:normalized())
end

function UIButton:getClickDuration()
    return self.clickDuration
end

-- true iff mouse is held and it started over button
function UIButton:isPressed()
    return self.pressed
end

-- true if enabled, in checkbox mode
function UIButton:isEnabled()
    return self.enabled
end

-------- EVENTS ---------
-- triggered when mouse click and end is over button
function UIButton:buttonClicked()
end

-- triggered when button is held
function UIButton:buttonHeld(duration)
end
-------------------------

return setmetatable(
    UIButton,
    {
        __index = UIWidget,
        __call = function(_, ...)
            local ok, ret = pcall(UIButton.new, ...)
            if ok then
                return ret
            else
                error("UIButton: " .. ret)
            end
        end
    }
)
