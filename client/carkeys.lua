if Garage.Mono_Carkeys then
    function GetPlayerKey()
        local closet = lib.getClosestVehicle(cache.coords, Keys.Distance, true)
        local props = lib.getVehicleProperties(closet)
        local keys = exports.ox_inventory:Search('slots', Keys.ItemName)

        for i, v in ipairs(keys) do
            if SP(v.metadata.plate) == SP(props.plate) then
                return true
            end
        end

        return false
    end

    function AbrirCerrar()
        local ped = cache.ped
        local closet = lib.getClosestVehicle(cache.coords, Keys.Distance, true)
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

            TriggerServerEvent('mono_carkeys:ServerDoors', VehToNet(closet))

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


    RegisterNetEvent('mono_carkeys:AddKeysCars', function()
        local playerVehicle = cache.vehicle
        if playerVehicle then
            local vehicleProps = lib.getVehicleProperties(playerVehicle)
            TriggerServerEvent('mono_carkeys:CreateKey', vehicleProps.plate)
        else
            TriggerEvent('mono_carkeys:Notification', locale('title'), locale('dentrocar'), 'car', '#3232a8')
        end
    end)

    RegisterNetEvent('mono_carkeys:DeleteClientKey', function(count)
        local playerVehicle = cache.vehicle
        if playerVehicle then
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
        distance = 1,
        canInteract = function(entity, distance, coords, name, bone)
            local plate = SP(lib.getVehicleProperties(entity).plate)
            local owner = lib.callback.await('mono_garage:ChangePlateOwner', source, plate)
            if not owner then return end
            local count = exports.ox_inventory:Search('count', Keys.ItemPlate)
            if count < 1 then return end
            return #(coords - GetEntityBonePosition_2(entity, GetEntityBoneIndexByName(entity, 'platelight'))) < 0.4
        end,
        onSelect = function(data)
            local entityh = GetEntityHeading(data.entity)
            local vehicleProps = lib.getVehicleProperties(data.entity)
            local oldplate = SP(vehicleProps.plate)
            local input = lib.inputDialog(locale('MatriculaNueva'), {
                {
                    type = 'input',
                    icon = 'window-maximize',
                    disabled = true,
                    label = 'Vehicle Owner Plate',
                    required = false,
                    placeholder = oldplate
                },
                {
                    type = 'input',
                    label = 'New Plate',
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
