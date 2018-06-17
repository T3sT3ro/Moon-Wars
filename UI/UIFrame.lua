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
---- flags.invisible = true iff displayMode not set
---- style.displayMode = '[bf]': [b]order [f]ill
function UIFrame.new(style)
    Typeassert(style, {"ANY", "nil", {displayMode = {"ANY", "nil", "R:[bf]+"}}})
    style = style or {}

    local self = UIWidget(style)
    self.flags.passThru = true
    self.flags.invisible = not style.displayMode

    self.style.displayMode = style.displayMode or ""
    return setmetatable(self, UIFrame) -- ok since UIFrame's index is UIWidget
end

function UIFrame:renderer()
    if string.match(self.style.displayMode, "f") then
        love.graphics.setColor(self.style.theme.bg:normalized())
        love.graphics.rectangle("fill", self:getAABB():normalized())
    end
    if string.match(self.style.displayMode, "b") then
        love.graphics.setColor(self.style.theme.fg:normalized())
        love.graphics.rectangle("line", self:getAABB():normalized())
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
