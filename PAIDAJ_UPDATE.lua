if game.PlaceId ~= 109983668079237 then
    warn("wrong game")
end

local Players = game:GetService("Players")
local TweenService = game:GetService("TweenService")
local HttpService = game:GetService("HttpService")
local CoreGui = game:GetService("CoreGui")
local UserInputService = game:GetService("UserInputService")
local RunService = game:GetService("RunService")
local Stats = game:GetService("Stats")
local Workspace = game:GetService("Workspace")
local GuiService = game:GetService("GuiService")
local Lighting = game:GetService("Lighting")
local MaterialService = game:GetService("MaterialService")

local HOST_URLS = {
    "wss://66fd0f8d-bce3-46a2-a78d-509f32c43d23-00-131g1m6kxx74f.worf.replit.dev:3000"
}
local currentUrlIndex = 1

local activeGradients = {} 
local function applyAnimatedGradient(obj, colors)
    if not obj then return end
    local grad = Instance.new("UIGradient")
    if type(colors) == "table" then grad.Color = ColorSequence.new(colors) else grad.Color = colors end
    grad.Rotation = 45
    grad.Parent = obj
    table.insert(activeGradients, grad)
    return grad
end

RunService.RenderStepped:Connect(function()
    for _, grad in ipairs(activeGradients) do
        if grad.Parent then 
            grad.Rotation = (grad.Rotation + 0.7) % 360 
        end
    end
end)

local GRADIENT_AQUA = {
    ColorSequenceKeypoint.new(0, Color3.fromRGB(0, 200, 255)),
    ColorSequenceKeypoint.new(0.5, Color3.fromRGB(200, 255, 255)), 
    ColorSequenceKeypoint.new(1, Color3.fromRGB(0, 150, 255))
}
local GRADIENT_FILTERS = {
    ColorSequenceKeypoint.new(0, Color3.fromRGB(0, 255, 255)),
    ColorSequenceKeypoint.new(0.5, Color3.fromRGB(255, 0, 255)),
    ColorSequenceKeypoint.new(1, Color3.fromRGB(100, 0, 255))
}

local function safeParent(gui)
    if gethui then gui.Parent = gethui()
    elseif syn and syn.protect_gui then syn.protect_gui(gui); gui.Parent = CoreGui
    else pcall(function() gui.Parent = CoreGui end) end
end

local function playClickSound()
    task.spawn(function()
        local sound = Instance.new("Sound", workspace)
        sound.SoundId = "rbxassetid://94753039770005"
        sound.Volume = 1
        sound:Play()
        sound.Ended:Wait()
        sound:Destroy()
    end)
end

local BlueBaseConnection = nil
local function toggleBlueBaseFunc(state)
    if not state then
        if BlueBaseConnection then BlueBaseConnection:Disconnect() BlueBaseConnection = nil end
        return
    end

    local function PaintPart(part)
        if part:IsA("BasePart") and part.Transparency < 1 then
            pcall(function()
                part.Color = Color3.fromRGB(0, 255, 255)
                part.Material = Enum.Material.SmoothPlastic
            end)
        end
    end

    local function GetPlayerBase()
        local plots = Workspace:FindFirstChild("Plots")
        if not plots then return nil end
        for _, plot in pairs(plots:GetChildren()) do
            local sign = plot:FindFirstChild("PlotSign")
            if sign and sign:FindFirstChild("YourBase") and sign.YourBase.Enabled then return plot end
            if plot:FindFirstChild("Owner") and plot.Owner.Value == Players.LocalPlayer then return plot end
        end
        return nil
    end

    local myPlot = GetPlayerBase()
    if myPlot then
        for _, obj in pairs(myPlot:GetDescendants()) do PaintPart(obj) end
        BlueBaseConnection = myPlot.DescendantAdded:Connect(function(obj)
            task.wait(0.1)
            PaintPart(obj)
        end)
    end
end

local function ApplyNuclearFFlags()
    local FFlags = {
        ["DFIntTaskSchedulerTargetFps"] = "2147483647",
        ["FFlagDisablePostFx"] = "True",
        ["FIntTextureCompositorLowResFactor"] = "8",
        ["DFFlagDebugRenderForceTechnologyVoxel"] = "True",
        ["FIntRenderShadowIntensity"] = "0",
        ["FFlagGlobalWindActivated"] = "False",
    }
    for flag, value in pairs(FFlags) do
        pcall(function() setfflag(flag, value) end)
    end
end

local function NukeWorld()
    pcall(function()
        settings().Rendering.QualityLevel = 1
        Lighting.GlobalShadows = false
        Lighting.FogEnd = 9e9
        Lighting.Technology = Enum.Technology.Legacy
        workspace.Terrain.WaterWaveSize = 0
        workspace.Terrain.Decoration = false
    end)
    
    local function obliterateObject(v)
        pcall(function()
            if v:IsA("BasePart") then
                v.Material = Enum.Material.Plastic
                v.Reflectance = 0
                v.CastShadow = false
                if v.Material == Enum.Material.Glass then v.Transparency = 1 end
            elseif v:IsA("Decal") or v:IsA("Texture") then
                if not (v.Name == "face" and v.Parent and v.Parent.Name == "Head") then v:Destroy() end
            elseif v:IsA("ParticleEmitter") or v:IsA("Trail") or v:IsA("Beam") or v:IsA("Fire") or v:IsA("Smoke") then
                v:Destroy()
            elseif v:IsA("Sky") or v:IsA("Atmosphere") or v:IsA("PostEffect") then
                v:Destroy()
            end
        end)
    end

    for _, v in ipairs(workspace:GetDescendants()) do obliterateObject(v) end
    workspace.DescendantAdded:Connect(obliterateObject)
    for _, v in ipairs(MaterialService:GetChildren()) do pcall(function() v:Destroy() end) end
end

local function EnableAntiLagCharacters()
    local function stripCharacter(char)
        if not char then return end
        task.wait(0.5)
        pcall(function()
            for _, v in ipairs(char:GetDescendants()) do
                if v:IsA("Accessory") or v:IsA("Shirt") or v:IsA("Pants") or v.ClassName == "LayeredClothing" then
                    v:Destroy()
                end
            end
        end)
    end
    for _, plr in ipairs(Players:GetPlayers()) do
        if plr.Character then stripCharacter(plr.Character) end
        plr.CharacterAdded:Connect(stripCharacter)
    end
    Players.PlayerAdded:Connect(function(plr) plr.CharacterAdded:Connect(stripCharacter) end)
end

local function activateNuclear()
    ApplyNuclearFFlags()
    NukeWorld()
    EnableAntiLagCharacters()
    local BAD = {["Blue"]=true, ["DiscoEffect"]=true, ["BeeBlur"]=true, ["ColorCorrection"]=true}
    Lighting.DescendantAdded:Connect(function(obj)
        if BAD[obj.Name] or obj:IsA("BlurEffect") or obj:IsA("ColorCorrectionEffect") then
            pcall(function() obj:Destroy() end)
        end
    end)
    pcall(function() setfpscap(9999) end)
end

local player = Players.LocalPlayer
local playerGui = player:WaitForChild("PlayerGui")
local SETTINGS_FILE = "JWPriority_Settings.json" 

local function safeGetConnections(sig)
    local ok, res = pcall(function() return getconnections(sig) end)
    if ok and type(res) == "table" then return res end
    return nil
end

local function safeFireSignal(signal)
    if not signal then return false end
    local cons = safeGetConnections(signal)
    if cons then
        for _, c in ipairs(cons) do
            task.spawn(function() 
                if c.Function and type(c.Function) == "function" then pcall(c.Function)
                elseif c.Function and type(c.Function) == "userdata" then pcall(c.Function)
                elseif type(c) == "function" then pcall(c) end
            end)
        end
        return true
    end
    local ok, _ = pcall(function()
        if signal.Fire then signal:Fire()
        elseif signal.Invoke then signal:Invoke()
        elseif signal.Activate then signal:Activate()
        elseif type(signal) == "function" then signal() end
    end)
    return ok
end

local chilliTextbox = nil
local chilliButton = nil

local function ultraFindGUI()
    task.spawn(function()
        while true do
            pcall(function()
                local tempTextbox, tempButton
                local roots = {game:GetService('CoreGui'), playerGui}
                for _, root in ipairs(roots) do
                    local jobIDLabel
                    for _, v in ipairs(root:GetDescendants()) do
                        if v:IsA("TextLabel") and v.Text:match("Job%-ID Input") and v.Parent then
                            jobIDLabel = v; break
                        end
                    end
                    if jobIDLabel then
                        local container = jobIDLabel.Parent.Parent or jobIDLabel.Parent
                        for _, v in ipairs(container:GetDescendants()) do
                            if v:IsA("TextBox") then tempTextbox = v end
                            if tempTextbox then break end
                        end
                        for _, v in ipairs(container:GetDescendants()) do
                            if v:IsA("TextButton") and v.Text:match("Join Job%-ID") then tempButton = v; break end
                        end
                        if not tempButton then
                            for _, v in ipairs(root:GetDescendants()) do
                                if v:IsA("TextButton") and v.Text:match("Join Job%-ID") then tempButton = v; break end
                            end
                        end
                    end
                    if tempTextbox and tempButton then break end
                end
                if tempTextbox and tempButton then chilliTextbox = tempTextbox; chilliButton = tempButton end
            end)
            if chilliTextbox and chilliButton then break end
            task.wait(0.5) 
        end
    end)
end

local function ultraCheckjobid(id)
    if not id or id == "" then return false end
    
    -- Buscar la GUI del Chilli si no esta encontrada
    if not chilliTextbox or not chilliButton then
        pcall(function()
            local roots = {game:GetService('CoreGui'), playerGui}
            for _, root in ipairs(roots) do
                for _, v in ipairs(root:GetDescendants()) do
                    if v:IsA("TextLabel") and v.Text:match("Job%-ID Input") and v.Parent then
                        local container = v.Parent.Parent or v.Parent
                        for _, c in ipairs(container:GetDescendants()) do
                            if c:IsA("TextBox") then chilliTextbox = c end
                        end
                        for _, c in ipairs(container:GetDescendants()) do
                            if c:IsA("TextButton") and c.Text:match("Join Job%-ID") then chilliButton = c; break end
                        end
                    end
                end
                if chilliTextbox and chilliButton then break end
            end
        end)
    end

    if not chilliTextbox or not chilliButton then return false end

    -- Poner el Job ID en el textbox del Chilli
    pcall(function() 
        chilliTextbox.Text = tostring(id)
        if chilliTextbox.FocusLost then safeFireSignal(chilliTextbox.FocusLost) end
    end)

    task.wait(0.1)

    -- Simular el click en el boton del Chilli
    task.spawn(function()
        local events = {chilliButton.Activated, chilliButton.MouseButton1Click, chilliButton.MouseButton1Down}
        for _, event in ipairs(events) do safeFireSignal(event) end
        for _, event in ipairs(events) do
            local connections = safeGetConnections(event)
            if connections then
                for _, con in ipairs(connections) do 
                    if con.Function then task.spawn(function() pcall(con.Function) end) end 
                end
            end
        end
    end)

    return true
end
ultraFindGUI()

local PET_DATABASE = {
    ["Brainrot God"] = {
        "Alessio", "Anpali Babel", "Antonio", "Aquanut", "Aquatic Index", "Ballerina Peppermintina", 
        "Ballerino Lololo", "Bambu Bambu Sahur", "Belula Beluga", "Bombardini Tortinii", 
        "Brainrot God Lucky Block", "Brasilini Berimbini", "Brr es Teh Patipum", "Bulbito Bandito Traktorito", 
        "Cacasito Satalito", "Capi Taco", "Cappuccino Clownino", "Chihuanini Taconini", "Cocofanto Elefanto", 
        "Corn Corn Corn Sahur", "Crabbo Limonetta", "Dug dug dug", "Espresso Signora", "Extinct Ballerina", 
        "Fishing Event", "Frio Ninja", "Gattatino Neonino", "Gattatino Nyanino", "Gattito Tacoto", 
        "Girafa Celestre", "Granchiello Spiritell", "Indonesian Event", "Jacko Jack Jack", "Krupuk Pagi Pagi", 
        "Las Cappuchinas", "Los Bombinitos", "Los Chihuaninis", "Los Crocodillitos", "Los Gattitos", 
        "Los Orcalitos", "Los Tipi Tacos", "Los Tungtungtungcitos", "Mastodontico Telepiedone", "Matteo", 
        "Money Money Man", "Mummy Ambalabu", "Noo La Polizia", "Odin Din Din Dun", "Orcalero Orcala", 
        "Orcalita Orcala", "Pakrahmatmamat", "Pakrahmatmatina", "Piccione Macchina", "Piccionetta Machina", 
        "Pop Pop Sahur", "Skull Skull Skull", "Snailenzo", "Squalanana", "Statutino Libertino", 
        "Tartaruga Cisterna", "Tentacolo Tecnico", "Tigroligre Frutonni", "Tipi Topi Taco", 
        "Tractoro Dinosauro", "Tralalero Tralala", "Tralalita Tralala", "Trenostruzzo Turbo 3000", 
        "Trippi Troppi Troppa Trippa", "Tukanno Bananno", "Unclito Samito", "Urubini Flamenguini", 
        "Vampira Cappuccina"
    },
    ["Secret"] = {
        "1x1x1x1", "25", "67", "Agarrini La Palini",
        "Chill Puppy","Spinny Hammy","Bacuru and Egguru","Hydra Dragon Cannelloni","Cerberus","La Romantic Grande","Rosey and Teddy","Love Love Bear",
        "Bisonte Giuppitere", "Blackhole Goat", "Boatito Auratito", "Burguro and Fryuro", "Burrito Bandito", 
        "Capitano Moby", "Celularcini Viciosini", "Chachechi", "Chicleteira Bicicleteira", 
        "Chicleteirina Bicicleteirina", "Chillin Chili", "Chimpanzini Spiderini", "Chipso and Queso", 
        "Coffin Tung Tung Tung Sahur", "Combinasions", "Cuadramat and Pakrahmatmamat", 
        "Dragon Cannelloni", "Dul Dul Dul", "Esok Sekolah", "Eviledon", "Extinct Matteo", 
        "Extinct Tralalero", "Festive 67", "Fishing Event", "Fishino Clownino", "Fragola La La La", 
        "Fragrama and Chocrama", "Frankentteo", "Garama and Madundung", "Giftini Spyderini", 
        "Gobblino Uniciclino", "Graipuss Medussi", "Guerriro Digitale", "Guest 666", "Headless Horseman", 
        "Hokka Horloge", "Horegini Boom", "Jackorilla", "Job Job Job Sahur", "Karker Sahur", 
        "Karkerkar Kurkur", "Ketchuru and Musturu", "Ketupat Kepat", "La Casa Boo", "La Cucaracha", 
        "La Extinct Grande", "La Ginger Sekolah", "La Gingerbread Kepat", "La Grande Combinasion", 
        "La Jolly Grande", "La Karkerkar Combinasion", "La Sahur Combinasion", "La Secret Combinasion", 
        "La Spooky Grande", "La Supreme Combinasion", "La Taco Combinasion", "La Vacca Jacko Linterino", 
        "La Vacca Presento Natalina", "La Vacca Saturno Saturnita", "Las Sis", "Las Tralaleritas", 
        "Las Vaquitas Saturnitas", "Lavadorito Spinito", "Los 67", "Los Bros", "Los Chicleteiras", 
        "Los Combinasionas", "Los Hotspotsitos", "Los Jobcitos", "Los Cucarachas", "Los Karkeritos", "Los Matteos", 
        "Los Mobilis", "Los Nooo My Hotspotsitos", "Los Planitos", "Los Quesadillas", "Chimnino", "Los 25", "Los Spaghettis", 
        "Los Spooky Combinasionas", "Los Spyderinis", "Los Tacoritas", "Los Tortus", "Los Tralaleritos", 
        "Los Burritos", "Telemorte", 
        "Mariachi Corazoni", "Mieteteira Bicicleteira", "Money Money Puggy", "Noo my Candy", 
        "Noo my examine", "Nooo My Hotspot", "Nuclearo Dinossauro", "Orcaledon", "Perrito Burrito", 
        "Pirulitoita Bicicleteira", "Pot Hotspot", "Pot Pumpkin", "Pumpkini Spyderini", 
        "Quesadilla Crocodila", "Quesadillo Vampiro", "Rang Ring Bus", "Sammyni Spyderini", 
        "Santa Chicleteira", "Spaghetti Tualetti", "Spooky and Pumpky", "Swag Soda", 
        "Tacorita Bicicleta", "Tamaluk un Meass", "Tang Tang Keletang", "Tictac Sahur", 
        "To to to Sahur", "Torrtuginni Dragonfrutini", "Tralaledon", "Trenostruzzo Turbo 4000", 
        "Trickolino", "Tung Tung Tung Sahur", "Vulturino Skeletono", "W or L", "Money Money Reindeer", "Yess my examine", "Tuff Toucan", "Swaggy Bros", "Reinito Sleighito", "Cooki and Milki", "Dragon Gingerini", "Jolly Jolly Sahur", "Los Jolly Combinasionas", "Los Candies",
        "Zombie Tralala"
    },
    ["OG"] = {
        "Strawberry Elephant", "Meowl", "Skibidi Toilet"
    }
}

local state = {
    autoJoin = false,
    minMoney = 10,
    minForceMoney = 100, 
    autoForceJoin = false, 
    forceDuration = 10,
    activeForces = {}, 
    blacklist = {}, 
    autoForceList = {}, 
    
    targetList = {},        
    targetLimits = {},       
    targetListOpen = false, 
    targetConfigOpen = false, 

    currentTab = "Brainrot God",
    currentForceTab = "Brainrot God",
    currentTargetTab = "Brainrot God", 
    filtersOpen = false,
    blacklistOpen = false,
    autoForceOpen = false,
    isMinimized = false,
    minimizeKey = Enum.KeyCode.RightControl,
    isBinding = false,
    antiError = false,
    showFps = false,
    showPing = false,
    nuclearLagEnabled = false,
    blueBaseEnabled = false
}

uiElements = {} 
local logSortCounter = 0
local BindBtnRef = nil

local function saveSettings()
    local data = {
        minMoney = state.minMoney,
        minForceMoney = state.minForceMoney, 
        autoForceJoin = state.autoForceJoin, 
        forceDuration = state.forceDuration,
        blacklist = state.blacklist,
        autoForceList = state.autoForceList,
        bind = state.minimizeKey.Name,
        antiError = state.antiError,
        showFps = state.showFps,
        showPing = state.showPing,
        nuclearLagEnabled = state.nuclearLagEnabled,
        blueBaseEnabled = state.blueBaseEnabled,
        targetList = state.targetList,
        targetLimits = state.targetLimits
    }
    pcall(function() if writefile then writefile(SETTINGS_FILE, HttpService:JSONEncode(data)) end end)
end

local function cleanMoney(val)
    if type(val) == "number" then return val end
    if type(val) == "string" then
        local cleaned = val:gsub("[^0-9%.]", "")
        return tonumber(cleaned) or 0
    end
    return 0
end

local function getNormalizedMoney(val)
    val = cleanMoney(val)
    if val > 999999 then return val / 1000000 end
    return val 
end

local function formatMoney(val)
    val = getNormalizedMoney(val)
    if val >= 1000 then return string.format("%.1fB", val/1000) end
    return string.format("%.0fM", val) 
end

local function loadSettings()
    pcall(function()
        if isfile and isfile(SETTINGS_FILE) then
            local raw = readfile(SETTINGS_FILE)
            local data = HttpService:JSONDecode(raw)
            if data.minMoney then state.minMoney = data.minMoney end
            if data.minForceMoney then state.minForceMoney = data.minForceMoney end
            if data.autoForceJoin ~= nil then state.autoForceJoin = data.autoForceJoin end
            if data.forceDuration then state.forceDuration = data.forceDuration end
            if data.blacklist then state.blacklist = data.blacklist end
            if data.autoForceList then state.autoForceList = data.autoForceList end
            if data.bind then 
               local success, key = pcall(function() return Enum.KeyCode[data.bind] end)
               if success and key then state.minimizeKey = key end
            end
            if data.antiError ~= nil then state.antiError = data.antiError end
            if data.showFps ~= nil then state.showFps = data.showFps end
            if data.showPing ~= nil then state.showPing = data.showPing end
            if data.nuclearLagEnabled ~= nil then state.nuclearLagEnabled = data.nuclearLagEnabled end
            if data.blueBaseEnabled ~= nil then state.blueBaseEnabled = data.blueBaseEnabled end
            if data.targetList then state.targetList = data.targetList end
            if data.targetLimits then state.targetLimits = data.targetLimits end
        end
    end)
end
loadSettings()

if state.nuclearLagEnabled then task.spawn(activateNuclear) end
if state.blueBaseEnabled then task.spawn(function() toggleBlueBaseFunc(true) end) end

task.spawn(function()
    while true do
        local activeCount = 0
        for _ in pairs(state.activeForces) do activeCount = activeCount + 1 end
        
        local processed = false
        for jobId, forceData in pairs(state.activeForces) do
            processed = true
            if os.clock() - forceData.time >= state.forceDuration then
                state.activeForces[jobId] = nil 
                if forceData.btn then
                    forceData.btn.BackgroundColor3 = COLORS.ButtonBG
                    forceData.btn.BackgroundTransparency = 1
                    forceData.btn.Text = "FORCE"
                    forceData.btn.TextColor3 = Color3.fromRGB(200, 200, 200) 
                    if forceData.stroke then 
                        forceData.stroke.Color = forceData.defColor or COLORS.Stroke 
                        forceData.stroke.Transparency = 0 
                    end
                end
                if forceData.row then
                    forceData.row.LayoutOrder = forceData.row:GetAttribute("OriginalOrder") or 0
                end
            else
                ultraCheckjobid(jobId)
                task.wait(0.15) 
            end
        end
        
        if not processed or activeCount == 0 then 
            task.wait(0.5) 
        end
    end
end)

RunService.RenderStepped:Connect(function()
    if state.antiError then
        pcall(function()
            local prompt = CoreGui:FindFirstChild("RobloxPromptGui")
            if prompt then
                local overlay = prompt:FindFirstChild("promptOverlay")
                if overlay then overlay.Visible = false end
            end
        end)
        GuiService:ClearError()
    end
end)

-- ============================================
-- COLORS REDEFINIDOS - ESTILO JW PRIORITY
-- ============================================
local COLORS = {
    Background = Color3.fromRGB(10, 12, 20),
    SectionBG = Color3.fromRGB(18, 20, 32),
    ButtonBG = Color3.fromRGB(28, 32, 50),
    Stroke = Color3.fromRGB(212, 175, 55),
    TextWhite = Color3.fromRGB(255, 255, 255),
    TextGray = Color3.fromRGB(160, 160, 180),
    Selected = Color3.fromRGB(212, 175, 55),
    Unselected = Color3.fromRGB(28, 32, 50),
    ForceActive = Color3.fromRGB(255, 60, 60),
    DiscordBlue = Color3.fromRGB(88, 101, 242),
    Gold = Color3.fromRGB(212, 175, 55),
    GoldDark = Color3.fromRGB(160, 130, 30),
    GoldLight = Color3.fromRGB(255, 220, 100),
    Tier1 = Color3.fromRGB(212, 175, 55),
    Tier2 = Color3.fromRGB(255, 200, 50),
    Tier3 = Color3.fromRGB(255, 120, 20),
    Tier4 = Color3.fromRGB(255, 20, 80),
    MoneyBadge = Color3.fromRGB(212, 175, 55)
}

local GRADIENT_GOLD = {
    ColorSequenceKeypoint.new(0, Color3.fromRGB(255, 220, 80)),
    ColorSequenceKeypoint.new(0.5, Color3.fromRGB(255, 255, 180)),
    ColorSequenceKeypoint.new(1, Color3.fromRGB(212, 175, 55))
}
local GRADIENT_AQUA = GRADIENT_GOLD
local GRADIENT_FILTERS = GRADIENT_GOLD

local uiElements = {}
local logSortCounter = 0
local BindBtnRef = nil

local ScreenGui = Instance.new("ScreenGui")
ScreenGui.Name = "JWPriorityUI"
ScreenGui.ResetOnSpawn = false
safeParent(ScreenGui)

-- FPS/PING OVERLAY
local OverlayFrame = Instance.new("Frame")
OverlayFrame.Name = "OverlayStats"
OverlayFrame.Size = UDim2.new(0, 200, 0, 30)
OverlayFrame.Position = UDim2.new(0.5, -100, 0, 5)
OverlayFrame.BackgroundTransparency = 1
OverlayFrame.Parent = ScreenGui
OverlayLayout = Instance.new("UIListLayout")
OverlayLayout.FillDirection = Enum.FillDirection.Horizontal
OverlayLayout.HorizontalAlignment = Enum.HorizontalAlignment.Center
OverlayLayout.Padding = UDim.new(0, 10)
OverlayLayout.Parent = OverlayFrame

local function createOverlayLabel(text)
    local frame = Instance.new("Frame")
    frame.Size = UDim2.new(0, 80, 0, 25)
    frame.BackgroundColor3 = COLORS.Background
    frame.BackgroundTransparency = 0.3
    frame.Visible = false
    frame.Parent = OverlayFrame
    Instance.new("UICorner", frame).CornerRadius = UDim.new(0, 6)
    local lbl = Instance.new("TextLabel")
    lbl.Size = UDim2.new(1,0,1,0)
    lbl.BackgroundTransparency = 1
    lbl.TextColor3 = COLORS.Gold
    lbl.Font = Enum.Font.GothamBold
    lbl.TextSize = 14
    lbl.Text = text
    lbl.Parent = frame
    local stroke = Instance.new("UIStroke")
    stroke.Thickness = 1.5
    stroke.Parent = frame
    local overlayGrad = Instance.new("UIGradient")
    overlayGrad.Color = ColorSequence.new{
    ColorSequenceKeypoint.new(0, Color3.fromRGB(255, 200, 50)),
    ColorSequenceKeypoint.new(0.5, Color3.fromRGB(255, 255, 180)),
    ColorSequenceKeypoint.new(1, Color3.fromRGB(212, 175, 55))
}
    overlayGrad.Parent = stroke
    table.insert(activeGradients, overlayGrad)
    return frame, lbl
end

local FpsFrame, FpsLabel = createOverlayLabel("FPS: 0")
local PingFrame, PingLabel = createOverlayLabel("Ping: 0")

RunService.RenderStepped:Connect(function(deltaTime)
    if state.showFps then
        FpsFrame.Visible = true
        FpsLabel.Text = "FPS: " .. math.floor(1 / deltaTime)
    else FpsFrame.Visible = false end
    if state.showPing then
        PingFrame.Visible = true
        local ping = 0
        pcall(function() ping = math.floor(Stats.Network.ServerStatsItem["Data Ping"]:GetValue()) end)
        PingLabel.Text = "Ping: " .. ping .. "ms"
    else PingFrame.Visible = false end
end)

-- MINI BUTTON
local MiniFrame = Instance.new("Frame")
MiniFrame.Size = UDim2.new(0, 55, 0, 55)
MiniFrame.Position = UDim2.new(0, 10, 0.5, -27)
MiniFrame.BackgroundColor3 = COLORS.Background
MiniFrame.Visible = false
MiniFrame.Parent = ScreenGui
Instance.new("UICorner", MiniFrame).CornerRadius = UDim.new(0, 12)
MiniStroke = Instance.new("UIStroke")
MiniStroke.Thickness = 2
MiniStroke.Parent = MiniFrame
local MiniGrad = Instance.new("UIGradient")
MiniGrad.Color = ColorSequence.new{
    ColorSequenceKeypoint.new(0, Color3.fromRGB(255, 200, 50)),
    ColorSequenceKeypoint.new(0.5, Color3.fromRGB(255, 255, 180)),
    ColorSequenceKeypoint.new(1, Color3.fromRGB(212, 175, 55))
}
MiniGrad.Parent = MiniStroke
table.insert(activeGradients, MiniGrad)
local MiniBtn = Instance.new("TextButton")
MiniBtn.Size = UDim2.new(1,0,1,0)
MiniBtn.BackgroundTransparency = 1
MiniBtn.Text = "OPEN"
MiniBtn.TextColor3 = Color3.fromRGB(255,255,255)
MiniBtn.Font = Enum.Font.GothamBlack
MiniBtn.TextSize = 10
MiniBtn.Parent = MiniFrame
local MiniBtnGrad = Instance.new("UIGradient")
MiniBtnGrad.Color = ColorSequence.new{
    ColorSequenceKeypoint.new(0, Color3.fromRGB(255, 220, 80)),
    ColorSequenceKeypoint.new(0.25, Color3.fromRGB(255, 255, 180)),
    ColorSequenceKeypoint.new(0.5, Color3.fromRGB(212, 175, 55)),
    ColorSequenceKeypoint.new(0.75, Color3.fromRGB(255, 255, 180)),
    ColorSequenceKeypoint.new(1, Color3.fromRGB(255, 220, 80))
}
MiniBtnGrad.Parent = MiniBtn
table.insert(activeGradients, MiniBtnGrad)

-- MAIN FRAME
local MainFrame = Instance.new("Frame")
MainFrame.Name = "MainFrame"
MainFrame.Size = UDim2.new(0, 520, 0, 420)
MainFrame.Position = UDim2.new(0.5, -260, 0.5, -210)
MainFrame.BackgroundColor3 = COLORS.Background
MainFrame.BorderSizePixel = 0
MainFrame.ClipsDescendants = true
MainFrame.Parent = ScreenGui
Instance.new("UICorner", MainFrame).CornerRadius = UDim.new(0, 16)

BorderStroke = Instance.new("UIStroke")
BorderStroke.Thickness = 2.5
BorderStroke.ApplyStrokeMode = Enum.ApplyStrokeMode.Border
BorderStroke.Parent = MainFrame
local BorderGradient = Instance.new("UIGradient")
BorderGradient.Color = ColorSequence.new{
    ColorSequenceKeypoint.new(0, Color3.fromRGB(255, 220, 80)),
    ColorSequenceKeypoint.new(0.25, Color3.fromRGB(255, 255, 180)),
    ColorSequenceKeypoint.new(0.5, Color3.fromRGB(212, 175, 55)),
    ColorSequenceKeypoint.new(0.75, Color3.fromRGB(255, 255, 180)),
    ColorSequenceKeypoint.new(1, Color3.fromRGB(255, 220, 80))
}
BorderGradient.Parent = BorderStroke
table.insert(activeGradients, BorderGradient)

local FiltersFrame = Instance.new("Frame")
local BlacklistFrame = Instance.new("Frame")
local AutoForceFrame = Instance.new("Frame")
local TargetFrame = Instance.new("Frame")
local ConfigFrame = Instance.new("Frame")

local function toggleUI()
    state.isMinimized = not state.isMinimized
    MainFrame.Visible = not state.isMinimized
    MiniFrame.Visible = state.isMinimized
    if state.isMinimized then
        FiltersFrame.Visible = false; state.filtersOpen = false
        BlacklistFrame.Visible = false; state.blacklistOpen = false
        AutoForceFrame.Visible = false; state.autoForceOpen = false
        TargetFrame.Visible = false; state.targetListOpen = false
        ConfigFrame.Visible = false; state.targetConfigOpen = false
    end
end

MiniBtn.MouseButton1Click:Connect(function() playClickSound(); toggleUI() end)

UserInputService.InputBegan:Connect(function(input, gameProcessed)
    if state.isBinding then
        if input.UserInputType == Enum.UserInputType.Keyboard then
            state.minimizeKey = input.KeyCode
            state.isBinding = false
            if BindBtnRef then BindBtnRef.Text = "UI Bind: " .. state.minimizeKey.Name end
            saveSettings()
        end
    elseif not gameProcessed and input.KeyCode == state.minimizeKey then
        toggleUI()
    end
end)

-- HEADER
local Header = Instance.new("Frame")
Header.Size = UDim2.new(1, 0, 0, 55)
Header.BackgroundColor3 = Color3.fromRGB(8, 10, 18)
Header.BorderSizePixel = 0
Header.ZIndex = 10
Header.Parent = MainFrame
Instance.new("UICorner", Header).CornerRadius = UDim.new(0, 16)

HeaderLine = Instance.new("Frame")
HeaderLine.Size = UDim2.new(1, 0, 0, 2)
HeaderLine.Position = UDim2.new(0, 0, 1, -2)
HeaderLine.BackgroundColor3 = Color3.fromRGB(255,255,255)
HeaderLine.BorderSizePixel = 0
HeaderLine.Parent = Header
local HeaderLineGrad = Instance.new("UIGradient")
HeaderLineGrad.Color = ColorSequence.new{
    ColorSequenceKeypoint.new(0, Color3.fromRGB(255, 220, 80)),
    ColorSequenceKeypoint.new(0.25, Color3.fromRGB(255, 255, 180)),
    ColorSequenceKeypoint.new(0.5, Color3.fromRGB(212, 175, 55)),
    ColorSequenceKeypoint.new(0.75, Color3.fromRGB(255, 255, 180)),
    ColorSequenceKeypoint.new(1, Color3.fromRGB(255, 220, 80))
}
HeaderLineGrad.Parent = HeaderLine
table.insert(activeGradients, HeaderLineGrad)

local Title = Instance.new("TextLabel")
Title.Text = "JW Auto Joiner — CONTROL PANEL"
Title.Font = Enum.Font.GothamBlack
Title.TextSize = 16
Title.TextColor3 = Color3.fromRGB(255,255,255)
Title.TextXAlignment = Enum.TextXAlignment.Center
Title.Size = UDim2.new(1, 0, 1, 0)
Title.BackgroundTransparency = 1
Title.ZIndex = 11
Title.Parent = Header
local TitleGrad = Instance.new("UIGradient")
TitleGrad.Color = ColorSequence.new{
    ColorSequenceKeypoint.new(0, Color3.fromRGB(255, 220, 80)),
    ColorSequenceKeypoint.new(0.25, Color3.fromRGB(255, 255, 180)),
    ColorSequenceKeypoint.new(0.5, Color3.fromRGB(212, 175, 55)),
    ColorSequenceKeypoint.new(0.75, Color3.fromRGB(255, 255, 180)),
    ColorSequenceKeypoint.new(1, Color3.fromRGB(255, 220, 80))
}
TitleGrad.Parent = Title
table.insert(activeGradients, TitleGrad)

local CloseBtn = Instance.new("TextButton")
CloseBtn.Size = UDim2.new(0, 28, 0, 28)
CloseBtn.Position = UDim2.new(1, -38, 0.5, -14)
CloseBtn.BackgroundTransparency = 1
CloseBtn.Text = "✕"
CloseBtn.TextColor3 = COLORS.Gold
CloseBtn.Font = Enum.Font.GothamBlack
CloseBtn.TextSize = 16
CloseBtn.ZIndex = 12
CloseBtn.Parent = Header

CloseBtn.MouseButton1Click:Connect(function() playClickSound(); toggleUI() end)

local FilterBtn = Instance.new("TextButton")
FilterBtn.Size = UDim2.new(0, 28, 0, 28)
FilterBtn.Position = UDim2.new(0, 10, 0.5, -14)
FilterBtn.BackgroundTransparency = 1
FilterBtn.Text = "⚙"
FilterBtn.TextColor3 = COLORS.Gold
FilterBtn.Font = Enum.Font.GothamBlack
FilterBtn.TextSize = 18
FilterBtn.ZIndex = 12
FilterBtn.Parent = Header

-- TOP BUTTONS ROW
TopBtnRow = Instance.new("Frame")
TopBtnRow.Size = UDim2.new(1, -20, 0, 38)
TopBtnRow.Position = UDim2.new(0, 10, 0, 60)
TopBtnRow.BackgroundTransparency = 1
TopBtnRow.Parent = MainFrame

TopBtnLayout = Instance.new("UIListLayout")
TopBtnLayout.FillDirection = Enum.FillDirection.Horizontal
TopBtnLayout.Padding = UDim.new(0, 6)
TopBtnLayout.VerticalAlignment = Enum.VerticalAlignment.Center
TopBtnLayout.Parent = TopBtnRow

local function makeTopBtn(text, width)
    local btn = Instance.new("TextButton")
    btn.Size = UDim2.new(0, width, 0, 34)
    btn.BackgroundColor3 = Color3.fromRGB(255,255,255)
    btn.Text = text
    btn.TextColor3 = Color3.fromRGB(10,10,10)
    btn.Font = Enum.Font.GothamBold
    btn.TextSize = 12
    btn.AutoButtonColor = false
    btn.Parent = TopBtnRow
    Instance.new("UICorner", btn).CornerRadius = UDim.new(0, 8)
    local btnGrad = Instance.new("UIGradient")
    btnGrad.Color = ColorSequence.new{
    ColorSequenceKeypoint.new(0, Color3.fromRGB(255, 220, 80)),
    ColorSequenceKeypoint.new(0.25, Color3.fromRGB(255, 255, 180)),
    ColorSequenceKeypoint.new(0.5, Color3.fromRGB(212, 175, 55)),
    ColorSequenceKeypoint.new(0.75, Color3.fromRGB(255, 255, 180)),
    ColorSequenceKeypoint.new(1, Color3.fromRGB(255, 220, 80))
}
    btnGrad.Parent = btn
    table.insert(activeGradients, btnGrad)
    return btn
end

local AutoJoinTopBtn = makeTopBtn("Auto Join: OFF", 118)
local AutoForceTopBtn = makeTopBtn("AutoForce: OFF", 118)
local ClearLogsBtn = makeTopBtn("Clear Logs", 95)
local BlacklistTopBtn = makeTopBtn("Blacklist name", 118)

-- MIN MONEY INPUT ROW
MinMoneyRow = Instance.new("Frame")
MinMoneyRow.Size = UDim2.new(0, 130, 0, 30)
MinMoneyRow.BackgroundColor3 = COLORS.SectionBG
MinMoneyRow.Parent = MainFrame
MinMoneyRow.Position = UDim2.new(0, 10, 0, 104)
Instance.new("UICorner", MinMoneyRow).CornerRadius = UDim.new(0, 8)
MinMoneyStroke = Instance.new("UIStroke")
MinMoneyStroke.Thickness = 1.5
MinMoneyStroke.Parent = MinMoneyRow
local MMGrad = Instance.new("UIGradient")
MMGrad.Color = ColorSequence.new{
    ColorSequenceKeypoint.new(0, Color3.fromRGB(255, 200, 50)),
    ColorSequenceKeypoint.new(0.5, Color3.fromRGB(255, 255, 180)),
    ColorSequenceKeypoint.new(1, Color3.fromRGB(212, 175, 55))
}
MMGrad.Parent = MinMoneyStroke
table.insert(activeGradients, MMGrad)

local MinMoneyInput = Instance.new("TextBox")
MinMoneyInput.Size = UDim2.new(1, -10, 1, 0)
MinMoneyInput.Position = UDim2.new(0, 5, 0, 0)
MinMoneyInput.BackgroundTransparency = 1
MinMoneyInput.Text = tostring(state.minMoney)
MinMoneyInput.PlaceholderText = "Min M/s"
MinMoneyInput.TextColor3 = COLORS.Gold
MinMoneyInput.Font = Enum.Font.GothamBold
MinMoneyInput.TextSize = 13
MinMoneyInput.Parent = MinMoneyRow

MinMoneyInput.FocusLost:Connect(function()
    local num = tonumber(MinMoneyInput.Text)
    if num then state.minMoney = num; saveSettings()
    else MinMoneyInput.Text = tostring(state.minMoney) end
end)

-- COLUMN HEADERS
ColHeader = Instance.new("Frame")
ColHeader.Size = UDim2.new(1, -20, 0, 24)
ColHeader.Position = UDim2.new(0, 10, 0, 140)
ColHeader.BackgroundTransparency = 1
ColHeader.Parent = MainFrame

ColPet = Instance.new("TextLabel")
ColPet.Text = "PET"
ColPet.Font = Enum.Font.GothamBlack
ColPet.TextSize = 12
ColPet.TextColor3 = COLORS.Gold
ColPet.Size = UDim2.new(0.45, 0, 1, 0)
ColPet.BackgroundTransparency = 1
ColPet.TextXAlignment = Enum.TextXAlignment.Left
ColPet.Parent = ColHeader
local ColPetGrad = Instance.new("UIGradient")
ColPetGrad.Color = ColorSequence.new{
    ColorSequenceKeypoint.new(0, Color3.fromRGB(255, 220, 80)),
    ColorSequenceKeypoint.new(0.25, Color3.fromRGB(255, 255, 180)),
    ColorSequenceKeypoint.new(0.5, Color3.fromRGB(212, 175, 55)),
    ColorSequenceKeypoint.new(0.75, Color3.fromRGB(255, 255, 180)),
    ColorSequenceKeypoint.new(1, Color3.fromRGB(255, 220, 80))
}
ColPetGrad.Parent = ColPet
table.insert(activeGradients, ColPetGrad)

ColVal = Instance.new("TextLabel")
ColVal.Text = "VALUE"
ColVal.Font = Enum.Font.GothamBlack
ColVal.TextSize = 12
ColVal.TextColor3 = COLORS.Gold
ColVal.Size = UDim2.new(0.3, 0, 1, 0)
ColVal.Position = UDim2.new(0.4, 0, 0, 0)
ColVal.BackgroundTransparency = 1
ColVal.TextXAlignment = Enum.TextXAlignment.Left
ColVal.Parent = ColHeader
local ColValGrad = Instance.new("UIGradient")
ColValGrad.Color = ColorSequence.new{
    ColorSequenceKeypoint.new(0, Color3.fromRGB(255, 220, 80)),
    ColorSequenceKeypoint.new(0.25, Color3.fromRGB(255, 255, 180)),
    ColorSequenceKeypoint.new(0.5, Color3.fromRGB(212, 175, 55)),
    ColorSequenceKeypoint.new(0.75, Color3.fromRGB(255, 255, 180)),
    ColorSequenceKeypoint.new(1, Color3.fromRGB(255, 220, 80))
}
ColValGrad.Parent = ColVal
table.insert(activeGradients, ColValGrad)

-- SEPARATOR LINE
SepLine = Instance.new("Frame")
SepLine.Size = UDim2.new(1, -20, 0, 1)
SepLine.Position = UDim2.new(0, 10, 0, 165)
SepLine.BackgroundColor3 = Color3.fromRGB(255,255,255)
SepLine.BackgroundTransparency = 0.5
SepLine.BorderSizePixel = 0
SepLine.Parent = MainFrame
local SepGrad = Instance.new("UIGradient")
SepGrad.Color = ColorSequence.new{
    ColorSequenceKeypoint.new(0, Color3.fromRGB(255, 220, 80)),
    ColorSequenceKeypoint.new(0.25, Color3.fromRGB(255, 255, 180)),
    ColorSequenceKeypoint.new(0.5, Color3.fromRGB(212, 175, 55)),
    ColorSequenceKeypoint.new(0.75, Color3.fromRGB(255, 255, 180)),
    ColorSequenceKeypoint.new(1, Color3.fromRGB(255, 220, 80))
}
SepGrad.Parent = SepLine
table.insert(activeGradients, SepGrad)

-- LOG SCROLL
ScrollContainer = Instance.new("Frame")
ScrollContainer.Name = "ScrollContainer"
ScrollContainer.Size = UDim2.new(1, -20, 1, -175)
ScrollContainer.Position = UDim2.new(0, 10, 0, 168)
ScrollContainer.BackgroundTransparency = 1
ScrollContainer.ClipsDescendants = true
ScrollContainer.Parent = MainFrame

local StatusLabel = Instance.new("TextLabel")
StatusLabel.Name = "StatusLabel"
StatusLabel.Text = "WAITING FOR LOGS..."
StatusLabel.Size = UDim2.new(1, 0, 1, 0)
StatusLabel.BackgroundTransparency = 1
StatusLabel.TextColor3 = Color3.fromRGB(80, 80, 80)
StatusLabel.Font = Enum.Font.GothamBold
StatusLabel.TextSize = 13
StatusLabel.ZIndex = 5
StatusLabel.Parent = ScrollContainer

local LogScroll = Instance.new("ScrollingFrame")
LogScroll.Name = "LogScroll"
LogScroll.Size = UDim2.new(1, 0, 1, 0)
LogScroll.BackgroundTransparency = 1
LogScroll.ScrollBarThickness = 2
LogScroll.ScrollBarImageColor3 = COLORS.Gold
LogScroll.BorderSizePixel = 0
LogScroll.AutomaticCanvasSize = Enum.AutomaticSize.Y
LogScroll.CanvasSize = UDim2.new(0,0,0,0)
LogScroll.Parent = ScrollContainer
LogScroll.ZIndex = 6

LogPadding = Instance.new("UIPadding")
LogPadding.PaddingTop = UDim.new(0, 3)
LogPadding.PaddingLeft = UDim.new(0, 2)
LogPadding.PaddingRight = UDim.new(0, 2)
LogPadding.PaddingBottom = UDim.new(0, 3)
LogPadding.Parent = LogScroll

LogListLayout = Instance.new("UIListLayout")
LogListLayout.SortOrder = Enum.SortOrder.LayoutOrder
LogListLayout.Padding = UDim.new(0, 4)
LogListLayout.Parent = LogScroll

uiElements.LogScroll = LogScroll
uiElements.StatusLabel = StatusLabel

-- DRAGGABLE
local function makeDraggable(handle, frame)
    local dragging, dragInput, dragStart, startPos = false, nil, nil, nil
    local function update(input)
        local delta = input.Position - dragStart
        local newX = startPos.X.Offset + delta.X
        local newY = startPos.Y.Offset + delta.Y
        frame.Position = UDim2.new(startPos.X.Scale, newX, startPos.Y.Scale, newY)

        -- Mover todos los paneles laterales con el MainFrame
        if frame == MainFrame then
            local gap = 10
            if state.filtersOpen and FiltersFrame.Visible then
                FiltersFrame.Position = UDim2.new(startPos.X.Scale, newX - FiltersFrame.Size.X.Offset - gap, startPos.Y.Scale, newY)
            end
            if state.blacklistOpen and BlacklistFrame.Visible then
                BlacklistFrame.Position = UDim2.new(startPos.X.Scale, newX + MainFrame.Size.X.Offset + gap, startPos.Y.Scale, newY)
            end
            if state.autoForceOpen and AutoForceFrame.Visible then
                AutoForceFrame.Position = UDim2.new(startPos.X.Scale, newX + MainFrame.Size.X.Offset + gap, startPos.Y.Scale, newY)
            end
            if state.targetListOpen and TargetFrame.Visible then
                TargetFrame.Position = UDim2.new(startPos.X.Scale, newX + MainFrame.Size.X.Offset + gap, startPos.Y.Scale, newY)
                if state.targetConfigOpen and ConfigFrame.Visible then
                    ConfigFrame.Position = UDim2.new(startPos.X.Scale, newX + MainFrame.Size.X.Offset + TargetFrame.Size.X.Offset + gap*2, startPos.Y.Scale, newY)
                end
            end
        end
    end
    handle.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
            dragging = true; dragStart = input.Position; startPos = frame.Position
            input.Changed:Connect(function() if input.UserInputState == Enum.UserInputState.End then dragging = false end end)
        end
    end)
    handle.InputChanged:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch then dragInput = input end
    end)
    UserInputService.InputChanged:Connect(function(input)
        if input == dragInput and dragging then update(input) end
    end)
end

makeDraggable(Header, MainFrame)
makeDraggable(MiniFrame, MiniFrame)

-- FILTERS FRAME
FiltersFrame.Size = UDim2.new(0, 240, 0, 380)
FiltersFrame.BackgroundColor3 = COLORS.Background
FiltersFrame.BorderSizePixel = 0
FiltersFrame.Visible = false
FiltersFrame.ClipsDescendants = true
FiltersFrame.Parent = ScreenGui
Instance.new("UICorner", FiltersFrame).CornerRadius = UDim.new(0, 16)
FiltersStroke = Instance.new("UIStroke")
FiltersStroke.Thickness = 2.5
FiltersStroke.Parent = FiltersFrame
local FiltersGrad = Instance.new("UIGradient")
FiltersGrad.Color = ColorSequence.new{
    ColorSequenceKeypoint.new(0, Color3.fromRGB(255, 220, 80)),
    ColorSequenceKeypoint.new(0.25, Color3.fromRGB(255, 255, 180)),
    ColorSequenceKeypoint.new(0.5, Color3.fromRGB(212, 175, 55)),
    ColorSequenceKeypoint.new(0.75, Color3.fromRGB(255, 255, 180)),
    ColorSequenceKeypoint.new(1, Color3.fromRGB(255, 220, 80))
}
FiltersGrad.Parent = FiltersStroke
table.insert(activeGradients, FiltersGrad)

FHeader = Instance.new("Frame")
FHeader.Size = UDim2.new(1, 0, 0, 45)
FHeader.BackgroundColor3 = Color3.fromRGB(8, 10, 18)
FHeader.BorderSizePixel = 0
FHeader.Parent = FiltersFrame
Instance.new("UICorner", FHeader).CornerRadius = UDim.new(0, 16)

FTitle = Instance.new("TextLabel")
FTitle.Text = "SETTINGS"
FTitle.Font = Enum.Font.GothamBlack
FTitle.TextSize = 14
FTitle.TextColor3 = Color3.fromRGB(255,255,255)
FTitle.TextXAlignment = Enum.TextXAlignment.Center
FTitle.Size = UDim2.new(1, 0, 1, 0)
FTitle.BackgroundTransparency = 1
FTitle.Parent = FHeader
local FTitleGrad = Instance.new("UIGradient")
FTitleGrad.Color = ColorSequence.new{
    ColorSequenceKeypoint.new(0, Color3.fromRGB(255, 220, 80)),
    ColorSequenceKeypoint.new(0.25, Color3.fromRGB(255, 255, 180)),
    ColorSequenceKeypoint.new(0.5, Color3.fromRGB(212, 175, 55)),
    ColorSequenceKeypoint.new(0.75, Color3.fromRGB(255, 255, 180)),
    ColorSequenceKeypoint.new(1, Color3.fromRGB(255, 220, 80))
}
FTitleGrad.Parent = FTitle
table.insert(activeGradients, FTitleGrad)

FDefault = Instance.new("TextButton")
FDefault.Text = "Default"
FDefault.Size = UDim2.new(0, 60, 0, 24)
FDefault.Position = UDim2.new(0, 10, 0.5, -12)
FDefault.BackgroundColor3 = Color3.fromRGB(255,255,255)
FDefault.TextColor3 = Color3.fromRGB(10,10,10)
FDefault.Font = Enum.Font.GothamBold
FDefault.TextSize = 11
FDefault.Parent = FHeader
Instance.new("UICorner", FDefault).CornerRadius = UDim.new(0, 6)
local FDefaultGrad = Instance.new("UIGradient")
FDefaultGrad.Color = ColorSequence.new{
    ColorSequenceKeypoint.new(0, Color3.fromRGB(255, 200, 50)),
    ColorSequenceKeypoint.new(0.5, Color3.fromRGB(255, 255, 180)),
    ColorSequenceKeypoint.new(1, Color3.fromRGB(212, 175, 55))
}
FDefaultGrad.Parent = FDefault
table.insert(activeGradients, FDefaultGrad)

FClose = Instance.new("TextButton")
FClose.Text = "✕"
FClose.Size = UDim2.new(0, 24, 0, 24)
FClose.Position = UDim2.new(1, -34, 0.5, -12)
FClose.BackgroundTransparency = 1
FClose.TextColor3 = COLORS.Gold
FClose.Font = Enum.Font.GothamBold
FClose.TextSize = 16
FClose.Parent = FHeader

FContainer = Instance.new("ScrollingFrame")
FContainer.Size = UDim2.new(1, -20, 1, -55)
FContainer.Position = UDim2.new(0, 10, 0, 50)
FContainer.BackgroundTransparency = 1
FContainer.ScrollBarThickness = 3
FContainer.ScrollBarImageColor3 = COLORS.Gold
FContainer.AutomaticCanvasSize = Enum.AutomaticSize.Y
FContainer.CanvasSize = UDim2.new(0,0,0,0)
FContainer.BorderSizePixel = 0
FContainer.Parent = FiltersFrame

FLayout = Instance.new("UIListLayout")
FLayout.Padding = UDim.new(0, 8)
FLayout.SortOrder = Enum.SortOrder.LayoutOrder
FLayout.Parent = FContainer

MinMoneyFrame = Instance.new("Frame")
MinMoneyFrame.Size = UDim2.new(1, 0, 0, 30)
MinMoneyFrame.BackgroundTransparency = 1
MinMoneyFrame.LayoutOrder = 1
MinMoneyFrame.Parent = FContainer
MLabel = Instance.new("TextLabel")
MLabel.Text = "Min Money:"
MLabel.Font = Enum.Font.GothamBold
MLabel.TextColor3 = COLORS.Gold
MLabel.TextSize = 12
MLabel.Size = UDim2.new(0.5, 0, 1, 0)
MLabel.BackgroundTransparency = 1
MLabel.TextXAlignment = Enum.TextXAlignment.Left
MLabel.Parent = MinMoneyFrame
MInput = Instance.new("TextBox")
MInput.Text = tostring(state.minMoney)
MInput.PlaceholderText = "10"
MInput.Size = UDim2.new(0, 50, 0, 24)
MInput.Position = UDim2.new(0.55, 0, 0.1, 0)
MInput.BackgroundColor3 = COLORS.SectionBG
MInput.TextColor3 = COLORS.Gold
MInput.Font = Enum.Font.GothamBold
MInput.TextSize = 12
MInput.Parent = MinMoneyFrame
Instance.new("UICorner", MInput).CornerRadius = UDim.new(0, 6)
MSuffix = Instance.new("TextLabel")
MSuffix.Text = "M/s"
MSuffix.Font = Enum.Font.GothamBold
MSuffix.TextColor3 = COLORS.Gold
MSuffix.TextSize = 12
MSuffix.Position = UDim2.new(0.82, 0, 0, 0)
MSuffix.Size = UDim2.new(0.2, 0, 1, 0)
MSuffix.BackgroundTransparency = 1
MSuffix.Parent = MinMoneyFrame

MinForceFrame = Instance.new("Frame")
MinForceFrame.Size = UDim2.new(1, 0, 0, 30)
MinForceFrame.BackgroundTransparency = 1
MinForceFrame.LayoutOrder = 2
MinForceFrame.Parent = FContainer
MFLabel = Instance.new("TextLabel")
MFLabel.Text = "Min Force:"
MFLabel.Font = Enum.Font.GothamBold
MFLabel.TextColor3 = COLORS.Gold
MFLabel.TextSize = 12
MFLabel.Size = UDim2.new(0.5, 0, 1, 0)
MFLabel.BackgroundTransparency = 1
MFLabel.TextXAlignment = Enum.TextXAlignment.Left
MFLabel.Parent = MinForceFrame
MFInput = Instance.new("TextBox")
MFInput.Text = tostring(state.minForceMoney)
MFInput.PlaceholderText = "100"
MFInput.Size = UDim2.new(0, 50, 0, 24)
MFInput.Position = UDim2.new(0.55, 0, 0.1, 0)
MFInput.BackgroundColor3 = COLORS.SectionBG
MFInput.TextColor3 = COLORS.Gold
MFInput.Font = Enum.Font.GothamBold
MFInput.TextSize = 12
MFInput.Parent = MinForceFrame
Instance.new("UICorner", MFInput).CornerRadius = UDim.new(0, 6)
MFSuffix = Instance.new("TextLabel")
MFSuffix.Text = "M/s"
MFSuffix.Font = Enum.Font.GothamBold
MFSuffix.TextColor3 = COLORS.Gold
MFSuffix.TextSize = 12
MFSuffix.Position = UDim2.new(0.82, 0, 0, 0)
MFSuffix.Size = UDim2.new(0.2, 0, 1, 0)
MFSuffix.BackgroundTransparency = 1
MFSuffix.Parent = MinForceFrame

MaxForceFrame = Instance.new("Frame")
MaxForceFrame.Size = UDim2.new(1, 0, 0, 45)
MaxForceFrame.BackgroundTransparency = 1
MaxForceFrame.LayoutOrder = 3
MaxForceFrame.Parent = FContainer
FTLabel = Instance.new("TextLabel")
FTLabel.Text = "Force Timeout:"
FTLabel.Font = Enum.Font.GothamBold
FTLabel.TextColor3 = COLORS.Gold
FTLabel.TextSize = 12
FTLabel.Size = UDim2.new(0.5, 0, 0, 30)
FTLabel.BackgroundTransparency = 1
FTLabel.TextXAlignment = Enum.TextXAlignment.Left
FTLabel.Parent = MaxForceFrame
FTInput = Instance.new("TextBox")
FTInput.Text = tostring(state.forceDuration)
FTInput.PlaceholderText = "10"
FTInput.Size = UDim2.new(0, 50, 0, 24)
FTInput.Position = UDim2.new(0.55, 0, 0, 3)
FTInput.BackgroundColor3 = COLORS.SectionBG
FTInput.TextColor3 = COLORS.Gold
FTInput.Font = Enum.Font.GothamBold
FTInput.TextSize = 12
FTInput.Parent = MaxForceFrame
Instance.new("UICorner", FTInput).CornerRadius = UDim.new(0, 6)
FTSuffix = Instance.new("TextLabel")
FTSuffix.Text = "s"
FTSuffix.Font = Enum.Font.GothamBold
FTSuffix.TextColor3 = COLORS.Gold
FTSuffix.TextSize = 12
FTSuffix.Position = UDim2.new(0.82, 0, 0, 3)
FTSuffix.Size = UDim2.new(0.2, 0, 0, 24)
FTSuffix.BackgroundTransparency = 1
FTSuffix.Parent = MaxForceFrame

local function createBigButton(text, order, colorOverride, parent)
    local btn = Instance.new("TextButton")
    btn.Size = UDim2.new(1, 0, 0, 32)
    btn.BackgroundColor3 = colorOverride or COLORS.SectionBG
    btn.Text = text
    btn.Font = Enum.Font.GothamBold
    btn.TextColor3 = COLORS.Gold
    btn.TextSize = 12
    btn.LayoutOrder = order
    btn.Parent = parent
    Instance.new("UICorner", btn).CornerRadius = UDim.new(0, 8)
    local s = Instance.new("UIStroke")
    s.Thickness = 1.5
    s.Parent = btn
    local sg = Instance.new("UIGradient")
    sg.Color = ColorSequence.new{
    ColorSequenceKeypoint.new(0, Color3.fromRGB(255, 200, 50)),
    ColorSequenceKeypoint.new(0.5, Color3.fromRGB(255, 255, 180)),
    ColorSequenceKeypoint.new(1, Color3.fromRGB(212, 175, 55))
}
    sg.Parent = s
    table.insert(activeGradients, sg)
    return btn
end

local BlacklistOpenBtn = createBigButton("Blacklist Pets ▶", 4, nil, FContainer)
local AutoForceListBtn = createBigButton("Auto Force List ▶", 5, nil, FContainer)
uiElements.TargetListBtn = createBigButton("Target List (Join Only) ▶", 6, nil, FContainer)
local AutoJoinBtn = createBigButton("Auto Join: OFF", 7, nil, FContainer)
local AutoForceJoinBtn = createBigButton("Auto Force Join: OFF", 8, nil, FContainer)
local BindKeyBtn = createBigButton("UI Bind: " .. state.minimizeKey.Name, 9, COLORS.SectionBG, FContainer)
BindKeyBtn.TextColor3 = COLORS.Gold
BindBtnRef = BindKeyBtn

BindKeyBtn.MouseButton1Click:Connect(function()
    BindKeyBtn.Text = "Press any key..."
    state.isBinding = true
end)

NotifyLabel = Instance.new("TextLabel")
NotifyLabel.Text = "Notify tiers"
NotifyLabel.Font = Enum.Font.GothamBold
NotifyLabel.TextColor3 = COLORS.Gold
NotifyLabel.TextSize = 12
NotifyLabel.Size = UDim2.new(1, 0, 0, 20)
NotifyLabel.BackgroundTransparency = 1
NotifyLabel.TextXAlignment = Enum.TextXAlignment.Left
NotifyLabel.LayoutOrder = 10
NotifyLabel.Parent = FContainer

local Tier1 = createBigButton("10m", 11, nil, FContainer)
local Tier2 = createBigButton("50m", 12, nil, FContainer)
local Tier3 = createBigButton("100m+", 13, nil, FContainer)

Tier1.MouseButton1Click:Connect(function() playClickSound(); state.minMoney = 10; MInput.Text = "10"; MinMoneyInput.Text = "10"; saveSettings() end)
Tier2.MouseButton1Click:Connect(function() playClickSound(); state.minMoney = 50; MInput.Text = "50"; MinMoneyInput.Text = "50"; saveSettings() end)
Tier3.MouseButton1Click:Connect(function() playClickSound(); state.minMoney = 100; MInput.Text = "100"; MinMoneyInput.Text = "100"; saveSettings() end)

SettingsLabel = Instance.new("TextLabel")
SettingsLabel.Text = "Extra Settings"
SettingsLabel.Font = Enum.Font.GothamBold
SettingsLabel.TextColor3 = COLORS.Gold
SettingsLabel.TextSize = 12
SettingsLabel.Size = UDim2.new(1, 0, 0, 20)
SettingsLabel.BackgroundTransparency = 1
SettingsLabel.TextXAlignment = Enum.TextXAlignment.Left
SettingsLabel.LayoutOrder = 14
SettingsLabel.Parent = FContainer

local AntiErrorBtn = createBigButton("Anti-Error: OFF", 15, COLORS.SectionBG, FContainer)
local ShowFpsBtn = createBigButton("Show FPS: OFF", 16, COLORS.SectionBG, FContainer)
local ShowPingBtn = createBigButton("Show Ping: OFF", 17, COLORS.SectionBG, FContainer)
local AntiLagBtn = createBigButton("Fps Booster: OFF", 18, COLORS.SectionBG, FContainer)
local BlueBaseBtn = createBigButton("Blue Base: OFF", 19, COLORS.SectionBG, FContainer)

local function updateSettingsVisuals()
    AutoJoinBtn.Text = state.autoJoin and "Auto Join: ON" or "Auto Join: OFF"
    AutoJoinBtn.BackgroundColor3 = state.autoJoin and COLORS.Gold or COLORS.SectionBG
    AutoJoinBtn.TextColor3 = state.autoJoin and Color3.fromRGB(10,10,10) or COLORS.Gold

    AutoForceJoinBtn.Text = state.autoForceJoin and "Auto Force Join: ON" or "Auto Force Join: OFF"
    AutoForceJoinBtn.BackgroundColor3 = state.autoForceJoin and COLORS.ForceActive or COLORS.SectionBG
    AutoForceJoinBtn.TextColor3 = COLORS.TextWhite

    AutoJoinTopBtn.Text = state.autoJoin and "Auto Join: ON" or "Auto Join: OFF"
    AutoForceTopBtn.Text = state.autoForceJoin and "AutoForce: ON" or "AutoForce: OFF"

    if BindBtnRef then BindBtnRef.Text = "UI Bind: " .. state.minimizeKey.Name end
end

MInput.FocusLost:Connect(function()
    local num = tonumber(MInput.Text)
    if num then state.minMoney = num; MinMoneyInput.Text = tostring(num); saveSettings()
    else MInput.Text = tostring(state.minMoney) end
end)

MFInput.FocusLost:Connect(function()
    local num = tonumber(MFInput.Text)
    if num then state.minForceMoney = num; saveSettings()
    else MFInput.Text = tostring(state.minForceMoney) end
end)

FTInput.FocusLost:Connect(function()
    local num = tonumber(FTInput.Text)
    if num then state.forceDuration = num; saveSettings()
    else FTInput.Text = tostring(state.forceDuration) end
end)

FDefault.MouseButton1Click:Connect(function()
    playClickSound()
    state.minMoney = 10; state.minForceMoney = 100; state.forceDuration = 10
    MInput.Text = "10"; MFInput.Text = "100"; FTInput.Text = "10"
    MinMoneyInput.Text = "10"
    updateSettingsVisuals(); saveSettings()
end)

local function updateAntiErrorVisuals()
    AntiErrorBtn.Text = state.antiError and "Anti-Error: ON" or "Anti-Error: OFF"
    AntiErrorBtn.BackgroundColor3 = state.antiError and COLORS.Gold or COLORS.SectionBG
    AntiErrorBtn.TextColor3 = state.antiError and Color3.fromRGB(10,10,10) or COLORS.Gold
end
updateAntiErrorVisuals()
AntiErrorBtn.MouseButton1Click:Connect(function() playClickSound(); state.antiError = not state.antiError; updateAntiErrorVisuals(); saveSettings() end)

local function updateStatsVisuals()
    ShowFpsBtn.Text = state.showFps and "Show FPS: ON" or "Show FPS: OFF"
    ShowFpsBtn.BackgroundColor3 = state.showFps and COLORS.Gold or COLORS.SectionBG
    ShowFpsBtn.TextColor3 = state.showFps and Color3.fromRGB(10,10,10) or COLORS.Gold
    ShowPingBtn.Text = state.showPing and "Show Ping: ON" or "Show Ping: OFF"
    ShowPingBtn.BackgroundColor3 = state.showPing and COLORS.Gold or COLORS.SectionBG
    ShowPingBtn.TextColor3 = state.showPing and Color3.fromRGB(10,10,10) or COLORS.Gold
end
updateStatsVisuals()
ShowFpsBtn.MouseButton1Click:Connect(function() playClickSound(); state.showFps = not state.showFps; updateStatsVisuals(); saveSettings() end)
ShowPingBtn.MouseButton1Click:Connect(function() playClickSound(); state.showPing = not state.showPing; updateStatsVisuals(); saveSettings() end)

local function updateAntiLagVisuals()
    AntiLagBtn.Text = state.nuclearLagEnabled and "Fps Booster: ON" or "Fps Booster: OFF"
    AntiLagBtn.BackgroundColor3 = state.nuclearLagEnabled and COLORS.ForceActive or COLORS.SectionBG
    AntiLagBtn.TextColor3 = COLORS.TextWhite
end
updateAntiLagVisuals()
AntiLagBtn.MouseButton1Click:Connect(function()
    playClickSound(); state.nuclearLagEnabled = not state.nuclearLagEnabled
    if state.nuclearLagEnabled then task.spawn(activateNuclear) end
    updateAntiLagVisuals(); saveSettings()
end)

local function updateBlueBaseVisuals()
    BlueBaseBtn.Text = state.blueBaseEnabled and "Blue Base: ON" or "Blue Base: OFF"
    BlueBaseBtn.BackgroundColor3 = state.blueBaseEnabled and COLORS.Gold or COLORS.SectionBG
    BlueBaseBtn.TextColor3 = state.blueBaseEnabled and Color3.fromRGB(10,10,10) or COLORS.Gold
end
updateBlueBaseVisuals()
BlueBaseBtn.MouseButton1Click:Connect(function()
    playClickSound(); state.blueBaseEnabled = not state.blueBaseEnabled
    toggleBlueBaseFunc(state.blueBaseEnabled); updateBlueBaseVisuals(); saveSettings()
end)

-- BLACKLIST FRAME
BlacklistFrame.Size = UDim2.new(0, 320, 0, 380)
BlacklistFrame.BackgroundColor3 = COLORS.Background
BlacklistFrame.BorderSizePixel = 0
BlacklistFrame.Visible = false
BlacklistFrame.ClipsDescendants = true
BlacklistFrame.Parent = ScreenGui
Instance.new("UICorner", BlacklistFrame).CornerRadius = UDim.new(0, 16)
BLStroke = Instance.new("UIStroke")
BLStroke.Thickness = 2.5
BLStroke.Parent = BlacklistFrame

local BLStrokeGrad = Instance.new("UIGradient")
BLStrokeGrad.Color = ColorSequence.new{
    ColorSequenceKeypoint.new(0, Color3.fromRGB(255, 220, 80)),
    ColorSequenceKeypoint.new(0.25, Color3.fromRGB(255, 255, 180)),
    ColorSequenceKeypoint.new(0.5, Color3.fromRGB(212, 175, 55)),
    ColorSequenceKeypoint.new(0.75, Color3.fromRGB(255, 255, 180)),
    ColorSequenceKeypoint.new(1, Color3.fromRGB(255, 220, 80))
}
BLStrokeGrad.Parent = BLStroke
table.insert(activeGradients, BLStrokeGrad)
BLHeader = Instance.new("Frame")
BLHeader.Size = UDim2.new(1, 0, 0, 45)
BLHeader.BackgroundColor3 = Color3.fromRGB(8, 10, 18)
BLHeader.BorderSizePixel = 0
BLHeader.Parent = BlacklistFrame
Instance.new("UICorner", BLHeader).CornerRadius = UDim.new(0, 16)

BLTitle = Instance.new("TextLabel")
BLTitle.Text = "BLACKLIST PETS"
BLTitle.Font = Enum.Font.GothamBlack
BLTitle.TextSize = 14
BLTitle.TextColor3 = Color3.fromRGB(255,255,255)
BLTitle.Size = UDim2.new(1, 0, 1, 0)
BLTitle.TextXAlignment = Enum.TextXAlignment.Center
BLTitle.BackgroundTransparency = 1
BLTitle.Parent = BLHeader
local BLTitleGrad = Instance.new("UIGradient")
BLTitleGrad.Color = ColorSequence.new{
    ColorSequenceKeypoint.new(0, Color3.fromRGB(255, 220, 80)),
    ColorSequenceKeypoint.new(0.25, Color3.fromRGB(255, 255, 180)),
    ColorSequenceKeypoint.new(0.5, Color3.fromRGB(212, 175, 55)),
    ColorSequenceKeypoint.new(0.75, Color3.fromRGB(255, 255, 180)),
    ColorSequenceKeypoint.new(1, Color3.fromRGB(255, 220, 80))
}
BLTitleGrad.Parent = BLTitle
table.insert(activeGradients, BLTitleGrad)

BLClose = Instance.new("TextButton")
BLClose.Text = "✕"
BLClose.Size = UDim2.new(0, 24, 0, 24)
BLClose.Position = UDim2.new(1, -34, 0.5, -12)
BLClose.BackgroundTransparency = 1
BLClose.TextColor3 = COLORS.Gold
BLClose.Font = Enum.Font.GothamBold
BLClose.TextSize = 16
BLClose.Parent = BLHeader

TabsContainer = Instance.new("Frame")
TabsContainer.Size = UDim2.new(1, -20, 0, 30)
TabsContainer.Position = UDim2.new(0, 10, 0, 50)
TabsContainer.BackgroundTransparency = 1
TabsContainer.Parent = BlacklistFrame
TabsLayout = Instance.new("UIListLayout")
TabsLayout.FillDirection = Enum.FillDirection.Horizontal
TabsLayout.Padding = UDim.new(0, 5)
TabsLayout.Parent = TabsContainer

local tabButtons = {}
local function createTab(name)
    local btn = Instance.new("TextButton")
    btn.Text = name
    btn.Size = UDim2.new(0.31, 0, 1, 0)
    btn.BackgroundColor3 = (name == state.currentTab) and COLORS.Gold or COLORS.SectionBG
    btn.TextColor3 = (name == state.currentTab) and Color3.fromRGB(10,10,10) or COLORS.Gold
    btn.Font = Enum.Font.GothamBold
    btn.TextSize = 10
    btn.Parent = TabsContainer
    btn.AutoButtonColor = false
    Instance.new("UICorner", btn).CornerRadius = UDim.new(0, 6)
    local tStroke = Instance.new("UIStroke")
    tStroke.Thickness = 1
    tStroke.Parent = btn
    local tGrad = Instance.new("UIGradient")
    tGrad.Color = ColorSequence.new{
    ColorSequenceKeypoint.new(0, Color3.fromRGB(255, 200, 50)),
    ColorSequenceKeypoint.new(0.5, Color3.fromRGB(255, 255, 180)),
    ColorSequenceKeypoint.new(1, Color3.fromRGB(212, 175, 55))
}
    tGrad.Parent = tStroke
    table.insert(activeGradients, tGrad)
    tabButtons[name] = btn
    return btn
end
local TabBrainrot = createTab("Brainrot God")
local TabSecret = createTab("Secret")
local TabOG = createTab("OG")

SearchBar = Instance.new("TextBox")
SearchBar.Size = UDim2.new(1, -20, 0, 28)
SearchBar.Position = UDim2.new(0, 10, 0, 88)
SearchBar.BackgroundColor3 = COLORS.SectionBG
SearchBar.PlaceholderText = "Search name..."
SearchBar.Text = ""
SearchBar.TextColor3 = COLORS.Gold
SearchBar.Font = Enum.Font.Gotham
SearchBar.TextSize = 12
SearchBar.Parent = BlacklistFrame
Instance.new("UICorner", SearchBar).CornerRadius = UDim.new(0, 8)
SearchStroke = Instance.new("UIStroke")
SearchStroke.Thickness = 1.5
SearchStroke.Parent = SearchBar
local SearchGrad = Instance.new("UIGradient")
SearchGrad.Color = ColorSequence.new{
    ColorSequenceKeypoint.new(0, Color3.fromRGB(255, 200, 50)),
    ColorSequenceKeypoint.new(0.5, Color3.fromRGB(255, 255, 180)),
    ColorSequenceKeypoint.new(1, Color3.fromRGB(212, 175, 55))
}
SearchGrad.Parent = SearchStroke
table.insert(activeGradients, SearchGrad)

ActionsFrame = Instance.new("Frame")
ActionsFrame.Size = UDim2.new(1, -20, 0, 30)
ActionsFrame.Position = UDim2.new(0, 10, 0, 124)
ActionsFrame.BackgroundTransparency = 1
ActionsFrame.Parent = BlacklistFrame
SelectAllBtn = Instance.new("TextButton")
SelectAllBtn.Text = "Select All"
SelectAllBtn.Size = UDim2.new(0.48, 0, 1, 0)
SelectAllBtn.BackgroundColor3 = Color3.fromRGB(255,255,255)
SelectAllBtn.TextColor3 = Color3.fromRGB(10,10,10)
SelectAllBtn.Font = Enum.Font.GothamBold
SelectAllBtn.TextSize = 12
SelectAllBtn.Parent = ActionsFrame
Instance.new("UICorner", SelectAllBtn).CornerRadius = UDim.new(0, 6)
local SelectAllBtnGrad = Instance.new("UIGradient")
SelectAllBtnGrad.Color = ColorSequence.new{
    ColorSequenceKeypoint.new(0, Color3.fromRGB(255, 200, 50)),
    ColorSequenceKeypoint.new(0.5, Color3.fromRGB(255, 255, 180)),
    ColorSequenceKeypoint.new(1, Color3.fromRGB(212, 175, 55))
}
SelectAllBtnGrad.Parent = SelectAllBtn
table.insert(activeGradients, SelectAllBtnGrad)
local ClearBLBtn = Instance.new("TextButton")
ClearBLBtn.Text = "Clear"
ClearBLBtn.Size = UDim2.new(0.48, 0, 1, 0)
ClearBLBtn.Position = UDim2.new(0.52, 0, 0, 0)
ClearBLBtn.BackgroundColor3 = COLORS.SectionBG
ClearBLBtn.TextColor3 = COLORS.Gold
ClearBLBtn.Font = Enum.Font.GothamBold
ClearBLBtn.TextSize = 12
ClearBLBtn.Parent = ActionsFrame
Instance.new("UICorner", ClearBLBtn).CornerRadius = UDim.new(0, 6)

PetsScroll = Instance.new("ScrollingFrame")
PetsScroll.Size = UDim2.new(1, -12, 1, -165)
PetsScroll.Position = UDim2.new(0, 6, 0, 162)
PetsScroll.BackgroundTransparency = 1
PetsScroll.ScrollBarThickness = 2
PetsScroll.ScrollBarImageColor3 = COLORS.Gold
PetsScroll.Parent = BlacklistFrame
PetsGrid = Instance.new("UIGridLayout")
PetsGrid.CellSize = UDim2.new(0.48, 0, 0, 30)
PetsGrid.CellPadding = UDim2.new(0, 5, 0, 5)
PetsGrid.Parent = PetsScroll

-- AUTO FORCE FRAME
AutoForceFrame.Size = UDim2.new(0, 320, 0, 380)
AutoForceFrame.BackgroundColor3 = COLORS.Background
AutoForceFrame.Visible = false
AutoForceFrame.ClipsDescendants = true
AutoForceFrame.Parent = ScreenGui
Instance.new("UICorner", AutoForceFrame).CornerRadius = UDim.new(0, 16)
AFStroke = Instance.new("UIStroke")
AFStroke.Thickness = 2.5
AFStroke.Parent = AutoForceFrame

local AFStrokeGrad = Instance.new("UIGradient")
AFStrokeGrad.Color = ColorSequence.new{
    ColorSequenceKeypoint.new(0, Color3.fromRGB(255, 220, 80)),
    ColorSequenceKeypoint.new(0.25, Color3.fromRGB(255, 255, 180)),
    ColorSequenceKeypoint.new(0.5, Color3.fromRGB(212, 175, 55)),
    ColorSequenceKeypoint.new(0.75, Color3.fromRGB(255, 255, 180)),
    ColorSequenceKeypoint.new(1, Color3.fromRGB(255, 220, 80))
}
AFStrokeGrad.Parent = AFStroke
table.insert(activeGradients, AFStrokeGrad)
AFHeader = Instance.new("Frame")
AFHeader.Size = UDim2.new(1, 0, 0, 45)
AFHeader.BackgroundColor3 = Color3.fromRGB(8, 10, 18)
AFHeader.BorderSizePixel = 0
AFHeader.Parent = AutoForceFrame
Instance.new("UICorner", AFHeader).CornerRadius = UDim.new(0, 16)

AFTitle = Instance.new("TextLabel")
AFTitle.Text = "AUTO FORCE LIST"
AFTitle.Font = Enum.Font.GothamBlack
AFTitle.TextSize = 14
AFTitle.TextColor3 = Color3.fromRGB(255,255,255)
AFTitle.Size = UDim2.new(1, 0, 1, 0)
AFTitle.TextXAlignment = Enum.TextXAlignment.Center
AFTitle.BackgroundTransparency = 1
AFTitle.Parent = AFHeader
local AFTitleGrad = Instance.new("UIGradient")
AFTitleGrad.Color = ColorSequence.new{
    ColorSequenceKeypoint.new(0, Color3.fromRGB(255, 220, 80)),
    ColorSequenceKeypoint.new(0.25, Color3.fromRGB(255, 255, 180)),
    ColorSequenceKeypoint.new(0.5, Color3.fromRGB(212, 175, 55)),
    ColorSequenceKeypoint.new(0.75, Color3.fromRGB(255, 255, 180)),
    ColorSequenceKeypoint.new(1, Color3.fromRGB(255, 220, 80))
}
AFTitleGrad.Parent = AFTitle
table.insert(activeGradients, AFTitleGrad)

AFClose = Instance.new("TextButton")
AFClose.Text = "✕"
AFClose.Size = UDim2.new(0, 24, 0, 24)
AFClose.Position = UDim2.new(1, -34, 0.5, -12)
AFClose.BackgroundTransparency = 1
AFClose.TextColor3 = COLORS.Gold
AFClose.Font = Enum.Font.GothamBold
AFClose.TextSize = 16
AFClose.Parent = AFHeader

AFTabsContainer = Instance.new("Frame")
AFTabsContainer.Size = UDim2.new(1, -20, 0, 30)
AFTabsContainer.Position = UDim2.new(0, 10, 0, 50)
AFTabsContainer.BackgroundTransparency = 1
AFTabsContainer.Parent = AutoForceFrame
AFTabsLayout = Instance.new("UIListLayout")
AFTabsLayout.FillDirection = Enum.FillDirection.Horizontal
AFTabsLayout.Padding = UDim.new(0, 5)
AFTabsLayout.Parent = AFTabsContainer

local forceTabButtons = {}
local function createForceTab(name)
    local btn = Instance.new("TextButton")
    btn.Text = name
    btn.Size = UDim2.new(0.31, 0, 1, 0)
    btn.BackgroundColor3 = (name == state.currentForceTab) and COLORS.Gold or COLORS.SectionBG
    btn.TextColor3 = (name == state.currentForceTab) and Color3.fromRGB(10,10,10) or COLORS.Gold
    btn.Font = Enum.Font.GothamBold
    btn.TextSize = 10
    btn.Parent = AFTabsContainer
    btn.AutoButtonColor = false
    Instance.new("UICorner", btn).CornerRadius = UDim.new(0, 6)
    local tStroke = Instance.new("UIStroke")
    tStroke.Thickness = 1
    tStroke.Parent = btn
    local tGrad = Instance.new("UIGradient")
    tGrad.Color = ColorSequence.new{
    ColorSequenceKeypoint.new(0, Color3.fromRGB(255, 200, 50)),
    ColorSequenceKeypoint.new(0.5, Color3.fromRGB(255, 255, 180)),
    ColorSequenceKeypoint.new(1, Color3.fromRGB(212, 175, 55))
}
    tGrad.Parent = tStroke
    table.insert(activeGradients, tGrad)
    forceTabButtons[name] = btn
    return btn
end
local AFTabBrainrot = createForceTab("Brainrot God")
local AFTabSecret = createForceTab("Secret")
local AFTabOG = createForceTab("OG")

AFSearchBar = Instance.new("TextBox")
AFSearchBar.Size = UDim2.new(1, -20, 0, 28)
AFSearchBar.Position = UDim2.new(0, 10, 0, 88)
AFSearchBar.BackgroundColor3 = COLORS.SectionBG
AFSearchBar.PlaceholderText = "Search name..."
AFSearchBar.Text = ""
AFSearchBar.TextColor3 = COLORS.Gold
AFSearchBar.Font = Enum.Font.Gotham
AFSearchBar.TextSize = 12
AFSearchBar.Parent = AutoForceFrame
Instance.new("UICorner", AFSearchBar).CornerRadius = UDim.new(0, 8)
AFSearchStroke = Instance.new("UIStroke")
AFSearchStroke.Thickness = 1.5
AFSearchStroke.Parent = AFSearchBar
local AFSGrad = Instance.new("UIGradient")
AFSGrad.Color = ColorSequence.new{
    ColorSequenceKeypoint.new(0, Color3.fromRGB(255, 200, 50)),
    ColorSequenceKeypoint.new(0.5, Color3.fromRGB(255, 255, 180)),
    ColorSequenceKeypoint.new(1, Color3.fromRGB(212, 175, 55))
}
AFSGrad.Parent = AFSearchStroke
table.insert(activeGradients, AFSGrad)

AFActionsFrame = Instance.new("Frame")
AFActionsFrame.Size = UDim2.new(1, -20, 0, 30)
AFActionsFrame.Position = UDim2.new(0, 10, 0, 124)
AFActionsFrame.BackgroundTransparency = 1
AFActionsFrame.Parent = AutoForceFrame
AFSelectAllBtn = Instance.new("TextButton")
AFSelectAllBtn.Text = "Select All"
AFSelectAllBtn.Size = UDim2.new(0.48, 0, 1, 0)
AFSelectAllBtn.BackgroundColor3 = Color3.fromRGB(255,255,255)
AFSelectAllBtn.TextColor3 = Color3.fromRGB(10,10,10)
AFSelectAllBtn.Font = Enum.Font.GothamBold
AFSelectAllBtn.TextSize = 12
AFSelectAllBtn.Parent = AFActionsFrame
Instance.new("UICorner", AFSelectAllBtn).CornerRadius = UDim.new(0, 6)
local AFSelectAllBtnGrad = Instance.new("UIGradient")
AFSelectAllBtnGrad.Color = ColorSequence.new{
    ColorSequenceKeypoint.new(0, Color3.fromRGB(255, 200, 50)),
    ColorSequenceKeypoint.new(0.5, Color3.fromRGB(255, 255, 180)),
    ColorSequenceKeypoint.new(1, Color3.fromRGB(212, 175, 55))
}
AFSelectAllBtnGrad.Parent = AFSelectAllBtn
table.insert(activeGradients, AFSelectAllBtnGrad)
AFClearBtn = Instance.new("TextButton")
AFClearBtn.Text = "Clear"
AFClearBtn.Size = UDim2.new(0.48, 0, 1, 0)
AFClearBtn.Position = UDim2.new(0.52, 0, 0, 0)
AFClearBtn.BackgroundColor3 = COLORS.SectionBG
AFClearBtn.TextColor3 = COLORS.Gold
AFClearBtn.Font = Enum.Font.GothamBold
AFClearBtn.TextSize = 12
AFClearBtn.Parent = AFActionsFrame
Instance.new("UICorner", AFClearBtn).CornerRadius = UDim.new(0, 6)

AFPetsScroll = Instance.new("ScrollingFrame")
AFPetsScroll.Size = UDim2.new(1, -12, 1, -165)
AFPetsScroll.Position = UDim2.new(0, 6, 0, 162)
AFPetsScroll.BackgroundTransparency = 1
AFPetsScroll.ScrollBarThickness = 2
AFPetsScroll.ScrollBarImageColor3 = COLORS.Gold
AFPetsScroll.Parent = AutoForceFrame
AFPetsGrid = Instance.new("UIGridLayout")
AFPetsGrid.CellSize = UDim2.new(0.48, 0, 0, 30)
AFPetsGrid.CellPadding = UDim2.new(0, 5, 0, 5)
AFPetsGrid.Parent = AFPetsScroll

-- TARGET FRAME
TargetFrame.Size = UDim2.new(0, 320, 0, 380)
TargetFrame.BackgroundColor3 = COLORS.Background
TargetFrame.Visible = false
TargetFrame.ClipsDescendants = true
TargetFrame.Parent = ScreenGui
Instance.new("UICorner", TargetFrame).CornerRadius = UDim.new(0, 16)
TFStroke = Instance.new("UIStroke")
TFStroke.Thickness = 2.5
TFStroke.Parent = TargetFrame

local TFStrokeGrad = Instance.new("UIGradient")
TFStrokeGrad.Color = ColorSequence.new{
    ColorSequenceKeypoint.new(0, Color3.fromRGB(255, 220, 80)),
    ColorSequenceKeypoint.new(0.25, Color3.fromRGB(255, 255, 180)),
    ColorSequenceKeypoint.new(0.5, Color3.fromRGB(212, 175, 55)),
    ColorSequenceKeypoint.new(0.75, Color3.fromRGB(255, 255, 180)),
    ColorSequenceKeypoint.new(1, Color3.fromRGB(255, 220, 80))
}
TFStrokeGrad.Parent = TFStroke
table.insert(activeGradients, TFStrokeGrad)
TFHeader = Instance.new("Frame")
TFHeader.Size = UDim2.new(1, 0, 0, 45)
TFHeader.BackgroundColor3 = Color3.fromRGB(8, 10, 18)
TFHeader.BorderSizePixel = 0
TFHeader.Parent = TargetFrame
Instance.new("UICorner", TFHeader).CornerRadius = UDim.new(0, 16)

TFTitle = Instance.new("TextLabel")
TFTitle.Text = "TARGET LIST"
TFTitle.Font = Enum.Font.GothamBlack
TFTitle.TextSize = 14
TFTitle.TextColor3 = Color3.fromRGB(255,255,255)
TFTitle.Size = UDim2.new(1, 0, 1, 0)
TFTitle.TextXAlignment = Enum.TextXAlignment.Center
TFTitle.BackgroundTransparency = 1
TFTitle.Parent = TFHeader
local TFTitleGrad = Instance.new("UIGradient")
TFTitleGrad.Color = ColorSequence.new{
    ColorSequenceKeypoint.new(0, Color3.fromRGB(255, 220, 80)),
    ColorSequenceKeypoint.new(0.25, Color3.fromRGB(255, 255, 180)),
    ColorSequenceKeypoint.new(0.5, Color3.fromRGB(212, 175, 55)),
    ColorSequenceKeypoint.new(0.75, Color3.fromRGB(255, 255, 180)),
    ColorSequenceKeypoint.new(1, Color3.fromRGB(255, 220, 80))
}
TFTitleGrad.Parent = TFTitle
table.insert(activeGradients, TFTitleGrad)

TFClose = Instance.new("TextButton")
TFClose.Text = "✕"
TFClose.Size = UDim2.new(0, 24, 0, 24)
TFClose.Position = UDim2.new(1, -34, 0.5, -12)
TFClose.BackgroundTransparency = 1
TFClose.TextColor3 = COLORS.Gold
TFClose.Font = Enum.Font.GothamBold
TFClose.TextSize = 16
TFClose.Parent = TFHeader

TFTabsContainer = Instance.new("Frame")
TFTabsContainer.Size = UDim2.new(1, -20, 0, 30)
TFTabsContainer.Position = UDim2.new(0, 10, 0, 50)
TFTabsContainer.BackgroundTransparency = 1
TFTabsContainer.Parent = TargetFrame
TFTabsLayout = Instance.new("UIListLayout")
TFTabsLayout.FillDirection = Enum.FillDirection.Horizontal
TFTabsLayout.Padding = UDim.new(0, 5)
TFTabsLayout.Parent = TFTabsContainer

local targetTabButtons = {}
local function createTargetTab(name)
    local btn = Instance.new("TextButton")
    btn.Text = name
    btn.Size = UDim2.new(0.31, 0, 1, 0)
    btn.BackgroundColor3 = (name == state.currentTargetTab) and COLORS.Gold or COLORS.SectionBG
    btn.TextColor3 = (name == state.currentTargetTab) and Color3.fromRGB(10,10,10) or COLORS.Gold
    btn.Font = Enum.Font.GothamBold
    btn.TextSize = 10
    btn.Parent = TFTabsContainer
    btn.AutoButtonColor = false
    Instance.new("UICorner", btn).CornerRadius = UDim.new(0, 6)
    local tStroke = Instance.new("UIStroke")
    tStroke.Thickness = 1
    tStroke.Parent = btn
    local tGrad = Instance.new("UIGradient")
    tGrad.Color = ColorSequence.new{
    ColorSequenceKeypoint.new(0, Color3.fromRGB(255, 200, 50)),
    ColorSequenceKeypoint.new(0.5, Color3.fromRGB(255, 255, 180)),
    ColorSequenceKeypoint.new(1, Color3.fromRGB(212, 175, 55))
}
    tGrad.Parent = tStroke
    table.insert(activeGradients, tGrad)
    targetTabButtons[name] = btn
    return btn
end
local TFTabBrainrot = createTargetTab("Brainrot God")
local TFTabSecret = createTargetTab("Secret")
local TFTabOG = createTargetTab("OG")

TFSearchBar = Instance.new("TextBox")
TFSearchBar.Size = UDim2.new(1, -20, 0, 28)
TFSearchBar.Position = UDim2.new(0, 10, 0, 88)
TFSearchBar.BackgroundColor3 = COLORS.SectionBG
TFSearchBar.PlaceholderText = "Search name..."
TFSearchBar.Text = ""
TFSearchBar.TextColor3 = COLORS.Gold
TFSearchBar.Font = Enum.Font.Gotham
TFSearchBar.TextSize = 12
TFSearchBar.Parent = TargetFrame
Instance.new("UICorner", TFSearchBar).CornerRadius = UDim.new(0, 8)

TFActionsFrame = Instance.new("Frame")
TFActionsFrame.Size = UDim2.new(1, -20, 0, 30)
TFActionsFrame.Position = UDim2.new(0, 10, 0, 124)
TFActionsFrame.BackgroundTransparency = 1
TFActionsFrame.Parent = TargetFrame
TFSelectAllBtn = Instance.new("TextButton")
TFSelectAllBtn.Text = "Select All"
TFSelectAllBtn.Size = UDim2.new(0.48, 0, 1, 0)
TFSelectAllBtn.BackgroundColor3 = Color3.fromRGB(255,255,255)
TFSelectAllBtn.TextColor3 = Color3.fromRGB(10,10,10)
TFSelectAllBtn.Font = Enum.Font.GothamBold
TFSelectAllBtn.TextSize = 12
TFSelectAllBtn.Parent = TFActionsFrame
Instance.new("UICorner", TFSelectAllBtn).CornerRadius = UDim.new(0, 6)
local TFSelectAllBtnGrad = Instance.new("UIGradient")
TFSelectAllBtnGrad.Color = ColorSequence.new{
    ColorSequenceKeypoint.new(0, Color3.fromRGB(255, 200, 50)),
    ColorSequenceKeypoint.new(0.5, Color3.fromRGB(255, 255, 180)),
    ColorSequenceKeypoint.new(1, Color3.fromRGB(212, 175, 55))
}
TFSelectAllBtnGrad.Parent = TFSelectAllBtn
table.insert(activeGradients, TFSelectAllBtnGrad)
TFClearBtn = Instance.new("TextButton")
TFClearBtn.Text = "Clear"
TFClearBtn.Size = UDim2.new(0.48, 0, 1, 0)
TFClearBtn.Position = UDim2.new(0.52, 0, 0, 0)
TFClearBtn.BackgroundColor3 = COLORS.SectionBG
TFClearBtn.TextColor3 = COLORS.Gold
TFClearBtn.Font = Enum.Font.GothamBold
TFClearBtn.TextSize = 12
TFClearBtn.Parent = TFActionsFrame
Instance.new("UICorner", TFClearBtn).CornerRadius = UDim.new(0, 6)

TFPetsScroll = Instance.new("ScrollingFrame")
TFPetsScroll.Size = UDim2.new(1, -12, 1, -210)
TFPetsScroll.Position = UDim2.new(0, 6, 0, 162)
TFPetsScroll.BackgroundTransparency = 1
TFPetsScroll.ScrollBarThickness = 2
TFPetsScroll.ScrollBarImageColor3 = COLORS.Gold
TFPetsScroll.Parent = TargetFrame
TFPetsGrid = Instance.new("UIGridLayout")
TFPetsGrid.CellSize = UDim2.new(0.48, 0, 0, 30)
TFPetsGrid.CellPadding = UDim2.new(0, 5, 0, 5)
TFPetsGrid.Parent = TFPetsScroll

-- CONFIG FRAME
ConfigFrame.Size = UDim2.new(0, 280, 0, 200)
ConfigFrame.BackgroundColor3 = COLORS.Background
ConfigFrame.Visible = false
ConfigFrame.ClipsDescendants = true
ConfigFrame.Parent = ScreenGui
Instance.new("UICorner", ConfigFrame).CornerRadius = UDim.new(0, 16)
CFStroke = Instance.new("UIStroke")
CFStroke.Thickness = 2.5
CFStroke.Parent = ConfigFrame

local CFStrokeGrad = Instance.new("UIGradient")
CFStrokeGrad.Color = ColorSequence.new{
    ColorSequenceKeypoint.new(0, Color3.fromRGB(255, 220, 80)),
    ColorSequenceKeypoint.new(0.25, Color3.fromRGB(255, 255, 180)),
    ColorSequenceKeypoint.new(0.5, Color3.fromRGB(212, 175, 55)),
    ColorSequenceKeypoint.new(0.75, Color3.fromRGB(255, 255, 180)),
    ColorSequenceKeypoint.new(1, Color3.fromRGB(255, 220, 80))
}
CFStrokeGrad.Parent = CFStroke
table.insert(activeGradients, CFStrokeGrad)
CFHeader = Instance.new("Frame")
CFHeader.Size = UDim2.new(1, 0, 0, 45)
CFHeader.BackgroundColor3 = Color3.fromRGB(8, 10, 18)
CFHeader.BorderSizePixel = 0
CFHeader.Parent = ConfigFrame
Instance.new("UICorner", CFHeader).CornerRadius = UDim.new(0, 16)

CFTitle = Instance.new("TextLabel")
CFTitle.Text = "CONFIG"
CFTitle.Font = Enum.Font.GothamBlack
CFTitle.TextSize = 14
CFTitle.TextColor3 = Color3.fromRGB(255,255,255)
CFTitle.Size = UDim2.new(1, 0, 1, 0)
CFTitle.TextXAlignment = Enum.TextXAlignment.Center
CFTitle.BackgroundTransparency = 1
CFTitle.Parent = CFHeader
local CFTitleGrad = Instance.new("UIGradient")
CFTitleGrad.Color = ColorSequence.new{
    ColorSequenceKeypoint.new(0, Color3.fromRGB(255, 220, 80)),
    ColorSequenceKeypoint.new(0.25, Color3.fromRGB(255, 255, 180)),
    ColorSequenceKeypoint.new(0.5, Color3.fromRGB(212, 175, 55)),
    ColorSequenceKeypoint.new(0.75, Color3.fromRGB(255, 255, 180)),
    ColorSequenceKeypoint.new(1, Color3.fromRGB(255, 220, 80))
}
CFTitleGrad.Parent = CFTitle
table.insert(activeGradients, CFTitleGrad)

CFClose = Instance.new("TextButton")
CFClose.Text = "✕"
CFClose.Size = UDim2.new(0, 24, 0, 24)
CFClose.Position = UDim2.new(1, -34, 0.5, -12)
CFClose.BackgroundTransparency = 1
CFClose.TextColor3 = COLORS.Gold
CFClose.Font = Enum.Font.GothamBold
CFClose.TextSize = 16
CFClose.Parent = CFHeader

local CFScroll = Instance.new("ScrollingFrame")
CFScroll.Size = UDim2.new(1, -20, 1, -55)
CFScroll.Position = UDim2.new(0, 10, 0, 50)
CFScroll.BackgroundTransparency = 1
CFScroll.ScrollBarThickness = 2
CFScroll.ScrollBarImageColor3 = COLORS.Gold
CFScroll.AutomaticCanvasSize = Enum.AutomaticSize.Y
CFScroll.CanvasSize = UDim2.new(0,0,0,0)
CFScroll.BorderSizePixel = 0
CFScroll.Parent = ConfigFrame
CFLayout = Instance.new("UIListLayout")
CFLayout.Padding = UDim.new(0, 8)
CFLayout.Parent = CFScroll


-- Compatibility bridges for logic section
TLBrainrot = TFTabBrainrot
TLSecret = TFTabSecret
TLOG = TFTabOG
TLSearchBar = TFSearchBar
TLPetsScroll = TFPetsScroll
ClearBtn = ClearBLBtn
AFBrainrot = AFTabBrainrot
AFSecret = AFTabSecret
AFOG = AFTabOG

-- Additional uiElements needed by logic
uiElements.TLSelectAllBtn = TFSelectAllBtn
uiElements.TLClearBtn = TFClearBtn
uiElements.ConfigOpenBtn = Instance.new("TextButton")
uiElements.ConfigOpenBtn.Text = "Configure Target M/s ▶"
uiElements.ConfigOpenBtn.Size = UDim2.new(1, -20, 0, 30)
uiElements.ConfigOpenBtn.Position = UDim2.new(0, 10, 1, -45)
uiElements.ConfigOpenBtn.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
uiElements.ConfigOpenBtn.TextColor3 = Color3.fromRGB(10, 10, 10)
uiElements.ConfigOpenBtn.Font = Enum.Font.GothamBold
uiElements.ConfigOpenBtn.TextSize = 12
uiElements.ConfigOpenBtn.AutoButtonColor = false
uiElements.ConfigOpenBtn.Parent = TargetFrame
Instance.new("UICorner", uiElements.ConfigOpenBtn).CornerRadius = UDim.new(0, 6)
local ConfigBtnGrad = Instance.new("UIGradient")
ConfigBtnGrad.Color = ColorSequence.new{
    ColorSequenceKeypoint.new(0, Color3.fromRGB(255, 220, 80)),
    ColorSequenceKeypoint.new(0.25, Color3.fromRGB(255, 255, 180)),
    ColorSequenceKeypoint.new(0.5, Color3.fromRGB(212, 175, 55)),
    ColorSequenceKeypoint.new(0.75, Color3.fromRGB(255, 255, 180)),
    ColorSequenceKeypoint.new(1, Color3.fromRGB(255, 220, 80))
}
ConfigBtnGrad.Parent = uiElements.ConfigOpenBtn
table.insert(activeGradients, ConfigBtnGrad)

uiElements.CFClose = CFClose
uiElements.TLClose = TFClose

-- Config search bar
ConfigSearchBar = Instance.new("TextBox")
ConfigSearchBar.Size = UDim2.new(1, -20, 0, 25)
ConfigSearchBar.Position = UDim2.new(0, 10, 0, 50)
ConfigSearchBar.BackgroundColor3 = COLORS.SectionBG
ConfigSearchBar.PlaceholderText = "Search name..."
ConfigSearchBar.Text = ""
ConfigSearchBar.TextColor3 = COLORS.Gold
ConfigSearchBar.Font = Enum.Font.Gotham
ConfigSearchBar.TextSize = 12
ConfigSearchBar.Parent = ConfigFrame
Instance.new("UICorner", ConfigSearchBar).CornerRadius = UDim.new(0, 6)

CFScroll2 = Instance.new("ScrollingFrame")
CFScroll2.Size = UDim2.new(1, -10, 1, -85)
CFScroll2.Position = UDim2.new(0, 5, 0, 80)
CFScroll2.BackgroundTransparency = 1
CFScroll2.ScrollBarThickness = 2
CFScroll2.ScrollBarImageColor3 = COLORS.Gold
CFScroll2.Parent = ConfigFrame
CFListLayout = Instance.new("UIListLayout")
CFListLayout.Padding = UDim.new(0, 8)
CFListLayout.SortOrder = Enum.SortOrder.LayoutOrder
CFListLayout.Parent = CFScroll2
CFScroll = CFScroll2

local function updateConfigList()
    for _, ch in pairs(CFScroll:GetChildren()) do
        if ch:IsA("Frame") or ch:IsA("TextLabel") then ch:Destroy() end
    end

    local sortedPets = {}
    for petName, isActive in pairs(state.targetList) do
        if isActive then table.insert(sortedPets, petName) end
    end
    table.sort(sortedPets)

    local searchText = string.lower(ConfigSearchBar.Text)

    for _, petName in ipairs(sortedPets) do
        if searchText == "" or string.find(string.lower(petName), searchText) then
            local row = Instance.new("Frame")
            row.Size = UDim2.new(1, -10, 0, 35)
            row.BackgroundColor3 = Color3.fromRGB(20, 23, 35)
            row.BorderSizePixel = 0
            row.Parent = CFScroll
            Instance.new("UICorner", row).CornerRadius = UDim.new(0, 8)
            
            local rStroke = Instance.new("UIStroke")
            rStroke.Color = Color3.fromRGB(40, 45, 70)
            rStroke.Thickness = 1
            rStroke.ApplyStrokeMode = Enum.ApplyStrokeMode.Border
            rStroke.Parent = row
            
            local pName = Instance.new("TextLabel")
            pName.Text = petName
            pName.Size = UDim2.new(0.55, 0, 1, 0)
            pName.Position = UDim2.new(0, 10, 0, 0)
            pName.BackgroundTransparency = 1
            pName.TextColor3 = COLORS.TextWhite
            pName.Font = Enum.Font.GothamMedium
            pName.TextSize = 12
            pName.TextXAlignment = Enum.TextXAlignment.Left
            pName.TextTruncate = Enum.TextTruncate.AtEnd
            pName.Parent = row
            
            local inputBg = Instance.new("Frame")
            inputBg.Size = UDim2.new(0, 50, 0, 22)
            inputBg.AnchorPoint = Vector2.new(1, 0.5)
            inputBg.Position = UDim2.new(1, -35, 0.5, 0)
            inputBg.BackgroundColor3 = Color3.fromRGB(13, 15, 25)
            inputBg.Parent = row
            Instance.new("UICorner", inputBg).CornerRadius = UDim.new(0, 6)
            
            local iStroke = Instance.new("UIStroke")
            iStroke.Color = COLORS.Stroke
            iStroke.Thickness = 1
            iStroke.Parent = inputBg
            
            local tBox = Instance.new("TextBox")
            tBox.Size = UDim2.new(1, 0, 1, 0)
            tBox.BackgroundTransparency = 1
            tBox.TextColor3 = COLORS.Stroke
            tBox.Font = Enum.Font.GothamBold
            tBox.TextSize = 12
            
            local currentVal = state.targetLimits[petName]
            if currentVal and currentVal > 0 then
                tBox.Text = tostring(currentVal)
            else
                tBox.Text = "0"
            end
            
            tBox.Parent = inputBg
            
            local suffix = Instance.new("TextLabel")
            suffix.Text = "M/s"
            suffix.Size = UDim2.new(0, 30, 1, 0)
            suffix.AnchorPoint = Vector2.new(1, 0.5)
            suffix.Position = UDim2.new(1, -2, 0.5, 0)
            suffix.BackgroundTransparency = 1
            suffix.TextColor3 = COLORS.TextWhite
            suffix.Font = Enum.Font.GothamBold
            suffix.TextSize = 11
            suffix.Parent = row
            
            tBox.FocusLost:Connect(function()
                local val = tonumber(tBox.Text)
                if val then
                    state.targetLimits[petName] = val
                    saveSettings()
                    refreshLogs()
                else
                    tBox.Text = tostring(state.targetLimits[petName] or 0)
                end
            end)
        end
    end
    
    CFScroll.CanvasSize = UDim2.new(0, 0, 0, CFListLayout.AbsoluteContentSize.Y + 10)
end

ConfigSearchBar:GetPropertyChangedSignal("Text"):Connect(updateConfigList)

local function refreshLogs()
    if not uiElements.LogScroll then return end
    local isTargetMode = false
    for _ in pairs(state.targetList) do isTargetMode = true; break end

    for _, row in ipairs(uiElements.LogScroll:GetChildren()) do
        if row:IsA("Frame") then
            local nameLabel = row:FindFirstChild("PetName", true)
            if nameLabel then
                local petName = nameLabel.Text
                local shouldDestroy = false
                if state.blacklist[petName] then shouldDestroy = true end
                if not shouldDestroy and isTargetMode and not state.targetList[petName] then shouldDestroy = true end
                if shouldDestroy then row:Destroy() end
            end
        end
    end
end

local function toggleFilters()
    state.filtersOpen = not state.filtersOpen
    if state.filtersOpen then
        FiltersFrame.Visible = true
        TweenService:Create(FiltersFrame, TweenInfo.new(0.3, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), {Position = UDim2.new(MainFrame.Position.X.Scale, MainFrame.Position.X.Offset - FiltersFrame.Size.X.Offset - 10, MainFrame.Position.Y.Scale, MainFrame.Position.Y.Offset)}):Play()
    else
        TweenService:Create(FiltersFrame, TweenInfo.new(0.2), {Position = UDim2.new(MainFrame.Position.X.Scale, MainFrame.Position.X.Offset, MainFrame.Position.Y.Scale, MainFrame.Position.Y.Offset)}):Play()
        task.delay(0.2, function() if not state.filtersOpen then FiltersFrame.Visible = false end end)
    end
end

local function toggleBlacklist()
    state.blacklistOpen = not state.blacklistOpen
    if state.blacklistOpen then
        if state.autoForceOpen then state.autoForceOpen = false; AutoForceFrame.Visible = false end
        if state.targetListOpen then 
            state.targetListOpen = false; TargetFrame.Visible = false; 
            state.targetConfigOpen = false; ConfigFrame.Visible = false 
        end
        BlacklistFrame.Visible = true
        TweenService:Create(BlacklistFrame, TweenInfo.new(0.3, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), {Position = UDim2.new(MainFrame.Position.X.Scale, MainFrame.Position.X.Offset + MainFrame.Size.X.Offset + 10, MainFrame.Position.Y.Scale, MainFrame.Position.Y.Offset)}):Play()
    else
        TweenService:Create(BlacklistFrame, TweenInfo.new(0.2), {Position = UDim2.new(MainFrame.Position.X.Scale, MainFrame.Position.X.Offset, MainFrame.Position.Y.Scale, MainFrame.Position.Y.Offset)}):Play()
        task.delay(0.2, function() if not state.blacklistOpen then BlacklistFrame.Visible = false end end)
    end
end

local function toggleAutoForce()
    state.autoForceOpen = not state.autoForceOpen
    if state.autoForceOpen then
        if state.blacklistOpen then state.blacklistOpen = false; BlacklistFrame.Visible = false end
        if state.targetListOpen then 
            state.targetListOpen = false; TargetFrame.Visible = false; 
            state.targetConfigOpen = false; ConfigFrame.Visible = false 
        end
        AutoForceFrame.Visible = true
        TweenService:Create(AutoForceFrame, TweenInfo.new(0.3, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), {Position = UDim2.new(MainFrame.Position.X.Scale, MainFrame.Position.X.Offset + MainFrame.Size.X.Offset + 10, MainFrame.Position.Y.Scale, MainFrame.Position.Y.Offset)}):Play()
    else
        TweenService:Create(AutoForceFrame, TweenInfo.new(0.2), {Position = UDim2.new(MainFrame.Position.X.Scale, MainFrame.Position.X.Offset, MainFrame.Position.Y.Scale, MainFrame.Position.Y.Offset)}):Play()
        task.delay(0.2, function() if not state.autoForceOpen then AutoForceFrame.Visible = false end end)
    end
end

local function toggleTargetList()
    state.targetListOpen = not state.targetListOpen
    if state.targetListOpen then
        if state.blacklistOpen then toggleBlacklist() end
        if state.autoForceOpen then toggleAutoForce() end
        TargetFrame.Visible = true
        TweenService:Create(TargetFrame, TweenInfo.new(0.3, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), {Position = UDim2.new(MainFrame.Position.X.Scale, MainFrame.Position.X.Offset + MainFrame.Size.X.Offset + 10, MainFrame.Position.Y.Scale, MainFrame.Position.Y.Offset)}):Play()
    else
         TweenService:Create(TargetFrame, TweenInfo.new(0.2), {Position = UDim2.new(MainFrame.Position.X.Scale, MainFrame.Position.X.Offset, MainFrame.Position.Y.Scale, MainFrame.Position.Y.Offset)}):Play()
         task.delay(0.2, function() if not state.targetListOpen then TargetFrame.Visible = false end end)
         if state.targetConfigOpen then 
             state.targetConfigOpen = false
             ConfigFrame.Visible = false
         end
    end
end

local function toggleTargetConfig()
    state.targetConfigOpen = not state.targetConfigOpen
    if state.targetConfigOpen then
        updateConfigList()
        local targetX = TargetFrame.Position.X.Offset
        local targetY = TargetFrame.Position.Y.Offset
        local targetW = TargetFrame.Size.X.Offset
        local targetScale = TargetFrame.Position.X.Scale
        local targetYScale = TargetFrame.Position.Y.Scale
        ConfigFrame.Position = UDim2.new(targetScale, targetX + targetW + 10, targetYScale, targetY)
        ConfigFrame.Visible = true
    else
        ConfigFrame.Visible = false
    end
end

local function updatePetGrid()
    for _, child in ipairs(PetsScroll:GetChildren()) do if child:IsA("TextButton") then child:Destroy() end end
    local pets = PET_DATABASE[state.currentTab] or {}
    local searchText = string.lower(SearchBar.Text)
    local petButtons = {}
    for _, petName in ipairs(pets) do
        if searchText == "" or string.find(string.lower(petName), searchText) then
            local btn = Instance.new("TextButton")
            btn.Text = petName
            btn.Font = Enum.Font.GothamBold
            btn.TextSize = 10
            btn.TextColor3 = COLORS.TextWhite
            btn.BackgroundColor3 = state.blacklist[petName] and COLORS.Selected or COLORS.ButtonBG
            btn.Parent = PetsScroll
            Instance.new("UICorner", btn).CornerRadius = UDim.new(0, 6)
            btn.MouseButton1Click:Connect(function()
                playClickSound()
                if state.blacklist[petName] then state.blacklist[petName] = nil; btn.BackgroundColor3 = COLORS.ButtonBG
                else state.blacklist[petName] = true; btn.BackgroundColor3 = COLORS.Selected end
                saveSettings(); refreshLogs()
            end)
            table.insert(petButtons, btn)
        end
    end
    PetsScroll.CanvasSize = UDim2.new(0, 0, 0, math.ceil(#petButtons / 2) * 35)
end

local function updateAutoForceGrid()
    for _, child in ipairs(AFPetsScroll:GetChildren()) do if child:IsA("TextButton") then child:Destroy() end end
    local pets = PET_DATABASE[state.currentForceTab] or {}
    local searchText = string.lower(AFSearchBar.Text)
    local petButtons = {}
    for _, petName in ipairs(pets) do
        if searchText == "" or string.find(string.lower(petName), searchText) then
            local btn = Instance.new("TextButton")
            btn.Text = petName
            btn.Font = Enum.Font.GothamBold
            btn.TextSize = 10
            btn.TextColor3 = COLORS.TextWhite
            btn.BackgroundColor3 = state.autoForceList[petName] and COLORS.Selected or COLORS.ButtonBG
            btn.Parent = AFPetsScroll
            Instance.new("UICorner", btn).CornerRadius = UDim.new(0, 6)
            btn.MouseButton1Click:Connect(function()
                playClickSound()
                if state.autoForceList[petName] then state.autoForceList[petName] = nil; btn.BackgroundColor3 = COLORS.ButtonBG
                else state.autoForceList[petName] = true; btn.BackgroundColor3 = COLORS.Selected end
                saveSettings()
            end)
            table.insert(petButtons, btn)
        end
    end
    AFPetsScroll.CanvasSize = UDim2.new(0, 0, 0, math.ceil(#petButtons / 2) * 35)
end

local function updateTargetGrid()
    for _, child in ipairs(TLPetsScroll:GetChildren()) do if child:IsA("TextButton") then child:Destroy() end end
    local pets = PET_DATABASE[state.currentTargetTab] or {}
    local searchText = string.lower(TLSearchBar.Text)
    local petButtons = {}
    
    for _, petName in ipairs(pets) do
        if searchText == "" or string.find(string.lower(petName), searchText) then
            local btn = Instance.new("TextButton")
            btn.Text = petName
            btn.Font = Enum.Font.GothamBold
            btn.TextSize = 10
            btn.TextColor3 = COLORS.TextWhite
            btn.BackgroundColor3 = state.targetList[petName] and COLORS.Selected or COLORS.ButtonBG
            btn.Parent = TLPetsScroll
            Instance.new("UICorner", btn).CornerRadius = UDim.new(0, 6)
            
            btn.MouseButton1Click:Connect(function()
                playClickSound()
                if state.targetList[petName] then 
                    state.targetList[petName] = nil
                    state.targetLimits[petName] = nil 
                    btn.BackgroundColor3 = COLORS.ButtonBG
                else 
                    state.targetList[petName] = true
                    btn.BackgroundColor3 = COLORS.Selected 
                end
                saveSettings()
                refreshLogs() 
                if state.targetConfigOpen then updateConfigList() end
            end)
            table.insert(petButtons, btn)
        end
    end
    TLPetsScroll.CanvasSize = UDim2.new(0, 0, 0, math.ceil(#petButtons / 2) * 35)
end

local function switchTab(tabName)
    state.currentTab = tabName
    for name, btn in pairs(tabButtons) do
        btn.BackgroundColor3 = (name == tabName) and COLORS.Selected or COLORS.ButtonBG
        btn.TextColor3 = COLORS.TextWhite
    end
    updatePetGrid()
end

local function switchForceTab(tabName)
    state.currentForceTab = tabName
    for name, btn in pairs(forceTabButtons) do
        btn.BackgroundColor3 = (name == tabName) and COLORS.Selected or COLORS.ButtonBG
        btn.TextColor3 = COLORS.TextWhite
    end
    updateAutoForceGrid()
end

local function switchTargetTab(tabName)
    state.currentTargetTab = tabName
    for name, btn in pairs(targetTabButtons) do
        btn.BackgroundColor3 = (name == tabName) and COLORS.Selected or COLORS.ButtonBG
    end
    updateTargetGrid()
end

TabBrainrot.MouseButton1Click:Connect(function() playClickSound(); switchTab("Brainrot God") end)
TabSecret.MouseButton1Click:Connect(function() playClickSound(); switchTab("Secret") end)
TabOG.MouseButton1Click:Connect(function() playClickSound(); switchTab("OG") end)
SearchBar:GetPropertyChangedSignal("Text"):Connect(updatePetGrid)

AFBrainrot.MouseButton1Click:Connect(function() playClickSound(); switchForceTab("Brainrot God") end)
AFSecret.MouseButton1Click:Connect(function() playClickSound(); switchForceTab("Secret") end)
AFOG.MouseButton1Click:Connect(function() playClickSound(); switchForceTab("OG") end)
AFSearchBar:GetPropertyChangedSignal("Text"):Connect(updateAutoForceGrid)

TLBrainrot.MouseButton1Click:Connect(function() playClickSound(); switchTargetTab("Brainrot God") end)
TLSecret.MouseButton1Click:Connect(function() playClickSound(); switchTargetTab("Secret") end)
TLOG.MouseButton1Click:Connect(function() playClickSound(); switchTargetTab("OG") end)
TLSearchBar:GetPropertyChangedSignal("Text"):Connect(updateTargetGrid)

SelectAllBtn.MouseButton1Click:Connect(function()
    playClickSound()
    local pets = PET_DATABASE[state.currentTab] or {}
    for _, petName in ipairs(pets) do state.blacklist[petName] = true end
    updatePetGrid(); saveSettings(); refreshLogs()
end)
ClearBtn.MouseButton1Click:Connect(function()
    playClickSound()
    local pets = PET_DATABASE[state.currentTab] or {}
    for _, petName in ipairs(pets) do state.blacklist[petName] = nil end
    updatePetGrid(); saveSettings()
end)

AFSelectAllBtn.MouseButton1Click:Connect(function()
    playClickSound()
    local pets = PET_DATABASE[state.currentForceTab] or {}
    for _, petName in ipairs(pets) do state.autoForceList[petName] = true end
    updateAutoForceGrid(); saveSettings()
end)
AFClearBtn.MouseButton1Click:Connect(function()
    playClickSound()
    local pets = PET_DATABASE[state.currentForceTab] or {}
    for _, petName in ipairs(pets) do state.autoForceList[petName] = nil end
    updateAutoForceGrid(); saveSettings()
end)

uiElements.TLSelectAllBtn.MouseButton1Click:Connect(function()
    playClickSound()
    local pets = PET_DATABASE[state.currentTargetTab] or {}
    for _, petName in ipairs(pets) do state.targetList[petName] = true end
    updateTargetGrid(); saveSettings(); refreshLogs()
    if state.targetConfigOpen then updateConfigList() end
end)
uiElements.TLClearBtn.MouseButton1Click:Connect(function()
    playClickSound()
    local pets = PET_DATABASE[state.currentTargetTab] or {}
    for _, petName in ipairs(pets) do 
        state.targetList[petName] = nil 
        state.targetLimits[petName] = nil
    end
    updateTargetGrid(); saveSettings(); refreshLogs()
    if state.targetConfigOpen then updateConfigList() end
end)
FilterBtn.MouseButton1Click:Connect(function() playClickSound(); toggleFilters() end);
FClose.MouseButton1Click:Connect(function() playClickSound(); toggleFilters() end)

BlacklistOpenBtn.MouseButton1Click:Connect(function() playClickSound(); toggleBlacklist() end);
BLClose.MouseButton1Click:Connect(function() playClickSound(); toggleBlacklist() end)

AutoForceListBtn.MouseButton1Click:Connect(function() playClickSound(); toggleAutoForce() end);
AFClose.MouseButton1Click:Connect(function() playClickSound(); toggleAutoForce() end)

uiElements.TargetListBtn.MouseButton1Click:Connect(function() playClickSound(); toggleTargetList() end)
uiElements.TLClose.MouseButton1Click:Connect(function() playClickSound(); toggleTargetList() end)
uiElements.ConfigOpenBtn.MouseButton1Click:Connect(function() playClickSound(); toggleTargetConfig() end)
uiElements.CFClose.MouseButton1Click:Connect(function() playClickSound(); toggleTargetConfig() end)

AutoJoinBtn.MouseButton1Click:Connect(function()
    playClickSound()
    state.autoJoin = not state.autoJoin
    updateSettingsVisuals()
    saveSettings()
end)

AutoForceJoinBtn.MouseButton1Click:Connect(function()
    playClickSound()
    state.autoForceJoin = not state.autoForceJoin
    updateSettingsVisuals()
    saveSettings()
end)

updatePetGrid()
updateAutoForceGrid()
updateTargetGrid()
updateConfigList()


-- Top buttons logic
ClearLogsBtn.MouseButton1Click:Connect(function()
    playClickSound()
    for _, child in ipairs(LogScroll:GetChildren()) do
        if child:IsA("Frame") then child:Destroy() end
    end
    StatusLabel.Visible = true
end)

AutoJoinTopBtn.MouseButton1Click:Connect(function()
    playClickSound()
    state.autoJoin = not state.autoJoin
    updateSettingsVisuals()
    saveSettings()
end)

AutoForceTopBtn.MouseButton1Click:Connect(function()
    playClickSound()
    state.autoForceJoin = not state.autoForceJoin
    updateSettingsVisuals()
    saveSettings()
end)

BlacklistTopBtn.MouseButton1Click:Connect(function()
    playClickSound()
    toggleBlacklist()
end)

MinMoneyInput.FocusLost:Connect(function()
    local num = tonumber(MinMoneyInput.Text)
    if num then state.minMoney = num; MInput.Text = tostring(num); saveSettings()
    else MinMoneyInput.Text = tostring(state.minMoney) end
end)

local function createLog(data)
    pcall(function()
        local rawMoney = cleanMoney(data.money)
        local moneyVal = getNormalizedMoney(rawMoney) 
        local petName = data.name or "Unknown"

        if state.blacklist[petName] then return end

        local isTargetMode = false
        for _ in pairs(state.targetList) do isTargetMode = true; break end 

        if isTargetMode then
            if not state.targetList[petName] then return end
            
            local specificLimit = state.targetLimits[petName] or 0 
            if moneyVal < specificLimit then return end
        else
            if moneyVal < state.minMoney then return end
        end
        
        if uiElements.StatusLabel and uiElements.StatusLabel.Visible then
            uiElements.StatusLabel.Visible = false
        end

        local tierColor = COLORS.Gold

        local shouldForce = false
        
        if state.autoForceJoin and state.autoForceList[petName] then 
            shouldForce = true 
        elseif state.autoForceJoin and moneyVal >= state.minForceMoney then 
            if not isTargetMode or not state.targetList[petName] then
                shouldForce = true 
            end
        end

        local row = Instance.new("Frame")
        row.Name = data.jobid 
        row.Size = UDim2.new(1, 0, 0, 45) 
        row.BackgroundColor3 = Color3.fromRGB(10, 12, 22) 
        row.BorderSizePixel = 0
        row.Parent = LogScroll
        
        local rowCorner = Instance.new("UICorner", row)
        rowCorner.CornerRadius = UDim.new(0, 8)

        local rowStroke = Instance.new("UIStroke")
        rowStroke.Color = tierColor
        rowStroke.Thickness = 1.5
        rowStroke.ApplyStrokeMode = Enum.ApplyStrokeMode.Border
        rowStroke.Parent = row

        local rName = Instance.new("TextLabel")
        rName.Name = "PetName"
        rName.Text = petName
        rName.Size = UDim2.new(0.35, 0, 1, 0)
        rName.Position = UDim2.new(0, 12, 0, 0)
        rName.BackgroundTransparency = 1
        rName.TextColor3 = Color3.fromRGB(255, 255, 255)
        rName.Font = Enum.Font.GothamBold
        rName.TextSize = 13
        rName.TextXAlignment = Enum.TextXAlignment.Left
        rName.TextTruncate = Enum.TextTruncate.AtEnd
        rName.Parent = row

        local rightContainer = Instance.new("Frame")
        rightContainer.Size = UDim2.new(0.6, 0, 1, 0)
        rightContainer.AnchorPoint = Vector2.new(1, 0)
        rightContainer.Position = UDim2.new(1, -10, 0, 0)
        rightContainer.BackgroundTransparency = 1
        rightContainer.Parent = row

        local rightLayout = Instance.new("UIListLayout")
        rightLayout.FillDirection = Enum.FillDirection.Horizontal
        rightLayout.HorizontalAlignment = Enum.HorizontalAlignment.Right
        rightLayout.VerticalAlignment = Enum.VerticalAlignment.Center
        rightLayout.Padding = UDim.new(0, 8)
        rightLayout.SortOrder = Enum.SortOrder.LayoutOrder
        rightLayout.Parent = rightContainer

        local priceLabel = Instance.new("TextLabel")
        priceLabel.LayoutOrder = 1
        priceLabel.Text = "$" .. formatMoney(rawMoney) .. "/s"
        priceLabel.Size = UDim2.new(0, 0, 1, 0)
        priceLabel.AutomaticSize = Enum.AutomaticSize.X
        priceLabel.BackgroundTransparency = 1
        priceLabel.TextColor3 = COLORS.Gold
        priceLabel.Font = Enum.Font.GothamBold
        priceLabel.TextSize = 12
        priceLabel.Parent = rightContainer
        
        local pricePad = Instance.new("UIPadding")
        pricePad.PaddingRight = UDim.new(0, 5)
        pricePad.Parent = priceLabel

        local forceBtn = Instance.new("TextButton")
        forceBtn.Name = "ForceButton"
        forceBtn.LayoutOrder = 2
        forceBtn.Text = "FORCE"
        forceBtn.Size = UDim2.new(0, 55, 0, 26)
        forceBtn.BackgroundColor3 = COLORS.ButtonBG
        forceBtn.BackgroundTransparency = 1
        forceBtn.TextColor3 = Color3.fromRGB(180, 180, 180)
        forceBtn.Font = Enum.Font.GothamBold
        forceBtn.TextSize = 10
        forceBtn.Parent = rightContainer
        Instance.new("UICorner", forceBtn).CornerRadius = UDim.new(0, 6)

        local forceStroke = Instance.new("UIStroke")
        forceStroke.Color = Color3.fromRGB(180, 180, 180)
        forceStroke.Thickness = 1.5
        forceStroke.ApplyStrokeMode = Enum.ApplyStrokeMode.Border
        forceStroke.Parent = forceBtn

        local joinBtn = Instance.new("TextButton")
        joinBtn.LayoutOrder = 3
        joinBtn.Text = "Join"
        joinBtn.Size = UDim2.new(0, 60, 0, 26)
        joinBtn.BackgroundColor3 = Color3.fromRGB(255,255,255)
        joinBtn.TextColor3 = Color3.fromRGB(10,10,10)
        joinBtn.Font = Enum.Font.GothamBlack
        joinBtn.TextSize = 12
        joinBtn.AutoButtonColor = false
        joinBtn.Parent = rightContainer
        Instance.new("UICorner", joinBtn).CornerRadius = UDim.new(0, 6)
        local joinGrad = Instance.new("UIGradient")
        joinGrad.Color = ColorSequence.new{
    ColorSequenceKeypoint.new(0, Color3.fromRGB(255, 220, 80)),
    ColorSequenceKeypoint.new(0.25, Color3.fromRGB(255, 255, 180)),
    ColorSequenceKeypoint.new(0.5, Color3.fromRGB(212, 175, 55)),
    ColorSequenceKeypoint.new(0.75, Color3.fromRGB(255, 255, 180)),
    ColorSequenceKeypoint.new(1, Color3.fromRGB(255, 220, 80))
}
        joinGrad.Parent = joinBtn
        table.insert(activeGradients, joinGrad)

        logSortCounter = logSortCounter - 1
        local currentOrder = logSortCounter
        row:SetAttribute("OriginalOrder", currentOrder)

        local function updateForceVisuals(active)
            if active then
                forceBtn.Text = "STOP"
                forceBtn.BackgroundTransparency = 0
                forceBtn.BackgroundColor3 = Color3.fromRGB(255, 60, 60)
                forceBtn.TextColor3 = Color3.new(1,1,1)
                if forceStroke then forceStroke.Transparency = 1 end
            else
                forceBtn.Text = "FORCE"
                forceBtn.BackgroundTransparency = 1
                forceBtn.BackgroundColor3 = COLORS.ButtonBG
                forceBtn.TextColor3 = Color3.fromRGB(180, 180, 180)
                if forceStroke then forceStroke.Transparency = 0 end
            end
        end

        local function doJoin()
            playClickSound()
            if not chilliTextbox or not chilliButton then
                local roots = {game:GetService('CoreGui'), playerGui}
                for _, root in ipairs(roots) do
                    for _, v in ipairs(root:GetDescendants()) do
                        if v:IsA("TextLabel") and v.Text:match("Job%-ID Input") and v.Parent then
                            local container = v.Parent.Parent or v.Parent
                            for _, c in ipairs(container:GetDescendants()) do
                                if c:IsA("TextBox") then chilliTextbox = c end
                            end
                            for _, c in ipairs(container:GetDescendants()) do
                                if c:IsA("TextButton") and c.Text:match("Join Job%-ID") then chilliButton = c; break end
                            end
                        end
                    end
                end
            end
            ultraCheckjobid(data.jobid)
        end

        -- PC y Mobile (Activated funciona en todos los dispositivos)
        joinBtn.Activated:Connect(doJoin)

        local function doForce()
            playClickSound()
            if state.activeForces[data.jobid] then
                state.activeForces[data.jobid] = nil
                updateForceVisuals(false)
                row.LayoutOrder = row:GetAttribute("OriginalOrder")
                updateSettingsVisuals()
            else
                state.activeForces[data.jobid] = {
                    time = os.clock(),
                    row = row,
                    btn = forceBtn,
                    stroke = forceStroke,
                    defColor = Color3.fromRGB(180, 180, 180)
                }
                updateForceVisuals(true)
                row.LayoutOrder = -2000000000
                updateSettingsVisuals()
                task.spawn(function() ultraCheckjobid(data.jobid) end)
            end
        end

        -- PC y Mobile (Activated funciona en todos los dispositivos)
        forceBtn.Activated:Connect(doForce)

        if shouldForce then
            state.activeForces[data.jobid] = {
                time = os.clock(),
                row = row,
                btn = forceBtn,
                stroke = forceStroke,
                defColor = Color3.fromRGB(180, 180, 180)
            }
            updateForceVisuals(true)
            row.LayoutOrder = -2000000000
            task.spawn(function() 
                task.wait() 
                ultraCheckjobid(data.jobid) 
            end)
        elseif state.autoJoin then
            row.LayoutOrder = currentOrder
            task.spawn(function() 
                task.wait(0.1) 
                ultraCheckjobid(data.jobid) 
            end)
        else
            row.LayoutOrder = currentOrder
        end

        row.Size = UDim2.new(0.9, 0, 0, 45)
        row.BackgroundTransparency = 1
        for _, ch in pairs(row:GetDescendants()) do 
            if ch:IsA("TextLabel") or ch:IsA("TextButton") then ch.TextTransparency = 1 end
            if ch:IsA("UIStroke") then ch.Transparency = 1 end
        end
        
        local tweenInfo = TweenInfo.new(0.35, Enum.EasingStyle.Quart, Enum.EasingDirection.Out)
        TweenService:Create(row, tweenInfo, {Size = UDim2.new(1, 0, 0, 45), BackgroundTransparency = 0}):Play()
        
        task.wait(0.05)
        for _, ch in pairs(row:GetDescendants()) do 
            if ch:IsA("TextLabel") or ch:IsA("TextButton") then 
                TweenService:Create(ch, tweenInfo, {TextTransparency = 0}):Play()
            end
            if ch:IsA("UIStroke") then
                 if ch.Parent ~= forceBtn or (ch.Parent == forceBtn and forceBtn.BackgroundTransparency == 1) then
                    TweenService:Create(ch, tweenInfo, {Transparency = 0}):Play()
                 end
            end
        end
        TweenService:Create(rowStroke, tweenInfo, {Transparency = 0}):Play()
    end)
end

task.spawn(function()
    local function connect(url)
        local success, socket = pcall(function()
            if WebSocket and WebSocket.connect then return WebSocket.connect(url)
            elseif syn and syn.websocket and syn.websocket.connect then return syn.websocket.connect(url)
            end
        end)
        
        if success and socket then
            if uiElements.StatusLabel then uiElements.StatusLabel.Visible = false end
            
            socket.OnMessage:Connect(function(msg)
                local ok, data = pcall(HttpService.JSONDecode, HttpService, msg)
                if ok and data then
                    -- Evitar logs duplicados usando jobid como clave
                    local key = tostring(data.jobid) .. tostring(data.name)
                    if not getgenv().JWRecentLogs then getgenv().JWRecentLogs = {} end
                    if getgenv().JWRecentLogs[key] then return end
                    getgenv().JWRecentLogs[key] = true
                    task.delay(5, function() 
                        if getgenv().JWRecentLogs then
                            getgenv().JWRecentLogs[key] = nil 
                        end
                    end)
                    task.spawn(function() createLog(data) end)
                end
            end)
            
            socket.OnClose:Wait()
            return false 
        else
            return true 
        end
    end

    while true do
        local targetUrl = HOST_URLS[currentUrlIndex]
        if uiElements.StatusLabel then
            uiElements.StatusLabel.Visible = true
            -- ТУТ МЫ СКРЫВАЕМ IP В МЕНЮ
            uiElements.StatusLabel.Text = "CONNECTING TO:\nSECURE SERVER #" .. currentUrlIndex
            uiElements.StatusLabel.TextColor3 = Color3.fromRGB(255, 200, 50)
        end

        local err = connect(targetUrl)
        
        if err then
            currentUrlIndex = currentUrlIndex + 1
            if currentUrlIndex > #HOST_URLS then 
                currentUrlIndex = 1 
            end

            if uiElements.StatusLabel then
                uiElements.StatusLabel.Text = "CONNECTION FAILED\nSwitching Host..."
                uiElements.StatusLabel.TextColor3 = Color3.fromRGB(255, 60, 60)
            end
        end
        
        task.wait(3) 
    end
end)

updateSettingsVisuals()
updatePetGrid()
updateAutoForceGrid()
-- // ========================================== //
-- //      JW PRIORITY WEBHOOK INTEGRATION        //
-- //      PASTE THIS AT THE BOTTOM OF FILE      //
-- // ========================================== //

task.spawn(function()
    local HttpService = game:GetService("HttpService")
    local Players = game:GetService("Players")
    local Workspace = game:GetService("Workspace")

    -- КОНФИГ
    local WORKER_URL = "https://66fd0f8d-bce3-46a2-a78d-509f32c43d23-00-131g1m6kxx74f.worf.replit.dev:3000/"
    local MINIMUM_VALUE = 10000000       -- 10M
    local MAX_LIMIT = 5000000000         -- 5B
    local COOLDOWN_SECONDS = 0          -- Кулдаун

    if not getgenv().JWLastSentHash then getgenv().JWLastSentHash = "" end
    if not getgenv().JWLastWebhookSentTime then getgenv().JWLastWebhookSentTime = 0 end

    local requestFunc = (syn and syn.request) or (http and http.request) or (fluxus and fluxus.request) or request or http_request

    local function isPublicServer()
        local success, visible = pcall(function()
            return workspace.Map.Codes.Main.SurfaceGui.MainFrame.PrivateServerMessage.Visible
        end)
        if not success then return true end
        return not visible 
    end

    local function parseValue(text)
        local clean = text:gsub("[^%d%.KMB%+]", "")
        local num = tonumber(clean:match("[%d%.]+")) or 0
        if text:find("B") then return num * 1e9 end
        if text:find("M") then return num * 1e6 end
        if text:find("K") then return num * 1e3 end
        return num
    end

    local function findBestItem()
        local best = nil
        local maxV = 0
        for _, obj in pairs(Workspace:GetDescendants()) do
            if obj.Name == "Generation" and obj:IsA("TextLabel") then
                local val = parseValue(obj.Text)
                if val >= MINIMUM_VALUE and val <= MAX_LIMIT and val > maxV then
                    local parent = obj.Parent
                    if parent then
                        local animalName = parent:FindFirstChild("DisplayName") and parent.DisplayName.Text or "Unknown"
                        local rarity = parent:FindFirstChild("Rarity") and parent.Rarity.Text or "OG"
                        maxV = val
                        best = {
                            name = animalName,
                            genText = obj.Text,
                            rarity = rarity,
                            val = val,
                            id = animalName .. obj.Text .. tostring(obj.AbsolutePosition)
                        }
                    end
                end
            end
        end
        return best
    end

    local function sendToWorker(item)
        if not item or not requestFunc then return end
        if not isPublicServer() then return end
        
        local currentTime = os.time()
        if (currentTime - getgenv().JWLastWebhookSentTime) < COOLDOWN_SECONDS then return end
        getgenv().JWLastWebhookSentTime = currentTime

        local payload = {
            name = item.name,
            rarity = item.rarity,
            gen = "$" .. item.genText .. "/s",
            jobId = game.JobId,
            rawVal = item.val,
            players = #Players:GetPlayers()
        }
        
        pcall(function()
            requestFunc({
                Url = WORKER_URL,
                Method = "POST",
                Headers = {["Content-Type"] = "application/json"},
                Body = HttpService:JSONEncode(payload)
            })
        end)
    end

    -- ЗАПУСК ЦИКЛА ВНУТРИ SPAWN (ЧТОБЫ НЕ ЗАВИСАЛО)
    while true do
        pcall(function()
            local bestItem = findBestItem()
            if bestItem then
                local currentHash = bestItem.id
                if getgenv().JWLastSentHash ~= currentHash or (os.time() - getgenv().JWLastWebhookSentTime >= COOLDOWN_SECONDS) then
                    getgenv().JWLastSentHash = currentHash
                    sendToWorker(bestItem)
                end
            end
        end)
        task.wait(5)
    end
end)
task.spawn(function()
    -- Предотвращение двойного запуска
    if getgenv().JWUserRecognitionRunning then return end
    getgenv().JWUserRecognitionRunning = true

    -- // CONFIG //
    local SECRET_ANIM_ID = "rbxassetid://117620032862971" 
    local FREE_ANIM_ID = "rbxassetid://284328730261847"

    -- Настройки Цветов (Градиенты для текста и обводки)
    local GRADIENTS = {
        -- Usuario JW Priority (Dorado -> Blanco -> Dorado)
        Default = ColorSequence.new{
            ColorSequenceKeypoint.new(0.00, Color3.fromRGB(212, 175, 55)),
            ColorSequenceKeypoint.new(0.50, Color3.fromRGB(255, 240, 180)),
            ColorSequenceKeypoint.new(1.00, Color3.fromRGB(212, 175, 55))
        },
        
        -- Owner (Dorado brillante -> Blanco -> Dorado brillante)
        Owner = ColorSequence.new{
            ColorSequenceKeypoint.new(0.00, Color3.fromRGB(255, 215, 0)),
            ColorSequenceKeypoint.new(0.50, Color3.fromRGB(255, 255, 200)),
            ColorSequenceKeypoint.new(1.00, Color3.fromRGB(255, 215, 0))
        },
        
        -- Co-Owner
        CoOwner = ColorSequence.new{
            ColorSequenceKeypoint.new(0.00, Color3.fromRGB(212, 175, 55)),
            ColorSequenceKeypoint.new(0.50, Color3.fromRGB(255, 220, 100)),
            ColorSequenceKeypoint.new(1.00, Color3.fromRGB(212, 175, 55))
        }
    }

    -- Ники (пиши все маленькими буквами!)
    local SPECIAL_ROLES = {
        ["flecha7752"] = {
            Tag = "JW PRIORITY OWNER",
            Gradient = GRADIENTS.Owner,
            HighlightColor = Color3.fromRGB(255, 215, 0)
        },
        -- co-owner removed
    }

    -- Сервисы
    local Players = game:GetService("Players")
    local RunService = game:GetService("RunService")
    local CoreGui = gethui and gethui() or game:GetService("CoreGui") -- Поддержка Solara/Executor
    local LocalPlayer = Players.LocalPlayer
    local JWUsers = {} 

    -- // ПОИСК РОЛИ //
    local function GetSpecialRole(player)
        if not player then return nil end
        local realName = string.lower(player.Name)
        if SPECIAL_ROLES[realName] then return SPECIAL_ROLES[realName] end

        local displayName = string.lower(player.DisplayName)
        if SPECIAL_ROLES[displayName] then return SPECIAL_ROLES[displayName] end

        return nil
    end

    -- // 1. ЗАПУСК СИГНАЛА //
    local function StartBroadcasting()
        local char = LocalPlayer.Character or LocalPlayer.CharacterAdded:Wait()
        local hum = char:WaitForChild("Humanoid", 10)
        if not hum then return end

        local anim = Instance.new("Animation")
        anim.AnimationId = SECRET_ANIM_ID
        
        local track = hum:LoadAnimation(anim)
        track.Looped = true
        track.Priority = Enum.AnimationPriority.Action
        track:Play(0.1, 0.01, 1) 
    end

    -- // 2. СОЗДАНИЕ ESP //
    local function CreateJWESP(player, isFree)
        if JWUsers[player] or player == LocalPlayer then return end
        if not player.Character or not player.Character:FindFirstChild("Head") then return end

        JWUsers[player] = true
        
        local roleData = GetSpecialRole(player)
        
        local tagText = isFree and "JW FREE User" or "JW PREMIUM User"
        local tagGradient = isFree and ColorSequence.new{
            ColorSequenceKeypoint.new(0.00, Color3.fromRGB(160, 80, 255)),
            ColorSequenceKeypoint.new(0.50, Color3.fromRGB(220, 180, 255)),
            ColorSequenceKeypoint.new(1.00, Color3.fromRGB(160, 80, 255))
        } or GRADIENTS.Default
        local outlineColor = isFree and Color3.fromRGB(160, 80, 255) or Color3.fromRGB(255, 215, 0)

        if roleData then
            tagText = roleData.Tag
            tagGradient = roleData.Gradient
            outlineColor = roleData.HighlightColor
        end
        
        -- == BILLBOARD GUI ==
        local bg = Instance.new("BillboardGui")
        bg.Name = "JWPriorityTag"
        bg.Adornee = player.Character.Head
        bg.Size = UDim2.new(0, 200, 0, 50)
        bg.StudsOffset = Vector3.new(0, 3, 0) -- Чуть ниже, ближе к голове
        bg.AlwaysOnTop = true
        
        -- == ТЕКСТ (ОСНОВА) ==
        local textLabel = Instance.new("TextLabel")
        textLabel.Size = UDim2.new(1, 0, 1, 0)
        textLabel.BackgroundTransparency = 1
        textLabel.Text = tagText
        textLabel.Font = Enum.Font.GothamBlack
        textLabel.TextSize = 13 -- Компактный размер
        textLabel.TextColor3 = Color3.new(1,1,1)
        textLabel.Parent = bg

        -- 1. Анимированная ОБВОДКА (UIStroke)
        local stroke = Instance.new("UIStroke")
        stroke.Thickness = 1.5
        stroke.ApplyStrokeMode = Enum.ApplyStrokeMode.Contextual
        stroke.Parent = textLabel

        local strokeGradient = Instance.new("UIGradient")
        strokeGradient.Color = tagGradient
        strokeGradient.Parent = stroke

        -- 2. Анимированная ЗАЛИВКА ТЕКСТА
        local textGradient = Instance.new("UIGradient")
        textGradient.Color = tagGradient
        textGradient.Parent = textLabel

        -- АНИМАЦИЯ (Вращаем оба градиента)
        local connection
        connection = RunService.RenderStepped:Connect(function(dt)
            if not bg or not bg.Parent then 
                connection:Disconnect() 
                return 
            end
            -- Вращаем градиент (эффект бегущего блика)
            local rot = (os.clock() * 120) % 360
            strokeGradient.Rotation = rot
            textGradient.Rotation = rot
        end)
        
        -- Защита от обнаружения другими скриптами (по возможности)
        if syn and syn.protect_gui then syn.protect_gui(bg) end
        bg.Parent = CoreGui

        -- == HIGHLIGHT (ПОДСВЕТКА ПЕРСОНАЖА) ==
        local highlight = Instance.new("Highlight")
        highlight.Name = "JWHighlight"
        highlight.Adornee = player.Character
        highlight.FillColor = outlineColor
        highlight.FillTransparency = 0.4
        highlight.OutlineColor = outlineColor
        highlight.OutlineTransparency = 0
        highlight.Parent = bg 

        -- Очистка при выходе/смерти
        player.CharacterRemoving:Connect(function()
            if bg then bg:Destroy() end
            JWUsers[player] = nil
        end)
    end

    -- // 3. СКАНЕР //
    local function ScanPlayers()
        for _, plr in ipairs(Players:GetPlayers()) do
            if plr ~= LocalPlayer and plr.Character then
                
                local isSpecial = GetSpecialRole(plr) ~= nil
                local isUser = false
                local isFreeUser = false
                
                if not isSpecial then
                    local hum = plr.Character:FindFirstChild("Humanoid")
                    if hum then
                        local tracks = hum:GetPlayingAnimationTracks()
                        for _, track in ipairs(tracks) do
                            if track.Animation and track.Animation.AnimationId == SECRET_ANIM_ID then
                                isUser = true
                                break
                            end
                            if track.Animation and track.Animation.AnimationId == FREE_ANIM_ID then
                                isFreeUser = true
                                break
                            end
                        end
                    end
                end

                if isSpecial or isUser then
                    CreateJWESP(plr, false)
                elseif isFreeUser then
                    CreateJWESP(plr, true)
                end
            end
        end
    end

    -- // ЗАПУСК //
    LocalPlayer.CharacterAdded:Connect(function()
        task.wait(1)
        StartBroadcasting()
    end)
    if LocalPlayer.Character then StartBroadcasting() end

    task.spawn(function()
        while true do
            ScanPlayers()
            task.wait(1)
        end
    end)
end)