Core = _G.Core
Knit = Core.Knit
GameConfig = Core.GameConfig

local EntityManager = Knit.CreateController{
    Name = "EntityManager",
}

-- Imports
local _type = require(script.Parent.Parent.TypeDefs)
local PlayerManager, RoleManager, Database: _type.Database

local cache = {
    Players = {}
}

local Game_Scene: Folder = workspace:WaitForChild("Game_Scene")
local NPCs: Folder = Game_Scene:WaitForChild("NPCs")
local LocalPlayer: Player = game:GetService("Players").LocalPlayer

function EntityManager:GetNPCMesh(Id: number)
    return NPCs:WaitForChild("Meshes/npc"..tostring(Id))
end

function EntityManager:SetupPlayer(UserId: number, playerType: string, meshPart: MeshPart?)
    assert(UserId, "UserId must be provided")
    assert(type(UserId) == "number", "UserId must be a number")
    return PlayerManager.new(UserId, playerType, meshPart)
end

function EntityManager:BuildAllPlayers()
    for i = 1, GameConfig.NPCCount do
        local npcID = i
        local npc = self:SetupPlayer(npcID, "npc", self:GetNPCMesh(npcID))
        table.insert(cache.Players, npc)
    end
    local ply = self:SetupPlayer(LocalPlayer.UserId, "player")
    table.insert(cache.Players, ply)
    for i = #cache.Players, 2, -1 do
        local j = math.random(i)
        cache.Players[i], cache.Players[j] = cache.Players[j], cache.Players[i]
    end
end

function EntityManager:FillGameRoles()
    math.randomseed(tick())
    local types = {"Good", "Evil"}
    local function fillRoles(type: string)
        for i=1, GameConfig.Constraints["Min"..type] do
            local randRoleMetadata = RoleManager:GenerateRandomRoleMetadata(type)
            RoleManager.new(randRoleMetadata)
            cache.Players[i]:AssignLiveRole(randRoleMetadata.Name)
            table.remove(cache.Players, i)
        end
    end
    for _, type in ipairs(types) do
        fillRoles(type)
    end
    local lastRandRole = types[math.random(1, #types)]
    local randRoleMetadata = RoleManager:GenerateRandomRoleMetadata(lastRandRole)
    RoleManager.new(randRoleMetadata)
    cache.Players[1]:AssignLiveRole(randRoleMetadata.Name)
    table.remove(cache.Players, 1)
end

function EntityManager:Start()
    PlayerManager = Knit.GetController("PlayerManager")
    RoleManager = Knit.GetController("RoleManager")
    Database = Knit.GetController("Database")

    self:BuildAllPlayers()
    self:FillGameRoles()
end

return EntityManager