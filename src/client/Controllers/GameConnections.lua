local GameConnections = _G.Core.Knit.CreateController {
    Name = "GameConnections",
    Connections = {}
}

function GameConnections:Append(name, callback)
    assert(name, "Name for the connection must be provided")
    assert(callback, "Callback for the connection must be provided")
    assert(type(callback) == "function", "Callback must be a function")
    self.Connections[name] = {Callback = callback}
end

function GameConnections:Connect(name, service, eventName)
    assert(self.Connections[name], "Connection named " .. name .. " not found")
    assert(eventName, "Event name must be provided")
    local gameService = game:GetService(service)
    assert(gameService, "Service " .. service .. " not found")
    local event = gameService[eventName]
    assert(event, "Event " .. eventName .. " not found in service " .. service)

    local callback = self.Connections[name].Callback
    self.Connections[name]["Connection"] = event:Connect(callback)
end

function GameConnections:Disconnect(name)
    assert(self.Connections[name], "Connection named " .. name .. " not found")
    self.Connections[name].Connection:Disconnect()
    self.Connections[name].Connection = nil
end

return GameConnections