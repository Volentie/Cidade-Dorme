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
    }
end

-- Load all controllers
function LoadControllers()
    local controllers = script.Parent.Controllers:GetChildren()
    for _, controller in controllers do
        if controller:IsA("ModuleScript") then
            local moduleTable = require(controller)
            assert(type(moduleTable) == "table", "Module must return a table")
            Controllers[moduleTable.Name] = moduleTable
        end
    end
end

function StartControllers()
    for _, controller in Controllers do
        if controller.Start then
            controller:Start()
        end
    end
end

function Boot()
    InitializateCore()
    Knit.Start():catch(warn)
    LoadControllers()
    StartControllers()
end

Boot()