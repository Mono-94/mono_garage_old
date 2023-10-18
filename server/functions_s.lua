local ox = exports.ox_inventory
local Thread = Citizen.CreateThread
local wait = Citizen.Wait

-- WEBHOOK LOGS TRANSFER VEHICLES!
local webhook =
'https://discord.com/api/webhooks/1162236750832345169/gbuH4OGEQrK-oI78MIb3cgtSAbcDiwCYGwuS5p9GYpJ0qGKcR4L4dUc99GNDI2vi1dht'


function Noti(player, text)
    TriggerClientEvent('mono_garage:Notification', player, text)
end

-- Generate Random Plate
function GeneratePlate()
    local caracteres = "ABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789"
    local longitud = 8
    local matricula = ""

    for i = 1, longitud do
        local indice = math.random(#caracteres)
        matricula = matricula .. string.sub(caracteres, indice, indice)
    end

    return matricula
end

-- Plate Equal
function PlateEqual(valor1, valor2)
    valor1 = tostring(valor1)
    valor2 = tostring(valor2)

    valor1 = valor1:gsub("%s", ""):lower()
    valor2 = valor2:gsub("%s", ""):lower()

    return valor1 == valor2
end

-- PlateCount
function PlateCount(platecounted, table)
    if Garage.Debug.Prints then
        print('PlateCount ' .. platecounted)
    end
    local cantidad = 0
    for entity, plate in pairs(table) do
        if PlateEqual(plate,platecounted) then
            cantidad = cantidad + 1
            if cantidad > 1 then
                return true
            end
        end
    end
    return false
end

-- Set Player in Car
function PlayerToCar(data)
    if DoesEntityExist(data.entity) then
        if data.intocar then
            Thread(function()
                while true do
                    TaskWarpPedIntoVehicle(data.player, data.entity, -1)
                    if GetPedInVehicleSeat(data.entity, -1) > 0 then
                        ServerInventoryKeys(data, 'add')
                        break
                    end
                    wait(0)
                end
            end)
        else
            ServerInventoryKeys(data, 'add')
        end
        if not data.impound then
            Noti(data.player, locale('SERVER_retirar'))
        end
    else
        return
    end
end

-- Set Player Out Car
function PlayerOutCar(data)
    if DoesEntityExist(data.entity) then
        Thread(function()
            while true do
                if GetPedInVehicleSeat(data.entity, -1) > 0 then
                    TaskLeaveVehicle(data.player, data.entity, 1)
                    Citizen.Wait(1000)
                else
                    Noti(data.player, locale('SERVER_VehiculoGuardado'))
                    ServerInventoryKeys(data, 'remove')
                    TriggerClientEvent('mono_garage:FadeOut', -1, NetworkGetNetworkIdFromEntity(data.entity))
                    wait(1500)
                    if DoesEntityExist(data.entity) then
                        DeleteEntity(data.entity)
                    end
                    break
                end
                wait(0)
            end
        end)
    else
        return
    end
end

-- Inventory give/remove KEYS
function ServerInventoryKeys(data, action)
    local source = data.player
    local plate = data.plate
    if Garage.CarKeys then
        if action == 'add' then
            if Garage.Inventory == 'ox' then
                ox:AddItem(source, Keys.ItemName, 1,
                    { plate = plate, description = locale('key_description', plate) })
            elseif Garage.Inventory == 'qs' then
                exports['qs-inventory']:AddItem(source, Keys.ItemName, 1, nil, {
                    plate = plate,
                    description = locale('key_description', plate)
                })
            elseif Garage.Inventory == 'custom' then
                Garage.FunctionKeys()
            elseif Garage.Inventory == 'qb' then
            --  Player.Functions.AddItem(item, amount, nil, info)
            end
        elseif action == 'remove' then
            if Garage.CarKeys then
                if Garage.Inventory == 'ox' then
                    ox:RemoveItem(source, Keys.ItemName, 1,
                        { plate = plate, description = locale('key_description', plate) })
                elseif Garage.Inventory == 'qs' then
                    exports['qs-inventory']:RemoveItem(source, Keys.ItemName, 1, nil,
                        { plate = plate, description = locale('key_description', plate) })
                elseif Garage.Inventory == 'custom' then
                    Garage.FunctionKeys()
                elseif Garage.Inventory == 'qb' then
                    print('work in')
                end
            end
        end
    end
end


RegisterNetEvent('ServerInventoryKeys', ServerInventoryKeys)

exports('ServerInventoryKeys', ServerInventoryKeys)



-- Close Vehicles Doors when vehicle create
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
            if VehEntity.EntityVehicleSpawn.OpenDoorProbability > math.random(1, 10) then
                return
            end
        end
        SetVehicleDoorsLocked(entity, 2)
    end
end)

-- WebHook
function WebHoook(data, action)
    if action == 'buy' then
        Description = 'Char Owner```' ..
            data.owner ..
            '```Name Owner```' ..
            data.Seller ..
            '```Char Buyer```' ..
            data.CharBuyer ..
            '```Name Buyer```' ..
            data.Buyer .. '```Vehicle```' .. data.name .. ' - ' .. data.marca .. '```Price```' .. data.input[2] .. '```'
        Author = 'Sell Vehicle'
    elseif action == 'trasnfer' then
        Description = 'Char Owner```' ..
            data.owner ..
            '```Name Owner```' ..
            data.Seller ..
            '```Char Receive```' ..
            data.CharBuyer .. '```Name Receive```' .. data.Buyer .. '```Vehicle ```' .. data.name .. '```'
        Author = 'Trasnfer vehicle'
    end
    local msg = {
        {
            ['id'] = 409357312,
            ['description'] = Description,
            ['fields'] = {},
            ['color'] = 8121969,
            ['author'] = { ['name'] = Author },
            ['footer'] = { ['text'] = "mono_garage  | " .. os.date("%Y-%m-%d") .. ' - ' .. os.date("%H:%M:%S") },
            ['username'] = " M O N O   G A R A G E ",
            ['avatar_url'] = "https://cdn.discordapp.com/attachments/1075654628047327266/1162773414457651382/Sin_titulo-1.png"
        }

    }

    PerformHttpRequest(webhook, function()
        end, 'POST',
        json.encode({ username = GetCurrentResourceName(), embeds = msg }),
        { ['Content-Type'] = 'application/json' }
    )
end

--- // CHECK NEW VERSION
if Garage.Version then
    local function GitHubUpdate()
        PerformHttpRequest('https://raw.githubusercontent.com/Mono-94/mono_garage/main/fxmanifest.lua',
            function(error, result, headers)
                local actual = GetResourceMetadata(GetCurrentResourceName(), 'version')

                if not result then print("^6MONO GARAGE^7 -  version couldn't be checked") end

                local version = string.sub(result, string.find(result, "%d.%d.%d"))

                if tonumber((version:gsub("%D+", ""))) > tonumber((actual:gsub("%D+", ""))) then
                    print('^6MONO GARAGE^7  - The version ^2' .. version ..'^0 is available, you are still using version ^1' .. actual .. ', ^0Download the new version at: https://github.com/Mono-94/mono_garage')
                else
                    print('^6MONO GARAGE^7 - You are using the latest version of the script.')
                end
            end)
    end
    GitHubUpdate()
end


-- // Print Bugs

function Bug(action, text, ...)
    if Garage.Debug.Prints then
        local formatted_args = {}

        for i, arg in ipairs({ ... }) do
            if type(arg) == "string" then
                table.insert(formatted_args, arg)
            else
                table.insert(formatted_args, arg)
            end
        end

        local formatted_text = string.format(text, table.unpack(formatted_args))

        print('^4 BUG ^5Action Name ^7= ' .. action .. '| Data = ' .. formatted_text)
    end
end
