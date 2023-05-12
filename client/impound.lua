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
            TriggerServerEvent('mono_garage:MandarVehiculoImpound', plate, impound)
            TriggerEvent('mono_garage:Notification', locale('impound1', plate))
        else
            Wait(5000)
            DeleteEntity(vehicle)
            TriggerServerEvent('mono_garage:MandarVehiculoImpound', plate, impound)
            TriggerEvent('mono_garage:Notification', locale('impound1', plate))
        end
    else
        TriggerEvent('mono_garage:Notification', locale('no_veh_nearby'))
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
                    TriggerEvent('mono_garage:Notification', locale('cancelado'))
                end
            else
                TriggerEvent('mono_garage:Notification', locale('no_veh_nearby'))
            end
            break
        end
    end
    if not jobAllowed then
        TriggerEvent('mono_garage:Notification', locale('impound3'))
    end
end)

AddEventHandler('mono_garage:NPCImpound', function()
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
            TriggerEvent('mono_garage:Notification', locale('cancelado'))
        end
    else
        TriggerEvent('mono_garage:Notification', locale('no_veh_nearby'))
    end
end)




