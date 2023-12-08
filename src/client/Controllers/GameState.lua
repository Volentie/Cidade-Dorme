-- I was using the new buffer type here, dealing with bytes, but I found that it became too redundant in this small project
-- Actually, this module is not even neccessary, but I'll keep it for how it should be, in terms of structure

local GameState = _G.Core.Knit.CreateController {
    Name = "GameState"
}

Signal = _G.Core.Signal

local proxy = {
    __index = function(_, idx, ...)
        if idx == "Set" then
            return function(self, state)
                self.State = state
            end
        elseif idx == "Get" then
            return function(self)
                return self.State
            end
        elseif idx == "Fire" then
            return function(self)
                self.Changed:Fire(self.State)
            end
        end
        return rawget(GameState, idx)
    end
}

function GameState:CreateState(name: string)
    local self = setmetatable({}, proxy)

    self.Name = name
    self.Changed = Signal.new()
    self.State = nil

    return self
end

return GameState