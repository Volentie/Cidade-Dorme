local RoleManager = _G.Core.Knit.CreateController {
    Name = "RoleManager"
}
RoleManager.__index = RoleManager

Signal = _G.Core.Signal
GameConfig = _G.Core.GameConfig

-- Imports
local _type = require(script.Parent.Parent.TypeDefs)
local Database: _type.Database

function RoleManager:KnitInit()
    Database = _G.Core.Knit.GetController("Database")
end

function RoleManager.new(roleMeta: table)
    assert(roleMeta and type(roleMeta) == "table", "roleMeta must be provided and must be a table")

    local self = setmetatable({}, RoleManager)
    
    self.Name = roleMeta.Name
    self.Behaviour = roleMeta.Behaviour
    self.Type = roleMeta.Type

    Database.Roles[self.Name] = self
    
    return self
end

function RoleManager:GenerateRandomRoleMetadata(Type: string)
    local randKey = GameConfig.RolesMeta[Type][math.random(1, #GameConfig.RolesMeta[Type])]
    local role = GameConfig.Roles[Type][randKey]
    return role
end

return RoleManager