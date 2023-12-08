local GameManager = _G.Core.Knit.CreateController {
    Name = "GameManager"
}

GameConfig = _G.Core.GameConfig
local Settings = GameConfig.GameSettings

-- Services
local TweenService = game:GetService("TweenService")

-- Imports
local GameConnections, GameLoop

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

function GameManager:CreateTween(TweenConfig: table)
    local info = TweenInfo.new(TweenConfig.Time, TweenConfig.Style)
    return TweenService:Create(TweenConfig.Object, info, TweenConfig.Props)
end

function GameManager:SetInitialGameSettings()
    for service, serviceTab in Settings.InitialConfigs.Services do
        for obj, props in serviceTab do
            local gameService = game:GetService(service)
            for prop, value in props do
                gameService[obj][prop] = value
            end
        end
    end
end

function GameManager:KnitInit()
    GameConnections = _G.Core.Knit.GetController("GameConnections")
    GameLoop = _G.Core.Knit.GetController("GameLoop")

    local StarterGui = game:GetService("StarterGui")
    StarterGui:SetCoreGuiEnabled(Enum.CoreGuiType.All, false)
    
    self:LoadGameHandlers()
    self:ConfigurePlayer()
    self:SetInitialGameSettings()
end

function GameManager:KnitStart()
    -- Run the game
    self:Run()
end

function GameManager:Run()
    local function startGame()
        warn("loop has started")
        GameLoop.Event:Fire(true)
    end

    local fadeTween = GameConnections:Append("StartFade", startGame, self:CreateTween(Settings.Tweens.Blur))
    GameConnections:ConnectOnce("StartFade", "Completed")
    fadeTween:Play()
end

return GameManager