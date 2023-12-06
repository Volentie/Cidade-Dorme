Signal = _G.Core.Signal

local GameState = _G.Core.Knit.CreateController {
    Name = "GameState"
}
GameState.__index = GameState

function GameState:CreateState(name: string)
    local self = setmetatable({}, GameState)

    self.Name = name
    self.State = buffer.create(1)
    self.Changed = Signal.new()

    return self
end

function GameState:SetState(uint8: number)
    buffer.fill(self.State, 0, uint8)
end

function GameState:GetState()
    return buffer.readu8(self.State, 0)
end

function GameState:Fire()
    self.Changed:Fire(self:GetState())
end

return GameState