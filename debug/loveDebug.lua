local min, max = math.min, math.max
love = {
    keyboard = {},
    mouse = {x = 0, y = 0, wheel = {x = 0, y = 0}},
    scissor = nil,
    graphics = {width = 800, height = 600},
    color = {0, 0, 0, 0}
}
function love.graphics.getWidth()
    print("love.graphics.getWidth():", "~>", love.graphics.width)
    return love.graphics.width
end
function love.graphics.getHeight()
    print("love.graphics.getHeight():", "~>", love.graphics.height)
    return love.graphics.height
end
function love.graphics.points(...)
    print("love.graphics.points():", ...)
end
function love.graphics.rectangle(...)
    print("love.graphics.rectangle():", ...)
end
function love.graphics.draw(...)
    print("love.graphics.draw():", ...)
end
function love.graphics.print(...)
    print("love.graphics.print():", ...)
end
function love.graphics.newImage(...)
    print("love.graphics.newImage():", ...)
end
function love.graphics.newFont(...)
    print("love.graphics.newFont():", ...)
    return ({...})[1]
end
function love.graphics.newText(...)
    print("love.graphics.newText():", ...)
end
function love.graphics.setScissor(x, y, w, h)
    print("love.graphics.setScissor():", x, y, w, h)
    if x ~= nil then
        love.scissor = {x = x, y = y, w = w, h = h}
    else
        love.scissor = nil
    end
end
function love.graphics.intersectScissor(x3, y3, w, h)
    print("love.graphics.setScissor():", x3, y3, w, h)
    if love.scissor == nil then -- as normal scissor
        love.scissor = {x = x3, y = y3, w = w, h = h}
        return
    end
    local x2, y2 = love.scissor.x + love.scissor.w, love.scissor.y + love.scissor.h
    local x4, y4 = x3 + w, y3 + h
    love.scissor.x, love.scissor.y = max(love.scissor.x, x3), max(love.scissor.y, y3)
    love.scissor.w, love.scissor.h = max(0, min(x2, x4) - love.scissor.x), max(0, min(y2, y4) - love.scissor.y)
end
function love.graphics.getScissor()
    print(
        "love.graphics.getScissor():",
        "~>",
        love.scissor and love.scissor.x,
        love.scissor and love.scissor.y,
        love.scissor and love.scissor.w,
        love.scissor and love.scissor.h
    )
end
function love.graphics.setColor(r, g, b, a)
    print(string.format("love.graphics.setColor(): %03f %03f %03f %03f", r, g, b, a))
    love.color = {r, g, b, a}
end
function love.graphics.getColor()
    print("love.graphics.getColor():", "~>", love.color[1], love.color[2], love.color[3], love.color[4])
    return love.color[1], love.color[2], love.color[3], love.color[4]
end
function love.keyboard.isDown(...)
    local t = true
    for _, v in pairs(({...})) do
        t = t and love.keyboard[v]
    end
    print("love.keyboard.isDown():", ..., "~>", t)
    return t
end
function love.mouse.isDown(...)
    print("love.mouse.isDown():", ..., "~>", t)
    local t = true
    for _, v in pairs(({...})) do
        t = t and love.mouse[v]
    end
    return t
end
function love.mouse.getPosition()
    print("love.mouse.getPosition():", "~>", love.mouse.x, love.mouse.y)
    return love.mouse.x, love.mouse.y
end
function love.mouse.getX()
    print("love.mouse.getX():", "~>", love.mouse.x)
    return love.mouse.x
end
function love.mouse.getY()
    print("love.mouse.getY():", "~>", love.mouse.y)
    return love.mouse.y
end
