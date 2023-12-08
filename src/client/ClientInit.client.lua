-- Path
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Packages = ReplicatedStorage.Packages
local Knit = require(Packages.knit)
local Signal = require(Packages.Signal)

-- Controllers table
local Controllers = {}

function InitializateCore()
    _G.Core = {
        Knit = Knit,
        Signal = Signal,
        GameConfig = require(script.Parent.Metadata:WaitForChild("GameConfig")),
    }
end

function Boot()
    InitializateCore()
    Knit.AddControllers(script.Parent.Controllers)
    Knit.Start():andThen(function()
        warn("Knit initialized")
    end):catch(warn)
end

Boot()