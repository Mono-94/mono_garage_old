lib.locale()

function Crearvehiculo(model, coordinates, heading, props, source, puertas, TaskInCar)

    local vehicle = CreateVehicleServerSetter(model, "automobile", coordinates.x, coordinates.y, coordinates.z, heading) 

    while not DoesEntityExist(vehicle) do                                                                                
        Wait(0)
    end

    Wait(200)

    local networkId = NetworkGetNetworkIdFromEntity(vehicle)

    Wait(200)

    if TaskInCar then
        if Garage.SetInToVehicle then
            TaskWarpPedIntoVehicle(GetPlayerPed(source), vehicle, -1)
        end
    end
    SetVehicleDoorsLocked(vehicle, puertas)

    print(props.plate)

    TriggerClientEvent('sy_garage:Propiedades', source, networkId, props)
    
end

lib.callback.register('sy_garage:getOwnerVehicles', function(source)
    local xPlayer = ESX.GetPlayerFromId(source)
    local identifier = xPlayer.getIdentifier()
    local vehicles = {}

    local results = MySQL.Sync.fetchAll(
        "SELECT * FROM `owned_vehicles` WHERE `owner` = @identifier OR `amigos` LIKE @like_identifier", {
            ['@identifier'] = identifier,
            ['@like_identifier'] = '%' .. identifier .. '%',
        })

    if results[1] ~= nil then
        for i = 1, #results do
            local result = results[i]
            local veh = json.decode(result.vehicle)
            veh.plate = result.plate
            veh.parking = result.parking
            veh.stored = result.stored
            veh.pound = result.pound
            veh.mileage = result.mileage
            veh.type = result.type
            veh.id = identifier
            veh.duen = result.owner
            veh.amigos = result.amigos
            veh.props = result.vehicle

            local isFriend = false
            if amigos ~= nil then
                for j = 1, #amigos do
                    local amigo = amigos[j]
                    if amigo == identifier then
                        isFriend = true
                        break
                    end
                end
            end
            if result.owner == identifier or isFriend then
                veh.owned = true
                vehicles[#vehicles + 1] = veh
            end
        end
    end

    -- vehiculo compartido
    local sharedResults = MySQL.Sync.fetchAll(
        "SELECT * FROM `owned_vehicles` WHERE JSON_CONTAINS(`amigos`, @identifier, '$')", {
            ['@identifier'] = json.encode({ identifier = identifier }),
        })

    if sharedResults[1] ~= nil then
        for i = 1, #sharedResults do
            local result = sharedResults[i]
            local veh = json.decode(result.vehicle)
            veh.plate = result.plate
            veh.parking = result.parking
            veh.stored = result.stored
            veh.pound = result.pound
            veh.mileage = result.mileage
            veh.type = result.type
            veh.id = identifier
            veh.duen = result.owner
            veh.amigos = json.decode(result.amigos)
            veh.props = result.vehicle
            --AGregar vehiculo si esta compartido a la lista.
            if result.owner ~= identifier then
                veh.owned = false
                vehicles[#vehicles + 1] = veh
            end
        end
    end



    return vehicles
end)


lib.callback.register('sy_garage:owner_vehicles', function(source)
    local vehicles = {}
    local results = MySQL.Sync.fetchAll("SELECT * FROM `owned_vehicles`")
    if results[1] ~= nil then
        for i = 1, #results do
            local result = results[i]
            local veh = json.decode(result.vehicle)

            veh.plate = result.plate
            veh.parking = result.parking
            veh.stored = result.stored
            veh.pound = result.pound
            veh.mileage = result.mileage
            veh.type = result.type
            veh.owner = result.owner
            veh.vehicle = result.vehicle
            veh.lastposition = result.lastposition

            vehicles[#vehicles + 1] = veh

            if Garage.Debug then
                print('Matrícula:', veh.plate, 'Modelo:', veh.model, 'positiom: ', veh.lastposition)
            end
        end

        return vehicles
    end
end)

RegisterServerEvent('sy_garage:EliminarAmigo', function(Amigo, plate)
    local source = source
    local xPlayer = ESX.GetPlayerFromId(source)
    local xIndidentifier = xPlayer.getIdentifier()
    MySQL.Async.fetchAll(
        "SELECT `amigos` FROM `owned_vehicles` WHERE `owner` = @identifier AND `plate` = @plate", {
            ['@identifier'] = xIndidentifier,
            ['@plate'] = plate
        }, function(result)
            if result[1] ~= nil then
                local amigosTable = {}
                if result[1].amigos ~= nil and result[1].amigos ~= '' then
                    amigosTable = json.decode(result[1].amigos)
                end
                local found = false
                for i, amigo in ipairs(amigosTable) do
                    if amigo.name == Amigo then
                        table.remove(amigosTable, i)
                        found = true
                        break
                    end
                end
                if found then
                    local amigosStr = json.encode(amigosTable)

                    if #amigosTable == 0 then
                        amigosStr = nil
                    end

                    MySQL.Async.execute(
                        "UPDATE `owned_vehicles` SET `amigos` = @amigos WHERE `owner` = @identifier AND `plate` = @plate",
                        {
                            ['@identifier'] = xIndidentifier,
                            ['@plate'] = plate,
                            ['@amigos'] = amigosStr
                        }, function(rowsChanged)
                            if rowsChanged > 0 then
                                TriggerClientEvent('sy_garage:Notification', source,
                                    locale('AmigosLista1', Amigo, plate))
                            else
                                TriggerClientEvent('sy_garage:Notification', source,
                                    locale('AmigosLista2', Amigo, plate))
                            end
                        end)
                else
                    if Garage.Debug then
                        print('No se encontró al amigo ' .. Amigo .. ' en el vehículo con la matricula ' .. plate)
                    end
                end
            else
                if Garage.Debug then
                    print('No se pudo encontrar el vehículo con la matricula ' .. plate)
                end
            end
        end)
end)




RegisterServerEvent('sy_garage:CompartirAmigo', function(Amigo, Name, plate)
    local source = source
    local xPlayer = ESX.GetPlayerFromId(source)
    local xIndidentifier = xPlayer.getIdentifier()

    local xAmigo = ESX.GetPlayerFromId(Amigo)
    local identifier = xAmigo.getIdentifier()

    if identifier == xIndidentifier then
        TriggerClientEvent('sy_garage:Notification', source, locale('noatimismo'))
        return
    end

    MySQL.Async.fetchAll(
        "SELECT `amigos` FROM `owned_vehicles` WHERE `owner` = @identifier AND `plate` = @plate", {
            ['@identifier'] = xIndidentifier,
            ['@plate'] = plate
        }, function(result)
            if result[1] ~= nil then
                local amigosTable = {}
                if result[1].amigos ~= nil and result[1].amigos ~= '' then
                    amigosTable = json.decode(result[1].amigos)
                end
                local amigoData = { name = Name, identifier = identifier }
                amigosTable[#amigosTable + 1] = amigoData
                local amigosStr = json.encode(amigosTable)


                MySQL.Async.execute(
                    "UPDATE `owned_vehicles` SET `amigos` = @amigos WHERE `owner` = @identifier AND `plate` = @plate",
                    {
                        ['@identifier'] = xIndidentifier,
                        ['@plate'] = plate,
                        ['@amigos'] = amigosStr
                    }, function(rowsChanged)
                        if rowsChanged > 0 then
                            TriggerClientEvent('sy_garage:Notification', source,
                                locale('AmigosLista3', plate, xAmigo.getName()))
                            TriggerClientEvent('sy_garage:Notification', xAmigo.source, locale('AmigosLista4', plate))
                        else
                            TriggerClientEvent('sy_garage:Notification', source,
                                locale('AmigosLista5', xAmigo.getName()))
                        end
                    end)
            else
                if Garage.Debug then
                    print('No se pudo encontrar el vehículo con la matricula ' .. plate)
                end
            end
        end)
end)



RegisterServerEvent('sy_garage:GuardarVehiculo', function(plate, vehicleData, garageName, vehicle)
    local source = source
    local xPlayer = ESX.GetPlayerFromId(source)
    local identifier = xPlayer.getIdentifier()
    local vehicleDataDecoded = json.decode(vehicleData)
    local vehicleDataEncoded = json.encode(vehicleDataDecoded)
    MySQL.Async.fetchAll(
        "SELECT `stored` FROM `owned_vehicles` WHERE `owner` = @identifier OR `amigos` AND `plate` = @plate",
        {
            ['@identifier'] = identifier,
            ['@plate'] = string.format("%-8s", plate),
        },
        function(result)
            if result and result[1] then
                local stored = result[1].store
                local parking = garageName
                if stored ~= 1 then
                    stored = 1
                end
                if owner == identifier then
                    MySQL.Async.execute(
                        "UPDATE `owned_vehicles` SET `vehicle` = @vehicleData, `stored` = @stored, `parking` = @parking WHERE `owner` = @identifier AND `plate` = @plate",
                        {
                            ['@identifier'] = identifier,
                            ['@vehicleData'] = vehicleDataEncoded,
                            ['@plate'] = string.format("%-8s", plate),
                            ['@stored'] = stored,
                            ['@parking'] = parking,
                        },
                        function(rowsChanged)
                            if rowsChanged > 0 then
                                local vehicle = NetworkGetEntityFromNetworkId(vehicle)
                                DeleteEntity(vehicle)
                                if Garage.Debug then
                                    print('Guardando vehículo con placa ' .. plate .. ' para jugador ' .. identifier)
                                end
                                TriggerClientEvent('sy_garage:Notification', source,
                                    locale('SERVER_VehiculoGuardado'))
                            else
                                TriggerClientEvent('sy_garage:Notification', source,
                                    locale('SERVER_ErrorGuardad'))
                            end
                        end
                    )
                else
                    MySQL.Async.execute(
                        "UPDATE `owned_vehicles` SET `vehicle` = @vehicleData, `stored` = @stored, `parking` = @parking WHERE  `plate` = @plate",
                        {
                            ['@vehicleData'] = vehicleDataEncoded,
                            ['@plate'] = string.format("%-8s", plate),
                            ['@stored'] = stored,
                            ['@parking'] = parking,
                        },
                        function(rowsChanged)
                            if rowsChanged > 0 then
                                local vehicle = NetworkGetEntityFromNetworkId(vehicle)
                                DeleteEntity(vehicle)
                                if Garage.Debug then
                                    print('Guardando vehículo con placa ' .. plate .. ' para jugador ' .. identifier)
                                end
                                TriggerClientEvent('sy_garage:Notification', source,
                                    locale('SERVER_VehiculoGuardado'))
                            else
                                TriggerClientEvent('sy_garage:Notification', source,
                                    locale('SERVER_ErrorGuardad'))
                            end
                        end
                    )
                end
            else
                -- Si la matri no coincide
                TriggerClientEvent('sy_garage:Notification', source, locale('NoEsTuyo'))
            end
        end
    )
end)





lib.callback.register('sy_garage:getBankMoney', function(source)
    local xPlayer = ESX.GetPlayerFromId(source)
    local bank = xPlayer.getAccount("bank")
    local money = xPlayer.getMoney()
    return { bank = bank.money, money = money }
end)


RegisterServerEvent('sy_garage:RetirarVehiculo', function(plate, lastparking, pos, hea, props, model)
    local source = source
    MySQL.Async.execute(
        "UPDATE `owned_vehicles` SET `stored` = 0, `lastparking` = @lastparking WHERE `plate` = @plate",
        {
            --   ['@identifier'] = identifier,
            ['@lastparking'] = lastparking,
            ['@plate'] = plate,
        }, function(rowsChanged)
            if rowsChanged > 0 then
                Crearvehiculo(model, pos, hea, props, source, 0, true)
                TriggerClientEvent('sy_garage:Notification', source,
                    locale('SERVER_retirar'))
            else
                TriggerClientEvent('sy_garage:Notification', source,
                    locale('SERVER_ErrorRetirar'))
            end
        end)
end)



RegisterServerEvent('sy_garage:RetirarVehiculoImpound', function(plate, money, price, props, pos, hea, model)
    local source = source
    local xPlayer = ESX.GetPlayerFromId(source)
    local identifier = xPlayer.getIdentifier()
    local bank = xPlayer.getAccount("bank")
    local price = price
    if money == 'money' then
        if xPlayer.getMoney() >= price then
            MySQL.Async.execute(
                "UPDATE `owned_vehicles` SET `pound` = NULL, `parking` = (SELECT `lastparking` FROM `owned_vehicles` WHERE `owner` = @identifier AND `plate` = @plate) WHERE `owner` = @identifier AND `plate` = @plate",
                {
                    ['@identifier'] = identifier,
                    ['@plate'] = plate,
                }, function(rowsChanged)
                    if rowsChanged > 0 then
                        Crearvehiculo(model, pos, hea, props, source, 0, true)

                        xPlayer.removeAccountMoney("money", price)
                        TriggerClientEvent('sy_garage:Notification', source,
                            locale('SERVER_RetirarImpound', price))
                    else
                        TriggerClientEvent('sy_garage:Notification', source,
                            locale('SERVER_RetirarImpoundError'))
                    end
                end)
        else
            TriggerClientEvent('sy_garage:Notification', source,
                locale('SERVER_SinDinero'))
        end
    elseif money == 'bank' then
        if bank.money >= price then
            MySQL.Async.execute(
                "UPDATE `owned_vehicles` SET `pound` = NULL, `parking` = (SELECT `lastparking` FROM `owned_vehicles` WHERE `owner` = @identifier AND `plate` = @plate) WHERE `owner` = @identifier AND `plate` = @plate",
                {
                    ['@identifier'] = identifier,
                    ['@plate'] = plate,
                }, function(rowsChanged)
                    if rowsChanged > 0 then
                        Crearvehiculo(model, pos, hea, props, source, 0, true)
                        xPlayer.removeAccountMoney("bank", price)
                        TriggerClientEvent('sy_garage:Notification', source,
                            locale('SERVER_RetirarImpound', price))
                    else
                        TriggerClientEvent('sy_garage:Notification', source,
                            locale('SERVER_RetirarImpoundError'))
                    end
                end)
        else
            TriggerClientEvent('sy_garage:Notification', source,
                locale('SERVER_SinDinero'))
        end
    end
end)

function DeleteVehicleByPlate(plate)
    local vehicles = GetAllVehicles()
    for i = 1, #vehicles, 1 do
        if GetVehicleNumberPlateText(vehicles[i]) == plate or (string.match(GetVehicleNumberPlateText(vehicles[i]), plate:gsub("%s", ".*")) ~= nil) then
            DeleteEntity(vehicles[i])
            return true
        end
    end
    return false
end

RegisterServerEvent('sy_garage:MandarVehiculoImpound', function(plate, impo)
    local source = source
    local xPlayer = ESX.GetPlayerFromId(source)
    local identifier = xPlayer.getIdentifier()

    MySQL.Async.execute(
        "UPDATE `owned_vehicles` SET `parking` = @impo, `pound` = 1 WHERE `owner` = @identifier AND `plate` = @plate",
        {
            ['@identifier'] = identifier,
            ['@plate'] = plate,
            ['@impo'] = impo,
        }, function(rowsChanged)
            if rowsChanged > 0 then
                DeleteVehicleByPlate(plate)
                TriggerClientEvent('sy_garage:Notification', source, locale('SERVER_MandarVehiculoImpound'))
            else
                TriggerClientEvent('sy_garage:Notification', source, locale('SERVER_MandarMal'))
            end
        end)
end)










RegisterServerEvent('sy_garage:AgregarKilometros', function(vehPlate, km)
    local plate = vehPlate
    local newKM = km

    MySQL.Async.fetchScalar('SELECT plate FROM owned_vehicles WHERE plate = @plate', { ['@plate'] = plate },
        function(result)
            MySQL.Async.execute('UPDATE owned_vehicles SET mileage = @kms WHERE plate = @plate',
                { ['@plate'] = plate, ['@kms'] = newKM })
        end)
end)

lib.addCommand(Garage.OwnerCarAdmin.Command, {
    help = locale('setearcar2'),
    restricted = Garage.OwnerCarAdmin.Group,
}, function(source)
    TriggerClientEvent('sy_garage:CheckVeh2', source)
end)



RegisterNetEvent('sy_garage:SetCarDB', function(vehicleData, plate)
    local source = source
    local xPlayer = ESX.GetPlayerFromId(source)
    if xPlayer.getGroup() == Garage.OwnerCarAdmin.Group then
        local plate = plate
        local results = MySQL.Sync.fetchAll(
            "SELECT * FROM owned_vehicles WHERE plate = @plate",
            { ['@plate'] = plate })
        if results[1] ~= nil then
            print('El vehículo con placa ' .. plate .. ' ya está en propiedad.')
        else
            vehicleData.plate = plate
            local jsonVehicleData = json.encode(vehicleData)
            MySQL.Sync.execute(
                "INSERT INTO owned_vehicles (owner, plate, vehicle) VALUES (@owner, @plate, @vehicle)",
                {
                    ['@owner']   = xPlayer.identifier,
                    ['@plate']   = plate,
                    ['@vehicle'] = jsonVehicleData,
                })
            print('El vehículo con placa ' ..
                plate .. ' ha sido agregado a las propiedades de ' .. xPlayer.getName() .. '.')
            TriggerEvent('sy_carkeys:CreateKey', plate, name)
        end
    else
        print('El jugador ' ..
            xPlayer.getName() .. ' no tiene permisos suficientes para agregar vehículos a las propiedades.')
    end
end)

if Garage.Persistent.Persitent then
    local vehiclesSpawned = {}

    RegisterNetEvent('esx:playerLoaded', function(player, xPlayer, isNew, cb)
        print(player, 'loaded', xPlayer.getName())
        if xPlayer then
            local results = MySQL.Sync.fetchAll("SELECT * FROM `owned_vehicles` WHERE owner = @identifier", {
                ['@identifier'] = xPlayer.getIdentifier()
            })
            if results[1] ~= nil then
                local allVehicles = GetAllVehicles()
                for i = 1, #results do
                    local result = results[i]
                    local veh = json.decode(result.vehicle)
                    local pos = json.decode(result.lastposition)

                    if pos ~= nil then
                        local plate = veh.plate
                        local model = veh.model
                        local coords = vector3(pos.x, pos.y, pos.z)
                        local Heading = pos.h
                        if not vehiclesSpawned[plate] then
                            if result.stored == 0 then
                                if not vehiclesSpawned[plate] then
                                    if result.stored == 0 then
                                        Crearvehiculo(model, coords, Heading, veh, player, pos.doors, false)

                                        --   if Garage.Debug then
                                        print('\027[1mVEHICLE SPAWN \027[0m ( Player Connect  ' ..
                                            xPlayer.getName() ..
                                            ' "\027[33m' ..
                                            plate ..
                                            '"\027[0m - \027[36mVector3(' ..
                                            coords .. ') Doors: \027[0m' .. pos.doors .. ', ( 0 = open / 2 close))')
                                        -- end
                                        vehiclesSpawned[plate] = true
                                    end
                                end

                                vehiclesSpawned[plate] = true
                            end
                        end
                    end
                end
            end
        end
    end)

    RegisterCommand('exit', function(source)
        local source = source
        local allVehicles = GetAllVehicles()
        local xPlayer = ESX.GetPlayerFromId(source)
        local identifier = xPlayer.getIdentifier()

        for i = 1, #allVehicles do
            local vehEntity = allVehicles[i]
            if DoesEntityExist(vehEntity) and GetEntityPopulationType(vehEntity) == 7 then
                local plate = GetVehicleNumberPlateText(vehEntity)
                local owner = MySQL.Sync.fetchScalar('SELECT owner FROM owned_vehicles WHERE plate = @plate', {
                    ['@plate'] = plate
                })
                if owner == identifier then
                    local position = GetEntityCoords(vehEntity)
                    local heading = GetEntityHeading(vehEntity)
                    local doorLockStatus = GetVehicleDoorLockStatus(vehEntity)
                    local posTable = {
                        x = position.x,
                        y = position.y,
                        z = position.z,
                        h = heading,
                        doors = doorLockStatus
                    }
                    local posStr = json.encode(posTable)
                    MySQL.Async.execute(
                        'UPDATE owned_vehicles SET lastposition = @lastposition WHERE plate = @plate',
                        {
                            ['@lastposition'] = posStr,
                            ['@plate'] = plate
                        }, function(rowsChanged)
                            vehiclesSpawned[plate] = false
                            if Garage.Debug then
                                print('\027[1mSAVE VEHICLE\027[0m ( "\027[33m' ..
                                    plate ..
                                    '"\027[0m - \027[36mvector4(' ..
                                    position.x ..
                                    ',' ..
                                    position.y ..
                                    ',' ..
                                    position.z ..
                                    ',' .. heading .. ' )\027[0m Doors: ' .. doorLockStatus .. ', ( 0 = Open / 2 Close))')
                            end
                            if Garage.Persistent.DeleteCarDisconnect then
                                DeleteEntity(vehEntity)
                                print('\027[1mVEHICLE DELETED\027[0m ( "\027[33m' .. plate .. '"\027[0m )')
                            else

                            end
                        end)
                end
            end
        end
    end)

    AddEventHandler('playerDropped', function(reason)
        local allVehicles = GetAllVehicles()
        local xPlayer = ESX.GetPlayerFromId(source)
        local identifier = xPlayer.getIdentifier()

        for i = 1, #allVehicles do
            local vehEntity = allVehicles[i]
            if DoesEntityExist(vehEntity) and GetEntityPopulationType(vehEntity) == 7 then
                local plate = GetVehicleNumberPlateText(vehEntity)
                local owner = MySQL.Sync.fetchScalar('SELECT owner FROM owned_vehicles WHERE plate = @plate', {
                    ['@plate'] = plate
                })
                if owner == identifier then
                    local position = GetEntityCoords(vehEntity)
                    local heading = GetEntityHeading(vehEntity)
                    local doorLockStatus = GetVehicleDoorLockStatus(vehEntity)
                    local posTable = {
                        x = position.x,
                        y = position.y,
                        z = position.z,
                        h = heading,
                        doors = doorLockStatus
                    }
                    local posStr = json.encode(posTable)
                    MySQL.Async.execute(
                        'UPDATE owned_vehicles SET lastposition = @lastposition WHERE plate = @plate',
                        {
                            ['@lastposition'] = posStr,
                            ['@plate'] = plate
                        }, function(rowsChanged)
                            vehiclesSpawned[plate] = false
                            if Garage.Debug then
                                print('\027[1mSAVE VEHICLE\027[0m ( "\027[33m' ..
                                    plate ..
                                    '"\027[0m - \027[36mvector4(' ..
                                    position.x ..
                                    ',' ..
                                    position.y ..
                                    ',' ..
                                    position.z ..
                                    ',' .. heading .. ' )\027[0m Doors: ' .. doorLockStatus .. ', ( 0 = Open / 2 Close))')
                            end
                            if Garage.Persistent.DeleteCarDisconnect then
                                DeleteEntity(vehEntity)
                                print('\027[1mVEHICLE DELETED\027[0m ( "\027[33m' .. plate .. '"\027[0m )')
                            else

                            end
                        end)
                end
            end
        end
    end)
end



if Garage.AutoImpound.AutoImpound then
    CreateThread(function()
        while true do
            local vehicles = MySQL.Sync.fetchAll("SELECT * FROM `owned_vehicles`")
            for i = 1, #vehicles do
                local data = vehicles[i]
                local allVehicles = GetAllVehicles()
                local vehicleFound = false
                for j = 1, #allVehicles do
                    local vehicle = allVehicles[j]
                    if DoesEntityExist(vehicle) then
                        local plate = GetVehicleNumberPlateText(vehicle)
                        if plate == data.plate then
                            vehicleFound = true
                            local ped = GetPedInVehicleSeat(vehicle, -1)
                            if ped == 0 then
                                if data.stored == 0 then
                                    if Garage.Debug then
                                        print('^0Plate: ' .. data.plate .. ', ^1Fuera sin jugador.')
                                    end
                                end
                            else
                                if Garage.Debug then
                                    print('^0Plate: ' .. data.plate .. ', ^2Fuera con jugador.')
                                end
                            end
                        end
                    end
                end

                if not vehicleFound and data.stored == 0 and data.pound == nil then
                    MySQL.Async.execute(
                        "UPDATE `owned_vehicles` SET `parking` = @impo, `pound` = 1 WHERE  `plate` = @plate", {
                            ['@plate'] = data.plate,
                            ['@impo'] = Garage.AutoImpound.ImpoundIn,
                        }, function(rowsChanged)
                            if rowsChanged > 0 then
                                if Garage.Debug then
                                    print('El vehiculo con la matricula ' ..
                                        data.plate .. ' fue depositado en ' .. Garage.AutoImpound.ImpoundIn)
                                end
                            else
                                if Garage.Debug then
                                    print('error')
                                end
                            end
                        end)
                end
            end
            Wait(Garage.AutoImpound.TimeCheck)
        end
    end)
end
