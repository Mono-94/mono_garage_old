lib.locale()

local blips, currentJob = {}, nil

RegisterNetEvent('esx:setJob', function(job)
    currentJob = job.name
    CrearBlips()
end)


function CrearBlips()
    for k, v in pairs(Garage.Garages) do
        if v.impound then
            if not blips[k] then
                if Garage.Target then
                    blips[k] = CrearBlip(v.NPCPos.xyz, v.sprite, v.scale, v.colorblip, k)
                else
                    blips[k] = CrearBlip(v.pos, v.sprite, v.scale, v.colorblip, k)
                end
            end
        else
            if v.blip and (v.job == false or currentJob == v.job) then
                if not blips[k] then
                    if Garage.Target then
                        blips[k] = CrearBlip(v.NPCPos.xyz, v.sprite, v.scale, v.colorblip, locale('Garaje-', k))
                    else
                        blips[k] = CrearBlip(v.pos, v.sprite, v.scale, v.colorblip, locale('Garaje-', k))
                    end
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

CreateThread(function()
    CrearBlips()
    for k, v in pairs(Garage.Garages) do
        if not v.impound then
            if Garage.Target then
                local options = {
                    {
                        name = 'mono_garage:TargetGuardar',
                        icon = 'fa-solid fa-road',
                        label = locale('DepositarVeh1'),
                        groups = v.job,
                        distance = Garage.TargetCarDistance,
                        onSelect = function()
                            SaveVehicle({ garage = k, distance = 2.5, type = v.type })
                        end
                    },
                }
                local optionNames = { 'mono_garage:TargetGuardar' }
                lib.zones.box({
                    coords = v.pos,
                    size = v.size,
                    rotation = v.heading,
                    debug = Garage.Debug.Zones,
                    onEnter = function()
                        ped = CreateNPC(v.NPCHash, v.NPCPos)
                        exports.ox_target:addBoxZone({
                            coords = vec3(v.NPCPos.x, v.NPCPos.y, v.NPCPos.z + 1),
                            size = vec3(1, 1, 2),
                            rotation = v.NPCPos.w,
                            debug = Garage.Debug.Zones,
                            options = {
                                {
                                    groups = v.job,
                                    distance = Garage.TargetNPCDistance,
                                    icon = 'fas fa-car',
                                    label = locale('SacarVehiculooo'),
                                    onSelect = function()
                                        if IsPedInAnyVehicle(PlayerPedId(), false) then
                                            TriggerEvent('mono_garage:Notification', locale('SalirVehiculo'))
                                        else
                                            OpenGarage({
                                                garage = k,
                                                spawnpos = v.spawnpos,
                                                impound = v.impoundIn,
                                                SetInToVeh = v.SetInToVehicle,
                                                shareGarage = v.ShareGarage
                                            })
                                        end
                                    end
                                }
                            }
                        })
                        exports.ox_target:addGlobalVehicle(options)
                    end,
                    onExit = function()
                        DeleteEntity(ped)
                        exports.ox_target:removeGlobalVehicle(optionNames)
                    end
                })
            else
                lib.zones.box({
                    coords = v.pos,
                    size = v.size,
                    rotation = v.heading,
                    debug = Garage.Debug.Zones,
                    onEnter = function()
                        if currentJob == v.job then
                            lib.registerRadial({
                                id = 'garaga_meter_sacar',
                                items = {
                                    {
                                        label = locale('DepositarVeh1'),
                                        icon = 'share',
                                        onSelect = function()
                                            SaveVehicle({ garage = k, distance = 2.5, type = v.type })
                                        end
                                    },
                                    {
                                        label = locale('SacarVehiculooo'),
                                        icon = 'car',
                                        onSelect = function()
                                            if cache.vehicle then
                                                TriggerEvent('mono_garage:Notification', locale('SalirVehiculo'))
                                            else
                                                OpenGarage({
                                                    garage = k,
                                                    spawnpos = v.spawnpos,
                                                    impound = v.impoundIn,
                                                    SetInToVeh = v.SetInToVehicle,
                                                    shareGarage = v.ShareGarage
                                                })
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
                        elseif v.job == false then
                            lib.registerRadial({
                                id = 'garaga_meter_sacar',
                                items = {
                                    {
                                        label = locale('DepositarVeh1'),
                                        icon = 'share',
                                        onSelect = function()
                                            SaveVehicle({ garage = k, distance = 2.5, type = v.type })
                                        end
                                    },
                                    {
                                        label = locale('SacarVehiculooo'),
                                        icon = 'car',
                                        onSelect = function()
                                            if cache.vehicle then
                                                TriggerEvent('mono_garage:Notification', locale('SalirVehiculo'))
                                            else
                                                OpenGarage({
                                                    garage = k,
                                                    spawnpos = v.spawnpos,
                                                    impound = v.impoundIn,
                                                    SetInToVeh = v.SetInToVehicle,
                                                    shareGarage = v.ShareGarage
                                                })
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
                        end
                    end,
                    onExit = function()
                        lib.removeRadialItem('garage_menu')
                    end
                })
            end
        else
            if Garage.Target then
                CreateNPC(v.NPCHash, v.NPCPos)
                exports.ox_target:addBoxZone({
                    coords = vec3(v.NPCPos.x, v.NPCPos.y, v.NPCPos.z + 1),
                    size = vec3(1, 1, 2),
                    rotation = v.NPCPos.w,
                    debug = Garage.Debug.Zones,
                    options = {
                        {
                            icon = 'fas fa-car',
                            label = k,
                            onSelect = function(data)
                                if cache.vehicle then
                                    TriggerEvent('mono_garage:Notification', locale('SalirVehiculo'))
                                else
                                    GarageImpound({
                                        garage = k,
                                        spawnpos = v.spawnpos,
                                        precio = v.impoundPrice,
                                        SetInToVeh = v.SetInToVehicle,
                                        job = v.job,
                                        Society = v.Society
                                    })
                                end
                            end
                        }
                    }
                })
            else
                lib.zones.box({
                    coords = v.pos,
                    size = v.size,
                    rotation = v.heading,
                    debug = Garage.Debug.Zones,
                    onEnter = function()
                        lib.addRadialItem({
                            {
                                id = 'impound',
                                label = k,
                                icon = 'car',
                                onSelect = function()
                                    if cache.vehicle then
                                        TriggerEvent('mono_garage:Notification', locale('SalirVehiculo'))
                                    else
                                        GarageImpound({
                                            garage = k,
                                            spawnpos = v.spawnpos,
                                            precio = v.impoundPrice,
                                            SetInToVeh = v.SetInToVehicle,
                                            job = v.job,
                                            Society = v.Society
                                        })
                                    end
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


function OpenGarage(info)
    local garagemenu = {}
    local vehicles = lib.callback.await('mono_garage:getOwnerVehicles')
    local vehiclesFound = false
    for i = 1, #vehicles do
        local data = vehicles[i]
        local props = json.decode(data.vehicle)
        local name = GetDisplayNameFromVehicleModel(props.model)
        local marca = GetMakeNameFromVehicleModel(props.model)
        local type = GetVehicleClassFromName(name)

        if info.shareGarage then
            shared = true
        else
            shared = data.parking == info.garage
        end
        if shared then
            vehiclesFound = true
            if data.stored == 0 or data.stored == 2 then
                data.parking = locale('VehEnLaCalle')
                color = '#FF8787'
            end
            if data.stored == 1 then
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
            if data.isOwner then
                propietario = locale('dueño')
            else
                propietario = locale('deunamigo')
            end

            local equivalenteEnKilometros = tonumber(data.mileage) / 520.000
            local formattedEquivalente = string.format("%.1f", equivalenteEnKilometros)

            table.insert(garagemenu, {
                title = marca .. ' - ' .. name,
                icon = icon,
                iconColor = color,
                arrow = true,
                metadata = {
                    { label = 'Total',             value = formattedEquivalente .. ' KM' },
                    { label = locale('VehDescri'), value = data.parking },
                    {
                        label = locale('VehDescrigas'),
                        value = ' ' .. props.fuelLevel .. '%',
                        progress = props.fuelLevel,
                    },

                },
                colorScheme = '#4ac76b',
                description = propietario .. ' | Plate: ' .. props.plate,
                onSelect = function()
                    VehicleSelected({
                        garage = info.garage,
                        spawn = info.spawnpos,
                        plate = props.plate,
                        name = name,
                        marca = marca,
                        model = props.model,
                        stored = data.stored,
                        impo = info.impound,
                        intocar = info.SetInToVeh,
                        isOwner = data.isOwner,
                        amigos = data.amigos
                    })
                end,
            })
        end
    end
    if not vehiclesFound then
        lib.registerContext({
            id = 'mono_garage:MenuCarList',
            title = locale('Garaje-', info.garage),
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
            id = 'mono_garage:MenuCarList',
            title = locale('Garaje-', info.garage),
            options = garagemenu
        })
    end
    lib.showContext('mono_garage:MenuCarList')
end

exports('OpenGarage', OpenGarage)

-- Seleccionado

function VehicleSelected(data)
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
                    local hea = v.w
                    local model = data.model
                    if SpawnClearArea(pos, 2.0) then
                        TriggerServerEvent('mono_garage:RetirarVehiculo', data.plate, data.garage, pos, hea, model,
                            data.intocar)
                        SpawPos = true
                        break
                    end
                end
                if not SpawPos then
                    TriggerEvent('mono_garage:Notification', locale('NoSpawn'))
                end
            end
        })
        if Garage.ShareCarFriend then
            if data.isOwner then
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
                        TriggerServerEvent('mono_garage:CompartirAmigo', input[1], input[2], data.plate)
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
                                                    event = 'mono_garage:EliminarAmigo',
                                                    params = { Amigo = ami.identifier, plate = data.plate }
                                                }
                                            }
                                        })
                                        if alert == "cancel" then
                                        else
                                            TriggerServerEvent('mono_garage:EliminarAmigo', ami.name, data.plate)
                                        end
                                    end
                                })
                            end
                            lib.registerContext({
                                id = 'menu_amigos',
                                menu = 'mono_garage:VehiculoSeleccionado',
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
        if data.isOwner then
            table.insert(select, {
                title = locale('markgps'),
                icon = 'location-dot',
                arrow = true,
                onSelect = function()
                    local allVeh = lib.callback.await('mono_garage:GetVehicleCoords', source, SP(data.plate))
                    if allVeh == nil then return locale('to_far') end
                    SetNewWaypoint(allVeh.x, allVeh.y)
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
                        TriggerServerEvent('mono_garage:CompartirAmigo', input[1], input[2], data.plate)
                    end
                })
            end
            table.insert(select, {
                title = locale('DepositarVeh2'),
                icon = 'car',
                arrow = true,
                description = locale('DescriDepoti'),
                onSelect = function()
                    TriggerServerEvent('mono_garage:MandarVehiculoImpound', SP(data.plate), data.impo)
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
                                                    event = 'mono_garage:EliminarAmigo',
                                                    params = { Amigo = ami.identifier, plate = data.plate }
                                                }
                                            }
                                        })
                                        if alert == "cancel" then
                                        else
                                            TriggerServerEvent('mono_garage:EliminarAmigo', ami.name, data.plate)
                                        end
                                    end
                                })
                            end
                            lib.registerContext({
                                id = 'menu_amigos',
                                menu = 'mono_garage:VehiculoSeleccionado',
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
        id = 'mono_garage:VehiculoSeleccionado',
        menu = 'mono_garage:MenuCarList',
        title = data.marca .. ' - ' .. data.name,
        options = select
    })
    lib.showContext('mono_garage:VehiculoSeleccionado')
end

--impound
function GarageImpound(info)
    local ImpoundMenu = {}
    local vehicles = lib.callback.await('mono_garage:getOwnerVehicles')
    local money = lib.callback.await('mono_garage:getBankMoney')
    local vehiclesFound = false
    for i = 1, #vehicles do
        local data = vehicles[i]
        local props = json.decode(data.vehicle)
        if data.pound == '1' and info.garage == data.parking and data.isOwner then
            vehiclesFound = true
            local infoimpound = json.decode(data.infoimpound)

            local date = infoimpound and infoimpound.date or locale('imp_nada_date')
            local reason = infoimpound and infoimpound.reason or locale('imp_nada_reason')
            local price = infoimpound and infoimpound.price or info.precio

            table.insert(ImpoundMenu, {
                title = GetMakeNameFromVehicleModel(props.model) ..
                    ' - ' .. GetDisplayNameFromVehicleModel(props.model),
                icon = 'car',
                iconColor = '#fcba03',
                arrow = true,
                description = locale('VehDescriImpound', price, props.plate, props.fuelLevel),
                metadata = {
                    { label = locale('imp_date'),   value = date },
                    { label = locale('imp_reason'), value = reason },
                    { label = locale('imp_price'),  value = price .. ' $' }
                },
                onSelect = function()
                    local SpawPos = false
                    local input = lib.inputDialog(locale('MetodoPagoTitulo'), {
                        {
                            type = 'select',
                            icon = 'dollar',
                            label = locale('ImpoundMetodo', money.money, money.bank),
                            options = {
                                { value = 'money', label = locale('MetodoPagoMoney') },
                                { value = 'bank',  label = locale('MetodoPagoBank') },
                            }
                        },
                    })
                    if input == nil then
                        return
                    elseif not input[1] then
                        return TriggerEvent('mono_garage:Notification', locale('metododepagos'))
                    end
                    local function Retirar(input)
                        for j = 1, #info.spawnpos do
                            local v = info.spawnpos[j]
                            local pos = vec3(v.x, v.y, v.z)
                            local hea = v.w
                            if SpawnClearArea(pos, 3.0) then
                                TriggerServerEvent('mono_garage:RetirarVehiculoImpound', data.plate, input,
                                    price,
                                    pos, hea, info.SetInToVeh, info.Society)
                                SpawPos = true
                                break
                            end
                        end
                    end

                    if input[1] == 'money' then
                        if money.money >= price then
                            Retirar(input[1])
                        else
                            SpawPos = true
                            TriggerEvent('mono_garage:Notification', locale('SERVER_SinDinero'))
                        end
                    elseif input[1] == 'bank' then
                        if money.bank >= price then
                            Retirar(input[1])
                        else
                            SpawPos = true
                            TriggerEvent('mono_garage:Notification', locale('SERVER_SinDinero'))
                        end
                    end
                    if not SpawPos then
                        TriggerEvent('mono_garage:Notification', locale('NoSpawn'))
                    end
                end
            })
        end
    end
    if not vehiclesFound then
        lib.registerContext({
            id = 'mono_garage:ImpoundMenu',
            title = 'Impound - ' .. info.garage,
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
            id = 'mono_garage:ImpoundMenu',
            title = 'Impound - ' .. info.garage,
            options = ImpoundMenu
        })
    end

    lib.showContext('mono_garage:ImpoundMenu')
end
