local Lighting = game:GetService("Lighting")
local NPC_COUNT = 5
local TOTAL_PLAYERS = NPC_COUNT + 1

local MIN_EVIL = 1
--local MAX_EVIL = math.floor(TOTAL_PLAYERS / 2)
local MIN_GOOD = 4
--local MAX_GOOD = MIN_GOOD + 1

-- Blur settings
local BLUR_FADE_TIME = 1
local BLUR_STYLE = Enum.EasingStyle.Linear
local BLUR_INITIAL_SIZE = 56
local BLUR_FINAL_SIZE = 0

return {
    NPCCount = NPC_COUNT,
    TotalPlayers = TOTAL_PLAYERS,
    Constraints = {
        MinEvil = MIN_EVIL,
        --MaxEvil = MAX_EVIL,
        MinGood = MIN_GOOD,
        --MaxGood = MAX_GOOD
    },
    GameSettings = {
        InitialConfigs = {
            Services = {
                Lighting = {
                    Blur = {
                        Size = BLUR_INITIAL_SIZE
                    }
                }
            }
        },
        Tweens = {
            Blur = {
                Object = game:GetService("Lighting"):WaitForChild("Blur"),
                Time = BLUR_FADE_TIME,
                Style = BLUR_STYLE,
                Props = {
                    Size = BLUR_FINAL_SIZE
                }
            }
        }
    },
    RolesMeta = {Good = {"Seer", "Villager"}, Evil = {"Assassin"}},
    Roles = {
        Good = {
            Seer = {
                Name = "Seer",
                Behaviour = {
                    Nightfall = "Peek",
                    Dawn = "Vote"
                },
                Type = "Good"
            },
            Villager = {
                Name = "Villager",
                Behaviour = {
                    Dawn = "Vote"
                },
                Type = "Good"
            },
        },
        Evil = {
            Assassin = {
                Name = "Assassin",
                Behaviour = {
                    Nightfall = "Vote",
                    Dawn = "Vote"
                },
                Type = "Evil"
            },
        }
    }
}