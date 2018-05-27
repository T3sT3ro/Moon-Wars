local ResourceManager = {}
local _assets = {}

function ResourceManager.init(resourcesFolderPath)
    local assets = love.filesystem.getDirectoryItems(resourcesFolderPath)
    for _, file in ipairs(assets) do
        local dotPos = file:find("%.")
        local assetName = file:sub(1, dotPos-1)
        local extension = file:sub(dotPos+1)
        ResourceManager.load(assetName, extension, resourcesFolderPath)
    end
end

function ResourceManager.clear()
    _assets = {}
end

function ResourceManager.load(assetName, extension, path)
    path = path or ""
    local fullPath = path .. "/" .. assetName .. "." .. extension
    local asset = love.graphics.newImage(fullPath)

    print("Asset: " .. assetName .. " loaded from path: " .. fullPath)
    _assets[assetName] = asset
end

function ResourceManager.unloadAsset(assetName)
    _assets[assetName] = nil
end

function ResourceManager.get(assetName)
    local asset = _assets[assetName]
    if asset == nil then error("Asset with name " .. assetName .. " was not loaded!") end
    return asset
end

return ResourceManager