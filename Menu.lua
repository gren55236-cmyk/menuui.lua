-- Psycho FiveM Menu - Fixed for Susano API
-- Black theme with sidebar, rounded corners, and custom header

local Menu = {
    isOpen = false,
    currentTab = 1,
    selectedIndex = 1,
    scrollOffset = 0,
    maxVisible = 10,
    searchQuery = "",
    
    -- Menu tabs
    tabs = {"Vehicle Spawner", "Player", "Teleport", "Events", "Settings"},
    
    -- Colors - Black Theme
    colors = {
        bg = {10, 10, 10, 245},
        sidebar = {18, 18, 18, 255},
        accent = {147, 51, 234, 255}, -- Purple accent
        text = {255, 255, 255, 255},
        textDim = {140, 140, 140, 255},
        hover = {35, 35, 35, 255},
        selected = {147, 51, 234, 180},
        border = {40, 40, 40, 255},
    },
    
    -- Vehicle categories
    vehicles = {
        {category = "Super Cars", items = {"adder", "t20", "zentorno", "osiris", "entityxf"}},
        {category = "Sports Cars", items = {"elegy", "jester", "massacro", "carbonizzare", "banshee"}},
        {category = "SUVs", items = {"granger", "baller", "patriot", "rocoto", "dubsta"}},
        {category = "Motorcycles", items = {"bati", "akuma", "lectro", "vader", "hakuchou"}},
        {category = "Emergency", items = {"police", "police2", "sheriff", "ambulance", "firetruk"}},
    },
    currentCategory = 1,
    
    -- Teleport locations
    teleportLocations = {
        {name = "Los Santos Airport", x = -1336.0, y = -3044.0, z = 13.9},
        {name = "Mount Chiliad", x = 501.8, y = 5604.5, z = 797.9},
        {name = "Military Base", x = -2047.0, y = 3132.0, z = 32.8},
        {name = "Maze Bank Tower", x = -75.0, y = -818.0, z = 326.0},
        {name = "Beach", x = -1376.0, y = -1514.0, z = 4.4},
        {name = "Casino", x = 925.0, y = 46.0, z = 81.1},
    },
    
    -- Player states
    godMode = false,
    invisibility = false,
    superJump = false,
    fastRun = false,
    
    -- Events log
    events = {},
    maxEvents = 50,
    
    -- Settings
    settings = {
        menuKey = 166, -- F5
        fontSize = 14,
        sidebarWidth = 180,
        contentWidth = 420,
        menuHeight = 600,
        cornerRadius = 8,
        spacing = 12,
    },
    
    -- Header texture
    headerTexture = nil,
    mainFont = nil,
    titleFont = nil,
}

-- Initialize fonts and textures
function Menu:Init()
    -- Load fonts - Note: Susano may not support external font loading
    -- Using default font for now
    self.mainFont = 0
    self.titleFont = 0
    
    -- Load header image from URL
    -- Note: LoadTexture may not work with direct GitHub URLs
    -- You'll need to host the image on a proper CDN or use a direct image link
    -- self.headerTexture = Susano.LoadTexture("direct_image_url_here")
end

-- Add event to log
function Menu:LogEvent(eventName, data)
    table.insert(self.events, 1, {
        name = eventName,
        data = data or "No data",
        time = os.date("%H:%M:%S")
    })
    if #self.events > self.maxEvents then
        table.remove(self.events, self.maxEvents + 1)
    end
end

-- Toggle menu
function Menu:Toggle()
    self.isOpen = not self.isOpen
    if self.isOpen then
        self:LogEvent("Menu Opened", "User opened the menu")
    end
end

-- Draw helper functions
function Menu:DrawBox(x, y, w, h, color)
    Susano.DrawRectFilled(x, y, w, h, color[1]/255, color[2]/255, color[3]/255, color[4]/255)
end

function Menu:DrawRoundedBox(x, y, w, h, color, radius)
    -- Susano doesn't have native rounded rectangles, so we'll approximate
    -- Main rect
    Susano.DrawRectFilled(x + radius, y, w - radius * 2, h, color[1]/255, color[2]/255, color[3]/255, color[4]/255)
    Susano.DrawRectFilled(x, y + radius, radius, h - radius * 2, color[1]/255, color[2]/255, color[3]/255, color[4]/255)
    Susano.DrawRectFilled(x + w - radius, y + radius, radius, h - radius * 2, color[1]/255, color[2]/255, color[3]/255, color[4]/255)
    
    -- Corners (approximated with circles)
    Susano.DrawCircle(x + radius, y + radius, radius, color[1]/255, color[2]/255, color[3]/255, color[4]/255, true)
    Susano.DrawCircle(x + w - radius, y + radius, radius, color[1]/255, color[2]/255, color[3]/255, color[4]/255, true)
    Susano.DrawCircle(x + radius, y + h - radius, radius, color[1]/255, color[2]/255, color[3]/255, color[4]/255, true)
    Susano.DrawCircle(x + w - radius, y + h - radius, radius, color[1]/255, color[2]/255, color[3]/255, color[4]/255, true)
end

function Menu:DrawText(text, x, y, color, fontSize)
    local size = fontSize or self.settings.fontSize
    Susano.DrawText(x, y, text, size, color[1]/255, color[2]/255, color[3]/255, color[4]/255)
end

function Menu:DrawButton(text, x, y, w, h, isSelected, rightText)
    local bgColor = isSelected and self.colors.selected or self.colors.bg
    self:DrawRoundedBox(x, y, w, h, bgColor, self.settings.cornerRadius)
    
    if isSelected then
        self:DrawRoundedBox(x, y, 4, h, self.colors.accent, 2)
    end
    
    self:DrawText(text, x + 15, y + (h - self.settings.fontSize) / 2 + 1, self.colors.text)
    
    if rightText then
        local textW = Susano.GetTextWidth(rightText, self.settings.fontSize)
        self:DrawText(rightText, x + w - textW - 15, y + (h - self.settings.fontSize) / 2 + 1, self.colors.textDim)
    end
end

function Menu:DrawToggle(x, y, state)
    local toggleW = 45
    local toggleH = 24
    local bgColor = state and {147, 51, 234, 255} or {60, 60, 60, 255}
    
    -- Background
    self:DrawRoundedBox(x, y, toggleW, toggleH, bgColor, 12)
    
    -- Circle
    local circleX = state and (x + toggleW - 20) or (x + 4)
    self:DrawRoundedBox(circleX, y + 4, 16, 16, {255, 255, 255, 255}, 8)
end

-- Get screen resolution
function Menu:GetScreenResolution()
    -- FiveM native to get screen resolution
    local _, x, y = GetActiveScreenResolution()
    return x, y
end

-- Main render function
function Menu:Render()
    if not self.isOpen then return end
    
    Susano.BeginFrame()
    
    local screenW, screenH = self:GetScreenResolution()
    local totalWidth = self.settings.sidebarWidth + self.settings.contentWidth
    local menuX = (screenW - totalWidth) / 2
    local menuY = (screenH - self.settings.menuHeight) / 2
    local h = self.settings.menuHeight
    
    -- Drop shadow
    self:DrawBox(menuX + 6, menuY + 6, totalWidth, h, {0, 0, 0, 120})
    
    -- Main background
    self:DrawBox(menuX, menuY, totalWidth, h, self.colors.bg)
    
    -- Header
    if self.headerTexture then
        Susano.DrawImage(self.headerTexture, menuX, menuY, totalWidth, 80)
    else
        self:DrawBox(menuX, menuY, totalWidth, 80, {20, 20, 20, 255})
        self:DrawText("PSYCHO MENU", menuX + 20, menuY + 30, self.colors.text, 20)
    end
    
    -- Sidebar
    local sidebarX = menuX
    local sidebarY = menuY + 80
    local sidebarH = h - 80
    
    self:DrawBox(sidebarX, sidebarY, self.settings.sidebarWidth, sidebarH, self.colors.sidebar)
    
    -- Sidebar tabs
    local tabHeight = 50
    local tabY = sidebarY + self.settings.spacing
    
    for i, tab in ipairs(self.tabs) do
        local isActive = self.currentTab == i
        
        if isActive then
            self:DrawRoundedBox(sidebarX + 8, tabY, self.settings.sidebarWidth - 16, tabHeight, self.colors.accent, self.settings.cornerRadius)
        end
        
        local textColor = isActive and self.colors.text or self.colors.textDim
        local fontSize = isActive and 16 or self.settings.fontSize
        self:DrawText(tab, sidebarX + 20, tabY + (tabHeight - fontSize) / 2, textColor, fontSize)
        
        tabY = tabY + tabHeight + self.settings.spacing
    end
    
    -- Content area
    local contentX = menuX + self.settings.sidebarWidth
    local contentY = menuY + 80
    local contentW = self.settings.contentWidth
    local contentH = h - 80
    
    -- Render tab content
    if self.currentTab == 1 then
        self:RenderVehicleSpawner(contentX, contentY, contentW, contentH)
    elseif self.currentTab == 2 then
        self:RenderPlayer(contentX, contentY, contentW, contentH)
    elseif self.currentTab == 3 then
        self:RenderTeleport(contentX, contentY, contentW, contentH)
    elseif self.currentTab == 4 then
        self:RenderEvents(contentX, contentY, contentW, contentH)
    elseif self.currentTab == 5 then
        self:RenderSettings(contentX, contentY, contentW, contentH)
    end
    
    Susano.SubmitFrame()
end

-- Vehicle Spawner Tab
function Menu:RenderVehicleSpawner(x, y, w, h)
    local sp = self.settings.spacing
    local itemHeight = 40
    local yOffset = y + sp + 10
    
    self:DrawText("CATEGORIES", x + sp + 5, yOffset, self.colors.textDim, 16)
    yOffset = yOffset + 30
    
    -- Category buttons
    for i, cat in ipairs(self.vehicles) do
        local isSelected = self.currentCategory == i
        self:DrawButton(cat.category, x + sp, yOffset, w - sp * 2, itemHeight, isSelected)
        yOffset = yOffset + itemHeight + sp
    end
    
    yOffset = yOffset + 15
    self:DrawText("VEHICLES", x + sp + 5, yOffset, self.colors.textDim, 16)
    yOffset = yOffset + 30
    
    -- Vehicle list
    local currentCat = self.vehicles[self.currentCategory]
    if currentCat then
        for i, vehicle in ipairs(currentCat.items) do
            if yOffset + itemHeight < y + h - sp then
                local isSelected = self.selectedIndex == i and self.currentTab == 1
                self:DrawButton(vehicle:upper(), x + sp, yOffset, w - sp * 2, itemHeight, isSelected)
                yOffset = yOffset + itemHeight + sp
            end
        end
    end
end

-- Player Tab
function Menu:RenderPlayer(x, y, w, h)
    local sp = self.settings.spacing
    local itemHeight = 45
    local yOffset = y + sp + 10
    
    self:DrawText("PLAYER OPTIONS", x + sp + 5, yOffset, self.colors.textDim, 16)
    yOffset = yOffset + 30
    
    local options = {
        {name = "God Mode", state = self.godMode, key = "godMode"},
        {name = "Invisibility", state = self.invisibility, key = "invisibility"},
        {name = "Super Jump", state = self.superJump, key = "superJump"},
        {name = "Fast Run", state = self.fastRun, key = "fastRun"},
    }
    
    for i, opt in ipairs(options) do
        local isSelected = self.selectedIndex == i and self.currentTab == 2
        self:DrawButton(opt.name, x + sp, yOffset, w - sp * 2 - 60, itemHeight, isSelected)
        
        -- Toggle switch
        self:DrawToggle(x + w - sp - 50, yOffset + 10, opt.state)
        
        yOffset = yOffset + itemHeight + sp
    end
    
    yOffset = yOffset + 20
    self:DrawText("HEALTH & ARMOR", x + sp + 5, yOffset, self.colors.textDim, 16)
    yOffset = yOffset + 30
    
    local isHealthSelected = self.selectedIndex == 5 and self.currentTab == 2
    self:DrawButton("Restore Health", x + sp, yOffset, w - sp * 2, itemHeight, isHealthSelected)
    yOffset = yOffset + itemHeight + sp
    
    local isArmorSelected = self.selectedIndex == 6 and self.currentTab == 2
    self:DrawButton("Restore Armor", x + sp, yOffset, w - sp * 2, itemHeight, isArmorSelected)
end

-- Teleport Tab
function Menu:RenderTeleport(x, y, w, h)
    local sp = self.settings.spacing
    local itemHeight = 40
    local yOffset = y + sp + 10
    
    self:DrawText("LOCATIONS", x + sp + 5, yOffset, self.colors.textDim, 16)
    yOffset = yOffset + 30
    
    for i, loc in ipairs(self.teleportLocations) do
        if yOffset + itemHeight < y + h - sp * 2 - itemHeight then
            local isSelected = self.selectedIndex == i and self.currentTab == 3
            local coords = string.format("%.0f, %.0f, %.0f", loc.x, loc.y, loc.z)
            self:DrawButton(loc.name, x + sp, yOffset, w - sp * 2, itemHeight, isSelected, coords)
            yOffset = yOffset + itemHeight + sp
        end
    end
    
    yOffset = y + h - sp - itemHeight - 10
    local isSaveSelected = self.selectedIndex == (#self.teleportLocations + 1) and self.currentTab == 3
    self:DrawButton("+ Save Current Position", x + sp, yOffset, w - sp * 2, itemHeight, isSaveSelected)
end

-- Events Tab
function Menu:RenderEvents(x, y, w, h)
    local sp = self.settings.spacing
    local yOffset = y + sp + 10
    
    self:DrawText("EVENT LOG (" .. #self.events .. ")", x + sp + 5, yOffset, self.colors.textDim, 16)
    yOffset = yOffset + 30
    
    if #self.events == 0 then
        self:DrawText("No events logged yet", x + sp + 5, yOffset + 50, self.colors.textDim)
    else
        for i = 1, math.min(#self.events, 8) do
            if yOffset + 60 < y + h - sp * 2 - 50 then
                local event = self.events[i]
                
                self:DrawRoundedBox(x + sp, yOffset, w - sp * 2, 55, self.colors.sidebar, self.settings.cornerRadius)
                
                self:DrawText(event.name, x + sp + 12, yOffset + 8, self.colors.text, 16)
                self:DrawText(event.time, x + w - sp - 70, yOffset + 8, self.colors.accent)
                self:DrawText(event.data, x + sp + 12, yOffset + 30, self.colors.textDim)
                
                yOffset = yOffset + 60
            end
        end
    end
    
    yOffset = y + h - sp - 45 - 10
    local isClearSelected = self.selectedIndex == 1 and self.currentTab == 4
    self:DrawButton("Clear Log", x + sp, yOffset, w - sp * 2, 45, isClearSelected)
end

-- Settings Tab
function Menu:RenderSettings(x, y, w, h)
    local sp = self.settings.spacing
    local itemHeight = 45
    local yOffset = y + sp + 10
    
    self:DrawText("MENU SETTINGS", x + sp + 5, yOffset, self.colors.textDim, 16)
    yOffset = yOffset + 30
    
    local settings = {
        {name = "Menu Key", value = "F5"},
        {name = "Accent Color", value = "Purple"},
        {name = "Font Size", value = tostring(self.settings.fontSize)},
        {name = "Corner Radius", value = tostring(self.settings.cornerRadius)},
    }
    
    for i, setting in ipairs(settings) do
        local isSelected = self.selectedIndex == i and self.currentTab == 5
        self:DrawButton(setting.name, x + sp, yOffset, w - sp * 2, itemHeight, isSelected, setting.value)
        yOffset = yOffset + itemHeight + sp
    end
    
    yOffset = yOffset + 30
    self:DrawText("ABOUT", x + sp + 5, yOffset, self.colors.textDim, 16)
    yOffset = yOffset + 30
    
    self:DrawText("Psycho Menu v1.0", x + sp + 5, yOffset, self.colors.text)
    yOffset = yOffset + 25
    self:DrawText("Built with Susano API", x + sp + 5, yOffset, self.colors.textDim)
end

-- Input handling
function Menu:HandleInput()
    -- Use FiveM's IsControlJustPressed for F5 (key 166)
    if IsControlJustPressed(0, self.settings.menuKey) then
        self:Toggle()
    end
    
    if not self.isOpen then return end
    
    -- Tab switching with number keys (1-5)
    for i = 1, #self.tabs do
        if IsControlJustPressed(0, 156 + i) then -- Number keys
            self.currentTab = i
            self.selectedIndex = 1
        end
    end
    
    -- Navigation
    if IsControlJustPressed(0, 172) then -- Up arrow
        self.selectedIndex = math.max(1, self.selectedIndex - 1)
    elseif IsControlJustPressed(0, 173) then -- Down arrow
        self.selectedIndex = self.selectedIndex + 1
    end
    
    -- Selection/Enter
    if IsControlJustPressed(0, 201) then -- Enter
        self:HandleSelection()
    end
end

-- Handle menu selections
function Menu:HandleSelection()
    if self.currentTab == 1 then -- Vehicle Spawner
        if self.selectedIndex <= #self.vehicles then
            self.currentCategory = self.selectedIndex
        else
            local currentCat = self.vehicles[self.currentCategory]
            local vehicleIndex = self.selectedIndex - #self.vehicles
            if currentCat and currentCat.items[vehicleIndex] then
                local vehicle = currentCat.items[vehicleIndex]
                self:LogEvent("Vehicle Spawned", vehicle)
                -- Spawn vehicle
                local playerPed = PlayerPedId()
                local coords = GetEntityCoords(playerPed)
                local heading = GetEntityHeading(playerPed)
                RequestModel(GetHashKey(vehicle))
                while not HasModelLoaded(GetHashKey(vehicle)) do
                    Wait(0)
                end
                local veh = CreateVehicle(GetHashKey(vehicle), coords.x + 2, coords.y + 2, coords.z, heading, true, false)
                SetPedIntoVehicle(playerPed, veh, -1)
            end
        end
    elseif self.currentTab == 2 then -- Player
        if self.selectedIndex == 1 then
            self.godMode = not self.godMode
            SetPlayerInvincible(PlayerId(), self.godMode)
            self:LogEvent("God Mode", self.godMode and "Enabled" or "Disabled")
        elseif self.selectedIndex == 2 then
            self.invisibility = not self.invisibility
            SetEntityVisible(PlayerPedId(), not self.invisibility, 0)
            self:LogEvent("Invisibility", self.invisibility and "Enabled" or "Disabled")
        elseif self.selectedIndex == 3 then
            self.superJump = not self.superJump
            self:LogEvent("Super Jump", self.superJump and "Enabled" or "Disabled")
        elseif self.selectedIndex == 4 then
            self.fastRun = not self.fastRun
            self:LogEvent("Fast Run", self.fastRun and "Enabled" or "Disabled")
        elseif self.selectedIndex == 5 then
            SetEntityHealth(PlayerPedId(), 200)
            self:LogEvent("Health Restored", "Full health")
        elseif self.selectedIndex == 6 then
            SetPedArmour(PlayerPedId(), 100)
            self:LogEvent("Armor Restored", "Full armor")
        end
    elseif self.currentTab == 3 then -- Teleport
        local loc = self.teleportLocations[self.selectedIndex]
        if loc then
            SetEntityCoords(PlayerPedId(), loc.x, loc.y, loc.z, false, false, false, true)
            self:LogEvent("Teleport", loc.name)
        elseif self.selectedIndex == (#self.teleportLocations + 1) then
            local coords = GetEntityCoords(PlayerPedId())
            table.insert(self.teleportLocations, {
                name = "Saved Location " .. (#self.teleportLocations + 1),
                x = coords.x,
                y = coords.y,
                z = coords.z
            })
            self:LogEvent("Location Saved", string.format("%.0f, %.0f, %.0f", coords.x, coords.y, coords.z))
        end
    elseif self.currentTab == 4 then -- Events
        self.events = {}
        self:LogEvent("Event Log Cleared", "All events removed")
    end
end

-- Main loop
CreateThread(function()
    Menu:Init()
    
    -- Enable overlay for Susano drawing
    Susano.EnableOverlay(true)
    
    while true do
        Menu:HandleInput()
        Menu:Render()
        
        -- Apply Super Jump
        if Menu.superJump then
            SetSuperJumpThisFrame(PlayerId())
        end
        
        -- Apply Fast Run
        if Menu.fastRun then
            SetRunSprintMultiplierForPlayer(PlayerId(), 1.49)
        end
        
        Wait(0)
    end
end)
