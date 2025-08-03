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
    local angle = math.random() * math.pi * 2
    local offsetX = math.cos(angle) * radius
    local offsetY = math.sin(angle) * radius
    return vector3(baseCoords.x + offsetX, baseCoords.y + offsetY, baseCoords.z)
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
    DoScreenFadeOut(500)
    Wait(600)
    DoScreenFadeIn(500)

    
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

function Functions.Fixtargets()
    -- Ensure all targets are set up correctly
    local ped
    local tCount = 0
    local speedMul = Config.speed.runSpeed 
    local runSpeedMul = Config.speed.runSpeed
    local wanderArea = Config.Locations.center.coords
    local radius = Config.Locations.center.radius
    for i,pedN in pairs(Config.targets) do
        ped = pedN.details.ped
        print("fixing ped: ".. ped)
        if ped and DoesEntityExist(ped) then
            SetBlockingOfNonTemporaryEvents(ped, true)
            SetPedFleeAttributes(ped, 0, false) -- disable natural fleeing
            SetPedCombatAttributes(ped, 17, true) -- ignore threats
            SetPedCombatAttributes(ped, 46, true) -- keep running even if shot

            -- No ragdoll or weapon drops
            SetPedCanRagdoll(ped, false)
            SetEntityInvincible(ped, false)
            SetPedDropsWeaponsWhenDead(ped, false)
            
            -- Free to run in the battlezone area
            FreezeEntityPosition(ped, false)
            TaskWanderInArea(ped, wanderArea.x, wanderArea.y, wanderArea.z, radius, 10.0, 10.0)
            SetPedMoveRateOverride(ped, speedMul)
            SetRunSprintMultiplierForPlayer(ped, runSpeedMul)
        end


    end
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
                        TriggerEvent("sg-aimlabs:initializeTraining")
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
    print("in target spawn")    
    local data = Config.targets[targetID]
    local model = data.details.model
    local coords = Functions.GetRandomPositionAround()
    local heading = Functions.GetRandomHeading()

    RequestModel(model)
    while not HasModelLoaded(model) do Wait(10) end

    local ped = CreatePed(4, model, coords.x, coords.y, coords.z, heading, true, true)
    data.details.ped = ped

    FreezeEntityPosition(ped, false)
    SetBlockingOfNonTemporaryEvents(ped, true)
    SetEntityInvincible(ped, false)
    SetPedFleeAttributes(ped, 0, false)
    SetPedCombatAttributes(ped, 17, true)
    SetPedCombatAttributes(ped, 46, true)
    SetPedDropsWeaponsWhenDead(ped, false)
    SetPedCanRagdoll(ped, false)

    local center = Config.Locations.center.coords
    local radius = Config.Locations.center.radius
    local speedMul = Config.speed.tSpeed or 2.5

    TaskWanderInArea(ped, center.x, center.y, center.z, radius, 10.0, 10.0)
    SetPedMoveRateOverride(ped, speedMul)
    SetRunSprintMultiplierForPlayer(ped, speedMul)

    print("[sg-aimlabs] Spawned target: " .. tostring(targetID))
end


