-- Load QBCore
local QBCore = exports['qb-core']:GetCoreObject()


local pedSpawned = false

-- When a player loads in
RegisterNetEvent('QBCore:Server:PlayerLoaded', function()
    local src = source
    if not pedSpawned then
        Functions.SpawnPed()
        pedSpawned = true
        print("[sg-aimlabs] Ped spawn triggered on first player.")
    end
end)


RegisterNetEvent('sg-aimlabs:Server:initializeTraining', function()
    local src = source

    -- Put player in separate bucket
    local ped = GetPlayerPed(src)
    SetEntityRoutingBucket(ped, 1000+ped)
    print(("[sg-aimlabs] Player %s moved to bucket %s"):format(src, 1000+ped))

    -- Tell the client to start the camera and UI
    TriggerClientEvent('sg-aimlabs:startTraining', src)
end)

RegisterNetEvent('sg-aimlabs:Server:EndTraining', function ()
    local src = source

    -- Put player in separate bucket
    local ped = GetPlayerPed(src)
    SetEntityRoutingBucket(ped, 1)
    print(("[sg-aimlabs] Player %s moved to bucket %s"):format(src, 1))

end)