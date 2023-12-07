Core = _G.Core
Knit = Core.Knit

local CameraHandler = {}

local UserInputService = game:GetService("UserInputService")
local Players = game:GetService("Players")
local LocalPlayer = Players.LocalPlayer
local Mouse = LocalPlayer:GetMouse()
local GameConnections = Knit.GetController("GameConnections")
local Camera = game.Workspace.CurrentCamera

-- Camera settings
local basePosition = Vector3.new(0, 4, 17.5)
local baseFocus = Vector3.new(0.07, 4.2, -6.597)
local sensitivity = 0.005
local maxYaw = math.rad(90)
local maxPitch = math.rad(90)
local currentYaw, currentPitch = 0, 0

function CameraHandler:Setup()
    Mouse.Icon = "rbxassetid://15562539376"
    UserInputService.MouseBehavior = Enum.MouseBehavior.LockCenter
    Camera.CameraType = Enum.CameraType.Scriptable

    function CameraHandler:UpdateCamera()
        local mouseDelta = UserInputService:GetMouseDelta()
        
        -- Calculate yaw and pitch change
        local yawChange = mouseDelta.X * sensitivity
        local pitchChange = mouseDelta.Y * sensitivity
    
        -- Update current yaw and pitch with clamping
        currentYaw = math.clamp(currentYaw + yawChange, -maxYaw, maxYaw)
        currentPitch = math.clamp(currentPitch + pitchChange, -maxPitch, maxPitch)
    
        -- Apply rotation while maintaining the original position
        local newOrientation = CFrame.Angles(currentPitch, currentYaw, 0):ToObjectSpace()
        Camera.CFrame = CFrame.new(basePosition) * newOrientation
        -- We need to update this as well, otherwise it goes crazy for some reason
        Camera.Focus = CFrame.new(baseFocus)
    end

    function CameraHandler:Connect()
        GameConnections:Append("CameraHandler", CameraHandler.UpdateCamera)
        GameConnections:Connect("CameraHandler", "RunService", "RenderStepped")
    end
end

CameraHandler:Setup()

return CameraHandler