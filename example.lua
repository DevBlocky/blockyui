Citizen.CreateThread(function()
    local pool = MenuPool:new()

    local mainMenu = Menu:new("Blocky Menu", "Main Menu")
    pool:addMenu(mainMenu)

    for i = 1, 100 do
        local name = 'Button '..i
        local d = math.random(1, 3)
        local btn
        if d == 1 then
            btn = MenuButton:base(name, name)
        elseif d == 2 then
            btn = MenuButton:checkbox(name, math.random(0, 1) == 1, name)
        else
            btn = MenuButton:list(name, {'Option 1', 'Option 2', 'Option 3'}, name)
        end
        mainMenu:addButton(btn)
    end

    while true do
        if IsControlJustPressed(0, 244) then
            mainMenu:setVisible(not mainMenu:getVisible())
        end
        pool:tick()
        Citizen.Wait(0)
    end
end)
