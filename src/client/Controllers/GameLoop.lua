Core = _G.Core
Knit = Core.Knit

-- Import
local _type = require(script.Parent.Parent.TypeDefs)

local GameLoop = Knit.CreateController{
    Name = "GameLoop"
}

local GameState, turnState, Database: _type.Database

function GameLoop:Init()
    GameState = Knit.GetController("GameState")
    turnState = GameState:CreateState("TurnState")
    Database = Knit.GetController("Database")
end

function GameLoop:AlterTime(time)
    turnState:SetState(time == "day" and 0 or 1)
end

function GameLoop.Loop()

    --print(10)
    GameLoop:AlterTime("day")


    task.wait(10)
end

return GameLoop