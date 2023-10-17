lib.locale()

local currentJob, grade, grade_name, grade_label = nil, nil, nil, nil


RegisterNetEvent('esx:setJob', function(job)
    currentJob = job.name
    grade = job.grade
    grade_name = job.grade_name
    grade_label = job.grade_label
    StartGarageBlips()
end)

RegisterNetEvent('esx:playerLoaded')
AddEventHandler('esx:playerLoaded', function(xPlayer, isNew, skin)
    currentJob = xPlayer.job.name
    grade = xPlayer.job.grade
    grade_name = xPlayer.job.grade_label
    grade_label = xPlayer.job.label
    StartGarageBlips()
end)

function StartGarageBlips()
    local blips = {}
    for k, v in pairs(Garage.Garages) do
        if v.impound then
            blips[k] = CrearBlip(v.NPCPos.xyz, v.sprite, v.scale, v.colorblip, k)
        else
            if v.blip and (v.job == false or currentJob == v.job) then
                if Garage.BlipsName then
                    blips[k] = CrearBlip(v.NPCPos.xyz, v.sprite, v.scale, v.colorblip, locale('Garaje-', k))
                else
                    blips[k] = CrearBlip(v.NPCPos.xyz, v.sprite, v.scale, v.colorblip, 'Garage')
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

StartGarageBlips()

for k, v in pairs(Garage.Garages) do
    v.garage = k
    if not v.impound then
        local options = {
            {
                name = 'mono_garage:TargetGuardar',
                icon = 'fa-solid fa-road',
                label = locale('DepositarVeh1'),
                groups = v.job,
                distance = Garage.TargetCarDistance,
                canInteract = function(entity, distance, coords, name, bone)
                    --print(entity)
                    return entity, distance, coords, name, bone
                end,
                onSelect = function(data)
                    print(data.entity)
                    if v.jobcar == nil then
                        SaveVehicle({ garage = k, distance = 2.5, type = v.type, entity = data.entity })
                    else
                        SaveVehicle({ garage = true, type = 'custom', entity = data.entity })
                    end
                end
            },
        }
        local open = {
            {
                name = 'mono_garage:TargetNpc',
                groups = v.job,
                distance = Garage.TargetNPCDistance,
                icon = 'fas fa-car',
                label = locale('SacarVehiculooo'),
                onSelect = function()
                    if cache.vehicle then
                        TriggerEvent('mono_garage:Notification', locale('SalirVehiculo'))
                    else
                        OpenGarage(v)
                    end
                end
            }
        }

        local optionNames = { 'mono_garage:TargetGuardar', 'mono_garage:TargetNpc' }

        function OnEnter()
            if Garage.SELECT == 'TARGET' then
                Ped = CreateNPC(v.NPCHash, v.NPCPos)
                exports.ox_target:addLocalEntity(Ped, open)
                if (currentJob == v.job) or (v.job == nil or false) then
                    exports.ox_target:addGlobalVehicle(options)
                end
            elseif Garage.SELECT == 'TEXTUI' then
                if (currentJob == v.job) or (v.job == nil or false) then
                    TextUI('[E] Open Garage '..v.garage..' <br> [X] Deposit vehicle')
                end
            elseif Garage.SELECT == 'RADIAL' then
                if (currentJob == v.job) or (v.job == nil or false) then
                    lib.addRadialItem({
                        id = 'Garage_Radial_Menu_mono',
                        icon = 'warehouse',
                        label = k,
                        menu = 'Garage_Radial_Menu'
                    })
                    lib.registerRadial({
                        id = 'Garage_Radial_Menu',
                        items = {
                            {
                                icon = 'fa-solid fa-road',
                                label = locale('DepositarVeh1'),
                                onSelect = function()
                                    if v.jobcar == nil then
                                        SaveVehicle({ garage = k, distance = 2.5, type = v.type })
                                    else
                                        SaveVehicle({ garage = true, type = 'custom' })
                                    end
                                end
                            },
                            {
                                icon = 'fas fa-car',
                                label = locale('SacarVehiculooo'),
                                onSelect = function()
                                    if cache.vehicle then
                                        TriggerEvent('mono_garage:Notification', locale('SalirVehiculo'))
                                    else
                                        OpenGarage(v)
                                    end
                                end
                            }
                        }
                    })
                end
            end
        end

        function OnExit()
            if Garage.SELECT == 'TARGET' then
                DeleteEntity(Ped)
                exports.ox_target:removeGlobalVehicle(optionNames)
            elseif Garage.SELECT == 'TEXTUI' then
                CloseTextUI()
            elseif Garage.SELECT == 'RADIAL' then
                lib.hideRadial()
                lib.removeRadialItem('Garage_Radial_Menu_mono')
            end
        end

        function Inside()
            if Garage.SELECT == 'TEXTUI' then
                if (currentJob == v.job) or (v.job == nil or false) then
                    if IsControlJustPressed(0, 38) then
                        if cache.vehicle then
                            TriggerEvent('mono_garage:Notification', locale('SalirVehiculo'))
                        else
                            OpenGarage(v)
                        end
                    end
                    if IsControlJustPressed(0, 73) then
                        if v.jobcar == nil then
                            SaveVehicle({ garage = k, distance = 2.5, type = v.type })
                        else
                            SaveVehicle({ garage = true, type = 'custom' })
                        end
                    end
                end
            end
        end

        if type(v.pos) == "table" and #v.pos > 1 then
            lib.zones.poly({
                points = v.pos,
                thickness = v.thickness,
                debug = Garage.Debug.Zones,
                onEnter = OnEnter,
                onExit = OnExit,
                inside = Inside
            })
        else
            lib.zones.box({
                coords = v.pos,
                size = v.size,
                rotation = v.pos.w,
                debug = Garage.Debug.Zones,
                onEnter = OnEnter,
                onExit = OnExit,
                inside = Inside
            })
        end
    else
        PedImpound = CreateNPC(v.NPCHash, v.NPCPos)
        local openImpound = {
            {
                name = 'mono_garage:TargetNpc',
                groups = v.job,
                distance = Garage.TargetNPCDistance,
                icon = 'fas fa-car',
                label = k,
                onSelect = function()
                    if cache.vehicle then
                        TriggerEvent('mono_garage:Notification', locale('SalirVehiculo'))
                    else
                        GarageImpound(v)
                    end
                end
            }
        }
        exports.ox_target:addLocalEntity(PedImpound, openImpound)
    end
end

RegisterNUICallback("exit", function(data)
    UiOpen = false
    SetNuiFocus(false, false)
    SendNUIMessage({ action = 'garage', show = false, })
end)


RegisterNUICallback("mono_garage", function(data)
    if data.jobcar == nil then
        if data.action == 'retirar' then
            local SpawPos = false
            local props = json.decode(data.vehicle.vehicle)
            for posis = 1, #data.garage.spawnpos do
                local v = data.garage.spawnpos[posis]
                local pos = vector3(v.x, v.y, v.z)
                if SpawnClearArea(pos, 2.0) then
                    TriggerServerEvent('mono_garage:RetirarVehiculo', data.vehicle.plate, data.garage.garage, pos, v.w,
                        props.model, data.garage.SetInToVeh)
                    SpawPos = true
                    break
                end
            end
            if not SpawPos then
                TriggerEvent('mono_garage:Notification', locale('NoSpawn'))
            end
        elseif data.action == 'depositar' then
            TriggerServerEvent('mono_garage:MandarVehiculoImpound', data.vehicle.plate, data.garage.impound)
        end
    else
        if data.action == 'retirar' then
            local SpawPos = false
            for posis = 1, #data.garage.spawnpos do
                local v = data.garage.spawnpos[posis]
                local pos = vector3(v.x, v.y, v.z)
                if SpawnClearArea(pos, 2.0) then
                    TriggerServerEvent('mono_garage:SpawnVehicle', data.vehicle.model, pos, v.w, data.vehicle.plate,
                        data.garage.SetInToVeh)
                    SpawPos = true
                    break
                end
            end
            if not SpawPos then
                TriggerEvent('mono_garage:Notification', locale('NoSpawn'))
            end
        end
    end
end)

function OpenGarage(info)
    local vehicles = lib.callback.await('mono_garage:getOwnerVehicles')

    if Garage.CustomMenu == true then
        if info.jobcar == nil then
            local data = {}
            for i = 1, #vehicles do
                local db = vehicles[i]
                local props = json.decode(db.vehicle)
                if info.shareGarage then
                    shared = true
                else
                    shared = db.parking == info.garage
                end
                if shared then
                    db.fuelLevel = props.fuelLevel or 100
                    db.engine = props.engineHealth or 1000
                    db.body = props.bodyHealth or 1000
                    db.name = GetDisplayNameFromVehicleModel(props.model)
                    db.marca = GetMakeNameFromVehicleModel(props.model)
                    db.type = GetVehicleClassFromName(db.name)
                    db.plate = props.plate
                    db.amigos = json.decode(db.amigos)
                    table.insert(data, db)
                end
            end
            if #data == 0 then
                TriggerEvent('mono_garage:Notification', locale('VehNoInfo'))
            else
                SendNUIMessage({
                    action = 'garage',
                    show = true,
                    garage = info,
                    vehicles = data
                })
                SetNuiFocus(true, true)
            end
        else
            if info.SpawnCars == true then
                local data = {}
                for k, v in pairs(Garage.Garages) do
                    if info.garage == k then
                        for i, t in pairs(v.jobcar) do
                            if grade_name == t.grade or grade == t.grade then
                                local db = t
                                db.fuelLevel = 100
                                db.engine = 1000
                                db.body = 1000
                                db.name = GetDisplayNameFromVehicleModel(t.model)
                                db.marca = GetMakeNameFromVehicleModel(t.model)
                                db.type = GetVehicleClassFromName(t.name)
                                db.amigos = false
                                db.gradeName = grade_label
                                table.insert(data, db)
                            end
                        end
                    end
                end
                SendNUIMessage({
                    action = 'garage',
                    show = true,
                    garage = info,
                    vehicles = data
                })
                SetNuiFocus(true, true)
            else
                local data = {}
                for i, t in pairs(info.jobcar) do
                    local db = t
                    db.fuelLevel = 100
                    db.engine = 1000
                    db.body = 1000
                    db.name = GetDisplayNameFromVehicleModel(t.model)
                    db.marca = GetMakeNameFromVehicleModel(t.model)
                    db.type = GetVehicleClassFromName(t.name)
                    db.amigos = false
                    db.gradeName = t.text
                    table.insert(data, db)
                end
                SendNUIMessage({
                    action = 'garage',
                    show = true,
                    garage = info,
                    vehicles = data
                })
                SetNuiFocus(true, true)
            end
        end
    elseif Garage.CustomMenu == false then
        local garagemenu = {}
        if info.jobcar == nil then
            local vehiclesFound = false
            for i = 1, #vehicles do
                local data = vehicles[i]
                local props = json.decode(data.vehicle)
                local name = GetDisplayNameFromVehicleModel(props.model)
                local marca = GetMakeNameFromVehicleModel(props.model)
                if info.shareGarage or (data.parking == info.garage) then
                    vehiclesFound = true
                    table.insert(garagemenu, {
                        title = marca .. ' - ' .. name,
                        icon = GetVehicleIcon(name),
                        iconColor = (data.stored == 1) and '#32a852' or '#FF8787',
                        arrow = true,
                        metadata = {
                            { label = locale('VehDescri'), value = data.parking },
                            {
                                label = locale('VehDescrigas'),
                                value = (props.fuelLevel and math.floor(props.fuelLevel / 10) .. '%' or '100%'),
                                progress = (props.fuelLevel and math.floor(props.fuelLevel / 10) or 100),
                            },
                            {
                                label = 'Engine ',
                                value = (props.engineHealth and math.floor(props.engineHealth / 10) .. '%' or '100%'),
                                progress = (props.engineHealth and math.floor(props.engineHealth / 10) or 100),
                            },
                            {
                                label = 'Body ',
                                value = (props.bodyHealth and math.floor(props.bodyHealth / 10) .. '%' or '100%'),
                                progress = (props.bodyHealth and math.floor(props.bodyHealth / 10) or 100),
                            },
                        },
                        colorScheme = '#4ac76b',
                        description = data.isOwner and locale('dueño', props.plate) or locale('deunamigo', props.plate),
                        onSelect = function()
                            VehicleSelected({
                                garage = info.garage,
                                spawn = info.spawnpos,
                                plate = props.plate,
                                owner = data.owner,
                                name = name,
                                type = info.type,
                                marca = marca,
                                model = props.model,
                                stored = data.stored,
                                impo = info.impoundIn,
                                intocar = info.SetInToVehicle,
                                isOwner = data.isOwner,
                                amigos = data.amigos,
                                props = info.props,
                                priceSend = info.priceSend
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
        else
            if info.SpawnCars == true then
                for k, v in pairs(Garage.Garages) do
                    if info.garage == k then
                        for i, t in pairs(v.jobcar) do
                            if grade_name == t.grade or grade == t.grade then
                                local name = GetDisplayNameFromVehicleModel(t.model)
                                local marca = GetMakeNameFromVehicleModel(t.model)
                                table.insert(garagemenu, {
                                    title = marca .. '' .. name,
                                    icon = GetVehicleIcon(name),
                                    arrow = true,
                                    colorScheme = '#4ac76b',
                                    description = 'Solicitar vehiculo',
                                    metadata = {
                                        { label = locale('VehDescrigas'), value = ' 100 %', progress = 100 },
                                        { label = 'Engine ',              value = ' 100 %', progress = 100 },
                                        { label = 'Body ',                value = ' 100 %', progress = 100 },
                                    },
                                    onSelect = function()
                                      --  local SpawPos = false
                                        local coords, heading, SpawPos = SpawnClearArea(v.spawnpos, 2.0)
                                        print(v.SetInToVehicle)
                                        TriggerServerEvent('mono_garage:SpawnVehicle', t.model, coords, heading, t .plate, v.SetInToVehicle)
                                        
                                        if not SpawPos then
                                            TriggerEvent('mono_garage:Notification', locale('NoSpawn'))
                                        end
                                    end,
                                })
                            end
                        end
                    end
                end
                lib.registerContext({
                    id = 'mono_garage:MenuCarList',
                    title = locale('Garaje-', info.garage),
                    options = garagemenu
                })
                lib.showContext('mono_garage:MenuCarList')
            else
                for i, t in pairs(info.jobcar) do
                    local name = GetDisplayNameFromVehicleModel(t.model)
                    local marca = GetMakeNameFromVehicleModel(t.model)
                    table.insert(garagemenu, {
                        title = marca .. '' .. name,
                        icon = GetVehicleIcon(name),
                        arrow = true,
                        colorScheme = '#4ac76b',
                        description = 'Solicitar vehiculo',
                        metadata = {
                            { label = locale('VehDescrigas'), value = ' 100 %', progress = 100 },
                            { label = 'Engine ',              value = ' 100 %', progress = 100 },
                            { label = 'Body ',                value = ' 100 %', progress = 100 },
                        },
                        onSelect = function()
                            local SpawPos = false
                            for posis = 1, #info.spawnpos do
                                local n = info.spawnpos[posis]
                                local pos = vector3(n.x, n.y, n.z)
                                if SpawnClearArea(pos, 2.0) then
                                    TriggerServerEvent('mono_garage:SpawnVehicle', t.model, pos, n.w, t.plate,
                                        info.SetInToVehicle)
                                    SpawPos = true
                                    break
                                end
                            end
                            if not SpawPos then
                                TriggerEvent('mono_garage:Notification', locale('NoSpawn'))
                            end
                        end,
                    })
                end
                lib.registerContext({
                    id = 'mono_garage:MenuCarList',
                    title = locale('Garaje-', info.garage),
                    options = garagemenu
                })
                lib.showContext('mono_garage:MenuCarList')
            end
        end
    end
end

exports('OpenGarage', OpenGarage)

-- Seleccionado
RegisterNetEvent('mono_garage:TransferVehicleClient', function(data, action)
    if action == 'send' then
        if data.input[2] > 0 then
            local alert = lib.alertDialog({
                header = 'Hola ' .. data.Buyer .. ', ' .. data.Seller .. ' quiere venderte un vehiculo.',
                content = 'Informacion  \n  **' ..
                    data.name .. ' - ' .. data.marca .. '  \n  ' .. 'Price** - ' .. data.input[2] .. '$  \n  ',
                centered = true,
                cancel = true
            })
            if alert == 'confirm' then
                TriggerServerEvent('mono_garage:TransferVehicle', data, 'buy')
            elseif alert == 'cancel' then
            end
        else
            local alert = lib.alertDialog({
                header = 'Hola ' .. data.Buyer .. ', ' .. data.Seller .. ' quiere transferirte el vehiculo.',
                content = 'Informacion  \n  **' .. data.name .. ' - ' .. data.marca .. '**',
                centered = true,
                cancel = true
            })
            if alert == 'confirm' then
                TriggerServerEvent('mono_garage:TransferVehicle', data, 'buy')
            elseif alert == 'cancel' then
            end
        end
    end
end)


function VehicleSelected(data)
    local select = {}
    if data.stored == 1 then
        table.insert(select, {
            title = locale('SacarVehiculooo'),
            description = locale('SacarDescription'),
            icon = 'car-side',
            arrow = true,
            onSelect = function()
                local coords, heading, distancia = SpawnClearArea(data.spawn, 2.0)

                if coords then
                    TriggerServerEvent('mono_garage:RetirarVehiculo', data.plate, data.garage, coords, heading,
                        data.model, data.intocar)
                else
                    TriggerEvent('mono_garage:Notification', locale('NoSpawn'))
                end
            end


        })
        if data.isOwner then
            table.insert(select, {
                title = locale('sendvehicle'),
                description = locale('sendvehicleDesc'),
                icon = 'car-side',
                arrow = true,
                onSelect = function()
                    local money = lib.callback.await('mono_garage:getBankMoney')
                    local opt = {}
                    for k, v in pairs(Garage.Garages) do
                        if data.type == 'all' and not v.impound and not v.job then
                            table.insert(opt, { label = k .. ' - ' .. v.type, value = k })
                        elseif not v.impound and not v.job and v.type == data.type then
                            table.insert(opt, { label = k .. ' - ' .. v.type, value = k })
                        end
                    end
                    local priceText = data.priceSend or 'FREE'
                    if data.priceSend == nil then
                        Input = { {
                            type = 'select',
                            icon = 'warehouse',
                            label = locale('selectgarage'),
                            description = locale('actualgarage', data.garage),
                            required = true,
                            options = opt
                        } }
                    else
                        Input = {
                            {
                                type = 'select',
                                icon = 'warehouse',
                                label = locale('selectgarage'),
                                description = locale('actualgarage', data.garage) .. ', Price: ' .. data.priceSend ..
                                    ' $',
                                required = true,
                                options = opt
                            },
                            {

                                type = 'select',
                                icon = 'dollar',
                                required = true,
                                label = locale('ImpoundMetodo'),
                                description = locale('ImpoundMetodo1', money.money, money.bank),
                                options = {
                                    { value = 'money', label = locale('MetodoPagoMoney') },
                                    { value = 'bank',  label = locale('MetodoPagoBank') },
                                }
                            }
                        }
                    end
                    local input = lib.inputDialog(locale('sendvehicle'), Input)
                    if not input then return end
                    data.garage = input[1]
                    data.money = input[2]
                    TriggerServerEvent('mono_garage:ChangeGarage', data)
                end
            })
            if Garage.TrasnferVehicles then
                table.insert(select, {
                    title = locale('Transferir_1'),
                    icon = 'file-import',
                    description = locale('Transferir_2'),
                    arrow = true,
                    onSelect = function()
                        data.input = lib.inputDialog(locale('Transferir_1'), {
                            {
                                type = 'number',
                                label = locale('Transferir_3'),
                                description = locale('Transferir_4'),
                                icon = 'hashtag'
                            },
                            {
                                type = 'number',
                                label = locale('impfunc_price'),
                                min = 0,
                                default = 0,
                                description =
                                    locale('Transferir_5'),
                                icon =
                                'hashtag'
                            },
                        })
                        if not data.input then return end
                        TriggerServerEvent('mono_garage:TransferVehicle', data, 'send')
                    end
                })
            end
        end
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
                                { type = 'input', label = locale('Transferir_3'), description = locale('Compartir3') },
                                { type = 'input', label = locale('Compartir1'),   description = locale('Compartir2') }
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
                                { type = 'input', label = locale('Transferir_3'), description = locale('Compartir3') },
                                { type = 'input', label = locale('Compartir1'),   description = locale('Compartir2') }
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
            local price = infoimpound and infoimpound.price or info.impoundPrice

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
                    lib.registerContext({
                        id = 'mono_garage:ImpoundMenuOption',
                        title = locale('Depo-', info.garage),
                        menu = 'mono_garage:ImpoundMenu',
                        options = {
                            {
                                title = locale('recu1'),
                                icon = 'car-on',
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
                                            required = true,
                                            label = locale('ImpoundMetodo'),
                                            description = locale('ImpoundMetodo1', money.money, money.bank),
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
                                        local coords, heading, distancia = SpawnClearArea(info.spawnpos, 2.0)

                                        if coords then
                                            TriggerServerEvent('mono_garage:RetirarVehiculoImpound', data.plate,
                                                input,
                                                price,
                                                coords, heading, info.SetInToVehicle, info.Society)
                                        else
                                            TriggerEvent('mono_garage:Notification', locale('NoSpawn'))
                                        end
                                        --[[for j = 1, #info.spawnpos do
                                            local v = info.spawnpos[j]
                                            local pos = vec3(v.x, v.y, v.z)
                                            local hea = v.w
                                            if SpawnClearArea(pos, 3.0) then
                                                TriggerServerEvent('mono_garage:RetirarVehiculoImpound', data.plate,
                                                    input,
                                                    price,
                                                    pos, hea, info.SetInToVehicle, info.Society)
                                                SpawPos = true
                                                break
                                            end
                                        end]]
                                    end

                                    if input[1] == 'money' then
                                        if money.money >= price then
                                            Retirar(input[1])
                                        else
                                            TriggerEvent('mono_garage:Notification', locale('SERVER_SinDinero'))
                                        end
                                    elseif input[1] == 'bank' then
                                        if money.bank >= price then
                                            Retirar(input[1])
                                        else
                                            TriggerEvent('mono_garage:Notification', locale('SERVER_SinDinero'))
                                        end
                                    end
                                end
                            },
                            {
                                title = locale('recu2'),
                                icon = 'recycle',
                                onSelect = function()
                                    local opt = {}
                                    for k, v in pairs(Garage.Garages) do
                                        if not v.impound and not v.job and v.type == data.type then
                                            table.insert(opt, { label = k, value = k })
                                        end
                                    end


                                    local input = lib.inputDialog(locale('MetodoPagoTitulo'), {
                                        {
                                            type = 'select',
                                            icon = 'dollar',
                                            required = true,
                                            label = locale('ImpoundMetodo'),
                                            description = locale('ImpoundMetodo1', money.money, money.bank),
                                            options = {
                                                { value = 'money', label = locale('MetodoPagoMoney') },
                                                { value = 'bank',  label = locale('MetodoPagoBank') },
                                            }
                                        },
                                        {
                                            type = 'select',
                                            icon = 'warehouse',
                                            label = locale('selectgarage'),
                                            description = locale('actualgarage', info.garage),
                                            required = true,
                                            options = opt
                                        },
                                    })

                                    if not input then
                                        return
                                    end

                                    input.price = price
                                    input.garage = input[2]
                                    input.money = input[1]
                                    input.society = info.Society
                                    input.plate = data.plate
                                    input.owner = data.owner
                                    input.last = info.garage


                                    TriggerServerEvent('mono_garage:ChangeGarage', input)
                                end
                            }

                        }
                    })
                    lib.showContext('mono_garage:ImpoundMenuOption')
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
