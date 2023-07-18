-- GetType
function GetVehicleCategory(vehicle)
    local ListaCategoria = {}

    VehicleCategories = {
        ['car'] = { 0, 1, 2, 3, 4, 5, 6, 7, 8, 9, 10, 11, 12, 17, 19, 13, 20, 18 },
        ['boat'] = { 14 },
        ['air'] = { 15, 16 },

    }
    local function GetClase()
        local clase = GetVehicleClass(vehicle)
        return clase
    end

    for categoria, clase in pairs(VehicleCategories) do
        for _, class in pairs(clase) do
            ListaCategoria[class] = categoria
        end
    end

    return ListaCategoria[GetClase()]
end

-- Blips

function CrearBlip(pos, sprite, scale, colorblip, blipName)
    local blip = AddBlipForCoord(pos)
    SetBlipSprite(blip, sprite)
    SetBlipDisplay(blip, 4)
    SetBlipScale(blip, scale)
    SetBlipColour(blip, colorblip)
    SetBlipAsShortRange(blip, true)
    BeginTextCommandSetBlipName("STRING")
    AddTextComponentString(blipName)
    EndTextCommandSetBlipName(blip)
    return blip
end

-- NPC

function CreateNPC(NPCHash, NPCPos)
    RequestModel(NPCHash)
    while not HasModelLoaded(NPCHash) do
        Wait(1)
    end
    local NPC = CreatePed(2, NPCHash, NPCPos, false, false)
    SetPedFleeAttributes(NPC, 0, 0)
    SetPedDiesWhenInjured(NPC, false)
    TaskStartScenarioInPlace(NPC, "missheistdockssetup1clipboard@base", 0, true)
    SetPedKeepTask(NPC, true)
    SetBlockingOfNonTemporaryEvents(NPC, true)
    SetEntityInvincible(NPC, true)
    FreezeEntityPosition(NPC, true)
    return NPC
end

-- Give Vehicle

RegisterNetEvent('mono_garage:GiveVehicle', function()
    local playerVehicle = cache.vehicle

    local props = lib.getVehicleProperties(playerVehicle)
    local plate = SP(props.plate)
    if playerVehicle then
        local opt = {}
        for k, v in pairs(Garage.Garages) do
            if not v.impound and not v.job then
                table.insert(opt, { label = k, value = k })
            end
        end
        local input = lib.inputDialog('GiveCar', {
            { type = 'select', label = 'Select garage', required = true, options = opt },
        })
        if not input then return end



        TriggerServerEvent('mono_garage:SetCarDB', props, plate, input[1])
    else
        TriggerEvent('mono_garage:Notification', locale('dentrocar'))
    end
end)


--[[ Get Total Km

function GetTotalKm(plate)
    local totalkm = lib.callback.await('mono_garage:GetTotalKm', source, SP(plate))
    local equivalenteEnKilometros = tonumber(totalkm) / 520.000
    local formattedEquivalente = string.format("%.1f", equivalenteEnKilometros)
    return formattedEquivalente
end

exports('GetTotalKm', GetTotalKm)]]

-- Save Vehicle

function SaveVehicle(data)
    if data.distance == nil or data.distance > 5 then
        data.distance = 2.5
    end
    local vehicle = lib.getClosestVehicle(cache.coords, data.distance, true)
    if vehicle then
        local vehicleProps = lib.getVehicleProperties(vehicle)
        local plate = SP(vehicleProps.plate)
        if data.type == 'all' then
            TriggerServerEvent('mono_garage:GuardarVehiculo', plate, vehicleProps, data.garage,
                VehToNet(vehicle))
        elseif GetVehicleCategory(vehicle) == data.type then
            TriggerServerEvent('mono_garage:GuardarVehiculo', plate, vehicleProps, data.garage,
                VehToNet(vehicle))
        else
            TriggerEvent('mono_garage:Notification', locale('NoAqui'))
        end
    else
        TriggerEvent('mono_garage:Notification', locale('mascerca'))
    end
end

exports('SaveVehicle', SaveVehicle)


function SpawnClearArea(pos, maxdistance)
    local vehicle = {}

    for k, v in pairs(GetGamePool('CVehicle')) do
        local distance = #(vector3(pos.x, pos.y, pos.z) - GetEntityCoords(v))

        if distance <= maxdistance then
            vehicle[#vehicle + 1] = k or v
        end
    end

    return #vehicle == 0
end

-- Fade In

function FadeInEntity(entity)
    local fadeCount = 5
    local fadeDuration = 200

    NetworkFadeInEntity(entity, false)

    for i = 1, fadeCount do
        Wait(fadeDuration)
        NetworkFadeInEntity(entity, true)
    end

    NetworkFadeInEntity(entity, true)
end

-- Fade Out

RegisterNetEvent('mono_garage:FadeOut', function(vehicle)
    NetworkFadeOutEntity(NetToVeh(vehicle), false, true)
end)

-- StateBag Props

AddStateBagChangeHandler('CrearVehiculo', nil, function(bagName, key, value, _unused, replicated)
    if not value then return end

    local entity = bagName:gsub('entity:', '')

    while not NetworkDoesEntityExistWithNetworkId(tonumber(entity)) do
        Wait(0)
    end

    local vehicle = NetToVeh(tonumber(entity))

    FadeInEntity(vehicle)

    while NetworkGetEntityOwner(vehicle) ~= PlayerId() do
        Wait(0)
    end

    SetVehicleEngineOn(vehicle, false, false, true)

    lib.setVehicleProperties(vehicle, value)

    Entity(vehicle).state:set('CrearVehiculo', nil, true)
end)

-- StringPlate

function SP(plate)
    return string.gsub(plate, "^%s*(.-)%s*$", "%1")
end

--- Garage notifications

--<-------------------------------------->--

--Notification

RegisterNetEvent('mono_garage:Notification', function(msg)
    lib.notify({
        title = locale('Garaje'),
        description = msg,
        position = 'top',
        icon = 'car',
        iconColor = 'rgb(36,116,255)'
    })
end)


---Copi coords

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
                label = '{ x = 0, y = 0, z = 0, w = 0}',
                onSelect = function()
                    local ped = cache.ped
                    local coords = GetEntityCoords(ped)
                    local heading = GetEntityHeading(ped)
                    lib.setClipboard('{ x = ' .. coords.x .. ', y = ' .. coords.y .. ', z = ' ..
                        coords.z .. ', w = ' .. heading .. '},')
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
                    lib.setClipboard('vec4(' .. coords.x .. ', ' .. coords.y .. ',' ..
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
