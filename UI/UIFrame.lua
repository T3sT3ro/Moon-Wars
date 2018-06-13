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
---- style.displayMode = ['b|f|bf']: [b]order [f]ill
function UIFrame.new(style, flags)
    Typeassert({style, flags}, {{"ANY", "nil", {displayMode = {"ANY", "nil", "R:[bf]+"}}}, "table|nil"})
    style, flags = style or {}, flags or {}

    flags.passThru = flags.passThru or true
    flags.invisible = not style.displayMode
    local self = UIWidget(style, flags)

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
