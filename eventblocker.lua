-- QBCore Standalone Event Blocker Script big booty cheeks - aqu

QBCore = exports['qb-core']:GetCoreObject()

-- List of forbidden events
local forbiddenEvents = {
    'eventName1', -- replace with actual event names
    'eventName2',
    -- add more events as needed
}

-- Function to handle forbidden event detection
local function handleForbiddenEvent(eventName, playerId)
    local Player = QBCore.Functions.GetPlayer(playerId)
    if not Player then return end

    local steamIdentifier = Player.PlayerData.steam
    local tokens = {}
    for i = 0, GetNumPlayerTokens(playerId) - 1 do
        table.insert(tokens, GetPlayerToken(playerId, i))
    end

    if not steamIdentifier then
        print("[ERROR] Steam identifier not found for player " .. GetPlayerName(playerId))
        return
    end

    local reason = "Triggered forbidden event: " .. eventName
    local query = 'INSERT INTO `bans` (`tokens`, `reason`, `steamName`, `time`) VALUES (?, ?, ?, ?)'
    local params = {json.encode(tokens), reason, GetPlayerName(playerId), os.date("%Y-%m-%d %H:%M:%S")}

    exports.oxmysql:execute(query, params, function(affectedRows)
        if affectedRows > 0 then
            DropPlayer(playerId, ':warning: You have been banned from the server.\nReason: ' .. reason)
            print(('[^2INFO^7] Player ^5%s^7 banned for "%s"'):format(GetPlayerName(playerId), reason))
        else
            print("[ERROR] Failed to insert ban record for player " .. GetPlayerName(playerId))
        end
    end)
end

-- Register event listeners for forbidden events
for _, eventName in ipairs(forbiddenEvents) do
    RegisterNetEvent(eventName)
    AddEventHandler(eventName, function()
        local src = source
        handleForbiddenEvent(eventName, src)
    end)
end

-- Command to add an event to the forbidden list (admin use)
QBCore.Commands.Add('blockevent', 'Block a specific event', {{name = 'eventName', help = 'Name of the event to block'}}, true, function(source, args)
    local eventName = args[1]
    if not eventName then
        TriggerClientEvent('QBCore:Notify', source, 'You must specify an event name', 'error')
        return
    end

    if not forbiddenEvents[eventName] then
        table.insert(forbiddenEvents, eventName)
        TriggerClientEvent('QBCore:Notify', source, 'Event "' .. eventName .. '" has been blocked', 'success')
    else
        TriggerClientEvent('QBCore:Notify', source, 'Event "' .. eventName .. '" is already blocked', 'error')
    end
end, 'admin')

-- Command to remove an event from the forbidden list (admin use)
QBCore.Commands.Add('unblockevent', 'Unblock a specific event', {{name = 'eventName', help = 'Name of the event to unblock'}}, true, function(source, args)
    local eventName = args[1]
    if not eventName then
        TriggerClientEvent('QBCore:Notify', source, 'You must specify an event name', 'error')
        return
    end

    for i, event in ipairs(forbiddenEvents) do
        if event == eventName then
            table.remove(forbiddenEvents, i)
            TriggerClientEvent('QBCore:Notify', source, 'Event "' .. eventName .. '" has been unblocked', 'success')
            return
        end
    end

    TriggerClientEvent('QBCore:Notify', source, 'Event "' .. eventName .. '" is not blocked', 'error')
end, 'admin')