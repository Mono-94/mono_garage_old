-- Get Vehicle type
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

-- Export InventoryKeys
exports('ClientInventoryKeys', function (plate, action)
    TriggerServerEvent('ServerInventoryKeys', {player = cache.serverId, plate = plate}, action)



-- Get Vehicle Icon ox_lib menu
function GetVehicleIcon(name)
    local class = GetVehicleClassFromName(name)
    local icons = {
        [8]  = 'motorcycle',
        [2]  = 'truck-pickup',
        [15] = 'helicopter',
        [16] = 'plane',
        [14] = 'ship',
    }
    return icons[class] or 'car'
end

-- Text UI
function TextUI(msg)
    if Garage.textui == 'custom' then
        exports['mono_textui']:TextUI(msg)
    elseif Garage.textui == 'ox_textui' then
        lib.showTextUI(msg, { icon = 'car' })
    elseif Garage.textui == 'esx_textui' then
        ESX.TextUI(msg)
    end
end

function CloseTextUI()
    if Garage.textui == 'custom' then
        exports['mono_textui']:TextUIOff()
    elseif Garage.textui == 'ox_textui' then
        lib.hideTextUI()
    elseif Garage.textui == 'esx_textui' then
        ESX.HideUI()
    end
end

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

-- Create Blips
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

-- Create NPC
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

-- Save Vehicles
function SaveVehicle(data)
    if data.distance == nil or data.distance > 5 then data.distance = 2.5 end
    if data.entity == nil then
        data.entity = lib.getClosestVehicle(cache.coords, data.distance, true)
    end
    if DoesEntityExist(data.entity) then
        if data.entity then
            data.vehicleProps = lib.getVehicleProperties(data.entity)
            data.vehicleType = GetVehicleCategory(data.entity)
            data.plate = SP(data.vehicleProps.plate)
            data.VehType = GetVehicleCategory(data.entity)
            data.model = string.lower(GetDisplayNameFromVehicleModel(GetEntityModel(data.entity)))
            data.entity = VehToNet(data.entity)
            if data.type == 'custom' then
                TriggerServerEvent('mono_garage:SaveVechile', data)
            elseif data.type == 'all' then
                TriggerServerEvent('mono_garage:SaveVechile', data)
            elseif data.VehType == data.type then
                TriggerServerEvent('mono_garage:SaveVechile', data)
            else
                TriggerEvent('mono_garage:Notification', locale('NoAqui'))
            end
        else
            if not data.entity then return end
            TriggerEvent('mono_garage:Notification', locale('mascerca'))
        end
    else
        return
    end
end

exports('SaveVehicle', SaveVehicle)


--  Plate Equal
function PlateEqual(valor1, valor2)
    valor1 = tostring(valor1)
    valor2 = tostring(valor2)

    valor1 = valor1:gsub("%s", ""):lower()
    valor2 = valor2:gsub("%s", ""):lower()

    return valor1 == valor2
end

--Is clear area vehicles
function SpawnClearArea(pos, maxdistance)
    local playerpos = GetEntityCoords(PlayerPedId())
    local distancia, cerca, heading, coords = math.huge, nil, nil, nil

    for _, v in ipairs(pos) do
        local spawnPos = vector3(v.x, v.y, v.z)
        local distance = #(playerpos - spawnPos)

        if distance < distancia then
            local isClear = true
            for k, vehicle in pairs(GetGamePool('CVehicle')) do
                local vehicleDistance = #(vector3(spawnPos.x, spawnPos.y, spawnPos.z) - GetEntityCoords(vehicle))
                if vehicleDistance <= maxdistance then
                    isClear = false
                    break
                end
            end

            if isClear then
                distancia, coords, heading = distance, spawnPos, v.w
            end
        end
    end

    return coords, heading, distancia
end

-- Fade In entity
function FadeInEntity(entity)
    if DoesEntityExist(entity) then
        local fadeCount = 5
        local fadeDuration = 200
        NetworkFadeInEntity(entity, false)
        for i = 1, fadeCount do
            Wait(fadeDuration)
            NetworkFadeInEntity(entity, true)
        end
        NetworkFadeInEntity(entity, true)
    end
end

-- Fade Out entity
RegisterNetEvent('mono_garage:FadeOut', function(vehicle)
    local entity = NetToVeh(vehicle)
    if DoesEntityExist(entity) then
        NetworkFadeOutEntity(entity, false, true)
    end
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
    
    if value.custom then
        if Garage.Fuel == 'LegacyFuel' then
            exports["LegacyFuel"]:SetFuel(vehicle, 100)
        elseif Garage.Fuel == 'esx-sna-fuel' then
            exports['esx-sna-fuel']:ApplyFuel(vehicle, 100)
        end
        SetVehicleEngineOn(vehicle, false, false, true)
        lib.setVehicleProperties(vehicle, value.props) 
    else
        if Garage.Fuel == 'LegacyFuel' then
            exports["LegacyFuel"]:SetFuel(vehicle, value.fuelLevel)
        elseif Garage.Fuel == 'esx-sna-fuel' then
            exports['esx-sna-fuel']:ApplyFuel(vehicle)
        end
        SetVehicleEngineOn(vehicle, false, false, true)
        lib.setVehicleProperties(vehicle, value) 

    end
    Entity(vehicle).state:set('CrearVehiculo', nil, true)
end)

-- StringPlate

function SP(plate)
    return string.gsub(plate, "^%s*(.-)%s*$", "%1")
end

-- Test String VehiclePropertis / Copy
function StringVehicleProps()
    local props = lib.getVehicleProperties(cache.vehicle)
    local input = json.encode(props)
    local step1 = input:gsub('"', '')
    local step2 = step1:gsub(':', '=')
    local step3 = step2:gsub('%[', '{')
    local step4 = step3:gsub('%]', '}')
    local function replaceExtras(match)
        return match:gsub('{(.-)}', function(inner)
            return inner:gsub('(%d+):(%d+)', '[%1] = %2')
        end)
    end

    local step5 = step4:gsub('extras:(%b{})', replaceExtras)

    return lib.setClipboard(step5)
end

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
                label = 'vec3(0,0,0)',
                onSelect = function()
                    local ped = cache.ped
                    local coords = GetEntityCoords(ped)
                    lib.setClipboard('vec3(' .. coords.x .. ',' .. coords.y .. ',' .. coords.z .. '),')
                end
            },
            {
                label = 'vecc4(0,0,0)',
                onSelect = function()
                    local ped = cache.ped
                    local coords = GetEntityCoords(ped)
                    local heading = GetEntityHeading(ped)
                    lib.setClipboard('vec4(' .. coords.x .. ', ' .. coords.y .. ',' .. coords.z .. ',' .. heading .. '),')
                end
            },
            {
                label = 'HEADING',
                onSelect = function()
                    local ped = cache.ped
                    lib.setClipboard(GetEntityHeading(ped))
                end
            },
            {
                label = 'StringVehicleProps',
                onSelect = function()
                    StringVehicleProps()
                end
            }
        }
    })
end


for k, v in pairs(Garage.Garages) do
    exports.ox_target:addGlobalVehicle({
        icon = 'fa-solid fa-share',
        label = locale('Extras1'),
        groups = v.job,
        distance = 2,
        canInteract = function(entity, distance, coords, name, bone)
            if v.jobcar ~= nil then
                for modelo, nombre in pairs(v.jobcar) do
                    if string.lower(GetDisplayNameFromVehicleModel(GetEntityModel(entity))) == nombre.model then
                        return entity, distance, coords, name, bone
                    end
                end
            end
        end,
        onSelect = function(data)
            local extras = {}
            for i = 1, 25 do
                if not DoesExtraExist(data.entity, i) then
                    goto aqui
                end

                local extraTurnedOn = IsVehicleExtraTurnedOn(data.entity, i)

                extras[#extras + 1] = {
                    label = ('Extra %d'):format(i),
                    close = true,
                    values = { locale('Extras2'), locale('Extras1'), },

                    defaultIndex = extraTurnedOn and 1 or 2,
                }

                ::aqui::
            end

            if #extras > 0 then
                lib.registerMenu({
                    id = 'menu:extras',
                    title = locale('Extras4'),
                    position = 'top-right',
                    options = extras,
                    onSideScroll = function(selected, index)
                        SetVehicleExtra(data.entity, selected, index - 1)
                    end
                }, function(selected, scr, args)
                    if Garage.Debug.Prints then
                        print(selected, scr, args)
                    end
                end)

                lib.showMenu('menu:extras')
            else
                TriggerEvent('mono_garage:Notification', locale('Extras4'))
            end
        end
    })
end
