Sy = {}

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






RegisterNetEvent('sy_garage:Propiedades', function(NetId, props)
    while not NetworkDoesEntityExistWithNetworkId(NetId)  do
       Wait(0)
    end

    if NetworkDoesEntityExistWithNetworkId(NetId) then
        lib.setVehicleProperties(NetToVeh(NetId), props)
    end
end)
  



RegisterNetEvent('sy_garage:CheckVeh2')
AddEventHandler('sy_garage:CheckVeh2', function()
    local playerVehicle = GetVehiclePedIsIn(PlayerPedId(), false)
    local vehicleProps = Sy.GetProps()
    local model = GetEntityModel(playerVehicle)
    local name = GetDisplayNameFromVehicleModel(model)
    local plate = GetVehicleNumberPlateText(playerVehicle)
    if cache.vehicle then
        TriggerServerEvent('sy_garage:SetCarDB', vehicleProps, plate, name)
        TriggerServerEvent('sy_carkeys:CreateKey', plate, name)
    else
        TriggerEvent('sy_garage:Notification', locale('dentrocar'))
    end
end)






