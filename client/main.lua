local QBCore = exports['qb-core']:GetCoreObject()

local displayingIDs = false
local hold = 2


-- functions
local function drawText3D(x, y, z, text, r, g, b)
	SetTextScale(0.5, 0.5)
    SetTextFont(5)
    SetTextProportional(1)
    SetTextColour(r, g, b, 255)
    SetTextEntry("STRING")
    SetTextCentre(true)
    AddTextComponentString(text)
    SetDrawOrigin(x, y, z, 0)
    DrawText(0.0, 0.0)
    local factor = (string.len(text)) / 450
    DrawRect(0.0, 0.0 + 0.018, 0.01 + factor, 0.03, 0, 0, 0, 75)
    ClearDrawOrigin()
end

local function getPlayers()
    local players = {}
    for _, player in ipairs(GetActivePlayers()) do
        local playerPed = GetPlayerPed(player)
        if DoesEntityExist(playerPed) then
            players[#players+1] = player
        end
    end
    return players
end

local function getNearbyPlayers()
    local players = getPlayers()
    local nearbyPlayers = {}
    local playerCoords = GetEntityCoords(PlayerPedId())

    for _, player in pairs(players) do
		local targetPlayer = GetPlayerPed(player)
		local targetPlayerCoords = GetEntityCoords(targetPlayer)
		local targetdistance = #(targetPlayerCoords - vector3(playerCoords.x, playerCoords.y, playerCoords.z))
		if targetdistance <= Config.MaxDistance then
            nearbyPlayers[#nearbyPlayers+1] = player
		end
    end

    return nearbyPlayers
end

-- threads
CreateThread(function()
    while not LocalPlayer.state.isLoggedIn do
        -- do nothing
        Wait(1000)
    end

    while true do
        local ped = PlayerPedId()

        if IsControlReleased(0, Config.ControlID) and displayingIDs then
            displayingIDs = false
            hold = 2
            -- TriggerEvent('dz-qb-holdmap:client:ToggleMap') -- uncomment this if you are using the holdmap resource
        end

        if IsControlPressed(0, Config.ControlID) and hold <= 0 and not displayingIDs then
            displayingIDs = true
            -- TriggerEvent('dz-qb-holdmap:client:ToggleMap') -- uncomment this if you are using the holdmap resource
        end

        if IsControlPressed(0, Config.ControlID) then
            if hold - 1 >= 0 then
                hold = hold - 1
            else
                hold = 0
            end
        end

        if displayingIDs then
            for _, player in pairs(getNearbyPlayers()) do
                local playerID = GetPlayerServerId(player)
                local playerPed = GetPlayerPed(player)
                local playerCoords = GetEntityCoords(playerPed)
                if NetworkIsPlayerTalking(player) then
                    drawText3D(playerCoords.x, playerCoords.y, playerCoords.z + 1.0, playerID, 255, 0, 0)
                elseif ped == playerPed then
                    drawText3D(playerCoords.x, playerCoords.y, playerCoords.z + 1.0, playerID, 0, 255, 0)
                else
                    drawText3D(playerCoords.x, playerCoords.y, playerCoords.z + 1.0, playerID, 255, 255, 255)
                end
            end
        end

        Wait(0)
    end
end)
