--────────────────────────────────────────────────────────|
--             Discord: https://discord.gg/Vk7eY8xYV2     |
--────────────────────────────────────────────────────────|

VehEntity = {}

-- Vehicle Entity spawn (All Vehicles create in world)

VehEntity.EntityVehicleSpawn = {

    CloseDoorEmptyCar = true, -- Close all vehicles without NPC inside.

    DoorProbability = true,   -- Probability of finding an open door.

    OpenDoorProbability = 1,  -- 1 = 10%  there is now a 10% chance of finding an open vehicle without a passenger.
}

--<-------------------------------------->--

-- The player can search for the key inside the vehicle.

VehEntity.FindKeys = {

    FindKeyBindKEY = 'B',  -- KeyBind FindKey

    FindKey = true,        -- The player can search for the key inside the vehicle.

    FindKeyCommand = true, -- Enable/disable Command

    Command = 'FindKey',   -- Command name

    Probability = 0.1,     -- Probability of finding the key in the vehicle.

    ProgressTime = 5000,   -- Time to search

    FindKeyBind = true,    -- KeyBind to search keys in a vehicle Default B

}

--<-------------------------------------->--

VehEntity.LockPick = {

    enable = true,          -- Enable o disable LockPick
    alarmProbability = 1.0, -- Min 0.0 max 1.0
    alarmTime = 10000,
    SkillCheck = true,      -- If it's false, a progress bar will be used.
    TimeProgress = 2000,
    Skills = {
        {
            { areaSize = 30, speedMultiplier = 0.2 + math.random() * 0.8 },
            { areaSize = 60, speedMultiplier = 0.2 + math.random() * 0.8 },
            { areaSize = 30, speedMultiplier = 0.2 + math.random() * 0.8 },
            { areaSize = 60, speedMultiplier = 0.2 + math.random() * 0.8 },
            { areaSize = 30, speedMultiplier = 0.2 + math.random() * 0.8 }
        },
        { 'E', 'E', 'E', 'E', 'E' }
    },
    animDict = "anim@amb@clubhouse@tutorial@bkr_tut_ig3@",
    anim = "machinic_loop_mechandplayer",
    Disptach = false,
    DispatchFunction = function(player, vehicle, vehicleCoords) -- You can put here Dispatch Event.
        print('Dispatch activated.', player, vehicle, vehicleCoords)
    end

}


VehEntity.HotWire = {
    enable = true,     -- Enable o Disable Hotwire.
    SkillCheck = true, -- If it's false, a progress bar will be used.
    TimeProgress = 2000,
    Skills = {
        {
            { areaSize = 30, speedMultiplier = 0.2 + math.random() * 0.8 },
            { areaSize = 60, speedMultiplier = 0.2 + math.random() * 0.8 },
            { areaSize = 30, speedMultiplier = 0.2 + math.random() * 0.8 },
            { areaSize = 60, speedMultiplier = 0.2 + math.random() * 0.8 },
            { areaSize = 60, speedMultiplier = 0.2 + math.random() * 0.8 },
            { areaSize = 30, speedMultiplier = 0.2 + math.random() * 0.8 }
        },
        { 'E', 'E', 'E', 'E', 'E', 'E' }
    },
    animDict = "veh@std@ds@base",
    anim = "hotwire",

}
