if Garage.Mono_Carkeys then
    lib.locale()


    local ox_inventory = exports.ox_inventory

    RegisterServerEvent('mono_carkeys:BuyKeys', function(plate, precio)
        local source = source
        local xPlayer = ESX.GetPlayerFromId(source)
        if ox_inventory:CanCarryItem(source, Keys.ItemName, 1) then
            if xPlayer.getMoney() >= precio then
                exports.ox_inventory:RemoveItem(source, 'money', precio)
                ServerInventoryKeys({player = source, plate = plate}, 'add')
                TriggerClientEvent('mono_carkeys:Notification', source, locale('title'), locale('llavecomprada', precio),
                    'key', '#fffff  ')
            else
                TriggerClientEvent('mono_carkeys:Notification', source, locale('title'), locale('NoDinero'), 'ban',
                    '#fffff')
            end
        end
    end)

    lib.callback.register('mono_carkeys:getVehicles', function(source, data)
        local xPlayer = ESX.GetPlayerFromId(source)
        local identifier = xPlayer.getIdentifier()
        local vehicles = {}

        local results = MySQL.Sync.fetchAll("SELECT * FROM owned_vehicles WHERE owner = @identifier", {
            ['@identifier'] = identifier,
        })

        if results[1] ~= nil then
            for i = 1, #results do
                local result = results[i]
                local veh = json.decode(result.vehicle)
                vehicles[#vehicles + 1] = { plate = result.plate, vehicle = veh }
            end
            return vehicles
        end
    end)



    lib.callback.register('mono_carkeys:FindPlate', function()
        local results = MySQL.Sync.fetchAll("SELECT * FROM owned_vehicles WHERE plate ")
        return results
    end)


    RegisterServerEvent('mono_carkeys:SetMatriculaServer', function(oldPlate, newPlate, entity, color)
        local source = source
        local xPlayer = ESX.GetPlayerFromId(source)
        local identifier = xPlayer.identifier

        MySQL.query("SELECT * FROM owned_vehicles WHERE owner = ? AND plate = ?", { identifier, newPlate },
            function(result)
                if result[1] ~= nil then
                    print("No se puede cambiar la matrícula porque ya existe")
                else
                    MySQL.query("SELECT * FROM owned_vehicles WHERE owner = ? AND plate = ?", { identifier, oldPlate },
                        function(result)
                            if result[1] ~= nil then
                                local decodedVehicle = json.decode(result[1].vehicle)
                                decodedVehicle.plate = newPlate
                                local newVehicle = json.encode(decodedVehicle)

                                MySQL.Async.execute(
                                    'UPDATE owned_vehicles SET plate = @newPlate, vehicle = @newVehicle WHERE owner = @identifier AND plate = @oldPlate',
                                    {
                                        ['@identifier'] = identifier,
                                        ['@oldPlate'] = oldPlate,
                                        ['@newPlate'] = newPlate,
                                        ['@newVehicle'] = newVehicle
                                    }, function(rowsChanged)
                                        if rowsChanged > 0 then
                                            ServerInventoryKeys({ player = source, plate = oldPlate }, 'remove')
                                            ServerInventoryKeys({ player = source, plate = newPlate }, 'add')
                                            ox_inventory:RemoveItem(source, Keys.ItemPlate, 1)
                                            TriggerClientEvent('mono_carkeys:SetVehiclePlate', source, entity, newPlate,
                                                color)
                                            TriggerClientEvent('mono_carkeys:Notification', source,
                                                locale('MatriculaActualizada', oldPlate, newPlate))
                                        else
                                            TriggerClientEvent('mono_carkeys:Notification', source,
                                                locale('ErrorActualizar'))
                                        end
                                    end)
                            else
                                TriggerClientEvent('mono_carkeys:Notification', source, locale('NoTienesMatricula'))
                            end
                        end)
                end
            end)
    end)


    --Commands

    lib.addCommand(Keys.CommandGiveKey, {
        help = locale('givekey'),
        params = {
            {
                name = 'target',
                help = locale('helpgivekey'),
                type = 'number',
                optional = true,
            },
        },
        restricted = 'group.admin'
    }, function(source, args)
        local id = args.target or source
        local Ped = GetPlayerPed(id)
        local inCar = GetVehiclePedIsIn(Ped, false)
        local plate = GetVehicleNumberPlateText(inCar)
        if plate == nil then
            TriggerClientEvent('mono_carkeys:Notification', source, locale('title'), 'El jugador no esta en un vehículo', 'error')
        else
            ServerInventoryKeys({ player = id, plate = plate }, 'add')
        end
    end)


    RegisterNetEvent('mono_carkeys:ServerDoors', function(id)
        local source = source

        local vehicle = NetworkGetEntityFromNetworkId(id)

        local status = GetVehicleDoorLockStatus(vehicle)
        if status == 2 then
            SetVehicleDoorsLocked(vehicle, 0)
            if not Keys.Progress then
                TriggerClientEvent('mono_carkeys:Notification', source, locale('title'), locale('unlock_veh'),
                    'lock-open',
                    '#32a852')
            end
        elseif status == 0 or 1 then
            SetVehicleDoorsLocked(vehicle, 2)
            if not Keys.Progress then
                TriggerClientEvent('mono_carkeys:Notification', source, locale('title'), locale('lock_veh'), 'lock',
                    '#a83254')
            end
        end

        TriggerClientEvent('mono_carkeys:SetSoundsAndLights', -1, id, status)
    end)

end
