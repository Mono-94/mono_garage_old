if Keys.Keys then
    lib.addKeybind({
        name = 'car_key',
        description = locale('keybindDesc'),
        defaultKey = Keys.KeyOpenClose,
        onPressed = function()
            local ped = cache.ped
            local playerCoords = GetEntityCoords(ped)
            local closet = lib.getClosestVehicle(playerCoords, Keys.Distance, true)
            local EstadoPuertas = GetVehicleDoorLockStatus(closet)
            if closet then
                local prop = GetHashKey('p_car_keys_01')

                RequestModel(prop)
                while not HasModelLoaded(prop) do
                    Wait(10)
                end
                local prop = CreateObject(prop, 1.0, 1.0, 1.0, 1, 1, 0)

                local dict = "anim@mp_player_intmenu@key_fob@"
                lib.requestAnimDict(dict)

                if not Sy.GetPlayerKey() then
                    TriggerEvent('sy_carkeys:Notification', locale('title'), locale('key_not_owned_car'), 'car',
                    '#3232a8')
                    return
                end
                if not IsPedInAnyVehicle(ped, true) then
                    AttachEntityToEntity(prop, ped, GetPedBoneIndex(ped, 57005), 0.08, 0.039, 0.0, 0.0, 0.0, 0.0, true,
                        true, false, true, 1, true)
                elseif not Sy.GetPlayerKey() then

                end
                if not IsPedInAnyVehicle(ped, true) then
                    TaskPlayAnim(ped, "anim@mp_player_intmenu@key_fob@", "fob_click_fp", 8.0, 8.0, -1, 48, 1, false,
                        false,
                        false)
                elseif not Sy.GetPlayerKey() then

                end


                TriggerServerEvent('sy_carkeys:ServerDoors', VehToNet(closet), EstadoPuertas)

                if EstadoPuertas == 2 then
                    TriggerEvent('sy_carkeys:Notification', locale('title'), locale('unlock_veh'), 'lock-open', '#32a852')
                    Wait(1000)
                    DetachEntity(prop, false, false)
                    DeleteEntity(prop)
                elseif EstadoPuertas == 0 then
                    TriggerEvent('sy_carkeys:Notification', locale('title'), locale('lock_veh'), 'lock', '#a83254')
                    Wait(1000)
                    DetachEntity(prop, false, false)
                    DeleteEntity(prop)
                end
            else
                TriggerEvent('sy_carkeys:Notification', locale('title'), locale('no_veh_nearby'), 'car', '#3232a8')
                return
            end
        end
    })






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
                    if Sy.GetPlayerKey() ~= nil and IsControlPressed(2, 75) then
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



    RegisterNetEvent('sy_carkeys:LucesLocas', function(netId, lockStatus)
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


    RegisterNetEvent('sy_carkeys:AddKeysCars')
    AddEventHandler('sy_carkeys:AddKeysCars', function()
        local ped = cache.ped
        local playerVehicle = GetVehiclePedIsIn(ped, false)
        if playerVehicle ~= 0 then
            local vehicleProps = lib.getVehicleProperties(playerVehicle)
            local model = GetEntityModel(playerVehicle)
            local name = GetDisplayNameFromVehicleModel(model)
            TriggerServerEvent('sy_carkeys:CreateKey', vehicleProps.plate, name)
        else
            TriggerEvent('sy_carkeys:Notification', locale('title'), locale('dentrocar'), 'car', '#3232a8')
        end
    end)

    RegisterNetEvent('sy_carkeys:DeleteClientKey')
    AddEventHandler('sy_carkeys:DeleteClientKey', function(count)
        local ped = cache.ped
        local playerVehicle = GetVehiclePedIsIn(ped, false)
        if playerVehicle ~= 0 then
            local vehicleProps = lib.getVehicleProperties(playerVehicle)
            local model = GetEntityModel(playerVehicle)
            local name = GetDisplayNameFromVehicleModel(model)
            TriggerServerEvent('sy_carkeys:DeleteKey', count, vehicleProps.plate, name)
        else
            TriggerEvent('sy_carkeys:Notification', locale('title'), locale('dentrocar'), 'car', '#3232a8')
        end
    end)




    function CarKey(time)
        local ped = cache.ped
        local pedcords = GetEntityCoords(ped)
        local car = lib.getClosestVehicle(pedcords, Keys.DistanceCreate, true)
        local model = GetEntityModel(car)
        local name = GetDisplayNameFromVehicleModel(model)
        local plate = GetVehicleNumberPlateText(car)
        if car == nil then
            TriggerEvent('sy_carkeys:Notification', locale('title'), locale('nocarcerca'), 'car', '#3232a8')
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
                TriggerServerEvent('sy_carkeys:CreateKey', plate, name)
            else
                TriggerEvent('sy_carkeys:Notification', locale('title'), locale('calcelado'), 'car', '#3232a8')
            end
        end
    end

    function CarKeyBuy(time)
        Wait(time)
        local ped = cache.ped
        local pedcords = GetEntityCoords(ped)
        local car = lib.getClosestVehicle(pedcords, Keys.DistanceCreate, true)
        local model = GetEntityModel(car)
        local name = GetDisplayNameFromVehicleModel(model)
        local plate = GetVehicleNumberPlateText(car)
        if car == nil then
            TriggerEvent('sy_carkeys:Notification', locale('title'), locale('nocarcerca'), 'car', '#3232a8')
        else
            TriggerServerEvent('sy_carkeys:CreateKey', plate, name)
        end
    end

    local vehiculocerrado = nil


    vehiculocerrado = SetInterval(function()
        local ped = cache.ped
        if DoesEntityExist(GetVehiclePedIsTryingToEnter(ped)) then
            local veh = GetVehiclePedIsTryingToEnter(ped)
            local lock = GetVehicleDoorLockStatus(veh)

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
                local ped = cache.ped
                local vehicle = GetVehiclePedIsIn(ped, false)
                local inCar = IsPedInAnyVehicle(ped, false)

                if inCar and vehicle ~= nil and vehicle ~= 0 then
                    local engineRunning = GetIsVehicleEngineRunning(vehicle)
                    if engineRunning then
                        --    print('activado')
                        EnableControlAction(2, 71, true)
                    else
                        --    print(' des activado')
                        --     SetVehicleEngineOn(vehicle, false, true, true)
                        DisableControlAction(2, 71, true)
                    end
                    Wait(0)
                else
                    Wait(0)
                end
            end
        end)


        local engineStatus = nil
        lib.addKeybind({
            name = 'motor',
            description = 'Apagar/Encender Motor',
            defaultKey = Keys.KeyToggleEngine,
            onPressed = function()
                local ped = cache.ped

                local vehicle = GetVehiclePedIsIn(ped, false)

                if not IsPedInAnyVehicle(ped, false) then
                    TriggerEvent('sy_carkeys:Notification', locale('title'),
                        locale('incar'), 'car', '#3232a8')
                    return
                end

                if not Sy.GetPlayerKey() then
                    TriggerEvent('sy_carkeys:Notification', locale('title'), locale('key_not_owned_car'), 'car',
                    '#3232a8')
                    return
                end
                if vehicle ~= nil and vehicle ~= 0 and GetPedInVehicleSeat(vehicle, 0) then
                    SetVehicleEngineOn(vehicle, (not GetIsVehicleEngineRunning(vehicle)), true, true)
                end

                if not (engineStatus) then
                    engineStatus = true
                else
                    engineStatus = false
                end
            end
        })
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
                        TriggerEvent('sy_carkeys:Notification', locale('LockPickTitle'), locale('NoLocPick'), 'car',
                        '#3232a8'
                        )
                        return
                    end
                    TaskPlayAnim(ped, v.animDict, v.anim, 8.0, 8.0, -1, 48, 1, false, false, false)
                    local success = lib.skillCheck(table.unpack(v.Skills))
                    if success then
                        ClearPedTasks(ped)
                        TriggerEvent('sy_carkeys:Notification', locale('LockPickTitle'), 'LockPick success', 'car',
                        '#3232a8'
                        )
                        TriggerServerEvent('sy_carkeys:ServerDoors', VehToNet(closet), GetVehicleDoorLockStatus(closet))
                        if math.random() < v.alarmProbability then
                            SetVehicleAlarmTimeLeft(closet, v.alarmTime)
                        end
                        if v.Disptach then
                            v.DispatchFunction()
                        end
                    else
                        ClearPedTasks(ped)
                        TriggerEvent('sy_carkeys:Notification', locale('LockPickTitle'), locale('LockPickFail'), 'car',
                        '#3232a8')
                    end
                else
                    if EstadoPuertas == 1 then
                        TriggerEvent('sy_carkeys:Notification', locale('LockPickTitle'), locale('NoLocPick'), 'car',
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
                        TriggerServerEvent('sy_carkeys:ServerDoors', VehToNet(closet), GetVehicleDoorLockStatus(closet))
                        if math.random() < v.alarmProbability then
                            SetVehicleAlarmTimeLeft(closet, v.alarmTime)
                        end
                        if v.Disptach then
                            v.DispatchFunction()
                            TriggerEvent('sy_carkeys:Dispatch')
                        end
                    else
                        if math.random() < v.alarmProbability then
                            SetVehicleAlarmTimeLeft(closet, v.alarmTime)
                        end
                        TriggerEvent('sy_carkeys:Notification', locale('LockPickTitle'), locale('LockPickFail'), 'car',
                        '#3232a8')
                    end
                end
            else
                TriggerEvent('sy_carkeys:Notification', locale('LockPickTitle'), locale('nocarcerca'), 'car', '#3232a8')
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
                        TriggerEvent('sy_carkeys:Notification', locale('HotWireTitle'), locale('HotWireFail'), 'car',
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
                        TriggerEvent('sy_carkeys:Notification', locale('HotWireTitle'), locale('HotWireFail'), 'car',
                        '#3232a8')
                    end
                end
            else
                TriggerEvent('sy_carkeys:Notification', locale('HotWireTitle'), locale('HotWireInCar'), 'car', '#3232a8')
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
                TriggerEvent('sy_carkeys:Notification', locale('title'), locale('MatriculaMax'), 'car', '#3232a8')
            else
                local vehicle = GetVehiclePedIsUsing(ped)
                local model = GetEntityModel(vehicle)
                local newName = GetDisplayNameFromVehicleModel(model)
                local newPlate = string.upper(input[1])
                local newColor = input[2]


                TriggerServerEvent('sy_carkeys:SetMatriculaServer', plate, newPlate, newColor, newName)
            end
        else
            TriggerEvent('sy_carkeys:Notification', locale('title'), locale('CambiarMatriDentro'), 'car', '#3232a8')
        end
    end

    RegisterNetEvent('sy_carkeys:SetMatricula')
    AddEventHandler('sy_carkeys:SetMatricula', function(newPlate, newColor)
        local vehicle = GetVehiclePedIsUsing(cache.ped)
        local plate = GetVehicleNumberPlateText(vehicle)
        local model = GetEntityModel(vehicle)
        local name = GetDisplayNameFromVehicleModel(model)
        SetVehicleNumberPlateText(vehicle, newPlate)
        SetVehicleNumberPlateTextIndex(vehicle, newColor)
        TriggerServerEvent('sy_carkeys:DeleteKey', 1, plate, name)
        TriggerServerEvent('sy_carkeys:CreateKey', newPlate, name)
        return newPlate, newColor, name
    end)




    exports('HotWire', HotWire)

    exports('LockPick', LockPick)

    exports('CarKeyBuy', CarKeyBuy)

    exports('CarKey', CarKey)

    exports('SetMatricula', SetMatricula)

    RegisterNetEvent('sy_carkeys:Motor')
    AddEventHandler('sy_carkeys:Motor', function(vehicle)
        SetVehicleEngineOn(vehicle, false, true, true)
    end)






    CreateThread(function()
        for k, v in pairs(Keys.NpcReclameKey) do
            RequestModel(v.hash)
            while not HasModelLoaded(v.hash) do
                Wait(100)
            end
            NPC = CreatePed(2, v.hash, v.pos.x, v.pos.y, v.pos.z, v.heading, false, false)
            SetPedFleeAttributes(NPC, 0, 0)
            SetPedDiesWhenInjured(NPC, false)
            TaskStartScenarioInPlace(NPC, v.PedScenario, 0, true)
            SetPedKeepTask(NPC, true)
            SetBlockingOfNonTemporaryEvents(NPC, true)
            SetEntityInvincible(NPC, true)
            FreezeEntityPosition(NPC, true)
            if v.blip then
                blip = AddBlipForCoord(v.pos.x, v.pos.y, v.pos.z)
                SetBlipSprite(blip, 186)
                SetBlipDisplay(blip, 4)
                SetBlipScale(blip, 1.0)
                SetBlipColour(blip, 4)
                SetBlipAsShortRange(blip, true)
                BeginTextCommandSetBlipName("STRING")
                AddTextComponentString(locale('cerrajero'))
                EndTextCommandSetBlipName(blip)
            end
            exports.ox_target:addBoxZone({
                coords = vec3(v.pos.x, v.pos.y, v.pos.z + 1),
                size = vec3(1, 1, 2),
                rotation = v.heading,
                debug = v.debug,
                options = {
                    {
                        icon = v.icon,
                        label = v.label,
                        onSelect = function()
                            local KeyMenu = {}
                            local vehicles = lib.callback.await('sy_carkeys:getVehicles')

                            if vehicles == nil then
                                TriggerEvent('sy_carkeys:Notification', locale('title'), locale('nopropio'), 'alert')
                                return
                            end
                            for i = 1, #vehicles do
                                local data = vehicles[i]
                                local name = GetDisplayNameFromVehicleModel(data.vehicle.model)
                                local marca = GetMakeNameFromVehicleModel(data.vehicle.model)
                                local plate = data.vehicle.plate
                                local price = Keys.CopyPrice


                                table.insert(KeyMenu, {
                                    title = marca .. ' - ' .. name,
                                    iconColor = 'green',
                                    icon = 'car',
                                    arrow = true,
                                    description = locale('matricula', plate),
                                    onSelect = function()
                                        local options = {}
                                        if v.BuyKey then
                                            table.insert(options, {
                                                title = locale('ComprarKey'),
                                                icon = 'key',
                                                arrow = true,
                                                description = locale('precio', price),
                                                image = 'nui://ox_inventory/web/images/' .. Keys.ItemName .. '.png',
                                                onSelect = function()
                                                    local alert = lib.alertDialog({
                                                        header = locale('buy_key_confirm1'),
                                                        content = locale('buy_key_confirm2', plate, marca, name,
                                                            price),
                                                        centered = true,
                                                        cancel = true
                                                    })
                                                    if alert == 'cancel' then
                                                        TriggerEvent('sy_carkeys:Notification', locale('title'),
                                                            locale('vuelve'),
                                                            'alert')
                                                        return
                                                    else
                                                        if lib.progressBar({
                                                                duration = Keys.CreateKeyTime,
                                                                label = locale('forjar'),
                                                                useWhileDead = false,
                                                                canCancel = false,
                                                                disable = {
                                                                    car = true,
                                                                },
                                                            })
                                                        then
                                                            TriggerServerEvent('sy_carkeys:BuyKeys', plate, name)
                                                        end
                                                    end
                                                end
                                            })
                                        end
                                        if v.BuyPlate then
                                            table.insert(options, {
                                                title = locale('Matricula'),
                                                icon = 'rectangle-list',
                                                arrow = true,
                                                description = locale('ComprarMatriDescri', Keys.PriceItemPlate),
                                                image = 'nui://ox_inventory/web/images/' .. Keys.ItemPlate .. '.png',
                                                serverEvent = 'sy_carkeys:ComprarMatricula'
                                            })
                                        end
                                        lib.registerContext({
                                            id = 'sy_carkeys:MenuCarSelect',
                                            title = name .. ' - ' .. marca,
                                            menu = 'sy_carkeys:SelectCarKey',
                                            options = options
                                        })


                                        lib.showContext('sy_carkeys:MenuCarSelect')
                                    end
                                })
                            end

                            lib.registerContext({
                                id = 'sy_carkeys:SelectCarKey',
                                title = locale('cerrajero'),
                                options = KeyMenu
                            })

                            lib.showContext('sy_carkeys:SelectCarKey')
                        end
                    }
                }
            })
        end
    end)
end
