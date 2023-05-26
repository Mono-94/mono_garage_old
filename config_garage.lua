--─▄▄▀▀█▀▀▄▄       |
--▐▄▌─▀─▀─▐▄▌      |
--──█─▄▄▄─█──▄▄    |
--──▄█▄▄▄█▄─▐──▌   |
--▄█▀█████▐▌─▀─▐   |
--▀─▄██▀██▀█▀▄▄▀   | ─────────────────────────────────────|
-- Symbiote#3027 - Discord: https://discord.gg/Vk7eY8xYV2 |
--────────────────────────────────────────────────────────|


Garage = {}

Garage.Debug = false          -- Debug, prints etc...

Garage.RadialCopyCoords = false -- Radial menu to copy coordinates and easily create garages, use this only on your development server!

Garage.Version = true         -- Check GitHub version.

Garage.Target = true         -- If it's true, it will use ox_target, if it's false, Radial Menu will be used.

Garage.TargetNPCDistance = 1.5   -- Distance to open Menu in NPC

Garage.TargetCarDistance = 2.5   -- Distance to deposit the vehicle with ox_target

--<-------------------------------------->--
Garage.OwnerCarAdmin = {
    -- The vehicle you are in will be saved in the database and become your property. (ADMIN)
    Command = 'givecar', -- Command
    Group = 'admin',     -- Group
}

Garage.AutoImpound = {
    
    AutoImpound = true,         -- This function allows vehicles that are outside the garage and the entity is not present in the world to be sent directly to the impound.

    ImpoundIn = 'Auto Impound', -- The default impound where the vehicle will be sent if the entity does not exist in the world. (It has to match with an impound created.)

    TimeCheck = 1000 * 4,      -- (Default 1min) Time to check for vehicles that do not exist in the world and are not found in the garage in order to impound them.
}

--<-------------------------------------->--

Garage.SharedGarage = false   -- If it is "true" it will be able to withdraw the vehicles in any garage, if it is "false" it will only be able to withdraw the vehicle in the garage that kept it.

Garage.ShareCarFriend = true  -- Share vehicles with friends.

Garage.SaveKilometers = true -- Save Kilometers in DB

Garage.SetInToVehicle = false -- Set ped into vehicle upon spawn.

--<-------------------------------------->--
Garage.Mono_Carkeys = true -- Config_keys.lua / https://mono-2.gitbook.io/docs/mono-scrips/mono_carkeys/events-y-exports

Garage.CarKeys = true      -- Add keys when removing the vehicle and remove them when depositing it.

--<-------------------------------------->--

Garage.NpcImpound = {
    NPCAnim = true,
    NpcHasw = 's_m_m_dockwork_01',
    TimeDeleteVehicle = 15000,
    ProgressBarTime = 5000,
    Command = 'impound',
    jobs = {
        [1] = 'police',
        [2] = 'sheriff',
        [3] = 'ambulance',
        [4] = 'paletoems',
        [5] = 'trafico',
        [6] = 'mechanic'
        --[420] = '',   -- Add more jobs
    }
}

--<-------------------------------------->--

Garage.Garages = {
    ['Auto Impound'] = {
        impound      = true,
        impoundPrice = 100,
        type         = 'car',
        impoundIn    = false,
        job          = false,
        pos          = vec3(408.81500244141, -1637.9078369141, 29.291925430298),
        size         = vec3(15, 30, 3),
        heading      = 141.7584991455078,
        SetInToVehicle = true,
        spawnpos     = {
            { x = 407.93273925781, y = -1654.6179199219, z = 29.001836776733, w = 320.06909179688 },
            { x = 405.76379394531, y = -1652.2020263672, z = 29.002393722534, w = 320.41540527344 },
            { x = 403.46255493164, y = -1650.3392333984, z = 29.003999710083, w = 320.78207397461 },
            { x = 420.50085449219, y = -1638.8636474609, z = 29.002016067505, w = 269.73226928711 },
        },
        blip         = true,
        sprite       = 524,
        scale        = 0.6,
        colorblip    = 0,
        NPCHash      = 'csb_trafficwarden',
        NPCPos       = vec4(400.30816650391, -1627.5834960938, 28.291940689087, 230.88716125488),
    },
    ['Paleto Bay Impound'] = {
        impound      = true,
        impoundPrice = 50,
        type         = 'car',
        impoundIn    = false,
        job          = false,
        pos          = vec3(-469.83917236328, 6032.5634765625, 31.34037399292),
        size         = vec3(15, 40, 3),
        heading      = 313.0982666015625,
        SetInToVehicle = false,
        spawnpos     = {
            { x = -468.47308349609, y = 6038.390625,     z = 30.928045272827, w = 224.43283081055 },
            { x = -472.20770263672, y = 6035.0908203125, z = 30.928321838379, w = 225.26126098633 },
            { x = -475.53344726563, y = 6031.2236328125, z = 30.928354263306, w = 224.62934875488 },
            { x = -478.90426635742, y = 6027.5659179688, z = 30.928239822388, w = 224.27416992188 },
            { x = -482.52709960938, y = 6024.615234375,  z = 30.928611755371, w = 223.71766662598 },
        },
        blip         = true,
        sprite       = 524,
        scale        = 0.6,
        colorblip    = 0,
        NPCHash      = 'csb_trafficwarden',
        NPCPos       = vec4(-463.06100463867, 6025.5874023438, 30.44896697998, 135.05729675293),

    },
    ['Pillbox Hill'] = {
        impound      = false,
        impoundPrice = false,
        type         = 'car',
        impoundIn    = 'Auto Impound',
        job          = false,
        pos          = vec3(227.27825927734, -785.90087890625, 30.716024398804),
        size         = vec3(55, 35, 5),
        heading      = 250.1240,
        SetInToVehicle = true,
        spawnpos     = {
             vec4(220.2780456543, -809.17193603516,30.056179046631,249.62936401367),
             vec4(221.07490539551, -806.69848632813, 30.390104293823, 248.47229003906),
             vec4(222.11103820801, -804.14074707031, 30.38419342041, 246.64263916016),
             vec4(223.20907592773, -801.78698730469, 30.369050979614, 247.40501403809),
             vec4(206.27438354492, -801.09350585938, 30.711149215698, 247.7689666748),
             vec4(207.43371582031, -798.52429199219, 30.690946578979, 247.72959899902),
             vec4(208.2936706543, -796.23156738281, 30.672399520874, 248.55288696289),
             vec4(209.48155212402, -793.83129882813, 30.646259307861, 249.14572143555),
             vec4(215.1284942627, -804.10589599609, 30.347541809082, 69.22452545166),
             vec4(216.35070800781, -801.84881591797, 30.325912475586, 68.610794067383),
             vec4(217.4236907959, -799.2294921875, 30.309574127197, 67.479904174805),
             vec4(218.359375, -796.85687255859, 30.297718048096, 67.339340209961),
             vec4(233.58877563477, -805.39239501953, 29.968862533569, 69.095611572266),
             vec4(232.12843322754, -807.85375976563, 29.973529815674, 68.418014526367),
             vec4(231.43034362793, -810.4765625, 30.428318023682, 68.37825012207)
        },
        blip         = true,
        sprite       = 50,
        scale        = 0.6,
        colorblip    = 0,
        NPCHash      = 'csb_trafficwarden',
        NPCPos       = vec4(214.69429016113, -807.11199951172, 29.800384521484, 339.01174926758),

    },
    ['Grape Seed'] = {
        impound      = false,
        impoundPrice = false,
        type         = 'car',
        impoundIn    = 'Paleto Bay Impound',
        job          = false,
        pos          = vector4(1700.13671875, 4931.6333007813,42.078128814697,62.388843536377),
        size         = vec3(40, 30, 5),
        heading      = 57.604652404785,
        SetInToVehicle = false,
        spawnpos     = {
            { x = 1695.2021484375, y = 4940.17578125, z = 41.75191116333, w = 99.631744384766},
   

        },
        blip         = true,
        sprite       = 50,
        scale        = 0.6,
        colorblip    = 0,
        NPCHash      = 'csb_trafficwarden',
        NPCPos       = vector4(1700.13671875, 4931.6333007813,41.078128814697,62.388843536377),

    },
    ['Little Seoul'] = {
        impound      = false,
        impoundPrice = false,
        type         = 'car',
        impoundIn    = 'Auto Impound',
        job          = false,
        pos          = vec3(-697.75500488281, -981.04711914063, 20.390176773071),
        size         = vec3(20, 15, 5),
        heading      = 351.32122802734375,
        SetInToVehicle = false,
        spawnpos     = {
            { x = -698.71136474609, y = -988.19073486328, z = 20.099597930908, w = 300.3828125 },
            { x = -701.25054931641, y = -985.26904296875, z = 20.099529266357, w = 298.08532714844 },
            { x = -703.17010498047, y = -982.14239501953, z = 20.099630355835, w = 299.89221191406 },
            { x = -705.10479736328, y = -979.02136230469, z = 20.099308013916, w = 299.97964477539 },
            { x = -686.54901123047, y = -982.19079589844, z = 20.100147247314, w = 86.923316955566 },
            { x = -686.50628662109, y = -975.06280517578, z = 20.10037612915,  w = 88.99080657959 },
            { x = -686.35290527344, y = -978.50183105469, z = 19.978174209595, w = 89.784156799316 },
        },
        blip         = true,
        sprite       = 50,
        scale        = 0.6,
        colorblip    = 0,
        NPCHash      = 'csb_trafficwarden',
        NPCPos       = vec4(-702.84808349609, -970.89501953125, 19.389713287354, 179.47773742676),

    },
    ['Paleto Bay'] = {
        impound      = false,
        impoundPrice = false,
        type         = 'car',
        impoundIn    = 'Auto Impound',
        job          = false,
        pos          = vec3(-199.8488, 6216.9556, 31.1998),
        size         = vec3(25, 20, 3),
        heading      = 226.0117,
        SetInToVehicle = false,
        spawnpos     = {
            { x = -207.30862426758, y = 6219.4477539063, z = 31.200904846191, w = 225.60264587402 },
            { x = -205.18788146973, y = 6221.8974609375, z = 31.201028823853, w = 226.04624938965 },
            { x = -202.69532775879, y = 6224.2993164063, z = 31.199897766113, w = 225.46133422852 },
            { x = -200.43357849121, y = 6226.60546875,   z = 31.204719543457, w = 225.56149291992 },
            { x = -197.94256591797, y = 6228.9672851563, z = 31.209632873535, w = 224.47320556641 },
        },
        blip         = true,
        sprite       = 50,
        scale        = 0.6,
        colorblip    = 0,
        NPCHash      = 'csb_trafficwarden',
        NPCPos       = vec4(-215.56448364258, 6219.1748046875, 30.491662979126, 225.76336669922),

    },
    -- BOAT GARAGES
    ['La Puerta Boat'] = {
        impound      = false,
        impoundPrice = false,
        type         = 'boat',
        impoundIn    = 'Boat Impound',
        job          = false,
        pos          = vec3(-761.92810058594, -1370.1292724609, -0.47471886873245),
        size         = vec3(21, 126, 5),
        heading      = 140.1520,
        SetInToVehicle = false,
        spawnpos     = {
            { x = -727.81530761719, y = -1326.5987548828, z = -0.094071432948112, w = 229.80152893066 },
            { x = -733.33190917969, y = -1332.6695556641, z = -0.08595734834671,  w = 229.80354309082 },
            { x = -739.35668945313, y = -1339.9422607422, z = -0.095463529229164, w = 229.78338623047 },
            { x = -745.50311279297, y = -1347.1071777344, z = -0.070759519934654, w = 229.80442810059 },
            { x = -750.82720947266, y = -1353.5904541016, z = -0.11510844528675,  w = 229.79382324219 },
            { x = -757.01312255859, y = -1360.8302001953, z = -0.10407355427742,  w = 229.79582214355 },
            { x = -771.07604980469, y = -1377.4093017578, z = -0.089632928371429, w = 229.81011962891 },
            { x = -775.16369628906, y = -1385.5844726563, z = -0.088174432516098, w = 234.73382568359 },
            { x = -780.06219482422, y = -1391.9166259766, z = -0.041924431920052, w = 234.73052978516 },
            { x = -787.36322021484, y = -1398.3914794922, z = -0.065565600991249, w = 231.17677307129 },
            { x = -794.11889648438, y = -1405.9254150391, z = -0.078368499875069, w = 231.18263244629 },
            { x = -799.26190185547, y = -1412.4825439453, z = -0.063017770648003, w = 231.16915893555 },
        },
        blip         = true,
        sprite       = 427,
        scale        = 0.6,
        colorblip    = 0,
        NPCHash      = 'csb_trafficwarden',
        NPCPos       = vec4(-718.55004882813, -1326.7746582031, 0.5962884426117, 48.328620910645),

    },
    ['Paleto Cove'] = {
        impound      = false,
        impoundPrice = false,
        type         = 'boat',
        impoundIn    = 'Boat Impound',
        job          = false,
        pos          = vec3(-1590.1145019531, 5263.9028320313, 0.36925473809242),
        size         = vec3(35, 20, 7),
        heading      = 25.3668098449707,
        SetInToVehicle = false,
        spawnpos     = {
            { x = -1599.9913330078, y = 5260.8452148438, z = 0.45005643367767, w = 26.22989654541 },
        },
        blip         = true,
        sprite       = 427,
        scale        = 0.6,
        colorblip    = 0,
        NPCHash      = 'csb_trafficwarden',
        NPCPos       = vec4(-1604.6020507813, 5256.5966796875, 1.0740420818329, 27.048063278198),

    },
    ['Boat Impound'] = {
        impound      = true,
        impoundPrice = 1431,
        type         = false,
        impoundIn    = false,
        job          = false,
        pos          = vec3(-781.90472412109, -1497.3582763672, 1.2815128564835),
        size         = vec3(80, 80, 10),
        heading      = 242.03529357910156,
        SetInToVehicle = false,
        spawnpos     = {
            { x = -808.94744873047, y = -1508.1628417969, z = -0.55900025367737, w = 114.28608703613 },
        },
        blip         = true,
        sprite       = 404,
        scale        = 0.6,
        colorblip    = 0,
        NPCHash      = 'csb_trafficwarden',
        NPCPos       = vec4(-788.95941162109, -1490.6604003906, 0.5952168703079, 289.04177856445),

    },
    -- AIRCRAFT GARAGE
    ['Aeropuerto INYL. de los Santos'] = {
        impound      = false,
        impoundPrice = false,
        type         = 'air',
        impoundIn    = 'AirCraft Impound',
        job          = false,
        pos          = vec3(-973.48748779297, -2997.5534667969, 13.944133758545),
        size         = vec3(80, 80, 10),
        heading      = 242.03529357910156,
        SetInToVehicle = false,
        spawnpos     = {
            { x = -969.91619873047, y = -3002.1491699219, z = 13.656873703003, w = 59.526836395264 },
        },
        blip         = true,
        sprite       = 307,
        scale        = 0.6,
        colorblip    = 0,
        NPCHash      = 'csb_trafficwarden',
        NPCPos       = vec4(-990.21435546875, -2949.2897949219, 12.945067405701, 239.44729614258),

    },
    ['Air Grand Senora'] = {
        impound      = false,
        impoundPrice = false,
        type         = 'air',
        impoundIn    = 'AirCraft Impound',
        job          = false,
        pos          = vec3(1691.5272216797, 3247.7075195313, 42.049549102783),
        size         = vec3(80, 80, 10),
        heading      = 242.03529357910156,
        SetInToVehicle = false,
        spawnpos     = {
            { x = 1693.6160888672, y = 3247.6115722656, z = 42.06803894043, w = 105.45626831055 },
        },
        blip         = true,
        sprite       = 307,
        scale        = 0.6,
        colorblip    = 0,
        NPCHash      = 'csb_trafficwarden',
        NPCPos       = vec4(1694.4133300781, 3267.849609375, 39.96208190918, 196.4981842041),

    },
    ['AirCraft Impound'] = {
        impound      = true,
        impoundPrice = 15000,
        type         = false,
        impoundIn    = false,
        job          = false,
        pos          = vec3(-1273.9510498047, -3384.6257324219, 14.940139770508),
        size         = vec3(80, 80, 10),
        heading      = 242.03529357910156,
        SetInToVehicle = false,
        spawnpos     = {
            { x = -1273.9510498047, y = -3384.6257324219, z = 14.940139770508, w = 327.82659912109375 },
        },
        blip         = true,
        sprite       = 307,
        scale        = 0.6,
        colorblip    = 0,
        NPCHash      = 'csb_trafficwarden',
        NPCPos       = vec4(-1284.7535400391, -3403.1101074219, 12.940143585205, 330.12164306641),

    },
    --- JOB GARAGE

    --Police
    ['Mission Row'] = {
        impound      = false,
        impoundPrice = false,
        type         = 'car',
        impoundIn    = 'Auto Impound',
        job          = 'police',
        pos          = vec3(435.595703125, -1019.4751586914, 28.816598892212),
        size         = vec3(15, 30, 3),
        heading      = 272.77542114258,
        SetInToVehicle = false,
        spawnpos     = {
            { x = 452.69467163086, y = -1007.8264770508, z = 27.408975601196, w = 180.98077392578 },
        },
        blip         = true,
        sprite       = 50,
        scale        = 0.6,
        colorblip    = 29,
        NPCHash      = 'csb_trafficwarden',
        NPCPos       = vec4(459.26806640625, -1008.0474853516, 27.258068084717, 92.018943786621),


    },
    ['Mission Row Air'] = {
        impound      = false,
        impoundPrice = false,
        type         = 'air',
        impoundIn    = 'AirCraft Impound',
        job          = 'police',
        pos          = vec3(450.50186157227, -981.42895507813, 43.404476165771),
        size         = vec3(20, 20, 5),
        heading      = 90.6708526611328,
        SetInToVehicle = false,
        spawnpos     = {
            { x = 450.50189208984, y = -981.42883300781, z = 43.404003143311, w = 90.670883178711 },
        },
        blip         = true,
        sprite       = 64,
        scale        = 0.6,
        colorblip    = 29,
        NPCHash      = 'csb_trafficwarden',
        NPCPos       = vec4(458.42761230469, -985.85266113281, 42.691696166992, 293.28179931641),

    },
    --Ambulance
    ['PillBox EMS'] = {
        impound      = false,
        impoundPrice = false,
        type         = 'car',
        impoundIn    = 'AirCraft Impound',
        job          = 'ambulance',
        pos          = vec3(329.1852722168, -575.96899414063, 28.796846389771),
        size         = vec3(15, 30, 2),
        heading      = 159.96160888671875,
        SetInToVehicle = false,
        spawnpos     = {
            { x = 333.36407470703, y = -575.63244628906, z = 28.384586334229, w = 338.10067749023 },
            { x = 325.93121337891, y = -572.48254394531, z = 28.384176254272, w = 339.78042602539 },
        },
        blip         = true,
        sprite       = 50,
        scale        = 0.6,
        colorblip    = 1,
        NPCHash      = 'csb_trafficwarden',
        NPCPos       = vec4(339.97662353516, -577.39678955078, 27.796838760376, 69.405403137207),


    },
    ['PillBox Air'] = {
        impound      = false,
        impoundPrice = false,
        type         = 'air',
        impoundIn    = 'AirCraft Impound',
        job          = 'ambulance',
        pos          = vec3(352.23852539063, -588.17376708984, 74.161697387695),
        size         = vec3(20, 20, 5),
        heading      = 159.96160888671875,
        SetInToVehicle = false,
        spawnpos     = {
            { x = 352.23303222656, y = -588.19903564453, z = 73.874557495117, w = 73.819213867188 },
        },
        blip         = true,
        sprite       = 64,
        scale        = 0.6,
        colorblip    = 1,
        NPCHash      = 'csb_trafficwarden',
        NPCPos       = vec4(341.15667724609, -590.27893066406, 73.161689758301, 359.56204223633),


    },
    --Paleto EMS
    ['Paleot Bay EMS'] = {
        impound      = false,
        impoundPrice = false,
        type         = 'car',
        impoundIn    = 'AirCraft Impound',
        job          = 'paletoems',
        pos          = vec3(-266.31524658203, 6335.0893554688, 32.363765716553),
        size         = vec3(15, 30, 2),
        heading      = 133.3769683837891,
        SetInToVehicle = false,
        spawnpos     = {
            { x = -257.8176574707, y = 6347.7309570313, z = 32.014705657959, w = 269.04821777344 },
        },
        blip         = true,
        sprite       = 50,
        scale        = 0.6,
        colorblip    = 1,
        NPCHash      = 'csb_trafficwarden',
        NPCPos       = vec4(-253.35675048828, 6338.904296875, 31.426189422607, 45.707008361816),



    },
}

--<-------------------------------------->--
--Notification
RegisterNetEvent('mono_garage:Notification')
AddEventHandler('mono_garage:Notification', function(msg)
    lib.notify({
        title = locale('Garaje'),
        description = msg,
        position = 'top',
        icon = 'car',
        iconColor = 'rgb(36,116,255)'
    })
end)
