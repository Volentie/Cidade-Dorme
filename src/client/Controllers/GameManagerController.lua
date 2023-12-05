Core = _G.Core
Knit = Core.Knit

local GameManagerController = Knit.CreateController {
    Name = "GameManagerController"
}

function GameManagerController:Start()
    local GameStateController = Knit.GetController("GameStateController")
    local GameConnectionsController = Knit.GetController("GameConnectionsController")
    local GameLoopController = Knit.GetController("GameLoopController")

    -- Create game run state
    self.RunState = GameStateController:CreateState("RunState")
    -- Create game loop connection
    GameConnectionsController:Append("GameLoop", GameLoopController.Loop)

    -- Listen for state changes and connect/disconnect the game loop
    self.RunState.Changed:Connect(function(state)
        if state == 1 then
            GameConnectionsController:Connect("GameLoop", "Heartbeat")
        else
            GameConnectionsController:Disconnect("GameLoop")
        end
    end)

    -- Run the game
    self:Run()
end

function GameManagerController:Run()
    self.RunState:SetState(1)
    self.RunState:Fire()
end

function GameManagerController:Stop()
    self.RunState:SetState(0)
    self.RunState:Fire()
end

return GameManagerController