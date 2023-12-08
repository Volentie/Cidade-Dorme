local Database = _G.Core.Knit.CreateController {
    Name = "Database"
}

Signal = _G.Core.Signal

function Database:KnitInit()
    self.Players = {}
    self.Roles = {}
    self.Goods = {}
    self.Evils = {}

    self.GetPlayerByUserId = function(self, id)
        for _, plyInstance in ipairs(self.Players) do
            if id == plyInstance.UserId then
                return plyInstance
            end
        end
    end

    self.RemovePlayerByValue = function(self, plyInstance, type)
        if type then
            for i, ply in ipairs(self[type .. "s"]) do
                if ply == plyInstance then
                    return table.remove(self[type .. "s"], i), i
                end
            end
        end
        for i, ply in ipairs(self.Players) do
            if ply == plyInstance then
                return table.remove(self.Players, i), i
            end
        end
    end


end

return Database