ESX = exports["es_extended"]:getSharedObject()

lib.locale()

local vehiculoCreado, vehiclesSpawned = {}, {}

local function CrearVehiculo(data, cb)
    Citizen.CreateThread(function()
        data.entity = CreateVehicleServerSetter(data.model, "automobile", data.coords.x, data.coords.y, data.coords.z,
            data.heading)
        while not DoesEntityExist(data.entity) do
            Citizen.Wait(1)
        end

        if data.props == false then
            SetVehicleNumberPlateText(data.entity, data.plate)
            Entity(data.entity).state.CrearVehiculo = { custom = true, props = data.props }
            if Garage.Fuel == 'ox_fuel' then
                Entity(data.entity).state.fuel = 100
            end
        else
            vehiculoCreado[data.entity] = data.props.plate
            vehiclesSpawned[data.plate] = { entity = data.entity, plate = data.plate }
            Entity(data.entity).state.CrearVehiculo = data.props
            SetVehicleDoorsLocked(data.entity, data.doors)
            SetVehicleNumberPlateText(data.entity, data.plate)
            if Garage.Fuel == 'ox_fuel' then
                Entity(data.entity).state.fuel = data.props.fuelLevel
            end
        end
        Bug('Function CrearVehiculo', 'Vehicle Spawned, Entity %s', data.entity)

        cb(data.entity)

        return data.entity
    end)
end

-- Delete duplicate vehicle Plate
--[[Citizen.CreateThread(function()
    while true do
        Citizen.Wait(1000 * 10)]]
lib.cron.new('*/01 * * * *', function()
    local duplicates = {}
    for entity, plate in pairs(vehiculoCreado) do
        if PlateCount(plate, vehiculoCreado) then
            table.insert(duplicates, entity)
        end
    end
    if #duplicates > 0 then
        local entityToRemove = duplicates[1]
        if DoesEntityExist(entityToRemove) then
            DeleteEntity(entityToRemove)
            vehiculoCreado[entityToRemove] = nil
        end
    end
end)
-- end
--end)



RegisterServerEvent('mono_garage:SpawnVehicle', function(model, pos, hea, plate, into)
    local source = source
    CrearVehiculo({ model = model, coords = pos, heading = hea, props = false, plate = plate }, function(vehicle)
        PlayerToCar({ player = source, plate = plate, entity = vehicle, intocar = into, impound = false })
    end)
end)



lib.callback.register('mono_garage:getOwnerVehicles', function(source)
    local xPlayer = ESX.GetPlayerFromId(source)
    local identifier = xPlayer.identifier
    local vehicles = MySQL.query.await("SELECT * FROM `owned_vehicles` WHERE `owner` = ? OR `amigos` LIKE ?",
        { identifier, '%' .. identifier .. '%' })
    for i, result in ipairs(vehicles) do
        local amigos = json.decode(result.amigos)
        local isOwner = result.owner == identifier
        if not isOwner and amigos then
            for j, amigo in ipairs(amigos) do
                if amigo.identifier == identifier then
                    isOwner = false
                    break
                end
            end
        end
        result.isOwner = isOwner
    end
    return vehicles
end)


lib.callback.register('mono_garage:GetPlayerNamePlate', function(source, plate)
    local name = {}
    local current_time = os.time()

    local result = MySQL.query.await(
        "SELECT owner, firstname, lastname FROM owned_vehicles JOIN users ON owned_vehicles.owner = users.identifier WHERE plate = ?",
        { plate })
    if result and #result > 0 then
        name.name = result[1].firstname .. ' ' .. result[1].lastname
    else
        name.name = 'Name not found!'
    end
    name.fecha = os.date("%d/%m/%Y", current_time)
    name.hora = os.date("%H:%M:%S", current_time)

    return name
end)


lib.callback.register('mono_garage:ChangePlateOwner', function(source, plate)
    local xPlayer = ESX.GetPlayerFromId(source)
    local identifier = xPlayer.identifier

    local owner = MySQL.query.await(
        "SELECT * FROM owned_vehicles WHERE owner = @identifier", {
            ['@identifier'] = identifier,
        })

    for i, result in ipairs(owner) do
        if PlateEqual(result.plate, plate) then
            return true
        end
    end

    return false
end)


lib.callback.register('mono_garage:GetVehicleCoords', function(source, plate1)
    local vehicles = MySQL.query.await("SELECT * FROM owned_vehicles")
    for i = 1, #vehicles do
        local data = vehicles[i]
        if PlateEqual(data.plate, plate1) then
            local pos = json.decode(data.lastposition)
            if pos then
                return vec3(pos.x, pos.y, pos.z)
            else
                local allVeh = GetAllVehicles()
                for i = 1, #allVeh do
                    local plate = GetVehicleNumberPlateText(allVeh[i])
                    if PlateEqual(plate, plate1) then
                        return GetEntityCoords(allVeh[i])
                    end
                end
            end
        end
    end
end)


lib.callback.register('mono_garage:getBankMoney', function(source)
    local xPlayer = ESX.GetPlayerFromId(source)
    local bank = xPlayer.getAccount("bank")
    local money = xPlayer.getMoney()
    local job = xPlayer.getJob().name
    return { bank = bank.money, money = money, job = job }
end)


RegisterServerEvent('mono_garage:EliminarAmigo', function(Amigo, plate)
    Bug('mono_garage:EliminarAmigo', 'Amigo = %s, Plate =  %s', Amigo, plate)
    plate = string.gsub(plate, "^%s*(.-)%s*$", "%1")
    local source = source
    local xPlayer = ESX.GetPlayerFromId(source)
    local xIndidentifier = xPlayer.identifier
    MySQL.query("SELECT amigos FROM owned_vehicles WHERE owner = ? AND plate = ?", { xIndidentifier, plate },
        function(result)
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
                    MySQL.update("UPDATE owned_vehicles SET amigos = ? WHERE owner = ? AND plate = ?",
                        { amigosStr, xIndidentifier, plate },
                        function(rowsChanged)
                            if rowsChanged > 0 then
                                Noti(source, locale('AmigosLista1', Amigo, plate))
                            else
                                Noti(source, locale('AmigosLista2', Amigo, plate))
                            end
                        end)
                end
            end
        end)
end)

RegisterServerEvent('mono_garage:CompartirAmigo', function(Amigo, Name, plate)
    Bug('mono_garage:CompartirAmigo ', 'Amigo = %s, Name =  %s, Plate =  %s', Amigo, Name, plate)
    local source = source
    local xPlayer = ESX.GetPlayerFromId(source)
    local xIndidentifier = xPlayer.identifier
    local xAmigo = ESX.GetPlayerFromId(Amigo)
    local identifier = xAmigo.identifier
    plate = string.gsub(plate, "^%s*(.-)%s*$", "%1")
    if identifier == xIndidentifier then
        return Noti(source, locale('noatimismo'))
    end

    MySQL.query("SELECT amigos FROM owned_vehicles WHERE owner = ? AND plate = ?", { xIndidentifier, plate },
        function(result)
            if result[1] ~= nil then
                local amigosTable = {}
                if result[1].amigos ~= nil and result[1].amigos ~= '' then
                    amigosTable = json.decode(result[1].amigos)
                end
                local amigoData = { name = Name, identifier = identifier }
                amigosTable[#amigosTable + 1] = amigoData
                local amigosStr = json.encode(amigosTable)
                MySQL.update("UPDATE owned_vehicles SET amigos = ? WHERE owner = ? AND plate = ?",
                    { amigosStr, xIndidentifier, plate },
                    function(rowsChanged)
                        if rowsChanged > 0 then
                            Noti(source, locale('AmigosLista3', plate, xAmigo.getName()))
                            Noti(xAmigo.source, locale('AmigosLista4', plate))
                        else
                            Noti(source, locale('AmigosLista5', xAmigo.getName()))
                        end
                    end)
            else
                Bug('mono_garage:CompartirAmigo ', 'No se pudo encontrar el vehículo con la matricula %s', plate)
            end
        end)
end)

RegisterServerEvent('mono_garage:SaveVechile', function(data)
    local source = source
    local entity = NetworkGetEntityFromNetworkId(data.entity)
    local plate = GetVehicleNumberPlateText(entity)
    if data.type == 'custom' then
        if data.garage == true then
            local no = false
            for k, v in pairs(Garage.Garages) do
                if v.jobcar ~= nil then
                    for modelo, nombre in pairs(v.jobcar) do
                        if data.model == nombre.model and PlateEqual(nombre.plate, plate) then
                            PlayerOutCar({ entity = entity, plate = nombre.plate, count = 1, player = source })
                            no = true
                            break
                        end
                    end
                end
            end
            if not no then Noti(source, locale('NoAqui')) end
        else
            local no = false
            for modelo, nombre in pairs(data.jobcar) do
                if data.model == nombre.model and PlateEqual(nombre.plate, plate) then
                    PlayerOutCar({ entity = entity, plate = nombre.plate, count = 1, player = source })
                    no = true
                    break
                end
            end
            if not no then Noti(source, locale('NoEsDeAqui')) end
        end
    else
        local xPlayer = ESX.GetPlayerFromId(source)
        local identifier = xPlayer.identifier
        local encontrado = false
        local vehicles = MySQL.query.await("SELECT * FROM owned_vehicles WHERE owner = ? OR amigos LIKE ?",
            { identifier, '%' .. identifier .. '%' })
        for i, result in ipairs(vehicles) do
            local amigos = json.decode(result.amigos)
            local isOwner = result.owner == identifier
            if PlateEqual(result.plate, plate) then
                encontrado = true
                if not isOwner and amigos then
                    for j, amigo in ipairs(amigos) do
                        if amigo.identifier == identifier then
                            result.owner = amigo.identifier
                            break
                        end
                    end
                end
                MySQL.update(
                    "UPDATE owned_vehicles SET calle = 0, vehicle = ?, stored = 1, pound = NULL,  parking = ?, type = ? WHERE  plate = ?",
                    { json.encode(data.vehicleProps), data.garage, data.type, result.plate },
                    function(rowsChanged)
                        if rowsChanged > 0 then
                            if vehiclesSpawned[result.plate] and vehiculoCreado[vehiclesSpawned[result.plate].entity] then
                                vehiculoCreado[vehiclesSpawned[result.plate].entity] = nil
                                vehiclesSpawned[result.plate] = nil
                            end
                            PlayerOutCar({ entity = entity, plate = result.plate, count = 1, player = source })
                        else
                            Noti(source, locale('SERVER_ErrorGuardad'))
                        end
                    end)
            end
        end
        if not encontrado then Noti(source, locale('NoEsTuyo')) end
    end
end)


RegisterServerEvent('mono_garage:TransferVehicle', function(data, action)
    Bug('mono_garage:TransferVehicle ', 'Action = %s', action)

    local xPlayer = ESX.GetPlayerFromIdentifier(data.owner)
    local source = xPlayer.source
    local xTarget = ESX.GetPlayerFromId(data.input[1])
    if xTarget == nil then return Noti(source, 'Id Invalida') end
    data.Seller = xPlayer.getName()
    data.Buyer = xTarget.getName()
    data.plate = string.gsub(data.plate, "^%s*(.-)%s*$", "%1")
    data.CharBuyer = xTarget.identifier
    if action == 'send' then
        if data.input[1] == source then
            Noti(source, locale('noatimismo'))
        else
            Noti(source, 'Solicitud enviada')
            TriggerClientEvent('mono_garage:TransferVehicleClient', xTarget.source, data, action)
        end
    elseif action == 'buy' then
        if data.input[2] > 0 then
            if xTarget.getAccount('bank').money > data.input[2] then
                MySQL.update('UPDATE owned_vehicles SET owner = ? , amigos = ? WHERE owner = ? AND plate = ?', {
                    data.CharBuyer, nil, data.owner, data.plate
                }, function(id)
                    Noti(xTarget.source, locale('VehAdquirido', data.input[2]))
                    xTarget.removeAccountMoney('bank', data.input[2])
                    Noti(source, locale('VehVendido', data.input[2]))
                    xPlayer.setAccountMoney('bank', data.input[2])
                    WebHoook(data, 'buy')
                end)
            else
                Noti(xTarget.source, locale('VehVendidoNoDinero', data.Buyer))
                Noti(source, locale('VehVendidoNoDinero', data.Buyer))
            end
        else
            MySQL.update('UPDATE owned_vehicles SET owner = ? , amigos = ? WHERE owner = ? AND plate = ?', {
                data.CharBuyer, nil, data.owner, data.plate
            }, function(id)
                Noti(xTarget.source, locale('VehTargetTrans', data.Buyer))
                Noti(source, locale('VehSourceTrans', data.Seller))
                WebHoook(data, 'trasnfer')
            end)
        end
    end
end)

RegisterServerEvent('mono_garage:RetirarVehiculo', function(plate, lastparking, pos, hea, model, intocar)
    Bug('mono_garage:RetirarVehiculo',
        'Plate = %s, LastParking = %s, Coords = %s, Heading = %s, Model = %s, InTocar = %s ', plate, lastparking, pos,
        hea, model, intocar)
    local source = source
    plate = string.gsub(plate, "^%s*(.-)%s*$", "%1")
    local xPlayer = ESX.GetPlayerFromId(source)
    MySQL.query("SELECT * FROM owned_vehicles WHERE plate = ?",
        { plate },
        function(result)
            if result and #result > 0 then
                local vehicleProps = json.decode(result[1].vehicle)
                MySQL.update("UPDATE owned_vehicles SET stored = 0, lastparking = ?, calle = ? WHERE plate = ?",
                    { lastparking, xPlayer.identifier, plate, },
                    function(rowsChanged)
                        if rowsChanged > 0 then
                            CrearVehiculo(
                                { model = model, coords = pos, heading = hea, props = vehicleProps, plate = plate },
                                function(vehicle)
                                    PlayerToCar({
                                        player = source,
                                        plate = plate,
                                        entity = vehicle,
                                        impound = false,
                                        intocar = intocar,
                                        model = model
                                    })
                                end)
                        else
                            Noti(source, locale('SERVER_ErrorRetirar'))
                        end
                    end)
            else
                Noti(source, locale('SERVER_ErrorRetirar'))
            end
        end)
end)

RegisterServerEvent('mono_garage:RetirarVehiculoImpound', function(plate, money, price, pos, hea, intocar, society)
    Bug('mono_garage:RetirarVehiculo', 'Plate = %s, Money = %s, Price = %s, Coords = %s, Headiung = %s, InTocar = %s ',
        plate, money, price, pos, hea, intocar)
    local source = source
    local xPlayer = ESX.GetPlayerFromId(source)
    local identifier = xPlayer.identifier
    local bank = xPlayer.getAccount("bank")
    local price = price
    plate = string.gsub(plate, "^%s*(.-)%s*$", "%1")
    local function RetirarVehiculo(dinero)
        MySQL.query("SELECT * FROM owned_vehicles WHERE plate = ?",
            { plate },
            function(result)
                if result and #result > 0 then
                    local vehicleProps = json.decode(result[1].vehicle)
                    local info = result[1].infoimpound and json.decode(result[1].infoimpound) or {}
                    if dinero >= (info.price or price) then
                        local lastparkingResult = MySQL.query.await(
                            "SELECT lastparking FROM owned_vehicles WHERE owner = ? AND plate = ?", { identifier, plate })
                        local lastparking = lastparkingResult[1].lastparking
                        MySQL.update(
                            "UPDATE owned_vehicles SET pound = NULL, infoimpound = NULL, parking = ?, calle = 1  WHERE owner = ? AND plate = ?",
                            { lastparking, identifier, plate },
                            function(rowsChanged)
                                if rowsChanged > 0 then
                                    CrearVehiculo(
                                        {
                                            model = vehicleProps.model,
                                            coords = pos,
                                            heading = hea,
                                            props = vehicleProps,
                                            plate = plate
                                        }, function(vehicle)
                                            PlayerToCar({
                                                player = source,
                                                plate = plate,
                                                entity = vehicle,
                                                impound = true,
                                                intocar = intocar
                                            })
                                        end)
                                    if not society then
                                        xPlayer.removeAccountMoney(money, (info.price or price))
                                    else
                                        TriggerEvent('esx_addonaccount:getSharedAccount', society, function(cuenta)
                                            xPlayer.removeAccountMoney(money, (info.price or price))
                                            cuenta.addMoney((info.price or price))
                                        end)
                                    end
                                    Noti(source, locale('SERVER_RetirarImpound', (info.price or price)))
                                else
                                    Noti(source, locale('SERVER_RetirarImpoundError'))
                                end
                            end)
                    else
                        Noti(source, locale('SERVER_SinDinero'))
                    end
                end
            end)
    end
    if money == 'money' then
        RetirarVehiculo(xPlayer.getMoney())
    elseif money == 'bank' then
        RetirarVehiculo(bank.money)
    end
end)





RegisterServerEvent('mono_garage:ImpoundJoB', function(plate, impound, price, reason, date, vehicle)
    Bug('mono_garage:ImpoundJoB', 'Delete Vehicle Plate = %s, Impound = %s, Price = %s, Reason = %s, Data = %s', plate,
        impound, price, reason, date)
    local entity = NetworkGetEntityFromNetworkId(vehicle)
    local source = source
    local info = { date = date, price = price, reason = reason }
    MySQL.update("UPDATE owned_vehicles SET parking = ?, infoimpound = ?, pound = 1, calle = 0, stored = 0  WHERE  plate = ?",
        { impound, json.encode(info), plate }, function(rowsChanged)
            if rowsChanged > 0 then
                TriggerClientEvent('mono_garage:FadeOut', -1, vehicle)
                Wait(1500)
                DeleteEntity(entity)
                vehiculoCreado[entity] = nil
                Noti(source, locale('impfunc_noti', plate, impound))
            else
                TriggerClientEvent('mono_garage:FadeOut', -1, vehicle)
                Wait(1500)
                DeleteEntity(entity)
            end
        end)
end)

RegisterServerEvent('mono_garage:MandarVehiculoImpound', function(plate, impound)
    Bug('mono_garage:MandarVehiculoImpound ', 'Impound Vehicle Plate = %s, Impound = %s', plate, impound)
    local source = source
    local xPlayer = ESX.GetPlayerFromId(source)
    local identifier = xPlayer.identifier
    plate = string.gsub(plate, "^%s*(.-)%s*$", "%1")

    MySQL.update("UPDATE owned_vehicles SET parking = ?, pound = 1, calle = 0 WHERE owner = ? AND plate = ?",
        { impound, identifier, plate },
        function(rowsChanged)
            if rowsChanged > 0 then
                for k, v in pairs(vehiculoCreado) do
                    if PlateEqual(v, plate) then
                        --    if DoesEntityExist(k) then
                        DeleteEntity(k)
                        --  end
                        vehiculoCreado[k] = nil
                    end
                end
                Noti(source, locale('SERVER_MandarVehiculoImpound'))
            else
                Noti(source, locale('SERVER_MandarMal'))
            end
        end)
end)

-- aqui
RegisterNetEvent('mono_garage:ChangeGarage', function(data)
    local source = source
    local xPlayer = ESX.GetPlayerFromId(source)
    local bank = xPlayer.getAccount("bank")
    data.plate = string.gsub(data.plate, "^%s*(.-)%s*$", "%1")
    if data.priceSend == nil then
        MySQL.update('UPDATE owned_vehicles SET stored = 1, parking = ? WHERE owner = ? and plate = ? ', {
            data.garage, data.owner, data.plate
        }, function(affectedRows)
            if affectedRows > 0 then
                Noti(source, locale('enviado', data.garage))
            else
                Noti(source, locale('SERVER_RetirarImpoundError'))
            end
        end)
    else
        local function RetirarVehiculo(dinero)
            print(dinero, data.money)
            if dinero >= data.priceSend then
                print(2)
                MySQL.update(
                    'UPDATE owned_vehicles SET parking = ?, stored = 1, pound = NULL, infoimpound = NULL    WHERE owner = ? and plate = ? ',
                    {
                        data.garage, data.owner, data.plate
                    }, function(affectedRows)
                        if affectedRows > 0 then
                            print(3)
                            if not data.society then
                                xPlayer.removeAccountMoney(data.money, data.priceSend)
                            else
                                print(4)
                                TriggerEvent('esx_addonaccount:getSharedAccount', data.society, function(cuenta)
                                    print(data.priceSend)
                                    xPlayer.removeAccountMoney(data.money, data.priceSend)
                                    cuenta.addMoney(data.priceSend)
                                end)
                            end
                            Noti(source,
                                locale('SERVER_RetirarImpound', data.priceSend))
                        else
                            Noti(source,
                                locale('SERVER_RetirarImpoundError'))
                        end
                    end)
            else
                Noti(source, locale('SERVER_SinDinero'))
            end
        end
        if data.money == 'money' then
            RetirarVehiculo(xPlayer.getMoney())
        elseif data.money == 'bank' then
            RetirarVehiculo(bank.money)
        end
    end
end)




if Garage.AutoImpound.AutoImpound then
    CreateThread(function()
        while true do
            local vehicles = MySQL.query.await("SELECT * FROM owned_vehicles")
            for i = 1, #vehicles do
                local data = vehicles[i]
                local vehicleFound = false
                for entity, plate in pairs(vehiculoCreado) do
                    if PlateEqual(plate, data.plate) then
                        if DoesEntityExist(entity) then
                            vehicleFound = true
                            Bug('AutoImpound 1', 'Entity = %s, Plate = %s, vehicleFound = %s', entity, plate,
                                vehicleFound)
                        end
                    end
                end
                if not vehicleFound and data.stored == 0 and data.pound == nil and data.calle == 1 and not data.calle == 2 then
                    MySQL.update(
                        "UPDATE owned_vehicles SET parking = ?, pound = 1, calle = 0 WHERE  plate = ?",
                        { Garage.AutoImpound.ImpoundIn, data.plate },
                        function(rowsChanged)
                            if rowsChanged > 0 then
                                Bug('AutoImpound2', 'El vehiculo con la matricula %s fue depositado en %s', data.plate,
                                    Garage.AutoImpound.ImpoundIn)
                            else
                                Bug('AutoImpound2', 'Error')
                            end
                        end)
                end
            end
            Wait(Garage.AutoImpound.TimeCheck)
        end
    end)
end

if Garage.Persistent then
    RegisterNetEvent('esx:playerLoaded', function(player, xPlayer, isNew)
        if xPlayer then
            local results = MySQL.query.await("SELECT * FROM owned_vehicles WHERE owner = ?", { xPlayer.identifier })
            if results[1] ~= nil then
                for i = 1, #results do
                    local result = results[i]
                    local veh = json.decode(result.vehicle)
                    if result.stored == 2 then
                        local pos = json.decode(result.lastposition)
                        if pos ~= nil then
                            local plate = veh.plate
                            local model = veh.model
                            local coords = vector3(pos.x, pos.y, pos.z)
                            local Heading = pos.h
                            CrearVehiculo(
                                {
                                    model = model,
                                    coords = coords,
                                    heading = Heading,
                                    props = veh,
                                    plate = plate,
                                    doors = pos.doors
                                },
                                function(vehicle)
                                    Citizen.SetTimeout(1000, function()
                                        MySQL.update(
                                            'UPDATE owned_vehicles SET stored = ?, lastposition = ?, calle = ? WHERE plate = ?',
                                            { 0, nil, xPlayer.identifier, plate, })
                                        vehiclesSpawned[plate] = { entity = vehicle }
                                        while DoesEntityExist(vehicle) do
                                            Bug('Car Spawn Persistent', 'Vehicle = %s ', vehicle)
                                            Wait(0)
                                        end

                                        SetVehicleDoorsLocked(vehicle, pos.doors)
                                    end)
                                end)
                        end
                    end
                end
            end
        end
    end)



    RegisterNetEvent('esx:playerDropped', function(source)
        local xPlayer = ESX.GetPlayerFromId(source)
        local vehicles = MySQL.query.await("SELECT * FROM owned_vehicles WHERE owner = ?", { xPlayer.identifier })
        for i = 1, #vehicles do
            local data = vehicles[i]
            if data.owner == xPlayer.identifier then
                local plate = data.plate
                if data.stored == 0 and vehiclesSpawned[plate] and DoesEntityExist(vehiclesSpawned[plate].entity) then
                    local Pos = GetEntityCoords(vehiclesSpawned[plate].entity)
                    local Heading = GetEntityHeading(vehiclesSpawned[plate].entity)
                    local Doors = GetVehicleDoorLockStatus(vehiclesSpawned[plate].entity)
                    local posTable = { x = Pos.x, y = Pos.y, z = Pos.z, h = Heading, doors = Doors }
                    MySQL.update('UPDATE owned_vehicles SET lastposition = ?, stored = 2 WHERE plate = ?',
                        { json.encode(posTable), plate }, function()
                            DeleteEntity(vehiclesSpawned[plate].entity)
                            if vehiclesSpawned[plate] and vehiculoCreado[vehiclesSpawned[plate].entity] then
                                vehiculoCreado[vehiclesSpawned[plate].entity] = nil
                                vehiclesSpawned[plate] = nil
                            end
                            Bug('Vehicle Save persistent', 'Plate = %s, Position = %s, Doors =%s', plate,
                                Pos, Doors)
                        end)
                end
            end
        end
    end)

    --[[RegisterCommand('in', function(source)
        local xPlayer = ESX.GetPlayerFromId(source)
        local results = MySQL.query.await("SELECT * FROM owned_vehicles")
        if results[1] ~= nil then
            for i = 1, #results do
                local result = results[i]
                local veh = json.decode(result.vehicle)
                if result.owner == xPlayer.identifier and result.calle == xPlayer.identifier then
                    if result.stored == 2 then
                        local pos = json.decode(result.lastposition)
                        if pos ~= nil then
                            local plate = veh.plate
                            local model = veh.model
                            local coords = vector3(pos.x, pos.y, pos.z)
                            local Heading = pos.h
                            CrearVehiculo(
                                { model = model, coords = coords, heading = Heading, props = veh, plate = plate },
                                function(vehicle)
                                    Citizen.SetTimeout(1000, function()
                                        SetVehicleDoorsLocked(vehicle, pos.doors)
                                        MySQL.update(
                                            'UPDATE owned_vehicles SET stored = ?, lastposition = ?  WHERE plate = ?',
                                            { 0, nil, plate, })
                                        vehiclesSpawned[plate] = { entity = vehicle }
                                        if DoesEntityExist(vehicle) then
                                            Bug('Car Spawn Persistent', 'Vehicle = %s ', vehicle)
                                        end
                                    end)
                                end)
                        end
                    end
                end
            end
        end
    end)

    RegisterCommand('out', function(source)
        local xPlayer = ESX.GetPlayerFromId(source)
        local vehicles = MySQL.query.await("SELECT * FROM owned_vehicles WHERE owner = ?", { xPlayer.identifier })
        for i = 1, #vehicles do
            local data = vehicles[i]
            if data.owner == xPlayer.identifier then
                local plate = data.plate

                if data.stored == 0 and vehiclesSpawned[plate] and DoesEntityExist(vehiclesSpawned[plate].entity) then
                    local pos = GetEntityCoords(vehiclesSpawned[plate].entity)
                    local hea = GetEntityHeading(vehiclesSpawned[plate].entity)
                    local doors = GetVehicleDoorLockStatus(vehiclesSpawned[plate].entity)
                    local posTable = { x = pos.x, y = pos.y, z = pos.z, h = hea, doors = doors }
                    local posStr = json.encode(posTable)
                    local props = json.decode(data.vehicle)
                    props.fuelLevel = Entity(vehiclesSpawned[plate].entity).state.fuel
                    local propsNew = json.encode(props)
                    MySQL.update('UPDATE owned_vehicles SET lastposition = ?, vehicle = ?, stored = 2 WHERE plate = ?',
                        { posStr, propsNew, plate }, function()
                            DeleteEntity(vehiclesSpawned[plate].entity)
                            vehiclesSpawned[plate] = nil
                            Bug('Vehicle Save persistent', 'Plate = %s, Position = %s, Doors =%s', plate, pos, doors)
                        end)
                end
            end
        end
    end)]]
end





lib.addCommand(Garage.Commands.givecar, {
    help = locale('setearcar2'),
    restricted = Garage.Commands.Group,
    params = {
        {
            name = 'target',
            type = 'playerId',
            help = 'Target player\'s server id',
        },
        {
            name = 'model',
            type = 'string',
            help = 'Vehicle Model. (sultan,t20,burrito)',
        },
        {
            name = 'garage',
            type = 'string',
            help = 'Garage name to set (Default ' .. Garage.Commands.defaultGarage .. ')',
            optional = true,
        },
    },
}, function(source, args)
    local plate = GeneratePlate()
    local parking = tostring((args.garage and args.garage:gsub("_", " ")) or
        (Garage and Garage.Commands and Garage.Commands.defaultGarage))
    local xPlayer = ESX.GetPlayerFromId(args.target)
    local Ped = GetPlayerPed(args.target)
    local inCar = GetVehiclePedIsIn(Ped, false)
    local coords = GetEntityCoords(Ped)
    local heading = GetEntityHeading(Ped)
    local results = MySQL.query.await("SELECT * FROM owned_vehicles WHERE plate = ?", { plate })
    local Properties = { plate = plate, fuelLevel = 100, model = args.model }
    if results[1] ~= nil then
        Noti(source, locale('setcardb_enpropiedad', plate))
    else
        if inCar <= 0 then
            local props = json.encode(Properties)
            CrearVehiculo({ model = args.model, coords = coords, heading = heading, props = props, plate = plate },
                function(vehicle)
                    PlayerToCar({ player = args.target, plate = plate, entity = vehicle, intocar = true, impound = true })

                    MySQL.update.await("INSERT INTO owned_vehicles (owner, plate, vehicle,parking) VALUES (?, ?, ?, ?)",
                        { xPlayer.identifier, plate, props, parking })
                    Noti(args.target, locale('setcardb_agregado', plate))
                end)
        else
            Noti(args.target, locale('Comando_2'))
        end
    end
end)
-- Command /spawncar
lib.addCommand(Garage.Commands.spawncar, {
    help = locale('setearcar2'),
    restricted = Garage.Commands.Group,
    params = {
        {
            name = 'target',
            type = 'playerId',
            help = 'Target player\'s server id',
        },
        {
            name = 'model',
            type = 'string',
            help = 'Vehicle Model. (sultan, t20, burrito, manchez)',
        },
        {
            name = 'time',
            type = 'number',
            help = 'Time to delete vehicle, 1 = 1 min',
            optional = true,
        },
    },
}, function(source, args)
    local plate = GeneratePlate()
    local Ped = GetPlayerPed(args.target)
    local inCar = GetVehiclePedIsIn(Ped, false)
end)
-- Command /spawncar
lib.addCommand(Garage.Commands.spawncar, {
    help = locale('setearcar2'),
    restricted = Garage.Commands.Group,
    params = {
        {
            name = 'target',
            type = 'playerId',
            help = 'Target player\'s server id',
        },
        {
            name = 'model',
            type = 'string',
            help = 'Vehicle Model. (sultan,t20,burrito)',
        },
        {
            name = 'time',
            type = 'number',
            help = 'Time to delete vehicle, 1 = 1 min',
            optional = true,
        },
    },
}, function(source, args)
    local plate = GeneratePlate()
    local Ped = GetPlayerPed(args.target)
    local inCar = GetVehiclePedIsIn(Ped, false)

    if inCar <= 0 then
        CrearVehiculo(
            {
                model = args.model,
                coords = GetEntityCoords(GetPlayerPed(args.target)),
                heading = GetEntityHeading(GetPlayerPed(args.target)),
                props = false,
                plate = plate
            }, function(vehicle)
                if args.time then
                    local time = args.time * 1000 * 60
                    Noti(args.target, locale('Comando_1', args.time))
                    PlayerToCar({ player = args.target, plate = plate, entity = vehicle, intocar = true, impound = true })

                    Citizen.SetTimeout(args.time * 1000 * 60, function()
                        if DoesEntityExist(vehicle) then
                            Noti(args.target, locale('Comando_2'))
                            PlayerOutCar({ entity = vehicle, plate = plate, player = args.target })
                        end
                    end)
                else
                    if DoesEntityExist(vehicle) then
                        PlayerToCar({
                            player = args.target,
                            plate = plate,
                            entity = vehicle,
                            intocar = true,
                            impound = true
                        })
                    end
                end
            end)
    else
        Noti(args.target, locale('Comando_3'))
    end
end)
