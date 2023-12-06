local NPC_COUNT = 5  -- Adjust this as needed for dynamic player counts
local TOTAL_PLAYERS = NPC_COUNT + 1

local MIN_EVIL = math.floor(TOTAL_PLAYERS / 3)
local MAX_EVIL = math.floor(TOTAL_PLAYERS / 2)
local MIN_GOOD = math.ceil(TOTAL_PLAYERS / 2)
local MAX_GOOD = MIN_GOOD + 1

return {
    NPCCount = NPC_COUNT,
    TotalPlayers = TOTAL_PLAYERS,
    Constraints = {
        MinEvil = MIN_EVIL,
        MaxEvil = MAX_EVIL,
        MinGood = MIN_GOOD,
        MaxGood = MAX_GOOD
    },
    RolesMeta = {"Assassin", "Seer", "Villager"},
    Roles = {
        Assassin = {
            Behaviour = {
                Nightfall = "Kill",
                Dawn = "Vote"
            },
            Type = "Evil"
        },
        Seer = {
            Behaviour = {
                Nightfall = "Peek",
                Dawn = "Vote"
            },
            Type = "Good"
        },
        Villager = {
            Behaviour = {
                Dawn = "Vote"
            },
            Type = "Good"
        },
    }
}