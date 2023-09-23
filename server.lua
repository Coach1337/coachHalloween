ESX = nil
QBCore = nil

local alreadyRequested = {}
local pumpkins = {}
timeout = Config.TimeBetweenSpawns * 60

if Config.Framework == "esx" then
    pcall(function() ESX = exports[Config.FrameworkEvents.esx.resource_name]:getSharedObject() end)
    if ESX == nil then
        TriggerEvent(Config.FrameworkEvents.esx.main, function(obj) ESX = obj end)
    end
elseif Config.Framework == "qb" then
    QBCore = exports["qb-core"]:GetCoreObject()
end

RegisterNetEvent('coachHalloween:losowanie')
AddEventHandler('coachHalloween:losowanie', function(netId)
    local _source = source
    nick = GetPlayerName(_source)

    if netId ~= nil then
        debugprint('trying to delete pumpkin with netId: '..netId)
        ent = NetworkGetEntityFromNetworkId(netId)
        for k, v in pairs(pumpkins) do
            if v.object == ent then
                table.remove(pumpkins, k)
                if ent > 0 then
                    DeleteEntity(ent)
                end
            end
        end
    end

    sum = 0
    draw = {}
    for k, v in pairs(Config.Rewards) do
        for i=1, v.chance do
            if v.itemName then
                table.insert(draw, {item = v.itemName, amount = math.random(v.amountMin, v.amountMax), label = v.itemLabel})
            elseif v.weapon then
                table.insert(draw, {weapon = v.weapon, label = v.itemLabel})
            elseif v.money then
                table.insert(draw, {money = v.money, amount = math.random(v.amountMin, v.amountMax), label = v.itemLabel})
            elseif v.black_money then
                table.insert(draw, {black_money = v.black_money, amount = math.random(v.amountMin, v.amountMax), label = v.itemLabel})
            elseif v.jumpscare then
                table.insert(draw, {jumpscare = true, label = v.itemLabel})
            end
        end
        sum = sum + v.chance
    end
    random = math.random(1, sum)
    reward = draw[random]

    if reward.item then
        if Config.Framework == "esx" then
            xPlayer = ESX.GetPlayerFromId(_source)
            xPlayer.addInventoryItem(reward.item, reward.amount)
        elseif Config.Framework == "qb" then
            local Player = QBCore.Functions.GetPlayer(_source)
            Player.Functions.AddItem(reward.item, 1)
            TriggerClientEvent('inventory:client:ItemBox', _source, QBCore.Shared.Items[reward.item], "add")
        end
    elseif reward.weapon then
        if Config.Framework == "esx" then
            xPlayer = ESX.GetPlayerFromId(_source)
            xPlayer.addInventoryItem(reward.weapon, 1)
        elseif Config.Framework == "qb" then
            local Player = QBCore.Functions.GetPlayer(_source)
            Player.Functions.AddItem(reward.weapon, 1)
            TriggerClientEvent('inventory:client:ItemBox', _source, QBCore.Shared.Items[reward.weapon], "add")
        end
    elseif reward.money then
        if Config.Framework == "esx" then
            xPlayer = ESX.GetPlayerFromId(_source)
            xPlayer.addMoney(reward.amount)
        elseif Config.Framework == "qb" then
            local Player = QBCore.Functions.GetPlayer(_source)
            Player.Functions.AddMoney('cash', reward.amount)
        end
    elseif reward.black_money then
        if Config.Framework == "esx" then
            xPlayer = ESX.GetPlayerFromId(_source)
            xPlayer.addAccountMoney('black_money', reward.amount)
        elseif Config.Framework == "qb" then
            local Player = QBCore.Functions.GetPlayer(_source)
            Player.Functions.AddMoney('blackmoney', reward.amount)
        end
    elseif reward.jumpscare then
        TriggerClientEvent('coachHalloween:wpierdol', _source)
    end
    if Config.EnableChatMessage then
        TriggerClientEvent('chat:addMessage', -1, {
            color = {255, 187, 51},
            multiline = false,
            args = {"🎃 HALLOWEEN", nick..' ^3picked up a pumpkin and got: ^7'..reward.label..' 🎃'}
        })
    end
    debugprint(nick..' ^3picked up a pumpkin and got: ^7'..reward.label..' 🎃')
    logtodc(nick..' picked up a pumpkin and got: '..reward.label..' 🎃')
end)

RegisterNetEvent('coachHalloween:requestCoords')
AddEventHandler('coachHalloween:requestCoords', function()
    local _source = source

    if alreadyRequested[_source] == nil then
        alreadyRequested[_source] = true
        debugprint(GetPlayerName(_source)..' ['.._source..'] requested pumpking spawn coords')
        TriggerClientEvent('coachHalloween:sendCoords', _source, resp)
        if Config.SyncPumpkins then
            debugprint(GetPlayerName(_source)..' ['.._source..'] requested pumpkin sync')
            TriggerClientEvent('coachHalloween:getSyncedPumpkins', _source, pumpkins)
        end
    else
        debugprint(GetPlayerName(_source)..'['.._source..']'..' is trying to access halloween coords again')
        logtodc(GetPlayerName(_source)..'['.._source..']'..' is trying to access halloween coords again')
    end
end)

AddEventHandler('onResourceStop', function(resourceName)
    if GetCurrentResourceName() == resourceName then
        for k, v in pairs(pumpkins) do
            DeleteEntity(v.object)
        end
    end
end)

if Config.SyncPumpkins then
    Citizen.CreateThread(function()
        while true do
            Citizen.Wait(2000)
            math.randomseed(os.time()) 
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
                        spawnPumpkinServer(Config.PumpkinModel, coords)
                    end
                end
            else
                timeout = Config.TimeBetweenSpawns * 60 * 1000
                spawnPumpkinServer(Config.PumpkinModel, coords)
            end
            Citizen.Wait(timeout)
        end
    end)
end

function spawnPumpkinServer(model, coords)
    if #GetPlayers() > 0 then 
        debugprint('spawning pumpkin ['..model..'] on coords '..coords)
        local model = type(mode) == 'number' and model or joaat(model)
        local vector = type(coords) == "vector3" and coords or vec(coords.x, coords.y, coords.z)
        obj = CreateObject(model, vector.xyz - vector3(0.0, 0.0, 10.0), true, true, true)
        while not DoesEntityExist(obj) do
            Citizen.Wait(0)
        end
        SetEntityDistanceCullingRadius(obj, 20000.0)
        debugprint('setting entity ['..obj..'] culling radius to 20000.0')
        table.insert(pumpkins, {object = obj, coords = coords, netId = NetworkGetNetworkIdFromEntity(obj)})
        TriggerClientEvent('coachHalloween:createNewPumpkin', -1, NetworkGetNetworkIdFromEntity(obj))
    else
        debugprint('no players online, waiting...')
    end
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

function logtodc(message)
    if Config.Webhook ~= "" then
        local n = {
            {
                ["color"] = 9803263,
                ["title"] = "coachHalloween - logs",
                ["description"] = message,
                ["footer"] = {
                    ["text"] = os.date("%d-%m-%Y %H:%M:%S")
                }
            }
        }
        PerformHttpRequest(Config.Webhook, function(f, o, h) end, 'POST', json.encode({username="coachHalloween", embeds=n}), {['Content-Type']='application/json'})
    end
end

if Config.VersionCheck then
    Citizen.CreateThread(function()
        Citizen.Wait(5000)
        local function ToNumber(str)
            return tonumber(str)
        end
        local resourceName = GetCurrentResourceName()
        local currentVersion = GetResourceMetadata(resourceName, 'version', 0)
        PerformHttpRequest('https://raw.githubusercontent.com/Coach1337/coachVersions/main/coachHalloween.txt',function(error, result, headers)
            if not result then 
                return print('^1Version check failed, github is down.^0') 
            end
            local result = json.decode(result:sub(1, -2))
            if ToNumber(result.version:gsub('%.', '')) > ToNumber(currentVersion:gsub('%.', '')) then
                local symbols = '^9'
                for cd = 1, 26+#resourceName do
                    symbols = symbols..'-'
                end
                symbols = symbols..'^0'
                print(symbols)
                print('^3['..resourceName..'] - New update available!^0\nCurrent Version: ^1'..currentVersion..'^0.\nNew Version: ^2'..result.version..'^0.\nNews: ^2'..result.news..'^0.\n\n^3Download it now on your keymaster.fivem.net^0.')
                print(symbols)
            end
        end, 'GET')
    end)
end
