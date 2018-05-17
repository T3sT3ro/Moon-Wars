local StateManager = {}
local _curState = nil
local _states = {}

function StateManager.add(state)
    _states[state.name] = state
end

function StateManager.load(stateName)
    local state = _states[stateName]
    if _curState ~= nil then
        _curState.clear()
    end

    state.init()
    _curState = state
end

function StateManager.update(dt)
    if _curState ~= nil then
        _curState.update(dt)
    end
end

function StateManager.draw() 
    if _curState ~= nil then
        _curState.draw()
    end
end

return StateManager