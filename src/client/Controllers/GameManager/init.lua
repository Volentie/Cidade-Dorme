Core = _G.Core
Knit = Core.Knit

local GameManager = Knit.CreateController {
    Name = "GameManager"
}

function GameManager:LoadGameHandlers()
    for _, moduleScript in ipairs(script:GetChildren()) do
        local handler = require(moduleScript)
        if handler["Connect"] then
            handler:Connect()
        end
    end
end

function GameManager:ConfigurePlayer()
    local Players = game:GetService("Players")
    local ply = Players.LocalPlayer
    local char = ply.Character or ply.CharacterAdded:Wait()
    local humanoid = char:WaitForChild("Humanoid")

    char:WaitForChild("HumanoidRootPart").Anchored = true
    char:PivotTo(CFrame.new(0, 999, 0))

    humanoid.WalkSpeed = 0
    humanoid.JumpPower = 0
end

function GameManager:Init()
    self:LoadGameHandlers()
    self:ConfigurePlayer()
end

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
            GameConnections:Connect("GameLoop", "RunService", "Heartbeat")
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