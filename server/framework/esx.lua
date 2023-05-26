Framework.Functions = {}
function Framework.Functions.GetPlayer(source)
    return Framework.Core.GetPlayerFromId(source)
end

function Framework.Functions.GetPlayerID(source)
    return Framework.Core.GetPlayerFromId(source).getIdentifier()
end

return Framework.Functions