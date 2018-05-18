local MainMenuState = {}
MainMenuState.name = "MainMenuState"

function MainMenuState.init()

end

function MainMenuState.clear()

end

function MainMenuState.update(dt)

end

function MainMenuState.draw()
    love.graphics.print("MainMenu State", 500, 300)
end

return MainMenuState