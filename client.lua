local loaded = false
local ped = PlayerPedId()
local coords = GetEntityCoords(ped)
local particleEffects = {}
local lastParticle = 0

local lastPumpkin = 0

local resp = {}

RegisterNetEvent('coachHalloween:sendCoords')
AddEventHandler('coachHalloween:sendCoords', function(coords)
    resp = coords
    loaded = true
end)

RegisterNetEvent('coachHalloween:getSyncedPumpkins')
AddEventHandler('coachHalloween:getSyncedPumpkins', function(pumpkinsServer)
    debugprint('got synced pumpkin data')
    for k, v in pairs(pumpkinsServer) do
        createPumpkinClient(v.netId)
    end
end)

Citizen.CreateThread(function()
    TriggerServerEvent('coachHalloween:requestCoords')
end)

local pumpkins = {}
local timeout = Config.TimeBetweenSpawns * 60 * 1000

if not Config.SyncPumpkins then
    Citizen.CreateThread(function() -- Main spawning thread
        while not loaded do
            Citizen.Wait(100)
        end
        if not Config.SpawnPumpkinsImmediately then
            Citizen.Wait((Config.FirstPumpkinWaitTime * 1000 * 60) or (5 * 60 * 1000))
        end
        while true do
            math.randomseed(GetGameTimer()) 
            coords = resp[math.random(#resp)]
            success = true
            if #pumpkins > 0 then
                if #pumpkins < Config.MaxPumpkins then
                    for k, v in pairs(pumpkins) do
                        if coords == v.coords then
                            timeout = 5
                            success = false
                            break
                        end
                    end
                    if success then
                        timeout = Config.TimeBetweenSpawns * 60 * 1000
                        TriggerEvent('coachHalloween:spawnObject', Config.PumpkinModel, coords)
                    end
                end
            else
                timeout = Config.TimeBetweenSpawns * 60 * 1000
                TriggerEvent('coachHalloween:spawnObject', Config.PumpkinModel, coords)
            end
            Citizen.Wait(timeout)
        end
    end)
end

Citizen.CreateThread(function()
    while true do
        Citizen.Wait(Config.Target == "" and 5 or 1000)
        local particle2 = nil
        letSleep, close = false, false
        local entity, entityDst = GetClosestObjectHere(Config.PumpkinModel)
        if DoesEntityExist(entity) then
            if entityDst <= 10 then
                if GetGameTimer() - lastParticle >= 1700 then
                    for k, v in pairs(particleEffects) do
                        StopParticleFxLooped(v, true)
                        particleEffects = {}
                    end
                    local particleDictionary2 = "scr_impexp_jug"
                    local particleName2 = "scr_ie_jug_mask_flame"
                    if not HasNamedPtfxAssetLoaded(particleDictionary2) then
                        RequestNamedPtfxAsset(particleDictionary2)
                        while not HasNamedPtfxAssetLoaded(particleDictionary2) do
                            Wait(10)
                        end
                    end
                    UseParticleFxAssetNextCall(particleDictionary2)
                    local particle2 = StartParticleFxLoopedOnEntity(particleName2, entity, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 3.0, false, false, false)
                    table.insert(particleEffects, 1, particle2)
                    lastParticle = GetGameTimer()
                end
                if Config.Target == "" then
                    if entityDst < 1.5 then
                        letSleep, close = false, true
                        local ent_coords = GetEntityCoords(entity)
                        if not IsPedInAnyVehicle(ped) then
                            DrawText3Ds(ent_coords, L("PRESS_TO_PICKUP"), 0.4)
                            if IsControlJustPressed(0, 51) then
                                if GetGameTimer() > lastPumpkin + 1500 then
                                    lastPumpkin = GetGameTimer()
                                    for k, v in pairs(pumpkins) do
                                        if v.object == entity then
                                            eventowa = true
                                            local particleDictionary = "proj_indep_firework"
                                            local particleName = "scr_indep_launcher_sparkle_spawn"
                                            local particleDictionary2 = "scr_indep_fireworks"
                                            local particleName2 = "scr_indep_firework_starburst"
                                            local loopAmount = 3
                                            RequestNamedPtfxAsset(particleDictionary)
                                            RequestNamedPtfxAsset(particleDictionary2)

                                            while not HasNamedPtfxAssetLoaded(particleDictionary) do
                                                Citizen.Wait(0)
                                            end
                                            while not HasNamedPtfxAssetLoaded(particleDictionary2) do
                                                Citizen.Wait(0)
                                            end
                                            local particleEffects = {}

                                            for x = 0, loopAmount do
                                                UseParticleFxAssetNextCall(particleDictionary)
                                                local particle = StartParticleFxLoopedOnEntity(particleName, entity, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 3.0, false, false, false)
                                                table.insert(particleEffects, 1, particle)
                                                UseParticleFxAssetNextCall(particleDictionary2)
                                                local particle2 = StartParticleFxLoopedOnEntity(particleName2, entity, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 3.0, false, false, false)
                                                table.insert(particleEffects, 1, particle2)
                                                Citizen.Wait(0)
                                            end
                                            TriggerServerEvent("coachHalloween:losowanie")
                                            PlaySoundFrontend(-1, "CHECKPOINT_PERFECT", "HUD_MINI_GAME_SOUNDSET", 0)
                                            table.remove(pumpkins, k)
                                            DeleteEntity(entity)
                                            Citizen.Wait(100)
                                        end
                                    end
                                    if not eventowa then
                                        Notify(L("THIS_IS_NOT_EVENT_PUMPKIN"), 5000, 'warning')
                                    end
                                else
                                    Notify(L("SLOW_DOWN"), 5000, 'warning')
                                end
                            end
                        else
                            DrawText3Ds(ent_coords, L("YOU_CANT_BE_IN_VEHICLE"), 0.4)
                        end
                    else
                        Citizen.Wait(500)
                    end
                end
            else
                letSleep, close = true, false
            end
            if letSleep and not close then
                Citizen.Wait(500)
            end
        end
    end
end)

function createPumpkinClient(netId)
    debugprint('creating pumpkin with netId: '..netId)
    entity = NetworkGetEntityFromNetworkId(netId)
    if entity > 0 then
        table.insert(pumpkins, {object = entity, coords = GetEntityCoords(entity)})
        if Config.Target == "ox_target" then
            local options = {
                {
                    icon = 'fas fa-ghost',
                    label = L("PICKUP"),
                    distance = 2.0,
                    entity = entity,
                    netId = netId,
                    canInteract = function(entity)
                        return true
                    end,
                    onSelect = function(data)
                        lastPumpkin = GetGameTimer()

                        if Config.EnableFireworkParticles then
                            local particleDictionary = "proj_indep_firework"
                            local particleName = "scr_indep_launcher_sparkle_spawn"
                            local particleDictionary2 = "scr_indep_fireworks"
                            local particleName2 = "scr_indep_firework_starburst"
                            local loopAmount = 3
                            RequestNamedPtfxAsset(particleDictionary)
                            RequestNamedPtfxAsset(particleDictionary2)

                            while not HasNamedPtfxAssetLoaded(particleDictionary) do
                                Citizen.Wait(0)
                            end
                            while not HasNamedPtfxAssetLoaded(particleDictionary2) do
                                Citizen.Wait(0)
                            end
                            local particleEffects = {}

                            for x = 0, loopAmount do
                                UseParticleFxAssetNextCall(particleDictionary)
                                local particle = StartParticleFxLoopedOnEntity(particleName, data.entity, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 3.0, false, false, false)
                                table.insert(particleEffects, 1, particle)
                                UseParticleFxAssetNextCall(particleDictionary2)
                                local particle2 = StartParticleFxLoopedOnEntity(particleName2, data.entity, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 3.0, false, false, false)
                                table.insert(particleEffects, 1, particle2)
                                Citizen.Wait(0)
                            end
                        end
                        TriggerServerEvent("coachHalloween:losowanie", data.netId)
                        PlaySoundFrontend(-1, "CHECKPOINT_PERFECT", "HUD_MINI_GAME_SOUNDSET", 0)
                    end
                }
            }
            exports.ox_target:addLocalEntity(entity, options)
        elseif Config.Target == "qb-target" then
            exports['qb-target']:AddTargetEntity(entity, {
                options = {
                    {
                        icon = 'fas fa-ghost',
                        label = L("PICKUP"),
                        entity = entity,
                        netId = netId,
                        canInteract = function()
                            return true
                        end,
                        action = function(data)
                            lastPumpkin = GetGameTimer()

                            if Config.EnableFireworkParticles then
                                local particleDictionary = "proj_indep_firework"
                                local particleName = "scr_indep_launcher_sparkle_spawn"
                                local particleDictionary2 = "scr_indep_fireworks"
                                local particleName2 = "scr_indep_firework_starburst"
                                local loopAmount = 3
                                RequestNamedPtfxAsset(particleDictionary)
                                RequestNamedPtfxAsset(particleDictionary2)

                                while not HasNamedPtfxAssetLoaded(particleDictionary) do
                                    Citizen.Wait(0)
                                end
                                while not HasNamedPtfxAssetLoaded(particleDictionary2) do
                                    Citizen.Wait(0)
                                end
                                local particleEffects = {}

                                for x = 0, loopAmount do
                                    UseParticleFxAssetNextCall(particleDictionary)
                                    local particle = StartParticleFxLoopedOnEntity(particleName, data, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 3.0, false, false, false)
                                    table.insert(particleEffects, 1, particle)
                                    UseParticleFxAssetNextCall(particleDictionary2)
                                    local particle2 = StartParticleFxLoopedOnEntity(particleName2, data, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 3.0, false, false, false)
                                    table.insert(particleEffects, 1, particle2)
                                    Citizen.Wait(0)
                                end
                            end
                            TriggerServerEvent("coachHalloween:losowanie", netId)
                            PlaySoundFrontend(-1, "CHECKPOINT_PERFECT", "HUD_MINI_GAME_SOUNDSET", 0)
                        end
                    },
                },
                distance = 2.0
            })
        end
    end
end

RegisterNetEvent('coachHalloween:createNewPumpkin')
AddEventHandler('coachHalloween:createNewPumpkin', function(netId)
    createPumpkinClient(netId)
end)

RegisterNetEvent('coachHalloween:spawnObject')
AddEventHandler('coachHalloween:spawnObject', function(model, coords)
    Citizen.CreateThread(function()
        local playerPed = PlayerPedId()
        local model = type(mode) == 'number' and model or joaat(model)
        local vector = type(coords) == "vector3" and coords or vec(coords.x, coords.y, coords.z)
        RequestModel(model)
        while not HasModelLoaded(model) do
            Wait(0)
        end

        obj = CreateObject(model, vector.xyz - vector3(0.0, 0.0, 10.0), false, false, true)
        SetEntityHeading(obj, GetEntityHeading(playerPed))
        SetEntityInvincible(obj, true)
        table.insert(pumpkins, {object = obj, coords = coords})
        if Config.Target == "ox_target" then
            local options = {
                {
                    icon = 'fas fa-ghost',
                    label = L("PICKUP"),
                    distance = 2.0,
                    entity = obj,
                    canInteract = function(entity)
                        return true
                    end,
                    onSelect = function(data)
                        lastPumpkin = GetGameTimer()

                        if Config.EnableFireworkParticles then
                            local particleDictionary = "proj_indep_firework"
                            local particleName = "scr_indep_launcher_sparkle_spawn"
                            local particleDictionary2 = "scr_indep_fireworks"
                            local particleName2 = "scr_indep_firework_starburst"
                            local loopAmount = 3
                            RequestNamedPtfxAsset(particleDictionary)
                            RequestNamedPtfxAsset(particleDictionary2)

                            while not HasNamedPtfxAssetLoaded(particleDictionary) do
                                Citizen.Wait(0)
                            end
                            while not HasNamedPtfxAssetLoaded(particleDictionary2) do
                                Citizen.Wait(0)
                            end
                            local particleEffects = {}

                            for x = 0, loopAmount do
                                UseParticleFxAssetNextCall(particleDictionary)
                                local particle = StartParticleFxLoopedOnEntity(particleName, data.entity, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 3.0, false, false, false)
                                table.insert(particleEffects, 1, particle)
                                UseParticleFxAssetNextCall(particleDictionary2)
                                local particle2 = StartParticleFxLoopedOnEntity(particleName2, data.entity, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 3.0, false, false, false)
                                table.insert(particleEffects, 1, particle2)
                                Citizen.Wait(0)
                            end
                        end
                        TriggerServerEvent("coachHalloween:losowanie")
                        PlaySoundFrontend(-1, "CHECKPOINT_PERFECT", "HUD_MINI_GAME_SOUNDSET", 0)
                        rem(ent)
                        DeleteEntity(data.entity)
                    end
                }
            }
            exports.ox_target:addLocalEntity(obj, options)
        elseif Config.Target == "qb-target" then
            exports['qb-target']:AddTargetEntity(obj, {
                options = {
                    {
                        icon = 'fas fa-ghost',
                        label = L("PICKUP"),
                        entity = obj,
                        canInteract = function()
                            return true
                        end,
                        action = function(data)
                            lastPumpkin = GetGameTimer()

                            if Config.EnableFireworkParticles then
                                local particleDictionary = "proj_indep_firework"
                                local particleName = "scr_indep_launcher_sparkle_spawn"
                                local particleDictionary2 = "scr_indep_fireworks"
                                local particleName2 = "scr_indep_firework_starburst"
                                local loopAmount = 3
                                RequestNamedPtfxAsset(particleDictionary)
                                RequestNamedPtfxAsset(particleDictionary2)

                                while not HasNamedPtfxAssetLoaded(particleDictionary) do
                                    Citizen.Wait(0)
                                end
                                while not HasNamedPtfxAssetLoaded(particleDictionary2) do
                                    Citizen.Wait(0)
                                end
                                local particleEffects = {}

                                for x = 0, loopAmount do
                                    UseParticleFxAssetNextCall(particleDictionary)
                                    local particle = StartParticleFxLoopedOnEntity(particleName, data.entity, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 3.0, false, false, false)
                                    table.insert(particleEffects, 1, particle)
                                    UseParticleFxAssetNextCall(particleDictionary2)
                                    local particle2 = StartParticleFxLoopedOnEntity(particleName2, data.entity, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 3.0, false, false, false)
                                    table.insert(particleEffects, 1, particle2)
                                    Citizen.Wait(0)
                                end
                            end
                            TriggerServerEvent("coachHalloween:losowanie")
                            PlaySoundFrontend(-1, "CHECKPOINT_PERFECT", "HUD_MINI_GAME_SOUNDSET", 0)
                            rem(ent)
                            DeleteEntity(data.entity)
                        end
                    },
                },
                distance = 2.0
            })
        end
    end)
end)

function rem(ent)
    for k, v in pairs(pumpkins) do
        if v.entity == ent then
            table.remove(pumpkins, k)
        end
    end
end

AddEventHandler('onResourceStop', function(resource) --w przypadku restartu skryptu chcemy usunac pumpkins z mapy
	if resource == GetCurrentResourceName() then
		for k, v in pairs(pumpkins) do
			DeleteEntity(v.object)
		end
		pumpkins = {}
	end
end)

RegisterNetEvent('coachHalloween:wpierdol')
AddEventHandler('coachHalloween:wpierdol', function()
    if Config.EnableJumpscare then
        local sound = ''
        math.randomseed(GetGameTimer())
        ran = math.random(1, 6)
        if ran == 1 then
            sound = 'cyrks'
        elseif ran == 2 then
            sound = 'devil_laugh'
        elseif ran == 3 then
            sound = 'dying'
        elseif ran == 4 then
            sound = 'laugh'
        elseif ran == 5 then
            sound = 'penny'
        elseif ran == 6 then
            sound = 'see'
        end
        SendNUIMessage({type = 'playSound', name = sound})
        SetNuiFocus(false, false)
        SendNUIMessage({type = sound})
    end
	AddExplosion(coords.x, coords.y, coords.z, 'EXPLOSION_GRENADE', 15, 1, 0, 1)
	SetEntityHealth(ped, 101)
	SetPedToRagdoll(ped, 5000, 5000, 0, 0, 0, 0)
    if Config.EnableJumpscare then
        Citizen.Wait(5500)
        SendNUIMessage({type = 'closeAll'})
    end
end)

Citizen.CreateThread(function()
    while true do
        Citizen.Wait(200)
        ped = PlayerPedId()
        coords = GetEntityCoords(ped)
    end
end)

function GetClosestObjectHere(model, coords)
    return GetClosestEntityHere(GetGamePool('CObject'), false, coords, model)
end

function GetClosestEntityHere(entities, isPlayerEntities, coords, modelFilter)
    local closestEntity, closestEntityDistance, filteredEntities = -1, -1, nil

    if coords then
        coords = vector3(coords.x, coords.y, coords.z)
    else
        local playerPed = PlayerPedId()
        coords = GetEntityCoords(playerPed)
    end

    if modelFilter then
        filteredEntities = {}

        for k, entity in pairs(entities) do
            if GetHashKey(modelFilter) == GetEntityModel(entity) then
                filteredEntities[#filteredEntities + 1] = entity
            end
        end
    end

    for k, entity in pairs(filteredEntities or entities) do
        local distance = #(coords - GetEntityCoords(entity))

        if closestEntityDistance == -1 or distance < closestEntityDistance then
            closestEntity, closestEntityDistance = isPlayerEntities and k or entity, distance
        end
    end

    return closestEntity, closestEntityDistance
end

function DrawText3Ds(coords, text)
    x,y,z = table.unpack(coords)
	SetTextScale(0.35, 0.35)
    SetTextFont(4)
    SetTextProportional(1)
    SetTextColour(255, 255, 255, 215)
    SetTextEntry("STRING")
    SetTextCentre(true)
    AddTextComponentString(text)
    SetDrawOrigin(x,y,z, 0)
    DrawText(0.0, 0.0)
    local factor = (string.len(text)) / 370
    DrawRect(0.0, 0.0+0.0125, 0.017+ factor, 0.03, 0, 0, 0, 75)
    ClearDrawOrigin()
end

function debugprint(...)
    if Config.Debug then
        local data = {...}
        local str = ""
        for i = 1, #data do
            if type(data[i]) == "table" then
                str = str .. json.encode(data[i])
            elseif type(data[i]) ~= "string" then
                str = str .. tostring(data[i])
            else
                str = str .. data[i]
            end
            if i ~= #data then
                str = str .. " "
            end
        end

        print("^6[coachHalloween] ^3[Debug]^0: " .. str)
    end
end
