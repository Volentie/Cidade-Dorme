Core = _G.Core
Knit = Core.Knit
GameConfig = Core.GameConfig

local RoleManager = Knit.CreateController {
    Name = "RoleManager",
    RolesDB = {
        Count = {
            Good = 0,
            Evil = 0
        },
        DB = {}
    }
}

function RoleManager.CreateRole(RoleName: string, roleBehaviour: () -> ())
    assert(RoleName, "RoleName must be provided")
    assert(roleBehaviour, "roleBehaviour must be provided")
    assert(type(RoleName) == "string", "RoleName must be a string")
    assert(type(roleBehaviour) == "function", "roleBehaviour must be a function")

    local self = setmetatable({}, RoleManager)
    
    self.RoleName = RoleName
    self.RoleBehaviour = roleBehaviour
    self.IsAssigned = false

    RoleManager.RoleDB.DB[RoleName] = self
    
    return self
end

function RoleManager.GenerateRandomRole()
    local iterationAttempts = 0
    local maxAttempts = 100
    local pass = false
    local roleType, roleName

    while not pass and iterationAttempts <= maxAttempts do
        roleName = GameConfig.Roles.Meta[math.random(1, #GameConfig.Roles.Meta)]
        roleType = GameConfig.Roles[roleName].Type
        pass = RoleManager.RoleDB.Count[roleType] < GameConfig.Constraints["Max"..roleType]
        iterationAttempts = iterationAttempts + 1
    end

    if pass then
        RoleManager.RoleDB.Count[roleType] = RoleManager.RoleDB.Count[roleType] + 1
        return RoleManager.RoleDB.DB[roleName]
    else
        return false
    end
end


-- Implement additional methods here...

return RoleManager