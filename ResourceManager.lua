local ResourceManager = {}
local _assets = {}

function ResourceManager.init(resourcesFolderPath)
    local assets = love.filesystem.enumerate(resourcesFolderPath)
    for k, file in ipairs(files) do
        print(k .. ". " .. file) --outputs something like "1. main.lua"
    end
end

function ResourceManager.clear()
    _assets = {}
end

function ResourceManager.load(assetName, extension, path)
    path = path or ""
    local fullPath = path .. "/" .. assetName .. "." .. extension
    _assets[assetName] = love.graphics.newImage(fullPath)
end

function ResourceManager.unload(assetName)
    _assets[assetName] = nil
end

function ResourceManager.get(assetName)
    local asset = _assets[assetName]
    if asset == nil then error("Asset with name " .. assetName .. "was not loaded!") end
    return asset
end

return ResourceManager