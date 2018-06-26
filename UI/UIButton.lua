local UIButton = {}
package.loaded[...] = UIButton

local UIWidget = require "UI/UIWidget"
local UIFrame = require "UI/UIFrame"
local Color = require "UI/Color"
local Typeassert = require "utils/Typeassert"
local min, max = math.min, math.max

UIButton.__index = UIButton

function UIButton.isButton(o)
    return UIWidget.isA(o, UIButton)
end

-- default:
---- UIWidget.style.*
---- UIWidget.flags.*
-- extra:
---- style.contentAllign = {[x='left|center|right'], [y='up|center|down']}
---- flags.enable = true iff type=='checkbox'
---- callback = function triggered when button clicked

-- type = {nil|'checkbox'|'normal'}   content = love Image or love Text
function UIButton.new(type, style, content, callback)
    Typeassert(
        {type, style, content, callback},
        {{"ANY", "nil", "R:checkbox", "R:normal"}, "nil|table", "nil|userdata|string", "nil|function"}
    )
    style = style or {}
    local self = UIWidget(style)
    self.flags.enable = type == "checkbox"
    self.clickDuration = 0
    self.enabled = false -- checkbox
    self.buttonClicked = callback -- callback setup
    self.contentFrame = UIWidget({invisible = false}, {passThru = true})
    self:addWidget(self.contentFrame)

    setmetatable(self, UIButton)
    self:setContent(content, style.contentAllign)
    return self
end

local function contentPred(o)
    return o == nil or type(o) == string or (o.typeOf and (o:typeOf("Image") or o:typeOf("Text")))
end
-- used to change the content of a button. content can be love Text or love Image for now
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
    if type(content) == "string" then
        content = love.graphics.newText(self.style.theme.font, content)
    end
    if content then -- FIXME: expand to drawable ?
        self.contentFrame.flags.hidden = false
        self.contentFrame.style.allign.x = (contentAllign and contentAllign.x) or "center"
        self.contentFrame.style.allign.y = (contentAllign and contentAllign.y) or "center"
        local width, height = max(content:getWidth(), 1), max(content:getHeight(), 1)
        self.contentFrame:resize(width, height)

        self.contentFrame.drawable = content
        self.contentFrame.renderer = function(self, ...)
            love.graphics.setColor(self.style.theme.content:normalized())
            love.graphics.draw(self.drawable, 0, 0)
        end
    else
        self.contentFrame.flags.hidden = true
        self.contentFrame.drawable = nil
    end
end

function UIButton:getCallback()
    return self.buttonClicked
end

-- @override
function UIButton:mousePressed(x, y, button)
    if button == 1 and self:requestFocus() then
        self.clickDuration = 0
    end
    if button ~= 1 then
        return true
    end
end

-- @override
function UIButton:mouseReleased(x, y, button)
    if button == 1 then
        if self:isPressed() and self:getUI():getClickEnd(button) == self then
            if self.flags.enable then
                self.enabled = not self.enabled
            end
            self:buttonClicked() -- emit event
        end
        self.clickDuration = 0
        self:dropFocus()
    end
    if button ~= 1 then
        return true
    end
end

function UIButton:requestDropFocus()
    self.clickDuration = 0
    self:dropFocus()
end

function UIButton:updater(dt, ...)
    if self:isPressed() then
        self.clickDuration = self.clickDuration + dt
        self:buttonHeld(self.clickDuration)
    end
    if self:isEnabled() or self:isPressed() then
        self.style.theme.body = self.style.theme.fg_focus
        self.style.theme.content = self.style.theme.hilit_focus
    elseif self:isHovered() then
        self.style.theme.body = self.style.theme.fg
        self.style.theme.content = self.style.theme.hilit
    else
        self.style.theme.body = self.style.theme.bg
        self.style.theme.content = self.style.theme.fg_focus
    end
    if self.contentFrame.drawable and self.contentFrame.drawable:typeOf("Image") then
        self.style.theme.content = Color("#ffffff")
    end
end

function UIButton:renderer()
    love.graphics.setColor(self.style.theme.body:normalized())
    love.graphics.rectangle("fill", 0, 0, self:getWidth(), self:getHeight())
end

function UIButton:getClickDuration()
    return self.clickDuration
end

-- true iff mouse is held and it started over button
function UIButton:isPressed()
    return self._UI and self._UI:getClickBegin(1) == self
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
