Knit = _G.Core.Knit
Signal = _G.Core.Signal

PlayerManager = Knit.CreateController {
    Name = "PlayerManager",    
}

PlayerManager.__index = PlayerManager

PlayerManager.PlayersDB = {
    All = {},
    Alive = {}
}
PlayerManager.PlayerDeactivated = Signal.new()

function PlayerManager.AddPlayerToDB(UserId: number, playerInstance: table)
    PlayerManager.PlayersDB.All[UserId] = playerInstance
    PlayerManager.PlayersDB.Alive[UserId] = playerInstance
end

function PlayerManager.CreatePlayer(UserId: number, playerType: string, meshPart: MeshPart?)
    assert(UserId, "PlayerID must be provided")
    assert(type(UserId) == "number", "UserId must be a number")
    assert(playerType, "playerType must be provided")
    assert(type(playerType) == "string", "playerType must be a string")
    
    local self = setmetatable({}, PlayerManager)
    
    self.UserId = UserId
    self.IsAlive = true
    self.Votes = 0
    self.Type = playerType

    if self.Type == "npc" then
        self.Part = meshPart
    end

    PlayerManager.AddPlayerToDB(UserId, self)

    return self
end

function PlayerManager:AssignRole(Role: table)
    assert(Role, "Role must be provided")
    assert(type(Role) == "table", "Role must be a table")

    self.Role = Role
end

function PlayerManager:IncrementVotes()
    self.Votes = self.Votes + 1
end

function PlayerManager:ResetVotes()
    self.Votes = 0
end

function PlayerManager:DeactivatePlayer()
    self.IsAlive = false
    self.PlayerDeactivated:Fire(self.UserId)
end

function PlayerManager:IsAlive()
    return self.IsAlive
end

return PlayerManager