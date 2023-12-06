Core = _G.Core
Knit = Core.Knit

local GameManager = Knit.CreateController {
    Name = "GameManager"
}

function GameManager:Start()
    local GameState = Knit.GetController("GameState")
    local GameConnections = Knit.GetController("GameConnections")
    local GameLoop = Knit.GetController("GameLoop")

    -- Create game run state
    self.RunState = GameState:CreateState("RunState")
    -- Create game loop connection
    GameConnections:Append("GameLoop", GameLoop.Loop)

    -- Listen for state changes and connect/disconnect the game loop
    self.RunState.Changed:Connect(function(state)
        if state == 1 then
            GameConnections:Connect("GameLoop", "Heartbeat")
        else
            GameConnections:Disconnect("GameLoop")
        end
    end)

    -- Run the game
    self:Run()
end

function GameManager:Run()
    self.RunState:SetState(1)
    self.RunState:Fire()
end

function GameManager:Stop()
    self.RunState:SetState(0)
    self.RunState:Fire()
end

return GameManager