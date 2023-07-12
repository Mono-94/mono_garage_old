for i = 1, #Garage.NpcImpound.jobs do
    local options = {
        {
            icon = 'fa-solid fa-car-on',
            label = 'Impound vehicle',
            groups = Garage.NpcImpound.jobs[i],
            canInteract = function(entity, distance, coords, name, bone)
                vehicle = { entity = entity, distance = distance, coords = coords, name = name, bone = bone,
                    job = Garage.NpcImpound.jobs[i] }
                return vehicle
            end,
            onSelect = function()
                ImpoundVehicle(vehicle)
            end
        }
    }
    exports.ox_target:addGlobalVehicle(options)
end


RegisterCommand(Garage.NpcImpound.Command, function()
    local trabajo = false
    local noti = false
    for k, v in pairs(Garage.NpcImpound.jobs) do
        if ESX.PlayerData.job.name == v then
            trabajo = true
            local entity, coords = lib.getClosestVehicle(cache.coords, 3.0, true)
            local veh = { coords = coords, entity = entity, job = v }
            if coords then
                ImpoundVehicle(veh)
            else
                if not noti then
                    TriggerEvent('mono_garage:Notification', locale('no_veh_nearby'))
                    noti = true
                end
            end
        end
    end

    if not trabajo and not noti then
        TriggerEvent('mono_garage:Notification', locale('impound3'))
        noti = true
    end
end)



function ImpoundVehicle(vehicle)
    local props = lib.getVehicleProperties(vehicle.entity)
    local name = lib.callback.await('mono_garage:GetPlayerNamePlate', source,
        string.gsub(props.plate, "^%s*(.-)%s*$", "%1"))
    if name == nil then
        name = 'Name not found!'
    end

    local imp = {}

    for k, v in pairs(Garage.Garages) do
        if v.impound then
            if v.job == vehicle.job then
                if GetVehicleCategory(vehicle.entity) == v.type then
                    table.insert(imp, { value = k, label = k })
                end
            end
        end
    end
    local vehiclename = GetMakeNameFromVehicleModel(props.model) .. ' - ' .. GetDisplayNameFromVehicleModel(props.model)

    local input = lib.inputDialog(locale('impound5'), {
        {
            type = 'input',
            icon = 'address-card',
            disabled = true,
            label = locale('impfunc_owner'),
            required = false,
            placeholder =
                name
        },
        {
            type = 'input',
            icon = 'window-maximize',
            disabled = true,
            label = locale('impfunc_plate'),
            required = false,
            placeholder =
                props.plate
        },
        {
            type = 'input',
            icon = 'car',
            disabled = true,
            label = locale('impfunc_model'),
            required = false,
            placeholder = vehiclename
        },
        {
            type = 'textarea',
            icon = 'pen-to-square',
            label = 'Reason',
            required = true,
            placeholder = locale('impfunc_reasonholder'),
            max = 200,
        },
        {
            type = 'number',
            icon = 'money-bill-trend-up',
            label = locale('impfunc_price'),
            required = true,
            default = 1,
            min = 1,
            max = 10000000
        },
        {
            type = 'date',
            label = locale('impfunc_date'),
            icon = { 'far', 'calendar' },
            disabled = false,
            required = true,
            format = "DD/MM/YYYY"
        },
        {
            type = 'select',
            icon = 'warehouse',
            label = locale('impound2'),
            required = true,
            options = imp
        },

    })
    if not input then return end
    local reason = input[4]
    local price = input[5]
    local date = input[6] / 1000
    local impound = input[7]

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
        NpcImpound({
            impound = impound,
            entity = vehicle.entity,
            coords = vehicle.coords,
            plate = string.gsub(props.plate, "^%s*(.-)%s*$", "%1"),
            price = price,
            reason = reason,
            date = date
        })
    else
        TriggerEvent('mono_garage:Notification', locale('cancelado'))
    end
end

function NpcImpound(data)
    if Garage.NpcImpound.NPCAnim then
        local playerPos = data.coords
        local hcar = GetEntityHeading(data.entity)
        local pos = vec4(playerPos.x, playerPos.y + 3, playerPos.z - 1, hcar + 50)
        local Spawned = CreateNPC(Garage.NpcImpound.NPCHash, pos)
        FreezeEntityPosition(Spawned, false)
        SetPedRelationshipGroupHash(Spawned, GetHashKey("PLAYER"))
        SetRelationshipBetweenGroups(0, GetHashKey("PLAYER"), GetPedRelationshipGroupHash(Spawned))
        SetVehicleDoorsLocked(data.entity, 0)
        SetEntityNoCollisionEntity(Spawned, cache.ped, true)
        SetEveryoneIgnorePlayer(Spawned, true)
        TaskEnterVehicle(Spawned, data.entity, -1, -1, 1.0, 1, 0)

        while true do
            Wait(0)
            if GetPedInVehicleSeat(data.entity, -1) > 0 then
                SetVehicleEngineOn(data.entity, true, true)
                break
            end
        end

        TaskVehicleDriveToCoordLongrange(Spawned, data.entity, 408.81500244141, -1637.9078369141, 29.291925430298, 60.0,
            447, 2.0)
            Wait(Garage.NpcImpound.TimeDeleteVehicle)
        DeletePed(Spawned)
        DeleteEntity(data.entity)
        TriggerServerEvent('mono_garage:ImpoundJoB', data.plate, data.impound, data.price, data.reason, data.date)
    else
        NetworkFadeOutEntity(data.entity,false, true)
        Wait(2000)
        DeleteEntity(data.entity)
        TriggerServerEvent('mono_garage:ImpoundJoB', data.plate, data.impound, data.price, data.reason, data.date)
    end
   
end
