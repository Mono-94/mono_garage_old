Framework.Functions = {}

function Framework.Functions.GetPlayer(source)
    return Framework.Core.GetPlayer(source)
end
function Framework.Functions.GetPlayerID(source)
    return Framework.Core.GetPlayer(source).citizenid
end
return Framework.Functions
