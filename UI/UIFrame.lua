local UI = require("UI/UI")
local UIFrame = {}

function UIFrame.new(flags, style, data)
    local Frame = UI(flags, style, data)
    

end


-------------------------------------------------------------------------------------
return setmetatable(
    UIFrame,
    {__index = UI, __call = function(_, ...)
            return UIFrame.new(...)
        end}
)
