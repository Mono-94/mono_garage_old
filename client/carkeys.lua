if Garage.Mono_Carkeys then
    local diley_key = false

    function GetPlayerKey()
        local closet = lib.getClosestVehicle(cache.coords, Keys.Distance, true)
        local plate = GetVehicleNumberPlateText(closet)
        if Keys.Inventory == 'ox' then
            local keys = exports.ox_inventory:Search('slots', Keys.ItemName)
            for i, v in ipairs(keys) do
                if PlateEqual(v.metadata.plate, plate) then
                    return true
                end
            end
        else
            local items = exports['qs-inventory']:getUserInventory()
            for item, meta in pairs(items) do
                if PlateEqual(meta.info.plate, plate) then
                    return true
                end
            end
        end

        return false
    end

    function AbrirCerrar()
        local ped = cache.ped
        local closet = lib.getClosestVehicle(cache.coords, Keys.Distance, true)
        local inCar = IsPedInAnyVehicle(ped, true)
        if closet then
            if not diley_key then
                if GetVehicleDoorLockStatus(closet) == 2 then
                    label = locale('unlock_veh')
                else
                    label = locale('lock_veh')
                end
                if Keys.Progress then
                    if not GetPlayerKey() then
                        return TriggerEvent('mono_carkeys:Notification', locale('title'), locale('key_not_owned_car'),
                            'car', '#3232a8')
                    end
                    if not inCar then
                        diley_key = true
                        if lib.progressBar({
                                duration = Keys.ProgressTime,
                                label = label,
                                useWhileDead = false,
                                canCancel = false,
                                disable = {
                                    car = true,
                                    combat = true,
                                },
                                anim = {
                                    dict = 'anim@mp_player_intmenu@key_fob@',
                                    clip = 'fob_click_fp'
                                },
                                prop = {
                                    model = 'p_car_keys_01',
                                    pos = vec3(0.08, 0.039, 0.0),
                                    rot = vec3(0.0, 0.0, 0.0),
                                    bone = 57005,
                                },
                            })
                        then
                            TriggerServerEvent('mono_carkeys:ServerDoors', VehToNet(closet))
                        end
                    else
                        diley_key = true
                        if lib.progressBar({
                                duration = Keys.ProgressTime,
                                label = label,
                                useWhileDead = false,
                                canCancel = false,
                                disable = {
                                    car = true,
                                    combat = true,
                                },
                            })
                        then
                            TriggerServerEvent('mono_carkeys:ServerDoors', VehToNet(closet))
                        end
                    end
                else
                    if not GetPlayerKey() then
                        return TriggerEvent('mono_carkeys:Notification', locale('title'), locale('key_not_owned_car'),
                            'car', '#3232a8')
                    end
                    diley_key = true
                    if not inCar then
                        RequestModel('p_car_keys_01')

                        while not HasModelLoaded('p_car_keys_01') do
                            Wait(1)
                        end
                        local prop = CreateObject('p_car_keys_01', 1.0, 1.0, 1.0, 1, 1, 0)

                        local dict = "anim@mp_player_intmenu@key_fob@"

                        lib.requestAnimDict(dict)

                        AttachEntityToEntity(prop, ped, GetPedBoneIndex(ped, 57005), 0.08, 0.039, 0.0, 0.0, 0.0, 0.0,
                            true, true, false, true, 1, true)
                        TaskPlayAnim(ped, "anim@mp_player_intmenu@key_fob@", "fob_click_fp", 8.0, 8.0, -1, 48, 1, false,
                            false, false)
                        TriggerServerEvent('mono_carkeys:ServerDoors', VehToNet(closet))
                        Citizen.Wait(1000)
                        DeleteObject(prop)
                    else
                        TriggerServerEvent('mono_carkeys:ServerDoors', VehToNet(closet))
                    end
                end
            end
        else
            TriggerEvent('mono_carkeys:Notification', locale('title'), locale('no_veh_nearby'), 'car', '#3232a8')
        end
    end

    function GetVehicleEngineState(vehicle)
        local state = GetVehicleEngineHealth(vehicle) > 0 and GetIsVehicleEngineRunning(vehicle)
        return state
    end

    RegisterNetEvent('mono_carkeys:SetSoundsAndLights', function(netId, status)
        local vehicle = NetToVeh(netId)
        if DoesEntityExist(vehicle) then
            if status == 2 then                                                                -- ProtonHorse
                PlayVehicleDoorCloseSound(vehicle, 1)
                PlaySoundFromEntity(-1, "Remote_Control_Fob", vehicle, "PI_Menu_Sounds", 1, 0) ---- PROTON
            else
                PlayVehicleDoorCloseSound(vehicle, 1)
                PlaySoundFromEntity(-1, "Remote_Control_Close", vehicle, "PI_Menu_Sounds", 1, 0) ---- PROTON
            end
            SetVehicleLights(vehicle, 2)
            Citizen.Wait(250)
            SetVehicleLights(vehicle, 0)
            Citizen.Wait(250)
            SetVehicleLights(vehicle, 2)
            Citizen.Wait(250)
            SetVehicleLights(vehicle, 0)
            Citizen.Wait(750)
            diley_key = false
        end
    end)

    local vehiculocerrado = nil

    vehiculocerrado = SetInterval(function()
        local ped = cache.ped
        local veh = GetVehiclePedIsTryingToEnter(ped)
        local lock = GetVehicleDoorLockStatus(veh)
        if DoesEntityExist(veh) then
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

                Wait(0)
            end
        end)

        if Keys.OnExitCar then
            local MotorOn = false
            local MotorOnSalir = nil
            MotorOnSalir = SetInterval(function()
                local vehicle = cache.vehicle
                if vehicle then
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
    end

    -- Funcitions

    local engineStatus = nil

    function ToggleEngine()
        local ped = cache.ped

        local vehicle = cache.vehicle

        if not IsPedInAnyVehicle(ped, false) then
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

    --Exports


    exports('ToggleEngine', ToggleEngine)


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


    CreateThread(function()
        for k, v in pairs(Keys.NpcReclameKey) do
            if v.Blip then
                CrearBlip(v.pos.xyz, v.Sprite, v.Scale, v.Colour, k)
            end

            local NPC = CreateNPC(v.hash, v.pos)

            TaskStartScenarioInPlace(NPC, v.PedScenario, 0, true)
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


local options = {
    {
        icon = 'fa-solid fa-window-maximize',
        label = 'Change Plate',
        distance = 2,
        canInteract = function(entity, distance, coords, name, bone)
            local plate = SP(lib.getVehicleProperties(entity).plate)
            local owner = lib.callback.await('mono_garage:ChangePlateOwner', source, plate)
            if not owner then return end
            local count = exports.ox_inventory:Search('count', Keys.ItemPlate)
            if count < 1 then return end
            return entity, distance, coords, name, bone
        end,
        onSelect = function(data)
            local pos = GetEntityBonePosition_2(data.entity, GetEntityBoneIndexByName(data.entity, 'platelight'))
            TaskGoStraightToCoord(cache.ped, pos.x + 0.7, pos.y, pos.z, 1.0, 10.0, GetEntityHeading(data.entity), 0.0)

            while true do
                Citizen.Wait(0)
                local ped = GetEntityCoords(cache.ped)
                local distance = Vdist2(ped.x, ped.y, ped.z, pos.x + 0.7, pos.y, pos.z)
                if distance < 0.5 then
                    print('aqui')
                    Citizen.Wait(500)
                    ClearPedTasksImmediately(cache.ped)
                    break
                end
            end
            local entityh = GetEntityHeading(data.entity)
            local vehicleProps = lib.getVehicleProperties(data.entity)
            local oldplate = SP(vehicleProps.plate)
            local input = lib.inputDialog(locale('MatriculaNueva'), {
                {
                    type = 'input',
                    icon = 'window-maximize',
                    disabled = true,
                    label = locale('DueñoDelVehiculo'),
                    required = false,
                    placeholder = oldplate
                },
                {
                    type = 'input',
                    label = locale('NuevaMatricula'),
                    required = true,
                    description = locale('MatriculaMax'),
                    min = 1,
                    max = 8
                },
                {
                    type = 'select',
                    icon = 'droplet',
                    required = true,
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
            local newPlate = string.upper(input[2])
            SetEntityHeading(cache.ped, entityh)
            SetVehicleNumberPlateTextIndex(data.entity, 0)
            SetVehicleNumberPlateText(data.entity, '')
            if lib.progressBar({
                    duration = 2000,
                    label = 'plate',
                    useWhileDead = false,
                    canCancel = true,
                    disable = {
                        car = true,
                        move = true,
                    },
                    anim = {
                        dict = 'anim@amb@clubhouse@tutorial@bkr_tut_ig3@',
                        clip = 'machinic_loop_mechandplayer',
                        flag = 1,

                    },
                    prop = {
                        model = 'p_num_plate_01',
                        pos = vec3(0.0, 0.2, 0.1),
                        rot = vec3(100, 100.0, 0.0)
                    },
                }) then
                TriggerServerEvent('mono_carkeys:SetMatriculaServer', oldplate, newPlate, data.entity, input[3])
            end
        end
    }
}

exports.ox_target:addGlobalVehicle(options)


RegisterNetEvent('mono_carkeys:SetVehiclePlate', function(entity, newPlate, color)
    SetVehicleNumberPlateTextIndex(entity, color)
    SetVehicleNumberPlateText(entity, newPlate)
end)


