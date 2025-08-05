-- Load QBCore
local QBCore = exports['qb-core']:GetCoreObject()


local pedModel = Config.Locations.MainNpc.model
local pedCoords = Config.Locations.MainNpc.coords
local pedHeading = Config.Locations.MainNpc.heading

local EXIT_KEY = Config.exitKey or 322 -- Default to 322 if not set in config


-------------------------------------
----- Event Handlers
-------------------------------------

RegisterNetEvent("sg-aimlabs:client:openUi", function()
    SetNuiFocus(true, true)
    SendNUIMessage({
        type = "ui",
        status = true,
    })

end)



RegisterNetEvent('sg-aimlabs:startTraining', function()

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
    SendNUIMessage({
        type = "killCounterUpdate",
        value = 0
    })
    SetNuiFocus(false, false)
    cb('ok')

    print("[sg-aimlabs] Have fun training!")
    TriggerEvent("sg-aimlabs:endTrainerCam")
    TriggerEvent('sg-aimlabs:playing')
end)

RegisterNUICallback('changeOption', function(data, cb)

    local distance 
    if data.option == "near" then
        distance = -5
    elseif data.option == "medium" then
        distance = 0
    elseif data.option == "far" then
        distance = 5
    end
    
    if distance then
        Config.Locations.center.coords.x = Config.Locations.center.coords.x + distance
        print("[sg-aimlabs] Training distance set to: " .. distance)
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
    TriggerServerEvent('sg-aimlabs:Server:EndTraining')
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

    SendNUIMessage({
        type = "hideKillCounter"
    })
    TriggerServerEvent('sg-aimlabs:Server:EndTraining')
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

    Functions.EnsureAmmo()
    CreateThread(function()
        while Config.playing do
            Wait(10)        
            for _, v in pairs(Config.targets) do
                if v.details.ped ~= nil and IsPedDeadOrDying(v.details.ped, true) then
                    local currentPed = Config.targets[_].details.ped
                    -- Delete the target
                    if currentPed then 
                        DeleteEntity(currentPed)
                        killCount = killCount + 1
                        SendNUIMessage({
                            type = "killCounterUpdate",
                            value = killCount
                        })
                        Functions.TargetSpawn(_)
                    end
                elseif(v.details.ped == nil and Config.playing) then
                    Functions.TargetSpawn(_) 
                    SetPedMoveRateOverride(Config.targets[_].details.ped, Config.speed.tSpeed)
                else
                    SetPedMoveRateOverride(Config.targets[_].details.ped, Config.speed.tSpeed)
                end
                
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



