-- Load QBCore
local QBCore = exports['qb-core']:GetCoreObject()


local killCount = 0
local pedModel = Config.Locations.MainNpc.model
local pedCoords = Config.Locations.MainNpc.coords
local pedHeading = Config.Locations.MainNpc.heading

local EXIT_KEY = Config.exitKey or 322 -- Default to 322 if not set in config


-------------------------------------
----- Event Handlers
-------------------------------------

RegisterNetEvent('sg-aimlabs:spawnPed', function()
    
    Functions.SpawnPed()
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
    Functions.Spawncam()
    -- Message to open the UI
    TriggerEvent('sg-aimlabs:client:openUi', source)
    Config.playing = true
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
    cb('ok')

    print("[sg-aimlabs] Have fun training!")
    TriggerEvent("sg-aimlabs:endTrainerCam")
    TriggerEvent('sg-aimlabs:playing')
end)

RegisterNUICallback('changeOption', function(data, cb)

    local radius 
    if data.option == "near" then
        radius = 3
    elseif data.option == "medium" then
        radius = 5
    elseif data.option == "far" then
        radius = 10
    end
    
    if radius then
        Config.Locations.center.radius = radius
        print("[sg-aimlabs] Training distance set to: " .. radius)
    end
    cb({'ok'})


end)

RegisterNUICallback('Exit', function(data, cb)
    SendNUIMessage({ 
        type = 'hideUI',
        status = false
    })
    SetNuiFocus(false, false)
    cb('ok')
    print("[sg-aimlabs] Exiting training...")
    TriggerEvent('sg-aimlabs:deleteTargets')
    TriggerEvent("sg-aimlabs:endTrainerCam")
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
        pos.coords = Functions.GetRandomPositionAround()
        local ped = CreatePed(4, targetModel, pos.coords.x, pos.coords.y, pos.coords.z, 0.0, false, true)
        SetEntityInvincible(ped, true)
        FreezeEntityPosition(ped, true)
        TaskStartScenarioInPlace(ped, "WORLD_HUMAN_HANG_OUT_STREET", 0, true)
        SetBlockingOfNonTemporaryEvents(ped, true)
        pos.details.ped = ped

    end

end)

RegisterNetEvent('sg-aimlabs:deleteTargets', function()
    Config.playing = false

    for _, targetData in pairs(Config.targets) do
        print("attempting to delete ".._.." with ped "..Config.targets[_].details.ped)
        local ped = Config.targets[_].details.ped
        if ped and DoesEntityExist(ped) then
            DeleteEntity(ped)
            Config.targets[_].details.ped = nil
        else
            print("[sg-aimlabs] Target does not exist or nil: " .. tostring(_))
        end
    end

    Functions.EnsureAmmo()
    Functions.UpdatePedTargetOptions()

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
    Config.playing = true
    Functions.UpdatePedTargetOptions()

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
    Functions.Fixtargets()
    Functions.EnsureAmmo()
    CreateThread(function()
        while Config.playing do
            if not Config.playing then break end
            Wait(100)        
            for _, v in pairs(Config.targets) do
                if v.details.ped ~= nil and IsPedDeadOrDying(v.details.ped, true) then
                    local currentPed = Config.targets[_].details.ped
                    -- Delete the target
                    if currentPed then 
                        DeleteEntity(currentPed)
                        killCount = killCount + 1
                        print("[sg-aimlabs] Kill count: " .. killCount)
                        Functions.TargetSpawn(_)
                    else
                        print("error in playing")
                    end
                    
                elseif(v.details.ped == nil)  then
                    
                    RequestModel(v.details.model)
                    while not HasModelLoaded(v.details.model) do
                        Wait(10)
                    end
                    local newCoords = Functions.GetRandomPositionAround()
                    local head = Functions.GetRandomHeading()
                    local area = Config.Locations.center.coords
                    local ped = CreatePed(4, v.details.model, newCoords.x, newCoords.y, newCoords.z, head, true, true)
                    local rad = Config.Locations.center.radius
                    v.details.ped = ped
                    SetPedFleeAttributes(ped, 0, true)
                    SetPedCombatAttributes(ped, 17, true)
                    SetPedCombatAttributes(ped, 46, true)
                    SetPedCanRagdoll(ped, false)
                    SetEntityInvincible(ped, false)
                    SetPedDropsWeaponsWhenDead(ped, false)
                    FreezeEntityPosition(ped, false)
                    TaskWanderInArea(ped, area.x, area.y, area.z, rad, 10.0, 10.0)
                    SetPedMoveRateOverride(ped, 2.5)
                    SetRunSprintMultiplierForPlayer(ped, 2.5)
                else
                    print("error creating ..".._)    
                end
                
            end
            if IsControlPressed(0, 73) then 
                print("[sg-aimlabs] Exiting training...")
                TriggerEvent('sg-aimlabs:deleteTargets')
                break
            end
        end
    end)
end)

CreateThread(function()
    while true do
        Wait(3000)
        if not Config.ped or not DoesEntityExist(Config.ped) then
            print("[sg-aimlabs] Ped missing, respawning...")
            Functions.SpawnPed()
        end

    end

end)



