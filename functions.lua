Sy = {}






















-- NO EDIT





















Sy.GetProps = function()
    local props = lib.getVehicleProperties(GetVehiclePedIsIn(cache.ped, false))
    return props
end
Sy.CarCloset = function(args)
    local dist = args.dist
    local pedcar = args.pedcar
    local ped = cache.ped
    local pedcoords = GetEntityCoords(ped)
    local car = lib.getClosestVehicle(vec3(pedcoords.x, pedcoords.y, pedcoords.z), dist, pedcar)
    return car
end
Sy.GetCar = function(args)
    local Name = args.name
    local InCar = args.car
    if Name then
        local vehicle = GetVehiclePedIsIn(cache.ped, false)
        local model = GetEntityModel(vehicle)
        local name = GetDisplayNameFromVehicleModel(model)
        return name
    end
    if InCar then
        local vehicle = GetVehiclePedIsIn(cache.ped, false)
        return vehicle
    end
end
Sy.GetPlayerKey = function()
    local ped = cache.ped
    local playerCoords = GetEntityCoords(ped)
    local closet = lib.getClosestVehicle(playerCoords, Keys.Distance, true)
    local plate = string.gsub(GetVehicleNumberPlateText(closet), " ", "")
    local keys = exports.ox_inventory:Search('slots', Keys.ItemName)
    for i, v in ipairs(keys) do
        if string.gsub(v.metadata.plate, " ", "") == plate then
            return v
        end
    end
    return nil
end
Sy.GetEnginStat = function()
    local ped = cache.ped
    local vehicle = GetVehiclePedIsIn(ped, false)
    local state = GetVehicleEngineHealth(vehicle) > 0 and GetIsVehicleEngineRunning(vehicle)
    return state
end
Sy.GetClase = function()
    local ped = PlayerPedId()
    local vehicle = GetVehiclePedIsUsing(ped)
    local clase = GetVehicleClass(vehicle)
    return clase
end


CreateThread(function()
    if Garage.RadialCopyCoords then
        lib.addRadialItem({
            {
                id = 'Cordenadas',
                label = 'Coords',
                icon = 'location-dot',
                menu = 'copy_coords'
            },

        })
        lib.registerRadial({
            id = 'copy_coords',
            items = {

                {
                    label = '{x= 0,y= 0,z= 0,w= 0}',
                    onSelect = function()
                        local ped = cache.ped
                        local coords = GetEntityCoords(ped)
                        local heading = GetEntityHeading(ped)
                        lib.setClipboard('{ x = ' .. coords.x .. ', y = ' .. coords.y .. ', z = ' ..
                            coords.z .. ', h = ' .. heading .. '},')
                    end
                },
                {
                    label = 'vector3(0,0,0)',
                    onSelect = function()
                        local ped = cache.ped
                        local coords = GetEntityCoords(ped)
                        lib.setClipboard('vec3(' .. coords.x .. ',' .. coords.y .. ',' .. coords.z .. ')')
                    end
                },
                {
                    label = 'vector4(0,0,0)',
                    onSelect = function()
                        local ped = cache.ped
                        local coords = GetEntityCoords(ped)
                        local heading = GetEntityHeading(ped)
                        lib.setClipboard('vector4(' .. coords.x .. ', ' .. coords.y .. ',' ..
                            coords.z .. ',' .. heading .. '),')
                    end
                },
                {
                    label = 'HEADING',
                    onSelect = function()
                        local ped = cache.ped
                        lib.setClipboard(GetEntityHeading(ped))
                    end
                },
            }
        })
    end
end)







-- FUNCION ANTIGUA
RegisterNetEvent('sy_garage:CheckVeh')
AddEventHandler('sy_garage:CheckVeh', function(vehicle)
    if cache.vehicle then
        TriggerEvent("sy_garage:CheckVeh2")
    else
        TriggerEvent('sy_garage:Notification', locale('dentrocar'))
    end
end)

RegisterNetEvent('sy_garage:CheckVeh2')
AddEventHandler('sy_garage:CheckVeh2', function(vehicle)
    local playerVehicle = GetVehiclePedIsIn(PlayerPedId(), false)
    local vehicleProps = ESX.Game.GetVehicleProperties(playerVehicle)
    local model = GetEntityModel(playerVehicle)
    local name = GetDisplayNameFromVehicleModel(model)

    ESX.TriggerServerCallback('sy_garage:SetCarDB', function(successRegister, plate)
        if successRegister then
            Wait(1000)
            TriggerEvent('sy_garage:Notification', locale('setearcar', name, plate))
            local plate = GetVehicleNumberPlateText(playerVehicle)
            SetVehicleNumberPlateText(playerVehicle, plate)
            TriggerServerEvent('sy_carkeys:CreateKey', plate, name)
        else
            TriggerEvent('sy_garage:Notification', 'Error')
        end
    end, vehicleProps, name, vehicleProps.plate)
end)



