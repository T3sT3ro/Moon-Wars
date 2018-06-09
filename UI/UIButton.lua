local UIButton = {}

local UIWidget = require "UI/UIWidget"

function UIButton.isButton(o)
    local mt = getmetatable(o)
    while mt ~= UIButton do
        if mt == nil then return false end
        mt = getmetatable(mt)
    end
    return true
end

-- additional flags:
---- allowEnable
function UIButton.new(action, content, style, flags)
    local self = UIWidget()
    local width, height = 30, 30
    if content and content.typeOf then 
        if content:typeOf("Image") then
            width, height = content:getWidth()+1, content:getHeight()+1
            self.content = content
        elseif content:typeOf("Text") then
            width, height = content:getWidth()+5, content:getHeight()+5
            self.content = content
        end
    end
    self.flags.allowEnable = self.flags.allowEnable or flags.allowEnable

    
    return self
end

function UIButton:getPressDuration()

end

function UIButton:isPressed()
    return self.enabled
end

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
