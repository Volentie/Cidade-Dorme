Core = _G.Core
Knit = Core.Knit

local RoleController = Knit.CreateController {
    Name = "RoleController"
}

function RoleController.CreateRole(RoleName: string, roleBehaviour: () -> ())
    assert(RoleName, "RoleName must be provided")
    assert(roleBehaviour, "roleBehaviour must be provided")
    assert(type(RoleName) == "string", "RoleName must be a string")
    assert(type(roleBehaviour) == "function", "roleBehaviour must be a function")

    local self = setmetatable({}, RoleController)
    
    self.RoleName = RoleName
    self.RoleBehaviour = roleBehaviour
    
    return self
end

-- Implement additional methods here...

return RoleController