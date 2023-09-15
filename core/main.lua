local BUI = {}
local menus = {}

function BUI.pushMenu(id, payload)
    -- only accept tables or nil
    if type(payload) == 'table' then
        -- keep track of the calling resource, so it can be removed if that resource is stopped
        payload['res'] = GetInvokingResource()
        menus[id] = payload
    elseif type(payload) == 'nil' then
        menus[id] = nil
    end
end

function BUI.pushManyMenus(updates)
    -- only accept tables
    if type(updates) ~= 'table' then error('parameter must be a table') end
    for i = 1, #updates do
        BUI.pushMenu(updates[i].id, updates[i].payload)
    end
end

AddEventHandler('onResourceStop', function(res)
    -- delete all menus that were created by the resource that was just stopped
    -- NOTE: it has to be a bit clunky like this because deleting in the loop below might miss some (thanks lua)
    local toDelete = {}
    for k, v in pairs(menus) do
        if type(v) == 'table' and v['res'] == res then
            table.insert(toDelete, k)
        end
    end
    for i = 1, #toDelete do
        menus[toDelete[i]] = nil
    end
end)

function BUI.rerender()
    -- push all menus to the NUI
    local m = {}
    for _, v in pairs(menus) do
        table.insert(m, v)
    end
    SendNUIMessage({ type = 'render', menus = m })
end

function BUI.numOpenMenus()
    local n = 0
    for _ in pairs(menus) do
        n = n + 1
    end
    return n
end

RegisterNUICallback('ready', function(_, cb)
    BUI.rerender()
    cb('OK')
end)

exports('get', function()
    return BUI
end)
