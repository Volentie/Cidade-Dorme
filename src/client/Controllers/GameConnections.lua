local GameConnections = _G.Core.Knit.CreateController {
    Name = "GameConnections",
    Connections = {}
}

function GameConnections:AssertDefaults(...)
    local name = select(1, ...)
    local connectionName = select(2, ...)
    local eventName = select(3, ...)
    assert(name, "Name for the connection must be provided")
    assert(type(name) == "string", "Name must be a string")

    if connectionName then
        assert(self.Connections[name], "Connection named " .. name .. " not found")
    end
    if eventName then
        assert(eventName, "Event name must be provided")
        assert(type(eventName) == "string", "Event name must be a string")
    end
end

function GameConnections:Append(name, callback, service: RBXScriptSignal?)
    self:AssertDefaults(name)
    assert(callback, "Callback for the connection must be provided")
    assert(type(callback) == "function", "Callback must be a function")
    self.Connections[name] = {Callback = callback}
    if service then
        self.Connections[name]["Service"] = service
        return service
    end
end

function GameConnections:Connect(name, service, eventName)
    self:AssertDefaults(name, true, eventName)
    local gameService = game:GetService(service)
    assert(gameService, "Service " .. service .. " not found")
    local event = gameService[eventName]
    assert(event, "Event " .. eventName .. " not found in service " .. service)

    local callback = self.Connections[name].Callback
    self.Connections[name]["Connection"] = event:Connect(callback)
end

function GameConnections:ConnectOnce(name, eventName)
    self:AssertDefaults(name, true, eventName)
    local service = self.Connections[name]["Service"]
    service[eventName]:Once(self.Connections[name].Callback)
end

function GameConnections:Disconnect(name)
    self:AssertDefaults(name, true)
    self.Connections[name].Connection:Disconnect()
    self.Connections[name].Connection = nil
end

return GameConnections