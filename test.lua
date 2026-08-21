-- ==============================================
--     ONYX KEY SYSTEM - WISNU HUB
-- ==============================================

-- LOAD SISTEM KEY
local Onyx = loadstring(game:HttpGet("https://cdn.jnkie.com/OnyxUI.lua"))()

-- KONFIGURASI
Onyx.Appearance = {
    Title = "Wisnu Hub",
    Subtitle = "Enter your key to continue",
    KeylessTitle = "Wisnu Hub",
    KeylessSubtitle = "No key required for this build - you're verified.",
    Icon = "rbxassetid://91006203868530",
}

Onyx.Links = {
    GetKey = "https://discord.gg/fZzN5HhFB",
    Discord = "https://discord.gg/fZzN5HhFB",
}

Onyx.Storage = {
    FileName = "WisnuHub_key",
    Remember = true,
    AutoLoad = true,
}

Onyx.Shop = {
    Enabled = false,
    Icon = "",
    Title = "Get Key",
    Subtitle = "Buy VIP key",
    ButtonText = "Buy",
    Link = "https://discord.gg/fZzN5HhFB"
}

-- 3. SCRIPT UTAMA
local function MainScript()
    print("✅ Key valid! Script loaded!")

-- ============================================================
--  LOAD UI LIBRARY (Oxidelib) + GAYA GROWAGARDEN2
-- ============================================================
local Library = loadstring(game:HttpGet("https://raw.githubusercontent.com/Naellx/Oxidelib/main/Oxidelib.lua"))()
if not Library then return warn("Oxidelib gagal dimuat") end
Library:SetTheme("Dark")  -- Gunakan tema standar yang dikenali ("Dark" atau "OLED")

local MY_LOGO = "rbxassetid://91006203868530"

-- Buat Jendela Utama dengan judul "Violance distrik"
local Window = Library:CreateWindow({
    Name = "Violance distrik",
    BrandSubtitle = "Violence District",
    Logo = MY_LOGO,
    LogoZoom = 1.5,
    ToggleKey = Enum.KeyCode.F3,
    ProfileKey = Enum.KeyCode.K,
    Size = UDim2.fromOffset(720, 500),
    LoadingText = "Wisnu Hub",
    LoadingSubtitle = "Loading Violent Engine...",
})

-- Watermark
task.spawn(function()
    task.wait(0.5)
    if Window.Watermark then
        Window.Watermark.ImageTransparency = 0.4
    end
end)

-- Mobile Bubble (hanya satu, hapus jika sudah ada)
task.spawn(function()
    pcall(function()
        local sg = Window.ScreenGui
        if not sg then return end

        -- Hapus bubble lama jika ada (untuk mencegah duplikasi)
        local oldBubble = sg:FindFirstChild("WisnuMobileBubble")
        if oldBubble then oldBubble:Destroy() end

        local btn = Instance.new("TextButton")
        btn.Name = "WisnuMobileBubble"
        btn.Size = UDim2.new(0, 56, 0, 56)
        btn.Position = UDim2.new(0.1, 0, 0.4, 0)
        btn.BackgroundColor3 = Color3.fromRGB(15, 15, 20)
        btn.BackgroundTransparency = 0.1
        btn.Text = ""
        btn.ZIndex = 999
        btn.Parent = sg

        local corner = Instance.new("UICorner", btn)
        corner.CornerRadius = UDim.new(0, 16)

        local stroke = Instance.new("UIStroke", btn)
        stroke.Color = Color3.fromRGB(167, 200, 244)
        stroke.Thickness = 1.5

        local icon = Instance.new("ImageLabel", btn)
        icon.Size = UDim2.new(0.8, 0, 0.8, 0)
        icon.Position = UDim2.new(0.1, 0, 0.1, 0)
        icon.BackgroundTransparency = 1
        icon.Image = MY_LOGO
        icon.ScaleType = Enum.ScaleType.Fit
        icon.ZIndex = 1000

        btn.MouseButton1Click:Connect(function() Window:ToggleUI() end)

        local UserInputService = game:GetService("UserInputService")
        local dragging, dragStart, startPos = false, nil, nil

        btn.InputBegan:Connect(function(input)
            if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
                dragging, dragStart, startPos = true, input.Position, btn.Position
            end
        end)

        UserInputService.InputChanged:Connect(function(input)
            if dragging and (input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch) then
                local delta = input.Position - dragStart
                btn.Position = UDim2.new(startPos.X.Scale, startPos.X.Offset + delta.X, startPos.Y.Scale, startPos.Y.Offset + delta.Y)
            end
        end)

        UserInputService.InputEnded:Connect(function(input)
            if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
                dragging = false
            end
        end)
    end)
end)

-- ============================================================
--  BACKEND & LOGIKA (SEMUA DARI SCRIPT ASLI)
-- ============================================================
-- SERVICES
local Players        = game:GetService("Players")
local RunService     = game:GetService("RunService")
local Workspace      = game:GetService("Workspace")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Lighting       = game:GetService("Lighting")
local UserInputService = game:GetService("UserInputService")
local VirtualInputManager = game:GetService("VirtualInputManager")
local Stats          = game:GetService("Stats")
local TweenService   = game:GetService("TweenService")

local LocalPlayer  = Players.LocalPlayer
local PlayerGui    = LocalPlayer:WaitForChild("PlayerGui")
local Camera       = workspace.CurrentCamera

local Remotes = ReplicatedStorage:WaitForChild("Remotes")
local AttackEvent = Remotes:WaitForChild("Attacks"):WaitForChild("BasicAttack")
local SkillCheckRemote = Remotes:WaitForChild("Generator"):WaitForChild("SkillCheckResultEvent")
local ToFItems = Remotes:FindFirstChild("Items")
local ToFFolder = ToFItems and ToFItems:FindFirstChild("Twist of Fate")
local ToFFireRemote = ToFFolder and ToFFolder:FindFirstChild("Fire")
local FlashlightFolder = ToFItems and ToFItems:FindFirstChild("Flashlight")
local GotBlindedRemote = FlashlightFolder and FlashlightFolder:FindFirstChild("GotBlinded")

-- ============== NEW: HIDE NAME SYSTEM ==============
local HideName = {
    Enabled = false,
    Keybind = Enum.KeyCode.F3,
    Connection = nil
}

-- ============== NEW: SILENT AIM (Improved) ==============
local SilentAim = {
    Enabled = false,
    FOV = 200,
    Distance = 400,
    TargetPart = "HumanoidRootPart",
    Prediction = true,
    PredictStrength = 0.15,
    BulletSpeed = 800,
    TargetMode = "Killer"
}
local silentHookActive = false
local silentOriginalCast = nil

-- ============== CONFIG =================
local ESP = {
    Survivor  = false,
    Killer    = false,
    Generator = false,
    Pallet    = false,
    Window    = false,
    SCP       = false,
    Distance  = 100
}

local ESPStatus = {
    Enabled      = false,
    ShowName     = true,
    ShowDistance = true,
    ShowHealth   = false,
    ShowItem     = true,
    Radius       = 100
}

local TeleportIndex = {
    Generator = 1,
    Hook = 1,
    Gate = 1,
    Pallet = 1,
    Window = 1
}

local ESPItems = {
    ["Twist of Fate"]   = true,
    ["Bandage"]         = true,
    ["Motion Tracker"]  = true,
    ["Gate"]            = true,
    ["Shadow Clone"]    = true,
    ["Parrying Dagger"] = true
}

local TeamColors = {
    Killer   = Color3.fromRGB(255, 60, 60),
    Survivor = Color3.fromRGB(60, 255, 120)
}

local Auto = {
    SkillCheck       = false,
    SkillCheckMode   = "Legit",
    Parry            = false,
    ParryDelay       = 0,
    ParryCooldown    = 1,
    ParryDistance    = 15,
    FaceSensitivity  = 0.7,
    RequireFacing    = true,
    PalletDrop       = false,
    PalletDropDist   = 6
}

local GenBypass = {
    Enabled     = false,
    Button      = nil,
    UI          = nil,
    Cache       = {},
    CacheTimer  = 0,
    Processed   = {},
    HotkeyCode  = Enum.KeyCode.G,
}

-- ============== GEN BYPASS SYSTEM ==============

function GB_GetAllGenerators()
    local now = tick()
    if now - GenBypass.CacheTimer < 5 then return GenBypass.Cache end
    GenBypass.Cache = {}
    GenBypass.CacheTimer = now
    local mapFolder = workspace:FindFirstChild("Map")
    if not mapFolder then return GenBypass.Cache end
    pcall(function()
        for _, v in pairs(mapFolder:GetDescendants()) do
            if not v:IsA("Model") then continue end
            if v.Name ~= "Generator" then continue end
            local isReal = v:GetAttribute("RepairProgress") ~= nil
                or v:GetAttribute("kickcount") ~= nil
                or v:GetAttribute("ProgressRepair") ~= nil
            if isReal then table.insert(GenBypass.Cache, v) end
        end
    end)
    return GenBypass.Cache
end

function GB_GetPoints(genModel)
    local points = {}
    pcall(function()
        for _, obj in pairs(genModel:GetChildren()) do
            if obj.Name:find("GeneratorPoint") and obj:IsA("BasePart") then
                table.insert(points, obj)
            end
        end
    end)
    return points
end

function GB_WaitRepairing(point, timeout)
    local start = tick()
    while tick() - start < (timeout or 1) do
        if point:GetAttribute("IsRepairing") == true then return true end
        task.wait(0.05)
    end
    return false
end

function GB_DoRepair(targetPoint)
    local genModel = targetPoint.Parent
    if GenBypass.Processed[genModel] then return end
    GenBypass.Processed[genModel] = true

    local character = LocalPlayer.Character
    local hrp = character and character:FindFirstChild("HumanoidRootPart")
    if not hrp then GenBypass.Processed[genModel] = nil return end

    local RepairEvent = ReplicatedStorage:FindFirstChild("Remotes")
        and ReplicatedStorage.Remotes:FindFirstChild("Generator")
        and ReplicatedStorage.Remotes.Generator:FindFirstChild("RepairEvent")

    if not RepairEvent then 
        GenBypass.Processed[genModel] = nil 
        return 
    end

    local originalCFrame = hrp.CFrame
    pcall(function()
        for _, point in pairs(GB_GetPoints(genModel)) do
            if point ~= targetPoint and point.Parent then
                hrp.Anchored = true
                hrp.CFrame = point.CFrame
                task.wait(0.15)
                pcall(function() RepairEvent:FireServer(point, true) end)
                if not GB_WaitRepairing(point, 0.8) then
                    pcall(function() RepairEvent:FireServer(point, false) end)
                    task.wait(0.1)
                    hrp.CFrame = point.CFrame
                    task.wait(0.15)
                    pcall(function() RepairEvent:FireServer(point, true) end)
                    GB_WaitRepairing(point, 0.5)
                end
                hrp.Anchored = false
                task.wait(0.05)
            end
        end
    end)
    pcall(function()
        if hrp and hrp.Parent then
            hrp.Anchored = false
            hrp.CFrame = originalCFrame
        end
    end)
    task.wait(0.1)
    pcall(function() RepairEvent:FireServer(targetPoint, false) end)
    GenBypass.Processed[genModel] = nil
end

function GB_GetNearestPoint()
    local character = LocalPlayer.Character
    local hrp = character and character:FindFirstChild("HumanoidRootPart")
    if not hrp then return nil end
    local bestPoint, bestDist = nil, math.huge
    for _, gen in pairs(GB_GetAllGenerators()) do
        for _, point in pairs(GB_GetPoints(gen)) do
            local d = (hrp.Position - point.Position).Magnitude
            if d < bestDist then bestDist = d; bestPoint = point end
        end
    end
    return bestPoint, bestDist
end

function GB_UpdateButton()
    if GenBypass.Button then
        GenBypass.Button.Visible = GenBypass.Enabled and UserInputService.TouchEnabled
    end
end

function GB_CreateButton()
    local oldUI = PlayerGui:FindFirstChild("BypassGenUI")
    if oldUI then oldUI:Destroy() end

    GenBypass.UI = Instance.new("ScreenGui")
    GenBypass.UI.Name = "BypassGenUI"
    GenBypass.UI.ResetOnSpawn = false
    GenBypass.UI.IgnoreGuiInset = true
    GenBypass.UI.Parent = PlayerGui

    GenBypass.Button = Instance.new("ImageButton")
    GenBypass.Button.Name = "BypassGenButton"
    GenBypass.Button.Size = UDim2.new(0, 60, 0, 60)
    GenBypass.Button.Position = UDim2.new(0.88, 0, 0.55, 0)
    GenBypass.Button.AnchorPoint = Vector2.new(0.5, 0.5)
    GenBypass.Button.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
    GenBypass.Button.BackgroundTransparency = 0.15
    GenBypass.Button.AutoButtonColor = true
    GenBypass.Button.Visible = false
    GenBypass.Button.ZIndex = 10
    GenBypass.Button.Parent = GenBypass.UI
    
    local corner = Instance.new("UICorner")
    corner.CornerRadius = UDim.new(1, 0)
    corner.Parent = GenBypass.Button
    
    local stroke = Instance.new("UIStroke")
    stroke.Color = Color3.fromRGB(255, 255, 255)
    stroke.Thickness = 2
    stroke.Transparency = 0.2
    stroke.Parent = GenBypass.Button
    
    local lbl = Instance.new("TextLabel")
    lbl.Size = UDim2.new(1, 0, 1, 0)
    lbl.BackgroundTransparency = 1
    lbl.Text = "BYPASS"
    lbl.TextColor3 = Color3.fromRGB(255, 255, 255)
    lbl.TextScaled = true
    lbl.Font = Enum.Font.GothamBlack
    lbl.ZIndex = 11
    lbl.Parent = GenBypass.Button

    GenBypass.Button.MouseButton1Click:Connect(function()
        if not GenBypass.Enabled then return end
        local bestPoint, bestDist = GB_GetNearestPoint()
        if bestPoint and bestDist <= 8 then 
            GB_DoRepair(bestPoint) 
        end
    end)
end

-- Inisialisasi button
GB_CreateButton()

-- Recreate button saat karakter respawn
LocalPlayer.CharacterAdded:Connect(function()
    task.wait(0.5)
    GB_CreateButton()
    GB_UpdateButton()
end)

function setGenBypass(v)
    GenBypass.Enabled = v
    GB_UpdateButton()
end

local GenBoostConfig = {
    Enabled = false,
    LastBroadcast = 0
}


local FakeTag = {
    Enabled = false,
    Text = "[WISNU]",
    Color = "#00FFFF"
}
local FakeParry = {
    Enabled   = false,
    Animation = "Parry",
    Keybind   = Enum.KeyCode.V
}

local FakeParryAnimations = {
    Enten     = "rbxassetid://127096285501517",
    Stopwatch = "rbxassetid://81793464499285",
    Fih       = "rbxassetid://123307242865945",
    BloodShield = "rbxassetid://75939529748815"
}

local AutoFlee = {
    Enabled        = false,
    DetectDistance = 50,
    Cooldown       = 0.1
}

local GunAim = {
    Enabled         = false,
    Holding         = false,
    TargetMode      = "Killer",
    Strength        = 1,
    Predict         = true,
    PredictStrength = 0.12,
    FOV             = 250,
    VisibilityCheck = true,
    Target          = nil,
    AimPart         = "HumanoidRootPart"
}

local ToFAimConfig = {
    Enabled = false,
    TargetMode = "Killer",
    AimPart = "HumanoidRootPart",
    Predict = true,
    BulletSpeed = 200,
    Range = 90,
    DotThreshold = 0.5
}


local AttackAim = {
    Enabled         = false,
    Holding         = false,
    Strength        = 1,
    Predict         = true,
    PredictStrength = 0.12,
    FOV             = 250,
    VisibilityCheck = true,
    AimPart         = "HumanoidRootPart"
}

local SpearAim = {
    Enabled = false,
    Gravity = 50,
    Speed   = 100,
    FOV     = 250,
    AimPart = "HumanoidRootPart"
}

local Killer = {
    KillAll   = false,
    KillRange = 500,
    BypassCooldown = false,
    BypassLeap = false,
    ThirdPerson = false,
    ThirdPersonWasActive = false,
    OriginalCameraType = nil,
    AntiBlind = false,
    BlockVaults = false
}

local Masked = {
    Enabled      = false,
    CurrentPower = "Cobra"
}

local MaskedPowers = {"Cobra", "Richter", "Brandon", "Rabbit", "Alex"}

local CameraZoom = {
    UnlimitedZoom = false,
    MaxDistance   = 1000,
    MinDistance   = 0,
    FOVEnabled    = false,
    FOV           = 70,
    DefaultFOV    = workspace.CurrentCamera.FieldOfView
}

local AutoStalk = {
    Enabled    = false,
    StalkRange = 150,
    Target     = nil
}

local PlayerMods = {
    GodMode = false,
    AntiFall = false,
    AntiVault = false
}

local Movement = {
    JumpPowerEnabled  = false,
    JumpPowerValue    = 50,
    OriginalJumpPower = 50,
    WalkSpeedEnabled  = false,
    WalkSpeedValue    = 17.6,
    OriginalWalkSpeed = 16,
    NoClip            = false
}

local FastVault = {
    Enabled    = false,
    Speed      = 1.2,
    ReplaceMap = {
        ["rbxassetid://83873880822918"] = "rbxassetid://136962284480779"
    }
}

local ParryRangeVisual = {
    Enabled      = false,
    Color        = Color3.fromRGB(255, 80, 80),
    Transparency = 0.9
}

local Crosshair = {
    Enabled   = false,
    Size      = 8,
    Thickness = 2,
    Color     = Color3.fromRGB(255, 255, 255),
    Style     = "Plus",
    OffsetX   = 0,
    OffsetY   = 0
}

local Visual = {
    Fullbright      = false,
    NoShadow        = false,
    Ambient         = false,
    AmbientColor    = Color3.fromRGB(255, 255, 255),
    ClockTimeEnabled = true,
    Brightness      = 2,
    ClockTime       = 14,
    LowGraphics     = false,
    LowRender       = false,
    NoFog           = false,
    CleanSky        = false,
    NoScreenEffects = false
}

local Emote = {
    Selected = "Mannrobics"
}

local EmoteButton = {
    Show        = false,
    GuiInstance = nil
}

-- ============== GROUPED STATE / CONNECTIONS ==============

local Connections = {
    WalkSpeed     = nil,
    NoClip        = nil,
    GunAim        = nil,
    AttackAim     = nil,
    Stalk         = nil,
    SkillHeartbeat = nil,
    CooldownBypass = nil,
    LeapBypass    = nil
}

local Config = {
    Surv_AutoParry = false,
    Surv_ParrySafety = false,
    Surv_ParryAggressive = false,
    Surv_ParryCircle = true,
    Surv_ParryRadius = 15,
    Surv_ParryFace = 0.7,
    Surv_AutoCrouch = false,
    Ignored_Skills_List = {}
}

local State = { 
    ParryCooldown = false,
    ParryCooldownTime = 60,
    AutoParryAdornment = nil,
    
    FakeParryButton     = nil,
    FakeParryTrack      = nil,
    ParryCircle         = nil,
    KillerTarget        = nil,
    GunAimButtonConn    = nil,
    CurrentGunButton    = nil,
    CurrentAttackButton = nil,
    busy                = false,
    ParryActive         = false,
    AttackAimMode       = "Normal",
    LastFlee            = 0,
    lastParry           = 0,
    FPS                 = 0,
    Frames              = 0,
    LastTick            = tick(),
    created             = false,
    LastCrosshairStyle  = nil,
    UsedPallets         = {}
}

local Timers = {
    lastESPUpdate    = 0,
    lastKillerUpdate = 0,
    lastGodMode      = 0,
    lastTracerScan   = 0,
    lastPalletScan   = 0,
    lastPalletDrop   = 0,
    lastVaultBlock   = 0
}

local ESPCache = {
    Objects    = {}, 
    Status     = {},
    SCP        = {}, 
    Generators = {},
    Windows    = {},
    Pallets    = {}
}

local OriginalLighting = {
    Brightness     = Lighting.Brightness,
    ClockTime      = Lighting.ClockTime,
    Ambient        = Lighting.Ambient,
    OutdoorAmbient = Lighting.OutdoorAmbient,
    GlobalShadows  = Lighting.GlobalShadows
}

local LastVisualState = {
    Fullbright  = nil,
    NoShadow    = nil,
    Ambient     = nil,
    AmbientColor = nil,
    Brightness  = nil,
    ClockTime   = nil
}

local LastOptimizationState = {
    LowGraphics = nil,
    LowRender   = nil,
    CleanSky    = nil
}

local VALID_PARRY_IDS = {
    ["122812055447896"] = "Veil lunge",
    ["133963973694098"] = "Mayers Basic",
    ["117042998468241"] = "Mayers lunge",
    ["135002183282873"] = "cure lunge",
    ["121216847022485"] = "cure Basic",
    ["132817836308238"] = "Jeff Basic",
    ["129784271201071"] = "Jeff lunge",
    ["82666958311998"] = "Jeff Frenzy",
    ["78432063483146"] = "Abyssal Basic",
    ["118907603246885"] = "Abyssal lunge",
    ["139369275981139"] = "Jason Basic",
    ["110355011987939"] = "Jason lunge",
    ["111920872708571"] = "Masked Basic",
    ["105374834496520"] = "Masked lunge",
    ["138720291317243"] = "Masked Tony",
    ["106871536134254"] = "Masked Alex",
    ["130593238885843"] = "Masked Cobra",
    ["115244153053858"] = "Masked Cobra lunge",
    ["74968262036854"] = "Hidden Basic",
    ["113255068724446"] = "Hidden lunge",
    ["98163597193511"] = "Hidden S1",
    ["80411309607666"] = "Abyssal S1"
}

local Attached = {}

-- ============== HIDE NAME FUNCTIONS ==============
local function shouldHideNameObject(object)
    local ok, isTextObj = pcall(function()
        return object:IsA("TextLabel") or object:IsA("TextButton") or object:IsA("TextBox")
    end)
    if not ok or not isTextObj then return false end
    local text = ""
    pcall(function() text = tostring(object.Text or "") end)
    return text == LocalPlayer.Name or text == LocalPlayer.DisplayName or text:find(LocalPlayer.Name, 1, true) ~= nil
end

local function enableHideName(enabled)
    if HideName.Connection then
        pcall(function() HideName.Connection:Disconnect() end)
        HideName.Connection = nil
    end
    local playerGui = LocalPlayer:FindFirstChildOfClass("PlayerGui")
    if not playerGui then return end
    
    local function process(object)
        if shouldHideNameObject(object) then
            object.Visible = not enabled
        end
    end
    
    for _, descendant in ipairs(playerGui:GetDescendants()) do
        process(descendant)
    end
    
    if enabled then
        HideName.Connection = playerGui.DescendantAdded:Connect(function(object)
            task.defer(process, object)
        end)
    end
end

-- ============== SILENT AIM FUNCTIONS ==============
local function getSilentTarget()
    local root = getRoot()
    if not root then return nil end
    local myPos = root.Position
    local cam = workspace.CurrentCamera
    if not cam then return nil end
    local center = Vector2.new(cam.ViewportSize.X / 2, cam.ViewportSize.Y / 2)
    local best, bestDist = nil, SilentAim.FOV

    for _, p in ipairs(Players:GetPlayers()) do
        if p == LocalPlayer then continue end
        local char = p.Character
        if not char then continue end

        local hum = char:FindFirstChildOfClass("Humanoid")
        if not hum or hum.Health <= 0 then continue end

        local valid = false
        if SilentAim.TargetMode == "Killer" and p.Team and p.Team.Name == "Killer" then
            valid = true
        elseif SilentAim.TargetMode == "Survivor" and p.Team and p.Team.Name == "Survivors" then
            valid = true
        elseif SilentAim.TargetMode == "SCP" then
            for obj in pairs(ESPCache.SCP) do
                if obj and obj.Parent then
                    valid = true
                    break
                end
            end
        end
        if not valid then continue end

        local part = char:FindFirstChild(SilentAim.TargetPart)
        if not part then
            part = char:FindFirstChild("HumanoidRootPart") or char:FindFirstChild("Head")
        end
        if not part or not part:IsA("BasePart") then continue end

        local targetPos = part.Position

        if SilentAim.Prediction then
            local success, vel = pcall(function()
                return part.AssemblyLinearVelocity
            end)
            if success and vel and type(vel) == "Vector3" then
                local dist = (targetPos - myPos).Magnitude
                if dist > 0 then
                    local travelTime = dist / SilentAim.BulletSpeed
                    targetPos = targetPos + vel * (travelTime * SilentAim.PredictStrength)
                end
            end
        end

        -- Visibility check (raycast from camera)
        local rayParams = RaycastParams.new()
        rayParams.FilterType = Enum.RaycastFilterType.Blacklist
        rayParams.FilterDescendantsInstances = { LocalPlayer.Character, char }
        local direction = targetPos - cam.CFrame.Position
        local result = workspace:Raycast(cam.CFrame.Position, direction, rayParams)
        if result then
            continue
        end

        local screenPos, onScreen = cam:WorldToViewportPoint(targetPos)
        if onScreen then
            local distFromCenter = (Vector2.new(screenPos.X, screenPos.Y) - center).Magnitude
            if distFromCenter < bestDist and distFromCenter <= SilentAim.FOV then
                local worldDist = (targetPos - myPos).Magnitude
                if worldDist <= SilentAim.Distance then
                    bestDist = distFromCenter
                    best = part
                end
            end
        end
    end

    return best
end

local function setupSilentAimHook()
    if silentHookActive then return end
    local castTable = nil
    for i, v in pairs(getgc(true)) do
        if type(v) == "table" and rawget(v, "cast") then
            castTable = v
            break
        end
    end
    if not castTable then
        Window:Notify({ Title = "Silent Aim Error", Content = "Fungsi 'cast' tidak ditemukan", Type = "warning", Duration = 3 })
        return
    end
    silentOriginalCast = castTable.cast
    if not silentOriginalCast then return end
    silentHookActive = true
    castTable.cast = function(p1, p2, p3)
        if SilentAim.Enabled then
            local target = getSilentTarget()
            if target and target:IsA("BasePart") and target.Parent then
                return target, target.Position, Vector3.new(0,1,0), target.Material
            end
        end
        return silentOriginalCast(p1, p2, p3)
    end
    Window:Notify({ Title = "Silent Aim", Content = "Hook installed!", Type = "success", Duration = 2 })
end

local function removeSilentAimHook()
    if not silentHookActive then return end
    local castTable = nil
    for i, v in pairs(getgc(true)) do
        if type(v) == "table" and rawget(v, "cast") then
            castTable = v
            break
        end
    end
    if castTable and silentOriginalCast then
        castTable.cast = silentOriginalCast
    end
    silentHookActive = false
    silentOriginalCast = nil
    Window:Notify({ Title = "Silent Aim", Content = "Hook removed", Type = "warning", Duration = 2 })
end

function IsSafeToParry(char)
    if not Config.Surv_ParrySafety then return true end
    if not char then return false end
    
    local interactObj = char:FindFirstChild("CheckInterractable")
    
    if interactObj then
        if interactObj:GetAttribute("isVaulting") == true then return false end
        if interactObj:GetAttribute("isRepairing") == true then return false end
        if interactObj:GetAttribute("isUnhooking") == true then return false end
        if interactObj:GetAttribute("isHealing") == true then return false end
        if interactObj:GetAttribute("isSliding") == true then return false end
    end
    
    return true 
end

function TriggerCrouch()
    pcall(function()
        local b = LocalPlayer:FindFirstChild("PlayerGui")

        for segment in string.gmatch("Survivor-mob.Controls.crouch.icon", "[^%.]+") do
            if b then
                b = b:FindFirstChild(segment)
            end
        end

        if b and b:IsA("GuiObject") and b.Visible and b.Parent and b.Parent:IsA("GuiButton") then
            local btn = b.Parent

            if UserInputService.TouchEnabled and type(firesignal) == "function" then
                firesignal(btn.MouseButton1Click)
                task.wait(2)
                firesignal(btn.MouseButton1Click)
            else
                VirtualInputManager:SendKeyEvent(true, Enum.KeyCode.LeftControl, false, game)
                task.wait(2)
                VirtualInputManager:SendKeyEvent(false, Enum.KeyCode.LeftControl, false, game)
            end
        else
            VirtualInputManager:SendKeyEvent(true, Enum.KeyCode.LeftControl, false, game)
            task.wait(2)
            VirtualInputManager:SendKeyEvent(false, Enum.KeyCode.LeftControl, false, game)
        end
    end)
end
function isWeapon(obj)
    if obj:IsA("Tool") then return true end
    if obj.Parent and armParts[obj.Parent.Name] then return true end
    local name = obj.Name:lower()
    if name:match("weapon") or name:match("gun") or name:match("blade") then return true end
    return false
end
function GetRole()
    if not LocalPlayer.Team then return "Unknown" end
    local name = LocalPlayer.Team.Name
    if name == "Killer" then return "Killer"
    elseif name == "Survivors" then return "Survivor"
    else return "Spectator" end
end
function IsSurvivor(p) return p and p.Team and p.Team.Name == "Survivors" end
function IsKiller(p) return p and p.Team and p.Team.Name == "Killer" end
function IsDowned(char)
    if not char then return false end
    return char:GetAttribute("Knocked") == true or char:GetAttribute("IsHooked") == true
end

function faceTarget(targetPart, smoothness)
    if not targetPart then return end
    smoothness = smoothness or 0.1
    local targetCFrame = CFrame.lookAt(Camera.CFrame.Position, targetPart.Position)
    Camera.CFrame = Camera.CFrame:Lerp(targetCFrame, smoothness)
end
function GetDistance(pos) 
    local root = LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("HumanoidRootPart")
    if not root then return math.huge end
    return (pos - root.Position).Magnitude 
end

local function getRoot()
    return LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("HumanoidRootPart")
end

function GetClosestEnemy()
    local closest = nil
    local shortest = AttackRange
    local myChar = player.Character
    local myHRP = myChar and myChar:FindFirstChild("HumanoidRootPart")
    if not myHRP then return nil end
    for _, plr in pairs(Players:GetPlayers()) do
        if plr ~= player and plr.Character and plr.Character:FindFirstChild("HumanoidRootPart") then
            local hrp = plr.Character.HumanoidRootPart
            local team = plr.Team and plr.Team.Name:lower() or ""
            if team ~= (player.Team and player.Team.Name:lower()) then
                local dist = (hrp.Position - myHRP.Position).Magnitude
                if dist < shortest then 
                    shortest = dist 
                    closest = plr 
                end
            end
        end
    end
    return closest, shortest
end

local KillerAnims = {
    ["rbxassetid://105374834496520"] = true,
    ["rbxassetid://113255068724446"] = true,
    ["rbxassetid://118907603246885"] = true,
    ["rbxassetid://129784271201071"] = true,
    ["rbxassetid://117042998468241"] = true,
    ["rbxassetid://122812055447896"] = true,
    ["rbxassetid://78935059863801"]  = true,
    ["rbxassetid://74968262036854"]  = true,
    ["rbxassetid://78432063483146"]  = true,
    ["rbxassetid://132817836308238"] = true,
    ["rbxassetid://133963973694098"] = true,
    ["rbxassetid://111920872708571"] = true,
    ["rbxassetid://80411309607666"]  = true,
    ["rbxassetid://98163597193511"]  = true,
    ["rbxassetid://82666958311998"]  = true,
    ["rbxassetid://110355011987939"] = true,
    ["rbxassetid://139369275981139"] = true,
    ["rbxassetid://135002183282873"] = true,
    ["rbxassetid://121216847022485"] = true,
    ["rbxassetid://130593238885843"] = true,
    ["rbxassetid://117070354890871"] = true,
    ["rbxassetid://106871536134254"] = true,
    ["rbxassetid://138720291317243"] = true
}

local hookedKillers = {}
local VaultTracks   = {}
local CrosshairDrawings = {}
local DisabledEffects   = {}

local AttackPaths = {
    "Slasher-mob.Controls.attack",
    "Masked-mob.Controls.attack",
    "Killer-mob.Controls.attack"
}

local ScreenEffectTypes = {
    "ColorCorrectionEffect",
    "DepthOfFieldEffect",
    "BlurEffect",
    "SunRaysEffect",
    "BloomEffect"
}

local EmoteList = {
    "Mannrobics", "Arm Swing", "Schadenfreude", "Kyoufuu",
    "Backflip", "Griddy", "Friday Night", "Floating Rest",
    "OnePlays", "Quick Combo", "WarCry", "Wave"
}

local GeneratorColor = Color3.fromRGB(255, 170, 0)
local PalletColor    = Color3.fromRGB(74, 255, 181)
local WindowColor    = Color3.fromRGB(74, 255, 181)
local SCPColor       = Color3.fromRGB(255, 0, 0)

local PARRY_DEBOUNCE = 0.2
local TouchID        = 8822
local ActionPath     = "Survivor-mob.Controls.action.check"

local RayParams = RaycastParams.new()
RayParams.FilterType = Enum.RaycastFilterType.Blacklist

local EmoteRemote = Remotes:WaitForChild("EmoteHandler")

-- ============================================================
--  UI STRUKTUR (OXIDELIB - GROWAGARDEN2)
-- ============================================================

local TabPlayer = Window:AddTab({ Name = "Player", Icon = "user" })
local SubSurvivor = TabPlayer:AddSubTab("Survivor")
local SubKiller = TabPlayer:AddSubTab("Killer")
local SubAimBot = TabPlayer:AddSubTab("AimBot")
local SubToF = TabPlayer:AddSubTab("ToF")
local SubParry = TabPlayer:AddSubTab("Parry")
local SubCrosshair = TabPlayer:AddSubTab("Crosshair")

local TabESP = Window:AddTab({ Name = "ESP", Icon = "eye" })
local SubESPCham = TabESP:AddSubTab("ESP Cham")
local SubESPStatus = TabESP:AddSubTab("ESP Status")

local TabMisc = Window:AddTab({ Name = "Misc", Icon = "sliders" })
local SubMovement = TabMisc:AddSubTab("Movement")
local SubEmote = TabMisc:AddSubTab("Emote")
local SubFakeTag = TabMisc:AddSubTab("Fake Tag")

local TabVisual = Window:AddTab({ Name = "Visual", Icon = "sparkles" })
local SubGraphics = TabVisual:AddSubTab("Graphics")
local SubMorph = TabVisual:AddSubTab("Morph")
local SubClock = TabVisual:AddSubTab("Clock")
local SubZoom = TabVisual:AddSubTab("Zoom")

local TabUISettings = Window:AddTab({ Name = "UI Settings", Icon = "settings" })
local SubUIMenu = TabUISettings:AddSubTab("Menu")

-- ============================================================
--  UI ELEMENTS (SEMUA FITUR) - DIPERBAIKI dengan AddKeybind
-- ============================================================

-- ===== PLAYER / SURVIVOR =====
SubSurvivor:AddSection("Ability")
SubSurvivor:AddToggle({
    Name = "Auto Skill Check",
    Default = false,
    Callback = function(v)
        Auto.SkillCheck = v
        if v then startSkillCheck() end
    end
})
SubSurvivor:AddDropdown({
    Name = "Skill Check Mode",
    Options = {"Legit", "Instant"},
    Default = "Legit",
    Callback = function(v) Auto.SkillCheckMode = v end
})
SubSurvivor:AddToggle({
    Name = "Boost Gen Bypass",
    Default = false,
    Tooltip = "Mengaktifkan bypass generator untuk repair cepat",
    Callback = function(v) 
        setGenBypass(v)
        if v then
            Window:Notify({ Title = "Gen Bypass", Content = "Diaktifkan - Klik tombol BYPASS di layar (mobile)", Type = "info", Duration = 3 })
        end
    end
})
SubSurvivor:AddToggle({
    Name = "Auto Drop Pallet",
    Default = false,
    Tooltip = "otomatis menjatuhkan pallet",
    Callback = function(v) Auto.PalletDrop = v end
})
SubSurvivor:AddSlider({
    Name = "Auto Pallet Distance",
    Min = 5,
    Max = 50,
    Default = 6,
    Callback = function(v) Auto.PalletDropDist = v end
})
SubSurvivor:AddToggle({
    Name = "Auto Flee Killer",
    Default = false,
    Tooltip = "otomatis tp menjauh dari killer",
    Callback = function(v) AutoFlee.Enabled = v end
})
SubSurvivor:AddToggle({
    Name = "Anti Fall Damage",
    Default = false,
    Tooltip = "memblokir efek slow ketika jatuh",
    Callback = function(v) PlayerMods.AntiFall = v end
})
SubSurvivor:AddToggle({
    Name = "Anti KnockDown",
    Default = false,
    Tooltip = "memaksa berdiri ketika KnockDown",
    Callback = function(v) PlayerMods.GodMode = v end
})
SubSurvivor:AddToggle({
    Name = "Fast Vault",
    Default = false,
    Tooltip = "percepat animasi lompat",
    Callback = function(v) FastVault.Enabled = v end
})
SubSurvivor:AddSlider({
    Name = "Vault Animation Speed",
    Min = 1,
    Max = 5,
    Default = 1.2,
    Callback = function(v) FastVault.Speed = v end
})
SubSurvivor:AddToggle({
    Name = "Disable Local Vault",
    Default = false,
    Tooltip = "Mencegah karaktermu melakukan vault",
    Callback = function(v) PlayerMods.AntiVault = v end
})

-- Hide Name (di Survivor) - tanpa keypicker, diganti dengan keybind terpisah
local HideNameToggle = SubSurvivor:AddToggle({
    Name = "Hide Name (Streamer Mode)",
    Default = false,
    Callback = function(v)
        HideName.Enabled = v
        enableHideName(v)
    end
})
-- Tambahkan keybind untuk toggle Hide Name
SubSurvivor:AddKeybind({
    Name = "Hide Name Keybind",
    Default = Enum.KeyCode.F3,
    OnPress = function()
        HideName.Enabled = not HideName.Enabled
        enableHideName(HideName.Enabled)
        -- Update toggle secara visual tidak bisa, tapi state internal berubah
        Window:Notify({ Title = "Hide Name", Content = tostring(HideName.Enabled and "Enabled" or "Disabled"), Type = "info", Duration = 1 })
    end
})

SubSurvivor:AddDivider()
SubSurvivor:AddButton({ Name = "Instan Escape (Finish Line)", Callback = function() teleportToFinishLine() end })

-- ===== PLAYER / KILLER =====
SubKiller:AddSection("Killer Abilities")
SubKiller:AddToggle({
    Name = "Block All Vaults (Entity Blocker)",
    Default = false,
    Tooltip = "memicu Entity Blocker (Mencegah Survivor Vault)",
    Callback = function(v) Killer.BlockVaults = v end
})
SubKiller:AddToggle({
    Name = "Anti Blind (Flashlight)",
    Default = false,
    Callback = function(v) Killer.AntiBlind = v end
})
SubKiller:AddToggle({
    Name = "Auto Stalk (Myers)",
    Default = false,
    Callback = function(v)
        AutoStalk.Enabled = v
        if v then startAutoStalk() else stopAutoStalk() end
    end
})
SubKiller:AddToggle({
    Name = "Bypass Cooldown (Abyss)",
    Default = false,
    Callback = function(v)
        Killer.BypassCooldown = v
        if v then
            StartCooldownBypass()
            Window:Notify({ Title = "Bypass Cooldown", Content = "Diaktifkan", Type = "success", Duration = 3 })
        else
            StopCooldownBypass()
            Window:Notify({ Title = "Bypass Cooldown", Content = "Dinonaktifkan", Type = "warning", Duration = 3 })
        end
    end
})
SubKiller:AddToggle({
    Name = "Bypass Leap Cooldown (Hidden)",
    Default = false,
    Callback = function(v)
        Killer.BypassLeap = v
        if v then StartLeapBypass() end
    end
})
SubKiller:AddToggle({
    Name = "Auto Kill All",
    Default = false,
    Callback = function(v) Killer.KillAll = v end
})
SubKiller:AddToggle({
    Name = "AimLock Attack",
    Default = false,
    Callback = function(v) AttackAim.Enabled = v; if v then startAttackAim() end end
})
SubKiller:AddDropdown({
    Name = "Aimlock Mode",
    Options = {"Normal", "Spear"},
    Default = "Normal",
    Callback = function(v) State.AttackAimMode = v end
})
SubKiller:AddSlider({
    Name = "Spear Gravity",
    Min = 10,
    Max = 200,
    Default = 50,
    Callback = function(v) SpearAim.Gravity = v end
})
SubKiller:AddSlider({
    Name = "Spear Speed",
    Min = 20,
    Max = 300,
    Default = 100,
    Callback = function(v) SpearAim.Speed = v end
})
SubKiller:AddDivider()
SubKiller:AddDropdown({
    Name = "Select Masked Power",
    Options = MaskedPowers,
    Default = "Cobra",
    Callback = function(v) Masked.CurrentPower = v end
})
SubKiller:AddButton({ Name = "Activate Power", Callback = function()
    local Event = ReplicatedStorage:FindFirstChild("Remotes", true)
        and ReplicatedStorage.Remotes:FindFirstChild("Killers", true)
        and ReplicatedStorage.Remotes.Killers:FindFirstChild("Masked", true)
        and ReplicatedStorage.Remotes.Killers.Masked:FindFirstChild("Activatepower")
    if Event then Event:FireServer(Masked.CurrentPower) end
end })
SubKiller:AddButton({ Name = "Deactivate Power", Callback = function()
    local Event = ReplicatedStorage:FindFirstChild("Remotes", true)
        and ReplicatedStorage.Remotes:FindFirstChild("Killers", true)
        and ReplicatedStorage.Remotes.Killers:FindFirstChild("Masked", true)
        and ReplicatedStorage.Remotes.Killers.Masked:FindFirstChild("Deactivatepower")
    if Event then Event:FireServer() end
end })

-- ===== PLAYER / AIMBOT =====
SubAimBot:AddSection("Gun AimLock")
SubAimBot:AddToggle({
    Name = "Aim Lock",
    Default = false,
    Callback = function(v) GunAim.Enabled = v end
})
SubAimBot:AddDropdown({
    Name = "Target",
    Options = {"Killer", "Survivor", "SCP"},
    Default = "Killer",
    Callback = function(v) GunAim.TargetMode = v end
})
SubAimBot:AddDropdown({
    Name = "Aim Part",
    Options = {"Head", "HumanoidRootPart", "Torso"},
    Default = "HumanoidRootPart",
    Callback = function(v) GunAim.AimPart = v end
})
SubAimBot:AddSlider({
    Name = "FOV",
    Min = 50,
    Max = 1000,
    Default = 250,
    Callback = function(v) GunAim.FOV = v end
})
SubAimBot:AddSlider({
    Name = "Prediction",
    Min = 0,
    Max = 1,
    Default = 0.12,
    Rounding = 2,
    Callback = function(v) GunAim.PredictStrength = v end
})

SubAimBot:AddDivider()
SubAimBot:AddSection("Silent Aim (All Weapons)")
local SilentAimToggle = SubAimBot:AddToggle({
    Name = "Enable Silent Aim",
    Default = false,
    Tooltip = "Aim tanpa gerak kamera (hook)",
    Callback = function(v)
        SilentAim.Enabled = v
        if v then setupSilentAimHook() else removeSilentAimHook() end
    end
})
SubAimBot:AddSlider({
    Name = "Silent FOV",
    Min = 30,
    Max = 500,
    Default = 200,
    Callback = function(v) SilentAim.FOV = v end
})
SubAimBot:AddSlider({
    Name = "Silent Distance",
    Min = 50,
    Max = 800,
    Default = 400,
    Callback = function(v) SilentAim.Distance = v end
})
SubAimBot:AddDropdown({
    Name = "Silent Target",
    Options = {"Killer", "Survivor", "SCP"},
    Default = "Killer",
    Callback = function(v) SilentAim.TargetMode = v end
})
SubAimBot:AddDropdown({
    Name = "Silent Aim Part",
    Options = {"HumanoidRootPart", "Head", "Torso"},
    Default = "HumanoidRootPart",
    Callback = function(v) SilentAim.TargetPart = v end
})
SubAimBot:AddToggle({
    Name = "Enable Prediction",
    Default = true,
    Callback = function(v) SilentAim.Prediction = v end
})
SubAimBot:AddSlider({
    Name = "Prediction Strength",
    Min = 0,
    Max = 50,
    Default = 15,
    Callback = function(v) SilentAim.PredictStrength = v / 100 end
})
SubAimBot:AddSlider({
    Name = "Bullet Speed",
    Min = 100,
    Max = 2000,
    Default = 800,
    Callback = function(v) SilentAim.BulletSpeed = v end
})

-- ===== PLAYER / TOF =====
SubToF:AddSection("Twist of Fate")
SubToF:AddToggle({
    Name = "SilentAim ToF",
    Default = false,
    Callback = function(v) ToFAimConfig.Enabled = v end
})
SubToF:AddDropdown({
    Name = "Target",
    Options = {"Killer", "Survivor", "SCP"},
    Default = "Killer",
    Callback = function(v) ToFAimConfig.TargetMode = v end
})
SubToF:AddDropdown({
    Name = "Aim Part",
    Options = {"HumanoidRootPart", "Head", "Torso"},
    Default = "HumanoidRootPart",
    Callback = function(v) ToFAimConfig.AimPart = v end
})
SubToF:AddToggle({
    Name = "Aim Prediction",
    Default = true,
    Callback = function(v) ToFAimConfig.Predict = v end
})
SubToF:AddSlider({
    Name = "Predict Bullet Speed",
    Min = 50,
    Max = 1000,
    Default = 200,
    Callback = function(v) ToFAimConfig.BulletSpeed = v end
})
SubToF:AddSlider({
    Name = "Aim Range",
    Min = 10,
    Max = 300,
    Default = 90,
    Callback = function(v) ToFAimConfig.Range = v end
})
SubToF:AddSlider({
    Name = "Safe FOV (Dot Threshold)",
    Min = -1,
    Max = 1,
    Default = 0.5,
    Rounding = 2,
    Callback = function(v) ToFAimConfig.DotThreshold = v end
})

-- ===== PLAYER / PARRY =====
SubParry:AddSection("Parry Settings")
local AutoParryToggle = SubParry:AddToggle({
    Name = "Auto Parry",
    Default = false,
    Callback = function(v) Config.Surv_AutoParry = v end
})
-- Keybind terpisah untuk Auto Parry
SubParry:AddKeybind({
    Name = "Auto Parry Key",
    Default = Enum.KeyCode.None,
    OnPress = function()
        Config.Surv_AutoParry = not Config.Surv_AutoParry
        Window:Notify({ Title = "Auto Parry", Content = tostring(Config.Surv_AutoParry and "Enabled" or "Disabled"), Type = "info", Duration = 1 })
    end
})
SubParry:AddToggle({
    Name = "Safety Parry",
    Default = false,
    Callback = function(v) Config.Surv_ParrySafety = v end
})
SubParry:AddToggle({
    Name = "Aggressive Mode",
    Tooltip = "Langsung parry tanpa peduli face direction",
    Default = false,
    Callback = function(v) Config.Surv_ParryAggressive = v end
})
SubParry:AddToggle({
    Name = "ESP Range Circle",
    Tooltip = "Tampilkan radius jarak parry di karakter",
    Default = true,
    Callback = function(v) Config.Surv_ParryCircle = v end
})
SubParry:AddSlider({
    Name = "Parry Radius",
    Tooltip = "Jarak maksimal parry bereaksi",
    Min = 5,
    Max = 25,
    Default = 15,
    Callback = function(v) Config.Surv_ParryRadius = v end
})
SubParry:AddSlider({
    Name = "Face Sensitivity",
    Tooltip = "Sensitivitas arah pandang (1-10)",
    Min = -10,
    Max = 10,
    Default = 7,
    Callback = function(v) Config.Surv_ParryFace = v / 10 end
})
SubParry:AddDropdown({
    Name = "Ignore Skills",
    Options = {"Hidden S1", "Abyssal S1"},
    Default = {},
    Multi = true,
    Tooltip = "Abaikan skill tertentu",
    Callback = function(v)
        local parsed = {}
        for k, v2 in pairs(v) do
            if type(k) == "string" and v2 then parsed[k] = true
            elseif type(v2) == "string" then parsed[v2] = true end
        end
        Config.Ignored_Skills_List = parsed
    end
})
SubParry:AddToggle({
    Name = "Auto Crouch (Dodge S1)",
    Tooltip = "Otomatis jongkok saat Abyssal menggunakan S1",
    Default = false,
    Callback = function(v) Config.Surv_AutoCrouch = v end
})

local FakeParryToggle = SubParry:AddToggle({
    Name = "Enable Fake Parry",
    Default = false,
    Callback = function(v)
        FakeParry.Enabled = v
        if UserInputService.TouchEnabled then
            if v then CreateFakeParryButton() else RemoveFakeParryButton() end
        end
    end
})
-- Keybind untuk Fake Parry
SubParry:AddKeybind({
    Name = "Fake Parry Key",
    Default = Enum.KeyCode.G,
    OnPress = function()
        if FakeParry.Enabled then PlayFakeParry() end
    end
})
SubParry:AddDropdown({
    Name = "Fake Parry Animation",
    Options = {"Enten", "Stopwatch", "Fih", "BloodShield"},
    Default = "Enten",
    Callback = function(v) FakeParry.Animation = v end
})

-- ===== PLAYER / CROSSHAIR =====
SubCrosshair:AddSection("Crosshair")
local CrosshairToggle = SubCrosshair:AddToggle({
    Name = "Enable Crosshair",
    Default = false,
    Callback = function(v) Crosshair.Enabled = v end
})
CrosshairToggle:AddColorPicker({
    Name = "Crosshair Color",
    Default = Color3.fromRGB(255, 255, 255),
    Callback = function(v) Crosshair.Color = v end
})
SubCrosshair:AddDropdown({
    Name = "Style",
    Options = {"Plus", "Dot", "Circle"},
    Default = "Plus",
    Callback = function(v) Crosshair.Style = v end
})
SubCrosshair:AddSlider({
    Name = "Position X",
    Min = -100,
    Max = 100,
    Default = 0,
    Callback = function(v) Crosshair.OffsetX = v end
})
SubCrosshair:AddSlider({
    Name = "Position Y",
    Min = -100,
    Max = 100,
    Default = 0,
    Callback = function(v) Crosshair.OffsetY = v end
})

-- ===== ESP / ESP CHAM =====
SubESPCham:AddSection("ESP Cham")
local SurvivorESP = SubESPCham:AddToggle({
    Name = "ESP Survivor",
    Default = false,
    Callback = function(v) ESP.Survivor = v end
})
SurvivorESP:AddColorPicker({
    Name = "Survivor Color",
    Default = TeamColors.Survivor,
    Callback = function(v) TeamColors.Survivor = v end
})

local KillerESP = SubESPCham:AddToggle({
    Name = "ESP Killer",
    Default = false,
    Callback = function(v) ESP.Killer = v end
})
KillerESP:AddColorPicker({
    Name = "Killer Color",
    Default = TeamColors.Killer,
    Callback = function(v) TeamColors.Killer = v end
})

local ESPGeneratorToggle = SubESPCham:AddToggle({
    Name = "Generator",
    Default = false,
    Callback = function(v) ESP.Generator = v end
})
ESPGeneratorToggle:AddColorPicker({
    Name = "Generator Color",
    Default = GeneratorColor,
    Callback = function(v) GeneratorColor = v end
})

local ESPSCPToggle = SubESPCham:AddToggle({
    Name = "SCP",
    Default = false,
    Callback = function(v) ESP.SCP = v end
})
ESPSCPToggle:AddColorPicker({
    Name = "SCP Color",
    Default = SCPColor,
    Callback = function(v) SCPColor = v end
})

local ESPPalletToggle = SubESPCham:AddToggle({
    Name = "Pallet",
    Default = false,
    Callback = function(v) ESP.Pallet = v end
})
ESPPalletToggle:AddColorPicker({
    Name = "Pallet Color",
    Default = PalletColor,
    Callback = function(v) PalletColor = v end
})

local ESPWindowToggle = SubESPCham:AddToggle({
    Name = "Window",
    Default = false,
    Callback = function(v) ESP.Window = v end
})
ESPWindowToggle:AddColorPicker({
    Name = "Window Color",
    Default = WindowColor,
    Callback = function(v) WindowColor = v end
})

SubESPCham:AddSlider({
    Name = "ESP Distance",
    Min = 10,
    Max = 1000,
    Default = 100,
    Callback = function(v) ESP.Distance = v end
})

-- ===== ESP / ESP STATUS =====
SubESPStatus:AddSection("ESP Status")
SubESPStatus:AddToggle({
    Name = "Enable Status ESP",
    Default = false,
    Callback = function(v) ESPStatus.Enabled = v end
})
SubESPStatus:AddToggle({
    Name = "Show Name",
    Default = true,
    Callback = function(v) ESPStatus.ShowName = v end
})
SubESPStatus:AddToggle({
    Name = "Show Item",
    Default = true,
    Callback = function(v) ESPStatus.ShowItem = v end
})
SubESPStatus:AddToggle({
    Name = "Show Distance",
    Default = true,
    Callback = function(v) ESPStatus.ShowDistance = v end
})
SubESPStatus:AddToggle({
    Name = "Show Health",
    Default = false,
    Callback = function(v) ESPStatus.ShowHealth = v end
})
SubESPStatus:AddSlider({
    Name = "Status Radius",
    Min = 20,
    Max = 500,
    Default = 100,
    Callback = function(v) ESPStatus.Radius = v end
})

SubESPStatus:AddDivider()
SubESPStatus:AddSection("Teleport (Loop)")
SubESPStatus:AddButton({ Name = "TP Generator (Loop)", Callback = TeleportToGenerator })
SubESPStatus:AddButton({ Name = "TP Hook (Loop)", Callback = TeleportToHook })
SubESPStatus:AddButton({ Name = "TP Gate (Loop)", Callback = TeleportToGate })
SubESPStatus:AddButton({ Name = "TP Pallet (Loop)", Callback = TeleportToPallet })
SubESPStatus:AddButton({ Name = "TP Window (Loop)", Callback = TeleportToWindow })
SubESPStatus:AddDivider()
SubESPStatus:AddButton({ Name = "Refresh Map Cache", Callback = RefreshMapForTeleport })

-- ===== MISC / MOVEMENT =====
SubMovement:AddSection("Movement")
SubMovement:AddToggle({
    Name = "Walk Speed",
    Default = false,
    Callback = function(v)
        Movement.WalkSpeedEnabled = v
        if v then applyWalkSpeed()
        else
            local char = LocalPlayer.Character
            local hum = char and char:FindFirstChildOfClass("Humanoid")
            if hum then hum.WalkSpeed = Movement.OriginalWalkSpeed end
        end
    end
})
SubMovement:AddSlider({
    Name = "Walk Speed Value",
    Min = 16,
    Max = 32,
    Default = 17.6,
    Rounding = 1,
    Callback = function(v)
        Movement.WalkSpeedValue = v
        if Movement.WalkSpeedEnabled then applyWalkSpeed() end
    end
})
SubMovement:AddButton({
    Name = "Moonwalk",
    Callback = function()
        local success, err = pcall(function()
            loadstring(game:HttpGet("https://pastebin.com/raw/JWr0bW8u"))()
        end)
        if success then
            Window:Notify({ Title = "Moonwalk", Content = "GUI Moonwalk berhasil dimuat!", Type = "success", Duration = 3 })
        else
            Window:Notify({ Title = "Error", Content = "Gagal memuat Moonwalk!", Type = "warning", Duration = 3 })
        end
    end
})
SubMovement:AddToggle({
    Name = "No Clip",
    Default = false,
    Callback = function(v) toggleNoClip(v) end
})
SubMovement:AddToggle({
    Name = "Custom Jump Power",
    Default = false,
    Callback = function(v)
        Movement.JumpPowerEnabled = v
        if v then applyJumpPower()
        else
            local char = LocalPlayer.Character
            local hum = char and char:FindFirstChildOfClass("Humanoid")
            if hum then hum.JumpPower = Movement.OriginalJumpPower end
        end
    end
})
SubMovement:AddSlider({
    Name = "Jump Power Value",
    Min = 0,
    Max = 300,
    Default = 50,
    Callback = function(v)
        Movement.JumpPowerValue = v
        if Movement.JumpPowerEnabled then applyJumpPower() end
    end
})

-- ===== MISC / EMOTE =====
SubEmote:AddSection("Emote")
SubEmote:AddDropdown({
    Name = "Select Emote",
    Options = EmoteList,
    Default = "Mannrobics",
    Callback = function(v)
        Emote.Selected = v
        if EmoteButton.LabelRef then EmoteButton.LabelRef.Text = v end
    end
})
SubEmote:AddButton({ Name = "Play Emote", Callback = function() playEmote(Emote.Selected) end })
SubEmote:AddToggle({
    Name = "Show Emote Button",
    Default = false,
    Callback = function(v)
        EmoteButton.Show = v
        if v then createEmoteButton() else removeEmoteButton() end
    end
})

-- ===== MISC / FAKE TAG =====
SubFakeTag:AddSection("Fake Chat Tag")
SubFakeTag:AddToggle({
    Name = "Enable Fake Tag",
    Default = FakeTag.Enabled,
    Callback = function(v) FakeTag.Enabled = v end
})
SubFakeTag:AddInput({
    Name = "Chat Tag",
    Default = FakeTag.Text,
    Placeholder = "[WISNU]",
    Callback = function(v)
        if v ~= "" then FakeTag.Text = v end
    end
})

-- ===== VISUAL / GRAPHICS =====
SubGraphics:AddSection("Graphics")
SubGraphics:AddToggle({
    Name = "Fullbright",
    Default = false,
    Callback = function(v) Visual.Fullbright = v; applyVisual() end
})
SubGraphics:AddToggle({
    Name = "No Shadow",
    Default = false,
    Callback = function(v) Visual.NoShadow = v end
})
SubGraphics:AddToggle({
    Name = "Low Graphics",
    Default = false,
    Callback = function(v) Visual.LowGraphics = v; applyOptimization() end
})
SubGraphics:AddToggle({
    Name = "No Screen Effects",
    Default = false,
    Callback = function(v) Visual.NoScreenEffects = v; applyNoScreenEffects() end
})
SubGraphics:AddToggle({
    Name = "Clean Sky",
    Default = false,
    Callback = function(v) Visual.CleanSky = v; applyOptimization() end
})

-- ===== VISUAL / MORPH =====
SubMorph:AddSection("Morph Avatar")
SubMorph:AddButton({
    Name = "Apply Korless",
    Callback = function()
        ApplyKorless()
        Window:Notify({ Title = "Morph", Content = "Korless Morph Applied", Type = "success", Duration = 3 })
    end
})

-- ===== VISUAL / CLOCK =====
SubClock:AddSection("Clock & Ambient")
SubClock:AddSlider({
    Name = "Clock Time",
    Min = 0,
    Max = 24,
    Default = 14,
    Callback = function(v)
        Visual.ClockTime = v
        Visual.Ambient = true
        applyVisual()
    end
})
SubClock:AddSlider({
    Name = "Brightness",
    Min = 0,
    Max = 5,
    Default = 2,
    Rounding = 1,
    Callback = function(v)
        Visual.Brightness = v
        Visual.Ambient = true
        applyVisual()
    end
})

-- ===== VISUAL / ZOOM =====
SubZoom:AddSection("Zoom & FOV")
SubZoom:AddToggle({
    Name = "Third Person View",
    Default = false,
    Callback = function(v)
        Killer.ThirdPerson = v
        if not v then UpdateThirdPerson() end
    end
})
SubZoom:AddToggle({
    Name = "Unlimited Zoom Out",
    Default = false,
    Callback = function(v) CameraZoom.UnlimitedZoom = v; applyUnlimitedZoom() end
})
SubZoom:AddSlider({
    Name = "Max Zoom Distance",
    Min = 100,
    Max = 5000,
    Default = 1000,
    Callback = function(v)
        CameraZoom.MaxDistance = v
        if CameraZoom.UnlimitedZoom then applyUnlimitedZoom() end
    end
})
SubZoom:AddToggle({
    Name = "Custom FOV",
    Default = false,
    Callback = function(v) CameraZoom.FOVEnabled = v; applyCameraFOV() end
})
SubZoom:AddSlider({
    Name = "Camera FOV",
    Min = 40,
    Max = 120,
    Default = 70,
    Callback = function(v)
        CameraZoom.FOV = v
        if CameraZoom.FOVEnabled then applyCameraFOV() end
    end
})

-- ===== UI SETTINGS / MENU =====
SubUIMenu:AddSection("Menu Settings")
SubUIMenu:AddToggle({
    Name = "Custom Cursor",
    Default = true,
    Callback = function(v) Library.ShowCustomCursor = v end
})
SubUIMenu:AddDropdown({
    Name = "Notification Side",
    Options = {"Left", "Right"},
    Default = "Right",
    Callback = function(v) Window:SetNotifySide(v) end
})
SubUIMenu:AddDropdown({
    Name = "DPI Scale",
    Options = {"50%", "75%", "85%", "100%", "125%", "150%"},
    Default = "85%",
    Callback = function(v)
        v = v:gsub("%%", "")
        Window:SetDPIScale(tonumber(v))
    end
})
SubUIMenu:AddToggle({
    Name = "Glow AccentBar",
    Default = true,
    Callback = function(v) Window:SetHeaderGlow(v) end
})
SubUIMenu:AddToggle({
    Name = "Show Profile",
    Default = true,
    Callback = function(v) Window:SetProfileVisible(v) end
})
SubUIMenu:AddDivider()
SubUIMenu:AddSection("Keybinds")
SubUIMenu:AddLabel({ Text = "Menu Bind" })
SubUIMenu:AddKeybind({
    Name = "Menu Keybind",
    Default = Enum.KeyCode.RightShift,
    OnPress = function() Window:ToggleUI() end
})
SubUIMenu:AddDivider()
SubUIMenu:AddButton({
    Name = "Unload Script",
    Callback = function()
        if HideName.Connection then HideName.Connection:Disconnect(); HideName.Connection = nil end
        removeSilentAimHook()
        Library:Unload()
    end
})

-- ============================================================
--  BACKEND FUNCTIONS (SEMUA YANG HILANG) - TIDAK DIUBAH
-- ============================================================

-- Teleport functions
local function TeleportToPart(part)
    if not part then return end
    local char = LocalPlayer.Character
    local hrp = char and char:FindFirstChild("HumanoidRootPart")
    if hrp then
        local offset = Vector3.new(0, 3, 0)
        if part:IsA("BasePart") then
            hrp.CFrame = part.CFrame + offset
        elseif part:IsA("Model") then
            local p = part:FindFirstChildWhichIsA("BasePart")
            if p then hrp.CFrame = p.CFrame + offset end
        end
        Window:Notify({ Title = "Teleport", Content = "Berhasil!", Type = "success", Duration = 1 })
    end
end

local function TeleportToGenerator()
    local gens = {}
    for obj in pairs(ESPCache.Generators) do
        if obj and obj.Parent then
            table.insert(gens, obj)
        end
    end
    if #gens == 0 then 
        Window:Notify({ Title = "TP Generator", Content = "Tidak ada generator!", Type = "warning", Duration = 2 })
        return 
    end
    if TeleportIndex.Generator > #gens then TeleportIndex.Generator = 1 end
    
    local gen = gens[TeleportIndex.Generator]
    local part = gen:FindFirstChildWhichIsA("BasePart")
    if part then
        TeleportToPart(part)
        Window:Notify({ Title = "TP Generator", Content = "Generator " .. TeleportIndex.Generator, Type = "info", Duration = 1.2 })
    end
    TeleportIndex.Generator = TeleportIndex.Generator + 1
end

local function TeleportToHook()
    local hooks = {}
    for _, obj in ipairs(workspace:GetDescendants()) do
        if obj.Name == "Hook" and obj:IsA("Model") then
            table.insert(hooks, obj)
        end
    end
    if #hooks == 0 then 
        Window:Notify({ Title = "TP Hook", Content = "Tidak ada hook!", Type = "warning", Duration = 2 })
        return 
    end
    if TeleportIndex.Hook > #hooks then TeleportIndex.Hook = 1 end
    
    local hook = hooks[TeleportIndex.Hook]
    local part = hook:FindFirstChild("HookPoint") or hook:FindFirstChildWhichIsA("BasePart")
    if part then TeleportToPart(part) end
    TeleportIndex.Hook = TeleportIndex.Hook + 1
end

local function TeleportToGate()
    local gates = {}
    for _, obj in ipairs(workspace:GetDescendants()) do
        if obj.Name == "Gate" and obj:IsA("Model") then
            table.insert(gates, obj)
        end
    end
    if #gates == 0 then 
        Window:Notify({ Title = "TP Gate", Content = "Tidak ada gate!", Type = "warning", Duration = 2 })
        return 
    end
    if TeleportIndex.Gate > #gates then TeleportIndex.Gate = 1 end
    
    local gate = gates[TeleportIndex.Gate]
    local part = gate:FindFirstChildWhichIsA("BasePart")
    if part then TeleportToPart(part) end
    TeleportIndex.Gate = TeleportIndex.Gate + 1
end

local function TeleportToPallet()
    local pallets = {}
    for pal in pairs(ESPCache.Pallets) do
        if pal and pal.Parent then
            table.insert(pallets, pal)
        end
    end
    if #pallets == 0 then 
        Window:Notify({ Title = "TP Pallet", Content = "Tidak ada pallet!", Type = "warning", Duration = 2 })
        return 
    end
    if TeleportIndex.Pallet > #pallets then TeleportIndex.Pallet = 1 end
    
    local pallet = pallets[TeleportIndex.Pallet]
    local part = pallet:FindFirstChild("PrimaryPartPallet") or pallet:FindFirstChildWhichIsA("BasePart")
    if part then TeleportToPart(part) end
    TeleportIndex.Pallet = TeleportIndex.Pallet + 1
end

local function TeleportToWindow()
    local windows = {}
    for win in pairs(ESPCache.Windows) do
        if win and win.Parent then
            table.insert(windows, win)
        end
    end
    if #windows == 0 then 
        Window:Notify({ Title = "TP Window", Content = "Tidak ada window!", Type = "warning", Duration = 2 })
        return 
    end
    if TeleportIndex.Window > #windows then TeleportIndex.Window = 1 end
    
    local window = windows[TeleportIndex.Window]
    local part = window:FindFirstChild("Bottom") or window:FindFirstChildWhichIsA("BasePart")
    if part then TeleportToPart(part) end
    TeleportIndex.Window = TeleportIndex.Window + 1
end

local function RefreshMapForTeleport()
    for _, obj in ipairs(workspace:GetDescendants()) do
        if obj.Name == "Generator" then ESPCache.Generators[obj] = true
        elseif obj.Name == "Window" then ESPCache.Windows[obj] = true
        elseif obj.Name == "Pallet" or obj.Name == "Palletwrong" then ESPCache.Pallets[obj] = true
        end
    end
    TeleportIndex.Generator = 1
    TeleportIndex.Hook = 1
    TeleportIndex.Gate = 1
    TeleportIndex.Pallet = 1
    TeleportIndex.Window = 1
    Window:Notify({ Title = "Refresh Map", Content = "Cache diperbarui!", Type = "info", Duration = 2 })
end

local function teleportToFinishLine()
    local root = getRoot()
    if not root then return end
    local found = nil
    for _, obj in ipairs(workspace:GetDescendants()) do
        if string.lower(obj.Name) == "fininshline" and obj:IsA("BasePart") then
            found = obj; break
        end
    end
    if not found then 
        Window:Notify({ Title = "Error", Content = "fininshline not found", Type = "warning", Duration = 2 })
        return 
    end
    root.CFrame = found.CFrame + Vector3.new(0, 5, 0)
    Window:Notify({ Title = "Teleport", Content = "Finish Line", Type = "success", Duration = 1 })
end

-- Visual functions
local function applyVisual(force)
    if force or LastVisualState.Fullbright ~= Visual.Fullbright then
        LastVisualState.Fullbright = Visual.Fullbright
        if Visual.Fullbright then
            Lighting.Brightness = 2; Lighting.ClockTime = 14
            Lighting.Ambient = Color3.new(1,1,1); Lighting.OutdoorAmbient = Color3.new(1,1,1)
        else
            Lighting.Brightness = OriginalLighting.Brightness
            Lighting.ClockTime  = OriginalLighting.ClockTime
            Lighting.Ambient    = OriginalLighting.Ambient
            Lighting.OutdoorAmbient = OriginalLighting.OutdoorAmbient
        end
    end

    if force or LastVisualState.NoShadow ~= Visual.NoShadow then
        LastVisualState.NoShadow = Visual.NoShadow
        Lighting.GlobalShadows = not Visual.NoShadow
    end

    local ambientChanged = LastVisualState.Ambient ~= Visual.Ambient
        or LastVisualState.AmbientColor ~= Visual.AmbientColor
        or LastVisualState.Brightness   ~= Visual.Brightness
        or LastVisualState.ClockTime    ~= Visual.ClockTime

    if force or ambientChanged then
        LastVisualState.Ambient      = Visual.Ambient
        LastVisualState.AmbientColor = Visual.AmbientColor
        LastVisualState.Brightness   = Visual.Brightness
        LastVisualState.ClockTime    = Visual.ClockTime
        if Visual.Ambient then
            Lighting.Ambient        = Visual.AmbientColor
            Lighting.OutdoorAmbient = Visual.AmbientColor
            Lighting.Brightness     = Visual.Brightness
            Lighting.ClockTime      = Visual.ClockTime
        elseif not Visual.Fullbright then
            Lighting.Brightness     = OriginalLighting.Brightness
            Lighting.ClockTime      = OriginalLighting.ClockTime
            Lighting.Ambient        = OriginalLighting.Ambient
            Lighting.OutdoorAmbient = OriginalLighting.OutdoorAmbient
        end
    end
end

local function applyOptimization(force)
    if force or LastOptimizationState.LowGraphics ~= Visual.LowGraphics then
        LastOptimizationState.LowGraphics = Visual.LowGraphics
        pcall(function()
            settings().Rendering.QualityLevel = Visual.LowGraphics
                and Enum.QualityLevel.Level01
                or  Enum.QualityLevel.Automatic
        end)
    end
    if force or LastOptimizationState.CleanSky ~= Visual.CleanSky then
        LastOptimizationState.CleanSky = Visual.CleanSky
        if Visual.CleanSky then
            for _, v in ipairs(Lighting:GetChildren()) do
                if v:IsA("Sky") then v:Destroy() end
            end
        end
    end
end

local function applyNoScreenEffects()
    if Visual.NoScreenEffects then
        for _, v in pairs(Lighting:GetChildren()) do
            for _, t in pairs(ScreenEffectTypes) do
                if v:IsA(t) then DisabledEffects[v] = v.Enabled; v.Enabled = false end
            end
        end
    else
        for obj, s in pairs(DisabledEffects) do
            if obj and obj.Parent then obj.Enabled = s end
        end
        DisabledEffects = {}
    end
end

-- Movement / Anti-AFK
local function applyJumpPower()
    if not Movement.JumpPowerEnabled then return end
    local char = LocalPlayer.Character
    if not char then return end
    local hum = char:FindFirstChildOfClass("Humanoid")
    if hum then hum.JumpPower = Movement.JumpPowerValue end
end

local function applyWalkSpeed()
    if Connections.WalkSpeed then
        Connections.WalkSpeed:Disconnect()
        Connections.WalkSpeed = nil
    end

    Connections.WalkSpeed = RunService.Heartbeat:Connect(function()
        if not Movement.WalkSpeedEnabled then return end
        local char = LocalPlayer.Character
        if not char then return end
        local hum = char:FindFirstChildOfClass("Humanoid")
        if not hum then return end
        if shouldDisableWalkSpeed() then return end
        if hum.WalkSpeed ~= Movement.WalkSpeedValue then
            hum.WalkSpeed = Movement.WalkSpeedValue
        end
    end)
end

local function shouldDisableWalkSpeed()
    local char = LocalPlayer.Character
    if not char then return false end

    local hum = char:FindFirstChildOfClass("Humanoid")
    if hum then
        local animator = hum:FindFirstChildOfClass("Animator")
        if animator then
            for _, track in ipairs(animator:GetPlayingAnimationTracks()) do
                local anim = track.Animation
                if anim and anim.AnimationId then
                    if anim.AnimationId == "rbxassetid://127096285501517" then return true end
                    if anim.AnimationId == "rbxassetid://112166042383605" then return true end
                    if anim.AnimationId == "http://www.roblox.com/asset/?id=126965695851149" then return true end
                    if anim.AnimationId == "http://www.roblox.com/asset/?id=135084204086504" then return true end
                    if anim.AnimationId == "rbxassetid://123047897844134" then return true end
                    local id = anim.AnimationId:match("%d+")
                    if id and KillerAnims["rbxassetid://" .. id] then return true end
                end
            end
        end

        if hum.Health <= 0 or hum.Health < 2
        or char:GetAttribute("Downed") == true
        or char:GetAttribute("IsDown") == true
        or char:GetAttribute("Knocked") == true then
            return true
        end
    end
    return false
end

local function toggleNoClip(state)
    Movement.NoClip = state
    if state then
        if Connections.NoClip then Connections.NoClip:Disconnect() end
        Connections.NoClip = RunService.RenderStepped:Connect(function()
            if Movement.NoClip then applyNoClip() end
        end)
    else
        if Connections.NoClip then
            Connections.NoClip:Disconnect()
            Connections.NoClip = nil
        end
        local char = LocalPlayer.Character
        if char then
            for _, v in pairs(char:GetDescendants()) do
                if v:IsA("BasePart") then v.CanCollide = true end
            end
        end
    end
end

local function applyNoClip()
    local char = LocalPlayer.Character
    if not char then return end
    for _, v in pairs(char:GetDescendants()) do
        if v:IsA("BasePart") and v.CanCollide then
            v.CanCollide = not Movement.NoClip
        end
    end
end

local function applyGodMode()
    if not PlayerMods.GodMode then return end
    local char = LocalPlayer.Character
    if not char then return end
    local hum = char:FindFirstChildOfClass("Humanoid")
    if not hum then return end
    if hum.Health < hum.MaxHealth then
        pcall(function() hum.Health = hum.MaxHealth end)
    end
    local s = hum:GetState()
    if s == Enum.HumanoidStateType.Dead
    or s == Enum.HumanoidStateType.FallingDown
    or s == Enum.HumanoidStateType.Ragdoll then
        pcall(function() hum:ChangeState(Enum.HumanoidStateType.Running) end)
    end
end

-- Skill check
local function pressSpace()
    VirtualInputManager:SendKeyEvent(true, Enum.KeyCode.Space, false, game)
    task.wait()
    VirtualInputManager:SendKeyEvent(false, Enum.KeyCode.Space, false, game)
end

local function GetActionTarget()
    local current = PlayerGui
    for segment in string.gmatch(ActionPath, "[^%.]+") do
        current = current and current:FindFirstChild(segment)
    end
    return current
end

local function TriggerMobileButton()
    local b = GetActionTarget()
    if b and b:IsA("GuiObject") then
        local p, s = b.AbsolutePosition, b.AbsoluteSize
        local i = game:GetService("GuiService"):GetGuiInset()
        local cx, cy = p.X + (s.X/2) + i.X, p.Y + (s.Y/2) + i.Y
        pcall(function()
            VirtualInputManager:SendTouchEvent(TouchID, 0, cx, cy)
            task.wait(0.01)
            VirtualInputManager:SendTouchEvent(TouchID, 2, cx, cy)
        end)
    end
end

local function startSkillCheck()
    if Connections.SkillHeartbeat then Connections.SkillHeartbeat:Disconnect() end
    Connections.SkillHeartbeat = RunService.RenderStepped:Connect(function()
        if not Auto.SkillCheck or State.busy then return end
        
        local prompt = PlayerGui:FindFirstChild("SkillCheckPromptGui")
        if not prompt then return end
        
        local check = prompt:FindFirstChild("Check")
        if not check or not check.Visible then return end
        
        local line = check:FindFirstChild("Line")
        local goal = check:FindFirstChild("Goal")
        if not line or not goal then return end

        if Auto.SkillCheckMode == "Instant" then
            line.Rotation = goal.Rotation + 109
            
            State.busy = true
            task.spawn(function()
                if UserInputService.TouchEnabled then 
                    TriggerMobileButton()
                else 
                    pressSpace() 
                end
                
                task.wait(0.2) 
                State.busy = false
            end)
        else
            local lr = line.Rotation % 360
            local gr = goal.Rotation % 360
            local startRange = (gr + 102) % 360
            local endRange   = (gr + 116) % 360
            local success = (startRange > endRange and (lr >= startRange or lr <= endRange))
                         or (lr >= startRange and lr <= endRange)
                         
            if success then
                State.busy = true
                task.spawn(function()
                    if UserInputService.TouchEnabled then TriggerMobileButton()
                    else pressSpace() end
                    task.wait(0.05)
                    State.busy = false
                end)
            end
        end
    end)
end

-- Fake Parry button
local function CreateFakeParryButton()
    if State.FakeParryButton then State.FakeParryButton:Destroy() end
    local gui = Instance.new("ScreenGui")
    gui.Name = "FakeParryGui"; gui.ResetOnSpawn = false; gui.Parent = PlayerGui
    local btn = Instance.new("ImageButton")
    btn.Size = UDim2.new(0, 50, 0, 50)
    btn.Position = UDim2.new(0.65, 0, 0.60, 0)
    btn.BackgroundColor3 = Color3.fromRGB(255,255,255)
    btn.BackgroundTransparency = 0.9
    btn.Image = "rbxassetid://73705354917255"
    btn.ImageTransparency = 0.1
    btn.Parent = gui
    local corner = Instance.new("UICorner"); corner.CornerRadius = UDim.new(1,0); corner.Parent = btn
    local stroke = Instance.new("UIStroke")
    stroke.ApplyStrokeMode = Enum.ApplyStrokeMode.Border
    stroke.Thickness = 1.2
    stroke.Color = Color3.fromRGB(255,255,255)
    stroke.Transparency = 0.8
    stroke.Parent = btn
    btn.MouseButton1Click:Connect(function()
        if FakeParry.Enabled then PlayFakeParry() end
    end)
    State.FakeParryButton = gui
end

local function RemoveFakeParryButton()
    if State.FakeParryButton then State.FakeParryButton:Destroy(); State.FakeParryButton = nil end
end

local function PlayFakeParry()
    local char = LocalPlayer.Character
    if not char then return end
    local hum = char:FindFirstChildOfClass("Humanoid")
    if not hum then return end
    local animator = hum:FindFirstChildOfClass("Animator") or Instance.new("Animator", hum)
    if State.FakeParryTrack then State.FakeParryTrack:Stop(); State.FakeParryTrack = nil end
    local anim = Instance.new("Animation")
    anim.AnimationId = FakeParryAnimations[FakeParry.Animation]
    State.FakeParryTrack = animator:LoadAnimation(anim)
    State.FakeParryTrack.Priority = Enum.AnimationPriority.Action
    State.FakeParryTrack:Play()
end

-- Emote functions
local function playEmote(name)
    pcall(function() EmoteRemote:FireServer(name) end)
end

local function createEmoteButton()
    if EmoteButton.GuiInstance then EmoteButton.GuiInstance:Destroy() end
    local gui = Instance.new("ScreenGui")
    gui.Name = "EmoteButtonGui"; gui.ResetOnSpawn = false; gui.Parent = PlayerGui
    local btn = Instance.new("ImageButton")
    btn.Size = UDim2.new(0,50,0,50); btn.Position = UDim2.new(0.55,0,0.75,0)
    btn.BackgroundColor3 = Color3.fromRGB(255,255,255); btn.BackgroundTransparency = 0.9
    btn.Image = "rbxassetid://87624947008823"; btn.ImageTransparency = 0.1; btn.Parent = gui
    local corner = Instance.new("UICorner"); corner.CornerRadius = UDim.new(1,0); corner.Parent = btn
    local stroke = Instance.new("UIStroke")
    stroke.ApplyStrokeMode = Enum.ApplyStrokeMode.Border
    stroke.Thickness = 1.2; stroke.Color = Color3.fromRGB(255,255,255); stroke.Transparency = 0.8; stroke.Parent = btn
    local label = Instance.new("TextLabel")
    label.Size = UDim2.new(0,80,0,20); label.Position = UDim2.new(0.5,-40,-0.6,0)
    label.BackgroundTransparency = 1; label.Text = Emote.Selected
    label.TextColor3 = Color3.fromRGB(255,255,255); label.TextStrokeTransparency = 0.5
    label.Font = Enum.Font.GothamBold; label.TextSize = 11; label.Parent = btn
    btn.MouseButton1Click:Connect(function()
        playEmote(Emote.Selected)
        stroke.Color = Color3.fromRGB(90,120,210)
        task.delay(0.3, function() stroke.Color = Color3.fromRGB(255,255,255) end)
    end)
    EmoteButton.GuiInstance = gui
    EmoteButton.LabelRef    = label
end

local function removeEmoteButton()
    if EmoteButton.GuiInstance then EmoteButton.GuiInstance:Destroy(); EmoteButton.GuiInstance = nil; EmoteButton.LabelRef = nil end
end

-- Third Person
local function UpdateThirdPerson()
    local cam = workspace.CurrentCamera
    if not cam then return end
    
    local isKiller = LocalPlayer.Team and LocalPlayer.Team.Name == "Killer"
    local shouldBeActive = Killer.ThirdPerson and isKiller
    
    if shouldBeActive then
        if not Killer.ThirdPersonWasActive then 
            Killer.OriginalCameraType = cam.CameraType 
        end
        cam.CameraType = Enum.CameraType.Custom
        local char     = LocalPlayer.Character
        local hum      = char and char:FindFirstChildOfClass("Humanoid")
        
        if hum then hum.CameraOffset = Vector3.new(2, 1, 8) end
        Killer.ThirdPersonWasActive = true
    elseif Killer.ThirdPersonWasActive then
        if Killer.OriginalCameraType then
            cam.CameraType = Killer.OriginalCameraType
            Killer.OriginalCameraType = nil
        end
        local char = LocalPlayer.Character
        local hum  = char and char:FindFirstChildOfClass("Humanoid")
        
        if hum then hum.CameraOffset = Vector3.new(0, 0, 0) end
        Killer.ThirdPersonWasActive = false
    end
end

-- Zoom functions
local function applyUnlimitedZoom()
    if CameraZoom.UnlimitedZoom then
        LocalPlayer.CameraMaxZoomDistance = CameraZoom.MaxDistance
        LocalPlayer.CameraMinZoomDistance = CameraZoom.MinDistance
    else
        LocalPlayer.CameraMaxZoomDistance = 128
        LocalPlayer.CameraMinZoomDistance = 0.5
    end
end

local function applyCameraFOV()
    local cam = workspace.CurrentCamera
    if not cam then return end
    cam.FieldOfView = CameraZoom.FOVEnabled and CameraZoom.FOV or CameraZoom.DefaultFOV
end

-- Parry sensor
local function tapMobileParryButton()
    local playerGui = LocalPlayer:FindFirstChild("PlayerGui")
    if not playerGui then return end

    local survivorMob = playerGui:FindFirstChild("Survivor-mob")
    local parryBtn = survivorMob
        and survivorMob:FindFirstChild("Controls")
        and survivorMob.Controls:FindFirstChild("Gui-mob")

    if parryBtn and parryBtn.Visible then
        if firesignal then
            pcall(function()
                firesignal(parryBtn.MouseButton1Down)
                task.wait(0.01)
                firesignal(parryBtn.MouseButton1Up)
            end)
        end
    else
        pcall(function()
            if mouse2click then
                mouse2click()
                return
            end
            if mouse2press and mouse2release then
                mouse2press()
                task.wait(0.01)
                mouse2release()
                return
            end
            if MouseButton2Click then
                MouseButton2Click()
                return
            end
            VirtualInputManager:SendMouseButtonEvent(0, 0, 1, true, game, 0)
            task.wait(0.01)
            VirtualInputManager:SendMouseButtonEvent(0, 0, 1, false, game, 0)
        end)
    end
end

local function ExecuteParry()
    if State.ParryCooldown then return end
    pcall(function()
        local parryRemote = game:GetService("ReplicatedStorage"):FindFirstChild("Remotes"):FindFirstChild("Items"):FindFirstChild("Parrying Dagger"):FindFirstChild("parry")
        if parryRemote then
            for i = 1, 10 do parryRemote:FireServer() end
        end
        task.spawn(tapMobileParryButton)
    end)
end

local function ListenToParryResult()
    task.spawn(function()
        local remotes = game:GetService("ReplicatedStorage"):WaitForChild("Remotes", 5)
        local dagger = remotes and remotes:WaitForChild("Items", 5):WaitForChild("Parrying Dagger", 5)
        local parryResultRemote = dagger and dagger:WaitForChild("parryResult", 5)
        
        if parryResultRemote then
            parryResultRemote.OnClientEvent:Connect(function(arg1, arg2)
                local cdDur = tonumber(arg2) or ((arg1 == true) and 90 or 60)
                State.ParryCooldown = true
                if State.ParryCooldownThread then task.cancel(State.ParryCooldownThread) end
                State.ParryCooldownThread = task.delay(cdDur, function()
                    State.ParryCooldown = false
                end)
            end)
        end
    end)
end
ListenToParryResult()

function AttachParrySensor(kChar)
    if not kChar or Attached[kChar] then return end
    Attached[kChar] = true
    local humanoid = kChar:FindFirstChild("Humanoid")
    if not humanoid then
        humanoid = kChar:WaitForChild("Humanoid", 5)
        if not humanoid then return end
    end
    local animator = humanoid:FindFirstChildOfClass("Animator")
    if not animator then
        animator = humanoid:WaitForChild("Animator", 5)
        if not animator then return end
    end

    humanoid.ChildAdded:Connect(function(child)
        if child:IsA("Animator") then
            Attached[kChar] = nil
            AttachParrySensor(kChar)
        end
    end)

    kChar.AncestryChanged:Connect(function(_, parent)
        if not parent then
            Attached[kChar] = nil
        end
    end)

    animator.AnimationPlayed:Connect(function(track)
        local animId = track.Animation and track.Animation.AnimationId or ""
        local id = animId:match("%d+")
        local attackName = VALID_PARRY_IDS[id]
        if not attackName then return end
        if id == "80411309607666" and Config.Surv_AutoCrouch then
            local myChar = LocalPlayer.Character
            if IsDowned(myChar) then return end
            local myHRP = myChar and myChar:FindFirstChild("HumanoidRootPart")
            local kHRP = kChar:FindFirstChild("HumanoidRootPart")
            if myHRP and kHRP then
                local dist = (myHRP.Position - kHRP.Position).Magnitude
                if dist <= 40 then
                    TriggerCrouch()
                end
            end
            return 
        end
        
        if not Config.Surv_AutoParry then return end
        if State.ParryCooldown then return end 
        if Config.Ignored_Skills_List and Config.Ignored_Skills_List[attackName] then return end

        local myChar = LocalPlayer.Character
        if IsDowned(myChar) or not IsSafeToParry(myChar) then return end
        local myHRP = myChar and myChar:FindFirstChild("HumanoidRootPart")
        local kHRP = kChar:FindFirstChild("HumanoidRootPart")
        if not myHRP or not kHRP then return end
        
        local delta = myHRP.Position - kHRP.Position
        local startDistance = delta.Magnitude

        if Config.Surv_ParryAggressive then
            local aggressiveRadius = 12
            local detectionRadius = Config.Surv_ParryRadius + 5
            if startDistance > detectionRadius then return end
            if startDistance <= aggressiveRadius then
                ExecuteParry()
            else
                local tracker
                local startTime = os.clock()
                tracker = RunService.Heartbeat:Connect(function()
                    if os.clock() - startTime >= 1.5 or State.ParryCooldown or not myHRP or not kHRP or IsDowned(myChar) then
                        if tracker then tracker:Disconnect() end
                        return
                    end
                    local currentDist = (myHRP.Position - kHRP.Position).Magnitude
                    if currentDist <= aggressiveRadius then
                        ExecuteParry()
                        if tracker then tracker:Disconnect() end
                    end
                end)
            end
        else
            if startDistance > Config.Surv_ParryRadius then return end
            local myPosFlat = Vector3.new(myHRP.Position.X, 0, myHRP.Position.Z)
            local kPosFlat = Vector3.new(kHRP.Position.X, 0, kHRP.Position.Z)
            local flatDelta = myPosFlat - kPosFlat
            if flatDelta.Magnitude > 0 then
                local flatDirection = flatDelta.Unit
                local kLookFlat = Vector3.new(kHRP.CFrame.LookVector.X, 0, kHRP.CFrame.LookVector.Z).Unit
                local isFacing = kLookFlat:Dot(flatDirection)
                if isFacing < Config.Surv_ParryFace then return end
            end
            ExecuteParry()
        end
    end)
end

function TryAttach(p)
    if p ~= LocalPlayer and IsKiller(p) and p.Character then 
        AttachParrySensor(p.Character) 
    end
end

function SetupPlayer(p)
    if p == LocalPlayer then return end
    p.CharacterAdded:Connect(function() TryAttach(p) end)
    p:GetPropertyChangedSignal("Team"):Connect(function() TryAttach(p) end)
    if p.Character then TryAttach(p) end
end

-- Auto Stalk
local function getClosestSurvivorForStalk()
    local root = getRoot()
    if not root then return nil end
    local closest, shortest = nil, math.huge
    for _, plr in pairs(Players:GetPlayers()) do
        if plr ~= LocalPlayer and plr.Character then
            local hum = plr.Character:FindFirstChildOfClass("Humanoid")
            local hrp = plr.Character:FindFirstChild("HumanoidRootPart")
            if hum and hrp and hum.Health > 30 then
                local dist = (hrp.Position - root.Position).Magnitude
                if dist <= AutoStalk.StalkRange and dist < shortest then
                    shortest = dist; closest = plr
                end
            end
        end
    end
    return closest
end

local function startAutoStalk()
    if Connections.Stalk then return end
    Connections.Stalk = RunService.Heartbeat:Connect(function()
        if not AutoStalk.Enabled then return end
        local target = getClosestSurvivorForStalk()
        if not target or not target.Character then return end
        local stalkEvent = ReplicatedStorage:FindFirstChild("Remotes", true)
            and ReplicatedStorage.Remotes:FindFirstChild("Killers", true)
            and ReplicatedStorage.Remotes.Killers:FindFirstChild("Stalker", true)
            and ReplicatedStorage.Remotes.Killers.Stalker:FindFirstChild("StartStalking")
        if stalkEvent then pcall(function() stalkEvent:FireServer(target) end) end
    end)
end

local function stopAutoStalk()
    if Connections.Stalk then Connections.Stalk:Disconnect(); Connections.Stalk = nil end
end

-- Leap Bypass
local function StartLeapBypass()
    Connections.LeapBypass = task.spawn(function()
        local leapFunction, m2Function
        for _, v in pairs(getgc(true)) do
            if type(v) == "function" and islclosure(v) then
                local info = debug.getinfo(v)
                if info.name == "tryActivate" then leapFunction = v end
                if info.name == "playM2Animation" then m2Function = v end
                if leapFunction and m2Function then break end
            end
        end
        if not leapFunction and not m2Function then
            warn("Function tidak ditemukan.") return
        end
        while task.wait(0.1) do
            if not Killer.BypassLeap then break end
            for _, fn in pairs({leapFunction, m2Function}) do
                if fn then
                    for i, val in pairs(debug.getupvalues(fn)) do
                        if type(val) == "boolean" and val == true then
                            debug.setupvalue(fn, i, false)
                        end
                    end
                end
            end
        end
    end)
end

-- Cooldown Bypass
local function StartCooldownBypass()
    if not State.CorruptHandlerFunc then
        for _, v in pairs(getgc(true)) do
            if type(v) == "function" and islclosure(v) then
                local constants = debug.getconstants(v)
                if table.find(constants, "corrupt") and table.find(constants, "Immobile") then
                    State.CorruptHandlerFunc = v
                    break
                end
            end
        end
    end

    if not State.CorruptHandlerFunc then
        warn("Fungsi corruptHandler tidak ditemukan di memori.")
        return
    end
    
    if Connections.CooldownBypass then 
        Connections.CooldownBypass:Disconnect() 
    end
    
    Connections.CooldownBypass = RunService.Heartbeat:Connect(function()
        if not Killer.BypassCooldown then return end
        if State.CorruptHandlerFunc then
            local upvalues = debug.getupvalues(State.CorruptHandlerFunc)
            for idx, val in pairs(upvalues) do
                if type(val) == "boolean" then
                    if val == false then
                        debug.setupvalue(State.CorruptHandlerFunc, idx, true)
                    end
                end
            end
        end
    end)
end

local function StopCooldownBypass()
    if Connections.CooldownBypass then
        Connections.CooldownBypass:Disconnect()
        Connections.CooldownBypass = nil
    end
end

-- Attack Aim
local function startAttackAim()
    if Connections.AttackAim then return end
    Connections.AttackAim = RunService.RenderStepped:Connect(function()
        if not AttackAim.Enabled then return end
        if not AttackAim.Holding then return end
        local cam = workspace.CurrentCamera
        if not cam then return end
        if State.AttackAimMode == "Spear" then
            local target = getClosestSpearTarget()
            if not target then return end
            local aimPos = SpearAimbotCalc(target.Position)
            if not aimPos then return end
            cam.CFrame = CFrame.new(cam.CFrame.Position, aimPos)
        else
            local target = getClosestAttackTarget()
            if not target then return end
            local pos = target.Position
            if AttackAim.Predict then pos = pos + (target.AssemblyLinearVelocity * AttackAim.PredictStrength) end
            cam.CFrame = CFrame.new(cam.CFrame.Position, pos)
        end
    end)
end

local function getClosestAttackTarget()
    local cam = workspace.CurrentCamera
    local center = Vector2.new(cam.ViewportSize.X / 2, cam.ViewportSize.Y / 2)
    local closest, shortest = nil, AttackAim.FOV
    for _, p in ipairs(Players:GetPlayers()) do
        if p ~= LocalPlayer and p.Team and p.Team.Name == "Survivors" and p.Character then
            local hrp = p.Character:FindFirstChild(AttackAim.AimPart)
            local hum = p.Character:FindFirstChildOfClass("Humanoid")
            if hrp and hum and hum.Health > 0 then
                local pos, visible = cam:WorldToViewportPoint(hrp.Position)
                if visible then
                    local dist = (Vector2.new(pos.X, pos.Y) - center).Magnitude
                    if dist < shortest then shortest = dist; closest = hrp end
                end
            end
        end
    end
    return closest
end

local function getClosestSpearTarget()
    local cam = workspace.CurrentCamera
    local center = Vector2.new(cam.ViewportSize.X / 2, cam.ViewportSize.Y / 2)
    local closest, shortest = nil, SpearAim.FOV
    for _, p in ipairs(Players:GetPlayers()) do
        if p ~= LocalPlayer and p.Team and p.Team.Name == "Survivors" and p.Character then
            local hrp = p.Character:FindFirstChild(SpearAim.AimPart)
            local hum = p.Character:FindFirstChildOfClass("Humanoid")
            if hrp and hum and hum.Health > 0 then
                local pos, visible = cam:WorldToViewportPoint(hrp.Position)
                if visible then
                    local dist = (Vector2.new(pos.X, pos.Y) - center).Magnitude
                    if dist < shortest then shortest = dist; closest = hrp end
                end
            end
        end
    end
    return closest
end

local function SpearAimbotCalc(targetPos)
    local root = getRoot()
    if not root then return nil end
    local startPos = root.Position + Vector3.new(0, 2, 0)
    local distance = (targetPos - startPos).Magnitude
    local time     = distance / SpearAim.Speed
    local drop     = 0.5 * SpearAim.Gravity * time * time
    return targetPos + Vector3.new(0, drop, 0)
end

-- Korless Morph
local KorlessMorph = {
    Enabled = false
}

local function ApplyKorless()
    local plr = game.Players.LocalPlayer

    local function Morph()
        repeat task.wait()
        until plr.Character
            and plr.Character:FindFirstChild("HumanoidRootPart")
            and plr.Character:FindFirstChild("Right Leg")

        task.wait(0.1)
        local char = plr.Character

        pcall(function()
            char.Head.Transparency = 1

            local face = char.Head:FindFirstChild("face")
            if face then
                face:Destroy()
            end

            char["Right Leg"].Transparency = 1

            local mesh = Instance.new("MeshPart")
            mesh.Name = "KorlessHead"
            mesh.Size = Vector3.new(1.5,1.5,1.5)
            mesh.CanCollide = false
            mesh.MeshId = "rbxassetid://902942096"
            mesh.TextureID = "rbxassetid://902843398"
            mesh.CFrame = char["Right Leg"].CFrame * CFrame.new(0,0.5,0)
            mesh.Parent = char

            local weld = Instance.new("WeldConstraint")
            weld.Part0 = char["Right Leg"]
            weld.Part1 = mesh
            weld.Parent = mesh
        end)
    end

    Morph()

    if KorlessMorph.Connection then
        KorlessMorph.Connection:Disconnect()
    end

    KorlessMorph.Connection = plr.CharacterAdded:Connect(function()
        task.wait(1)
        Morph()
    end)
end

-- Hook Vault for fast vault
local function normalizeId(id)
    local num = tostring(id):match("%d+")
    return num and ("rbxassetid://" .. num)
end

local function hookVault(char)
    local hum = char:FindFirstChildOfClass("Humanoid")
    if not hum then return end
    local animator = hum:FindFirstChildOfClass("Animator")
    if not animator then return end
    animator.AnimationPlayed:Connect(function(track)
        if not FastVault.Enabled then return end
        local anim = track.Animation
        if not anim or not anim.AnimationId then return end
        local id = normalizeId(anim.AnimationId)
        if not id then return end
        local replaceId = FastVault.ReplaceMap[id]
        if not replaceId then return end
        if VaultTracks[track] then return end
        VaultTracks[track] = true
        track:Stop()
        local newAnim = Instance.new("Animation"); newAnim.AnimationId = replaceId
        local newTrack = animator:LoadAnimation(newAnim)
        newTrack.Priority = Enum.AnimationPriority.Action
        newTrack:Play(); newTrack:AdjustSpeed(FastVault.Speed)
        newTrack.Stopped:Connect(function() VaultTracks[track] = nil end)
    end)
end

-- ============================================================
--  EVENT HANDLERS & LOOPS
-- ============================================================

-- Setup Parry Sensor for all players
for _, p in pairs(Players:GetPlayers()) do 
    SetupPlayer(p) 
end
Players.PlayerAdded:Connect(SetupPlayer)

task.spawn(function()
    while true do 
        task.wait(5) 
        for _, p in pairs(Players:GetPlayers()) do 
            TryAttach(p) 
        end 
    end
end)

-- Character events
LocalPlayer.CharacterAdded:Connect(function(char)
    task.wait(0.8)
    applyJumpPower()
    applyWalkSpeed()
end)

LocalPlayer.CharacterAdded:Connect(function(char)
    task.wait(0.8)
    if Movement.NoClip then task.wait(0.3); toggleNoClip(true) end
end)

LocalPlayer.CharacterAdded:Connect(function(char)
    local hum = char:WaitForChild("Humanoid"); task.wait(0.5)
    if State.ParryCircle then State.ParryCircle:Destroy(); State.ParryCircle = nil end
end)

LocalPlayer.CharacterAdded:Connect(function()
    task.wait(1)
    GunAim.Target = nil; GunAim.Holding = false
    applyCameraFOV()
end)

LocalPlayer.CharacterAdded:Connect(function(char)
    task.wait(0.5)
    applyUnlimitedZoom()
    hookVault(char)
end)

LocalPlayer.CharacterAdded:Connect(function(char)
    task.wait(0.8)
    applyJumpPower()
    applyWalkSpeed()
    
    TeleportIndex.Generator = 1
    TeleportIndex.Hook = 1
    TeleportIndex.Gate = 1
    TeleportIndex.Pallet = 1
    TeleportIndex.Window = 1
end)

-- Auto GodMode & other loops
RunService.Heartbeat:Connect(function()
    local now = tick()
    
    HandleAutoPallet()

    if now - Timers.lastVaultBlock >= 1.5 then
        Timers.lastVaultBlock = now
        HandleBlockVaults()
    end

    if now - Timers.lastGodMode >= 0.1 then
        Timers.lastGodMode = now
        applyGodMode()
    end

    if now - Timers.lastKillerUpdate >= 0.05 then
        Timers.lastKillerUpdate = now

        if Killer.KillAll then
            local root = getRoot()
            if root then
                if not State.KillerTarget
                or not State.KillerTarget:FindFirstChild("Humanoid")
                or State.KillerTarget.Humanoid.Health <= 35 then
                    State.KillerTarget = GetNearestAliveSurvivor()
                end
                if State.KillerTarget then
                    local targetHRP = State.KillerTarget:FindFirstChild("HumanoidRootPart")
                    if targetHRP then
                        local velocity = targetHRP.AssemblyLinearVelocity
                        local predict  = velocity * 0.15
                        local targetPos = targetHRP.Position + predict
                        local behind    = targetHRP.CFrame.LookVector * -3
                        root.CFrame = CFrame.new(targetPos + behind, targetPos)
                    end
                    pcall(function() AttackEvent:FireServer(false) end)
                end
            end
        end

        if Movement.WalkSpeedEnabled then
            local char = LocalPlayer.Character
            local hum  = char and char:FindFirstChildOfClass("Humanoid")
            if hum then
                if shouldDisableWalkSpeed() then
                    if hum.WalkSpeed == Movement.WalkSpeedValue then
                        hum.WalkSpeed = Movement.OriginalWalkSpeed
                    end
                else
                    if hum.WalkSpeed ~= Movement.WalkSpeedValue then
                        hum.WalkSpeed = Movement.WalkSpeedValue
                    end
                end
            end
        end
    end
end)

-- ESP Update loop
RunService.RenderStepped:Connect(function()
    local root = getRoot()
    if not root then return end
    local now = tick()
    local hrp = root

    if now - Timers.lastESPUpdate >= 0.05 then
        Timers.lastESPUpdate = now

        for _, p in pairs(Players:GetPlayers()) do
            if p ~= LocalPlayer and p.Character then
                local char = p.Character
                local hum  = char:FindFirstChildOfClass("Humanoid")
                if hum and hum.Health > 0 then
                    local hrp2 = char:FindFirstChild("HumanoidRootPart")
                    if hrp2 then
                        local distance = (hrp2.Position - root.Position).Magnitude
                        if distance <= ESP.Distance then
                            if ESP.Survivor and p.Team and p.Team.Name == "Survivors" then
                                createESP(char, TeamColors.Survivor)
                            elseif ESP.Killer and p.Team and p.Team.Name == "Killer" then
                                createESP(char, TeamColors.Killer)
                            else
                                removeESP(char)
                            end
                        else
                            removeESP(char)
                        end
                    end
                    createStatusESP(p, char, root)
                else
                    removeESP(char)
                end
            end
        end

        if ESP.Generator then
            for gen in pairs(ESPCache.Generators) do UpdateGenerator(gen) end
        end

        for obj in pairs(ESPCache.Windows) do UpdateMapESP(obj, root) end
        for obj in pairs(ESPCache.Pallets) do UpdateMapESP(obj, root) end

        UpdateSCPEsp(root)
        applyVisual()
        applyNoScreenEffects()
        updateParryCircle()
    end
    
    drawCrosshair()
    UpdateThirdPerson()
    
    if Config.Surv_ParryCircle and Config.Surv_AutoParry and hrp then 
        if not State.AutoParryAdornment or State.AutoParryAdornment.Parent ~= hrp then 
            if State.AutoParryAdornment then State.AutoParryAdornment:Destroy() end
            State.AutoParryAdornment = Instance.new("CylinderHandleAdornment")
            State.AutoParryAdornment.Name = "AutoParryCircleESP"
            State.AutoParryAdornment.Height = 0.05
            State.AutoParryAdornment.Transparency = 0.3
            State.AutoParryAdornment.Adornee = hrp
            State.AutoParryAdornment.Parent = hrp
            State.AutoParryAdornment.ZIndex = 0
            State.AutoParryAdornment.AlwaysOnTop = false 
        end
        local cR = Config.Surv_ParryRadius
        State.AutoParryAdornment.Radius = cR
        State.AutoParryAdornment.InnerRadius = math.max(0.1, cR - 0.15)
        State.AutoParryAdornment.CFrame = CFrame.new(0, -3, 0) * CFrame.Angles(math.rad(90), 0, 0)
        if State.ParryCooldown then 
            State.AutoParryAdornment.Color3 = Color3.fromRGB(255, 128, 0) 
        elseif Config.Surv_ParryAggressive then 
            State.AutoParryAdornment.Color3 = Color3.fromRGB(255, 0, 0) 
        else 
            State.AutoParryAdornment.Color3 = Color3.fromRGB(0, 255, 255) 
        end 
    elseif State.AutoParryAdornment then 
        State.AutoParryAdornment:Destroy()
        State.AutoParryAdornment = nil 
    end
end)

-- Auto Pallet logic
function HandleAutoPallet()
    if not Auto.PalletDrop then return end
    
    local plr = Players.LocalPlayer
    if not (plr.Team and plr.Team.Name == "Survivors") then return end

    local now = tick()
    if now - Timers.lastPalletScan < 0.2 then return end
    Timers.lastPalletScan = now

    if now - Timers.lastPalletDrop < 2.5 then return end

    local root = getRoot()
    if not root then return end
    local hum = plr.Character:FindFirstChildOfClass("Humanoid")
    if not hum or hum.Health <= 0 then return end

    local killerRoot, killerDist = GetNearestKiller()
    if not killerRoot or killerDist > Auto.PalletDropDist then return end

    local remotes = ReplicatedStorage:FindFirstChild("Remotes")
    local palletFold = remotes and remotes:FindFirstChild("Pallet")
    local dropEvent = palletFold and palletFold:FindFirstChild("PalletDropEvent")
    if not dropEvent then return end

    local bestPallet = nil
    local bestDist = 8 

    local function findPalletPointSlide(model)
        local slide = model:FindFirstChild("PalletPointSlide")
        if slide then return slide end
        for _, child in ipairs(model:GetDescendants()) do
            if child.Name == "PalletPointSlide" then return child end
        end
        return model:FindFirstChild("PalletPoint")
    end

    for pal, _ in pairs(ESPCache.Pallets) do
        if not pal or State.UsedPallets[pal] then continue end

        local refPart = pal:FindFirstChild("PalletPoint") or pal:FindFirstChild("PalletPointSlide")
        if not refPart then continue end

        local ok, pos = pcall(function() return refPart.Position end)
        if not ok or not pos then continue end

        local d = (root.Position - pos).Magnitude
        if d < bestDist then
            bestDist = d
            bestPallet = pal
        end
    end

    if bestPallet then
        local fireTarget = findPalletPointSlide(bestPallet)
        if fireTarget then
            pcall(function() dropEvent:FireServer(fireTarget) end)
            State.UsedPallets[bestPallet] = true
            Timers.lastPalletDrop = now
        end
    end
end

-- Block Vaults
function HandleBlockVaults()
    if not Killer.BlockVaults then return end
    local remotes = ReplicatedStorage:FindFirstChild("Remotes")
    local vaultEvent = remotes and remotes:FindFirstChild("Window") and remotes.Window:FindFirstChild("VaultEvent")
    if not vaultEvent then return end

    local map = workspace:FindFirstChild("Map")
    local vaultsFolder = map and map:FindFirstChild("Vaults")
    
    if vaultsFolder then
        for _, vault in ipairs(vaultsFolder:GetChildren()) do
            for _, part in ipairs(vault:GetChildren()) do
                if part:IsA("BasePart") then
                    pcall(function() vaultEvent:FireServer(part, true) end)
                end
            end
        end
    else
        for window in pairs(ESPCache.Windows) do
            if window and window.Parent then
                for _, child in ipairs(window:GetDescendants()) do
                    if child:IsA("BasePart") then
                        pcall(function() vaultEvent:FireServer(child, true) end)
                    end
                end
            end
        end
    end
end

-- ============================================================
--  NOTIFIKASI & SAVE MANAGER
-- ============================================================
Window:Notify({
    Title = "Wisnu Hub",
    Content = "Violence District Loaded! (Hide Name + Silent Aim)",
    Type = "success",
    Duration = 4
})

Window:SaveConfig()

print("✅ Wisnu Hub - Violence District UI Migrated!")
end

-- 4. JALANKAN SISTEM KEY
Onyx.Callbacks.OnSuccess = function()
    MainScript()
end

Onyx:LaunchJunkie({
    Service = "Wisnu",
    Identifier = "1163413",
    Provider = "Wisnu Hub"
})