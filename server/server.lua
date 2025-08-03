-- Load QBCore
local QBCore = exports['qb-core']:GetCoreObject()


local pedSpawned = false

-- When a player loads in
RegisterNetEvent('QBCore:Server:PlayerLoaded', function()
    local src = source
    if not pedSpawned then
        TriggerClientEvent('sg-aimlabs:spawnPed', src)
        pedSpawned = true
        print("[sg-aimlabs] Ped spawn triggered on first player.")
    end
end)
