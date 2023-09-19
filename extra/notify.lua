-- ⚠️EDIT THIS FILE ONLY IF YOU KNOW WHAT YOU ARE DOING⚠️

function Notify(text, timeout, typ)
    if Config.Notifications == "esx" then
        ESX.ShowNotification(text)
    elseif Config.Notifications == "qb" then
        if typ == 'warning' then
            typ = 'error'
        elseif typ == 'info' then
            typ = 'primary'
        end
        QBCore.Functions.Notify(text, typ)
    elseif Config.Notifications == "okokNotify" then            
        exports['okokNotify']:Alert(L('NOTIFY_TITLE'), text, timeout, typ)
    elseif Config.Notifications == "pNotify" then
        exports['pNotify']:SendNotification({text = text, timeout = timeout, type = typ})
    elseif Config.Notifications == "ps-ui" then
        if typ == 'warning' then
            typ = 'error'
        end
        exports['ps-ui']:Notify(text, typ, timeout)
    elseif Config.Notifications == "ox" then
        if typ == 'warning' then
            typ = 'error'
        end
        lib.notify({
            title = L('NOTIFY_TITLE'),
            description = text,
            type = typ
        })
    end
end