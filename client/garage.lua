lib.locale()

local ListaCategoria, blips, currentJob = {}, {}, nil

RegisterNetEvent('esx:setJob')
AddEventHandler('esx:setJob', function(job)
    currentJob = job.name
    CrearBlips()
end)


VehicleCategories = {
    ['car'] = { 0, 1, 2, 3, 4, 5, 6, 7, 9, 10, 11, 12, 8, 17, 19, 13 },
    ['boat'] = { 14 },
    ['air'] = { 15, 16 },
}
local function SyGargeTypeCar(class)
    return ListaCategoria[class]
end

CreateThread(function()
    for categoria, clase in pairs(VehicleCategories) do
        for _, class in pairs(clase) do
            ListaCategoria[class] = categoria
        end
    end
end)

function CrearBlips()
    for k, v in pairs(Garage.Garages) do
        if v.impound then
            if not blips[k] then
                if Garage.Target then
                    blips[k] = AddBlipForCoord(v.NPCPos.xyz)
                else
                    blips[k] = AddBlipForCoord(v.pos)
                end
                SetBlipSprite(blips[k], v.sprite)
                SetBlipDisplay(blips[k], 4)
                SetBlipScale(blips[k], v.scale)
                SetBlipColour(blips[k], v.colorblip)
                SetBlipAsShortRange(blips[k], true)
                BeginTextCommandSetBlipName("STRING")
                AddTextComponentString(k)
                EndTextCommandSetBlipName(blips[k])
            end
        else
            if v.blip and v.job == false then
                if not blips[k] then
                    if Garage.Target then
                        blips[k] = AddBlipForCoord(v.NPCPos.xyz)
                    else
                        blips[k] = AddBlipForCoord(v.pos)
                    end
                    SetBlipSprite(blips[k], v.sprite)
                    SetBlipDisplay(blips[k], 4)
                    SetBlipScale(blips[k], v.scale)
                    SetBlipColour(blips[k], v.colorblip)
                    SetBlipAsShortRange(blips[k], true)
                    BeginTextCommandSetBlipName("STRING")
                    AddTextComponentString(locale('Garaje-', k))
                    EndTextCommandSetBlipName(blips[k])
                end
            else
                if currentJob == v.job then
                    if not blips[k] then
                        if Garage.Target then
                            blips[k] = AddBlipForCoord(v.NPCPos.xyz)
                        else
                            blips[k] = AddBlipForCoord(v.pos)
                        end
                        SetBlipSprite(blips[k], v.sprite)
                        SetBlipDisplay(blips[k], 4)
                        SetBlipScale(blips[k], v.scale)
                        SetBlipColour(blips[k], v.colorblip)
                        SetBlipAsShortRange(blips[k], true)
                        BeginTextCommandSetBlipName("STRING")
                        AddTextComponentString(locale('Garaje-', k))
                        EndTextCommandSetBlipName(blips[k])
                    end
                else
                    if blips[k] then
                        RemoveBlip(blips[k])
                        blips[k] = nil
                    end
                end
            end
        end
    end
end

CreateThread(function ()
    if (GetCurrentResourceName() ~= 'sy_garage') then
        return
    end
    CrearBlips()
end)



CreateThread(function()
    for k, v in pairs(Garage.Garages) do
        if not v.impound then
            if Garage.Target then
                RequestModel(v.NPCHash)
                while not HasModelLoaded(v.NPCHash) do
                    Wait(1)
                end
                NPC = CreatePed(2, v.NPCHash, v.NPCPos.x, v.NPCPos.y, v.NPCPos.z, v.NPCPos.w, false, false)
                SetPedFleeAttributes(NPC, 0, 0)
                SetPedDiesWhenInjured(NPC, false)
                TaskStartScenarioInPlace(NPC, "missheistdockssetup1clipboard@base", 0, true)
                SetPedKeepTask(NPC, true)
                SetBlockingOfNonTemporaryEvents(NPC, true)
                SetEntityInvincible(NPC, true)
                FreezeEntityPosition(NPC, true)
                exports.ox_target:addBoxZone({
                    coords = vec3(v.NPCPos.x, v.NPCPos.y, v.NPCPos.z + 1),
                    size = vec3(1, 1, 2),
                    rotation = v.NPCPos.w,
                    debug = v.debug,
                    options = {
                        {
                            groups = v.job,
                            icon = 'fas fa-car',
                            label = locale('SacarVehiculooo'),
                            onSelect = function()
                                if IsPedInAnyVehicle(PlayerPedId(), false) then
                                    TriggerEvent('sy_garage:Notification',
                                        locale('SalirVehiculo'))
                                else
                                    TriggerEvent('sy_garage:garage',
                                        { garage = k, spawnpos = v.spawnpos, impound = v.impoundIn })
                                end
                            end
                        }
                    }
                })

                local options = {
                    {
                        name = 'sy_garage:TargetGuardar',
                        event = 'ox_target:debug',
                        icon = 'fa-solid fa-road',
                        label = locale('DepositarVeh1'),
                        distance = 2,
                        onSelect = function()
                            local closet = lib.getClosestVehicle(cache.coords, 2.5, true)
                            if closet then
                                local plate = string.gsub(GetVehicleNumberPlateText(closet), " ", "")
                                local model = GetEntityModel(closet)
                                local name = GetDisplayNameFromVehicleModel(model)
                                local vehicleProps = lib.getVehicleProperties(closet)

                                if Garage.CarKeys then
                                    Garage.DeleteKeyEvent(plate, name)
                                end

                                TriggerServerEvent('sy_garage:GuardarVehiculo', plate,
                                    json.encode(vehicleProps), k,
                                    VehToNet(closet))
                            else
                                TriggerEvent('sy_garage:Notification', locale('mascerca'))
                            end
                        end
                    },
                }
                local optionNames = { 'sy_garage:TargetGuardar' }

                lib.zones.box({
                    coords = v.pos,
                    size = v.size,
                    rotation = v.heading,
                    debug = v.debug,
                    onEnter = function()
                        exports.ox_target:addGlobalVehicle(options)
                    end,
                    onExit = function()
                        exports.ox_target:removeGlobalVehicle(optionNames)
                    end
                })
            else
                lib.zones.box({
                    coords = v.pos,
                    size = v.size,
                    rotation = v.heading,
                    debug = v.debug,
                    -- inside = inside,
                    onEnter = function()
                        lib.registerRadial({
                            id = 'garaga_meter_sacar',
                            items = {
                                {
                                    label = locale('DepositarVeh1'),
                                    icon = 'share',
                                    onSelect = function()
                                        if ESX.PlayerData.job.name == v.job then
                                            if SyGargeTypeCar(Sy.GetClase()) == v.type then
                                                if Sy.GetProps() == nil then
                                                    return TriggerEvent('sy_garage:Notification',
                                                        locale('EnUnVeh'))
                                                end
                                                if Garage.CarKeys then
                                                    Garage.DeleteKeyEvent(Sy.GetProps().plate, Sy.GetCar({ name = true }))
                                                end
                                                local vehicle = GetVehiclePedIsIn(cache.ped, false)
                                                local vehicleProps = lib.getVehicleProperties(vehicle)
                                                TriggerServerEvent('sy_garage:GuardarVehiculo',
                                                    GetVehicleNumberPlateText(Sy.GetCar({ car = true })),
                                                    json.encode(vehicleProps), k,
                                                    VehToNet(Sy.GetCar({ car = true })))
                                            else
                                                TriggerEvent('sy_garage:Notification',
                                                    locale('NoAqui'))
                                            end
                                        elseif v.job == false then
                                            if SyGargeTypeCar(Sy.GetClase()) == v.type then
                                                if Sy.GetProps() == nil then
                                                    return TriggerEvent('sy_garage:Notification',
                                                        locale('EnUnVeh'))
                                                end
                                                if Garage.CarKeys then
                                                    Garage.DeleteKeyEvent(Sy.GetProps().plate, Sy.GetCar({ name = true }))
                                                end
                                                local vehicle = GetVehiclePedIsIn(cache.ped, false)
                                                local vehicleProps = lib.getVehicleProperties(vehicle)
                                                TriggerServerEvent('sy_garage:GuardarVehiculo',
                                                    GetVehicleNumberPlateText(Sy.GetCar({ car = true })),
                                                    json.encode(vehicleProps), k,
                                                    VehToNet(Sy.GetCar({ car = true })))
                                            else
                                                TriggerEvent('sy_garage:Notification',
                                                    locale('NoAqui'))
                                            end
                                        end
                                    end
                                },
                                {
                                    label = locale('SacarVehiculooo'),
                                    icon = 'car',
                                    onSelect = function()
                                        if v.job == ESX.PlayerData.job.name then
                                            if IsPedInAnyVehicle(PlayerPedId(), false) then
                                                TriggerEvent('sy_garage:Notification',
                                                    locale('SalirVehiculo'))
                                            else
                                                TriggerEvent('sy_garage:garage',
                                                    { garage = k, spawnpos = v.spawnpos, impound = v.impoundIn })
                                            end
                                        elseif v.job == false then
                                            if IsPedInAnyVehicle(PlayerPedId(), false) then
                                                TriggerEvent('sy_garage:Notification',
                                                    locale('SalirVehiculo'))
                                            else
                                                TriggerEvent('sy_garage:garage',
                                                    { garage = k, spawnpos = v.spawnpos, impound = v.impoundIn })
                                            end
                                        end
                                    end
                                },

                            }
                        })
                        lib.addRadialItem({
                            {
                                id = 'garage_menu',
                                label = locale('Garaje-', k),
                                icon = 'warehouse',
                                menu = 'garaga_meter_sacar'
                            },
                        })
                    end,
                    onExit = function()
                        lib.removeRadialItem('garage_menu')
                    end
                })
            end
        else
            if Garage.Target then
                RequestModel(v.NPCHash)
                NPC = CreatePed(2, v.NPCHash, v.NPCPos, false, false)
                SetPedFleeAttributes(NPC, 0, 0)
                SetPedDiesWhenInjured(NPC, false)
                TaskStartScenarioInPlace(NPC, v.PedScenario, 0, true)
                SetPedKeepTask(NPC, true)
                SetBlockingOfNonTemporaryEvents(NPC, true)
                SetEntityInvincible(NPC, true)
                FreezeEntityPosition(NPC, true)
                exports.ox_target:addBoxZone({
                    coords = vec3(v.NPCPos.x, v.NPCPos.y, v.NPCPos.z + 1),
                    size = vec3(1, 1, 2),
                    rotation = v.NPCPos.w,
                    debug = v.debug,
                    options = {
                        {
                            icon = 'fas fa-car',
                            label = k,
                            onSelect = function()
                                TriggerEvent('sy_garage:garageImpound',
                                    { garage = k, spawnpos = v.spawnpos, precio = v.impoundPrice })
                            end
                        }
                    }
                })
            else
                lib.zones.box({
                    coords = v.pos,
                    size = v.size,
                    rotation = v.heading,
                    debug = v.debug,
                    onEnter = function()
                        lib.addRadialItem({
                            {
                                id = 'impound',
                                label = k,
                                icon = 'car',
                                onSelect = function()
                                    TriggerEvent('sy_garage:garageImpound',
                                        { garage = k, spawnpos = v.spawnpos, precio = v.impoundPrice })
                                end
                            },
                        })
                    end,
                    onExit = function()
                        lib.removeRadialItem('impound')
                    end
                })
            end
        end
    end
end)




AddEventHandler('sy_garage:garage', function(data)
    local garagemenu = {}
    local vehicles = lib.callback.await('sy_garage:getOwnerVehicles')
    local spawn = data.spawnpos
    local garageName = data.garage
    local impo = data.impound
    local vehiclesFound = false
    for i = 1, #vehicles do
        local data = vehicles[i]
        local name = GetDisplayNameFromVehicleModel(data.model)
        local marca = GetMakeNameFromVehicleModel(data.model)
        local type = GetVehicleClassFromName(name)
        local plate = data.plate
        if data.parking == garageName then
            vehiclesFound = true
            if data.parking == garageName and data.stored == 0 then
                data.parking = locale('VehEnLaCalle')
                color = '#FF8787'
            end
            if data.parking == garageName and data.stored == 1 then
                color = '#32a852'
            end
            if type == 8 then
                icon = 'motorcycle'
            elseif type == 2 then
                icon = 'truck-pickup'
            elseif type == 15 then
                icon = 'helicopter'
            elseif type == 16 then
                icon = 'plane'
            elseif type == 14 then
                icon = 'ship'
            else
                icon = 'car'
            end

            if data.id == data.duen then
                propietario = locale('dueño')
            else
                propietario = locale('deunamigo')
            end

            local km = math.floor((data.mileage / 20517.9) * 10) / 10
            local formattedKM = string.format("%.1f km", km)
            table.insert(garagemenu, {
                title = marca .. ' - ' .. name,
                icon = icon,
                iconColor = color,
                arrow = true,
                metadata = {
                    { label = 'Total',             value = formattedKM },
                    { label = locale('VehDescri'), value = data.parking },
                    {
                        label = locale('VehDescrigas'),
                        value = ' ' .. data.fuelLevel .. '%',
                        progress = data
                            .fuelLevel,
                    },

                },
                colorScheme = '#4ac76b',
                description = propietario .. ' | Plate: ' .. plate,
                args = {
                    vehicle = data,
                    garage = garageName,
                    spawn = spawn,
                    plate = plate,
                    name = name,
                    marca = marca,
                    model = data.model,
                    pound = data.pound,
                    stored = data.stored,
                    impo = impo,
                    duen = data.duen,
                    id = data.id,
                    amigos = data.amigos,
                },
                event = 'sy_garage:VehiculoSeleccionado',
            })
        end
    end
    if not vehiclesFound then
        lib.registerContext({
            id = 'sy_garage:MenuCarList',
            title = locale('Garaje-', data.garage),
            options = {
                {
                    disabled = true,
                    title = locale('nocars'),
                    icon = 'triangle-exclamation',
                }

            }
        })
    else
        lib.registerContext({
            id = 'sy_garage:MenuCarList',
            title = locale('Garaje-', data.garage),
            options = garagemenu
        })
    end
    lib.showContext('sy_garage:MenuCarList')
end)


AddEventHandler('sy_garage:VehiculoSeleccionado', function(data)
    local select = {}
    if data.stored == 1 then
        table.insert(select, {
            title = locale('SacarVehiculooo'),
            icon = 'car-side',
            onSelect = function()
                local SpawPos = false

                for j = 1, #data.spawn do
                    local v = data.spawn[j]
                    local pos = vector3(v.x, v.y, v.z)
                    local hea = v.h
                    local props = data.vehicle
                    local model = data.model

                    if ESX.Game.IsSpawnPointClear(pos, 2.0) then
                        if Garage.CarKeys then
                            Garage.AddKeyEvent(data.plate, data.name)
                        end
                        TriggerServerEvent('sy_garage:RetirarVehiculo', data.plate, data.garage, pos, hea, props, model)
                        SpawPos = true
                        break
                    end
                end
                if not SpawPos then
                    TriggerEvent('sy_garage:Notification', locale('NoSpawn'))
                end
            end
        })
        if Garage.ShareCarFriend then
            if data.id == data.duen then
                table.insert(select, {
                    title = locale('compartir'),
                    icon = 'users',
                    arrow = true,
                    description = locale('DescriShare'),
                    onSelect = function()
                        local input = lib.inputDialog(locale('Compartirx'),
                            {
                                { type = 'input', label = 'ID',                 description = locale('Compartir3') },
                                { type = 'input', label = locale('Compartir1'), description = locale('Compartir2') }
                            })


                        if not input then return end
                        TriggerServerEvent('sy_garage:CompartirAmigo', input[1], input[2], data.plate)
                    end
                })

                if data.amigos ~= nil then
                    table.insert(select, {
                        title = locale('ListaAmigos'),
                        icon = 'car',
                        arrow = true,
                        description = locale('ListaDescri'),
                        onSelect = function()
                            local amigos = {}
                            local ami = json.decode(data.amigos)
                            for i, ami in ipairs(ami) do
                                table.insert(amigos, {
                                    icon = 'user',
                                    title = ami.name,
                                    description = locale('Gestionar'),
                                    onSelect = function()
                                        local alert = lib.alertDialog({
                                            header = locale('Eliminar', ami.name),
                                            content = locale('SeguroEliminar'),
                                            centered = true,
                                            cancel = true,
                                            buttons = {
                                                {
                                                    text = locale('elimi'),
                                                    event = 'sy_garage:EliminarAmigo',
                                                    params = { Amigo = ami.identifier, plate = data.plate }
                                                }
                                            }
                                        })
                                        if alert == "cancel" then
                                        else
                                            TriggerServerEvent('sy_garage:EliminarAmigo', ami.name, data.plate)
                                        end
                                    end
                                })
                            end
                            lib.registerContext({
                                id = 'menu_amigos',
                                menu = 'sy_garage:VehiculoSeleccionado',
                                title = locale('ListaAmigos'),
                                options = amigos
                            })
                            lib.showContext('menu_amigos')
                        end
                    })
                end
            end
        end
    else
        if data.id == data.duen then
            table.insert(select, {
                title = locale('markgps'),
                icon = 'location-dot',
                arrow = true,
                onSelect = function()
                    local allVehicles = ESX.Game.GetVehicles()
                    for j = 1, #allVehicles do
                        local vehicle = allVehicles[j]
                        if DoesEntityExist(vehicle) then
                            local vehicleCoords = GetEntityCoords(vehicle)
                            local plate = GetVehicleNumberPlateText(vehicle)
                            if plate == data.plate then
                                SetNewWaypoint(vehicleCoords.x, vehicleCoords.y)
                            end
                        end
                    end
                end
            })
            if Garage.ShareCarFriend then
                table.insert(select, {
                    title = locale('compartir'),
                    icon = 'users',
                    arrow = true,
                    description = locale('DescriShare'),
                    onSelect = function()
                        local input = lib.inputDialog(locale('Compartirx'),
                            {
                                { type = 'input', label = 'ID',                 description = locale('Compartir3') },
                                { type = 'input', label = locale('Compartir1'), description = locale('Compartir2') }
                            })


                        if not input then return end
                        TriggerServerEvent('sy_garage:CompartirAmigo', input[1], input[2], data.plate)
                    end
                })
            end
            table.insert(select, {
                title = locale('DepositarVeh2'),
                icon = 'car',
                arrow = true,
                description = locale('DescriDepoti'),
                onSelect = function()
                    TriggerServerEvent('sy_garage:MandarVehiculoImpound', data.plate, data.impo)
                end
            })
            if Garage.ShareCarFriend then
                if data.amigos ~= nil then
                    table.insert(select, {
                        title = locale('ListaAmigos'),
                        icon = 'car',
                        arrow = true,
                        description = locale('ListaDescri'),
                        onSelect = function()
                            local amigos = {}
                            local ami = json.decode(data.amigos)
                            for i, ami in ipairs(ami) do
                                table.insert(amigos, {
                                    icon = 'user',
                                    title = ami.name,
                                    description = locale('Gestionar'),
                                    onSelect = function()
                                        local alert = lib.alertDialog({
                                            header = locale('Eliminar', ami.name),
                                            content = locale('SeguroEliminar'),
                                            centered = true,
                                            cancel = true,
                                            buttons = {
                                                {
                                                    text = locale('elimi'),
                                                    event = 'sy_garage:EliminarAmigo',
                                                    params = { Amigo = ami.identifier, plate = data.plate }
                                                }
                                            }
                                        })
                                        if alert == "cancel" then
                                        else
                                            TriggerServerEvent('sy_garage:EliminarAmigo', ami.name, data.plate)
                                        end
                                    end
                                })
                            end
                            lib.registerContext({
                                id = 'menu_amigos',
                                menu = 'sy_garage:VehiculoSeleccionado',
                                title = locale('ListaAmigos'),
                                options = amigos
                            })
                            lib.showContext('menu_amigos')
                        end
                    })
                end
            end
        else
            table.insert(select, {
                disabled = true,
                title = locale('sinaccesoo'),
                icon = 'triangle-exclamation',
            })
        end
    end
    lib.registerContext({
        id = 'sy_garage:VehiculoSeleccionado',
        menu = 'sy_garage:MenuCarList',
        title = data.marca .. ' - ' .. data.name,
        options = select
    })
    lib.showContext('sy_garage:VehiculoSeleccionado')
end)


AddEventHandler('sy_garage:garageImpound', function(nata)
    local ImpoundMenu = {}
    local vehicles = lib.callback.await('sy_garage:getOwnerVehicles')
    local bank = lib.callback.await('sy_garage:getBankMoney')
    local spawn = nata.spawnpos
    local garageName = nata.garage
    local price = nata.precio
    local vehiclesFound = false
    for i = 1, #vehicles do
        local data = vehicles[i]
        local name = GetDisplayNameFromVehicleModel(data.model)
        local marca = GetMakeNameFromVehicleModel(data.model)
        local plate = data.plate

        if data.pound == '1' and garageName == data.parking then
            vehiclesFound = true
            table.insert(ImpoundMenu, {
                title = marca .. ' - ' .. name,
                icon = 'car',
                iconColor = '#fcba03',
                arrow = true,
                description = locale('VehDescriImpound', price, data.plate, data.fuelLevel),
                onSelect = function()
                    local input = lib.inputDialog(locale('MetodoPagoTitulo'), {
                        {
                            type = 'select',
                            icon = 'dollar',
                            label = locale('ImpoundMetodo', bank.money, bank.bank),
                            options = {
                                { value = 'money', label = locale('MetodoPagoMoney') },
                                { value = 'bank',  label = locale('MetodoPagoBank') },
                            }
                        },
                    })
                    if input == nil then
                        return
                    end

                    if not input[1] then
                        return TriggerEvent('sy_garage:Notification', locale('metododepagos'))
                    end

                    if input[1] == 'money' then
                        if bank.money >= price then
                            for j = 1, #spawn do
                                local v = spawn[j]
                                local pos = vector3(v.x, v.y, v.z)
                                local hea = v.h
                                local SpawPos = false
                                local model = data.model
                                if ESX.Game.IsSpawnPointClear(vector3(v.x, v.y, v.z), 3.0) then
                                    TriggerServerEvent('sy_garage:RetirarVehiculoImpound', plate, input[1], price,
                                        data, pos, hea, model)
                                    SpawPos = true
                                    if Garage.CarKeys then
                                        Garage.AddKeyEvent(plate, name)
                                    end

                                    break
                                end

                                if not SpawPos then
                                    TriggerEvent('sy_garage:Notification',
                                        locale('NoSpawn'))
                                end
                            end
                        else
                            TriggerEvent('sy_garage:Notification',
                                locale('SERVER_SinDinero'))
                        end
                    elseif input[1] == 'bank' then
                        if bank.bank >= price then
                            for j = 1, #spawn do
                                local v = spawn[j]
                                local pos = vector3(v.x, v.y, v.z)
                                local hea = v.h
                                local model = data.model
                                local SpawPos = false
                                if ESX.Game.IsSpawnPointClear(vector3(v.x, v.y, v.z), 3.0) then
                                    TriggerServerEvent('sy_garage:RetirarVehiculoImpound', plate, input[1], price,
                                        data, pos, hea, model)
                                    SpawPos = true
                                    if Garage.CarKeys then
                                        Garage.AddKeyEvent(plate, name)
                                    end
                                    break
                                end

                                if not SpawPos then
                                    TriggerEvent('sy_garage:Notification',
                                        locale('NoSpawn'))
                                end
                            end
                        else
                            TriggerEvent('sy_garage:Notification',
                                locale('SERVER_SinDinero'))
                        end
                    end
                end
            })
        end
    end
    if not vehiclesFound then
        lib.registerContext({
            id = 'sy_garage:ImpoundMenu',
            title = 'Impound - ' .. nata.garage,
            options = {
                {
                    disabled = true,
                    title = locale('nocars'),
                    icon = 'triangle-exclamation',
                }

            }
        })
    else
        lib.registerContext({
            id = 'sy_garage:ImpoundMenu',
            title = 'Impound - ' .. nata.garage, -- usar la variable local
            options = ImpoundMenu
        })
    end




    lib.showContext('sy_garage:ImpoundMenu')
end)






if Garage.SaveKilometers then
    local inVeh = false
    totalKM = 0

    CreateThread(function()
        while true do
            Wait(1000)
            if IsPedInAnyVehicle(PlayerPedId(), false) and not inVeh then
                local veh = GetVehiclePedIsIn(PlayerPedId(), false)
                local driver = GetPedInVehicleSeat(veh, -1)
                if driver then
                    inVeh = true
                    local plate = GetVehicleNumberPlateText(veh)
                    local vehicles = lib.callback.await('sy_garage:owner_vehicles')
                    for i = 1, #vehicles do
                        local data = vehicles[i]
                        if plate == data.plate then
                            local PosAnituga = GetEntityCoords(PlayerPedId())
                            Wait(1000)
                            local PosNueva = GetEntityCoords(PlayerPedId())
                            if SyGargeTypeCar(Sy.GetClase()) == 'car' then
                                distan = Vdist2(PosAnituga.x, PosAnituga.y, PosAnituga.z, PosNueva.x, PosNueva.y,
                                    PosNueva.z)
                            elseif SyGargeTypeCar(Sy.GetClase()) == 'air' then
                                distan = Vdist2(PosAnituga.x, PosAnituga.y, PosAnituga.z, PosNueva.x, PosNueva.y,
                                    PosNueva.z)
                            elseif SyGargeTypeCar(Sy.GetClase()) == 'boat' then
                                distan = Vdist2(PosAnituga.x, PosAnituga.y, PosAnituga.z, PosNueva.x, PosNueva.y,
                                    PosNueva.z)
                            else
                                distan = 0
                            end
                            data.mileage = data.mileage + distan
                            TriggerServerEvent('sy_garage:AgregarKilometros', plate, data.mileage)
                            inVeh = false
                        end
                    end
                end
            end
        end
    end)
end
