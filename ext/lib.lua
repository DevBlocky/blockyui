--[[
  ______ ______ _____
 |  ____|  ____|_   _|
 | |__  | |__    | |
 |  __| |  __|   | |
 | |    | |     _| |_
 |_|    |_|    |_____|


]]
local function getParentResource()
    -- try to find the parent resource name through the fxmanifest
    local res = GetCurrentResourceName()
    local n = GetNumResourceMetadata(res, 'blockyui_resource')
    if n > 0 then
        return GetResourceMetadata(res, 'blockyui_resource')
    end

    -- try it through the replicated convar
    local convar = GetConvar('__blockyui_name', '')
    if #convar > 0 then return convar end

    -- otherwise use default as 'blockyui'
    print('^1WARN: ^7blockyui_resource is not set in fxmanifest.lua')
    return 'blockyui'
end

-- async handler for obtaining the BUI object
local BUI = nil
local function getBui()
    if BUI then
        return promise.new():resolve(BUI)
    end

    local buiRes = getParentResource()
    -- if the resource is already started, then just obtain the object and return the resolved promise
    local d = promise.new()
    local function resolve()
        if BUI == nil then
            BUI = exports[buiRes]:get()
        end
        return d:resolve(BUI)
    end

    if GetResourceState(buiRes) == 'started' then
        return resolve()
    end

    -- blockui resource not started, so await for it to start
    print('^1WARN: ^7BlockyUI is not started!')
    local ev = AddEventHandler('onResourceStart', function(other)
        if other == buiRes then resolve() end
    end)
    return d:next(function(result)
        RemoveEventHandler(ev)
        return result
    end)
end

AddEventHandler('onResourceStop', function(other)
    -- reset the BUI handle if the resource is stopped
    if other == getParentResource() then
        BUI = nil
    end
end)

--[[
  _    _ _______ _____ _       _____
 | |  | |__   __|_   _| |     / ____|
 | |  | |  | |    | | | |    | (___
 | |  | |  | |    | | | |     \___ \
 | |__| |  | |   _| |_| |____ ____) |
  \____/   |_|  |_____|______|_____/


]]
local statics = {
    -- the amount of time b/t control actions when holding it
    -- each index represents the seconds since the control was held
    controlDeltas = { 250, 150, 75, 35 }
}

--[[ Turns the specified value into an accepted inline text value ]]
local function asInline(val)
    if type(val) == 'table' then
        if type(val.type) == 'string' then
            return { val }
        else
            return val
        end
    elseif val == nil then
        return nil
    else
        return { val }
    end
end

--[[ Makes a randomly generated ID ]]
local function makeId()
    local characters = 'ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz0123456789'
    local r = ('xxxxxxxx'):gsub('x', function()
        local i = math.ceil(math.random() * #characters)
        return characters:sub(i, i)
    end)
    return r
end

--[[ Clamps a value between min and max ]]
local function clamp(val, min, max)
    if val < min then
        return min
    elseif val > max then
        return max
    else
        return val
    end
end

--[[ Safely calls the specified function ]]
local function safeCall(fn, ...)
    if type(fn) == 'function' then
        fn(...)
    end
end

--[[ Creates a weak reference to an object ]]
local function weakref(obj)
    local meta = {
        __mode = 'v',
        __call = function(self) return self.real end
    }
    local ref = setmetatable({ real = obj }, meta)
    return ref
end

--[[ Removes all values from a table that match a predicate ]]
local function removeWhere(tbl, fn)
    local i = 1
    while i <= #tbl do
        if fn(tbl[i]) then
            table.remove(tbl, i)
        else
            i = i + 1
        end
    end
end

local function tblConcat(...)
    local inp = { ... }
    local out = {}
    for i = 1, #inp do
        local tbl = inp[i]
        if type(tbl) == 'table' and tbl[1] ~= nil then
            for j = 1, #tbl do table.insert(out, tbl[j]) end
        elseif tbl ~= nil then
            table.insert(out, tbl)
        end
    end
    return out
end

--[[
   _____ ____  _   _ _______ _____   ____  _       _____
  / ____/ __ \| \ | |__   __|  __ \ / __ \| |     / ____|
 | |   | |  | |  \| |  | |  | |__) | |  | | |    | (___
 | |   | |  | | . ` |  | |  |  _  /| |  | | |     \___ \
 | |___| |__| | |\  |  | |  | | \ \| |__| | |____ ____) |
  \_____\____/|_| \_|  |_|  |_|  \_\\____/|______|_____/


]]
local controls = {}
local function testControl(control, opts)
    if type(opts) == 'nil' then opts = {} end
    if type(opts.hold) == 'nil' then opts.hold = true end

    DisableControlAction(0, control, true)
    if IsDisabledControlJustPressed(0, control) then
        -- the control just got pressed, return true and
        if opts.hold then
            controls[control] = { begin = GetGameTimer(), last = GetGameTimer() }
        end
        return true
    elseif IsDisabledControlJustReleased(0, control) then
        -- the control is no longer being held
        controls[control] = nil
    elseif IsDisabledControlPressed(0, control) and controls[control] ~= nil then
        local curTime = GetGameTimer()
        local sinceBegin = curTime - controls[control].begin
        local deltaIndex = clamp(math.floor(sinceBegin / 1000) + 1, 1, #statics.controlDeltas)
        local delta = statics.controlDeltas[deltaIndex]

        if controls[control].last + delta < GetGameTimer() then
            controls[control].last = GetGameTimer()
            return true
        end
    end
    return false
end

--[[
  __  __ ______ _   _ _    _   _____   ____   ____  _
 |  \/  |  ____| \ | | |  | | |  __ \ / __ \ / __ \| |
 | \  / | |__  |  \| | |  | | | |__) | |  | | |  | | |
 | |\/| |  __| | . ` | |  | | |  ___/| |  | | |  | | |
 | |  | | |____| |\  | |__| | | |    | |__| | |__| | |____
 |_|  |_|______|_| \_|\____/  |_|     \____/ \____/|______|


]]
MenuPool = {}
MenuPool.__index = MenuPool

function MenuPool:new()
    -- create the class object
    local pool = {
        -- a table of all menus
        menus = {},
        -- a history of menus in the order they were opened
        history = {},
    }
    setmetatable(pool, MenuPool)
    return pool
end

--[[
    Registers a menu with the pool
]]
function MenuPool:addMenu(menu)
    menu.parent = self
    table.insert(self.menus, menu)
end

--[[
    Removes a menu from the pool, and closes it if open
]]
function MenuPool:removeMenu(menu)
    removeWhere(self.history, function(m) return m == menu end)
    removeWhere(self.menus, function(m) return m == menu end)
    local bui = Citizen.Await(getBui())
    bui.pushMenu(menu.id, nil)
    bui.rerender()
end

--[[
    Returns the currently visible menu (for the pool)
]]
function MenuPool:currentMenu()
    if #self.history > 0 then
        return self.history[#self.history]
    else
        return nil
    end
end

--[[
    Opens the specified menu
    `menu` - the menu to open
    `historical` - whether to keep the previous menu history
]]
function MenuPool:openMenu(menu, historical)
    if historical then
        table.insert(self.history, menu)
    else
        self.history = { menu }
    end
    self:render()
end

--[[
    Closes the currently open menu
    `historical` - if true, then it will act as a "go back" button (to the previous menu)
]]
function MenuPool:closeMenu(historical)
    if historical then
        table.remove(self.history, #self.history)
    else
        self.history = {}
    end
    self:render()
end

--[[
    Binds the specified button to open a menu when selected
    `menu` - The menu to open when the button is selected
    `btn` - The button to bind
]]
function MenuPool:bindMenuToButton(menu, btn)
    local wMenu = weakref(menu)
    btn.onSelect = function()
        local m = wMenu()
        if m then
            self:openMenu(m, true)
        end
    end
end

--[[
    Pushes all menu states to the core
]]
function MenuPool:render()
    local updates = {}
    local bui = Citizen.Await(getBui())

    -- verify that all menus that are not visible are removed
    for _, m in ipairs(self.menus) do
        table.insert(updates, { id = m.id, payload = nil })
    end
    -- render the visible menu and sync with the core
    local curMenu = self:currentMenu()
    if curMenu then
        table.insert(updates, { id = curMenu.id, payload = curMenu:dbg() })
    end
    bui.pushManyMenus(updates)
    bui.rerender()
end

function MenuPool:tick()
    local curMenu = self:currentMenu()
    if curMenu then
        curMenu:tick()
    end
end

--[[
  __  __ ______ _   _ _    _
 |  \/  |  ____| \ | | |  | |
 | \  / | |__  |  \| | |  | |
 | |\/| |  __| | . ` | |  | |
 | |  | | |____| |\  | |__| |
 |_|  |_|______|_| \_|\____/


]]
Menu = {}
Menu.__index = Menu

function Menu:new(title, subtitle)
    local menu = {
        id = makeId(),
        parent = nil,
        title = title,
        subtitle = asInline(subtitle),
        align = 'right',
        buttons = {},
        -- index of the top displayed button
        topOffset = 1,
        -- # of buttons that can be displayed at once
        maxButtons = 10,
        -- index of the selected button
        selected = 1
    }
    setmetatable(menu, Menu)
    return menu
end

-- adds a button to the menu
-- `btn`: the button to add
function Menu:addButton(btn)
    for _, b in ipairs(self.buttons) do
        if b == btn then return end
    end
    table.insert(self.buttons, btn)
    table.insert(btn.parents, self)
    self:render()
end

-- returns currently selected button
function Menu:getSelectedButton()
    return self.buttons[self.selected]
end

--[[ INTERNAL FUNCTION ]]
function Menu:render()
    if self:getVisible() then
        self.parent:render()
    end
end

--[[ INTERNAL FUNCTION ]]
function Menu:dbg()
    local buttons = {}
    for i = 1, #self.buttons do
        if i >= self.topOffset and i < self.topOffset + self.maxButtons then
            table.insert(buttons, self.buttons[i]:dbg(i == self.selected))
        end
    end
    local sBtn = self.buttons[self.selected]
    return {
        id = self.id,
        title = self.title,
        subtitle = self.subtitle,
        align = self.align,
        buttons = buttons,
        desc = sBtn and sBtn:getDesc()
    }
end

--[[ INTERNAL FUNCTION ]]
function Menu:adjustTop()
    if self.selected < self.topOffset then
        -- selected button is above the top
        self.topOffset = self.selected
    elseif self.selected >= self.topOffset + self.maxButtons then
        -- selected button is below the bottom
        self.topOffset = self.selected - self.maxButtons + 1
    end
    self.topOffset = clamp(self.topOffset, 1, #self.buttons)
end

-- sets the selected index of the menu
-- * `index`: the new index of the menu
function Menu:setIndex(index)
    self.selected = clamp(index, 1, #self.buttons)
    self:adjustTop()
    self:render()
end

-- relatively changed the index of the menu
-- * `n`: the amount to change the index by (can be negative)
function Menu:scrollMenu(n)
    self:setIndex((self.selected - 1 + n) % #self.buttons + 1)
end

--[[ INTERNAL FUNCTION ]]
function Menu:internalListShift(btn, n)
    if btn.type == 'list' then
        btn:scrollList(n)
        safeCall(self.onListIndexChange, self, btn, btn:getListIndex())
        safeCall(btn.onListIndexChange, self, btn, btn:getListIndex())
    end
end

-- will cause a menu go up action
function Menu:goUp()
    self:scrollMenu(-1)
    PlaySoundFrontend(-1, 'NAV_UP_DOWN', 'HUD_FRONTEND_DEFAULT_SOUNDSET', true)
end

-- will cause a menu go down action
function Menu:goDown()
    self:scrollMenu(1)
    PlaySoundFrontend(-1, 'NAV_UP_DOWN', 'HUD_FRONTEND_DEFAULT_SOUNDSET', true)
end

-- will cause a menu go left action
function Menu:goLeft()
    local btn = self:getSelectedButton()
    self:internalListShift(btn, -1)
    PlaySoundFrontend(-1, 'NAV_LEFT_RIGHT', 'HUD_FRONTEND_DEFAULT_SOUNDSET', true)
end

-- will cause a menu go right action
function Menu:goRight()
    local btn = self:getSelectedButton()
    self:internalListShift(btn, 1)
    PlaySoundFrontend(-1, 'NAV_LEFT_RIGHT', 'HUD_FRONTEND_DEFAULT_SOUNDSET', true)
end

-- will cause a menu select action
function Menu:goSelect()
    local btn = self:getSelectedButton()
    if not btn then return end
    if btn.type == 'checkbox' then
        btn.checked = not btn.checked
        btn:render()
        safeCall(btn.onCheckboxChange, self, btn, btn.checked)
        safeCall(self.onCheckboxChange, self, btn, btn.checked)
    end
    safeCall(btn.onSelect, self, btn)
    safeCall(self.onSelect, self, btn)
    PlaySoundFrontend(-1, 'SELECT', 'HUD_FRONTEND_DEFAULT_SOUNDSET', true)
end

-- will cause a menu back action
function Menu:goBack()
    self.parent:closeMenu(true)
    PlaySoundFrontend(-1, 'BACK', 'HUD_FRONTEND_DEFAULT_SOUNDSET', true)
end

--[[ INTERNAL FUNCTION ]]
function Menu:tick()
    if testControl(172) or testControl(241, { hold = false }) then     -- up arrow / scroll
        self:goUp()
    elseif testControl(173) or testControl(242, { hold = false }) then -- down arrow / scroll
        self:goDown()
    elseif testControl(174) then                                       -- left arrow
        self:goLeft()
    elseif testControl(175) then                                       -- right arrow
        self:goRight()
    end

    -- have the controls separate so that you can do both actions at the same time
    -- kinda like keyboard ghosting
    if testControl(176, { hold = false }) then     -- enter / left click
        self:goSelect()
    elseif testControl(177, { hold = false }) then -- back / right click
        self:goBack()
    end
end

function Menu:getVisible()
    return self.parent:currentMenu() == self
end

function Menu:setVisible(visible)
    if visible then
        self.parent:openMenu(self, false)
    elseif self:getVisible() then
        self.parent:closeMenu(false)
    end
end

function Menu:getTitle()
    return self.title
end

function Menu:setTitle(title)
    self.title = title
    self:render()
end

function Menu:getSubtitle()
    return self.subtitle
end

function Menu:setSubtitle(subtitle)
    self.subtitle = asInline(subtitle)
    self:render()
end

--[[
  ____  _    _ _______ _______ ____  _   _
 |  _ \| |  | |__   __|__   __/ __ \| \ | |
 | |_) | |  | |  | |     | | | |  | |  \| |
 |  _ <| |  | |  | |     | | | |  | | . ` |
 | |_) | |__| |  | |     | | | |__| | |\  |
 |____/ \____/   |_|     |_|  \____/|_| \_|


]]
MenuButton = {}
MenuButton.__index = MenuButton

--[[ INTERNAL FUNCTION ]]
function MenuButton:new(type, text, desc)
    local button = {
        id = makeId(),
        type = type,
        parents = {},
        leftText = asInline(text),
        rightText = nil,
        desc = asInline(desc)
    }
    setmetatable(button, MenuButton)
    return button
end

-- creates a new standard button object. Use `Menu:addButton` to register a button with a menu
-- * `text`: the inline type for the main text
-- * `desc`: the inline type for the description text
function MenuButton:base(text, desc)
    return MenuButton:new('base', text, desc)
end

function MenuButton:checkbox(text, checked, desc)
    local button = MenuButton:new('checkbox', text, desc)
    button.checked = not not checked
    return button
end

function MenuButton:list(text, list, desc)
    local button = MenuButton:new('list', text, desc)
    button:setList(list)
    button.selected = 1
    return button
end

--[[ INTERNAL FUNCTION ]]
function MenuButton:render()
    for i = 1, #self.parents do
        self.parents[i]:render()
    end
end

--[[ INTERNAL FUNCTION ]]
function MenuButton:dbg(selected)
    local rightExtra
    if self.type == 'checkbox' then
        rightExtra = { {
            type = 'icon',
            prefix = self.checked and 'fas' or 'far',
            name = self.checked and 'check-square' or 'square',
            size = '1x'
        } }
    elseif self.type == 'list' then
        local d = self.list[self.selected]
        rightExtra = tblConcat(
            { type = 'icon', prefix = 'fas', name = 'chevron-left', size = 'xs' },
            d or {},
            { type = 'icon', prefix = 'fas', name = 'chevron-right', size = 'xs' }
        )
    end
    return {
        id = self.id,
        left = self.leftText,
        right = tblConcat(self.rightText, rightExtra),
        selected = not not selected
    }
end

-- returns the main text of the button
function MenuButton:getText()
    return self.leftText
end

-- sets the main text of the button
-- * `text`: the inline type to display
function MenuButton:setText(text)
    self.leftText = asInline(text)
    self:render()
end

-- returns the right text of the button
function MenuButton:getRightText()
    return self.rightText
end

-- sets the right text of the button
-- * `text`: the inline type to display
function MenuButton:setRightText(text)
    self.rightText = asInline(text)
    self:render()
end

-- returns the description of the button
function MenuButton:getDesc()
    return self.desc
end

-- sets the description of the button
-- * `desc`: the inline type to display
function MenuButton:setDesc(desc)
    self.desc = asInline(desc)
    self:render()
end

-- returns the table of list items (DO NOT MODIFY)
-- NOTE: only for "list" button types
function MenuButton:getList()
    return self.list
end

-- sets the table of list items
-- NOTE: only for "list" button types
-- * `list`: the table of list items
function MenuButton:setList(list)
    local copy = {}
    for i = 1, #list do
        table.insert(copy, list[i])
    end
    self.list = copy
    self:render()
end

-- returns the current list index
-- NOTE: only for "list" button types
function MenuButton:getListIndex()
    return self.selected
end

-- sets the selected list index
-- NOTE: only for "list" button types
-- * `index`: the new index of the list
function MenuButton:setListIndex(index)
    self.selected = clamp(index, 1, #self.list)
    self:render()
end

-- relatively sets the index of the list
-- NOTE: only for "list" button types
-- * `n`: the amount of shift the list index (can be negative)
function MenuButton:scrollList(n)
    if self.type ~= 'list' then return end
    self:setListIndex((self.selected + n - 1) % #self.list + 1)
end
