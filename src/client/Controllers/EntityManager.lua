Core = _G.Core
Knit = Core.Knit
GameConfig = Core.GameConfig

local EntityManager = Knit.CreateController{
    Name = "EntityManager",
}

local PlayerManager, RoleManager
local PlayersDB -- PlayerManager.PlayersDB

local Game_Scene: Folder = workspace:WaitForChild("Game_Scene")
local NPCs: Folder = Game_Scene:WaitForChild("NPCs")
local LocalPlayer: Player = game:GetService("Players").LocalPlayer

function EntityManager:GetNPCMesh(Id: number)
    return NPCs:WaitForChild("Meshes/npc"..tostring(Id))
end

function EntityManager:SetupPlayer(UserId: number, playerType: string, meshPart: MeshPart?)
    assert(UserId, "UserId must be provided")
    assert(type(UserId) == "number", "UserId must be a number")
    PlayerManager.CreatePlayer(UserId, playerType, meshPart)
end

function EntityManager:BuildAllPlayers()
    for i = 1, GameConfig.NPCCount do
        local npcID = i
        self:SetupPlayer(npcID, "npc", self:GetNPCMesh(npcID))
    end
    self:SetupPlayer(LocalPlayer.UserId, "player")
end

function EntityManager:BuildAllRoles()
    for roleName, roleTable in GameConfig.Roles do
        RoleManager.CreateRole(roleName, roleTable.Behaviour)
    end
end

function EntityManager:AssignPlayersRoles()
    math.randomseed(tick())
    for _, ply in PlayersDB.All do
        ply:AssignRole(RoleManager.GenerateRandomRole())
    end
end

function EntityManager:ListenSignals()
    PlayerManager.PlayerDeactivated:Connect(function(UserId)
        PlayersDB.Alive[UserId] = nil
    end)
end

function EntityManager:Init()
    PlayerManager = Knit.GetController("PlayerManager")
    RoleManager = Knit.GetController("RoleManager")
    PlayersDB = PlayerManager.PlayersDB

    self:BuildAllPlayers()
    self:BuildAllRoles()
    self:AssignPlayersRoles()
    self:ListenSignals()
end

return EntityManager