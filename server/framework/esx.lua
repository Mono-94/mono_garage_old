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

return Framework.Functions