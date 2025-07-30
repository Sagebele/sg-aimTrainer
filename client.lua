-- Load QBCore
local QBCore = exports['qb-core']:GetCoreObject()
local pedSpawned = false
local killCount = 0

local pedModel = Config.Locations.MainNpc.model
local pedCoords = Config.Locations.MainNpc.coords
local pedHeading = Config.Locations.MainNpc.heading
local EXIT_KEY = Config.exitKey or 322 -- Default to 322 if not set in config

-------------------------
--- Functions
-------------------------
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
    local tCount = 0
    local speedMul = Config.speed.runSpeed or 1.5
    local runSpeedMul = Config.speed.runSpeed or 1.2

    for i,pedN in pairs(Config.targets) do
        ped = pedN.details.ped
        print("fixing ped: ".. ped)
        if ped and DoesEntityExist(ped) then
            SetBlockingOfNonTemporaryEvents(ped, true)
            SetPedCanRagdoll(ped, false)
            SetEntityInvincible(ped, false) --can be shot
            SetPedDropsWeaponsWhenDead(ped, false)
            FreezeEntityPosition(ped, false) -- Unfreeze the ped
            -- Make them run immediately
            TaskWanderStandard(ped, 10.0, 10)
            SetPedMoveRateOverride(ped, speedMul)
            SetRunSprintMultiplierForPlayer(ped, runSpeedMul) 
        end


    end
end

function GetRandomPositionAround()
    local angle = math.random() * math.pi * 2 -- random angle in radians
    local radius = Config.Locations.center.radius or 5.0 -- Default radius if not set
    local baseCoords = Config.Locations.center.coords
    local offsetX = math.cos(angle) * radius
    local offsetY = math.sin(angle) * radius

    -- Return a new vector3, keeping the same Z (height)
    return vector3(baseCoords.x + offsetX, baseCoords.y + offsetY, baseCoords.z)
end


-------------------------------------
----- Event Handlers
-------------------------------------

RegisterNetEvent('sg-aimlabs:spawnPed', function()
    
    SpawnPed()
end)

RegisterNetEvent("sg-aimlabs:client:openUi", function()
    SetNuiFocus(true, true)
    SendNUIMessage({
        type = "ui",
        status = true,
        config = Config
    })

end)



RegisterNetEvent('sg-aimlabs:initializeTraining', function()
    TriggerEvent('sg-aimlabs:spawnTargets', source)
    Spawncam()
    -- Message to open the UI
    TriggerEvent('sg-aimlabs:client:openUi', source)

end)
------------------------------------------
------------------------------------------
--- NUI Callbacks
RegisterNUICallback('Start', function(data, cb)
    print('Start clicked with option: ' .. (data.option or 'none'))
    SendNUIMessage({ 
        type = 'hideUI', 
        status = false,
    })
    SetNuiFocus(false, false)
    cb(
        print("[sg-aimlabs] Have fun training!"),
        TriggerEvent("sg-aimlabs:endTrainerCam"),
        TriggerEvent('sg-aimlabs:playing')
    )
end)

RegisterNUICallback('changeOption', function(data, cb)

        print("[sg-aimlabs] Changing Options. to " .. data.option)


end)

RegisterNUICallback('Exit', function(data, cb)
    SendNUIMessage({ 
        type = 'hideUI',
        status = false
    })
    SetNuiFocus(false, false)
    cb(
        print("[sg-aimlabs] Exiting training..."),
        TriggerEvent('sg-aimlabs:deleteTargets'),
        TriggerEvent("sg-aimlabs:endTrainerCam")
    )
end)

----------------------------------------
RegisterNetEvent('sg-aimlabs:spawnTargets', function()
    
    local targetModel = Config.targets.t1.details.model or "a_m_y_hasjew_01"
    local positions = {}
    local targetHeading = Config.targets.t1.details.heading or 285.92
    local temp = 1

    RequestModel(targetModel)
    while not HasModelLoaded(targetModel) do 
        Wait(10) 
    end

    for _, pos in pairs(Config.targets) do
        pos.coords = GetRandomPositionAround()
        local ped = CreatePed(4, targetModel, pos.coords.x, pos.coords.y, pos.coords.z, 0.0, false, true)
        SetEntityInvincible(ped, true)
        FreezeEntityPosition(ped, true)
        TaskStartScenarioInPlace(ped, "WORLD_HUMAN_HANG_OUT_STREET", 0, true)
        SetBlockingOfNonTemporaryEvents(ped, true)
        pos.details.ped = ped

    end

end)

RegisterNetEvent('sg-aimlabs:deleteTargets', function()
    local counter = 0

    for key, targetData in pairs(Config.targets) do
        local ped = targetData.details.ped
        if ped and DoesEntityExist(ped) then
            DeleteEntity(ped)
            targetData.details.ped = nil
            counter = counter + 1
        else
            print("[sg-aimlabs] Target does not exist or nil: " .. tostring(key))
        end
    end

    if counter == 0 then
        print("[sg-aimlabs] No targets to delete.")
    else
        print("[sg-aimlabs] All targets deleted successfully.")
    end


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

    local tTemp = 1
    local killCount = 0
    local iniCount = 5
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
            Wait(500)        
            print("[sg-aimlabs] Checking targets...")
            for _, Cped in pairs(Config.targets) do
                local currentPed = Cped.details.ped
                if IsPedDeadOrDying(currentPed, true) and currentPed ~= nil then
                    print("[sg-aimlabs] Target killed: " .. currentPed)
                    -- Delete the target
                    DeleteEntity(currentPed)
                    Cped.details.ped = nil
                    
                    killCount = killCount + 1
                    print("[sg-aimlabs] Kill count: " .. killCount)
                end
            end
            if IsControlPressed(0, 73) then 
                    print("[sg-aimlabs] Exiting training...")
                    TriggerEvent('sg-aimlabs:deleteTargets')
                    -- TriggerEvent("sg-aimlabs:endTrainerCam")
                    break
            elseif killCount == iniCount then
                TriggerEvent('sg-aimlabs:spawnTargets')
                Fixtargets()
                iniCount = iniCount + 5
            end
        end
    end)
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
            distance = 2,
        })
    end

end)


