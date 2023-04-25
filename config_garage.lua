--<-------------------------------------->--
--[[
▒█▀▀▀█ ▒█░░▒█ 　 ▒█▀▀█ ░█▀▀█ ▒█▀▀█ ░█▀▀█ ▒█▀▀█ ▒█▀▀▀
░▀▀▀▄▄ ▒█▄▄▄█ 　 ▒█░▄▄ ▒█▄▄█ ▒█▄▄▀ ▒█▄▄█ ▒█░▄▄ ▒█▀▀▀
▒█▄▄▄█ ░░▒█░░ 　 ▒█▄▄█ ▒█░▒█ ▒█░▒█ ▒█░▒█ ▒█▄▄█ ▒█▄▄▄]]
--<-------------------------------------->--

Garage = {}

Garage.Debug = false                -- Debug, prints etc...

Garage.RadialCopyCoords = true      -- Radial menu to copy coordinates and easily create garages, use this only on your development server!

Garage.OwnerCarAdmin = {            -- The vehicle you are in will be saved in the database and become your property. (ADMIN)
    Command = 'givecar',
    Group = 'admin',
} 

Garage.Persistent = {
    Persitent = true,                   -- Sistema de vehiculo persistente.
    DeleteCarDisconnect = true,         -- Cuando el jugador se desconecta y su vehiculo esta fuera del garaje se elimina y guarda la pos.
}
--<-------------------------------------->--

Garage.ShareCarFriend = true  -- Share vehicles with friends.

Garage.SaveKilometers = true  -- Save Kilometers in DB 

Garage.SetInToVehicle = true -- Set ped into vehicle upon spawn.

--<-------------------------------------->--
Garage.CarKeys = true         -- Add keys when removing the vehicle and remove them when depositing it.


--<-------------------------------------->--

--You can add the event of the script you use or use the one included in the garage. You can modify it from config_keys.lua.
Garage.AddKeyEvent = function(plate, name)
    TriggerServerEvent('sy_carkeys:CreateKey', plate, name)
end
Garage.DeleteKeyEvent = function(plate, name)
    TriggerServerEvent('sy_carkeys:DeleteKey', 1, plate, name)
end

--<-------------------------------------->--

Garage.NpcImpound = {
    NPCAnim = true,
    NpcHash = 's_m_m_dockwork_01',
    TimeDeleteVehicle = 15000,
    ProgressBarTime = 5000,
    Command = 'impound',
    jobs = {
        [1] = 'police',
        [2] = 'sheriff',
        [3] = 'ambulance',
        [4] = 'paletoems',
        [5] = 'trafico',
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
        spawnpos     = {
            { x = 407.93273925781, y = -1654.6179199219, z = 29.001836776733, h = 320.06909179688 },
            { x = 405.76379394531, y = -1652.2020263672, z = 29.002393722534, h = 320.41540527344 },
            { x = 403.46255493164, y = -1650.3392333984, z = 29.003999710083, h = 320.78207397461 },
            { x = 420.50085449219, y = -1638.8636474609, z = 29.002016067505, h = 269.73226928711 },
        },
        debug        = false,
        blip         = true,
        sprite       = 524,
        scale        = 0.6,
        colorblip    = 0,
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
        spawnpos     = {
            { x = -468.47308349609, y = 6038.390625,     z = 30.928045272827, h = 224.43283081055 },
            { x = -472.20770263672, y = 6035.0908203125, z = 30.928321838379, h = 225.26126098633 },
            { x = -475.53344726563, y = 6031.2236328125, z = 30.928354263306, h = 224.62934875488 },
            { x = -478.90426635742, y = 6027.5659179688, z = 30.928239822388, h = 224.27416992188 },
            { x = -482.52709960938, y = 6024.615234375,  z = 30.928611755371, h = 223.71766662598 },
        },
        debug        = false,
        blip         = true,
        sprite       = 524,
        scale        = 0.6,
        colorblip    = 0,
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
        spawnpos     = {
            { x = 220.05404663086, y = -809.19030761719, z = 30.382051467896, h = 247.63989257813 },
            { x = 221.07490539551, y = -806.69848632813, z = 30.390104293823, h = 248.47229003906 },
            { x = 222.11103820801, y = -804.14074707031, z = 30.38419342041,  h = 246.64263916016 },
            { x = 223.20907592773, y = -801.78698730469, z = 30.369050979614, h = 247.40501403809 },
            { x = 206.27438354492, y = -801.09350585938, z = 30.711149215698, h = 247.7689666748 },
            { x = 207.43371582031, y = -798.52429199219, z = 30.690946578979, h = 247.72959899902 },
            { x = 208.2936706543,  y = -796.23156738281, z = 30.672399520874, h = 248.55288696289 },
            { x = 209.48155212402, y = -793.83129882813, z = 30.646259307861, h = 249.14572143555 },
            { x = 215.1284942627,  y = -804.10589599609, z = 30.347541809082, h = 69.22452545166 },
            { x = 216.35070800781, y = -801.84881591797, z = 30.325912475586, h = 68.610794067383 },
            { x = 217.4236907959,  y = -799.2294921875,  z = 30.309574127197, h = 67.479904174805 },
            { x = 218.359375,      y = -796.85687255859, z = 30.297718048096, h = 67.339340209961 },
            { x = 233.58877563477, y = -805.39239501953, z = 29.968862533569, h = 69.095611572266 },
            { x = 232.12843322754, y = -807.85375976563, z = 29.973529815674, h = 68.418014526367 },
            { x = 231.43034362793, y = -810.4765625,     z = 30.428318023682, h = 68.37825012207 },

        },
        debug        = false,
        blip         = true,
        sprite       = 50,
        scale        = 0.6,
        colorblip    = 0,
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
        spawnpos     = {
            { x = -698.71136474609, y = -988.19073486328, z = 20.099597930908, h = 300.3828125 },
            { x = -701.25054931641, y = -985.26904296875, z = 20.099529266357, h = 298.08532714844 },
            { x = -703.17010498047, y = -982.14239501953, z = 20.099630355835, h = 299.89221191406 },
            { x = -705.10479736328, y = -979.02136230469, z = 20.099308013916, h = 299.97964477539 },
            { x = -686.54901123047, y = -982.19079589844, z = 20.100147247314, h = 86.923316955566 },
            { x = -686.50628662109, y = -975.06280517578, z = 20.10037612915,  h = 88.99080657959 },
            { x = -686.35290527344, y = -978.50183105469, z = 19.978174209595, h = 89.784156799316 },
        },
        debug        = false,
        blip         = true,
        sprite       = 50,
        scale        = 0.6,
        colorblip    = 0,
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
        spawnpos     = {
            { x = -207.30862426758, y = 6219.4477539063, z = 31.200904846191, h = 225.60264587402 },
            { x = -205.18788146973, y = 6221.8974609375, z = 31.201028823853, h = 226.04624938965 },
            { x = -202.69532775879, y = 6224.2993164063, z = 31.199897766113, h = 225.46133422852 },
            { x = -200.43357849121, y = 6226.60546875,   z = 31.204719543457, h = 225.56149291992 },
            { x = -197.94256591797, y = 6228.9672851563, z = 31.209632873535, h = 224.47320556641 },
        },
        debug        = false,
        blip         = true,
        sprite       = 50,
        scale        = 0.6,
        colorblip    = 0,
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
        spawnpos     = {
            { x = -727.81530761719, y = -1326.5987548828, z = -0.094071432948112, h = 229.80152893066 },
            { x = -733.33190917969, y = -1332.6695556641, z = -0.08595734834671,  h = 229.80354309082 },
            { x = -739.35668945313, y = -1339.9422607422, z = -0.095463529229164, h = 229.78338623047 },
            { x = -745.50311279297, y = -1347.1071777344, z = -0.070759519934654, h = 229.80442810059 },
            { x = -750.82720947266, y = -1353.5904541016, z = -0.11510844528675,  h = 229.79382324219 },
            { x = -757.01312255859, y = -1360.8302001953, z = -0.10407355427742,  h = 229.79582214355 },
            { x = -771.07604980469, y = -1377.4093017578, z = -0.089632928371429, h = 229.81011962891 },
            { x = -775.16369628906, y = -1385.5844726563, z = -0.088174432516098, h = 234.73382568359 },
            { x = -780.06219482422, y = -1391.9166259766, z = -0.041924431920052, h = 234.73052978516 },
            { x = -787.36322021484, y = -1398.3914794922, z = -0.065565600991249, h = 231.17677307129 },
            { x = -794.11889648438, y = -1405.9254150391, z = -0.078368499875069, h = 231.18263244629 },
            { x = -799.26190185547, y = -1412.4825439453, z = -0.063017770648003, h = 231.16915893555 },
        },
        debug        = false,
        blip         = true,
        sprite       = 427,
        scale        = 0.6,
        colorblip    = 0,
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
        spawnpos     = {
            { x = -1599.9913330078, y = 5260.8452148438, z = 0.45005643367767, h = 26.22989654541 },
        },
        debug        = false,
        blip         = true,
        sprite       = 427,
        scale        = 0.6,
        colorblip    = 0,
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
        spawnpos     = {
            { x = -808.94744873047, y = -1508.1628417969, z = -0.55900025367737, h = 114.28608703613 },
        },
        debug        = false,
        blip         = true,
        sprite       = 404,
        scale        = 0.6,
        colorblip    = 0,
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
        spawnpos     = {
            { x = -969.91619873047, y = -3002.1491699219, z = 13.656873703003, h = 59.526836395264 },
        },
        debug        = false,
        blip         = true,
        sprite       = 307,
        scale        = 0.6,
        colorblip    = 0,
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
        spawnpos     = {
            { x = 1693.6160888672, y = 3247.6115722656, z = 42.06803894043, h = 105.45626831055 },
        },
        debug        = false,
        blip         = true,
        sprite       = 307,
        scale        = 0.6,
        colorblip    = 0,
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
        spawnpos     = {
            { x = -1273.9510498047, y = -3384.6257324219, z = 14.940139770508, h = 327.82659912109375 },
        },
        debug        = false,
        blip         = true,
        sprite       = 307,
        scale        = 0.6,
        colorblip    = 0,
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
        spawnpos     = {
            { x = 452.69467163086, y = -1007.8264770508, z = 27.408975601196, h = 180.98077392578 },
        },
        debug        = false,
        blip         = true,
        sprite       = 50,
        scale        = 0.6,
        colorblip    = 29,
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
        spawnpos     = {
            { x = 450.50189208984, y = -981.42883300781, z = 43.404003143311, h = 90.670883178711 },
        },
        debug        = false,
        blip         = true,
        sprite       = 64,
        scale        = 0.6,
        colorblip    = 29,
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
        spawnpos     = {
            { x = 333.36407470703, y = -575.63244628906, z = 28.384586334229, h = 338.10067749023 },
            { x = 325.93121337891, y = -572.48254394531, z = 28.384176254272, h = 339.78042602539 },
        },
        debug        = false,
        blip         = true,
        sprite       = 50,
        scale        = 0.6,
        colorblip    = 1,
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
        spawnpos     = {
            { x = 352.23303222656, y = -588.19903564453, z = 73.874557495117, h = 73.819213867188 },
        },
        debug        = false,
        blip         = true,
        sprite       = 64,
        scale        = 0.6,
        colorblip    = 1,
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
        spawnpos     = {
            { x = 333.36407470703, y = -575.63244628906, z = 28.384586334229, h = 338.10067749023 },
            { x = 325.93121337891, y = -572.48254394531, z = 28.384176254272, h = 339.78042602539 },
        },
        debug        = false,
        blip         = true,
        sprite       = 50,
        scale        = 0.6,
        colorblip    = 1,
    },
}

--<-------------------------------------->--
--Notification
RegisterNetEvent('sy_garage:Notification')
AddEventHandler('sy_garage:Notification', function(msg)
    lib.notify({
        title = locale('Garaje'),
        description = msg,
        position = 'top',
        icon = 'car',
        iconColor = 'rgb(36,116,255)'
    })
end)
