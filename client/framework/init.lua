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
        self.Frame = exports["qb-core"]:GetCoreObject()
        lib.require "client.framework.qb"
        Framework:GetData()
        return
    end
    if GetResourceState("es_extended") == "started" then
        Framework.Core = exports["es_extended"]:getSharedObject()
        lib.require "client.framework.esx"
        Framework:GetData()
        return
    end
end

function Framework:GetData()
    Framework.Player = Framework.Core.GetPlayerData()
end

Framework:Init()
