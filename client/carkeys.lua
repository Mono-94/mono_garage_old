if Garage.Mono_Carkeys then
    function GetPlayerKey()
        local ped = cache.ped
        local playerCoords = GetEntityCoords(ped)
        local closet = lib.getClosestVehicle(playerCoords, Keys.Distance, true)
        local plate = GetVehicleNumberPlateText(closet)
        local keys = exports.ox_inventory:Search('slots', Keys.ItemName)

        for i, v in ipairs(keys) do
            if v.metadata.plate == plate then
                return v
            end
        end
        return nil
    end

    function AbrirCerrar()
        local ped = cache.ped
        local playerCoords = GetEntityCoords(ped)
        local closet = lib.getClosestVehicle(playerCoords, Keys.Distance, true)
        local prop = GetHashKey('p_car_keys_01')
        local inCar = IsPedInAnyVehicle(ped, true)
        if closet then
            RequestModel(prop)

            while not HasModelLoaded(prop) do
                Wait(1)
            end

            local prop = CreateObject(prop, 1.0, 1.0, 1.0, 1, 1, 0)

            local dict = "anim@mp_player_intmenu@key_fob@"

            lib.requestAnimDict(dict)

            if not GetPlayerKey() then
                TriggerEvent('mono_carkeys:Notification', locale('title'), locale('key_not_owned_car'), 'car',
                    '#3232a8')
                return
            end

            if not inCar then
                AttachEntityToEntity(prop, ped, GetPedBoneIndex(ped, 57005), 0.08, 0.039, 0.0, 0.0, 0.0, 0.0, true,
                    true, false, true, 1, true)
                TaskPlayAnim(ped, "anim@mp_player_intmenu@key_fob@", "fob_click_fp", 8.0, 8.0, -1, 48, 1, false,
                    false,
                    false)
            end

            TriggerServerEvent('mono_carkeys:ServerDoors', VehToNet(closet), prop)

            Wait(1500)

            DeleteObject(prop)
        else
            TriggerEvent('mono_carkeys:Notification', locale('title'), locale('no_veh_nearby'), 'car', '#3232a8')
        end
    end

    function GetVehicleEngineState(vehicle)
        local state = GetVehicleEngineHealth(vehicle) > 0 and GetIsVehicleEngineRunning(vehicle)
        return state
    end

    if Keys.OnExitCar then
        local MotorOn = false
        local MotorOnSalir = nil
        MotorOnSalir = SetInterval(function()
            local ped = cache.ped
            local vehicle = GetVehiclePedIsIn(ped, false)
            local inCar = IsPedInAnyVehicle(ped, false)
            if inCar and vehicle ~= nil and vehicle ~= 0 then
                if IsControlPressed(2, 75) then
                    Wait(100)
                    if GetPlayerKey() ~= nil and IsControlPressed(2, 75) then
                        Wait(100)
                        if not MotorOn and GetVehicleEngineState(vehicle) then
                            MotorOn = true
                        end
                        if MotorOn then
                            SetVehicleEngineOn(vehicle, true, true, false)
                        end
                    end
                else
                    if GetVehicleEngineState(vehicle) then
                        MotorOn = true
                    else
                        MotorOn = false
                    end
                end
            else
                SetInterval(MotorOnSalir, 500)
            end
        end, 10)
    end



    RegisterNetEvent('mono_carkeys:LucesLocas', function(netId, lockStatus)
        local vehicle = NetToVeh(netId)
        if DoesEntityExist(vehicle) then
            PlayVehicleDoorCloseSound(vehicle, 1)
            SetVehicleDoorsLockedForAllPlayers(vehicle, lockStatus)
            SetVehicleLights(vehicle, 2)
            Wait(250)
            SetVehicleLights(vehicle, 0)
            Wait(250)
            SetVehicleLights(vehicle, 2)
            Wait(250)
            SetVehicleLights(vehicle, 0)
            Wait(600)
        end
    end)


    RegisterNetEvent('mono_carkeys:AddKeysCars')
    AddEventHandler('mono_carkeys:AddKeysCars', function()
        local ped = cache.ped
        local playerVehicle = GetVehiclePedIsIn(ped, false)
        if playerVehicle ~= 0 then
            local vehicleProps = lib.getVehicleProperties(playerVehicle)
            TriggerServerEvent('mono_carkeys:CreateKey', vehicleProps.plate)
        else
            TriggerEvent('mono_carkeys:Notification', locale('title'), locale('dentrocar'), 'car', '#3232a8')
        end
    end)

    RegisterNetEvent('mono_carkeys:DeleteClientKey')
    AddEventHandler('mono_carkeys:DeleteClientKey', function(count)
        local ped = cache.ped
        local playerVehicle = GetVehiclePedIsIn(ped, false)
        if playerVehicle ~= 0 then
            local vehicleProps = lib.getVehicleProperties(playerVehicle)
            TriggerServerEvent('mono_carkeys:DeleteKey', count, vehicleProps.plate)
        else
            TriggerEvent('mono_carkeys:Notification', locale('title'), locale('dentrocar'), 'car', '#3232a8')
        end
    end)





    local vehiculocerrado = nil


    vehiculocerrado = SetInterval(function()
        local ped = cache.ped
        local veh = GetVehiclePedIsTryingToEnter(ped)
        local lock = GetVehicleDoorLockStatus(veh)
        if DoesEntityExist(GetVehiclePedIsTryingToEnter(ped)) then
            if lock == 2 then
                ClearPedTasks(ped)
            end

            if Keys.Engine then
                if lock == 0 then
                    if GetIsVehicleEngineRunning(veh) == false then
                        SetVehicleNeedsToBeHotwired(veh, false)
                        SetVehicleEngineOn(veh, false, true, true)
                    end
                end
                if GetIsVehicleEngineRunning(veh) == false then
                    return
                end
            end
        else
            SetInterval(vehiculocerrado, 500)
        end
    end, 0)



    if Keys.Engine then
        CreateThread(function()
            while true do
                local vehicle = cache.vehicle
                if vehicle then
                    if GetIsVehicleEngineRunning(vehicle) then
                        EnableControlAction(2, 71, true)
                    else
                        DisableControlAction(2, 71, true)
                    end
                end

                Wait(vehicle and 0 or 500)
            end
        end)
    end







    RegisterNetEvent('mono_carkeys:SetMatricula')
    AddEventHandler('mono_carkeys:SetMatricula', function(newPlate, newColor)
        local vehicle = GetVehiclePedIsUsing(cache.ped)
        local plate = GetVehicleNumberPlateText(vehicle)

        SetVehicleNumberPlateText(vehicle, newPlate)
        SetVehicleNumberPlateTextIndex(vehicle, newColor)
        TriggerServerEvent('mono_carkeys:DeleteKey', 1, plate)
        TriggerServerEvent('mono_carkeys:CreateKey', newPlate)
        return newPlate, newColor
    end)












    -- Funcitions

    local engineStatus = nil
    function ToggleEngine()
        local ped = cache.ped

        local vehicle = GetVehiclePedIsIn(ped, false)

        if not IsPedInAnyVehicle(ped, false) then
            TriggerEvent('mono_carkeys:Notification', locale('title'),
                locale('incar'), 'car', '#3232a8')
            return
        end

        if not GetPlayerKey() then
            TriggerEvent('mono_carkeys:Notification', locale('title'), locale('key_not_owned_car'), 'car',
                '#3232a8')
            return
        end
        if vehicle ~= nil and vehicle ~= 0 and GetPedInVehicleSeat(vehicle, 0) then
            SetVehicleEngineOn(vehicle, (not GetIsVehicleEngineRunning(vehicle)), true, true, true)
            engineStatus = not GetIsVehicleEngineRunning(vehicle)
        end
        if Keys.EngineNoti then
            if not (engineStatus) then
                TriggerEvent('mono_carkeys:Notification', locale('title'), locale('on'), 'bolt-lightning',
                    '#f6ff00')
            else
                TriggerEvent('mono_carkeys:Notification', locale('title'), locale('off'), 'bolt-lightning',
                    '#2f3000')
            end
        end
    end

    if Keys.FindKeys.FindKey then
        local searchedVehicles = {}
        function FindKeys()
            local coords = GetEntityCoords(cache.ped)
            local vehicle = lib.getClosestVehicle(coords, 0.5, true)
            local plate = GetVehicleNumberPlateText(vehicle)
            local vehicles = lib.callback.await('mono_carkeys:getVehicles')


            if vehicle then
                for i = 1, #vehicles do
                    local data = vehicles[i]
                    if data.plate == plate then
                        return TriggerEvent('mono_carkeys:Notification', locale('title'), 'Este vehiculo te pertenese')
                    end
                end

                if not searchedVehicles[plate] then
                    if lib.progressBar({
                            duration = Keys.FindKeys.ProgressTime,
                            label = locale('buscando'),
                            useWhileDead = false,
                            canCancel = false,
                            disable = {
                                car = false,
                            },
                        }) then
                        if math.random() > Keys.FindKeys.Probability then
                            TriggerEvent('mono_carkeys:Notification', locale('title'), locale('nokeysfound'))
                            searchedVehicles[plate] = true
                        else
                            TriggerEvent('mono_carkeys:Notification', locale('title'), locale('encontrada'))
                            TriggerServerEvent('mono_carkeys:CreateKey', plate)
                            searchedVehicles[plate] = true
                        end
                    end
                else
                    TriggerEvent('mono_carkeys:Notification', locale('title'), locale('buscado'))
                end
            else
                TriggerEvent('mono_carkeys:Notification', locale('title'), locale('dentrocar'))
            end
        end

        if Keys.FindKeys.FindKeyCommand then
            RegisterCommand(Keys.FindKeys.Command, function()
                FindKeys()
            end)
        end
    end



    function LockPick()
        for k, v in pairs(Keys.LockPick) do
            local ped = cache.ped
            local pedcords = GetEntityCoords(ped)
            local closet = lib.getClosestVehicle(pedcords, 3, true)
            local EstadoPuertas = GetVehicleDoorLockStatus(closet)
            lib.requestAnimDict(v.animDict)
            if closet then
                if v.SkillCheck then
                    if EstadoPuertas == 1 then
                        TriggerEvent('mono_carkeys:Notification', locale('LockPickTitle'), locale('NoLocPick'), 'car',
                            '#3232a8'
                        )
                        return
                    end
                    TaskPlayAnim(ped, v.animDict, v.anim, 8.0, 8.0, -1, 48, 1, false, false, false)
                    local success = lib.skillCheck(table.unpack(v.Skills))
                    if success then
                        ClearPedTasks(ped)
                        TriggerEvent('mono_carkeys:Notification', locale('LockPickTitle'), 'LockPick success', 'car',
                            '#3232a8'
                        )
                        TriggerServerEvent('mono_carkeys:ServerDoors', VehToNet(closet), GetVehicleDoorLockStatus(closet))
                        if math.random() < v.alarmProbability then
                            SetVehicleAlarmTimeLeft(closet, v.alarmTime)
                        end
                        if v.Disptach then
                            v.DispatchFunction()
                        end
                    else
                        ClearPedTasks(ped)
                        TriggerEvent('mono_carkeys:Notification', locale('LockPickTitle'), locale('LockPickFail'), 'car',
                            '#3232a8')
                    end
                else
                    if EstadoPuertas == 1 then
                        TriggerEvent('mono_carkeys:Notification', locale('LockPickTitle'), locale('NoLocPick'), 'car',
                            '#3232a8'
                        )
                        return
                    end
                    if lib.progressBar({
                            duration = v.TimeProgress,
                            label = locale('LocPickProgress'),
                            useWhileDead = false,
                            canCancel = false,
                            disable = {
                                car = true,
                            },
                            anim = {
                                dict = v.animDict,
                                clip = v.anim
                            },
                        }) then
                        TriggerServerEvent('mono_carkeys:ServerDoors', VehToNet(closet), GetVehicleDoorLockStatus(closet))
                        if math.random() < v.alarmProbability then
                            SetVehicleAlarmTimeLeft(closet, v.alarmTime)
                        end
                        if v.Disptach then
                            v.DispatchFunction()
                            TriggerEvent('mono_carkeys:Dispatch')
                        end
                    else
                        if math.random() < v.alarmProbability then
                            SetVehicleAlarmTimeLeft(closet, v.alarmTime)
                        end
                        TriggerEvent('mono_carkeys:Notification', locale('LockPickTitle'), locale('LockPickFail'), 'car',
                            '#3232a8')
                    end
                end
            else
                TriggerEvent('mono_carkeys:Notification', locale('LockPickTitle'), locale('nocarcerca'), 'car', '#3232a8')
            end
        end
    end

    function HotWire()
        for k, v in pairs(Keys.HotWire) do
            local ped = cache.ped
            local inVehicle2 = GetVehiclePedIsIn(ped, false)
            local inVehicle = IsPedInAnyVehicle(ped)
            lib.requestAnimDict(v.animDict)
            if inVehicle then
                if v.SkillCheck then
                    TaskPlayAnim(ped, v.animDict, v.anim, 8.0, 8.0, -1, 48, 1, false, false, false)
                    local success = lib.skillCheck(table.unpack(v.Skills))
                    if success then
                        local engineRunning = GetIsVehicleEngineRunning(inVehicle2)
                        if engineRunning then
                            SetVehicleEngineOn(inVehicle2, false, true, true)
                            if Keys.Debug then
                                print('Motor off')
                            end
                            DisableControlAction(2, 71, false)
                        else
                            SetVehicleEngineOn(inVehicle2, true, true, true)
                            if Keys.Debug then
                                print('Motor on')
                            end
                        end
                        ClearPedTasks(ped)
                    else
                        TriggerEvent('mono_carkeys:Notification', locale('HotWireTitle'), locale('HotWireFail'), 'car',
                            '#3232a8')
                    end
                else
                    if lib.progressBar({
                            duration = v.TimeProgress,
                            label = locale('LocPickProgress'),
                            useWhileDead = false,
                            canCancel = false,
                            disable = {
                                car = true,
                            },
                            anim = {
                                dict = v.animDict,
                                clip = v.anim
                            },
                        }) then
                        local engineRunning = GetIsVehicleEngineRunning(inVehicle2)
                        if engineRunning then
                            SetVehicleEngineOn(inVehicle2, false, true, true)
                            if Keys.Debug then
                                print('Motor off')
                            end
                        else
                            SetVehicleEngineOn(inVehicle2, true, true, true)
                            if Keys.Debug then
                                print('Motor on')
                            end
                        end
                    else
                        if math.random() < v.alarmProbability then
                            SetVehicleAlarmTimeLeft(inVehicle2, v.alarmTime)
                        end
                        TriggerEvent('mono_carkeys:Notification', locale('HotWireTitle'), locale('HotWireFail'), 'car',
                            '#3232a8')
                    end
                end
            else
                TriggerEvent('mono_carkeys:Notification', locale('HotWireTitle'), locale('HotWireInCar'), 'car',
                    '#3232a8')
            end
        end
    end

    function SetMatricula()
        local ped = cache.ped
        local inVehicle = IsPedInAnyVehicle(ped)

        if inVehicle then
            local vehicle = GetVehiclePedIsIn(ped, false)
            local plate = GetVehicleNumberPlateText(vehicle)

            local input = lib.inputDialog(locale('MatriculaNueva'), {
                {
                    type = 'input',
                    label = locale('ActualMatri', plate),
                    description = locale('MatriculaMax')
                },
                {
                    type = 'select',
                    label = locale('CambiarColorMatri'),
                    options = {
                        { value = 0, label = 'Blue / White' },
                        { value = 1, label = 'Yellow / black' },
                        { value = 2, label = 'Yellow / Blue' },
                        { value = 3, label = 'Blue/ White 2' },
                        { value = 4, label = 'Blue / White 3' },
                        { value = 5, label = 'Yankton' },
                    }
                },
            })
            if not input then return end
            local count = 0
            for i = 1, #input[1] do
                local c = string.sub(input[1], i, i)
                if c == ' ' then
                    count = count + 1
                else
                    count = count + utf8.len(c)
                end
            end

            if count > 8 or count == 0 then
                TriggerEvent('mono_carkeys:Notification', locale('title'), locale('MatriculaMax'), 'car', '#3232a8')
            else
                local newPlate = string.upper(input[1])
                local newColor = input[2]


                TriggerServerEvent('mono_carkeys:SetMatriculaServer', plate, newPlate, newColor)
            end
        else
            TriggerEvent('mono_carkeys:Notification', locale('title'), locale('CambiarMatriDentro'), 'car', '#3232a8')
        end
    end

    function CarKey(time)
        local ped = cache.ped
        local pedcords = GetEntityCoords(ped)
        local car = lib.getClosestVehicle(pedcords, Keys.DistanceCreate, true)
        local plate = GetVehicleNumberPlateText(car)
        if car == nil then
            TriggerEvent('mono_carkeys:Notification', locale('title'), locale('nocarcerca'), 'car', '#3232a8')
        else
            if lib.progressBar({
                    duration = time,
                    label = locale('forjar'),
                    useWhileDead = false,
                    canCancel = true,
                    disable = {
                        car = true,
                    },
                })
            then
                TriggerServerEvent('mono_carkeys:CreateKey', plate)
            else
                TriggerEvent('mono_carkeys:Notification', locale('title'), locale('calcelado'), 'car', '#3232a8')
            end
        end
    end

    --Exports

    exports('HotWire', HotWire)

    exports('LockPick', LockPick)

    exports('CarKey', CarKey)

    exports('SetMatricula', SetMatricula)

    exports('FindKeys', FindKeys)



    -- KeyBinds


    lib.addKeybind({
        name = 'mono_carkeys_openclose',
        description = locale('keybindDesc'),
        defaultKey = Keys.KeyOpenClose,
        onPressed = function()
            AbrirCerrar()
        end
    })

    if Keys.Engine then
        lib.addKeybind({
            name = 'mono_carkeys_toggleengine',
            description = 'Apagar/Encender Motor',
            defaultKey = Keys.KeyToggleEngine,
            onPressed = function()
                ToggleEngine()
            end
        })
    end

    if Keys.FindKeys.FindKeyBind then
        lib.addKeybind({
            name = 'mono_carkeys_search',
            description = 'Buscar llaves en el vehiculo',
            defaultKey = Keys.FindKeyBindKEY,
            onPressed = function()
                FindKeys()
            end
        })
    end


    function CreateBlip(Position, Sprite, Display, Scale, Colour, ShortRange, Name)
        local blip = AddBlipForCoord(Position.x, Position.y, Position.z)
        SetBlipSprite(blip, Sprite)
        SetBlipDisplay(blip, Display)
        SetBlipScale(blip, Scale)
        SetBlipColour(blip, Colour)
        SetBlipAsShortRange(blip, ShortRange)
        BeginTextCommandSetBlipName("STRING")
        AddTextComponentSubstringPlayerName(Name)
        EndTextCommandSetBlipName(blip)
    end

    function SetPedPos(Hash, Pos, Scenario)
        RequestModel(Hash)
        while not HasModelLoaded(Hash) do Wait(0) end
        NPC = CreatePed(2, Hash, Pos.x, Pos.y, Pos.z, Pos.w, false, false)
        SetPedFleeAttributes(NPC, 0, 0)
        SetPedDiesWhenInjured(NPC, false)
        if Scenario == false then else
            TaskStartScenarioInPlace(NPC, Scenario, 0, true)
        end
        SetPedKeepTask(NPC, true)
        SetBlockingOfNonTemporaryEvents(NPC, true)
        SetEntityInvincible(NPC, true)
        FreezeEntityPosition(NPC, true)
    end

    CreateThread(function()
        for k, v in pairs(Keys.NpcReclameKey) do
            if v.Blip then
                CreateBlip(v.pos, v.Sprite, v.Display, v.Scale, v.Colour, v.ShortRange, locale('cerrajero'))
            end
            SetPedPos(v.hash, v.pos, v.PedScenario)
            exports.ox_target:addBoxZone({
                coords = vec3(v.pos.x, v.pos.y, v.pos.z + 1),
                size = vec3(1, 1, 2),
                rotation = v.pos.w,
                debug = v.debug,
                options = {
                    {
                        icon = v.icon,
                        label = v.label,
                        onSelect = function()
                            MenuKeys(v.price, v.tiempoprogress)
                        end
                    }
                }
            })
        end
    end)


    function MenuKeys(precio, tiempoprogress)
        local KeyMenu = {}
        local vehicles = lib.callback.await('mono_carkeys:getVehicles')
        if vehicles == nil then
            TriggerEvent('mono_carkeys:Notification', locale('title'), locale('nopropio'), 'alert')
            return
        end
        for i = 1, #vehicles do
            local data = vehicles[i]
            local name = GetDisplayNameFromVehicleModel(data.vehicle.model)
            local marca = GetMakeNameFromVehicleModel(data.vehicle.model)
            local plate = data.vehicle.plate
            local price = precio
            table.insert(KeyMenu, {
                title = marca .. ' - ' .. name,
                iconColor = '#81cdeb',
                icon = 'car-side',
                arrow = true,
                description = locale('matricula', plate),
                metadata = { { label = 'Price', value = price .. '$' } },
                onSelect = function()
                    local alert = lib.alertDialog({
                        header = locale('buy_key_confirm1'),
                        content = locale('buy_key_confirm2', plate, marca, name,
                            price),
                        centered = true,
                        cancel = true
                    })
                    if alert == 'cancel' then
                        MenuKeys(price)
                        return
                    else
                        if lib.progressBar({
                                duration = tiempoprogress,
                                label = locale('forjar'),
                                useWhileDead = false,
                                canCancel = false,
                                disable = {
                                    car = true,
                                    move = true,

                                },
                                anim = {
                                    dict = 'missheistdockssetup1clipboard@base',
                                    clip = 'base'
                                },
                                prop = {
                                    model = `prop_notepad_01`,
                                    bone = 18905,
                                    pos = vec3(0.1, 0.02, 0.05),
                                    rot = vec3(10.0, 0.0, 0.0)
                                },
                            })
                        then
                            TriggerServerEvent('mono_carkeys:BuyKeys', plate, price)
                        end
                    end
                end
            })
        end
        lib.registerContext({
            id = 'mono_carkeys:SelectCarKey',
            title = locale('cerrajero'),
            options = KeyMenu
        })

        lib.showContext('mono_carkeys:SelectCarKey')
    end
end
