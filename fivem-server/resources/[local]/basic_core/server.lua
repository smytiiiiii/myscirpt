local function broadcast(color, author, message)
    TriggerClientEvent('chat:addMessage', -1, {
        color = color,
        multiline = true,
        args = { author, message }
    })
end

AddEventHandler('playerJoining', function()
    local name = GetPlayerName(source)
    print(('[basic_core] %s a rejoint le serveur'):format(name))
    broadcast({ 0, 200, 0 }, 'Serveur', ('%s a rejoint le serveur.'):format(name))
end)

AddEventHandler('playerDropped', function(reason)
    local name = GetPlayerName(source)
    print(('[basic_core] %s a quitté le serveur (%s)'):format(name, reason))
    broadcast({ 200, 120, 0 }, 'Serveur', ('%s a quitté le serveur (%s).'):format(name, reason))
end)

-- /announce <message> : réservé aux admins (voir les add_ace dans server.cfg)
RegisterCommand('announce', function(_, args)
    local message = table.concat(args, ' ')
    if message == '' then return end
    broadcast({ 255, 80, 80 }, 'ANNONCE', message)
end, true)
