Config = {}
Config.Debug = false -- Set to true if you want to see debug messages
Config.VersionCheck = true -- Set to false if you don't want console notifications when update is available

Config.Framework = "esx"
--[[
    Supported Frameworks:
        • esx | https://github.com/esx-framework/esx-legacy
        • qb | https://github.com/qbcore-framework/qb-core
]]

Config.FrameworkEvents = { -- Change these events if you changed their name in your framework script
    esx = { 
        resource_name = 'es_extended',
        main = 'esx:getSharedObject',
        load = 'esx:playerLoaded',
        job = 'esx:setJob'
    },
    qbcore = { 
        resource_name = 'qb-core',
        main = 'QBCore:GetObject',
        load = 'QBCore:Client:OnPlayerLoaded',
        job = 'QBCore:Client:OnJobUpdate',
        gang = 'QBCore:Client:OnGangUpdate',
    }
}

Config.Target = "ox_target" -- Target script. Leave empty if you want to use 3d text instead
--[[
    Supported Targets:
        • ox_target
        • qb-target
]]

Config.Notifications = "okokNotify" -- Leave empty and edit extra/notify.lua if you want to use other notifications
--[[
    Supported Notifications:
        • esx
        • qb
        • okokNotify
        • pNotify
        • ps-ui
]]

Config.Rewards = { -- Reward list
    -- sum of 'chance' has to be 100
    [1] = {itemName = 'weed', itemLabel = 'Weed', amountMin = 1, amountMax = 5, chance = 25}, -- Normal item
    [2] = {money = 15000, itemLabel = 'Money', amountMin = 10000, amountMax = 15000, chance = 20}, -- Money
    [3] = {black_money = 15000, itemLabel = 'Black Money', amountMin = 10000, amountMax = 15000, chance = 20}, -- Black Money
    [4] = {weapon = "WEAPON_PISTOL", itemLabel = 'Pistol', chance = 10}, -- Weapon
    [5] = {jumpscare = true, itemLabel = 'Jumpscare', chance = 25} -- Jumpscare
}

Config.PumpkinModel = 'jackolantern'
Config.SpawnPumpkinsImmediately = true -- If set to true, first pumpkin will spawn immediately when player joins server
Config.FirstPumpkinWaitTime = 15 -- (in minutes) If Config.SpawnPumpkinsImmediately is set to false then first pumpkin will spawn after this time
Config.TimeBetweenSpawns = 0.1 -- (in minutes) Time between spawning pumpkins

Config.SyncPumpkins = true -- If set to true all players on server will have common synced pumpkins, if set to false then every player will have their own pumpkins
Config.MaxPumpkins = 20 -- Max pumpkins on map

Config.EnableFireParticles = true -- If set to true fire particles will spawn on pumpkin making it more visible from distance
Config.EnableFireworkParticles = true -- If set to true firework will burst when picking up pumpkin
Config.EnableJumpscare = false -- If set to true jumpscare might appear when picking up pumpkin
Config.EnableChatMessage = true -- If set to true chat message will be send to every player on server when someone picked up a pumpkin

Language = {
    ["PICKUP"] = "PICKUP PUMPKIN",
    ["PRESS_TO_PICKUP"] = "PRESS [E] TO PICKUP PUMPKIN",
    ["THIS_IS_NOT_EVENT_PUMPKIN"] = "This is not an event pumpkin!",
    ["SLOW_DOWN"] = "Slow down cowboy!",
    ["YOU_CANT_BE_IN_VEHICLE"] = "Leave vehicle to pickup a pumpkin!"
}

-- ⚠️DON'T TOUCH THIS⚠️
function L(id) if Language[id] then return Language[id] else return "MISSING LOCALE ("..id..")" end end
