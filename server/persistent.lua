local vehiclesSpawned, vehiculos = {}, {}


function Crearvehiculo(model, coordinates, heading, props, source, puertas)
    local entity = CreateVehicleServerSetter(model, "automobile", coordinates.x, coordinates.y, coordinates.z, heading)

    Wait(100)

    while not DoesEntityExist(entity) do
        Wait(0)
    end

    local network = NetworkGetNetworkIdFromEntity(entity)
    Wait(200)

    local netid = NetworkGetEntityFromNetworkId(network)

    if Garage.Persistent.debug then
        print(("VEH: %s, NET: %s,NID: %s"):format(entity, network, netid))
    end



    vehiculos[network] = source

    Wait(200)

    local state = Entity(netid)

    if vehiculos[network] == source then
        state.state.Mods = props
    end

    Wait(200)
    
    SetVehicleDoorsLocked(entity, puertas)
end

if Garage.Persistent.persitenent then
    RegisterNetEvent('esx:playerLoaded', function(player, xPlayer, isNew, cb)
        if xPlayer then
            local results = MySQL.Sync.fetchAll("SELECT * FROM owned_vehicles WHERE owner = @identifier", {
                ['@identifier'] = xPlayer.getIdentifier()
            })
            if results[1] ~= nil then
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
                            if result.calle == 1 then
                                Crearvehiculo(model, coords, Heading, veh, player, pos.doors, false)
                                MySQL.Async.execute(
                                    'UPDATE owned_vehicles SET stored = @stored WHERE plate = @plate',
                                    {
                                        ['@plate'] = plate,
                                        ['@stored'] = 0,
                                    })
                                if Garage.Persistent.debug then
                                    print('\027[1mVEHICLE SPAWN \027[0m ( Player Connect  ' ..
                                        xPlayer.getName() ..
                                        ' "\027[33m' ..
                                        plate ..
                                        '"\027[0m - \027[36mVector3(' ..
                                        coords .. ') Doors: \027[0m' .. pos.doors .. ', ( 0 = open / 2 close))')
                                end
                                vehiclesSpawned[plate] = true
                            end
                        end
                    end
                end
            end
        end
    end)

    RegisterNetEvent('esx:playerDropped', function(playerId)
        local xPlayer = ESX.GetPlayerFromId(playerId)
        local allVehicles = GetAllVehicles()
        local vehicles = MySQL.Sync.fetchAll("SELECT * FROM owned_vehicles")
        for i = 1, #allVehicles do
            local vehEntity = allVehicles[i]
            local plate = GetVehicleNumberPlateText(vehEntity)
            if DoesEntityExist(vehEntity) then
                for i = 1, #vehicles do
                    local data = vehicles[i]
                    if data.owner == xPlayer.getIdentifier() then
                        if data.calle == 1 and data.plate == plate then
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
                                'UPDATE owned_vehicles SET lastposition = @lastposition, stored = @stored WHERE plate = @plate',
                                {
                                    ['@lastposition'] = posStr,
                                    ['@plate'] = plate,
                                    ['@stored'] = 1,
                                }, function(rowsChanged)
                                    vehiclesSpawned[plate] = false
                                    if Garage.Persistent.debug then
                                        print('\027[1mSAVE VEHICLE\027[0m ( "\027[33m' ..
                                            plate ..
                                            '"\027[0m - \027[36mvector4(' ..
                                            position.x ..
                                            ',' ..
                                            position.y ..
                                            ',' ..
                                            position.z ..
                                            ',' ..
                                            heading ..
                                            ' )\027[0m Doors: ' ..
                                            doorLockStatus ..
                                            ', ( 0 = Open / 2 Close))\027- [1mVEHICLE DELETED\027[0m ( "\027[33m' ..
                                            plate .. '"\027[0m )')
                                    end
                                    DeleteEntity(vehEntity)
                                end)
                        end
                    end
                end
            end
        end
    end)
end
