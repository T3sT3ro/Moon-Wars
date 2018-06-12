local MainMenuState = {name = "MainMenuState"}

function MainMenuState.init()
    love.graphics.setColor(1,1,1,1)
end

function MainMenuState.clear()
end

function MainMenuState.update(dt)
    if love.keyboard.isDown('lalt') and love.keyboard.isDown('d') then 
        StateManager.load(UIDebugState.name)
    end
end

function MainMenuState.draw()
   love.graphics.print("MainMenu State", 500, 300)
end

return MainMenuState
