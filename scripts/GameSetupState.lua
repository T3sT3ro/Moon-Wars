local GameSetupState = {}
GameSetupState.name = "GameSetupState"

function GameSetupState.init()

end

function GameSetupState.clear()

end

function GameSetupState.update(dt)

end

function GameSetupState.draw()
    love.graphics.print("GameSetupState draw", 500, 300)
end

return GameSetupState