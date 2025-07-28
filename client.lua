-- Load QBCore
local QBCore = exports['qb-core']:GetCoreObject()
local pedSpawned = false


local pedModel = Config.Locations.MainNpc.model
local pedCoords = Config.Locations.MainNpc.coords
local pedHeading = Config.Locations.MainNpc.heading



function SpawnPed()
    if pedSpawned then return end -- Prevent duplicate
    pedSpawned = true

    RequestModel(pedModel)
    while not HasModelLoaded(pedModel) do
        Wait(10)
    end

    local ped = CreatePed(4, pedModel, pedCoords.x, pedCoords.y, pedCoords.z, pedHeading, true, true)
    Config.ped = ped
    print(Config.ped)

    FreezeEntityPosition(ped, true)
    SetEntityInvincible(ped, true)
    SetBlockingOfNonTemporaryEvents(ped, true)


    local netId = NetworkGetNetworkIdFromEntity(ped)
    SetNetworkIdExistsOnAllMachines(netId, true)
    SetNetworkIdCanMigrate(netId, false)

    print("[sg-aimlabs] Ped created and synced.")
end

RegisterNetEvent('sg-aimlabs:spawnPed', function()
    
    SpawnPed()
end)



CreateThread(function()
    while true do
        Wait(10000)
        if not Config.ped or not DoesEntityExist(Config.ped) then
            print("[sg-aimlabs] Ped missing, respawning...")
            SpawnPed()
        end
        exports['qb-target']:AddTargetEntity(Config.ped, {
            options = {
                {
                    label = "Start Aimlabs",
                    icon = "fas fa-crosshairs",
                    action = function()
                        TriggerEvent("sg-aimlabs:startTraining")
                    end,
                },
            },
            distance = 2.5,
        })
    end

end)

RegisterNetEvent('sg-aimlabs:startTraining', function()
    
    print("kati")
end)


