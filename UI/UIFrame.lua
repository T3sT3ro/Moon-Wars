local UIFrame = {}
package.loaded[...] = UIFrame

local UIWidget = require "UI/UIWidget"
local Typeassert = require "utils/Typeassert"

UIFrame.__index = UIFrame

function UIFrame.isFrame(o)
    return UIWidget.isA(o, UIFrame)
end

-- default:
---- UIWidget.style.*
---- UIWidget.flags.*
-- extra:
---- flags.passThru = true
---- style.invisible = true
---- style.displayMode = '[bf]': [b]order [f]ill
function UIFrame.new(style)
    Typeassert(style, {"ANY", "nil", {displayMode = {"ANY", "nil", "R:[bf]+"}}})
    style = style or {}

    local self = UIWidget(style)
    self.style.invisible = style.invisible or style.invisible == nil and true
    self.style.displayMode = style.displayMode or ""

    self.flags.passThru = true
    return setmetatable(self, UIFrame) -- ok since UIFrame's index is UIWidget
end

function UIFrame:renderer()
    if string.match(self.style.displayMode, "f") then
        love.graphics.setColor(self.style.theme.bg:normalized())
        love.graphics.rectangle("fill", 0, 0, self:getWidth(), self:getHeight())
    end
    if string.match(self.style.displayMode, "b") then
        love.graphics.setLineWidth(5)
        love.graphics.setColor(self.style.theme.fg:normalized())
        love.graphics.rectangle("line", 0, 0, self:getWidth(), self:getHeight())
    end
end

return setmetatable(
    UIFrame,
    {
        __index = UIWidget,
        __call = function(_, ...)
            local ok, ret = pcall(UIFrame.new, ...)
            if ok then
                return ret
            else
                error("UIFrame: " .. ret)
            end
        end
    }
)
