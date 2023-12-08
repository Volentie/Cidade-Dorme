local GameLoop = _G.Core.Knit.CreateController {
    Name = "GameLoop"
}
Signal = _G.Core.Signal


-- Import
local _type = require(script.Parent.Parent.TypeDefs)
local Database: _type.Database, GameConnections

function GameLoop:KnitInit()
    Database = _G.Core.Knit.GetController("Database")
    GameConnections = _G.Core.Knit.GetController("GameConnections")
end

-- Services
local TweenService = game:GetService("TweenService")
local Players = game:GetService("Players")
local LocalPlayer = Players.LocalPlayer
local Lighting = game:GetService("Lighting")

-- GameOver Screen UI
local PlayerGui = LocalPlayer:WaitForChild("PlayerGui")
local GameOverScreen = PlayerGui:WaitForChild("ScreenGui")
local GameOverFrame = GameOverScreen:WaitForChild("GameOverFrame")
local GameOverText = GameOverFrame:WaitForChild("GameOverText")
local YouDiedText = GameOverScreen:WaitForChild("YouDiedText")
local YourTurnText = GameOverScreen:WaitForChild("YourTurnText")
local LastKilledText = GameOverScreen:WaitForChild("LastKilledText")

-- Game dynamics
local Camera = game.Workspace.CurrentCamera
local Game_Utils: Folder = game.Workspace:WaitForChild("Game_Utils")
local Cards: Folder = Game_Utils:WaitForChild("Cards")
local Highlight = Game_Utils:WaitForChild("Highlight")
local Selection = Game_Utils:WaitForChild("Selection")
local AssassinOutline = Game_Utils:WaitForChild("AssassinOutline")
local CardsSpotLight = Game_Utils:WaitForChild("CardsSpotLight"):WaitForChild("SpotLight")
local CardsSpotLightBellow = Game_Utils:WaitForChild("CardsSpotLightBellow"):WaitForChild("SpotLight")
local PlayerRole = nil
local baseCamPos = Vector3.new(0, 4, 17.5)

local isPlayerAimLocked = true
local selectedNPC = nil
local shouldBlur = false
local ScreenBlur, ScreenUnblur
local isLocalPlayerDead = false

-- Triggers
local IsCardVisible = false
local objectHighlighted = nil

GameLoop.Event = Signal.new()
GameLoop.Running = false
GameLoop.Time = "Nightfall"

function GameLoop:ShiftDaytime()
    self.Time = self.Time == "Nightfall" and "Dawn" or "Nightfall"
    -- tween to shift day, if nightfall tween to 0, if dawn tween to 12
    local props = {
        ClockTime = self.Time == "Nightfall" and 0 or 12
    }
    local shiftTween = self:CreateTween(3, Enum.EasingStyle.Linear, game.Lighting, props)
    shiftTween:Play()
    shiftTween.Completed:Wait()
end

function GameLoop:ShowGameOverScreen(text)
    GameOverText.Text = text
    local showOverFrameTween = self:CreateTween(1, Enum.EasingStyle.Linear, GameOverFrame, {
        BackgroundTransparency = 0.55
    })
    local showOverTextTween = self:CreateTween(1, Enum.EasingStyle.Linear, GameOverText, {
        TextTransparency = 0
    })
    showOverFrameTween:Play()
    showOverTextTween:Play()
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
    if shouldBlur and ScreenUnblur.PlaybackState == Enum.PlaybackState.Completed or not shouldBlur then
        local instance = object and object.Instance
        if instance and objectHighlighted ~= instance then
            Highlight.Parent = instance
            objectHighlighted = instance
        elseif not instance and objectHighlighted then
            Highlight.Parent = Game_Utils
            objectHighlighted = nil
        end
    end
    if not isLocalPlayerDead then
        task.wait(0.1)
        self:HandleHighlight(self:GetAimObject())
    elseif isLocalPlayerDead and objectHighlighted then
        Highlight.Parent = Game_Utils
        objectHighlighted = nil
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
    return TweenService:Create(object, info, props)
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
                    if player.Chasing then
                        -- Reset NPC's memory if it was chasing someone before
                        player.Chasing = nil
                    end
                    return false
                end
                player.Chasing = target
                return true
            end
        end,
    }
    behaviourLogic[behaviourType](player, target)
end

function GameLoop:RevealSightIfBlurred()
    if not shouldBlur then
        return
    end
    ScreenUnblur:Play()
    ScreenUnblur.Completed:Wait()
end

function GameLoop:CheckVotes()
    -- Reveal who is going to die
    local mostVoted = nil
    for _, player in Database.Players do
        if not mostVoted then
            mostVoted = player
        elseif player.Votes > mostVoted.Votes then
            mostVoted = player
        elseif player.Votes == mostVoted.Votes then
            if math.random(1, 2) == 1 then
                mostVoted = player
            end
        end
    end

    if not mostVoted then
        print("theres something wrong, no one was voted")
    end

    print("Most voted: ", mostVoted.UserId, "votes: ", mostVoted.Votes)

    for _, player in Database.Players do
        player:ResetVotes()
    end

    self:RevealSightIfBlurred()

    if mostVoted.UserId == LocalPlayer.UserId then
        -- Player is dead
        YouDiedText.Visible = true
        isLocalPlayerDead = true
        task.wait(0.5)
        --self.Running = false
    else
        warn("Killing npc: "..mostVoted.UserId, "role:", mostVoted.Role.Name)

        -- Fade out the npc and kill it
        local killTween = self:CreateTween(1, Enum.EasingStyle.Linear, mostVoted.Part, {
            Transparency = 1
        })
        killTween:Play()
        killTween.Completed:Wait()

        if Highlight.Parent == mostVoted.Part then
            Highlight.Parent = Game_Utils
        end
    end
    mostVoted:Kill()
    LastKilledText.Text = "Last killed: " .. mostVoted.UserId .. ", ROLE: " .. mostVoted.Role.Name
    if #Database.Evils == 0 then
        GameOverText.TextColor3 = Color3.fromRGB(0, 255, 0)
        self:ShowGameOverScreen("The Villagers win")
        self.Running = false
    elseif #Database.Goods == #Database.Evils then
        GameOverText.TextColor3 = Color3.fromRGB(255, 0, 0)
        self:ShowGameOverScreen("The Assassins win")
        self.Running = false
    end

    if not self.Running then
        LastKilledText.Visible = false
        if YouDiedText.Visible then
            YouDiedText.Visible = false
        end
    end
end

function GameLoop:Loop()
    for _, player in Database.Players do
        local behaviour = player.Role.Behaviour[self.Time]
        if not behaviour then
            if shouldBlur then
                ScreenBlur:Play()
                ScreenBlur.Completed:Wait()
            end
            continue
        end

        local target

        if player.Type == "npc" then
            -- NPC logic
            if player.Chasing then
                -- NPC is chasing a target
                target = player.Chasing
                print("NPC ("..player.UserId..", role: "..player.Role.Name..") is chasing the target: "..target.UserId, "which has the role: ", target.Role.Name)
            else
                if player.Role.Type == "Evil" then
                    -- NPC is evil, lets make it vote for a random good player
                    local randGood = Database.Goods[math.random(1, #Database.Goods)]
                    target = randGood
                    print("Assasin ("..player.UserId..", role: "..player.Role.Name..") voted to kill: "..target.UserId, "which has the role: ", target.Role.Name)
                else
                    local realocPly, index = Database:RemovePlayerByValue(player)
                    target = Database.Players[math.random(1, #Database.Players)]
                    table.insert(Database.Players, index, realocPly)
                    if player.Role.Name == "Seer" then
                        -- Print that npc is chasing the target
                        print("Seer ("..player.UserId..", role: "..player.Role.Name..") revealed the role of: "..target.UserId, "which is", target.Role.Type)
                    else
                        print("NPC ("..player.UserId..", role: "..player.Role.Name..") has selected the target: "..target.UserId, "which has the role: ", target.Role.Name)
                    end
                end
            end
            self:TriggerBehaviour(behaviour, player, target)
        elseif not isLocalPlayerDead then
            -- Player's turn
            isPlayerAimLocked = false  -- Unlock the player's ability to select
            repeat
                if not YourTurnText.Visible then
                    YourTurnText.Visible = true
                end
                task.wait()  -- Wait here for the player's decision
            until selectedNPC

            YourTurnText.Visible = false

            print("You've selected the NPC: " .. selectedNPC.UserId, "which has the role: ", selectedNPC.Role.Name)
            -- Process the player's decision
            self:TriggerBehaviour(behaviour, player, selectedNPC)

            -- Add a delay for visualizing the selection
            task.wait(0.5)

            selectedNPC = nil  -- Reset for next turn
            isPlayerAimLocked = true  -- Lock the player's ability to select again
            if Selection.Parent ~= Game_Utils then
                Selection.Parent = Game_Utils
            end
        end
        task.wait(0.2)
    end

    self:CheckVotes()

    if self.Running then
        -- Time shift
        self:ShiftDaytime()
        warn("Starting next loop")
        self:Loop()
    end
end

GameLoop.Event:Connect(function(bool: boolean)
    if bool then

        -- Blur settings
        -- Get player role
        local PlayerData, idx = Database:GetPlayerByUserId(LocalPlayer.UserId)
        PlayerRole = PlayerData.Role

        if PlayerRole.Name == "Assassin" then
            if #Database.Evils > 1 then
                -- Assassin is not alone, lets show the assassin outline
                local npcPart = Database.Evils[idx == 1 and 2 or 1].Part
                AssassinOutline.Parent = npcPart
            end
        end

        if not PlayerRole.Behaviour["Nightfall"] then
            shouldBlur = true
            ScreenBlur = GameLoop:CreateTween(1, Enum.EasingStyle.Linear, Lighting.Blur, {
                Size = 56
            })
            ScreenUnblur = GameLoop:CreateTween(1, Enum.EasingStyle.Linear, Lighting.Blur, {
                Size = 0
            })
        end

        GameLoop.Running = true
        -- Set initial cards visibility
        GameLoop:HideCards()
        -- Get player card
        local PlayerCard = Cards:WaitForChild(PlayerRole.Name.."-Card")
        -- Toggle card visible to show the player their role
        GameLoop:ToggleCardVisibility(PlayerCard)
        -- Create a tween to position the card in front of the camera
        local showCardTween = GameLoop:CreateTween(1, Enum.EasingStyle.Linear, PlayerCard, {
            CFrame = CFrame.new(baseCamPos) * CFrame.new(Vector3.new(0, 0, -2)) * CFrame.Angles(math.rad(-90), 0, math.rad(180))
        })
        -- Create another tween to offset the card bellow the camera a bit so the game can continue
        local offsetCardBellowTween = GameLoop:CreateTween(1, Enum.EasingStyle.Linear, PlayerCard, {
            CFrame = CFrame.new(baseCamPos) * CFrame.new(Vector3.new(0, -2, -2)) * CFrame.Angles(math.rad(-90), 0, math.rad(180))
        })
        showCardTween.Completed:Once(function()
            CardsSpotLight.Enabled = true
            task.wait(2)
            offsetCardBellowTween:Play()
        end)
        offsetCardBellowTween.Completed:Once(function()
            CardsSpotLightBellow.Enabled = true
            -- Handle highlight
            task.spawn(function()
                GameLoop:HandleHighlight(GameLoop:GetAimObject())
            end)
            -- Start game loop
            GameLoop:Loop()
        end)
        -- Play the tween
        showCardTween:Play()

        GameConnections:Append("NPCClick", function(input)
            if isPlayerAimLocked then
                return
            end
            if input.UserInputType == Enum.UserInputType.MouseButton1 then
                if not objectHighlighted then
                    print("trying to click on nothing")
                    return
                end
                selectedNPC = Database:GetPlayerByUserId(objectHighlighted:GetAttribute("UserId"))
                if not selectedNPC then
                    print("trying to click on an invalid npc " .. objectHighlighted:GetAttribute("UserId"))
                    return
                end
            end
        end)
        GameConnections:Connect("NPCClick", "UserInputService", "InputBegan")
    else
        warn("Finishing game")
        GameLoop.Running = false
    end
end)

return GameLoop