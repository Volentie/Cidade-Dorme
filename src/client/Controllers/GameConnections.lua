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

function GameConnections:Connect(name, eventName)
    assert(self.Connections[name], "Connection named " .. name .. " not found")
    assert(eventName, "Event name must be provided")
    local runService = game:GetService("RunService")
    assert(runService[eventName], "Event named " .. eventName .. " is not a valid Roblox event")

    local callback = self.Connections[name].Callback
    self.Connections[name]["Connection"] = runService[eventName]:Connect(callback)
end

function GameConnections:Disconnect(name)
    assert(self.Connections[name], "Connection named " .. name .. " not found")
    self.Connections[name].Connection:Disconnect()
    self.Connections[name].Connection = nil
end

return GameConnections