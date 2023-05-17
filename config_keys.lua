--─▄▄▀▀█▀▀▄▄       |
--▐▄▌─▀─▀─▐▄▌      |
--──█─▄▄▄─█──▄▄    |
--──▄█▄▄▄█▄─▐──▌   |
--▄█▀█████▐▌─▀─▐   |
--▀─▄██▀██▀█▀▄▄▀   | ─────────────────────────────────────|
-- Symbiote#3027 - Discord: https://discord.gg/Vk7eY8xYV2 |
--────────────────────────────────────────────────────────|

lib.locale()

Keys = {}

-- Debug
Keys.Debug = false      -- Prints.
--<-------------------------------------->--
Keys.Distance = 5       -- Distance to open or close.
Keys.DistanceCreate = 5 -- Distance to create key.
--<-------------------------------------->--
-- Time.
Keys.CreateKeyTime = 1000 -- progressBar time.
--<-------------------------------------->--
-- Items.
Keys.ItemName = 'carkeys' -- Key Item.
Keys.ItemPlate = 'plate'  -- Plate item.
--<-------------------------------------->--
-- Prices
Keys.CopyPrice = 50        -- Price to buy copy keys.
Keys.PriceItemPlate = 1500 -- Price to change plate number
--<-------------------------------------->--
-- KeyBinds
Keys.KeyOpenClose = 'U'    -- KeyBind Open / Close.
Keys.KeyToggleEngine = 'M' -- KeyBind Open / Close.
Keys.FindKeyBindKEY = 'B'  -- KeyBind FindKey
--<-------------------------------------->--
-- Command only admins.
Keys.CommandGiveKey = 'givekey' -- Give Key.
Keys.CommandDelKey = 'delkey'   -- Delete Key.
--<-------------------------------------->--
-- Car Options
Keys.Engine = true    -- With this you will maintain control of the engine in the vehicle and you will only be able to start the engine with the keys.
Keys.EngineNoti = true  -- Toggle engine notifications 
Keys.OnExitCar = true -- (Car key  necessary) Its purpose is to allow, if the vehicle is running and the "F" key is hold down, the engine will continue running. If the "F" key is pressed once and released, the engine will turn off. Initially, this function should only work if the vehicle is running.
--<-------------------------------------->--
-- Vehicle Entity spawn (All Vehicles create in world)
Keys.EntityVehicleSpawn = {
    CloseDoorEmptyCar = true,  -- Lock all vehicles with the engine turned off.
    DoorProbability = true,    -- Probability of finding an open door.
    OpenDoorProbability = 0.9, -- Min 0.0 , Max 1.0.
}
--<-------------------------------------->--
-- The player can search for the key inside the vehicle.
Keys.FindKeys = {
    FindKey = true,      -- The player can search for the key inside the vehicle.
    FindKeyCommand = false, -- Enable/disable Command
    Command = 'FindKey', -- Command name
    Probability = 0.1,   -- Probability of finding the key in the vehicle.
    ProgressTime = 5000, -- Time to search
    FindKeyBind = true,  -- KeyBind to search keys in a vehicle Default B
}
--<-------------------------------------->--
Keys.NpcReclameKey = {
    ['Premium Motor Deluxe'] = {
        price = 50,
        hash = 'a_m_y_beachvesp_02',
        PedScenario = "PROP_HUMAN_SEAT_COMPUTER",
        pos = vec4(-56.087562561035,-1098.4111328125,24.931186676025, 341.8551),
        icon = 'fas fa-key',
        tiempoprogress = 5000,
        label = locale('cerrajero'),
        debug = false,
        Blip = true,
        Sprite = 255,
        Display = 4,
        Scale = 0.6,
        Colour = 0,
        ShortRange = true,
    },
}
--<-------------------------------------->--
Keys.LockPick = {
    {
        enable = true,          -- Enable o disable LockPick
        alarmProbability = 1.0, -- Min 0.0 max 1.0
        alarmTime = 10000,
        SkillCheck = true,      -- If it's false, a progress bar will be used.
        TimeProgress = 2000,
        Skills = {
            { { areaSize = 60, speedMultiplier = 1 }, { areaSize = 60, speedMultiplier = 0.5 },
                { areaSize = 60, speedMultiplier = 0.5 }, { areaSize = 60, speedMultiplier = 0.5 } },
            { '1', '2', '3', '4' }
        },
        animDict = "anim@amb@clubhouse@tutorial@bkr_tut_ig3@",
        anim = "machinic_loop_mechandplayer",
        Disptach = false,
        DispatchFunction = function() -- You can put here Dispatch Event.
            print('Dispatch activated.')
        end
    }
}
Keys.HotWire = {
    {
        enable = true,     -- Enable o Disable Hotwire.
        SkillCheck = true, -- If it's false, a progress bar will be used.
        TimeProgress = 2000,
        Skills = {
            { { areaSize = 60, speedMultiplier = 1 }, { areaSize = 60, speedMultiplier = 0.5 } }, { '1', '2' }
        },
        animDict = "veh@std@ds@base",
        anim = "hotwire",
    }
}
--<-------------------------------------->--
RegisterNetEvent('mono_carkeys:Notification', function(title, msg, icon, color)
    lib.notify({
        title = title,
        description = msg,
        position = 'bottom',
        icon = icon,
        iconColor = color
    })
end)
