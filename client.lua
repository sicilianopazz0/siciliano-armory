ESX = exports["es_extended"]:getSharedObject()

-- Variables
local isNearNPC = false
local currentJob = nil
local npcs = {}

-- Create NPCs
Citizen.CreateThread(function()
    for job, npcConfig in pairs(Config.NPC) do
        local model = GetHashKey(npcConfig.model)
        RequestModel(model)
        while not HasModelLoaded(model) do
            Wait(1)
        end

        local ped = CreatePed(4, model, npcConfig.position.x, npcConfig.position.y, npcConfig.position.z - 1.0, npcConfig.heading, false, true)
        SetEntityHeading(ped, npcConfig.heading)
        FreezeEntityPosition(ped, true)
        SetEntityInvincible(ped, true)
        SetBlockingOfNonTemporaryEvents(ped, true)
        
        npcs[job] = ped
    end
end)

-- Check distance from NPCs
Citizen.CreateThread(function()
    while true do
        local sleep = 1000
        local playerPed = PlayerPedId()
        local coords = GetEntityCoords(playerPed)
        local currentJob = ESX.GetPlayerData().job.name
        
        for job, npcConfig in pairs(Config.NPC) do
            local distance = #(coords - vector3(npcConfig.position.x, npcConfig.position.y, npcConfig.position.z))

            if distance < 3.0 then
                sleep = 0
                isNearNPC = true
                
                if currentJob == job then
                    DrawText3D(npcConfig.position.x, npcConfig.position.y, npcConfig.position.z + 1.0, 'Premi [E] per richiedere equipaggiamento\nPremi [G] per restituire equipaggiamento')
                    
                    if IsControlJustReleased(0, 38) then -- E key
                        TriggerServerEvent('lspd_armory:getEquipment', currentJob)
                    elseif IsControlJustReleased(0, 47) then -- G key
                        TriggerServerEvent('lspd_armory:returnEquipment', currentJob)
                    end
                else
                    DrawText3D(npcConfig.position.x, npcConfig.position.y, npcConfig.position.z + 1.0, 'Non hai il permesso di accedere a questo armadio!')
                end
            end
        end

        if not isNearNPC then
            sleep = 1000
        end

        Wait(sleep)
    end
end)

-- Draw 3D text function
function DrawText3D(x, y, z, text)
    local onScreen, _x, _y = World3dToScreen2d(x, y, z)
    local px, py, pz = table.unpack(GetGameplayCamCoords())
    
    SetTextScale(0.35, 0.35)
    SetTextFont(4)
    SetTextProportional(1)
    SetTextColour(255, 255, 255, 215)
    SetTextEntry("STRING")
    SetTextCentre(1)
    AddTextComponentString(text)
    DrawText(_x, _y)
    local factor = (string.len(text)) / 370
    DrawRect(_x, _y + 0.0125, 0.015 + factor, 0.03, 41, 11, 41, 68)
end
