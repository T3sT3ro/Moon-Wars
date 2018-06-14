local UIProgressBar = {}
package.loaded[...] = UIProgressBar

local UIWidget = require "UI/UIWidget"
local Typeassert = require "utils/Typeassert"
local Color = require "UI/Color"
local min, max, floor = math.min, math.max, math.floor

UIProgressBar.__index = UIProgressBar

function UIProgressBar.isProgressBar(o)
    return UIWidget.isA(o, UIProgressBar)
end

-- default:
---- UIWidget.style.*
---- UIWidget.flags.*
---- flags.passThru = true
-- extra:
---- value=[minValue-maxValue]
---- min=0
---- max=100
---- style.color.<primary|secondary|lore>=style.theme.<hilit|bg|red>
---- style.showValue=false
---- style.format="%d"
---- orientation='x|y'

function UIProgressBar.new(style, value, minV, maxV)
    Typeassert(
        {value = value, style = style},
        {
            value = "nil|number",
            minV = "nil|number",
            maxV = "nil|number",
            style = {
                "ANY",
                "nil",
                {
                    color = {
                        "ANY",
                        "nil",
                        {
                            primary = {"ANY", "nil", Color.ioColor},
                            secondary = {"ANY", "nil", Color.ioColor},
                            lore = {"ANY", "nil", Color.ioColor},
                        }
                    },
                    showValue = "nil|boolean",
                    orientation = {"ANY", "nil", "R:x", "R:y"},
                    format = "nil|string"
                }
            }
        }
    )
    local style = style or {}
    local self = UIWidget(style, {passThru = true})
    
    self.value = value or 0
    self.min = minV or 0
    self.max = maxV or 100

    self.style.color =
        setmetatable(
        {},
        {
            _primary, -- filled progress bar color
            _secondary, -- not filled progress bar color
            _lore, -- displayed value color
            __index = function(t, k)
                local code = ({primary = 4, secondary = 1, lore = 6})[k]
                return (code and self._UI and Color(self._UI.theme[code])) or Color("#ffffff") -- default is black
            end
        }
    )
    self.style.showValue = style.showValue or false
    self.style.orientation = style.orientation or "x"
    self.style.format = style.format or "%d"

    setmetatable(self, UIProgressBar)
    return self
end

function UIProgressBar:renderer()
    love.graphics.setColor(self.style.color.secondary:normalized())
    local aabb = self:getAABB()
    love.graphics.rectangle("fill", aabb:normalized())
    local value = min(max(self.value, self.min), self.max)
    local valueP = 100 * (value - self.min) / (self.max - self.min) -- normalized to [0-100]
    if self.style.orientation == "x" then
        aabb:contract("right", floor(aabb:getWidth() * (100 - valueP) / 100))
    else
        aabb:contract("up", floor(aabb:getHeight() * (100 - valueP) / 100))
    end
    love.graphics.setColor(self.style.color.primary:normalized())
    love.graphics.rectangle("fill", aabb:normalized())
    if self.style.showValue then
        love.graphics.setColor(self.style.color.lore:normalized())
        local text = love.graphics.newText(love.graphics.newFont(10), string.format(self.style.format, value))
        local ox, oy =
            floor((self:getAABB()[1].x + self:getAABB()[2].x) / 2),
            floor((self:getAABB()[1].y + self:getAABB()[2].y) / 2)
        love.graphics.draw(text, ox - text:getWidth() / 2, oy - text:getHeight() / 2)
    end
end

return setmetatable(
    UIProgressBar,
    {
        __index = UIWidget,
        __call = function(_, ...)
            local ok, ret = pcall(UIProgressBar.new, ...)
            if ok then
                return ret
            else
                error("UIProgressBar: " .. ret)
            end
        end
    }
)
