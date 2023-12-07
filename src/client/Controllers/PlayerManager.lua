Knit = _G.Core.Knit
Signal = _G.Core.Signal

-- Imports
local _type = require(script.Parent.Parent.TypeDefs)
local Database: _type.Database

PlayerManager = Knit.CreateController {
    Name = "PlayerManager",    
}
PlayerManager.__index = PlayerManager

function PlayerManager:Init()
    Database = Knit.GetController("Database")
end

function PlayerManager.new(UserId: number, playerType: string, meshPart: MeshPart?)
    assert(UserId, "PlayerID must be provided")
    assert(type(UserId) == "number", "UserId must be a number")
    assert(playerType, "playerType must be provided")
    assert(type(playerType) == "string", "playerType must be a string")
    
    local self = setmetatable({}, PlayerManager)
    
    self.UserId = UserId
    self.Type = playerType
    self.Alive = true
    self.Votes = 0
    self.Role = false

    if self.Type == "npc" then
        self.Part = meshPart
        meshPart:SetAttribute("UserId", UserId)
    end

    return self
end

function PlayerManager:AssignLiveRole(roleName: string)
    assert(roleName, "roleName must be provided")
    assert(type(roleName) == "string", "roleName must be a string")

    self.Role = Database.Roles[roleName]
    Database.Players[self.UserId] = self
end

function PlayerManager:IncrementVotes()
    self.Votes = self.Votes + 1
end

function PlayerManager:ResetVotes()
    self.Votes = 0
end

function PlayerManager:Kill()
    self.Alive = false
    if self.Part then
        self.Part:Destroy()
    end
    Database.Players[self.UserId] = nil
end

function PlayerManager:IsAlive()
    return self.IsAlive
end

return PlayerManager