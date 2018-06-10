local function changeStat(...)
    local stats = {...}
    return 
    function(unit, args)
        local mult = 1
        if args and args.unequip then
            mult = -1 * mult
        end
        for i = 1, #stats, 2 do
            local statName = stats[i]
            local changeValue = stats[i+1] 
            if not unit[statName] then
                print("ERROR: unit has not stat: " .. statName)
            else
                unit[statName]  = unit[statName] + mult * changeValue      
            end
        end
    end
end

local function craftMat(...)
    local args = {...}
    local materials = {}
    for i = 1, #args do
        materials[#materials + 1] = {args[i], args[i+1]}
    end
    return materials
end

local Items = 
{
    {
        name = "dagger", -- if there is no assetName, name itself will be used
        itemType = "weapon", 
        onUse = changeStat("attack", 10),
        toCraft = craftMat("wood", 2, "stone", 1)
    },

    {
        name = "sword",
        itemType = "weapon", 
        assetName = "dagger2", 
        onUse = changeStat("attack", 20),
        toCraft = craftMat("wood", 1, "stone", 2)
    },

    {
        name = "bow",
        itemType = "weapon",  
        onUse = changeStat("attack", 10, "range", 1),
        toCraft = craftMat("wood", 3, "stone", 1)
    },

    {
        name = "lightArmor",
        itemType = "armor",  
        onUse = changeStat("defense", 1),
        toCraft = craftMat("wood", 2)
    },

    {
        name = "heavyArmor",
        itemType = "armor",  
        onUse = changeStat("defense", 3, "movePenalty", 1),
        toCraft = craftMat("stone", 2)
    },

    {
        name = "smallHealthPotion",
        assetName = "potion", 
        itemType = "potion",  
        onUse = changeStat("health", 50),
        toCraft = craftMat("crystal", 1)
    },

    {
        name = "bigHealthPotion",
        assetName = "potion", 
        itemType = "potion",  
        onUse = changeStat("health", 150),
        toCraft = craftMat("crystal", 2)
    },
    

    {
        name = "magicRing",
        itemType = "artifact",  
        onUse = changeStat("attack", 5, "defense", 5, "movePenalty", -2),
        toCraft = nil -- can not be crafted
    },

}

return Items