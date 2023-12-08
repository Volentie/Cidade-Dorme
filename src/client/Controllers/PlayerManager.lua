PlayerManager = _G.Core.Knit.CreateController {
    Name = "PlayerManager",    
}
PlayerManager.__index = PlayerManager

Signal = _G.Core.Signal

-- Imports
local _type = require(script.Parent.Parent.TypeDefs)
local Database: _type.Database

function PlayerManager:KnitInit()
    Database = _G.Core.Knit.GetController("Database")
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
    table.insert(Database.Players, self)
    print(self.Role.Name .. " assigned to " .. self.UserId, "type " .. self.Role.Type)
    table.insert(Database[self.Role.Type .. "s"], self)
end

function PlayerManager:IncrementVotes()
    self.Votes = self.Votes + 1
end

function PlayerManager:ResetVotes()
    self.Votes = 0
end

function PlayerManager:Kill()
    if self.Type == "npc" then
        self.Part:Destroy()
    end
    
    self.Alive = false
    Database:RemovePlayerByValue(self)
    Database:RemovePlayerByValue(self, self.Role.Type)
end

function PlayerManager:IsAlive()
    return self.IsAlive
end

return PlayerManager