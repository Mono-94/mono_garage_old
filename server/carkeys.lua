if Garage.Mono_Carkeys then
    lib.locale()


    local ox_inventory = exports.ox_inventory




    RegisterServerEvent('mono_carkeys:DeleteKey', function(count, plate)
        local source = source
        local platedelentejas = string.len(plate)
        if platedelentejas < 8 then
            while platedelentejas < 8 do
                plate = plate .. " "
                platedelentejas = platedelentejas + 1
            end
        end
        exports.ox_inventory:RemoveItem(source, 'carkeys', count,
            { plate = plate, description = locale('key_description', plate) })
    end)





    RegisterServerEvent('mono_carkeys:CreateKey', function(plate)
        local source = source
        local platedelentejas = string.len(plate)
        if platedelentejas < 8 then
            while platedelentejas < 8 do
                plate = plate .. " "
                platedelentejas = platedelentejas + 1
            end
        end
        if ox_inventory:CanCarryItem(source, Keys.ItemName, 1) then
            ox_inventory:AddItem(source, Keys.ItemName, 1,
                { plate = plate, description = locale('key_description', plate) })
        end
    end)


    RegisterServerEvent('mono_carkeys:BuyKeys', function(plate, precio)
        local source = source
        local xPlayer = ESX.GetPlayerFromId(source)
        local platedelentejas = string.len(plate)
        if platedelentejas < 8 then
            while platedelentejas < 8 do
                plate = plate .. " "
                platedelentejas = platedelentejas + 1
            end
        end
        if ox_inventory:CanCarryItem(source, Keys.ItemName, 1) then
            if xPlayer.getMoney() >= precio then
                exports.ox_inventory:RemoveItem(source, 'money', precio)
                ox_inventory:AddItem(source, Keys.ItemName, 1,
                    { plate = plate, description = locale('key_description', plate) })
                TriggerClientEvent('mono_carkeys:Notification', source, locale('title'), locale('llavecomprada', precio),
                    'key', '#fffff')
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



    lib.callback.register('mono_carkeys:FindPlate', function()
        local results = MySQL.Sync.fetchAll("SELECT * FROM owned_vehicles WHERE plate ")
        return results
    end)




    RegisterServerEvent('mono_carkeys:SetMatriculaServer')
    AddEventHandler('mono_carkeys:SetMatriculaServer', function(oldPlate, newPlate, newColor)
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
                        TriggerClientEvent('mono_carkeys:SetMatricula', xPlayer.source, decodedVehicle.plate, newColor)
                        TriggerClientEvent('mono_carkeys:Notification', xPlayer.source,
                            locale('MatriculaActualizada', oldPlate, decodedVehicle.plate))
                    else
                        TriggerClientEvent('mono_carkeys:Notification', xPlayer.source, locale('ErrorActualizar'))
                    end
                end)
        else
            TriggerClientEvent('mono_carkeys:Notification', xPlayer.source, locale('NoTienesMatricula'))
        end
    end)







    if Keys.EntityVehicleSpawn.CloseDoorEmptyCar then
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

            local plate = GetVehicleNumberPlateText(entity)

            local motor = GetIsVehicleEngineRunning(entity)

            if motor then
                if Keys.Debug then
                    print('Vehiculo encendido ', plate)
                end
            end
            if not motor then
                if Keys.Debug then
                    print('Vehiculo apagado ', plate .. ', Puertas cerradas.')
                end
                if Keys.EntityVehicleSpawn.DoorProbability then
                    if math.random() > Keys.EntityVehicleSpawn.OpenDoorProbability then
                        return
                    end
                end
                SetVehicleDoorsLocked(entity, 2)
            end
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

    RegisterServerEvent('mono_carkeys:ComprarMatricula', function()
        local xPlayer = ESX.GetPlayerFromId(source)
        if ox_inventory:CanCarryItem(source, Keys.ItemPlate, 1) then
            if xPlayer.getMoney() >= Keys.PriceItemPlate then
                exports.ox_inventory:RemoveItem(source, 'money', Keys.PriceItemPlate)
                ox_inventory:AddItem(source, Keys.ItemPlate, 1)
                TriggerClientEvent('mono_carkeys:Notification', xPlayer.source, locale('title'),
                    locale('MatriculaComprada') 'success')
            else
                TriggerClientEvent('mono_carkeys:Notification', xPlayer.source, locale('title'), locale('NoDinero'),
                    'error')
            end
        end
    end)


    -- SYNC

    RegisterNetEvent('mono_carkeys:ServerDoors', function(id)
        local source = source

        local vehicle = NetworkGetEntityFromNetworkId(id)

        local status = GetVehicleDoorLockStatus(vehicle)

        if Keys.Debug then
            print('Carkey = ' .. 'Vehicle Newwork: ' .. vehicle .. ' Door:' .. status)
        end
        if status == 2 then
            SetVehicleDoorsLocked(vehicle, 0)
            TriggerClientEvent('mono_carkeys:Notification', source, locale('title'), locale('unlock_veh'), 'lock-open',
                '#32a852')
        elseif status == 0 then
            SetVehicleDoorsLocked(vehicle, 2)
            TriggerClientEvent('mono_carkeys:Notification', source, locale('title'), locale('lock_veh'), 'lock',
                '#a83254')
        end
        TriggerClientEvent('mono_carkeys:LucesLocas', source, id, status ~= 2)
    end)
end
