--─▄▄▀▀█▀▀▄▄       |
--▐▄▌─▀─▀─▐▄▌      |
--──█─▄▄▄─█──▄▄    |
--──▄█▄▄▄█▄─▐──▌   |
--▄█▀█████▐▌─▀─▐   |
--▀─▄██▀██▀█▀▄▄▀   | ─────────────────────────────────────|
-- symbiote_ - Discord: https://discord.gg/Vk7eY8xYV2     |
--────────────────────────────────────────────────────────|

Garage = {}

Garage.Debug = {
    Prints = false,               -- Prints data events, functions etc...
    Zones = false,                -- Garage Zones 
    Persistent = false,           -- Prints Persistent
    Autoimpound = false,          -- Autoimpound
}

Garage.RadialCopyCoords = true -- Radial menu to copy coordinates and easily create garages, use this only on your development server!

Garage.Version = true           -- Check GitHub version.

Garage.Target = true            -- If it's true, it will use ox_target, if it's false, Radial Menu will be used.

Garage.TargetNPCDistance = 2.5  -- Distance to open Menu in NPC

Garage.TargetCarDistance = 2.5  -- Distance to deposit the vehicle with ox_target

--<-------------------------------------->--
Garage.OwnerCarAdmin = {
    -- The vehicle you are in will be saved in the database and become your property. (ADMIN)
    Command = 'givecar', -- Command

    Group = 'admin',     -- Group

}

Garage.AutoImpound = {
    AutoImpound = true,         -- This function allows vehicles that are outside the garage and the entity is not present in the world to be sent directly to the impound.

    ImpoundIn = 'Auto Impound', -- The default impound where the vehicle will be sent if the entity does not exist in the world. (It has to match with an impound created.)

    TimeCheck = 1000 * 60,       --  (Default 1min) Time to check for vehicles that do not exist in the world and are not found in the garage in order to impound them.
}

Garage.Persistent = true      

--<-------------------------------------->--

Garage.ShareCarFriend = true -- Share vehicles with friends.

-- Garage.TrasnferVehicles = true  Work in
--<-------------------------------------->--

Garage.Mono_Carkeys = true -- Config_keys.lua / https://mono-2.gitbook.io/docs/mono-scrips/mono_carkeys

Garage.CarKeys = true      -- Add keys when removing the vehicle and remove them when depositing it.

--<-------------------------------------->--

Garage.NpcImpound = {
    NPCAnim = false,
    NPCHash = 's_m_m_dockwork_01',
    Command = 'impound',
    TimeDeleteVehicle = 15000,
    ProgressBarTime = 5000,
    jobs = {
        [1] = 'police',
        --[420] = '',   -- Add more jobs
    }
}

--<-------------------------------------->--

Garage.Garages = {
    -- Impound
    ['Auto Impound'] = {
        impound        = true,
        ShareGarage    = false,
        impoundPrice   = 100,
        type           = 'car',
        impoundIn      = false,
        job            = false,
        Society        = false,
        pos            = vec3(408.81500244141, -1637.9078369141, 29.291925430298),
        size           = vec3(15, 30, 3),
        heading        = 141.7584991455078,
        SetInToVehicle = false,
        spawnpos       = {
            vec4(407.93273925781, -1654.6179199219, 29.001836776733, 320.06909179688),
            vec4(405.76379394531, -1652.2020263672, 29.002393722534, 320.41540527344),
            vec4(403.46255493164, -1650.3392333984, 29.003999710083, 320.78207397461),
            vec4(420.50085449219, -1638.8636474609, 29.002016067505, 269.73226928711),
            vec4(420.73623657227, -1635.7631835938,28.879852294922,268.98785400391),
        },
        blip           = true,
        sprite         = 524,
        scale          = 0.6,
        colorblip      = 0,
        NPCHash        = 'csb_trafficwarden',
        NPCPos         = vec4(400.30816650391, -1627.5834960938, 28.291940689087, 230.88716125488),
    },
    ['Paleto Bay Impound'] = {
        impound        = true,
        ShareGarage    = false,
        impoundPrice   = 50,
        type           = 'car',
        impoundIn      = false,
        job            = false,
        Society        = false,
        pos            = vec3(-469.83917236328, 6032.5634765625, 31.34037399292),
        size           = vec3(15, 40, 3),
        heading        = 313.0982666015625,
        SetInToVehicle = true,
        spawnpos       = {
            vec4(-468.47308349609, 6038.390625, 30.928045272827, 224.43283081055),
            vec4(-472.20770263672, 6035.0908203125, 30.928321838379, 225.26126098633),
            vec4(-475.53344726563, 6031.2236328125, 30.928354263306, 224.62934875488),
            vec4(-478.90426635742, 6027.5659179688, 30.928239822388, 224.27416992188),
            vec4(-482.52709960938, 6024.615234375, 30.928611755371, 223.71766662598),
        },
        blip           = true,
        sprite         = 524,
        scale          = 0.6,
        colorblip      = 0,
        NPCHash        = 'csb_trafficwarden',
        NPCPos         = vec4(-463.06100463867, 6025.5874023438, 30.44896697998, 135.05729675293),

    },
    -- Garage
    ['Pillbox Hill'] = {
        impound        = false,
        ShareGarage    = false,
        impoundPrice   = false,
        type           = 'car',
        impoundIn      = 'Auto Impound',
        job            = false,
        pos            = vec3(227.27825927734, -785.90087890625, 30.716024398804),
        size           = vec3(55, 35, 5),
        heading        = 250.1240,
        SetInToVehicle = false,
        spawnpos       = {
            vec4(220.2780456543, -809.17193603516, 30.056179046631, 249.62936401367),
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
        blip           = true,
        sprite         = 50,
        scale          = 0.6,
        colorblip      = 0,
        NPCHash        = 'csb_trafficwarden',
        NPCPos         = vec4(214.69429016113, -807.11199951172, 29.800384521484, 339.01174926758),

    },
    ['Beach Garage'] = {
        impound        = false,
        ShareGarage    = false,
        impoundPrice   = false,
        type           = 'car',
        impoundIn      = 'Auto Impound',
        job            = false,
        pos            = vector4(-1186.9885253906, -1485.1993408203,4.3795204162598,125.26085662842),
        size           = vec3(34, 43, 5),
        heading        = 35.44283294677734,
        SetInToVehicle = false,
        spawnpos       = {
            vector4(-1183.7606201172, -1496.3354492188,3.9706411361694,124.90840148926),
            vector4(-1185.7902832031, -1493.615234375,3.9681849479675,125.64490509033),
            vector4(-1187.5167236328, -1490.9871826172,3.9701550006866,124.67469787598),
            vector4(-1189.0646972656, -1488.5158691406,3.9695651531219,123.46624755859),
            vector4(-1191.1324462891, -1485.9688720703,3.9685642719269,126.22340393066),
            vector4(-1192.7150878906, -1483.1861572266,3.9685180187225,124.46572113037),
            vector4(-1194.4948730469, -1480.1081542969,3.970828294754,124.8539276123),
            vector4(-1204.2700195313, -1484.6954345703,3.9610035419464,305.99017333984),
            vector4(-1202.2098388672, -1488.3464355469,3.9569838047028,306.90289306641),
            vector4(-1198.900390625, -1490.4631347656,3.9644057750702,306.28082275391),
            vector4(-1197.5792236328, -1493.8762207031,3.9614400863647,307.00152587891),
            vector4(-1196.1829833984, -1497.0876464844,3.9586639404297,304.75402832031),
            vector4(-1190.4721679688, -1503.7625732422,3.9637606143951,307.09887695313),
        },
        blip           = true,
        sprite         = 50,
        scale          = 0.6,
        colorblip      = 0,
        NPCHash        = 'csb_trafficwarden',
        NPCPos         = vector4(-1179.2971191406, -1494.8515625,3.379668712616,210.91143798828),

    },
    ['VineWood Center'] = {
        impound        = false,
        ShareGarage    = false,
        impoundPrice   = false,
        type           = 'car',
        impoundIn      = 'Auto Impound',
        job            = false,
        pos            = vector4(372.28897094727, 280.52334594727,102.97301483154,70.706298828125),
        size           = vec3(34, 43, 5),
        heading        = 70.706298828125,
        SetInToVehicle = false,
        spawnpos       = {
            vector4(374.85760498047, 294.43109130859,102.86688995361,165.0818939209),
            vector4(378.56265258789, 293.04306030273,102.78726959229,163.20666503906),
            vector4(382.55520629883, 291.36309814453,102.70172119141,163.94944763184),
            vector4(386.67111206055, 290.53021240234,102.63737487793,164.09982299805),
            vector4(390.22622680664, 288.65908813477,102.58652496338,164.05674743652),
            vector4(361.58099365234, 293.32504272461,103.08926391602,249.62924194336),
            vector4(360.5810546875, 289.76022338867,103.07821655273,247.47273254395),
            vector4(358.81109619141, 286.13931274414,103.07056427002,253.79345703125),
            vector4(357.28283691406, 282.52239990234,102.99289703369,253.17288208008),
            vector4(360.27276611328, 272.29049682617,102.69003295898,338.95504760742),
            vector4(363.72314453125, 269.96838378906,102.65316009521,340.4401550293),
            vector4(370.71759033203, 284.26663208008,102.8475112915,336.60717773438),
            vector4(374.66918945313, 282.80575561523,102.77003479004,336.00482177734),
        },
        blip           = true,
        sprite         = 50,
        scale          = 0.6,
        colorblip      = 0,
        NPCHash        = 'csb_trafficwarden',
        NPCPos         = vector4(363.22973632813, 298.1669921875,102.88312530518,252.08975219727),

    },

--[[    --Truck and Trailer garage (work-in)
    ['Elysian Island Truck'] = {
        impound        = false,
        ShareGarage    = false,
        impoundPrice   = false,
        type           = 'car',
        impoundIn      = 'Truck Impound',
        job            = false,
        pos            = vector4(153.26777648926, -2819.2109375,6.0001978874207,6.0922379493713),
        size           = vec3(70, 80, 5),
        heading        = 267.8787536621094,
        SetInToVehicle = false,
        spawnpos       = {
            vector4(374.85760498047, 294.43109130859,102.86688995361,165.0818939209),
        },
        blip           = true,
        sprite         = 50,
        scale          = 0.6,
        colorblip      = 0,
        NPCHash        = 'csb_trafficwarden',
        NPCPos         = vector4(157.4217376709, -2828.09375,5.1511669158936,177.23825073242),

    },]]
    ['Grape Seed'] = {
        impound        = false,
        ShareGarage    = false,
        impoundPrice   = false,
        type           = 'car',
        impoundIn      = 'Paleto Bay Impound',
        job            = false,
        pos            = vector4(1700.13671875, 4931.6333007813, 42.078128814697, 62.388843536377),
        size           = vec3(40, 30, 5),
        heading        = 57.604652404785,
        SetInToVehicle = true,
        spawnpos       = {
            vec4(1695.2021484375, 4940.17578125, 40.75191116333, 99.631744384766)


        },
        blip           = true,
        sprite         = 50,
        scale          = 0.6,
        colorblip      = 0,
        NPCHash        = 'csb_trafficwarden',
        NPCPos         = vector4(1700.13671875, 4931.6333007813, 41.078128814697, 62.388843536377),

    },
    ['Little Seoul'] = {
        impound        = false,
        ShareGarage    = false,
        impoundPrice   = false,
        type           = 'car',
        impoundIn      = 'Auto Impound',
        job            = false,
        pos            = vec3(-697.75500488281, -981.04711914063, 20.390176773071),
        size           = vec3(20, 15, 5),
        heading        = 351.32122802734375,
        SetInToVehicle = true,
        spawnpos       = {
            vec4(-698.71136474609, -988.19073486328, 20.099597930908, 300.3828125),
            vec4(-701.25054931641, -985.26904296875, 20.099529266357, 298.08532714844),
            vec4(-703.17010498047, -982.14239501953, 20.099630355835, 299.89221191406),
            vec4(-705.10479736328, -979.02136230469, 20.099308013916, 299.97964477539),
            vec4(-686.54901123047, -982.19079589844, 20.100147247314, 86.923316955566),
            vec4(-686.50628662109, -975.06280517578, 20.10037612915, 88.99080657959),
            vec4(-686.35290527344, -978.50183105469, 19.978174209595, 89.784156799316),
        },
        blip           = true,
        sprite         = 50,
        scale          = 0.6,
        colorblip      = 0,
        NPCHash        = 'csb_trafficwarden',
        NPCPos         = vec4(-702.84808349609, -970.89501953125, 19.389713287354, 179.47773742676),

    },
    ['Paleto Bay'] = {
        impound        = false,
        ShareGarage    = false,
        impoundPrice   = false,
        type           = 'car',
        impoundIn      = 'Auto Impound',
        job            = false,
        pos            = vec3(-199.8488, 6216.9556, 31.1998),
        size           = vec3(27, 27, 3),
        heading        = 226.0117,
        SetInToVehicle = true,
        spawnpos       = {
            vec4(-207.30862426758, 6219.4477539063, 31.200904846191, 225.60264587402),
            vec4(-205.18788146973, 6221.8974609375, 31.201028823853, 226.04624938965),
            vec4(-202.69532775879, 6224.2993164063, 31.199897766113, 225.46133422852),
            vec4(-200.43357849121, 6226.60546875, 31.204719543457, 225.56149291992),
            vec4(-197.94256591797, 6228.9672851563, 31.209632873535, 224.47320556641),
        },
        blip           = true,
        sprite         = 50,
        scale          = 0.6,
        colorblip      = 0,
        NPCHash        = 'csb_trafficwarden',
        NPCPos         = vec4(-215.56448364258, 6219.1748046875, 30.491662979126, 225.76336669922),

    },
    -- BOAT GARAGES
    ['La Puerta Boat'] = {
        impound        = false,
        ShareGarage    = false,
        impoundPrice   = false,
        type           = 'boat',
        impoundIn      = 'Boat Impound',
        job            = false,
        pos            = vec3(-761.92810058594, -1370.1292724609, -0.47471886873245),
        size           = vec3(21, 126, 5),
        heading        = 140.1520,
        SetInToVehicle = true,
        spawnpos       = {
            vec4(-727.81530761719, -1326.5987548828, -0.094071432948112, 229.80152893066),
            vec4(-733.33190917969, -1332.6695556641, -0.08595734834671, 229.80354309082),
            vec4(-739.35668945313, -1339.9422607422, -0.095463529229164, 229.78338623047),
            vec4(-745.50311279297, -1347.1071777344, -0.070759519934654, 229.80442810059),
            vec4(-750.82720947266, -1353.5904541016, -0.11510844528675, 229.79382324219),
            vec4(-757.01312255859, -1360.8302001953, -0.10407355427742, 229.79582214355),
            vec4(-771.07604980469, -1377.4093017578, -0.089632928371429, 229.81011962891),
            vec4(-775.16369628906, -1385.5844726563, -0.088174432516098, 234.73382568359),
            vec4(-780.06219482422, -1391.9166259766, -0.041924431920052, 234.73052978516),
            vec4(-787.36322021484, -1398.3914794922, -0.065565600991249, 231.17677307129),
            vec4(-794.11889648438, -1405.9254150391, -0.078368499875069, 231.18263244629),
            vec4(-799.26190185547, -1412.4825439453, -0.063017770648003, 231.16915893555),
        },
        blip           = true,
        sprite         = 427,
        scale          = 0.6,
        colorblip      = 0,
        NPCHash        = 'csb_trafficwarden',
        NPCPos         = vec4(-718.55004882813, -1326.7746582031, 0.5962884426117, 48.328620910645),

    },
    ['Paleto Cove'] = {
        impound        = false,
        ShareGarage    = false,
        impoundPrice   = false,
        type           = 'boat',
        impoundIn      = 'Boat Impound',
        job            = false,
        pos            = vec3(-1590.1145019531, 5263.9028320313, 0.36925473809242),
        size           = vec3(35, 20, 7),
        heading        = 25.3668098449707,
        SetInToVehicle = true,
        spawnpos       = {
            vec4(-1599.9913330078, 5260.8452148438, 0.45005643367767, 26.22989654541)
        },
        blip           = true,
        sprite         = 427,
        scale          = 0.6,
        colorblip      = 0,
        NPCHash        = 'csb_trafficwarden',
        NPCPos         = vec4(-1604.6020507813, 5256.5966796875, 1.0740420818329, 27.048063278198),

    },
    ['Boat Impound'] = {
        impound        = true,
        ShareGarage    = false,
        impoundPrice   = 1431,
        type           = 'boat',
        impoundIn      = false,
        job            = false,
        Society        = false,
        pos            = vec3(-781.90472412109, -1497.3582763672, 1.2815128564835),
        size           = vec3(80, 80, 10),
        heading        = 242.03529357910156,
        SetInToVehicle = true,
        spawnpos       = {
            vec4(-808.94744873047, -1508.1628417969, -0.55900025367737, 114.28608703613),
        },
        blip           = true,
        sprite         = 404,
        scale          = 0.6,
        colorblip      = 0,
        NPCHash        = 'csb_trafficwarden',
        NPCPos         = vec4(-788.95941162109, -1490.6604003906, 0.5952168703079, 289.04177856445),

    },
    -- AIRCRAFT GARAGE
    ['Aeropuerto INYL. de los Santos'] = {
        impound        = false,
        ShareGarage    = false,
        impoundPrice   = false,
        type           = 'air',
        impoundIn      = 'AirCraft Impound',
        job            = false,
        pos            = vec3(-973.48748779297, -2997.5534667969, 13.944133758545),
        size           = vec3(80, 80, 10),
        heading        = 242.03529357910156,
        SetInToVehicle = true,
        spawnpos       = {
            vec4(-969.91619873047, -3002.1491699219, 13.656873703003, 59.526836395264),
        },
        blip           = true,
        sprite         = 307,
        scale          = 0.6,
        colorblip      = 0,
        NPCHash        = 'csb_trafficwarden',
        NPCPos         = vec4(-990.21435546875, -2949.2897949219, 12.945067405701, 239.44729614258),

    },
    ['Air Grand Senora'] = {
        impound        = false,
        ShareGarage    = false,
        impoundPrice   = false,
        type           = 'air',
        impoundIn      = 'AirCraft Impound',
        job            = false,
        pos            = vec3(1691.5272216797, 3247.7075195313, 42.049549102783),
        size           = vec3(80, 80, 10),
        heading        = 242.03529357910156,
        SetInToVehicle = true,
        spawnpos       = {
            vec4(1693.6160888672, 3247.6115722656, 42.06803894043, 105.45626831055),
        },
        blip           = true,
        sprite         = 307,
        scale          = 0.6,
        colorblip      = 0,
        NPCHash        = 'csb_trafficwarden',
        NPCPos         = vec4(1694.4133300781, 3267.849609375, 39.96208190918, 196.4981842041),

    },
    ['AirCraft Impound'] = {
        impound        = true,
        ShareGarage    = false,
        impoundPrice   = 15000,
        type           = 'air',
        impoundIn      = false,
        job            = false,
        Society        = false,
        pos            = vec3(-1273.9510498047, -3384.6257324219, 14.940139770508),
        size           = vec3(80, 80, 10),
        heading        = 242.03529357910156,
        SetInToVehicle = true,
        spawnpos       = {
            vec4(-1273.9510498047, -3384.6257324219, 14.940139770508, 327.8265991210935),
        },
        blip           = true,
        sprite         = 307,
        scale          = 0.6,
        colorblip      = 0,
        NPCHash        = 'csb_trafficwarden',
        NPCPos         = vec4(-1284.7535400391, -3403.1101074219, 12.940143585205, 330.12164306641),

    },

    --JOB GARAGE

    --Police

    ['Mission Row'] = {
        impound        = false,
        ShareGarage    = false,
        impoundPrice   = false,
        type           = 'car',
        impoundIn      = 'Auto Impound',
        job            = 'police',
        pos            = vec3(435.595703125, -1019.4751586914, 28.816598892212),
        size           = vec3(15, 30, 3),
        heading        = 272.77542114258,
        SetInToVehicle = true,
        spawnpos       = {
            vec4(452.69467163086, -1007.8264770508, 27.408975601196, 180.98077392578),
        },
        blip           = true,
        sprite         = 50,
        scale          = 0.6,
        colorblip      = 29,
        NPCHash        = 'csb_trafficwarden',
        NPCPos         = vec4(459.26806640625, -1008.0474853516, 27.258068084717, 92.018943786621),


    },

    ['Mission Row Air'] = {
        impound        = false,
        ShareGarage    = false,
        impoundPrice   = false,
        type           = 'air',
        impoundIn      = 'AirCraft Impound',
        job            = 'police',
        pos            = vec3(450.50186157227, -981.42895507813, 43.404476165771),
        size           = vec3(20, 20, 5),
        heading        = 90.6708526611328,
        SetInToVehicle = true,
        spawnpos       = {
            vec4(450.50189208984, -981.42883300781, 43.404003143311, 90.670883178711),
        },
        blip           = true,
        sprite         = 64,
        scale          = 0.6,
        colorblip      = 29,
        NPCHash        = 'csb_trafficwarden',
        NPCPos         = vec4(458.42761230469, -985.85266113281, 42.691696166992, 293.28179931641),

    },

    ['Mission Row Impound'] = {
        impound        = true,
        ShareGarage    = false,
        impoundPrice   = false,
        type           = 'car',
        impoundIn      = false,
        job            = 'police',
        Society        = 'society_police',
        pos            = vec4(474.15145874023, -1095.3350830078,29.202104568481,155.19471740723),
        size           = vec3(15, 30, 3),
        heading        = 270.60968017578,
        SetInToVehicle = false,
        spawnpos       = {
            vec4(442.40338134766, -1020.0192260742,28.22324180603,90.319671630859),
        },
        blip           = true,
        sprite         = 524,
        scale          = 0.6,
        colorblip      = 0,
        NPCHash        = 'csb_trafficwarden',
        NPCPos         = vec4(458.69915771484, -1017.1785888672,27.191934585571,98.036026000977),
    },

    --Ambulance

    ['PillBox EMS'] = {
        impound        = false,
        ShareGarage    = false,
        impoundPrice   = false,
        type           = 'car',
        impoundIn      = 'AirCraft Impound',
        job            = 'ambulance',
        pos            = vec3(329.1852722168, -575.96899414063, 28.796846389771),
        size           = vec3(15, 30, 2),
        heading        = 159.96160888671875,
        SetInToVehicle = true,
        spawnpos       = {
            vec4(333.36407470703, -575.63244628906, 28.384586334229, 338.10067749023),
            vec4(325.93121337891, -572.48254394531, 28.384176254272, 339.78042602539),
        },
        blip           = true,
        sprite         = 50,
        scale          = 0.6,
        colorblip      = 1,
        NPCHash        = 'csb_trafficwarden',
        NPCPos         = vec4(339.97662353516, -577.39678955078, 27.796838760376, 69.405403137207),


    },
    ['PillBox Air'] = {
        impound        = false,
        ShareGarage    = false,
        impoundPrice   = false,
        type           = 'air',
        impoundIn      = 'AirCraft Impound',
        job            = 'ambulance',
        pos            = vec3(352.23852539063, -588.17376708984, 74.161697387695),
        size           = vec3(20, 20, 5),
        heading        = 159.96160888671875,
        SetInToVehicle = true,
        spawnpos       = {
            vec4(352.23303222656, -588.19903564453, 73.874557495117, 73.819213867188),
        },
        blip           = true,
        sprite         = 64,
        scale          = 0.6,
        colorblip      = 1,
        NPCHash        = 'csb_trafficwarden',
        NPCPos         = vec4(341.15667724609, -590.27893066406, 73.161689758301, 359.56204223633),


    },
    --Paleto EMS
    ['Paleot Bay EMS'] = {
        impound        = false,
        ShareGarage    = false,
        impoundPrice   = false,
        type           = 'car',
        impoundIn      = 'AirCraft Impound',
        job            = 'paletoems',
        pos            = vec3(-266.31524658203, 6335.0893554688, 32.363765716553),
        size           = vec3(15, 30, 2),
        heading        = 133.3769683837891,
        SetInToVehicle = true,
        spawnpos       = {
            vec4(-257.8176574707, 6347.7309570313, 32.014705657959, 269.04821777344),
        },
        blip           = true,
        sprite         = 50,
        scale          = 0.6,
        colorblip      = 1,
        NPCHash        = 'csb_trafficwarden',
        NPCPos         = vec4(-253.35675048828, 6338.904296875, 31.426189422607, 45.707008361816),



    },
}


