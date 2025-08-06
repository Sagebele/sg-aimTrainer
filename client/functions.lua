Functions = {}
-- Load QBCore only once here if needed
local QBCore = exports['qb-core']:GetCoreObject()

-- Random heading
function Functions.GetRandomHeading()
    return math.random() * 360.0
end

-- Random position inside radius
function Functions.GetRandomPositionAround()
    local baseCoords = Config.Locations.center.coords
    local radius = Config.Locations.center.radius or 5.0
    local minDistance = 2.0 -- minimum allowed distance between targets
    local maxAttempts = 10

    for attempt = 1, maxAttempts do
        local angle = math.random() * math.pi * 2
        local offsetX = math.cos(angle) * radius
        local offsetY = math.sin(angle) * radius
        local newPos = vector3(baseCoords.x + offsetX, baseCoords.y + offsetY, baseCoords.z)

        -- Check distance from other spawned targets
        local tooClose = false
        for _, target in pairs(Config.targets) do
            if target.details.ped and DoesEntityExist(target.details.ped) then
                local pedPos = GetEntityCoords(target.details.ped)
                if #(pedPos - newPos) < minDistance then
                    tooClose = true
                    break
                end
            end
        end

        if not tooClose then
            return newPos
        end
    end

    -- If we fail to find a spaced-out spot, just return the last generated one
    return vector3(baseCoords.x + math.cos(0) * radius, baseCoords.y + math.sin(0) * radius, baseCoords.z)
end

function Functions.MakePedRunRandomly(ped)
    local speed = Config.runSpeed
    CreateThread(function()
        while DoesEntityExist(ped) and not IsPedDeadOrDying(ped, true) do
            local targetPos = Functions.GetRandomPositionAround()
            TaskGoToCoordAnyMeans(ped, targetPos.x, targetPos.y, targetPos.z, speed, 0, false, 786603, 0) -- 3.0 = run speed
            Wait(3000) -- wait before picking next position
        end
    end)
end


function Functions.EnsureAmmo()
    local ped = PlayerPedId()
    local weapon = GetSelectedPedWeapon(ped)
    if Config.playing then
        GiveWeaponToPed(ped, weapon, 9999, false, true)
        SetPedInfiniteAmmo(ped, true, weapon)
        SetPedInfiniteAmmoClip(ped, true)
    else
        GiveWeaponToPed(ped, weapon, 0, false, true)
        SetPedInfiniteAmmo(ped, false, weapon)
        SetPedInfiniteAmmoClip(ped, false)
    end 
    
end

function Functions.Spawncam()
    local cam = CreateCam("DEFAULT_SCRIPTED_CAMERA", true)
    Config.cam = cam
    SetCamCoord(cam, Config.Locations.Camera.coords.x, Config.Locations.Camera.coords.y, Config.Locations.Camera.coords.z)
    PointCamAtCoord(cam, Config.Locations.Camera.lookAt.x, Config.Locations.Camera.lookAt.y, Config.Locations.Camera.lookAt.z)
    SetCamActive(cam, true)
    RenderScriptCams(true, true, 0, true, true)
    print("[sg-aimlabs] Camera created.")

    -- Optional: Freeze player + fade screen
    FreezeEntityPosition(PlayerPedId(), true)
    DoScreenFadeOut(300)
    Wait(700)
    DoScreenFadeIn(700)

    
end


function Functions.SpawnPed()
    local pedModel = Config.Locations.MainNpc.model
    local pedCoords = Config.Locations.MainNpc.coords
    local pedHeading = Config.Locations.MainNpc.heading
    if Config.Locations.MainNpc.spawned then 
        return 
    end -- Prevent duplicate
    Config.Locations.MainNpc.spawned = true

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
    Functions.UpdatePedTargetOptions()
end



function Functions.UpdatePedTargetOptions()
    if not Config.ped or not DoesEntityExist(Config.ped) then return end

    -- First, clear all previous target options
    exports['qb-target']:RemoveTargetEntity(Config.ped)


    if Config.playing then
        exports['qb-target']:AddTargetEntity(Config.ped, {
            options = {
                {
                    label = "Stop Training",
                    icon = "fas fa-crosshairs",
                    action = function()
                        TriggerEvent("sg-aimlabs:deleteTargets")
                    end,
                },
            },
            distance = 2.0,
        })
    else
        exports['qb-target']:AddTargetEntity(Config.ped, {
            options = {
                {
                    label = "Start Training",
                    icon = "fas fa-crosshairs",
                    action = function()
                        TriggerServerEvent("sg-aimlabs:Server:initializeTraining")
                        Functions.UpdatePedTargetOptions() 
                    end,
                },
            },
            distance = 2.0,
        })
    end
end

-- Clean spawn logic for targets
function Functions.TargetSpawn(targetID)
    local data = Config.targets[targetID]
    local model = data.details.model
    local coords = Functions.GetRandomPositionAround()
    data.coords = coords
    local heading = Functions.GetRandomHeading()
    data.details.heading = heading
    local radius = Config.Locations.center.radius
    local center = Config.Locations.center.coords

    RequestModel(model)
    while not HasModelLoaded(model) do Wait(10) end

    local ped = CreatePed(4, model, coords.x, coords.y, coords.z, heading, true, true)
    data.details.ped = ped
    
    ClearPedTasksImmediately(ped)
    SetBlockingOfNonTemporaryEvents(ped, true)
    SetPedFleeAttributes(ped, 0, false)
    SetEntityInvincible(ped, false)
    SetPedFleeAttributes(ped, 0, false)
    SetPedCombatAttributes(ped, 17, true) -- Always fight, ignore threats
    SetPedCombatAttributes(ped, 38, true) -- Keep running when shot at
    SetPedCombatAttributes(ped, 46, true) -- Keep running when shot at
    SetPedSeeingRange(ped, 0.0)
    SetPedHearingRange(ped, 0.0)
    SetPedAlertness(ped, 0)
    SetPedDropsWeaponsWhenDead(ped, false)
    SetPedCanRagdoll(ped, false)

    -- Disable collisions with player & other targets
    SetEntityNoCollisionEntity(ped, PlayerPedId(), true)
    for _, otherTarget in pairs(Config.targets) do
        if otherTarget.details.ped and DoesEntityExist(otherTarget.details.ped) then
            SetEntityNoCollisionEntity(ped, otherTarget.details.ped, true)
            SetEntityNoCollisionEntity(otherTarget.details.ped, ped, true)
        end
    end

    Functions.MakePedRunRandomly(ped) -- make them actively running
end


