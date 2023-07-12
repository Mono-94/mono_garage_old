--─▄▄▀▀█▀▀▄▄       |
--▐▄▌─▀─▀─▐▄▌      |
--──█─▄▄▄─█──▄▄    |
--──▄█▄▄▄█▄─▐──▌   |
--▄█▀█████▐▌─▀─▐   |
--▀─▄██▀██▀█▀▄▄▀   | ─────────────────────────────────────|
-- symbiote_ - Discord: https://discord.gg/Vk7eY8xYV2     |
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
--<-------------------------------------->--
-- KeyBinds
Keys.KeyOpenClose = 'U'    -- KeyBind Open / Close.
Keys.KeyToggleEngine = 'M' -- KeyBind Open / Close.
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
        Scale = 0.6,
        Colour = 0,
    },
    ['The Chrome Dome'] = {
        price = 50,
        hash = 'a_m_y_beachvesp_02',
        PedScenario = "WORLD_HUMAN_BUM_STANDING",
        pos = vector4(-200.32583618164, 6234.50390625,30.502861022949,228.85556030273),
        icon = 'fas fa-key',
        tiempoprogress = 5000,
        label = locale('cerrajero'),
        debug = false,
        Blip = true,
        Sprite = 255,
        Scale = 0.6,
        Colour = 0,
    },
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
