local GameLogic = require "game/GameLogic"

local ResourceManager = {}
local _assets = {}
local _patterns = {image = {"png", "jpg", "bmp"}, font = {"ttf", "fnt"}, AI = {"lua"}}

function ResourceManager.init(resourcesFolderPath)
    ResourceManager.loadDir(resourcesFolderPath)
end

function ResourceManager.loadDir(path, assetPrefix)
    local assets = love.filesystem.getDirectoryItems(path)
    for _, file in ipairs(assets) do
        -- file patterns

        if love.filesystem.getInfo(path .. "/" .. file).type == "directory" then -- load directory
            ResourceManager.loadDir(path .. "/" .. file, (assetPrefix and assetPrefix .. "." .. file) or file)
        else -- load file
            for ftype, extensions in pairs(_patterns) do
                for _, ext in pairs(extensions) do
                    local fpath
                    local fname
                    local fext
                    fpath, fname, fext = string.match(path .. "/" .. file, "(.*)[/\\]([^/\\]-)%.(" .. ext .. ")$")
                    -- [prefix.]name

                    -- in place oneline if
                    local assetName = not fname or ((assetPrefix and assetPrefix .. "." .. fname) or fname)
                    fpath = not fpath or ResourceManager.load(assetName, fname, fext, fpath, ftype) -- match if fpath ~= nil
                end
            end
        end
    end
end

function ResourceManager.clear()
    _assets = {}
end

local function encapsuledPrint(assetName)
    return 
        function(...)
            print(assetName .. ": " .. tostring(...))
        end
end

function ResourceManager.load(assetName, fname, fext, fpath, type, ...)
    fpath = fpath or ""
    local path = fpath .. "/" .. fname .. "." .. fext

    local isOK
    local asset

    if type == "image" then -- images
        isOK, asset = pcall(love.graphics.newImage, path, ...)
    elseif type == "font" then -- fonts with size as optional argument (defaults to 12)
        isOK, asset = pcall(love.graphics.newFont, path, ...)
    elseif type == "AI" then
        local file = loadfile(path, "bt", {print = encapsuledPrint(assetName), doAction = GameLogic.doAction})
         -- loading with specified enviroment
        isOK, asset = pcall(file) -- calling script
    end

    if isOK then
        print("ResourceManager: loaded '" .. assetName .. "' from '" .. path .. "'.")
        _assets[assetName] = asset
    else
        print("ResourceManager: couldn't open asset '" .. assetName .. "' from '" .. path .. "'. Details: "..tostring(asset))
    end
end

function ResourceManager.unloadAsset(assetName)
    _assets[assetName] = nil
end

function ResourceManager.get(assetName)
    local asset = _assets[assetName]
    if asset == nil then
        error("ResourceManager: asset '" .. assetName .. "' wasn't loaded!")
    end
    return asset
end

return ResourceManager
