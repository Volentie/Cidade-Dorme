Core = _G.Core
Knit = Core.Knit
Signal = Core.Signal

local Database = Knit.CreateController {
    Name = "Database"
}

function Database:Init()
    self.Players = {}
    self.Roles = {}
end

return Database