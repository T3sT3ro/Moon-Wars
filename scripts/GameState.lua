local GameState = {}
GameState.name = "GameState"

function GameState.init()

end

function GameState.clear()

end

function GameState.update(dt)

end

function GameState.draw()
    love.graphics.print("GameState draw", 500, 300)
end

return GameState