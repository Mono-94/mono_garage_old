Framework.Functions = {}
function Framework.Functions.GetProps(vehicle)
    return Framework.Core.Game.GetVehicleProperties(vehicle)
end

function Framework.Functions.GetJob()
    return Framework.Player.PlayerData.job.name
end

function Framework.Functions.SpawnPoint(pos, radius)
    return Framework.Core.Game.IsSpawnPointClear(pos, radius or 2.0)
end

function Framwork.Functions.GetAllVehicles()
    return Framework.Core.Game.GetVehicles()
end

return Framework.Functions
