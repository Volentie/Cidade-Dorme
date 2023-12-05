PlayerManager = _G.Core.Knit.CreateController {
    Name = "PlayerManager",
    ActivePlayers = {}
}

function PlayerManager.CreatePlayer(PlayerID: string)
    assert(PlayerID, "PlayerID must be provided")
    assert(type(PlayerID) == "string", "PlayerID must be a string")
    
    local self = setmetatable({}, PlayerManager)
    
    self.PlayerID = PlayerID
    self.IsAlive = true

    PlayerManager.ActivePlayers[PlayerID] = true

    return self
end

function PlayerManager:DeactivatePlayer()
    self.IsAlive = false
    PlayerManager.ActivePlayers[self.PlayerID] = nil
end

function PlayerManager:IsAlive()
    return self.IsAlive
end

return PlayerManager