Knit = _G.Core.Knit
Signal = _G.Core.Signal

PlayerManager = Knit.CreateController {
    Name = "PlayerManager",
    PlayersDB = {}
}

PlayerManager.PlayerDeactivated = Signal.new()

function PlayerManager.CreatePlayer(UserId: number)
    assert(UserId, "PlayerID must be provided")
    assert(type(UserId) == "number", "UserId must be a number")
    
    local self = setmetatable({}, PlayerManager)
    
    self.UserId = UserId
    self.IsAlive = true
    self.Votes = 0

    PlayerManager.PlayersDB[UserId] = self

    return self
end

function PlayerManager:AssignRole(Role: table)
    assert(Role, "Role must be provided")
    assert(type(Role) == "table", "Role must be a table")

    self.Role = Role
end

function PlayerManager:SetNPC(meshPart: MeshPart)
    assert(meshPart, "MeshPart must be provided")
    assert(meshPart:IsA("MeshPart"), "MeshPart must be a MeshPart")

    self.NPC = meshPart
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