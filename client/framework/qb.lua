Framework.Functions = {}
function Framework.Functions.GetProps(vehicle)
    return Framework.Core.Functions.GetVehicleProperties(vehicle)
end

function Framework.Functions.GetJob()
    return Framework.Player.PlayerData.job.name
end

function Framework.Functions.SpawnPoint(pos, radius)
    return Framework.Core.Functions.SpawnClear(pos, radius or 2.0)
end

function Framework.Functions.GetAllVehicles()
    return Framework.Core.Functions.GetVehicles()
end

return Framework.Functions
