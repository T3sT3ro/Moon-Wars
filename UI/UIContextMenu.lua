local UIContextMenu = {}
package.loaded[...] = UIContextMenu

local UIWidget = require "UI/UIWidget"
local UIFrame = require "UI/UIFrame"
local UIButton = require "UI/UIButton"
local UILabel = require "UI/UILabel"
local Color = require "UI/Color"
local Typeassert = require "utils/Typeassert"
local min, max, floor, ceil = math.min, math.max, math.floor, math.ceil

UIContextMenu.__index = UIContextMenu

function UIContextMenu.isContextMenu(o)
    return UIWidget.isA(o, UIContextMenu)
end

-- default:
---- UIWidget.style.*
---- UIWidget.flags.*
---- style.size = {x=0, y=0} - will grow according to options sizes
---- allign = {x="left", y="up"}
---- style.margin ~ ignored
---- style.invisible = false
---- flags.allowOverflow = true
-- extra:
---- options = {} ordered list of options in menu
function UIContextMenu.new(style)
    style, flags = style or {}, flags or {}
    style.size = {x = 0, y = 0}
    style.margin = nil
    style.invisible = false
    style.allign = {x = "left", y = "up"}
    flags.allowOverflow = false
    local self = UIWidget(style, flags)
    self.options = {}
    self._suboptions = {}
    setmetatable(self, UIContextMenu)
    self.flags.hidden = true
    return self
end

-- FIXME: adds vertical line to the menu
function UIContextMenu:addDivider()
    local div = UIFrame({size = {y = 9}, allign = {y = "up"}, invisible = false}) --TODO: UIMinimalistic
    div.renderer = function(self)
        love.graphics.setLineWidth(1)
        love.graphics.setColor(self.style.theme.hilit:normalized())
        local vpos = ceil(self:getHeight() / 2)
        love.graphics.line(0, vpos, self:getWidth(), vpos)
    end
    div.isDivider = true
    table.insert(self.options, div) -- 4px gap, 1px line, 4px gap
    table.insert(self._childrenByZ, div)
    self.style.size.y = self.style.size.y + div:getHeight() -- 1 pixel dividers
    self._layoutModified = true
end

-- adds option (aka button with callback), index is optional, default adds at the end
function UIContextMenu:addOption(text, callback)
    local txt = love.graphics.newText(self.style.theme.font, text)
    self.style.size.x = max(self.style.size.x, txt:getWidth()+30)
    local option =
        UIButton(
        "normal",
        {
            origin = {y = self.style.size.y},
            size = {y = txt:getHeight() + 4, x = "100%"},
            margin = {x = 0},
            contentAllign = {x = "left"},
            allign = {x = "left", y = "up"}
        },
        txt,
        callback
    )
    table.insert(self.options, option)
    self:addWidget(option)
    local oldEvt = option.buttonClicked
    option.buttonClicked = function(_self)
        oldEvt(_self)
        self:despawn()
    end
    self._suboptions[option] = true
    self.style.size.y = self.style.size.y + option:getHeight()
    self._layoutModified = true
end

-- -- removes option from context menu, returns removed object
-- function UIContextMenu:removeOption(idx)
--     if idx < 0 or idx > #self.options then
--         return
--     end
--     local removed = self.options[idx]
--     table.remove(self.options, idx)
--     for i = idx, #self.options do -- shift all below by proper amount
--         local opt = self.options[i]
--         opt.origin.y = opt.origin.y - removed:getHeight()
--     end
--     self.style.size.y = self.style.size.y - opt:getHeight()
--     self._layoutModified = true
--     return removed
-- end

-- function UIContextMenu:addSubmenu(text, ContextMenu)
--     if not UIContextMenu.isContextMenu(ContextMenu) then
--         error("UIContextMenu: Invalid argument to addSubmenu() - required object of class UIContextMenu.")
--     end

--     self:addOption(text, function() ContextMenu:spawn() end)
--     -- TODO:
-- end

function UIContextMenu:mousePressed(x, y, button)
end

-- spawns menu at given x and y (screen coordinates)
function UIContextMenu:spawn(x, y)
    if self:requestFocus() then
        x, y = self:toRelativeCoordinates(x, y)
        local minx, miny = self:toRelativeCoordinates(self._availAABB[1].x, self._availAABB[1].y)
        local maxx, maxy = self:toRelativeCoordinates(self._availAABB[2].x, self._availAABB[2].y)        
        self.flags.hidden = false
        self.style.origin.x = max(miny, min(x, maxx-self:getWidth())) -- max(0, min(self._availAABB:getWidth() - self:getWidth(), x))
        self.style.origin.y = max(minx, min(y, maxy-self:getHeight())) -- max(0, min(self._availAABB:getHeight() - self:getHeight(), y))
    end
end

function UIContextMenu:despawn()
    self:requestDropFocus(self)
end

function UIContextMenu:requestDropFocus(requestingWidget)
    self:dropFocus()
    if not self:isSuboption(requestingWidget) then
        self.flags.hidden = true
    end
    return true
end

function UIContextMenu:isSuboption(widget)
    return self._suboptions[widget]
end

function UIContextMenu:renderer()
    love.graphics.setColor(self.style.theme.bg:normalized())
    love.graphics.rectangle("fill", 0, 0, self:getWidth(), self:getHeight())
end

return setmetatable(
    UIContextMenu,
    {
        __index = UIWidget,
        __call = function(_, ...)
            local ok, ret = pcall(UIContextMenu.new, ...)
            if ok then
                return ret
            else
                error("UIContextMenu: " .. ret)
            end
        end
    }
)
