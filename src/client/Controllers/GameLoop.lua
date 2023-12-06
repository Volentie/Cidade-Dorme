Core = _G.Core
Knit = Core.Knit

local GameLoop = Knit.CreateController{
    Name = "GameLoop"
}

function GameLoop.Loop()
    local GameState = Knit.GetController("GameState")
    local turnState = GameState:CreateState("TurnState")
    turnState:SetState(0)
    
    -- Start
    print(turnState:GetState())

    task.wait(0.5)
end

return GameLoop