Framework.Functions = {}

function Framework.Functions.GetPlayer(source)
    return Framework.Core.GetPlayer(source)
end
function Framework.Functions.GetPlayerID(source)
    return Framework.Core.GetPlayer(source).citizenid
end

function Framework.Functions.GetName(source)
    local fullname = ("%s %s"):format(Framework.Core.GetPlayer(source).PlayerData.charinfo.firstname,Framework.Core.GetPlayer(source).PlayerData.charinfo.lastname)
    return fullname
end

function Framework.Functions.GetSource(source)
    local player = Framework.Functions.GetPlayer(source)
    return player.PlayerData.source
end
return Framework.Functions
