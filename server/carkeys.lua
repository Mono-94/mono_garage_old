if Garage.Mono_Carkeys then
    lib.locale()


    local ox_inventory = exports.ox_inventory

    RegisterServerEvent('mono_carkeys:DeleteKey', function(count, plate)
        ox_inventory:RemoveItem(source, Keys.ItemName, count, { plate = plate, description = locale('key_description', plate) })
    end)

    RegisterServerEvent('mono_carkeys:CreateKey', function(plate)
        ox_inventory:AddItem(source, Keys.ItemName, 1, { plate = plate, description = locale('key_description', plate) })
    end)

    
    RegisterServerEvent('mono_carkeys:BuyKeys', function(plate, precio)
        local source = source
        local xPlayer = ESX.GetPlayerFromId(source)
        if ox_inventory:CanCarryItem(source, Keys.ItemName, 1) then
            if xPlayer.getMoney() >= precio then
                exports.ox_inventory:RemoveItem(source, 'money', precio)
                ox_inventory:AddItem(source, Keys.ItemName, 1,
                    { plate = plate, description = locale('key_description', plate) })
                TriggerClientEvent('mono_carkeys:Notification', source, locale('title'), locale('llavecomprada', precio),
                    'key', '#fffff  ')
            else
                TriggerClientEvent('mono_carkeys:Notification', source, locale('title'), locale('NoDinero'), 'ban',
                    '#fffff')
            end
        end
    end)

    lib.callback.register('mono_carkeys:getVehicles', function(source)
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
                                            local count = exports.ox_inventory:GetItem(source, Keys.ItemName,
                                                { plate = oldPlate, description = locale('key_description', oldPlate) },
                                                true)

                                            exports.ox_inventory:RemoveItem(source, Keys.ItemName, count,
                                                { plate = oldPlate, description = locale('key_description', oldPlate) })

                                            ox_inventory:AddItem(source, Keys.ItemName, count,
                                                { plate = newPlate, description = locale('key_description', newPlate) })

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
                name = 'ID',
                help = locale('helpgivekey'),
                optional = true,
            },
        },
        restricted = 'group.admin'
    }, function(source, args)
        local id = args.ID or source
        if args.ID ~= nil then
            TriggerClientEvent('mono_carkeys:AddKeysCars', id)
        else
            TriggerClientEvent('mono_carkeys:Notification', source, locale('title'), 'debes poner una ID', 'error')
        end
    end)


    lib.addCommand(Keys.CommandDelKey, {
        help = locale('givekey'),
        params = {
            {
                name = 'id',
                help = locale('helpgivekey'),
                optional = true,
            },
            {
                name = 'count',
                help = locale('helpgivekeycount'),
                optional = true,
            },

        },
        restricted = 'group.admin'
    }, function(source, args)
        local id = args.ID or source
        TriggerClientEvent('mono_carkeys:DeleteClientKey', id, args.count)
    end)


    RegisterNetEvent('mono_carkeys:ServerDoors', function(id)
        local source = source

        local vehicle = NetworkGetEntityFromNetworkId(id)

        local status = GetVehicleDoorLockStatus(vehicle)
        if status == 2 then
            SetVehicleDoorsLocked(vehicle, 0)
            TriggerClientEvent('mono_carkeys:Notification', source, locale('title'), locale('unlock_veh'), 'lock-open',
                '#32a852')
        elseif status == 0 or 1 then
            SetVehicleDoorsLocked(vehicle, 2)
            TriggerClientEvent('mono_carkeys:Notification', source, locale('title'), locale('lock_veh'), 'lock',
                '#a83254')
        end
        TriggerClientEvent('mono_carkeys:LucesLocas', source, id, status ~= 2)
    end)
end





