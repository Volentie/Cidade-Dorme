Core = _G.Core
Knit = Core.Knit
GameConfig = Core.GameConfig

local EntityManager = Knit.CreateController{
    Name = "EntityManager",
}

EntityManager.ActivePlayers = {}

local PlayerManager, RoleManager

local Game_Scene = workspace:WaitForChild("Game_Scene")
local NPCs = Game_Scene:WaitForChild("NPCs")
local LocalPlayer = game:GetService("Players").LocalPlayer

function EntityManager:SetupPlayer(UserId: number, isNPC: boolean)
    assert(UserId, "UserId must be provided")
    assert(type(UserId) == "number", "UserId must be a number")
    local plyObj = PlayerManager.CreatePlayer(UserId)
    if isNPC then
        plyObj:SetNPC(NPCs:WaitForChild(UserId))
    end
    self.ActivePlayers[UserId] = plyObj
end

function EntityManager:BuildAllPlayers()
    for i = 1, GameConfig.NPCCount do
        local npcID = i
        self:SetupPlayer(npcID, true)
    end
    self:SetupPlayer(LocalPlayer.UserId)
end

function EntityManager:BuildAllRoles()
    for roleName, roleTable in GameConfig.Roles do
        RoleManager.CreateRole(roleName, roleTable.Behaviour)
    end
end


function EntityManager:AssignPlayersRoles()
    math.randomseed(tick())
    for _, ply in PlayerManager.ActivePlayers do
        ply:AssignRole(RoleManager.GetRandomRole())
    end
end

function EntityManager:ListenSignals()
    PlayerManager.PlayerDeactivated:Connect(function(UserId)
        self.ActivePlayers[UserId] = nil
    end)
end

function EntityManager:Init()
    PlayerManager = Knit.GetController("PlayerManager")
    RoleManager = Knit.GetController("RoleManager")

    self:BuildAllPlayers()
    self:BuildAllRoles()
    self:ListenSignals()
end

return EntityManager