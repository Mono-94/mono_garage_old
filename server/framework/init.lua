Framework = setmetatable({}, {
    __newindex = function(self, key, value)
        rawset(self, key, value)
    end,
    __index = function(self, value)
        return rawget(self, value)
    end
})

function Framework:Init()
    if GetResourceState("qb-core") == "started" then
        Framework.Core = exports["qb-core"]:GetCoreObject()
        Framework:GetData()
        lib.require "client.framework.qb"
    end
    if GetResourceState("es_extended") == "started" then
        Framework.Core = exports["es_extended"]:getSharedObject()
        Framework:GetData()
        lib.require "client.framework.esx"
    end
end

function Framework:GetData()
    Framework.Player = Framework.Core.GetPlayerData()
end
