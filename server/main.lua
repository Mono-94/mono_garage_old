if Keys.Keys then
    lib.locale()

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
                                    TriggerClientEvent('sy_garage:Notification', xPlayer.source,
                                        locale('SERVER_VehiculoGuardado'))
                                else
                                    TriggerClientEvent('sy_garage:Notification', xPlayer.source,
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
                                if Garage.Debug then
                                end
                                if rowsChanged > 0 then
                                    local vehicle = NetworkGetEntityFromNetworkId(vehicle)
                                    DeleteEntity(vehicle)
                                    if Garage.Debug then
                                        print('Guardando vehículo con placa ' .. plate .. ' para jugador ' .. identifier)
                                    end
                                    TriggerClientEvent('sy_garage:Notification', xPlayer.source,
                                        locale('SERVER_VehiculoGuardado'))
                                else
                                    TriggerClientEvent('sy_garage:Notification', xPlayer.source,
                                        locale('SERVER_ErrorGuardad'))
                                end
                            end
                        )
                    end
                else
                    -- Si la matri no coincide
                    TriggerClientEvent('sy_garage:Notification', xPlayer.source, locale('NoEsTuyo'))
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
                    ESX.OneSync.SpawnVehicle(model, pos, hea, props, function(vehicle)
                        local vehicle = NetworkGetEntityFromNetworkId(vehicle)
                        Wait(300)

                        if Garage.SetInToVehicle then
                            TaskWarpPedIntoVehicle(GetPlayerPed(source), vehicle, -1)
                        end

                        SetVehicleDoorsLocked(vehicle, 0)
                    end)
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
                            ESX.OneSync.SpawnVehicle(model, pos, hea, props, function(vehicle)
                                local vehicle = NetworkGetEntityFromNetworkId(vehicle)
                                Wait(300)

                                if Garage.SetInToVehicle then
                                    TaskWarpPedIntoVehicle(source, vehicle, -1)
                                end
                                SetVehicleDoorsLocked(vehicle, 0)
                            end)
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
                            ESX.OneSync.SpawnVehicle(model, pos, hea, props, function(vehicle)
                                local vehicle = NetworkGetEntityFromNetworkId(vehicle)
                                Wait(300)

                                if Garage.SetInToVehicle then
                                    TaskWarpPedIntoVehicle(source, vehicle, -1)
                                end
                                SetVehicleDoorsLocked(vehicle, 0)
                            end)
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
                    TriggerClientEvent('sy_garage:Notification', xPlayer.source,
                        locale('SERVER_MandarVehiculoImpound'))
                else
                    TriggerClientEvent('sy_garage:Notification', xPlayer.source,
                        locale('SERVER_MandarMal'))
                end
            end)
    end)










    RegisterServerEvent('sy_garage:AgregarKilometros', function(vehPlate, km)
        local plate = vehPlate
        local newKM = km

        MySQL.Async.fetchScalar('SELECT plate FROM owned_vehicles WHERE plate = @plate', { ['@plate'] = plate },
            function(result)
                MySQL.Async.execute('UPDATE owned_vehicles SET mileage = @kms WHERE plate = @plate',
                    { ['@plate'] = plate,['@kms'] = newKM })
            end)
    end)

    lib.addCommand(Garage.OwnerCarAdmin.Command, {
        help = locale('setearcar2'),
        restricted = Garage.OwnerCarAdmin.Group
    }, function(source)
        local source = source
        local playerPed = GetPlayerPed(source)
        local playerVehicle = GetVehiclePedIsIn(playerPed, false)

        if playerVehicle then
            TriggerClientEvent('sy_garage:CheckVeh', source, playerVehicle)
        end
    end)




    ESX.RegisterServerCallback('sy_garage:SetCarDB', function(source, cb, vehicleData, plate)
        local xPlayer = ESX.GetPlayerFromId(source)
        if xPlayer then
            if xPlayer.getGroup() == Garage.OwnerCarAdmin.Group then
                local plate = plate
                vehicleData.plate = plate
                local jsonVehicleData = json.encode(vehicleData)
                MySQL.Sync.execute(
                    "INSERT INTO owned_vehicles (owner, plate, vehicle) VALUES (@owner, @plate, @vehicle)",
                    {
                        ['@owner']   = xPlayer.identifier,
                        ['@plate']   = plate,
                        ['@vehicle'] = jsonVehicleData,
                    })
                cb(true, plate)
            else
                cb(false, nil)
            end
        else
            cb(false, nil)
        end
    end)
end
