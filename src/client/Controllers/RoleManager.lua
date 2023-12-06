Core = _G.Core
Knit = Core.Knit
GameConfig = Core.GameConfig

local RoleManager = Knit.CreateController {
    Name = "RoleManager"
}

RoleManager.RolesDB = {
    Count = {
        Good = 0,
        Evil = 0
    },
    DB = {}
}

function RoleManager.CreateRole(RoleName: string, roleBehaviour: table)
    assert(RoleName, "RoleName must be provided")
    assert(roleBehaviour, "roleBehaviour must be provided")
    assert(type(RoleName) == "string", "RoleName must be a string")
    assert(type(roleBehaviour) == "table", "roleBehaviour must be a table")

    local self = setmetatable({}, RoleManager)
    
    self.RoleName = RoleName
    self.RoleBehaviour = roleBehaviour

    RoleManager.RolesDB.DB[RoleName] = self
    
    return self
end

function RoleManager.GenerateRandomRole()
    local iterationAttempts = 0
    local maxAttempts = 100
    local pass = false
    local roleType, roleName

    while not pass and iterationAttempts <= maxAttempts do
        roleName = GameConfig.RolesMeta[math.random(1, #GameConfig.RolesMeta)]
        roleType = GameConfig.Roles[roleName].Type
        pass = RoleManager.RolesDB.Count[roleType] < GameConfig.Constraints["Max"..roleType]
        iterationAttempts = iterationAttempts + 1
    end

    if pass then
        RoleManager.RolesDB.Count[roleType] = RoleManager.RolesDB.Count[roleType] + 1
        return RoleManager.RolesDB.DB[roleName]
    else
        return false
    end
end

return RoleManager