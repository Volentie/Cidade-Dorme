local UserInputService = game:GetService("UserInputService")
Core = _G.Core
Knit = Core.Knit
Signal = Core.Signal

-- Import
local _type = require(script.Parent.Parent.TypeDefs)

local GameLoop = Knit.CreateController{
    Name = "GameLoop"
}

GameLoop.Event = Signal.new()
GameLoop.Running = false

local GameState, Database: _type.Database
local GameConnections
local turnState, currentAction

-- Services
local UserInputService = game:GetService("UserInputService")
local Players = game:GetService("Players")
local LocalPlayer = Players.LocalPlayer

-- Game dynamics
local Camera = game.Workspace.CurrentCamera
local Game_Utils: Folder = game.Workspace:WaitForChild("Game_Utils")
local Cards: Folder = Game_Utils:WaitForChild("Cards")
local Highlight = Game_Utils:WaitForChild("Highlight")
local Selection = Game_Utils:WaitForChild("Selection")
local CardsSpotLight = Game_Utils:WaitForChild("CardsSpotLight"):WaitForChild("SpotLight")
local CardsSpotLightBellow = Game_Utils:WaitForChild("CardsSpotLightBellow"):WaitForChild("SpotLight")
local PlayerRole = nil
local baseCamPos = Vector3.new(0, 4, 17.5)

local deathVotes = {}
local isPlayerLocked = true
local selectedNPC = nil
local gameQueue = 0

-- Triggers
local IsCardVisible = false

local objectHighlighted = nil

function GameLoop:Init()
    GameState = Knit.GetController("GameState")
    GameConnections = Knit.GetController("GameConnections")
    turnState = GameState:CreateState("TurnState")
    currentAction = GameState:CreateState("CurrentAction")
    Database = Knit.GetController("Database")
end

function GameLoop:AlterTime()
    turnState:SetState( bit32.bxor(turnState:GetState(), 1) )
end

function GameLoop:GetAimObject()
    local CamFrame = Camera.CFrame
    local CamPos = CamFrame.Position
    local rayParams = RaycastParams.new()
    rayParams.FilterType = Enum.RaycastFilterType.Whitelist
    rayParams.FilterDescendantsInstances = {table.unpack(workspace:WaitForChild("Game_Scene"):WaitForChild("NPCs"):GetChildren())}
    local ray = workspace:Raycast(CamPos, CamFrame.LookVector * 42, rayParams)
    return ray
end

function GameLoop:HandleHighlight(object)
    local instance = object and object.Instance
    if instance and objectHighlighted ~= instance then
        Highlight.Parent = instance
        objectHighlighted = instance
    elseif not instance and objectHighlighted then
        Highlight.Parent = Game_Utils
        objectHighlighted = nil
    end
    if self.Running then
        task.wait(0.1)
        self:HandleHighlight(self:GetAimObject())
    end
end

function GameLoop:ToggleCardVisibility(card)
    IsCardVisible = not IsCardVisible
    if IsCardVisible then
        card.Transparency = 0
        card.Texture.Transparency = 0
    else
        card.Transparency = 1
        card.Texture.Transparency = 1
    end
end

function GameLoop:CreateTween(time, style, object, props)
    local info = TweenInfo.new(time, style)
    return game:GetService("TweenService"):Create(object, info, props)
end

function GameLoop:HideCards()
    for _, card in Cards:GetChildren() do
        card.Transparency = 1
        card.Texture.Transparency = 1
    end
end

function GameLoop:TriggerBehaviour(behaviourType: string, player: {}, target: {})
    local behaviourLogic = {
        Vote = function(player, target)
            -- Increment target votes
            target:IncrementVotes()
            return true
        end,
        Peek = function(player, target)
            -- Reveal player's role
            local targetRole = target.Role
            local roleType = targetRole.Type
            -- Check if player is the local player
            if player.UserId == LocalPlayer.UserId then
                if roleType == "Good" then
                    Selection.OutlineColor = Color3.fromRGB(0, 255, 0)
                else
                    Selection.OutlineColor = Color3.fromRGB(255, 0, 0)
                end
                Selection.Parent = target.Part
                return true
            else
                -- Player is a NPC, lets make it chase the target if he finds out he's evil
                if roleType == "Good" then
                    -- To reduce complexity, we'll not track NPC's memory
                    return false
                end
                player.Chasing = target
                return true
            end
        end,
    }
    behaviourLogic[behaviourType](player, target)
end

function GameLoop:CheckVotes()
    if gameQueue == #Database.Players then
        gameQueue = 0
        -- Reveal who is going to die
        local mostVoted = nil
        for _, player in Database.Players do
            if player.Votes == 0 then
                continue
            end
            if not mostVoted then
                mostVoted = player
            end
            if player.Votes > mostVoted.Votes then
                mostVoted = player
            end
        end

        print("Most voted: ", mostVoted.UserId, "votes: ", mostVoted.Votes)

        if mostVoted.UserId == LocalPlayer.UserId then
            -- Player is dead
            print("You died")
            task.wait(2)
            -- Close game
            self.Running = false
        else
            -- Fade out the npc and kill it
            local killTween = self:CreateTween(1, Enum.EasingStyle.Linear, mostVoted.Part, {
                Transparency = 1
            })
            killTween.Completed:Wait()
            print("killing npc")
            mostVoted:Kill()
        end
        self:AlterTime()
        print("turn state: ", turnState:GetState())
    end
end

function GameLoop:Loop()
    for _, player in Database.Players do
        gameQueue += 1
        if turnState:GetState() == 0 and not player.Role.Behaviour["Nightfall"] then
            continue
        end

        local behaviour = player.Role.Behaviour[turnState:GetState() == 0 and "Nightfall" or "Dawn"]
        local target

        if player.Type == "npc" then
            -- NPC logic
            target = Database.Players[math.random(1, #Database.Players)]
            print("NPC selected: "..target.UserId, "role: ", target.Role.Name)
            self:TriggerBehaviour(behaviour, player, target)
        else
            -- Player's turn
            isPlayerLocked = false  -- Unlock the player's ability to select
            repeat
                print("Your turn, click on a target")
                task.wait()  -- Wait here for the player's decision
            until selectedNPC

            -- Process the player's decision
            self:TriggerBehaviour(behaviour, player, selectedNPC)

            -- Add a delay for visualizing the selection
            task.wait(1.5)

            selectedNPC = nil  -- Reset for next turn
            isPlayerLocked = true  -- Lock the player's ability to select again
            Selection.Parent = Game_Utils
        end
        self:CheckVotes()
        task.wait(0.5)
    end

    if self.Running then
        self:Loop()
    end
end

GameLoop.Event:Connect(function(bool: boolean)
    if bool then
        GameLoop.Running = true
        --[[
            1. Get player role
            2. Get player card
            3. Toggle card visible to show the player their role
            4. Create a tween to position the card in front of the camera
            5. Play the tween
        ]]
        -- Set initial cards visibility
        GameLoop:HideCards()
        -- Get player role
        PlayerRole = Database.Players[LocalPlayer.UserId].Role.Name
        -- Get player card
        local PlayerCard = Cards:WaitForChild(PlayerRole.."-Card")
        -- Toggle card visible to show the player their role
        GameLoop:ToggleCardVisibility(PlayerCard)
        -- Create a tween to position the card in front of the camera
        local tween = GameLoop:CreateTween(1, Enum.EasingStyle.Linear, PlayerCard, {
            CFrame = CFrame.new(baseCamPos) * CFrame.new(Vector3.new(0, 0, -2)) * CFrame.Angles(math.rad(-90), 0, math.rad(180))
        })
        -- Create another tween to offset the card bellow the camera a bit so the game can continue
        local tween2 = GameLoop:CreateTween(1, Enum.EasingStyle.Linear, PlayerCard, {
            CFrame = CFrame.new(baseCamPos) * CFrame.new(Vector3.new(0, -2, -2)) * CFrame.Angles(math.rad(-90), 0, math.rad(180))
        })
        tween.Completed:Once(function()
            CardsSpotLight.Enabled = true
            task.wait(2)
            tween2:Play()
        end)
        tween2.Completed:Once(function()
            CardsSpotLightBellow.Enabled = true
            -- Handle highlight
            task.spawn(function()
                GameLoop:HandleHighlight(GameLoop:GetAimObject())
            end)
            -- Start game loop
            GameLoop:Loop()
        end)
        -- Play the tween
        tween:Play()

        GameConnections:Append("NPCClick", function(input)
            if isPlayerLocked then
                return
            end
            if input.UserInputType == Enum.UserInputType.MouseButton1 then
                if not objectHighlighted then
                    return
                end
                selectedNPC = Database.Players[objectHighlighted:GetAttribute("UserId")]
            end
        end)
        GameConnections:Connect("NPCClick", "UserInputService", "InputBegan")
    else
        GameLoop.Running = false
    end
end)

return GameLoop