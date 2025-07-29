-- Load QBCore
local QBCore = exports['qb-core']:GetCoreObject()
local pedSpawned = false


local pedModel = Config.Locations.MainNpc.model
local pedCoords = Config.Locations.MainNpc.coords
local pedHeading = Config.Locations.MainNpc.heading
local EXIT_KEY = Config.exitKey or 322 -- Default to 322 if not set in config


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

function Spawncam()
    local cam = CreateCam("DEFAULT_SCRIPTED_CAMERA", true)
    Config.cam = cam
    SetCamCoord(cam, Config.Locations.Camera.coords.x, Config.Locations.Camera.coords.y, Config.Locations.Camera.coords.z)
    PointCamAtCoord(cam, Config.Locations.Camera.lookAt.x, Config.Locations.Camera.lookAt.y, Config.Locations.Camera.lookAt.z)
    SetCamActive(cam, true)
    RenderScriptCams(true, true, 0, true, true)
    print("[sg-aimlabs] Camera created.")

    -- Optional: Freeze player + fade screen
    FreezeEntityPosition(PlayerPedId(), true)
    DoScreenFadeOut(500)
    Wait(600)
    DoScreenFadeIn(500)

    
end

function Fixtargets()
    -- Ensure all targets are set up correctly
    local ped
    for i=1, 3 do
        ped = Config.Locations.targets["t" .. i].details.ped
        if ped and DoesEntityExist(ped) then
            SetBlockingOfNonTemporaryEvents(ped, true)
            SetPedCanRagdoll(ped, true)
            SetEntityInvincible(ped, false) -- 🔥 Now can be shot
            SetPedDropsWeaponsWhenDead(ped, false)
            TaskStandStill(ped, -1)
        end


    end
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
                        TriggerEvent("sg-aimlabs:initializeTraining")
                    end,
                },
            },
            distance = 2.5,
        })
    end

end)

RegisterNetEvent('sg-aimlabs:initializeTraining', function()
    TriggerEvent('sg-aimlabs:spawnTargets', source)
    Spawncam()
    -- Add a way to exit training
    CreateThread(function()
        while true do
            Wait(10)
            if IsControlJustPressed(0, EXIT_KEY) then 
                print("[sg-aimlabs] Exiting training...")
                TriggerEvent('sg-aimlabs:deleteTargets')
                TriggerEvent("sg-aimlabs:endTrainerCam")
                break
            end
            if IsControlJustPressed(0, 191) then 
                print("[sg-aimlabs] Have fun training!")
                TriggerEvent('sg-aimlabs:playing')
                break
            end
        end
        -- TriggerEvent("sg-aimlabs:endTrainerCam")
    end)
end)

RegisterNetEvent('sg-aimlabs:spawnTargets', function()
    
    local targetModel = Config.Locations.targets.t1.details.model or "a_m_y_hasjew_01"
    local positions = {
        Config.Locations.targets.t1.coords,
        Config.Locations.targets.t2.coords,
        Config.Locations.targets.t3.coords,
    }
    local targetHeading = Config.Locations.targets.t1.details.heading or 285.92
    local temp = 1

    RequestModel(targetModel)
    while not HasModelLoaded(targetModel) do 
        Wait(10) 
    end

    for _, pos in ipairs(positions) do
        local ped = CreatePed(4, targetModel, pos.x, pos.y, pos.z, 0.0, false, true)
        
        SetEntityInvincible(ped, true)
        FreezeEntityPosition(ped, true)
        TaskStartScenarioInPlace(ped, "WORLD_HUMAN_HANG_OUT_STREET", 0, true)
        
        Config.Locations.targets["t" .. temp].details.ped = ped
        temp = temp + 1
    end

end)

RegisterNetEvent('sg-aimlabs:deleteTargets', function()
    local targetPeds = {
        Config.Locations.targets.t1.details.ped,
        Config.Locations.targets.t2.details.ped,
        Config.Locations.targets.t3.details.ped,
    }
    local tTemp = 1
    for _, ped in ipairs(targetPeds) do
        if DoesEntityExist(ped) then
            DeleteEntity(ped)
            Config.Locations.targets["t"..tTemp].details.ped = nil
        end

        tTemp = tTemp + 1

    end

    print("[sg-aimlabs] Targets deleted.")
end)


RegisterNetEvent('sg-aimlabs:endTrainerCam', function()
    -- Destroy camera and unfreeze player
    if Config.cam then
        RenderScriptCams(false, true, 500, true, true)
        DoScreenFadeOut(500)
        Wait(600)
        DoScreenFadeIn(500)
        DestroyCam(Config.cam, false)
        Config.cam = nil
        -- Unfreeze player
        FreezeEntityPosition(PlayerPedId(), false)
        print("[sg-aimlabs] Camera destroyed and player unfrozen.")
    end
end)

RegisterNetEvent('sg-aimlabs:playing', function()
    local targets = {
        Config.Locations.targets.t1.details.ped,
        Config.Locations.targets.t2.details.ped,
        Config.Locations.targets.t3.details.ped,
    }
    local tTemp = 1
    local killCount = 0
    if Config.cam then
        RenderScriptCams(false, true, 500, true, true)
        DoScreenFadeOut(500)
        Wait(600)
        DoScreenFadeIn(500)
        DestroyCam(Config.cam, false)
        Config.cam = nil
        -- Unfreeze player
        FreezeEntityPosition(PlayerPedId(), false)
        print("[sg-aimlabs] Camera destroyed and player unfrozen.")
    end
    -- Unfreeze targets
    Fixtargets()
    CreateThread(function()
        while true do
            Wait(1000)        
            print("[sg-aimlabs] Checking targets...")
            for _, Cped in ipairs(targets) do
                if IsPedDeadOrDying(Cped, true) and Cped ~= nil then
                    print("[sg-aimlabs] Target killed: " .. Cped)
                    -- Delete the target
                    DeleteEntity(Cped)
                    Cped = nil
                    Config.Locations.targets["t"..tTemp].details.ped = nil
                    
                    -- killCount = killCount + 1
                    -- print("[sg-aimlabs] Kill count: " .. killCount)
                end
                tTemp = tTemp + 1
            end
            if IsControlPressed(0, 73) then 
                    print("[sg-aimlabs] Exiting training...")
                    TriggerEvent('sg-aimlabs:deleteTargets')
                    -- TriggerEvent("sg-aimlabs:endTrainerCam")
                    break
            -- elseif killCount >= 3 then
            --     print("[sg-aimlabs] All targets killed! Training complete.")
            --     break
            end
            
            tTemp = 1 -- Reset for next check
        end
    end)
end)
