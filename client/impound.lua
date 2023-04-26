function NPCImpoundGarage(impound)
    local playerPed = PlayerPedId()
    local playerPos = GetEntityCoords(playerPed)
    local npcHash = GetHashKey(Garage.NpcImpound.NpcHash)
    local vehicle = lib.getClosestVehicle(playerPos, 7.0, false)
    local plate = GetVehicleNumberPlateText(vehicle)
    if vehicle then
        if Garage.NpcImpound.NPCAnim then
            RequestModel(npcHash)
            while not HasModelLoaded(npcHash) do
                Wait(0)
            end

            local npcPed = CreatePed(5, npcHash, playerPos.x + 2, playerPos.y + 2, playerPos.z - 1, 0.0, true, false)

            SetPedRelationshipGroupHash(npcPed, GetHashKey("PLAYER"))
            SetRelationshipBetweenGroups(0, GetHashKey("PLAYER"), GetPedRelationshipGroupHash(npcPed))


            SetEntityNoCollisionEntity(npcPed, playerPed, true)
            SetEveryoneIgnorePlayer(npcPed, true)

            Wait(1000)

            TaskEnterVehicle(npcPed, vehicle, -1, -1, 1.0, 1, 0)

            SetVehicleEngineOn(vehicle, true, true)
            SetVehicleDoorsLocked(vehicle, 0)
            TaskVehicleDriveToCoordLongrange(npcPed, vehicle, 408.81500244141, -1637.9078369141, 29.291925430298, 60.0,
                447,
                2.0)
            local tiempo = Garage.NpcImpound.TimeDeleteVehicle
            Wait(tiempo)
            ClearPedTasks(npcPed)
            DeletePed(npcPed)
            DeleteEntity(vehicle)
            TriggerServerEvent('sy_garage:MandarVehiculoImpound', plate, impound)
            TriggerEvent('sy_garage:Notification', locale('impound1', plate))
        else
            Wait(5000)
            DeleteEntity(vehicle)
            TriggerServerEvent('sy_garage:MandarVehiculoImpound', plate, impound)
            TriggerEvent('sy_garage:Notification', locale('impound1', plate))
        end
    else
        TriggerEvent('sy_garage:Notification', locale('no_veh_nearby'))
    end
end

RegisterCommand(Garage.NpcImpound.Command, function()
    local jobAllowed = false
    for i = 1, #Garage.NpcImpound.jobs do
        if ESX.PlayerData.job.name == Garage.NpcImpound.jobs[i] then
            jobAllowed = true
            if Sy.CarCloset({ dist = 7, pedcar = true }) then
                local input
                local imp = {}
                for k, v in pairs(Garage.Garages) do
                    if v.impound then
                        table.insert(imp, {
                            value = k, label = k
                        })
                    end
                end

                input = lib.inputDialog(locale('impound5'), {
                    {
                        type = 'select',
                        icon = 'warehouse',
                        label = locale('impound2'),
                        options = imp
                    },
                })
                if not input then return end
                if lib.progressBar({
                        duration = Garage.NpcImpound.ProgressBarTime,
                        label = locale('impound4'),
                        useWhileDead = false,
                        canCancel = true,
                        disable = {
                            car = true,
                        },
                        anim = {
                            scenario = 'WORLD_HUMAN_CLIPBOARD',
                        },

                    }) then
                    NPCImpoundGarage(input[1])
                else
                    TriggerEvent('sy_garage:Notification', locale('cancelado'))
                end
            else
                TriggerEvent('sy_garage:Notification', locale('no_veh_nearby'))
            end
            break
        end
    end
    if not jobAllowed then
        TriggerEvent('sy_garage:Notification', locale('impound3'))
    end
end)

AddEventHandler('sy_garage:NPCImpound', function()
    if Sy.CarCloset({ dist = 7, pedcar = true }) then
        local input
        local imp = {}
        for k, v in pairs(Garage.Garages) do
            if v.impound then
                table.insert(imp, {
                    value = k, label = k
                })
            end
        end

        input = lib.inputDialog(locale('impound5'), {
            {
                type = 'select',
                icon = 'warehouse',
                label = locale('impound2'),
                options = imp
            },
        })
        if not input then return end
        if lib.progressBar({
                duration = Garage.NpcImpound.ProgressBarTime,
                label = locale('impound4'),
                useWhileDead = false,
                canCancel = true,
                disable = {
                    car = true,
                },
                anim = {
                    scenario = 'WORLD_HUMAN_CLIPBOARD',
                },

            }) then
            NPCImpoundGarage(input[1])
        else
            TriggerEvent('sy_garage:Notification', locale('cancelado'))
        end
    else
        TriggerEvent('sy_garage:Notification', locale('no_veh_nearby'))
    end
end)



if Garage.AutoImpound.AutoImpound then
    CreateThread(function()
        while true do
            local vehicles = lib.callback.await('sy_garage:owner_vehicles')
            for i = 1, #vehicles do
                local data = vehicles[i]
                local veh = json.decode(data.vehicle)
                local allVehicles = ESX.Game.GetVehicles()
                local vehicleFound = false
                for j = 1, #allVehicles do
                    local vehicle = allVehicles[j]
                    if DoesEntityExist(vehicle) then
                        local model = GetEntityModel(vehicle)
                        local plate = GetVehicleNumberPlateText(vehicle)
                        if plate == data.plate then
                            local ped = GetPedInVehicleSeat(vehicle, -1)
                            if ped == 0 then
                                if data.stored == 0 then
                                    if Garage.Debug then
                                        print('Plate: ' ..
                                            data.plate .. ', Hash: ' .. veh.model .. ', Fuera sin jugador.')
                                    end
                                end
                            else
                                if Garage.Debug then
                                    print('Plate: ' .. data.plate .. ', Hash: ' .. veh.model .. ', Fuera con jugador.')
                                end
                            end
                            vehicleFound = true
                            break
                        end
                    end
                end
                if not vehicleFound and data.stored == 0 and data.pound == nil then
                    TriggerServerEvent('sy_garage:AutoImpound', data.plate, Garage.AutoImpound.ImpoundIn)
                    if Garage.Debug then
                        print('Plate: ' ..
                            data.plate .. ', Hash: ' .. veh.model .. ', Entidad no existe. ( Incautado con exito )')
                    end
                end
            end
            Wait(Garage.AutoImpound.TimeCheck)
        end
    end)
end
