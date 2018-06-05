-- Color module
local Color = {}
local floor = math.floor
local min, max = math.min, math.max

Color.__index = Color

function Color.isColor(o)
    return getmetatable(o) == Color
end

function Color.new(r, g, b, a)
    if Color.isColor(r) then -- copy constructor
        r, g, b, a = r.r, r.g, r.b, r.a
    end
    r, g, b, a = (r or 0), (g or 0), (b or 0), (a or 255)
    if type(r) == "string" then
        local hex = r
        r, g, b, a =
            string.match(string.upper(hex), "#([0-9A-F][0-9A-F])([0-9A-F][0-9A-F])([0-9A-F][0-9A-F])([0-9A-F][0-9A-F])")
        if r == nil then
            r, g, b = string.match(string.upper(hex), "#([0-9A-F][0-9A-F])([0-9A-F][0-9A-F])([0-9A-F][0-9A-F])")
            a = "FF"
        end
        if r == nil then
            error("Color: malformed hex")
        end
        r, g, b, a = floor(("0x" .. r) + 0), floor(("0x" .. g) + 0), floor(("0x" .. b) + 0), floor(("0x" .. a) + 0)
    end
    if type(r) ~= "number" or type(g) ~= "number" or type(b) ~= "number" or type(a) ~= "number" then
        error("Color: parameters r,g,b[,a] must be numbers in range [0,255], [0.0,1.0] or properly formatted hex.")
    end
    local t = {__index = Color, r = r % 256, g = g % 256, b = b % 256, a = a % 256}
    return setmetatable(t, Color)
end

function Color:toHex()
    return string.format("#%02x%02x%02x%02x", self.r, self.g, self.b, self.a)
end

function Color:toRGBA()
    return self.r, self.g, self.b, self.a
end

function Color:normalized()
    return self.r / 255, self.g / 255, self.b / 255, self.a / 255
end

function Color:modComponent(dr, dg, db, da)
    self.r = max(min(self.r + dr, 255), 0)
    self.g = max(min(self.g + dg, 255), 0)
    self.b = max(min(self.b + db, 255), 0)
    self.a = max(min(self.a + da, 255), 0)
end

return setmetatable(
    Color,
    {
        __call = function(_, ...)
            return Color.new(...)
        end
    }
)
