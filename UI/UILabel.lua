local UILabel = {}
package.loaded[...] = UIScrollPane

local UIWidget = require "UI/UIWidget"
local UIFrame = require "UI/UIFrame"
local Typeassert = require "utils/Typeassert"
local min, max, floor = math.min, math.max, math.floor

UILabel.__index = UILabel

function UILabel.isLabel(o)
    return UIWidget.isA(o, UILabel)
end

-- default:
---- UIWidget.style.*
---- UIWidget.flags.*
---- flags.passThru = true
---- color is style.theme.hilit
function UILabel.new(text, style)
    Typeassert(text, "nil|string")
    local self = UIWidget(style)
    self.flags.passThru = true

    setmetatable(self, UILabel)
    self.wrappedText = {}
    self:setText(text)
    local tmt = getmetatable(self.style.theme)
    tmt.__newindex = function(t, k, v) -- on font change: trigger reload
        rawset(t, k, v)
        if (k == 'font') then self._layoutModified = true end
    end
    return self
end

function UILabel:setText(text)
    text = text or ""
    self.text = text
    local _, wrappedText = self.style.theme.font:getWrap(text, self.style.size.x)
    self.wrappedText = wrappedText
    self._layoutModified = true
end

function UILabel:reloadLayoutSelf(doReload)
    if not (self.flags.hidden and doReload) or self._layoutModified then
        UIWidget.reloadLayoutSelf(self)
        self:setText(self.text)
        self._layoutModified = false
    end
end

-- hide functionality
function UILabel:addWidget() end

function UILabel:getText()
    return self.text
end

function UILabel:renderer()
    local totalHeight = 0
    love.graphics.setColor(self.style.theme.hilit:normalized())
    for lix, line in ipairs(self.wrappedText) do
        line = love.graphics.newText(self.style.theme.font, line)
        love.graphics.draw(line, 0, totalHeight)
        totalHeight = totalHeight + line:getHeight()
    end
end

return setmetatable(
    UILabel,
    {
        __index = UIWidget,
        __call = function(_, ...)
            local ok, ret = pcall(UILabel.new, ...)
            if ok then
                return ret
            else
                error("UILabel: " .. ret)
            end
        end
    }
)
