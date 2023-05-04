if Keys.Keys then
    lib.locale()


    local ox_inventory = exports.ox_inventory




   RegisterServerEvent('sy_carkeys:DeleteKey', function(count, plate, model)
       local formattedPlate = string.gsub(plate, "^%s*(.-)%s*$", "%1")
        exports.ox_inventory:RemoveItem(source, 'carkeys', count,
            { plate = formattedPlate, description = locale('key_description', formattedPlate, model) })
    end)






    RegisterServerEvent('sy_carkeys:CreateKey', function(plate, model)
        if ox_inventory:CanCarryItem(source, Keys.ItemName, 1) then
            ox_inventory:AddItem(source, Keys.ItemName, 1,
                { plate = plate, description = locale('key_description', plate, model) })
        end
    end)


    RegisterServerEvent('sy_carkeys:BuyKeys', function(plate, model)
        local xPlayer = ESX.GetPlayerFromId(source)
        if ox_inventory:CanCarryItem(source, Keys.ItemName, 1) then
            if xPlayer.getMoney() >= Keys.CopyPrice then
                exports.ox_inventory:RemoveItem(source, 'money', Keys.CopyPrice)
                ox_inventory:AddItem(source, Keys.ItemName, 1,
                    { plate = plate, description = locale('key_description', plate, model) })
                TriggerClientEvent('sy_carkeys:Notification', xPlayer.source, locale('title'),
                    locale('llavecomprada', model, Keys.CopyPrice), 'success')
            else
                TriggerClientEvent('sy_carkeys:Notification', xPlayer.source, locale('title'), locale('NoDinero'),
                    'error')
            end
        end
    end)

    lib.callback.register('sy_carkeys:getVehicles', function(source)
        local xPlayer = ESX.GetPlayerFromId(source)
        local identifier = xPlayer.getIdentifier()
        local vehicles = {}

        local results = MySQL.Sync.fetchAll("SELECT * FROM `owned_vehicles` WHERE `owner` = @identifier", {
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




    RegisterServerEvent('sy_carkeys:SetMatriculaServer')
    AddEventHandler('sy_carkeys:SetMatriculaServer', function(oldPlate, newPlate, newColor)
        local xPlayer = ESX.GetPlayerFromId(source)
        local identifier = xPlayer.getIdentifier()

        local result = MySQL.Sync.fetchAll(
            "SELECT * FROM `owned_vehicles` WHERE `owner` = @identifier AND `plate` = @oldPlate", {
                ['@identifier'] = identifier,
                ['@oldPlate'] = oldPlate
            })

        if result[1] ~= nil then
            local decodedVehicle = json.decode(result[1].vehicle)
            decodedVehicle.plate = newPlate .. string.rep(' ', 8 - #newPlate)
            local newVehicle = json.encode(decodedVehicle)
            exports.ox_inventory:RemoveItem(xPlayer.source, Keys.ItemPlate, 1)
            MySQL.Async.execute(
                'UPDATE `owned_vehicles` SET `plate` = @newPlate, `vehicle` = @newVehicle WHERE `owner` = @identifier AND `plate` = @oldPlate',
                {
                    ['@identifier'] = identifier,
                    ['@oldPlate'] = oldPlate,
                    ['@newPlate'] = decodedVehicle.plate,
                    ['@newVehicle'] = newVehicle
                }, function(rowsChanged)
                    if rowsChanged > 0 then
                        TriggerClientEvent('sy_carkeys:SetMatricula', xPlayer.source, decodedVehicle.plate, newColor)
                        TriggerClientEvent('sy_carkeys:Notification', xPlayer.source,
                            locale('MatriculaActualizada', oldPlate, decodedVehicle.plate))
                    else
                        TriggerClientEvent('sy_carkeys:Notification', xPlayer.source, locale('ErrorActualizar'))
                    end
                end)
        else
            TriggerClientEvent('sy_carkeys:Notification', xPlayer.source, locale('NoTienesMatricula'))
        end
    end)








    if Keys.CloseDoorsNPC then
        AddEventHandler('entityCreated', function(entity)
            if not DoesEntityExist(entity) then
                return
            end
            local entityType = GetEntityType(entity)
            if entityType ~= 2 then
                return
            end
            if GetEntityPopulationType(entity) > 5 then
                return
            end
            if Keys.DoorProbability then
                if math.random() > Keys.OpenDoorProbability then
                    return
                end
            end

            SetVehicleDoorsLocked(entity, 2)
        end)
    end

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
        TriggerClientEvent('sy_carkeys:AddKeysCars', id)
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
        TriggerClientEvent('sy_carkeys:DeleteClientKey', id, args.count)
    end)

    RegisterServerEvent('sy_carkeys:ComprarMatricula', function()
        local xPlayer = ESX.GetPlayerFromId(source)
        if ox_inventory:CanCarryItem(source, Keys.ItemPlate, 1) then
            if xPlayer.getMoney() >= Keys.PriceItemPlate then
                exports.ox_inventory:RemoveItem(source, 'money', Keys.PriceItemPlate)
                ox_inventory:AddItem(source, Keys.ItemPlate, 1)
                TriggerClientEvent('sy_carkeys:Notification', xPlayer.source, locale('title'),
                    locale('MatriculaComprada') 'success')
            else
                TriggerClientEvent('sy_carkeys:Notification', xPlayer.source, locale('title'), locale('NoDinero'),
                    'error')
            end
        end
    end)


    -- SYNC

    RegisterNetEvent('sy_carkeys:ServerDoors', function(id, status)
        local vehicle = NetworkGetEntityFromNetworkId(id)
        local xPlayer = ESX.GetPlayerFromId(source)
        print('Carkey = ' .. 'Vehicle Newwork: ' .. vehicle .. ' Door:' .. status)
        SetVehicleDoorsLocked(vehicle, status == 2 and 0 or 2)
        TriggerClientEvent('sy_carkeys:LucesLocas', xPlayer.source, id, status ~= 2)
    end)
end
