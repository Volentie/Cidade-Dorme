Signal = _G.Core.Signal

local GameStateController = _G.Core.Knit.CreateController {
    Name = "GameStateController"
}
GameStateController.__index = GameStateController

function GameStateController:CreateState(name: string)
    local self = setmetatable({}, GameStateController)

    self.Name = name
    self.State = buffer.create(1)
    self.Changed = Signal.new()

    return self
end

function GameStateController:SetState(uint8: number)
    buffer.fill(self.State, 0, uint8)
end

function GameStateController:GetState()
    return buffer.readu8(self.State, 0)
end

function GameStateController:Fire()
    self.Changed:Fire(self:GetState())
end

return GameStateController