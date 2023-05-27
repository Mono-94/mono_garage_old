Framework.Functions = {}
function Framework.Functions.GetPlayer(source)
    return Framework.Core.GetPlayerFromId(source)
end

function Framework.Functions.GetPlayerID(source)
    return Framework.Core.GetPlayerFromId(source).getIdentifier()
end

function Framework.Functions.GetName(source)
    return Framework.Core.GetPlayerFromId(source).getIdentifier().getName()
end

function Framework.Functions.GetSource(source)
    local player = Framework.Core.GetPlayerFromId(source)
    return player.source
end

function Framework.Functions.GetMoney(source)
    local player = Framework.Core.GetPlayerFromId(source)
    return {
        bank = player.getAccount("bank"),
        money = player.getMoney()
    }
end

function Framework.Functions.SpawnVehicle(source, model, pos, hea, warp, vehicleprops)
    Framework.Core.OneSync.SpawnVehicle(model, pos, hea, vehicleprops, function(NetworkId)
        Wait(100)
        local Vehicle = NetworkGetEntityFromNetworkId(NetworkId)

        while not DoesEntityExist(Vehicle) do
            Wait(0)
        end
        if warp then
            while not NetworkGetEntityOwner(source) == source do
                Wait(0)
                print("NO SOY EL DUEÑO")
            end
            TaskWarpPedIntoVehicle(source, Vehicle, -1)
        end
    end)
end

return Framework.Functions
