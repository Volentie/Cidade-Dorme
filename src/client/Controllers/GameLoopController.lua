Core = _G.Core
Knit = Core.Knit

local GameLoopController = Knit.CreateController{
    Name = "GameLoopController"
}

function GameLoopController.Loop()
    local stateController = Knit.GetController("GameStateController")
    local turnState = stateController:CreateState("TurnState")
    turnState:SetState(0)
    
    -- Start
    print(turnState:GetState())

    task.wait(0.5)
end

return GameLoopController