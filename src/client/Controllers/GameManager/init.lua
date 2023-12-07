Core = _G.Core
Knit = Core.Knit
GameConfig = Core.GameConfig
local Settings = GameConfig.GameSettings

local GameManager = Knit.CreateController {
    Name = "GameManager"
}

-- Services
local RunService = game:GetService("RunService")
local TweenService = game:GetService("TweenService")

-- Imports
local GameState, GameConnections, GameLoop

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

function GameManager:Init()
    self:LoadGameHandlers()
    self:ConfigurePlayer()
    self:SetInitialGameSettings()
end

function GameManager:Start()
    GameConnections = Knit.GetController("GameConnections")
    GameLoop = Knit.GetController("GameLoop")

    -- Run the game
    self:Run()
end

function GameManager:Run()
    local function startGame()
        print("loop has started")
        GameLoop.Event:Fire(true)
    end

    local fadeTween = GameConnections:Append("StartFade", startGame, self:CreateTween(Settings.Tweens.Blur))
    GameConnections:ConnectOnce("StartFade", "Completed")
    fadeTween:Play()
end

return GameManager