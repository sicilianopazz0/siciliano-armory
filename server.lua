ESX = exports['es_extended']:getSharedObject()

local lastEquipRequest = {}  -- Memorizziamo l'ultimo tempo di richiesta per ogni giocatore

-- Funzione per inviare un log a Discord con il colore specifico
function sendLogToDiscord(action, playerName, playerId, steamName, color, time)
    local embedData = {
        {
            ["color"] = color,
            ["title"] = "Log Equipaggiamento",
            ["description"] = string.format("**Azione:** %s\n**Nome In-Game:** %s\n**ID:** %d\n**Steam/ID TXAdmin:** %s\n**Ora:** %s", action, playerName, playerId, steamName, time),
            ["footer"] = {
                ["text"] = "Sistema Equipaggiamento"
            },
            ["timestamp"] = time
        }
    }

    PerformHttpRequest(Config.Discord.webhookURL, function(err, text, headers) end, 'POST', json.encode({embeds = embedData}), {['Content-Type'] = 'application/json'})
end

-- Function to check if player has required job
local function HasRequiredJob(source, job)
    local xPlayer = ESX.GetPlayerFromId(source)
    return xPlayer and xPlayer.job.name == job
end

-- Function to check cooldown
local function CheckCooldown(source)
    local currentTime = os.time()
    if lastEquipRequest[source] then
        local timeElapsed = currentTime - lastEquipRequest[source]
        if timeElapsed < 3600 then
            return false, math.ceil((3600 - timeElapsed) / 60)
        end
    end
    return true, 0
end

-- Function to give equipment to player
local function GiveEquipment(source, job)
    local xPlayer = ESX.GetPlayerFromId(source)
    if not xPlayer then return false end

    local equipment = Config.Equipaggiamento[job]
    if not equipment then return false end

    local canGive = true
    local missingItems = {}

    -- Check inventory space first
    for _, item in ipairs(equipment) do
        if not xPlayer.canCarryItem(item.item, item.quantity) then
            canGive = false
            table.insert(missingItems, item.label)
        end
    end

    if not canGive then
        TriggerClientEvent('esx:showNotification', source, Config.Messages.no_space)
        return false
    end

    -- Give items
    for _, item in ipairs(equipment) do
        xPlayer.addInventoryItem(item.item, item.quantity)
    end

    -- Update cooldown
    lastEquipRequest[source] = os.time()

    -- Send Discord log
    local playerName = xPlayer.getName()
    local playerId = xPlayer.source
    local steamName = GetPlayerName(source)
    local time = os.date('%Y-%m-%d %H:%M:%S', os.time())
    sendLogToDiscord('Richiesta Equipaggiamento - ' .. job, playerName, playerId, steamName, Config.Discord.colors.success, time)

    return true
end

-- Function to remove equipment from player
local function RemoveEquipment(source, job)
    local xPlayer = ESX.GetPlayerFromId(source)
    if not xPlayer then return false end

    local equipment = Config.Equipaggiamento[job]
    if not equipment then return false end

    local hasAllItems = true
    for _, item in ipairs(equipment) do
        if xPlayer.getInventoryItem(item.item).count < item.quantity then
            hasAllItems = false
            break
        end
    end

    if not hasAllItems then
        TriggerClientEvent('esx:showNotification', source, 'Non hai tutti gli oggetti da restituire!')
        return false
    end

    -- Remove items
    for _, item in ipairs(equipment) do
        xPlayer.removeInventoryItem(item.item, item.quantity)
    end

    -- Reset cooldown
    lastEquipRequest[source] = nil

    -- Send Discord log
    local playerName = xPlayer.getName()
    local playerId = xPlayer.source
    local steamName = GetPlayerName(source)
    local time = os.date('%Y-%m-%d %H:%M:%S', os.time())
    sendLogToDiscord('Posa Equipaggiamento - ' .. job, playerName, playerId, steamName, Config.Discord.colors.warning, time)

    return true
end

-- Event handler for getting equipment
RegisterNetEvent('lspd_armory:getEquipment')
AddEventHandler('lspd_armory:getEquipment', function(job)
    local source = source
    
    if not HasRequiredJob(source, job) then
        TriggerClientEvent('esx:showNotification', source, Config.Messages.error)
        return
    end

    local canRequest, remainingTime = CheckCooldown(source)
    if not canRequest then
        TriggerClientEvent('esx:showNotification', source, string.format("⏳ Devi aspettare ancora %d minuti prima di richiedere l'equipaggiamento.", remainingTime))
        return
    end

    if GiveEquipment(source, job) then
        TriggerClientEvent('esx:showNotification', source, Config.Messages.success)
    end
end)

-- Event handler for returning equipment
RegisterNetEvent('lspd_armory:returnEquipment')
AddEventHandler('lspd_armory:returnEquipment', function(job)
    local source = source
    
    if not HasRequiredJob(source, job) then
        TriggerClientEvent('esx:showNotification', source, Config.Messages.error)
        return
    end

    if RemoveEquipment(source, job) then
        TriggerClientEvent('esx:showNotification', source, 'Hai restituito il tuo equipaggiamento!')
    end
end)

-- Comando /resetequip
RegisterCommand('resetequip', function(source, args, rawCommand)
    local xPlayer = ESX.GetPlayerFromId(source)
    
    if not xPlayer then return end

    -- Verifica se il giocatore ha il grado di polizia sopra 7
    if xPlayer.job.name == 'police' and xPlayer.job.grade >= 7 then
        -- Verifica che sia stato passato un ID valido
        if args[1] then
            local targetId = tonumber(args[1])
            if targetId then
                local targetPlayer = ESX.GetPlayerFromId(targetId)
                if targetPlayer then
                    -- Reset del timer per il target
                    lastEquipRequest[targetId] = nil

                    -- Notifica al giocatore che ha usato il comando
                    TriggerClientEvent('esx:showNotification', source, 'Hai resettato il timer dell\'equipaggiamento per il giocatore ID: ' .. targetId)

                    -- Notifica al giocatore target
                    TriggerClientEvent('esx:showNotification', targetId, 'Il tuo timer per richiedere l\'equipaggiamento è stato resettato da un poliziotto.')

                    -- Ottieni nome e ID del giocatore
                    local playerName = xPlayer.getName()
                    local playerId = xPlayer.source
                    local steamName = GetPlayerName(source)
                    local time = os.date('%Y-%m-%d %H:%M:%S', os.time())

                    -- Invia il log su Discord con il colore rosso
                    sendLogToDiscord('Reset Timer Equipaggiamento', playerName, playerId, steamName, Config.Discord.colors.error, time)
                else
                    TriggerClientEvent('esx:showNotification', source, 'Giocatore non trovato.')
                end
            else
                TriggerClientEvent('esx:showNotification', source, 'ID non valido.')
            end
        else
            TriggerClientEvent('esx:showNotification', source, 'Usa il comando come: /resetequip [ID].')
        end
    else
        TriggerClientEvent('esx:showNotification', source, 'Non hai il permesso di usare questo comando.')
    end
end, false)
