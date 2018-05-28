local ResourceManager = {}
local _assets = {}

function ResourceManager.init(resourcesFolderPath)
    local assets = love.filesystem.getDirectoryItems(resourcesFolderPath)
    for _, file in ipairs(assets) do
        local dotPos = file:find("%.")
        local assetName = file:sub(1, dotPos-1)
        local extension = file:sub(dotPos+1)
        ResourceManager.load(assetName, extension, resourcesFolderPath, true)
    end
end

function ResourceManager.clear()
    _assets = {}
end

function ResourceManager.load(assetName, extension, path, notShowError)
    path = path or ""
    local fullPath = path .. "/" .. assetName .. "." .. extension
    local isOpen, asset = pcall(love.graphics.newImage, fullPath)
    if isOpen then
        print("Asset: " .. assetName .. " loaded from path: " .. fullPath)
        _assets[assetName] = asset
    elseif not notShowError then
        print("Asset: " .. assetName .. " at path: " .. fullPath .. " not open because: " .. asset)
    end
end

function ResourceManager.unloadAsset(assetName)
    _assets[assetName] = nil
end

function ResourceManager.get(assetName)
    local asset = _assets[assetName]
    if asset == nil then error("Asset with name " .. assetName .. " was not loaded!") end
    return asset
end

function ResourceManager.loadAI()
    local file = loadfile("AItest.lua", "bt", {print = print }) -- loading with specified enviroment
    local isOk, ai = pcall(file) -- calling script
    if not isOk then
        print("AI loading failed, error: " .. ai)
        return
    end

    print(pcall(ai.foo)) -- calling function in script
end

return ResourceManager