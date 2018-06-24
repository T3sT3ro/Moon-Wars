local AI = {}

function AI.makeMove(unit, logic, map)
    print("making move for unit " .. unit.id)
    unit:debugInfo()
    doAction("endTurn")
end

return AI