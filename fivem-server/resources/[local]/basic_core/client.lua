local function notify(message)
    BeginTextCommandThefeedPost('STRING')
    AddTextComponentSubstringPlayerName(message)
    EndTextCommandThefeedPostTicker(false, true)
end

local function chatMessage(author, message)
    TriggerEvent('chat:addMessage', { color = { 80, 170, 255 }, args = { author, message } })
end

local function deleteVehicle(vehicle)
    SetEntityAsMissionEntity(vehicle, true, true)
    DeleteVehicle(vehicle)
end

-- Message de bienvenue à la première apparition
local hasSpawned = false
AddEventHandler('playerSpawned', function()
    if hasSpawned then return end
    hasSpawned = true
    chatMessage('Serveur', Config.WelcomeMessage)
end)

-- /car [modèle] : fait apparaître un véhicule et met le joueur dedans
RegisterCommand('car', function(_, args)
    local model = args[1] or Config.DefaultVehicle
    local hash = joaat(model)

    if not IsModelInCdimage(hash) or not IsModelAVehicle(hash) then
        notify(('~r~Modèle de véhicule inconnu : %s'):format(model))
        return
    end

    RequestModel(hash)
    local timeout = GetGameTimer() + 5000
    while not HasModelLoaded(hash) do
        if GetGameTimer() > timeout then
            notify('~r~Impossible de charger le modèle.')
            return
        end
        Wait(0)
    end

    local ped = PlayerPedId()
    local current = GetVehiclePedIsIn(ped, false)
    if current ~= 0 then deleteVehicle(current) end

    local coords = GetEntityCoords(ped)
    local vehicle = CreateVehicle(hash, coords.x, coords.y, coords.z, GetEntityHeading(ped), true, false)
    SetVehicleNumberPlateText(vehicle, Config.PlateText)
    SetPedIntoVehicle(ped, vehicle, -1)
    SetEntityAsNoLongerNeeded(vehicle)
    SetModelAsNoLongerNeeded(hash)

    notify(('~g~Véhicule créé : %s'):format(model))
end, false)

-- /dv : supprime le véhicule actuel (ou le dernier utilisé s'il est proche)
RegisterCommand('dv', function()
    local ped = PlayerPedId()
    local vehicle = GetVehiclePedIsIn(ped, false)

    if vehicle == 0 then
        local last = GetVehiclePedIsIn(ped, true)
        if last ~= 0 and #(GetEntityCoords(ped) - GetEntityCoords(last)) < 10.0 then
            vehicle = last
        end
    end

    if vehicle == 0 then
        notify('~r~Aucun véhicule à supprimer.')
        return
    end

    deleteVehicle(vehicle)
    notify('~g~Véhicule supprimé.')
end, false)

-- /fix : répare et nettoie le véhicule actuel
RegisterCommand('fix', function()
    local vehicle = GetVehiclePedIsIn(PlayerPedId(), false)
    if vehicle == 0 then
        notify('~r~Tu dois être dans un véhicule.')
        return
    end
    SetVehicleFixed(vehicle)
    SetVehicleDirtLevel(vehicle, 0.0)
    notify('~g~Véhicule réparé.')
end, false)

-- /heal : vie et armure au maximum
RegisterCommand('heal', function()
    local ped = PlayerPedId()
    SetEntityHealth(ped, GetEntityMaxHealth(ped))
    SetPedArmour(ped, 100)
    ClearPedBloodDamage(ped)
    notify('~g~Soigné.')
end, false)

-- /tpm : téléportation sur le point de passage de la carte
RegisterCommand('tpm', function()
    local blip = GetFirstBlipInfoId(8)
    if not DoesBlipExist(blip) then
        notify('~r~Place un point de passage sur la carte.')
        return
    end

    local target = GetBlipInfoIdCoord(blip)
    local ped = PlayerPedId()
    local entity = IsPedInAnyVehicle(ped, false) and GetVehiclePedIsIn(ped, false) or ped

    FreezeEntityPosition(entity, true)
    for z = 0.0, 1000.0, 25.0 do
        SetEntityCoordsNoOffset(entity, target.x, target.y, z, false, false, false)
        RequestCollisionAtCoord(target.x, target.y, z)
        Wait(0)
        local found, groundZ = GetGroundZFor_3dCoord(target.x, target.y, z, false)
        if found then
            SetEntityCoordsNoOffset(entity, target.x, target.y, groundZ + 1.0, false, false, false)
            break
        end
    end
    FreezeEntityPosition(entity, false)
    notify('~g~Téléporté.')
end, false)

-- /coords : affiche la position actuelle (pratique pour créer des scripts)
RegisterCommand('coords', function()
    local ped = PlayerPedId()
    local c = GetEntityCoords(ped)
    local text = ('vector4(%.2f, %.2f, %.2f, %.2f)'):format(c.x, c.y, c.z, GetEntityHeading(ped))
    chatMessage('Coords', text)
    print(text)
end, false)

-- /aide : liste des commandes
RegisterCommand('aide', function()
    chatMessage('Aide', '/car [modèle], /dv, /fix, /heal, /tpm, /coords')
end, false)

-- Suggestions dans le chat
CreateThread(function()
    TriggerEvent('chat:addSuggestion', '/car', 'Faire apparaître un véhicule', {
        { name = 'modèle', help = 'ex : adder, zentorno, t20 (par défaut : ' .. Config.DefaultVehicle .. ')' }
    })
    TriggerEvent('chat:addSuggestion', '/dv', 'Supprimer le véhicule')
    TriggerEvent('chat:addSuggestion', '/fix', 'Réparer le véhicule')
    TriggerEvent('chat:addSuggestion', '/heal', 'Se soigner')
    TriggerEvent('chat:addSuggestion', '/tpm', 'Se téléporter au point de passage')
    TriggerEvent('chat:addSuggestion', '/coords', 'Afficher sa position')
    TriggerEvent('chat:addSuggestion', '/aide', 'Liste des commandes')
end)
