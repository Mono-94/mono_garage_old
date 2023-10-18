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
    local name = lib.callback.await('mono_garage:GetPlayerNamePlate', source, SP(props.plate) )


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
            placeholder =  name.name
        },
        {
            type = 'input',
            icon = 'window-maximize',
            disabled = true,
            label = locale('impfunc_plate'),
            required = false,
            placeholder =  props.plate
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
            type = 'input',
            icon = { 'far', 'calendar' },
            disabled = true,
            label = locale('impfunc_date'),
            required = false,
            placeholder =  name.fecha..' '..name.hora
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
            TriggerServerEvent('mono_garage:ImpoundJoB', SP(props.plate), input[7],input[5], input[4], name.fecha, VehToNet(vehicle.entity))
    else
        TriggerEvent('mono_garage:Notification', locale('cancelado'))
    end
end

