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
        if VehEntity.EntityVehicleSpawn.DoorProbability then
            if  VehEntity.EntityVehicleSpawn.OpenDoorProbability > math.random(1, 10) then
                return
            end
        end
        SetVehicleDoorsLocked(entity, 2)
    end
end)
