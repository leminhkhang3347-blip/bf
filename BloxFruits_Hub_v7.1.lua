--[[
  Blox Fruits | Multi-Tab Panel (No Sliders) + Real Combat VFX (v7.1)
  v7.1 thay doi:
   - FIX FillCup: truyen dung Cup (Tool) -> het loi "attempt to index nil with 'Name'"
   - FIX "loi: nil": remote tra ve nil la THANH CONG, khong con bi bao loi
   - Hung nuoc: bay toi vung nuoc, chui duoi NGON BANG (icicle) roi cham + Activate Cup
   - Mob Leader: tim boss dong (Enemies / ReplicatedStorage / EnemySpawns / workspace), tuan tra nhieu diem, khong dung im
   - Them nut "Scan Data": quet NPC / Prompt / Remote / vat the quanh nguoi -> copy + luu file
   - Log them moi remote game goi (tru RegisterAttack/RegisterHit)
]]

local function closeExisting()
    if getgenv and getgenv().BF_AUTOFARM_CLOSE then
        pcall(getgenv().BF_AUTOFARM_CLOSE)
    end
end
closeExisting()

local Players = game:GetService("Players")
local RS = game:GetService("ReplicatedStorage")
local TweenService = game:GetService("TweenService")
local RunService = game:GetService("RunService")
local VirtualUser = game:GetService("VirtualUser")
local UserInputService = game:GetService("UserInputService")
local Debris = game:GetService("Debris")
local VIM
pcall(function() VIM = game:GetService("VirtualInputManager") end)

if not game:IsLoaded() then game.Loaded:Wait() end
local plr = Players.LocalPlayer
repeat task.wait(0.2) until plr.Character and plr.Character:FindFirstChild("HumanoidRootPart")

local CFG = {
    -- Farm & Combat
    Enabled = false,
    KillAura = false,
    KillAuraPlayers = false,
    Weapon = "Melee",
    InstantHit = true,
    M1Effect = true,
    HitVFX = true,
    AutoBuso = true,
    AutoSkillZX = false,
    SmartCluster = true,
    SkipGhost = true,
    Boss = false,
    MultiAttack = true,
    ScreenClick = false,
    -- Stats
    AutoStats = false,
    StatMelee = true,
    StatDefense = true,
    StatSword = false,
    StatGun = false,
    StatFruit = false,
    StatAmount = 3,
    -- Melee & Boss
    AutoMelee = false,
    SelectedMelee = "Electric",
    AutoBoss = false,
    SelectedBoss = "",
    -- Quest & Item
    AutoSaberV1 = false,
    AutoSaberV2 = false,
    AutoSwanGlasses = false,
    AutoWardenSword = false,
    AutoPoleV1 = false,
    -- Numeric Config (Stepper - / +)
    FarHeight = 16,
    FlyHeight = 15,
    TweenSpeed = 175,
    BringRadius = 220,
    HitRange = 60,
    HitBurst = 2,
    AttackDelay = 0.03,
}

local SEA1_ID = 2753915549
local SEA2_ID = 4442272183
local SEA3_ID = 7449423635

local function getCurrentSea()
    local pid = game.PlaceId
    if pid == SEA1_ID or pid == 85211729168715 then return 1 end
    if pid == SEA2_ID then return 2 end
    if pid == SEA3_ID then return 3 end
    return 1
end

local MELEE = {
    {
        id = "Dark Step", name = "Black Leg (Dark Step)",
        beli = 150000, frags = 0, lvReq = 1,
        npcNames = { "Dark Step Teacher" },
        npcPos = {
            [1] = CFrame.new(-985, 14, 3983),
            [2] = CFrame.new(-4988, 315, -3205),
            [3] = CFrame.new(-4996, 315, -3210),
        },
        masteryReq = {}, itemsReq = {},
        steps = { { "BuyBlackLeg", true }, { "BuyBlackLeg" } }
    },
    {
        id = "Electric", name = "Electro (Electric)",
        beli = 500000, frags = 0, lvReq = 1,
        npcNames = { "Mad Scientist" },
        npcPos = {
            [1] = CFrame.new(-5384, 315, -2155),
            [2] = CFrame.new(-4980, 315, -3215),
            [3] = CFrame.new(-5005, 315, -3200),
        },
        masteryReq = {}, itemsReq = {},
        specialQuest = "ElectroCloudQuest",
        steps = { { "BuyElectro", true }, { "BuyElectro" } }
    },
    {
        id = "Water Kung Fu", name = "Fishman Karate (Water Kung Fu)",
        beli = 750000, frags = 0, lvReq = 1,
        npcNames = { "Water Kung Fu Teacher" },
        npcPos = {
            [1] = CFrame.new(61583, 19, 989),
            [2] = CFrame.new(-4970, 315, -3220),
            [3] = CFrame.new(-5015, 315, -3190),
        },
        masteryReq = {}, itemsReq = {},
        steps = { { "BuyFishmanKarate", true }, { "BuyFishmanKarate" } }
    },
    {
        id = "Dragon Breath", name = "Dragon Claw (Dragon Breath)",
        beli = 0, frags = 1500, lvReq = 700,
        npcNames = { "Sabi" },
        npcPos = {
            [2] = CFrame.new(708, 185, 650),
            [3] = CFrame.new(-5025, 315, -3180),
        },
        masteryReq = {}, itemsReq = {},
        steps = { { "BlackbeardReward", "DragonClaw", "1" }, { "BlackbeardReward", "DragonClaw", "2" } }
    },
    {
        id = "Superhuman", name = "Superhuman",
        beli = 3000000, frags = 0, lvReq = 700,
        npcNames = { "Martial Arts Master" },
        npcPos = {
            [2] = CFrame.new(1375, 248, -5187),
            [3] = CFrame.new(-5035, 315, -3170),
        },
        masteryReq = {
            { tool = "Dark Step", mas = 300 },
            { tool = "Electric", mas = 300 },
            { tool = "Water Kung Fu", mas = 300 },
            { tool = "Dragon Breath", mas = 300 },
        },
        itemsReq = {},
        steps = { { "BuySuperhuman", true }, { "BuySuperhuman" } }
    },
    {
        id = "Death Step", name = "Death Step",
        beli = 2500000, frags = 5000, lvReq = 700,
        npcNames = { "Phoeyu, the Reformed" },
        npcPos = {
            [2] = CFrame.new(6348, 297, -6765),
            [3] = CFrame.new(-4990, 315, -3230),
        },
        masteryReq = {
            { tool = "Dark Step", mas = 400 },
        },
        itemsReq = {
            { name = "Library Key", count = 1, boss = "Awakened Ice Admiral", source = "Boss Awakened Ice Admiral (Ice Castle - 10% drop)" },
        },
        steps = { { "BuyDeathStep", true }, { "BuyDeathStep" } }
    },
    {
        id = "Sharkman Karate", name = "Sharkman Karate",
        beli = 2500000, frags = 5000, lvReq = 700,
        npcNames = { "Daigrock, the Sharkman" },
        npcPos = {
            [2] = CFrame.new(-2604, 239, -10315),
            [3] = CFrame.new(-4980, 315, -3235),
        },
        masteryReq = {
            { tool = "Water Kung Fu", mas = 400 },
        },
        itemsReq = {
            { name = "Water Key", count = 1, boss = "Tide Keeper", source = "Boss Tide Keeper (Forgotten Island - 5% drop)" },
        },
        steps = { { "BuySharkmanKarate", true }, { "BuySharkmanKarate" } }
    },
    {
        id = "Electric Claw", name = "Electric Claw",
        beli = 3000000, frags = 5000, lvReq = 1500,
        npcNames = { "Previous Hero" },
        npcPos = {
            [3] = CFrame.new(-10371, 332, -10131),
        },
        masteryReq = {
            { tool = "Electric", mas = 400 },
        },
        itemsReq = {},
        specialQuest = "ElectricClaw30s",
        steps = { { "BuyElectricClaw", true }, { "BuyElectricClaw" } }
    },
    {
        id = "Dragon Talon", name = "Dragon Talon",
        beli = 3000000, frags = 5000, lvReq = 1500,
        npcNames = { "Uzoth" },
        npcPos = {
            [3] = CFrame.new(5662, 1211, 865),
        },
        masteryReq = {
            { tool = "Dragon Breath", mas = 400 },
        },
        itemsReq = {
            { name = "Fire Essence", count = 1, source = "Quay Death King (50 Bones/lan - 3%)" },
        },
        specialQuest = "RollFireEssence",
        steps = { { "BuyDragonTalon", true }, { "BuyDragonTalon" } }
    },
    {
        id = "Godhuman", name = "Godhuman",
        beli = 5000000, frags = 5000, lvReq = 1500,
        npcNames = { "Ancient Monk" },
        npcPos = {
            [3] = CFrame.new(-13776, 334, -9876),
        },
        masteryReq = {
            { tool = "Superhuman", mas = 400 },
            { tool = "Death Step", mas = 400 },
            { tool = "Sharkman Karate", mas = 400 },
            { tool = "Electric Claw", mas = 400 },
            { tool = "Dragon Talon", mas = 400 },
        },
        itemsReq = {
            { name = "Fish Tail", count = 20, source = "Farm Fishman (Sea 1/3)" },
            { name = "Magma Ore", count = 20, source = "Farm Magma (Sea 1/2)" },
            { name = "Dragon Scale", count = 10, source = "Farm Dragon Crew (Hydra Island)" },
            { name = "Mystic Droplet", count = 10, source = "Farm Sea Soldier (Forgotten Island)" },
        },
        steps = { { "BuyGodhuman", true }, { "BuyGodhuman" } }
    },
    {
        id = "Sanguine Art", name = "Sanguine Art",
        beli = 5000000, frags = 5000, lvReq = 1500,
        npcNames = { "Shafi" },
        npcPos = {
            [3] = CFrame.new(-16514, 23, -191),
        },
        masteryReq = {},
        itemsReq = {
            { name = "Leviathan Heart", count = 1, source = "San Leviathan + keo tim ve Tiki Outpost" },
            { name = "Demonic Wisp", count = 20, source = "Farm Demonic Soul (Haunted Castle)" },
            { name = "Vampire Fang", count = 20, source = "Farm Vampire (Graveyard)" },
            { name = "Dark Fragment", count = 2, boss = "Darkbeard", source = "Boss Darkbeard (Dark Arena)" },
        },
        steps = { { "BuySanguineArt", true }, { "BuySanguineArt" } }
    },
}

local function getMeleeById(id)
    for _, m in ipairs(MELEE) do
        if m.id == id or m.name == id then return m end
    end
    return MELEE[1]
end

local alive_script = true
local conns = {}
local function track(c) conns[#conns + 1] = c return c end

------------------------------------------------------------------ status
local statusLabel, titleLabel, footerStatusLabel, isMini
local function setStatus(s)
    if statusLabel then statusLabel.Text = s end
    if footerStatusLabel then footerStatusLabel.Text = s end
    if titleLabel then
        titleLabel.Text = isMini and ("BF: " .. s) or "Blox Fruits | Hub v7.1"
    end
end

------------------------------------------------------------------ shared state
local gui
local copyDebug, resetQuest, shutdownScript, hasRemote, buyMelee, refreshBossList
local buyResultLabel, autoMeleeTogglePaint, bossHeadLbl
local current
local curTargetModel
local priorityBossName = nil
local questItemBossName = nil
local questItemBossTag = nil
local questItemRunning = false
local questItemHoldLock = false
local saberV1Paint, saberV2Paint, swanGlassesPaint, wardenSwordPaint, poleV1Paint
local autoMeleeNeedsFarm = false
local masteryTargetTool = nil
local isBuyingNpc = false
local manualBuyActive = false
local isElectroQuestRunning = false
local electroQuestAccepted = false
local electroStateName = "IDLE"
local meleeBackoffSec = 3
local equipWeapon, triggerSwingFull
cupFilledFlag = false      -- v7.1: da goi FillCup thanh cong (server khong bao loi)
mobLeaderPatrolIdx = 1     -- v7.1: diem tuan tra Mob Leader

local function shouldKeepBuying()
    return isBuyingNpc and (CFG.AutoMelee or manualBuyActive)
end

local function safeGui()
    local ok, g = pcall(function() return gethui and gethui() end)
    if ok and g then return g end
    ok, g = pcall(function() return game:GetService("CoreGui") end)
    if ok and g then return g end
    return plr:WaitForChild("PlayerGui")
end

------------------------------------------------------------------ helpers & scanners (weak tables prevent memory leak)
local function enemiesFolder() return workspace:FindFirstChild("Enemies") end
local function charsFolder() return workspace:FindFirstChild("Characters") end
local function spawnsFolder()
    local wo = workspace:FindFirstChild("_WorldOrigin")
    return wo and wo:FindFirstChild("EnemySpawns")
end

local noDmgTrack = setmetatable({}, { __mode = "k" })
local noDmgBlacklist = setmetatable({}, { __mode = "k" })
local lastTargetVfx = setmetatable({}, { __mode = "k" })

local function isGhostOrImmuneName(name)
    if not name then return false end
    local low = string.lower(tostring(name))
    return string.find(low, "ghost", 1, true) ~= nil
        or string.find(low, "dummy", 1, true) ~= nil
        or string.find(low, "specter", 1, true) ~= nil
        or string.find(low, "hồn ma", 1, true) ~= nil
end

local function isIgnoredEnemy(e)
    if not e or not e.Parent then return true end
    local exp = noDmgBlacklist[e]
    if exp then
        if tick() < exp then
            return true
        else
            noDmgBlacklist[e] = nil
        end
    end
    if e:FindFirstChildOfClass("ForceField") then return true end
    if CFG.SkipGhost then
        if isGhostOrImmuneName(e.Name) then return true end
        local h = e:FindFirstChildOfClass("Humanoid")
        if h and isGhostOrImmuneName(h.DisplayName) then return true end
    end
    return false
end

local function markHitProgress(e)
    if not e or not e.Parent then return end
    local h = e:FindFirstChildOfClass("Humanoid")
    if not h or h.Health <= 0 then
        noDmgTrack[e] = nil
        return
    end
    local now = tick()
    local rec = noDmgTrack[e]
    if not rec then
        noDmgTrack[e] = { hp = h.Health, t0 = now }
    else
        if h.Health < rec.hp - 0.5 then
            rec.hp = h.Health
            rec.t0 = now
        elseif now - rec.t0 >= 2.5 then
            noDmgBlacklist[e] = now + 30
            noDmgTrack[e] = nil
        end
    end
end

local function aliveEnemy(e)
    if isIgnoredEnemy(e) then return false end
    local h, r = e:FindFirstChildOfClass("Humanoid"), e:FindFirstChild("HumanoidRootPart")
    return h and r and h.Health > 0
end

local function aliveTargetPlayer(charModel)
    if not charModel or charModel == plr.Character or not charModel.Parent then return false end
    if charModel:FindFirstChildOfClass("ForceField") then return false end
    local otherPlr = Players:GetPlayerFromCharacter(charModel)
    if not otherPlr then return false end
    if otherPlr.Team and plr.Team and otherPlr.Team == plr.Team and plr.Team.Name == "Marines" then
        return false
    end
    local h = charModel:FindFirstChildOfClass("Humanoid")
    local r = charModel:FindFirstChild("HumanoidRootPart")
    return h and r and h.Health > 0
end

local function isBossModel(e)
    local h = e:FindFirstChildOfClass("Humanoid")
    if not h then return false end
    if string.find(h.DisplayName, "%[Boss%]") or string.find(h.DisplayName, "%[Raid Boss%]") then
        return true
    end
    return h.MaxHealth >= 5000 and string.find(e.Name, "Boss") ~= nil
end

local function getServerBosses()
    local found, seen = {}, {}
    local function scan(folder)
        if not folder then return end
        for _, e in ipairs(folder:GetChildren()) do
            if e:IsA("Model") and not seen[e.Name] and aliveEnemy(e) and isBossModel(e) then
                seen[e.Name] = true
                found[#found + 1] = e.Name
            end
        end
    end
    scan(enemiesFolder())
    scan(RS)
    table.sort(found)
    return found
end

local function cleanMobName(rawName)
    return (tostring(rawName or ""):gsub("%s*%[Lv%..*$", "")):gsub("^%s*(.-)%s*$", "%1")
end

local function matchMobName(rawName, mob)
    if not rawName or not mob then return false end
    return string.lower(cleanMobName(rawName)) == string.lower(cleanMobName(mob))
end

local function hasAliveBoss(name)
    if not name or name == "" then return false end
    local ef = enemiesFolder()
    if ef then
        for _, e in ipairs(ef:GetChildren()) do
            if matchMobName(e.Name, name) and aliveEnemy(e) then return true end
        end
    end
    for _, e in ipairs(RS:GetChildren()) do
        if matchMobName(e.Name, name) and aliveEnemy(e) then return true end
    end
    return false
end

local function isHoldingQuestTool()
    local ch = plr.Character
    if not ch then return false end
    local t = ch:FindFirstChildOfClass("Tool")
    if not t then return false end
    local low = string.lower(t.Name)
    return low == "torch" or low == "cup" or low == "relic"
end

-- Fix xung dot: isElectroQuestRunning KHONG bat isFarmActive nua
local function isFarmActive()
    if isBuyingNpc or questItemRunning or questItemHoldLock or isElectroQuestRunning then return false end
    if questItemBossName and hasAliveBoss(questItemBossName) then return true end
    if CFG.AutoBoss and CFG.SelectedBoss ~= "" and hasAliveBoss(CFG.SelectedBoss) then return true end
    if CFG.AutoMelee and autoMeleeNeedsFarm then return true end
    if CFG.Enabled then return true end
    return false
end

------------------------------------------------------------------ UI (Multi-Tab Panel, NO Sliders, Stepper -/+ Controls)
local function buildUI()
    do
        local host = safeGui()
        local old = host and host:FindFirstChild("BF_AutoFarm")
        if old then pcall(function() old:Destroy() end) end
    end

    local THEME = {
        bg = Color3.fromRGB(16, 18, 24),
        topbar = Color3.fromRGB(24, 27, 36),
        sidebar = Color3.fromRGB(20, 23, 31),
        card = Color3.fromRGB(28, 32, 44),
        cardDark = Color3.fromRGB(22, 25, 34),
        stroke = Color3.fromRGB(48, 55, 74),
        accent = Color3.fromRGB(72, 160, 255),
        accentOn = Color3.fromRGB(44, 182, 112),
        accentOff = Color3.fromRGB(64, 70, 88),
        tabActive = Color3.fromRGB(40, 56, 86),
        tabIdle = Color3.fromRGB(25, 29, 39),
        danger = Color3.fromRGB(185, 58, 66),
        text = Color3.fromRGB(238, 242, 250),
        subtext = Color3.fromRGB(148, 158, 180),
        warn = Color3.fromRGB(255, 214, 120),
    }

    local function addCorner(obj, r)
        local c = Instance.new("UICorner")
        c.CornerRadius = UDim.new(0, r or 7)
        c.Parent = obj
        return c
    end

    local function addStroke(obj, color, thick)
        local s = Instance.new("UIStroke")
        s.Color = color or THEME.stroke
        s.Thickness = thick or 1
        s.ApplyStrokeMode = Enum.ApplyStrokeMode.Border
        s.Parent = obj
        return s
    end

    gui = Instance.new("ScreenGui")
    gui.Name = "BF_AutoFarm"
    gui.ResetOnSpawn = false
    gui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
    gui.Parent = safeGui()

    local FULL_W, FULL_H = 420, 320
    local frame = Instance.new("Frame")
    frame.Name = "MainWindow"
    frame.Size = UDim2.fromOffset(FULL_W, FULL_H)
    frame.Position = UDim2.new(0, 14, 0.1, 0)
    frame.BackgroundColor3 = THEME.bg
    frame.BorderSizePixel = 0
    frame.Active = true
    frame.ClipsDescendants = true
    frame.Parent = gui
    addCorner(frame, 11)
    addStroke(frame, THEME.stroke, 1.2)

    local bar = Instance.new("Frame")
    bar.Name = "TopBar"
    bar.Size = UDim2.new(1, 0, 0, 34)
    bar.BackgroundColor3 = THEME.topbar
    bar.BorderSizePixel = 0
    bar.Active = true
    bar.Parent = frame
    addCorner(bar, 11)

    local barMask = Instance.new("Frame")
    barMask.Size = UDim2.new(1, 0, 0, 11)
    barMask.Position = UDim2.new(0, 0, 1, -11)
    barMask.BackgroundColor3 = THEME.topbar
    barMask.BorderSizePixel = 0
    barMask.Parent = bar

    local dot = Instance.new("Frame")
    dot.Size = UDim2.fromOffset(8, 8)
    dot.Position = UDim2.new(0, 11, 0.5, -4)
    dot.BackgroundColor3 = THEME.accent
    dot.BorderSizePixel = 0
    dot.Parent = bar
    addCorner(dot, 4)

    local title = Instance.new("TextLabel")
    title.Size = UDim2.new(1, -92, 1, 0)
    title.Position = UDim2.new(0, 25, 0, 0)
    title.BackgroundTransparency = 1
    title.Text = "Blox Fruits | Hub v7.1"
    title.TextXAlignment = Enum.TextXAlignment.Left
    title.TextColor3 = THEME.text
    title.Font = Enum.Font.GothamBold
    title.TextSize = 13
    title.TextTruncate = Enum.TextTruncate.AtEnd
    title.Parent = bar
    titleLabel = title

    local dragging, dragInput, dragStart, startPos = false, nil, nil, nil
    bar.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
            dragging = true
            dragStart = input.Position
            startPos = frame.Position
            input.Changed:Connect(function()
                if input.UserInputState == Enum.UserInputState.End then
                    dragging = false
                end
            end)
        end
    end)
    bar.InputChanged:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch then
            dragInput = input
        end
    end)
    track(UserInputService.InputChanged:Connect(function(input)
        if dragging and input == dragInput and dragStart and startPos then
            local delta = input.Position - dragStart
            frame.Position = UDim2.new(startPos.X.Scale, startPos.X.Offset + delta.X, startPos.Y.Scale, startPos.Y.Offset + delta.Y)
        end
    end))

    local function topButton(text, xOffset, bgColor, cb)
        local b = Instance.new("TextButton")
        b.Size = UDim2.fromOffset(26, 22)
        b.Position = UDim2.new(1, xOffset, 0.5, -11)
        b.BackgroundColor3 = bgColor or Color3.fromRGB(46, 50, 66)
        b.TextColor3 = Color3.new(1, 1, 1)
        b.Font = Enum.Font.GothamBold
        b.TextSize = 14
        b.Text = text
        b.BorderSizePixel = 0
        b.Parent = bar
        addCorner(b, 6)
        b.Activated:Connect(function() cb(b) end)
        return b
    end

    local contentWrap = Instance.new("Frame")
    contentWrap.Size = UDim2.new(1, 0, 1, -34)
    contentWrap.Position = UDim2.new(0, 0, 0, 34)
    contentWrap.BackgroundTransparency = 1
    contentWrap.Parent = frame

    local SIDE_W = 92
    local sidebar = Instance.new("Frame")
    sidebar.Size = UDim2.new(0, SIDE_W, 1, -26)
    sidebar.Position = UDim2.new(0, 0, 0, 0)
    sidebar.BackgroundColor3 = THEME.sidebar
    sidebar.BorderSizePixel = 0
    sidebar.Parent = contentWrap

    local sideList = Instance.new("UIListLayout", sidebar)
    sideList.Padding = UDim.new(0, 5)
    sideList.SortOrder = Enum.SortOrder.LayoutOrder

    local sidePad = Instance.new("UIPadding", sidebar)
    sidePad.PaddingTop = UDim.new(0, 7)
    sidePad.PaddingBottom = UDim.new(0, 7)
    sidePad.PaddingLeft = UDim.new(0, 6)
    sidePad.PaddingRight = UDim.new(0, 6)

    local vLine = Instance.new("Frame")
    vLine.Size = UDim2.new(0, 1, 1, -26)
    vLine.Position = UDim2.new(0, SIDE_W, 0, 0)
    vLine.BackgroundColor3 = THEME.stroke
    vLine.BorderSizePixel = 0
    vLine.Parent = contentWrap

    local pageHost = Instance.new("Frame")
    pageHost.Size = UDim2.new(1, -(SIDE_W + 1), 1, -26)
    pageHost.Position = UDim2.new(0, SIDE_W + 1, 0, 0)
    pageHost.BackgroundTransparency = 1
    pageHost.Parent = contentWrap

    local footer = Instance.new("Frame")
    footer.Size = UDim2.new(1, 0, 0, 26)
    footer.Position = UDim2.new(0, 0, 1, -26)
    footer.BackgroundColor3 = THEME.topbar
    footer.BorderSizePixel = 0
    footer.Parent = contentWrap

    local fLine = Instance.new("Frame")
    fLine.Size = UDim2.new(1, 0, 0, 1)
    fLine.BackgroundColor3 = THEME.stroke
    fLine.BorderSizePixel = 0
    fLine.Parent = footer

    footerStatusLabel = Instance.new("TextLabel")
    footerStatusLabel.Size = UDim2.new(1, -16, 1, -2)
    footerStatusLabel.Position = UDim2.new(0, 8, 0, 1)
    footerStatusLabel.BackgroundTransparency = 1
    footerStatusLabel.Text = "san sang"
    footerStatusLabel.TextXAlignment = Enum.TextXAlignment.Left
    footerStatusLabel.TextColor3 = THEME.warn
    footerStatusLabel.Font = Enum.Font.Gotham
    footerStatusLabel.TextSize = 11
    footerStatusLabel.TextTruncate = Enum.TextTruncate.AtEnd
    footerStatusLabel.Parent = footer

    local minimized = false
    topButton("-", -62, Color3.fromRGB(46, 50, 66), function(b)
        minimized = not minimized
        isMini = minimized
        titleLabel.Text = minimized and ("BF: " .. (footerStatusLabel and footerStatusLabel.Text or "")) or "Blox Fruits | Hub v7.1"
        contentWrap.Visible = not minimized
        b.Text = minimized and "+" or "-"
        TweenService:Create(frame, TweenInfo.new(0.16, Enum.EasingStyle.Quad), {
            Size = minimized and UDim2.fromOffset(FULL_W, 34) or UDim2.fromOffset(FULL_W, FULL_H)
        }):Play()
    end)

    topButton("X", -31, THEME.danger, function()
        if shutdownScript then shutdownScript() end
    end)

    local tabs = {}
    local tabCount = 0
    local function selectTab(tabId)
        for _, tb in ipairs(tabs) do
            local active = (tb.id == tabId)
            tb.page.Visible = active
            tb.btn.BackgroundColor3 = active and THEME.tabActive or THEME.tabIdle
            tb.btn.TextColor3 = active and THEME.accent or THEME.subtext
            tb.bar.Visible = active
        end
    end

    local function createTab(id, tabName)
        tabCount = tabCount + 1

        local btn = Instance.new("TextButton")
        btn.Size = UDim2.new(1, 0, 0, 32)
        btn.BackgroundColor3 = THEME.tabIdle
        btn.BorderSizePixel = 0
        btn.Text = tabName
        btn.TextColor3 = THEME.subtext
        btn.Font = Enum.Font.GothamBold
        btn.TextSize = 11
        btn.LayoutOrder = tabCount
        btn.Parent = sidebar
        addCorner(btn, 7)

        local activeBar = Instance.new("Frame")
        activeBar.Size = UDim2.new(0, 3, 0, 18)
        activeBar.Position = UDim2.new(0, 0, 0.5, -9)
        activeBar.BackgroundColor3 = THEME.accent
        activeBar.BorderSizePixel = 0
        activeBar.Visible = false
        activeBar.Parent = btn
        addCorner(activeBar, 2)

        local page = Instance.new("ScrollingFrame")
        page.Name = "Tab_" .. id
        page.Size = UDim2.new(1, 0, 1, 0)
        page.BackgroundTransparency = 1
        page.BorderSizePixel = 0
        page.ScrollBarThickness = 3
        page.ScrollBarImageColor3 = THEME.accent
        page.CanvasSize = UDim2.new(0, 0, 0, 0)
        page.AutomaticCanvasSize = Enum.AutomaticSize.Y
        page.Visible = false
        page.Parent = pageHost

        local pl = Instance.new("UIListLayout", page)
        pl.Padding = UDim.new(0, 5)
        pl.SortOrder = Enum.SortOrder.LayoutOrder

        local pp = Instance.new("UIPadding", page)
        pp.PaddingTop = UDim.new(0, 7)
        pp.PaddingBottom = UDim.new(0, 10)
        pp.PaddingLeft = UDim.new(0, 8)
        pp.PaddingRight = UDim.new(0, 10)

        btn.Activated:Connect(function()
            selectTab(id)
        end)

        tabs[#tabs + 1] = { id = id, btn = btn, bar = activeBar, page = page }

        local itemOrder = 0
        local function nextOrder()
            itemOrder = itemOrder + 1
            return itemOrder
        end

        local api = { Page = page }

        function api:AddSection(secText)
            local lbl = Instance.new("TextLabel")
            lbl.Size = UDim2.new(1, 0, 0, 18)
            lbl.BackgroundTransparency = 1
            lbl.Text = string.upper(secText)
            lbl.TextXAlignment = Enum.TextXAlignment.Left
            lbl.TextColor3 = THEME.accent
            lbl.Font = Enum.Font.GothamBold
            lbl.TextSize = 10
            lbl.LayoutOrder = nextOrder()
            lbl.Parent = page
            return lbl
        end

        function api:AddToggle(text, key, onChange)
            local row = Instance.new("Frame")
            row.Size = UDim2.new(1, 0, 0, 30)
            row.BackgroundColor3 = THEME.card
            row.BorderSizePixel = 0
            row.LayoutOrder = nextOrder()
            row.Parent = page
            addCorner(row, 7)

            local lbl = Instance.new("TextLabel")
            lbl.Size = UDim2.new(1, -60, 1, 0)
            lbl.Position = UDim2.new(0, 9, 0, 0)
            lbl.BackgroundTransparency = 1
            lbl.Text = text
            lbl.TextXAlignment = Enum.TextXAlignment.Left
            lbl.TextColor3 = THEME.text
            lbl.Font = Enum.Font.Gotham
            lbl.TextSize = 11
            lbl.TextTruncate = Enum.TextTruncate.AtEnd
            lbl.Parent = row

            local trackBtn = Instance.new("TextButton")
            trackBtn.Size = UDim2.fromOffset(42, 20)
            trackBtn.Position = UDim2.new(1, -48, 0.5, -10)
            trackBtn.BorderSizePixel = 0
            trackBtn.Text = ""
            trackBtn.AutoButtonColor = false
            trackBtn.Parent = row
            addCorner(trackBtn, 10)

            local knob = Instance.new("Frame")
            knob.Size = UDim2.fromOffset(14, 14)
            knob.BackgroundColor3 = Color3.new(1, 1, 1)
            knob.BorderSizePixel = 0
            knob.Parent = trackBtn
            addCorner(knob, 7)

            local function paint(animate)
                local on = CFG[key]
                local targetBg = on and THEME.accentOn or THEME.accentOff
                local targetPos = on and UDim2.new(1, -17, 0.5, -7) or UDim2.new(0, 3, 0.5, -7)
                if animate then
                    TweenService:Create(trackBtn, TweenInfo.new(0.12), { BackgroundColor3 = targetBg }):Play()
                    TweenService:Create(knob, TweenInfo.new(0.12, Enum.EasingStyle.Quad), { Position = targetPos }):Play()
                else
                    trackBtn.BackgroundColor3 = targetBg
                    knob.Position = targetPos
                end
            end
            paint(false)

            trackBtn.Activated:Connect(function()
                CFG[key] = not CFG[key]
                paint(true)
                if onChange then onChange(CFG[key]) end
            end)
            return function() paint(true) end
        end

        function api:AddStepper(text, key, mn, mx, step, fmt)
            local row = Instance.new("Frame")
            row.Size = UDim2.new(1, 0, 0, 32)
            row.BackgroundColor3 = THEME.card
            row.BorderSizePixel = 0
            row.LayoutOrder = nextOrder()
            row.Parent = page
            addCorner(row, 7)

            local lbl = Instance.new("TextLabel")
            lbl.Size = UDim2.new(1, -124, 1, 0)
            lbl.Position = UDim2.new(0, 9, 0, 0)
            lbl.BackgroundTransparency = 1
            lbl.Text = text
            lbl.TextXAlignment = Enum.TextXAlignment.Left
            lbl.TextColor3 = THEME.text
            lbl.Font = Enum.Font.Gotham
            lbl.TextSize = 11
            lbl.TextTruncate = Enum.TextTruncate.AtEnd
            lbl.Parent = row

            local valLbl = Instance.new("TextLabel")
            valLbl.Size = UDim2.fromOffset(48, 22)
            valLbl.Position = UDim2.new(1, -82, 0.5, -11)
            valLbl.BackgroundColor3 = THEME.cardDark
            valLbl.BorderSizePixel = 0
            valLbl.TextColor3 = THEME.accent
            valLbl.Font = Enum.Font.GothamBold
            valLbl.TextSize = 11
            valLbl.Parent = row
            addCorner(valLbl, 5)

            local function paint()
                valLbl.Text = string.format(fmt or "%d", CFG[key])
            end
            paint()

            local function mkBtn(sym, xPos, delta)
                local b = Instance.new("TextButton")
                b.Size = UDim2.fromOffset(26, 22)
                b.Position = UDim2.new(1, xPos, 0.5, -11)
                b.BackgroundColor3 = Color3.fromRGB(52, 60, 82)
                b.BorderSizePixel = 0
                b.Text = sym
                b.TextColor3 = Color3.new(1, 1, 1)
                b.Font = Enum.Font.GothamBold
                b.TextSize = 14
                b.Parent = row
                addCorner(b, 5)
                b.Activated:Connect(function()
                    local v = math.clamp(CFG[key] + delta * step, mn, mx)
                    CFG[key] = math.floor(v * 100 + 0.5) / 100
                    paint()
                end)
            end
            mkBtn("-", -112, -1)
            mkBtn("+", -30, 1)
        end

        function api:AddButtonRow(buttonsSpec)
            local row = Instance.new("Frame")
            row.Size = UDim2.new(1, 0, 0, 30)
            row.BackgroundTransparency = 1
            row.LayoutOrder = nextOrder()
            row.Parent = page

            local n = #buttonsSpec
            for i, spec in ipairs(buttonsSpec) do
                local b = Instance.new("TextButton")
                local w = 1 / n
                b.Size = UDim2.new(w, i < n and -3 or 0, 1, 0)
                b.Position = UDim2.new((i - 1) * w, i > 1 and 3 or 0, 0, 0)
                b.BackgroundColor3 = spec.color or Color3.fromRGB(54, 62, 84)
                b.BorderSizePixel = 0
                b.Text = spec.text
                b.TextColor3 = Color3.new(1, 1, 1)
                b.Font = Enum.Font.GothamBold
                b.TextSize = 11
                b.Parent = row
                addCorner(b, 7)
                b.Activated:Connect(function()
                    if spec.cb then spec.cb(b) end
                end)
            end
        end

        function api:AddRow(h)
            local f = Instance.new("Frame")
            f.Size = UDim2.new(1, 0, 0, h or 30)
            f.BackgroundColor3 = THEME.card
            f.BorderSizePixel = 0
            f.LayoutOrder = nextOrder()
            f.Parent = page
            addCorner(f, 7)
            return f
        end

        function api:NextOrder()
            return nextOrder()
        end

        return api
    end

    ------------------------------------------------------------------ TAB 1: FARM & COMBAT
    local tabFarm = createTab("Farm", "Farm")
    tabFarm:AddSection("Tu dong cay cap")
    tabFarm:AddToggle("Auto Farm (Quest + Gom Quai)", "Enabled", function(on)
        if not on then setStatus("tam dung Auto Farm") end
    end)
    tabFarm:AddToggle("Gom Cum Quai Dong Nhat", "SmartCluster")
    tabFarm:AddToggle("Auto Buso Haki (Tang Dam/Logia)", "AutoBuso")
    tabFarm:AddToggle("Auto Skill Z/X khi gom quai", "AutoSkillZX")
    tabFarm:AddToggle("Quest Boss", "Boss")

    do
        local f = tabFarm:AddRow(30)
        local lbl = Instance.new("TextLabel")
        lbl.Size = UDim2.new(1, -112, 1, 0)
        lbl.Position = UDim2.new(0, 9, 0, 0)
        lbl.BackgroundTransparency = 1
        lbl.Text = "Vu khi farm (Weapon)"
        lbl.TextXAlignment = Enum.TextXAlignment.Left
        lbl.TextColor3 = THEME.text
        lbl.Font = Enum.Font.Gotham
        lbl.TextSize = 11
        lbl.Parent = f

        local weapons = { "Melee", "Sword", "Gun", "Blox Fruit" }
        local wi = 1
        local b = Instance.new("TextButton")
        b.Size = UDim2.fromOffset(98, 22)
        b.Position = UDim2.new(1, -104, 0.5, -11)
        b.BackgroundColor3 = Color3.fromRGB(54, 62, 86)
        b.BorderSizePixel = 0
        b.Text = CFG.Weapon
        b.TextColor3 = Color3.new(1, 1, 1)
        b.Font = Enum.Font.GothamBold
        b.TextSize = 11
        b.Parent = f
        addCorner(b, 6)
        b.Activated:Connect(function()
            wi = wi % #weapons + 1
            CFG.Weapon = weapons[wi]
            b.Text = CFG.Weapon
        end)
    end

    tabFarm:AddSection("Chien dau & Kill Aura")
    tabFarm:AddToggle("Kill Aura (Danh trong Hit Range)", "KillAura", function(on)
        setStatus(on and ("Bat Kill Aura (tam " .. tostring(CFG.HitRange) .. "m)") or "Da tat Kill Aura")
    end)
    tabFarm:AddToggle("Kill Aura Danh Ca Nguoi Choi (PvP)", "KillAuraPlayers")
    tabFarm:AddToggle("Instant Attack (Fast Hit)", "InstantHit")
    tabFarm:AddToggle("Multi Attack (Danh Da Muc Tieu)", "MultiAttack")
    tabFarm:AddToggle("Animation Danh M1 (Khong Gia Click)", "M1Effect")
    tabFarm:AddToggle("Hieu Ung Trung Don (Hit VFX)", "HitVFX")
    tabFarm:AddToggle("Bo Qua NPC Ghost / 0 Dam", "SkipGhost")
    tabFarm:AddToggle("Click Man Hinh (Tuy Chon)", "ScreenClick")

    ------------------------------------------------------------------ TAB 2: MELEE
    local tabMelee = createTab("Melee", "Melee")
    tabMelee:AddSection("Auto Lay Vo (Full Req + Mua)")
    autoMeleeTogglePaint = tabMelee:AddToggle("Auto Lay Melee", "AutoMelee", function(on)
        if on then
            CFG.Weapon = "Melee"
            setStatus("Bat Auto Lay Melee: " .. CFG.SelectedMelee)
        else
            priorityBossName = nil
            autoMeleeNeedsFarm = false
            masteryTargetTool = nil
            isBuyingNpc = false
            manualBuyActive = false
            isElectroQuestRunning = false
            electroQuestAccepted = false
            electroStateName = "IDLE"
            meleeBackoffSec = 3
            setStatus("Da tat Auto Lay Melee (dung ngay)")
        end
    end)

    do
        local infoBox = tabMelee:AddRow(40)
        infoBox.AutomaticSize = Enum.AutomaticSize.Y
        local rl = Instance.new("TextLabel")
        rl.Size = UDim2.new(1, -14, 0, 0)
        rl.Position = UDim2.new(0, 7, 0, 5)
        rl.AutomaticSize = Enum.AutomaticSize.Y
        rl.BackgroundTransparency = 1
        rl.TextWrapped = true
        rl.TextXAlignment = Enum.TextXAlignment.Left
        rl.TextYAlignment = Enum.TextYAlignment.Top
        rl.TextColor3 = THEME.warn
        rl.Font = Enum.Font.Gotham
        rl.TextSize = 11
        rl.Text = "Dang chon: " .. CFG.SelectedMelee .. " | Bat Auto Lay Melee hoac bam Mua ngay."
        rl.Parent = infoBox
        buyResultLabel = rl

        tabMelee:AddSection("Danh sach he vo")
        local btns = {}
        local function refreshColors()
            for id, b in pairs(btns) do
                b.BackgroundColor3 = (id == CFG.SelectedMelee) and THEME.accentOn or Color3.fromRGB(40, 46, 64)
            end
        end

        for _, m in ipairs(MELEE) do
            local rowF = Instance.new("Frame")
            rowF.Size = UDim2.new(1, 0, 0, 26)
            rowF.BackgroundTransparency = 1
            rowF.LayoutOrder = tabMelee:NextOrder()
            rowF.Parent = tabMelee.Page

            local selBtn = Instance.new("TextButton")
            selBtn.Size = UDim2.new(1, -64, 1, 0)
            selBtn.BackgroundColor3 = (m.id == CFG.SelectedMelee) and THEME.accentOn or Color3.fromRGB(40, 46, 64)
            selBtn.BorderSizePixel = 0
            selBtn.Text = m.name
            selBtn.TextColor3 = Color3.new(1, 1, 1)
            selBtn.Font = Enum.Font.Gotham
            selBtn.TextSize = 11
            selBtn.Parent = rowF
            addCorner(selBtn, 6)
            btns[m.id] = selBtn

            selBtn.Activated:Connect(function()
                CFG.SelectedMelee = m.id
                electroQuestAccepted = false
                electroStateName = "IDLE"
                meleeBackoffSec = 3
                refreshColors()
                if buyResultLabel then buyResultLabel.Text = "Da chon: " .. m.name end
            end)

            local buyBtn = Instance.new("TextButton")
            buyBtn.Size = UDim2.fromOffset(60, 26)
            buyBtn.Position = UDim2.new(1, -60, 0, 0)
            buyBtn.BackgroundColor3 = Color3.fromRGB(64, 96, 158)
            buyBtn.BorderSizePixel = 0
            buyBtn.Text = "Mua ngay"
            buyBtn.TextColor3 = Color3.new(1, 1, 1)
            buyBtn.Font = Enum.Font.GothamBold
            buyBtn.TextSize = 11
            buyBtn.Parent = rowF
            addCorner(buyBtn, 6)
            buyBtn.Activated:Connect(function()
                if buyMelee then buyMelee(m) end
            end)
        end
    end

    ------------------------------------------------------------------ TAB 3: QUEST & ITEM
    local tabQuest = createTab("Quest", "Quest")
    tabQuest:AddSection("Nhiem vu & Vat pham")
    local function disableOtherQuestItems(keepKey)
        local map = {
            { k = "AutoSaberV1",     p = function() if saberV1Paint then saberV1Paint() end end },
            { k = "AutoSaberV2",     p = function() if saberV2Paint then saberV2Paint() end end },
            { k = "AutoSwanGlasses", p = function() if swanGlassesPaint then swanGlassesPaint() end end },
            { k = "AutoWardenSword", p = function() if wardenSwordPaint then wardenSwordPaint() end end },
            { k = "AutoPoleV1",      p = function() if poleV1Paint then poleV1Paint() end end },
        }
        for _, item in ipairs(map) do
            if item.k ~= keepKey and CFG[item.k] then
                CFG[item.k] = false
                item.p()
            end
        end
        questItemBossName, questItemBossTag = nil, nil
    end

    saberV1Paint = tabQuest:AddToggle("Auto Saber v1 (Full Puzzle + Boss)", "AutoSaberV1", function(on)
        if on then
            disableOtherQuestItems("AutoSaberV1")
            questItemHoldLock = true
            cupFilledFlag = false
            mobLeaderPatrolIdx = 1
            setStatus("Bat Auto Saber v1 (khoa doc quyen tranh xung dot)")
        else
            questItemHoldLock = false
            questItemRunning = false
            if questItemBossTag == "Auto Saber v1" then questItemBossName, questItemBossTag = nil, nil end
            setStatus("Da tat Auto Saber v1")
        end
    end)
    saberV2Paint = tabQuest:AddToggle("Auto Saber v2 (Farm 1M Bounty)", "AutoSaberV2", function(on)
        if on then
            disableOtherQuestItems("AutoSaberV2")
            questItemHoldLock = false
            setStatus("Bat Auto Saber v2 (Farm 1M Bounty + Check)")
        else
            questItemHoldLock = false
            questItemRunning = false
            if questItemBossTag == "Auto Saber v2" then questItemBossName, questItemBossTag = nil, nil end
            setStatus("Da tat Auto Saber v2")
        end
    end)
    swanGlassesPaint = tabQuest:AddToggle("Auto Lay Kinh Don Swan (Sea 2)", "AutoSwanGlasses", function(on)
        if on then
            disableOtherQuestItems("AutoSwanGlasses")
            questItemHoldLock = false
            setStatus("Bat Auto Lay Kinh Don Swan (Sea 2)")
        else
            questItemHoldLock = false
            questItemRunning = false
            if questItemBossTag == "Auto Kinh Don Swan" then questItemBossName, questItemBossTag = nil, nil end
            setStatus("Da tat Auto Lay Kinh Don Swan")
        end
    end)
    wardenSwordPaint = tabQuest:AddToggle("Auto Lay Kiem Wander (Warden)", "AutoWardenSword", function(on)
        if on then
            disableOtherQuestItems("AutoWardenSword")
            questItemHoldLock = false
            setStatus("Bat Auto Lay Kiem Warden (Sea 1)")
        else
            questItemHoldLock = false
            questItemRunning = false
            if questItemBossTag == "Auto Kiem Warden" then questItemBossName, questItemBossTag = nil, nil end
            setStatus("Da tat Auto Lay Kiem Warden")
        end
    end)
    poleV1Paint = tabQuest:AddToggle("Auto Lay Pole (Thunder God)", "AutoPoleV1", function(on)
        if on then
            disableOtherQuestItems("AutoPoleV1")
            questItemHoldLock = false
            setStatus("Bat Auto Lay Pole v1 (Sea 1)")
        else
            questItemHoldLock = false
            questItemRunning = false
            if questItemBossTag == "Auto Pole v1" then questItemBossName, questItemBossTag = nil, nil end
            setStatus("Da tat Auto Lay Pole v1")
        end
    end)

    ------------------------------------------------------------------ TAB 4: BOSS
    local tabBoss = createTab("Boss", "Boss")
    tabBoss:AddSection("San Boss Server")
    tabBoss:AddToggle("Auto Farm Boss (da chon)", "AutoBoss", function(on)
        if on then
            setStatus(CFG.SelectedBoss ~= "" and ("San Boss: " .. CFG.SelectedBoss) or "Chua chon Boss -> dung yen")
        else
            setStatus("Da tat Auto Farm Boss")
        end
    end)

    do
        local head = tabBoss:AddRow(30)
        bossHeadLbl = Instance.new("TextLabel")
        bossHeadLbl.Size = UDim2.new(1, -80, 1, 0)
        bossHeadLbl.Position = UDim2.new(0, 9, 0, 0)
        bossHeadLbl.BackgroundTransparency = 1
        bossHeadLbl.Text = "Boss: (chua chon)"
        bossHeadLbl.TextXAlignment = Enum.TextXAlignment.Left
        bossHeadLbl.TextColor3 = THEME.text
        bossHeadLbl.Font = Enum.Font.Gotham
        bossHeadLbl.TextSize = 11
        bossHeadLbl.TextTruncate = Enum.TextTruncate.AtEnd
        bossHeadLbl.Parent = head

        local refBtn = Instance.new("TextButton")
        refBtn.Size = UDim2.fromOffset(66, 22)
        refBtn.Position = UDim2.new(1, -72, 0.5, -11)
        refBtn.BackgroundColor3 = Color3.fromRGB(52, 114, 152)
        refBtn.BorderSizePixel = 0
        refBtn.Text = "Refresh"
        refBtn.TextColor3 = Color3.new(1, 1, 1)
        refBtn.Font = Enum.Font.GothamBold
        refBtn.TextSize = 11
        refBtn.Parent = head
        addCorner(refBtn, 6)

        local box = Instance.new("Frame")
        box.Size = UDim2.new(1, 0, 0, 0)
        box.AutomaticSize = Enum.AutomaticSize.Y
        box.BackgroundColor3 = THEME.cardDark
        box.BorderSizePixel = 0
        box.LayoutOrder = tabBoss:NextOrder()
        box.Parent = tabBoss.Page
        addCorner(box, 7)
        addStroke(box, THEME.stroke, 1)

        local bl = Instance.new("UIListLayout", box)
        bl.Padding = UDim.new(0, 4)
        bl.SortOrder = Enum.SortOrder.LayoutOrder
        local pad = Instance.new("UIPadding", box)
        pad.PaddingTop = UDim.new(0, 6)
        pad.PaddingBottom = UDim.new(0, 6)
        pad.PaddingLeft = UDim.new(0, 6)
        pad.PaddingRight = UDim.new(0, 6)

        refreshBossList = function()
            for _, c in ipairs(box:GetChildren()) do
                if c:IsA("TextButton") or c:IsA("TextLabel") then c:Destroy() end
            end
            local bosses = getServerBosses()
            if #bosses == 0 then
                local empty = Instance.new("TextLabel")
                empty.Size = UDim2.new(1, 0, 0, 22)
                empty.BackgroundTransparency = 1
                empty.Text = "Khong co Boss nao dang song trong server"
                empty.TextColor3 = THEME.subtext
                empty.Font = Enum.Font.Gotham
                empty.TextSize = 11
                empty.Parent = box
                return
            end
            for i, bName in ipairs(bosses) do
                local b = Instance.new("TextButton")
                b.Size = UDim2.new(1, 0, 0, 26)
                b.BackgroundColor3 = (CFG.SelectedBoss == bName) and THEME.accentOn or Color3.fromRGB(46, 52, 70)
                b.BorderSizePixel = 0
                b.Text = bName
                b.TextColor3 = Color3.new(1, 1, 1)
                b.Font = Enum.Font.Gotham
                b.TextSize = 11
                b.LayoutOrder = i
                b.Parent = box
                addCorner(b, 6)
                b.Activated:Connect(function()
                    CFG.SelectedBoss = bName
                    bossHeadLbl.Text = "Boss: " .. bName
                    refreshBossList()
                end)
            end
        end

        refBtn.Activated:Connect(function()
            refreshBossList()
        end)
        refreshBossList()
    end

    ------------------------------------------------------------------ TAB 5: STATS
    local tabStats = createTab("Stats", "Stats")
    tabStats:AddSection("Tu dong cong diem chi so")
    tabStats:AddToggle("Auto Stats", "AutoStats", function(on)
        setStatus(on and "Bat Auto Stats" or "Da tat Auto Stats")
    end)
    tabStats:AddToggle("Cong Melee", "StatMelee")
    tabStats:AddToggle("Cong Defense", "StatDefense")
    tabStats:AddToggle("Cong Sword", "StatSword")
    tabStats:AddToggle("Cong Gun", "StatGun")
    tabStats:AddToggle("Cong Blox Fruit", "StatFruit")
    tabStats:AddStepper("Diem / lan cong", "StatAmount", 1, 15, 1, "%d")

    ------------------------------------------------------------------ TAB 6: CONFIG & DEBUG
    local tabCfg = createTab("Config", "Config")
    tabCfg:AddSection("Thong so di chuyen & danh (- / +)")
    tabCfg:AddStepper("Float Height (Instant)", "FarHeight", 8, 45, 2, "%d")
    tabCfg:AddStepper("Float Height (Thuong)", "FlyHeight", 8, 30, 1, "%d")
    tabCfg:AddStepper("Bring Radius (x2 logic)", "BringRadius", 50, 500, 25, "%d")
    tabCfg:AddStepper("Move Speed", "TweenSpeed", 100, 350, 15, "%d")
    tabCfg:AddStepper("Hit Range", "HitRange", 30, 80, 5, "%d")
    tabCfg:AddStepper("Hits / Tick", "HitBurst", 1, 5, 1, "%d")
    tabCfg:AddStepper("Hit Delay", "AttackDelay", 0.01, 0.25, 0.01, "%.2f")

    tabCfg:AddSection("Cong cu & Trang thai")
    tabCfg:AddButtonRow({
        { text = "Copy Debug", color = Color3.fromRGB(56, 94, 168), cb = function() if copyDebug then copyDebug() end end },
        { text = "Reset Quest", color = Color3.fromRGB(132, 86, 52), cb = function() if resetQuest then resetQuest() end end },
    })
    tabCfg:AddButtonRow({
        { text = "Scan Data (NPC/Object)", color = Color3.fromRGB(44, 130, 110), cb = function() if copyScan then copyScan() end end },
    })
    tabCfg:AddButtonRow({
        { text = "FULL SCAN Sea (bay + luu file)", color = Color3.fromRGB(150, 70, 140), cb = function() if copyFullScan then copyFullScan() end end },
    })

    local sf = tabCfg:AddRow(58)
    statusLabel = Instance.new("TextLabel")
    statusLabel.Size = UDim2.new(1, -14, 1, -8)
    statusLabel.Position = UDim2.new(0, 7, 0, 4)
    statusLabel.BackgroundTransparency = 1
    statusLabel.TextColor3 = THEME.subtext
    statusLabel.Font = Enum.Font.Gotham
    statusLabel.TextSize = 11
    statusLabel.TextWrapped = true
    statusLabel.TextXAlignment = Enum.TextXAlignment.Left
    statusLabel.TextYAlignment = Enum.TextYAlignment.Top
    statusLabel.Text = "san sang"
    statusLabel.Parent = sf

    selectTab("Farm")
end
local uiOk, uiErr = pcall(buildUI)
if not uiOk then warn("[BF] loi UI: " .. tostring(uiErr)) end

------------------------------------------------------------------ physics & tween
track(plr.Idled:Connect(function()
    pcall(function()
        VirtualUser:CaptureController()
        VirtualUser:ClickButton2(Vector2.new())
    end)
end))

local function hrp() return plr.Character and plr.Character:FindFirstChild("HumanoidRootPart") end
local function hum() return plr.Character and plr.Character:FindFirstChildOfClass("Humanoid") end
local function alive() local h = hum(); return h and h.Health > 0 and hrp() ~= nil end

local function getLevel()
    local ok, v = pcall(function() return plr.Data.Level.Value end)
    return ok and v or 1
end

local isFlying = false
local holder

local function setHold(on)
    local root = hrp()
    local h = hum()
    if on and root then
        if h then h.PlatformStand = true end
        if not holder or holder.Parent ~= root then
            holder = Instance.new("BodyVelocity")
            holder.Name = "BF_Hold"
            holder.MaxForce = Vector3.new(1e6, 1e6, 1e6)
            holder.Velocity = Vector3.zero
            holder.Parent = root
        end
    else
        if h then h.PlatformStand = false end
        if holder then
            holder:Destroy()
            holder = nil
        end
    end
end

track(RunService.Stepped:Connect(function()
    if (isFarmActive() or shouldKeepBuying() or questItemRunning or questItemHoldLock or isElectroQuestRunning) and alive() then
        local root = hrp()
        if root then
            root.AssemblyAngularVelocity = Vector3.zero
            if not isFlying then
                root.AssemblyLinearVelocity = Vector3.zero
            end
        end
        for _, p in ipairs(plr.Character:GetDescendants()) do
            if p:IsA("BasePart") then p.CanCollide = false end
        end
    end
end))

local activeTween
local function stopMoving()
    isFlying = false
    if activeTween then
        activeTween:Cancel()
        activeTween = nil
    end
end

local function tweenStep(cf, buyMode, interruptFn)
    local root = hrp()
    local function canRun()
        if not (alive_script and alive()) then return false end
        if interruptFn and interruptFn() then return false end
        return (buyMode and shouldKeepBuying()) or questItemRunning or isElectroQuestRunning or isFarmActive()
    end
    if not root or not canRun() then return false end
    local dist = (root.Position - cf.Position).Magnitude
    if dist < 4 then
        root.CFrame = cf
        return true
    end
    stopMoving()
    isFlying = true
    local speed = math.max(CFG.TweenSpeed, 60)
    local duration = math.max(0.05, dist / speed)
    local t = TweenService:Create(root, TweenInfo.new(duration, Enum.EasingStyle.Linear), { CFrame = cf })
    activeTween = t
    local done = false
    local conn
    conn = t.Completed:Connect(function()
        done = true
        if conn then conn:Disconnect() end
    end)
    t:Play()
    while not done and canRun() do
        if holder and holder.Parent == root then
            local dir = (cf.Position - root.Position)
            holder.Velocity = dir.Magnitude > 1 and (dir.Unit * speed) or Vector3.zero
        end
        task.wait(0.03)
    end
    isFlying = false
    if holder and holder.Parent == root then
        holder.Velocity = Vector3.zero
    end
    if not done then
        stopMoving()
        return false
    end
    return true
end

local function goTo(cf, buyMode, interruptFn)
    local root = hrp()
    if not root or not alive() then return false end
    local startPos = root.Position
    local endPos = cf.Position
    local dist = (startPos - endPos).Magnitude

    if dist > 450 then
        local safeY = math.max(startPos.Y, endPos.Y) + 75
        if not tweenStep(CFrame.new(startPos.X, safeY, startPos.Z), buyMode, interruptFn) then return false end
        if not tweenStep(CFrame.new(endPos.X, safeY, endPos.Z), buyMode, interruptFn) then return false end
    elseif dist > 110 then
        local midY = math.max(startPos.Y, endPos.Y) + 18
        if not tweenStep(CFrame.new(endPos.X, midY, endPos.Z), buyMode, interruptFn) then return false end
    end
    return tweenStep(cf, buyMode, interruptFn)
end

local function extractTargetCF(obj)
    if not obj then return nil end
    if obj:IsA("BasePart") then return obj.CFrame end
    if obj:IsA("Model") then
        local p = obj:FindFirstChild("HumanoidRootPart") or obj.PrimaryPart or obj:FindFirstChildWhichIsA("BasePart", true)
        if p then return p.CFrame end
    end
    return nil
end

local function findRealNpcInContainers(m)
    if not m or type(m.npcNames) ~= "table" then return nil, nil, false end

    local root = hrp()
    local origin = root and root.Position or Vector3.zero
    local npcFolder = workspace:FindFirstChild("NPCs")
    local scanRoot = npcFolder or workspace
    local wanted = {}
    for _, name in ipairs(m.npcNames) do
        wanted[name] = true
    end

    local bestCF, bestName, bestDistance
    for _, d in ipairs(scanRoot:GetDescendants()) do
        if d:IsA("Model") and wanted[d.Name] then
            local humanoid = d:FindFirstChildOfClass("Humanoid")
            local cf = extractTargetCF(d)
            if cf and cf.Position.Magnitude > 10 and (not humanoid or humanoid.Health > 0) then
                local distance = (cf.Position - origin).Magnitude
                if not bestDistance or distance < bestDistance then
                    bestCF, bestName, bestDistance = cf * CFrame.new(0, 0, 2.5), d.Name, distance
                end
            end
        end
    end
    if bestCF then return bestCF, bestName, true end
    return nil, nil, false
end

local function findMeleeNpcCF(m)
    local cf, name, live = findRealNpcInContainers(m)
    if cf then return cf, name, true end

    local rsNpcs = RS:FindFirstChild("NPCs")
    if rsNpcs and type(m.npcNames) == "table" then
        for _, nName in ipairs(m.npcNames) do
            local npc = rsNpcs:FindFirstChild(nName, true)
            local rcf = extractTargetCF(npc)
            if rcf and rcf.Position.Magnitude > 10 then
                return rcf * CFrame.new(0, 0, 2.5), npc.Name, false
            end
        end
    end

    local sea = getCurrentSea()
    if m.npcPos and m.npcPos[sea] then
        return m.npcPos[sea], (m.npcNames and m.npcNames[1] or m.name), false
    end

    return nil, nil, false
end

------------------------------------------------------------------ du lieu game
local Quests
do
    local ok, mod = pcall(function() return require(RS:WaitForChild("Quests", 15)) end)
    if ok and type(mod) == "table" then Quests = mod end
end

local function hasAliveMob(mob)
    local ef = enemiesFolder()
    if not ef then return false end
    for _, e in ipairs(ef:GetChildren()) do
        if matchMobName(e.Name, mob) and aliveEnemy(e) then return true end
    end
    return false
end

local function spawnPoints(mob)
    local out = {}
    local sf = spawnsFolder()
    if sf then
        for _, s in ipairs(sf:GetChildren()) do
            if matchMobName(s.Name, mob) then
                local cf = extractTargetCF(s)
                if cf then out[#out + 1] = cf end
            end
        end
    end
    local ef = enemiesFolder()
    if ef then
        for _, e in ipairs(ef:GetChildren()) do
            if matchMobName(e.Name, mob) and e:FindFirstChild("HumanoidRootPart") then
                out[#out + 1] = e.HumanoidRootPart.CFrame
            end
        end
    end
    for _, e in ipairs(RS:GetChildren()) do
        if e:IsA("Model") and matchMobName(e.Name, mob) and e:FindFirstChild("HumanoidRootPart") then
            out[#out + 1] = e.HumanoidRootPart.CFrame
        end
    end
    return out
end

local function getMobCamps(mob)
    local pts = spawnPoints(mob)
    local clusters = {}
    for _, cf in ipairs(pts) do
        local pos = cf.Position
        local placed = false
        for _, cl in ipairs(clusters) do
            if (cl.center - pos).Magnitude <= 75 then
                cl.sum = cl.sum + pos
                cl.count = cl.count + 1
                cl.center = cl.sum / cl.count
                placed = true
                break
            end
        end
        if not placed then
            clusters[#clusters + 1] = { sum = pos, count = 1, center = pos }
        end
    end
    table.sort(clusters, function(a, b)
        if math.abs(a.center.X - b.center.X) > 25 then
            return a.center.X < b.center.X
        end
        return a.center.Z < b.center.Z
    end)
    local camps = {}
    for _, cl in ipairs(clusters) do
        camps[#camps + 1] = CFrame.new(cl.center)
    end
    return camps
end

local function eachQuest(fn)
    if type(Quests) ~= "table" then return end
    for qname, v in pairs(Quests) do
        if type(v) == "table" then
            if v.Task or v.Tasks or v.Levels or v.LevelReq then
                fn(qname, nil, v)
            else
                for idx, q in pairs(v) do
                    if type(q) == "table" then fn(qname, idx, q) end
                end
            end
        end
    end
end

local function qLevel(q)
    local lv = q.LevelReq or q.Levels or q.Level or q.MinLevel or q.ReqLevel
    if type(lv) == "table" then lv = lv[1] end
    return type(lv) == "number" and lv or nil
end

local function questMob(q)
    local t = q.Task or q.Tasks
    if type(t) ~= "table" then return nil end
    local mob, count
    for m, c in pairs(t) do mob, count = m, c end
    return mob, count
end

local function teamAllows(qname)
    local team = plr.Team and plr.Team.Name or ""
    if qname == "MarineQuest" and string.find(team, "Pirate") then return false end
    if qname == "BanditQuest1" and string.find(team, "Marine") then return false end
    return true
end

local function pickQuest(level)
    local hasSpawns = spawnsFolder() ~= nil
    local best
    eachQuest(function(qname, idx, q)
        local lv = qLevel(q)
        if not lv or lv > level or not teamAllows(qname) then return end
        if best and lv <= best.level then return end
        local mob, count = questMob(q)
        if type(mob) ~= "string" or type(count) ~= "number" or count < 1 then return end
        if CFG.SkipGhost and isGhostOrImmuneName(mob) then return end
        local isBoss = (count == 1)
        if isBoss and not (CFG.Boss and hasAliveMob(mob)) then return end
        if hasSpawns and #spawnPoints(mob) == 0 then return end
        best = { name = qname, index = idx, level = lv, mob = mob, count = count, isBoss = isBoss }
    end)
    return best
end

local function isGuiActuallyVisible(inst)
    local cur = inst
    while cur do
        if cur == gui then return false end
        if cur:IsA("GuiObject") and not cur.Visible then return false end
        if cur:IsA("ScreenGui") and not cur.Enabled then return false end
        cur = cur.Parent
    end
    return true
end

local qCache, qCacheT, qText = false, 0, ""
local lastFullT, lastFullRes, lastFullTxt = 0, false, ""

local function isQuestText(txt)
    return string.find(txt, "Đánh bại", 1, true) ~= nil or string.find(txt, "Defeat", 1, true) ~= nil
end

local function scanQuestText(root)
    for _, d in ipairs(root:GetDescendants()) do
        if d:IsA("TextLabel") and d.Text ~= "" and isQuestText(d.Text) and isGuiActuallyVisible(d) then
            return true, d.Text
        end
    end
    return false, ""
end

local function computeQuest()
    local pg = plr:FindFirstChild("PlayerGui")
    if not pg then return false, "" end
    local tracked = pg:FindFirstChild("TrackedQuestFrame")
    if tracked then
        local a, t = scanQuestText(tracked)
        if a then return true, t end
    end
    local ok, legacy = pcall(function()
        local q = pg.Main.Quest
        return q and isGuiActuallyVisible(q)
    end)
    if ok and legacy then return true, "" end
    if not tracked then
        local now = tick()
        if now - lastFullT > 3 then
            lastFullT = now
            lastFullRes, lastFullTxt = scanQuestText(pg)
        end
        return lastFullRes, lastFullTxt
    end
    return false, ""
end

local function questActive(force)
    local now = tick()
    if force or now - qCacheT > 0.4 then
        qCacheT = now
        qCache, qText = computeQuest()
    end
    return qCache
end

local function questTextHas(mob)
    return qText ~= "" and string.find(string.lower(qText), string.lower(mob), 1, true) ~= nil
end

local goodRemote
local function getCommF()
    if goodRemote and goodRemote.Parent then return goodRemote end
    local remFolder = RS:FindFirstChild("Remotes")
    local r = remFolder and (remFolder:FindFirstChild("CommF_") or remFolder:FindFirstChild("CommonF_"))
    if r then
        goodRemote = r
        return r
    end
    return nil
end

local function fmtVal(v, depth)
    depth = depth or 0
    local tv = type(v)
    if tv == "table" then
        if depth >= 2 then return "{...}" end
        local parts, n = {}, 0
        for k, x in pairs(v) do
            n = n + 1
            if n > 18 then
                parts[#parts + 1] = "...+" .. tostring(n)
                break
            end
            parts[#parts + 1] = tostring(k) .. "=" .. fmtVal(x, depth + 1)
        end
        return "{" .. table.concat(parts, ", ") .. "}"
    elseif tv == "string" then
        return '"' .. v .. '"'
    end
    return tostring(v)
end

local function fmtArgsList(args)
    local parts = {}
    for i = 1, #args do
        parts[#parts + 1] = fmtVal(args[i], 1)
    end
    return table.concat(parts, ", ")
end

local commLog = {}
otherRemoteLog = {}
local scriptCallLog = {}

local function pushScriptLog(args, ret, elapsedMs)
    local first = tostring(args[1] or "")
    local retStr = (first == "getInventory" and type(ret) == "table") and ("<table:" .. tostring(#ret) .. ">") or fmtVal(ret, 0)
    local entry = string.format("[%s | %dms] (%s) => %s", os.date("%H:%M:%S"), math.floor(elapsedMs or 0), fmtArgsList(args), retStr)
    if first == "getInventory" and #scriptCallLog > 0 and string.find(scriptCallLog[#scriptCallLog], '"getInventory"', 1, true) then
        scriptCallLog[#scriptCallLog] = entry
        return
    end
    scriptCallLog[#scriptCallLog + 1] = entry
    if #scriptCallLog > 45 then table.remove(scriptCallLog, 1) end
end

-- Hook: log CommF_ (day du) + moi remote khac game goi (tru RegisterAttack/RegisterHit)
do
    local commRemote = getCommF()
    pcall(function()
        if not (hookmetamethod and getnamecallmethod) then return end
        local old
        local hook = function(self, ...)
            local m = getnamecallmethod()
            if (m == "InvokeServer" or m == "FireServer") and not (checkcaller and checkcaller()) then
                if commRemote and rawequal(self, commRemote) and m == "InvokeServer" then
                    local parts = {}
                    for i = 1, select("#", ...) do
                        local a = select(i, ...)
                        parts[#parts + 1] = type(a) == "string" and ('"' .. a .. '"') or tostring(a)
                    end
                    local callStr = table.concat(parts, ", ")
                    local r1, r2, r3 = old(self, ...)
                    local okFmt, retTxt = pcall(fmtVal, r1, 0)
                    local line = callStr .. " => " .. (okFmt and retTxt or tostring(r1))
                    if commLog[#commLog] ~= line then
                        commLog[#commLog + 1] = line
                        if #commLog > 40 then table.remove(commLog, 1) end
                    end
                    return r1, r2, r3
                elseif typeof(self) == "Instance" then
                    local nm = self.Name
                    if not string.find(nm, "Register", 1, true) then
                        local parts = {}
                        for i = 1, select("#", ...) do
                            parts[#parts + 1] = tostring((select(i, ...)))
                        end
                        local line = m .. " " .. self:GetFullName() .. "(" .. table.concat(parts, ", ") .. ")"
                        if otherRemoteLog[#otherRemoteLog] ~= line then
                            otherRemoteLog[#otherRemoteLog + 1] = line
                            if #otherRemoteLog > 30 then table.remove(otherRemoteLog, 1) end
                        end
                    end
                end
            end
            return old(self, ...)
        end
        old = hookmetamethod(game, "__namecall", newcclosure and newcclosure(hook) or hook)
    end)
end

-- v7.1 FIX: remote tra ve nil la THANH CONG ("nil"), chi bao "loi:" khi pcall that bai
local function callRemoteSync(r, ...)
    if not r then return nil end
    local args = { ... }
    local done, ret = false, nil
    local t0 = tick()
    task.spawn(function()
        local ok, res = pcall(function()
            if r:IsA("RemoteFunction") then
                return r:InvokeServer(table.unpack(args))
            else
                r:FireServer(table.unpack(args))
                return "fired"
            end
        end)
        if ok then
            ret = res
        else
            ret = "loi: " .. tostring(res)
        end
        done = true
    end)
    while not done and tick() - t0 < 1.5 do task.wait(0.05) end
    local finalRet
    if not done then
        finalRet = "het gio"
    elseif ret == nil then
        finalRet = "nil"
    else
        finalRet = ret
    end
    pushScriptLog(args, finalRet, (tick() - t0) * 1000)
    return finalRet
end

local function startQuest(q)
    local r = getCommF()
    if not r then return false end
    if q.index ~= nil then
        callRemoteSync(r, "StartQuest", q.name, q.index)
    else
        callRemoteSync(r, "StartQuest", q.name)
    end
    for _ = 1, 12 do
        if questActive(true) then return true end
        task.wait(0.08)
    end
    return questActive(true)
end

local function abandonQuest()
    local r = getCommF()
    if r then callRemoteSync(r, "AbandonQuest") end
end

local function invokeRet(r, ...)
    local args = { ... }
    local done, ret = false, nil
    local t0 = tick()
    task.spawn(function()
        local ok, res = pcall(function() return r:InvokeServer(table.unpack(args)) end)
        if ok then
            ret = res
        else
            ret = "loi: " .. tostring(res)
        end
        done = true
    end)
    while not done and tick() - t0 < 4 do task.wait(0.05) end
    local finalRet
    if not done then
        finalRet = "het gio"
    elseif ret == nil then
        finalRet = "nil"
    else
        finalRet = ret
    end
    pushScriptLog(args, finalRet, (tick() - t0) * 1000)
    return finalRet
end

function isErrRet(v)
    return type(v) == "string" and (string.sub(v, 1, 4) == "loi:" or v == "het gio")
end

local function showBuy(s)
    if buyResultLabel then buyResultLabel.Text = s end
    setStatus(s)
    print("[BF melee] " .. s)
end

local function fmtNum(n)
    local s = tostring(math.floor(n or 0))
    return s:reverse():gsub("(%d%d%d)", "%1,"):reverse():gsub("^,", "")
end

local function getCurrency()
    local beli, frags = 0, 0
    pcall(function() beli = plr.Data.Beli.Value end)
    pcall(function() frags = plr.Data.Fragments.Value end)
    return beli, frags
end

local masteryCache = {}
local function scanToolMastery()
    for _, container in ipairs({ plr.Backpack, plr.Character }) do
        if container then
            for _, t in ipairs(container:GetChildren()) do
                if t:IsA("Tool") and t.ToolTip == "Melee" then
                    local lvObj = t:FindFirstChild("Level") or t:FindFirstChild("Mastery")
                    local val = lvObj and tonumber(lvObj.Value)
                    if not val then val = tonumber(t:GetAttribute("Level") or t:GetAttribute("Mastery")) end
                    if val then masteryCache[t.Name] = val end
                end
            end
        end
    end
end

local function getCurrentMeleeTool()
    for _, container in ipairs({ plr.Character, plr.Backpack }) do
        if container then
            for _, t in ipairs(container:GetChildren()) do
                if t:IsA("Tool") and t.ToolTip == "Melee" then return t.Name end
            end
        end
    end
    return nil
end

local function getInventoryCounts(r)
    local counts = {}
    local inv = invokeRet(r, "getInventory")
    if type(inv) == "table" then
        for _, v in pairs(inv) do
            if type(v) == "table" and v.Name then
                counts[v.Name] = tonumber(v.Count) or 1
                if v.Mastery then masteryCache[v.Name] = tonumber(v.Mastery) end
            end
        end
        return counts
    end

    for _, container in ipairs({ plr.Backpack, plr.Character }) do
        if container then
            for _, t in ipairs(container:GetChildren()) do
                counts[t.Name] = (counts[t.Name] or 0) + 1
            end
        end
    end
    return counts
end

local function checkMeleeRequirements(m, r)
    scanToolMastery()
    local invCounts = getInventoryCounts(r)
    local beli, frags = getCurrency()
    local lvl = getLevel()
    local missing = {}

    if (m.lvReq or 1) > lvl then
        missing[#missing + 1] = "Lv." .. tostring(m.lvReq or 1) .. " (hiện " .. tostring(lvl) .. ")"
    end
    if (m.beli or 0) > beli then
        missing[#missing + 1] = "Thiếu " .. fmtNum(m.beli - beli) .. " Beli"
    end
    if (m.frags or 0) > frags then
        missing[#missing + 1] = "Thiếu " .. fmtNum(m.frags - frags) .. " Fragments"
    end
    for _, mr in ipairs(m.masteryReq or {}) do
        local curMas = masteryCache[mr.tool]
        if curMas == nil or curMas < mr.mas then
            missing[#missing + 1] = mr.tool .. " Mastery (" .. tostring(curMas or "?") .. "/" .. tostring(mr.mas) .. ")"
        end
    end
    for _, ir in ipairs(m.itemsReq or {}) do
        local have = invCounts[ir.name] or 0
        if have < ir.count then
            missing[#missing + 1] = tostring(ir.count - have) .. "x " .. ir.name
        end
    end
    return #missing == 0, missing, invCounts, beli, frags, lvl
end

local function notifyBF(msg, color)
    if not gui then return end
    task.spawn(function()
        local lbl = Instance.new("TextLabel")
        lbl.Size = UDim2.new(0.86, 0, 0, 68)
        lbl.Position = UDim2.new(0.07, 0, 0.18, 0)
        lbl.BackgroundTransparency = 1
        lbl.Text = msg
        lbl.TextColor3 = color or Color3.fromRGB(255, 225, 80)
        lbl.TextStrokeTransparency = 0.2
        lbl.TextStrokeColor3 = Color3.new(0, 0, 0)
        lbl.Font = Enum.Font.GothamBold
        lbl.TextSize = 17
        lbl.TextWrapped = true
        lbl.ZIndex = 99
        lbl.Parent = gui

        TweenService:Create(lbl, TweenInfo.new(0.25, Enum.EasingStyle.Quad), {
            Position = UDim2.new(0.07, 0, 0.13, 0)
        }):Play()

        task.wait(4.5)
        local fade = TweenService:Create(lbl, TweenInfo.new(0.5), {
            TextTransparency = 1,
            TextStrokeTransparency = 1
        })
        fade:Play()
        fade.Completed:Wait()
        lbl:Destroy()
    end)
end

------------------------------------------------------------------ Update 30: Skylands Cloud Scanner
local ELECTRO_NPC_POS = Vector3.new(-5384, 315, -2155)
local SKY_PATROL_POINTS = {
    Vector3.new(-5250, 420, -2150),
    Vector3.new(-4950, 520, -2450),
    Vector3.new(-4750, 720, -2600),
    Vector3.new(-5150, 650, -2750),
    Vector3.new(-5500, 480, -2350),
    Vector3.new(-5050, 860, -2250),
    Vector3.new(-5420, 620, -1920),
}

local cloudColorCache = setmetatable({}, { __mode = "k" })
local lastCloudScanList = {}

local function isCloudNamed(inst)
    local cur = inst
    for _ = 1, 5 do
        if not cur then break end
        local n = string.lower(cur.Name)
        if string.find(n, "cloud", 1, true) or string.find(n, "storm", 1, true)
            or string.find(n, "thunder", 1, true) or string.find(n, "lightning", 1, true) then
            return true
        end
        cur = cur.Parent
    end
    return false
end

local function hasCloudLightningFx(d)
    local check = { d, d.Parent }
    for _, obj in ipairs(check) do
        if obj and obj ~= workspace then
            for _, child in ipairs(obj:GetChildren()) do
                if (child:IsA("ParticleEmitter") and child.Enabled)
                    or (child:IsA("Beam") and child.Enabled)
                    or (child:IsA("PointLight") and child.Enabled)
                    or (child:IsA("Sparkles") and child.Enabled)
                    or child:IsA("Highlight") then
                    return true
                end
            end
        end
    end
    return false
end

local function scanSkylandsClouds()
    local now = tick()
    local candidates = {}
    local bestPart, bestScore = nil, nil
    for _, d in ipairs(workspace:GetDescendants()) do
        if d:IsA("BasePart") and isCloudNamed(d) and d.Transparency < 0.95 then
            local pos = d.Position
            local delta = (pos - ELECTRO_NPC_POS).Magnitude
            if delta < 3000 and pos.Y > 180 and pos.Y < 1900
                and math.max(d.Size.X, d.Size.Y, d.Size.Z) >= 3.5 then
                local c = d.Color
                local brightness = (c.R + c.G + c.B) / 3
                local rec = cloudColorCache[d]
                local isFlashing = false
                if rec then
                    if math.abs(brightness - rec.b) >= 0.04 then
                        rec.flashUntil = now + 8
                    end
                    rec.b = brightness
                    isFlashing = (rec.flashUntil or 0) > now
                else
                    cloudColorCache[d] = { b = brightness, flashUntil = 0 }
                end

                local fx = hasCloudLightningFx(d)
                local lowName = string.lower(d.Name .. " " .. (d.Parent and d.Parent.Name or ""))
                local stormTagged = string.find(lowName, "storm", 1, true) ~= nil
                    or string.find(lowName, "thunder", 1, true) ~= nil
                    or string.find(lowName, "lightning", 1, true) ~= nil
                    or string.find(lowName, "dark", 1, true) ~= nil

                local isTarget = isFlashing or fx or stormTagged or (brightness <= 0.68)
                local score = delta + brightness * 420
                    - (isFlashing and 700 or 0)
                    - (fx and 500 or 0)
                    - (stormTagged and 400 or 0)

                candidates[#candidates + 1] = {
                    part = d,
                    score = score,
                    brightness = brightness,
                    flashing = isFlashing,
                    fx = fx,
                    storm = stormTagged,
                    dist = math.floor(delta),
                    target = isTarget,
                }
                if isTarget and (not bestScore or score < bestScore) then
                    bestPart, bestScore = d, score
                end
            end
        end
    end

    table.sort(candidates, function(a, b) return a.score < b.score end)
    lastCloudScanList = {}
    for i = 1, math.min(6, #candidates) do
        local it = candidates[i]
        lastCloudScanList[i] = string.format(
            "%s | dist=%dm | bright=%.2f | flash=%s | fx=%s | storm=%s | target=%s",
            it.part:GetFullName(), it.dist, it.brightness,
            tostring(it.flashing), tostring(it.fx), tostring(it.storm), tostring(it.target)
        )
    end

    if bestPart then return bestPart.CFrame, bestPart end
    return nil, nil
end

local function findDarkCloudTarget()
    return scanSkylandsClouds()
end

local function getLightningBoltCount(r)
    local counts = getInventoryCounts(r)
    for name, count in pairs(counts) do
        local low = string.lower(tostring(name))
        if low == "lightning bolt" or string.find(low, "lightning bolt", 1, true) or string.find(low, "tia chớp", 1, true) then
            return tonumber(count) or 0
        end
    end
    return 0
end

function findDialogueChoice(needles)
    local pg = plr:FindFirstChild("PlayerGui")
    if not pg then return false end
    for _, d in ipairs(pg:GetDescendants()) do
        if d:IsA("TextButton") and d.Visible and isGuiActuallyVisible(d) then
            local txt = string.lower(d.Text or "")
            for _, needle in ipairs(needles) do
                if string.find(txt, needle, 1, true) then
                    local ok = pcall(function() d:Activate() end)
                    if not ok and firesignal then
                        pcall(function() firesignal(d.Activated) end)
                    end
                    return true
                end
            end
        end
    end
    return false
end

local function interactMadScientist(m)
    local targetCF, npcName = findMeleeNpcCF(m)
    if not targetCF then
        return false, "Không có tọa độ Mad Scientist ở Sea " .. getCurrentSea()
    end

    local function stopElectro()
        return not alive_script or not alive() or not (CFG.AutoMelee or manualBuyActive)
    end

    if hrp() and (hrp().Position - targetCF.Position).Magnitude > 18 then
        if not goTo(targetCF, false, stopElectro) then return false, "Không bay tới được Mad Scientist" end
    end

    local tWait = tick()
    local liveCF, liveName
    while tick() - tWait < 4 and not stopElectro() do
        local cf, name, live = findRealNpcInContainers(m)
        if cf and live then
            liveCF, liveName = cf, name
            break
        end
        task.wait(0.2)
    end

    if liveCF and hrp() and (hrp().Position - liveCF.Position).Magnitude > 10 then
        goTo(liveCF, false, stopElectro)
    end

    local npcFolder = workspace:FindFirstChild("NPCs") or workspace
    local npc
    local wantName = liveName or npcName
    for _, d in ipairs(npcFolder:GetDescendants()) do
        if d:IsA("Model") and d.Name == wantName then npc = d break end
    end
    if npc then
        for _, d in ipairs(npc:GetDescendants()) do
            if d:IsA("ProximityPrompt") then
                pcall(function()
                    if fireproximityprompt then
                        fireproximityprompt(d)
                    else
                        d:InputHoldBegin()
                        task.wait(math.max(d.HoldDuration, 0.2))
                        d:InputHoldEnd()
                    end
                end)
                break
            elseif d:IsA("ClickDetector") and fireclickdetector then
                pcall(function() fireclickdetector(d) end)
                break
            end
        end
    end
    task.wait(0.75)
    return true, wantName
end

------------------------------------------------------------------ REAL M1 ANIMATION + HIT IMPACT VFX (NO FAKE MOUSE CLICKING)
local m1State = {
    toolName = nil,
    gcController = nil,
    gcScanned = false,
    combatUtil = nil,
    combatUtilChecked = false,
    cachedAnimIds = {},
    animStep = 0,
    fallbackTracks = {},
    lastMethodUsed = "None",
}

local function getAnimator()
    local h = hum()
    if not h then return nil end
    return h:FindFirstChildOfClass("Animator") or h
end

local function getPlayingActionTracks()
    local anim = getAnimator()
    if not anim or not anim.GetPlayingAnimationTracks then return {}, 0 end
    local ids, cnt = {}, 0
    local ok, tracks = pcall(function() return anim:GetPlayingAnimationTracks() end)
    if ok and type(tracks) == "table" then
        for _, tr in ipairs(tracks) do
            if tr.IsPlaying and tr.Priority ~= Enum.AnimationPriority.Core
                and tr.Priority ~= Enum.AnimationPriority.Idle
                and tr.Priority ~= Enum.AnimationPriority.Movement then
                cnt = cnt + 1
                ids[#ids + 1] = tostring(tr.Animation and tr.Animation.AnimationId or tr.Name)
            end
        end
    end
    return ids, cnt
end

local function findSafeViewportPoint()
    local cam = workspace.CurrentCamera
    local vs = cam and cam.ViewportSize or Vector2.new(1280, 672)
    local pg = plr:FindFirstChild("PlayerGui")
    local ratios = {
        { 0.72, 0.45 },
        { 0.64, 0.34 },
        { 0.78, 0.30 },
        { 0.56, 0.42 },
    }
    for _, r in ipairs(ratios) do
        local sx, sy = math.floor(vs.X * r[1]), math.floor(vs.Y * r[2])
        local blocked = false
        if pg and pg.GetGuiObjectsAtPosition then
            local ok, objs = pcall(function() return pg:GetGuiObjectsAtPosition(sx, sy) end)
            if ok and type(objs) == "table" then
                for _, o in ipairs(objs) do
                    if o.Visible and (o:IsA("TextButton") or o:IsA("ImageButton") or o:IsDescendantOf(gui)) then
                        blocked = true
                        break
                    end
                end
            end
        end
        if not blocked then return sx, sy end
    end
    return math.floor(vs.X * 0.72), math.floor(vs.Y * 0.45)
end

local function getCombatUtil()
    if m1State.combatUtilChecked then return m1State.combatUtil end
    m1State.combatUtilChecked = true
    pcall(function()
        local mods = RS:FindFirstChild("Modules")
        local cu = mods and mods:FindFirstChild("CombatUtil")
        if cu and cu:IsA("ModuleScript") then
            local ok, mod = pcall(require, cu)
            if ok and type(mod) == "table" then
                m1State.combatUtil = mod
            end
        end
    end)
    return m1State.combatUtil
end

local function findLiveCombatController()
    if m1State.gcController and type(m1State.gcController) == "table" then
        return m1State.gcController
    end
    pcall(function()
        local ps = plr:FindFirstChild("PlayerScripts")
        local cfMod = ps and ps:FindFirstChild("CombatFramework")
        if cfMod and debug and debug.getupvalues then
            local ok, req = pcall(require, cfMod)
            if ok and type(req) == "table" then
                local ups = debug.getupvalues(req)
                if type(ups) == "table" then
                    for _, u in pairs(ups) do
                        if type(u) == "table" and u.activeController and type(u.activeController.attack) == "function" then
                            m1State.gcController = u.activeController
                            return
                        end
                    end
                end
            end
        end
    end)
    if m1State.gcController then return m1State.gcController end

    if not m1State.gcScanned and getgc then
        m1State.gcScanned = true
        pcall(function()
            for _, obj in ipairs(getgc(true)) do
                if type(obj) == "table" then
                    if type(rawget(obj, "attack")) == "function"
                        and (rawget(obj, "anims") ~= nil or rawget(obj, "hitboxMagnitude") ~= nil or rawget(obj, "timeToNextAttack") ~= nil) then
                        m1State.gcController = obj
                        break
                    elseif type(rawget(obj, "activeController")) == "table"
                        and type(rawget(rawget(obj, "activeController"), "attack")) == "function" then
                        m1State.gcController = rawget(obj, "activeController")
                        break
                    end
                end
            end
        end)
    end
    return m1State.gcController
end

local function collectToolAnimations(tool)
    local out, seen = {}, {}
    local function pushId(aid)
        if type(aid) == "string" and aid ~= "" and not seen[aid] then
            seen[aid] = true
            out[#out + 1] = aid
        end
    end
    if tool then
        for _, d in ipairs(tool:GetDescendants()) do
            if d:IsA("Animation") then pushId(d.AnimationId) end
        end
    end
    local ctrl = findLiveCombatController()
    if ctrl and type(ctrl.anims) == "table" and type(ctrl.anims.basic) == "table" then
        for _, animId in ipairs(ctrl.anims.basic) do
            if type(animId) == "string" then
                pushId(animId)
            elseif typeof(animId) == "Instance" and animId:IsA("Animation") then
                pushId(animId.AnimationId)
            end
        end
    end
    if #out == 0 then
        pushId("rbxassetid://522635514")
        pushId("rbxassetid://522638767")
    end
    return out
end

local function playNativeSwingAnimation(tool)
    if not tool then return false end
    if m1State.toolName ~= tool.Name then
        m1State.toolName = tool.Name
        m1State.cachedAnimIds = {}
        m1State.fallbackTracks = {}
        m1State.animStep = 0
    end

    local ctrl = findLiveCombatController()
    if ctrl and type(ctrl.attack) == "function" then
        local ok = pcall(function()
            if ctrl.timeToNextAttack then ctrl.timeToNextAttack = 0 end
            ctrl:attack()
        end)
        if ok then
            m1State.lastMethodUsed = "CombatController"
            return true
        end
    end

    local anim = getAnimator()
    if not (anim and anim.LoadAnimation) then return false end
    if #m1State.cachedAnimIds == 0 then
        m1State.cachedAnimIds = collectToolAnimations(tool)
    end
    local ids = m1State.cachedAnimIds
    if #ids == 0 then return false end

    m1State.animStep = (m1State.animStep % #ids) + 1
    local aid = ids[m1State.animStep]
    local tr = m1State.fallbackTracks[aid]
    if not tr then
        local aObj = Instance.new("Animation")
        aObj.AnimationId = aid
        local ok, loaded = pcall(function() return anim:LoadAnimation(aObj) end)
        if ok and loaded then
            loaded.Priority = Enum.AnimationPriority.Action
            m1State.fallbackTracks[aid] = loaded
            tr = loaded
        end
    end
    if tr then
        pcall(function() tr:Play(0.04, 1, 2.0) end)
        m1State.lastMethodUsed = "AnimatorDirect"
        return true
    end
    return false
end

local function getStyleVfxColor(tool)
    if not tool then return Color3.fromRGB(120, 210, 255) end
    local low = string.lower(tool.Name)
    if string.find(low, "electric", 1, true) or string.find(low, "electro", 1, true) or string.find(low, "pole", 1, true) then
        return Color3.fromRGB(90, 215, 255)
    elseif string.find(low, "dark", 1, true) or string.find(low, "death", 1, true) or string.find(low, "dragon", 1, true) then
        return Color3.fromRGB(255, 130, 55)
    elseif string.find(low, "water", 1, true) or string.find(low, "shark", 1, true) then
        return Color3.fromRGB(70, 170, 255)
    elseif string.find(low, "sanguine", 1, true) then
        return Color3.fromRGB(220, 55, 85)
    elseif tool.ToolTip == "Sword" then
        return Color3.fromRGB(255, 235, 150)
    end
    return Color3.fromRGB(255, 255, 255)
end

local function spawnHitImpactVFX(targetModel, hitPart, tool)
    if not (CFG.HitVFX and targetModel and hitPart and hitPart.Parent) then return end
    local now = tick()
    if lastTargetVfx[targetModel] and (now - lastTargetVfx[targetModel] < 0.14) then
        return
    end
    lastTargetVfx[targetModel] = now

    local color = getStyleVfxColor(tool)

    local cu = getCombatUtil()
    if cu then
        pcall(function()
            if type(cu.ApplyHitEffect) == "function" then
                cu:ApplyHitEffect(targetModel, hitPart)
            elseif type(cu.PlayHitEffect) == "function" then
                cu:PlayHitEffect(targetModel, hitPart)
            end
        end)
    end

    pcall(function()
        local pos = hitPart.Position + Vector3.new(
            (math.random() - 0.5) * 1.4,
            (math.random() - 0.5) * 1.2,
            (math.random() - 0.5) * 1.4
        )
        local fxPart = Instance.new("Part")
        fxPart.Name = "BF_HitFX"
        fxPart.Anchored = true
        fxPart.CanCollide = false
        fxPart.CanQuery = false
        fxPart.CanTouch = false
        fxPart.CastShadow = false
        fxPart.Material = Enum.Material.Neon
        fxPart.Color = color
        fxPart.Shape = Enum.PartType.Ball
        fxPart.Size = Vector3.new(1.1, 1.1, 1.1)
        fxPart.Transparency = 0.2
        fxPart.CFrame = CFrame.new(pos)
        fxPart.Parent = workspace

        TweenService:Create(fxPart, TweenInfo.new(0.18, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), {
            Size = Vector3.new(4.2, 4.2, 4.2),
            Transparency = 1,
        }):Play()

        local slash = Instance.new("Part")
        slash.Name = "BF_SlashFX"
        slash.Anchored = true
        slash.CanCollide = false
        slash.CanQuery = false
        slash.CanTouch = false
        slash.CastShadow = false
        slash.Material = Enum.Material.Neon
        slash.Color = Color3.new(1, 1, 1)
        slash.Size = Vector3.new(0.25, 0.25, 4.8)
        slash.Transparency = 0.1
        slash.CFrame = CFrame.new(pos) * CFrame.Angles(math.random() * 3.14, math.random() * 3.14, math.random() * 3.14)
        slash.Parent = workspace

        TweenService:Create(slash, TweenInfo.new(0.16, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), {
            Size = Vector3.new(0.08, 0.08, 7.2),
            Transparency = 1,
        }):Play()

        local oldHl = targetModel:FindFirstChild("BF_HitFlash")
        if not oldHl then
            local hl = Instance.new("Highlight")
            hl.Name = "BF_HitFlash"
            hl.FillColor = color
            hl.OutlineColor = Color3.new(1, 1, 1)
            hl.FillTransparency = 0.45
            hl.OutlineTransparency = 0.15
            hl.Adornee = targetModel
            hl.Parent = targetModel
            Debris:AddItem(hl, 0.12)
        end

        Debris:AddItem(fxPart, 0.22)
        Debris:AddItem(slash, 0.2)
    end)
end

local function triggerSwing(isCloudHit)
    local tool = plr.Character and plr.Character:FindFirstChildOfClass("Tool")
    if not tool then return end

    pcall(function() tool:Activate() end)
    if CFG.M1Effect then
        playNativeSwingAnimation(tool)
    end

    if (isCloudHit or CFG.ScreenClick) and VIM then
        local sx, sy = findSafeViewportPoint()
        pcall(function()
            VIM:SendMouseButtonEvent(sx, sy, 0, true, game, 0)
            VIM:SendMouseButtonEvent(sx, sy, 0, false, game, 0)
        end)
    end
end

-- Bay den sat NPC & mua vo
local function flyToNpcAndBuy(r, m, isManual)
    local ready, missing = checkMeleeRequirements(m, r)
    if not ready then
        return false, "Thiếu điều kiện: " .. table.concat(missing, " | "), 999, "N/A"
    end

    local targetCF, npcLabel = findMeleeNpcCF(m)
    if not targetCF then
        return false, "Không có NPC bán " .. m.name .. " ở Sea " .. getCurrentSea(), 999, "N/A"
    end

    isBuyingNpc = true
    manualBuyActive = isManual == true
    stopMoving()
    setHold(true)
    showBuy("Đang bay tới " .. tostring(npcLabel) .. "...")

    local arrived = goTo(targetCF, true)
    if not arrived or not shouldKeepBuying() then
        setHold(false)
        isBuyingNpc = false
        manualBuyActive = false
        return false, "Đã hủy di chuyển", 999, tostring(npcLabel)
    end

    local tWait = tick()
    local liveCF, liveName
    while tick() - tWait < 3.5 and shouldKeepBuying() do
        local cf, name, live = findRealNpcInContainers(m)
        if cf and live then
            liveCF, liveName = cf, name
            break
        end
        task.wait(0.2)
    end

    if not shouldKeepBuying() then
        setHold(false)
        isBuyingNpc = false
        manualBuyActive = false
        return false, "Đã hủy di chuyển", 999, tostring(npcLabel)
    end

    local finalCF = liveCF or targetCF
    local finalName = liveName or npcLabel

    local approachRoot = hrp()
    if approachRoot and (approachRoot.Position - finalCF.Position).Magnitude > 12 then
        goTo(finalCF, true)
    end

    local root = hrp()
    local dist = root and (root.Position - finalCF.Position).Magnitude or 999

    local lastRet
    for _, args in ipairs(m.steps) do
        lastRet = invokeRet(r, table.unpack(args))
        task.wait(0.2)
    end

    setHold(false)
    isBuyingNpc = false
    manualBuyActive = false

    local ok = (lastRet == 1 or lastRet == true or (type(lastRet) == "string" and string.find(string.lower(lastRet), "learned")))
    return ok, fmtVal(lastRet), math.floor(dist), tostring(finalName)
end

-- May trang thai Electro (Update 30): CHECK_STATE -> ACCEPT -> HUNT_CLOUD -> DELIVER -> BUY
function isElectroServerDone(stateVal)
    if stateVal == true or stateVal == 2 then return true end
    if type(stateVal) == "string" then
        local low = string.lower(stateVal)
        return string.find(low, "complete", 1, true) ~= nil or string.find(low, "done", 1, true) ~= nil or string.find(low, "unlock", 1, true) ~= nil
    end
    if type(stateVal) == "table" then
        return stateVal.Completed == true or stateVal.Done == true or stateVal.Unlocked == true
    end
    return false
end

function isElectroServerActive(stateVal)
    if stateVal == 1 then return true end
    if type(stateVal) == "string" then
        local low = string.lower(stateVal)
        return string.find(low, "active", 1, true) ~= nil or string.find(low, "progress", 1, true) ~= nil or string.find(low, "start", 1, true) ~= nil
    end
    if type(stateVal) == "table" then
        return stateVal.Active == true or stateVal.Started == true or stateVal.Accepted == true
    end
    return false
end

local function doElectroCloudQuest(r)
    if getCurrentSea() ~= 1 then
        electroStateName = "WRONG_SEA"
        return false, "Lightning Bolt chỉ lấy được ở Lower Skylands - First Sea"
    end
    isElectroQuestRunning = true
    autoMeleeNeedsFarm = false
    priorityBossName = nil
    local m = getMeleeById("Electric")
    local function stopElectro()
        return not alive_script or not alive() or not (CFG.AutoMelee or manualBuyActive)
    end
    local function finish(ok, msg, st)
        electroStateName = st or (ok and "READY_BUY" or "RETRY_WAIT")
        isElectroQuestRunning = false
        setHold(false)
        stopMoving()
        return ok, msg
    end

    electroStateName = "CHECK_STATE"
    local qState = invokeRet(r, "ElectroQuestState")
    if isElectroServerDone(qState) then
        electroQuestAccepted = true
        return finish(true, "Server báo đã xong quest Electric (" .. fmtVal(qState) .. ")", "READY_BUY")
    end
    if isElectroServerActive(qState) then
        electroQuestAccepted = true
    end

    local have = getLightningBoltCount(r)
    if have <= 0 then
        setHold(true)

        if not electroQuestAccepted then
            electroStateName = "ACCEPT"
            showBuy("Electric [1/4 - ACCEPT]: Tới Mad Scientist nhận quest Lightning Bolt...")
            local okNpc, npcMsg = interactMadScientist(m)
            if not okNpc then return finish(false, npcMsg, "ACCEPT_FAIL") end

            findDialogueChoice({
                "i'll get you one", "ill get you one", "get you one",
                "tôi sẽ", "đồng ý", "nhận", "có", "yes", "ok"
            })
            electroQuestAccepted = true
            task.wait(0.6)
        end

        electroStateName = "HUNT_CLOUD"
        showBuy("Electric [2/4 - HUNT]: Đang bay quét mây đen/mây nháy ở Skylands...")
        local startedAt = tick()
        local patrolIdx = 1
        local lastPatrolT = 0
        local lastBoltCheck = 0

        while not stopElectro() and (tick() - startedAt < 65) do
            if tick() - lastBoltCheck >= 1.2 then
                lastBoltCheck = tick()
                have = getLightningBoltCount(r)
                if have > 0 then break end
            end

            local cloudCF, cloudPart = findDarkCloudTarget()
            if cloudCF and cloudPart and cloudPart.Parent then
                showBuy("Electric [2/4 - HUNT]: Thấy mây đen/nháy! Đang bay xuyên & đánh...")
                equipWeapon()
                local attackStarted = tick()
                local passStep = 0
                while not stopElectro() and cloudPart and cloudPart.Parent and (tick() - attackStarted < 9) do
                    if tick() - lastBoltCheck >= 1.0 then
                        lastBoltCheck = tick()
                        if getLightningBoltCount(r) > 0 then break end
                    end
                    local root = hrp()
                    if root then
                        passStep = (passStep + 1) % 6
                        local offset = (passStep == 0) and Vector3.new(0, 0, 0) or Vector3.new(0, 1.5, 5)
                        local dest = cloudPart.Position + offset
                        if (root.Position - dest).Magnitude > 14 then
                            if not goTo(CFrame.new(dest), false, stopElectro) then break end
                        else
                            root.CFrame = CFrame.lookAt(dest, cloudPart.Position + Vector3.new(0, 0, 0.01))
                            root.AssemblyLinearVelocity = Vector3.zero
                        end
                        if firetouchinterest then
                            pcall(function()
                                firetouchinterest(root, cloudPart, 0)
                                firetouchinterest(root, cloudPart, 1)
                            end)
                        end
                    end
                    triggerSwing(true)
                    task.wait(0.16)
                end
                task.wait(0.35)
            else
                if tick() - lastPatrolT >= 2.8 then
                    lastPatrolT = tick()
                    local pt = SKY_PATROL_POINTS[patrolIdx]
                    local curIdx = patrolIdx
                    patrolIdx = (patrolIdx % #SKY_PATROL_POINTS) + 1
                    showBuy("Electric [2/4 - HUNT]: Quét mây Skylands (" .. curIdx .. "/" .. #SKY_PATROL_POINTS .. ")...")
                    goTo(CFrame.new(pt), false, stopElectro)
                else
                    task.wait(0.35)
                end
            end
        end

        have = getLightningBoltCount(r)
        if have <= 0 then
            return finish(false, "Hết lượt quét 65s chưa rớt Lightning Bolt -> tự quét tiếp sau backoff", "HUNT_RETRY")
        end
    end

    electroStateName = "DELIVER"
    setHold(true)
    showBuy("Electric [3/4 - DELIVER]: Đã có Lightning Bolt! Đang quay lại Mad Scientist giao đồ...")
    local okNpc, npcMsg = interactMadScientist(m)
    if not okNpc then return finish(false, npcMsg, "DELIVER_FAIL") end

    findDialogueChoice({
        "hand it over", "hand over", "give it", "deliver",
        "đưa", "giao", "trả", "có", "yes", "ok"
    })
    task.wait(1.0)

    local afterDeliver = getLightningBoltCount(r)
    local afterState = invokeRet(r, "ElectroQuestState")
    if afterDeliver > 0 and not isElectroServerDone(afterState) then
        return finish(false, "Đã tới Mad Scientist nhưng Lightning Bolt vẫn còn trong túi (state=" .. fmtVal(afterState) .. ")", "DELIVER_RETRY")
    end

    return finish(true, "Đã giao Lightning Bolt cho Mad Scientist!", "READY_BUY")
end

buyMelee = function(m)
    if isBuyingNpc then
        showBuy("Đang xử lý NPC, vui lòng chờ...")
        return
    end
    local r = getCommF()
    if not r or not r:IsA("RemoteFunction") then
        showBuy("Không tìm thấy CommF_ RemoteFunction")
        return
    end

    task.spawn(function()
        local ready, missing = checkMeleeRequirements(m, r)
        if not ready then
            local reason = "CHƯA ĐỦ ĐIỀU KIỆN: " .. table.concat(missing, " | ")
            showBuy(reason)
            notifyBF(reason, Color3.fromRGB(255, 170, 80))
            return
        end

        if m.specialQuest == "ElectroCloudQuest" then
            manualBuyActive = true
            local questOK, questMsg = doElectroCloudQuest(r)
            manualBuyActive = false
            if not questOK then
                showBuy("Lightning Bolt: " .. tostring(questMsg))
                return
            end
        elseif m.specialQuest == "ElectricClaw30s" then
            local reason = "UNSUPPORTED: cần tự hoàn thành quest 30 giây của Electric Claw trước khi mua"
            showBuy(reason)
            notifyBF(reason, Color3.fromRGB(255, 170, 80))
            return
        end

        local ok, lastRet, distToNpc, npcLabel = flyToNpcAndBuy(r, m, true)
        if lastRet == "Đã hủy di chuyển" then return end
        if ok or getCurrentMeleeTool() == m.id then
            local msg = "Đã tới " .. tostring(npcLabel) .. " và mua thành công: " .. m.name .. "!"
            showBuy("[OK] " .. msg)
            notifyBF(msg, Color3.fromRGB(90, 255, 120))
        else
            local reason = "Tại " .. tostring(npcLabel) .. " (cách " .. tostring(distToNpc) .. "m), server trả về: " .. tostring(lastRet)
            showBuy("[KHÔNG MUA ĐƯỢC] " .. reason)
            notifyBF("Không mua được " .. m.name .. ": " .. reason, Color3.fromRGB(255, 95, 95))
        end
    end)
end

-- Vong lap Auto Lay Melee
task.spawn(function()
    local lastCheck = 0
    while alive_script do
        task.wait(0.5)
        if CFG.AutoMelee and alive() and not isBuyingNpc and not isElectroQuestRunning and not questItemRunning and not questItemHoldLock then
            local now = tick()
            if now - lastCheck >= meleeBackoffSec then
                lastCheck = now
                local okLoop, errLoop = pcall(function()
                    local r = getCommF()
                    if not r then return end
                    local m = getMeleeById(CFG.SelectedMelee)
                    if not m then return end

                    if getCurrentMeleeTool() == m.id then
                        CFG.AutoMelee = false
                        priorityBossName = nil
                        autoMeleeNeedsFarm = false
                        electroQuestAccepted = false
                        electroStateName = "OWNED"
                        meleeBackoffSec = 3
                        if autoMeleeTogglePaint then autoMeleeTogglePaint() end
                        local doneMsg = "Đã sở hữu " .. m.name .. "!"
                        showBuy(doneMsg)
                        notifyBF(doneMsg, Color3.fromRGB(90, 255, 120))
                        return
                    end

                    scanToolMastery()
                    local invCounts = getInventoryCounts(r)
                    local beli, frags = getCurrency()

                    if (m.lvReq or 1) > getLevel() then
                        priorityBossName = nil
                        autoMeleeNeedsFarm = true
                        masteryTargetTool = nil
                        meleeBackoffSec = 3
                        showBuy("NEED_LEVEL [" .. m.id .. "]: cần Lv." .. tostring(m.lvReq) .. ", hiện Lv." .. tostring(getLevel()))
                        return
                    end

                    masteryTargetTool = nil
                    for _, mr in ipairs(m.masteryReq or {}) do
                        local curMas = masteryCache[mr.tool]
                        if curMas == nil or curMas < mr.mas then
                            priorityBossName = nil
                            local owned = false
                            for _, container in ipairs({ plr.Backpack, plr.Character }) do
                                local t = container and container:FindFirstChild(mr.tool)
                                if t and t:IsA("Tool") and t.ToolTip == "Melee" then
                                    owned = true
                                    break
                                end
                            end
                            if not owned then
                                local subM = getMeleeById(mr.tool)
                                local bought, buyReason = flyToNpcAndBuy(r, subM, false)
                                if not CFG.AutoMelee then return end
                                task.wait(0.4)
                                scanToolMastery()
                                curMas = masteryCache[mr.tool]
                                if not bought and not (plr.Backpack:FindFirstChild(mr.tool) or (plr.Character and plr.Character:FindFirstChild(mr.tool))) then
                                    autoMeleeNeedsFarm = false
                                    masteryTargetTool = nil
                                    meleeBackoffSec = math.min(20, meleeBackoffSec * 2)
                                    showBuy("RETRY [" .. m.id .. "] (" .. meleeBackoffSec .. "s): chưa sở hữu " .. mr.tool .. " — " .. tostring(buyReason))
                                    return
                                end
                            end
                            if curMas == nil or curMas < mr.mas then
                                autoMeleeNeedsFarm = true
                                masteryTargetTool = mr.tool
                                meleeBackoffSec = 3
                                showBuy(string.format("NEED_MASTERY [%s]: cày %s (%s/%d)",
                                    m.id, mr.tool, tostring(curMas or 0), mr.mas))
                                return
                            end
                        end
                    end

                    for _, ir in ipairs(m.itemsReq or {}) do
                        local have = invCounts[ir.name] or 0
                        if have < ir.count then
                            if ir.boss and hasAliveBoss(ir.boss) then
                                priorityBossName = ir.boss
                                autoMeleeNeedsFarm = true
                                meleeBackoffSec = 3
                                showBuy("Auto Melee [" .. m.id .. "]: Đang săn boss " .. ir.boss .. " lấy " .. ir.name)
                                return
                            else
                                priorityBossName = nil
                                autoMeleeNeedsFarm = false
                                meleeBackoffSec = math.min(15, meleeBackoffSec + 3)
                                showBuy("IDLE [" .. m.id .. "]: Thiếu " .. (ir.count - have) .. "x " .. ir.name .. " (" .. ir.source .. ") -> chờ " .. meleeBackoffSec .. "s")
                                return
                            end
                        end
                    end

                    priorityBossName = nil

                    if (m.beli or 0) > beli then
                        autoMeleeNeedsFarm = true
                        meleeBackoffSec = 3
                        showBuy("Auto Melee [" .. m.id .. "]: Farm thêm " .. fmtNum(m.beli - beli) .. " Beli")
                        return
                    end
                    if (m.frags or 0) > frags then
                        autoMeleeNeedsFarm = false
                        meleeBackoffSec = 10
                        showBuy("IDLE [" .. m.id .. "]: Thiếu " .. fmtNum(m.frags - frags) .. " Fragments -> đứng yên")
                        return
                    end

                    autoMeleeNeedsFarm = false
                    if m.specialQuest == "ElectroCloudQuest" then
                        local questOK, questMsg = doElectroCloudQuest(r)
                        if not CFG.AutoMelee then return end
                        if not questOK then
                            meleeBackoffSec = math.min(20, meleeBackoffSec * 2)
                            showBuy("RETRY [Electric | " .. electroStateName .. " | " .. meleeBackoffSec .. "s]: " .. tostring(questMsg))
                            return
                        end
                        meleeBackoffSec = 3
                    elseif m.specialQuest == "ElectricClaw30s" then
                        meleeBackoffSec = 15
                        showBuy("IDLE [Electric Claw]: cần tự hoàn thành quest 30 giây")
                        return
                    end

                    electroStateName = "BUY"
                    local ok, lastRet, distToNpc, npcLabel = flyToNpcAndBuy(r, m, false)
                    if not CFG.AutoMelee then return end
                    if ok or getCurrentMeleeTool() == m.id then
                        CFG.AutoMelee = false
                        electroQuestAccepted = false
                        electroStateName = "OWNED"
                        meleeBackoffSec = 3
                        if autoMeleeTogglePaint then autoMeleeTogglePaint() end
                        local winMsg = "Đã tới " .. tostring(npcLabel) .. " và mua thành công: " .. m.name .. "!"
                        showBuy(winMsg)
                        notifyBF(winMsg, Color3.fromRGB(90, 255, 120))
                    else
                        autoMeleeNeedsFarm = false
                        meleeBackoffSec = math.min(20, meleeBackoffSec * 2)
                        showBuy("BUY_RETRY [" .. m.id .. " | " .. meleeBackoffSec .. "s]: Tại " .. tostring(npcLabel) .. " (cách " .. tostring(distToNpc) .. "m), server=" .. tostring(lastRet))
                    end
                end)
                if not okLoop then
                    meleeBackoffSec = math.min(20, meleeBackoffSec * 2)
                    showBuy("Loi AutoMelee (" .. meleeBackoffSec .. "s): " .. tostring(errLoop))
                    warn("[BF AutoMelee] " .. tostring(errLoop))
                end
            end
        elseif not CFG.AutoMelee then
            priorityBossName = nil
            autoMeleeNeedsFarm = false
            masteryTargetTool = nil
            meleeBackoffSec = 3
            lastCheck = 0
        end
    end
end)

local function enemyLevel(e)
    local h = e:FindFirstChildOfClass("Humanoid")
    local s = (h and h.DisplayName or "") .. " " .. e.Name
    local n = string.match(s, "[Ll][Vv]%.?%s*(%d+)")
    return n and tonumber(n) or nil
end

local function nearestEnemy(mob, around, allowRS)
    local best, bd
    local function scan(folder)
        if not folder then return end
        for _, e in ipairs(folder:GetChildren()) do
            if (mob == nil or matchMobName(e.Name, mob)) and aliveEnemy(e) then
                local d = (e.HumanoidRootPart.Position - around).Magnitude
                if not bd or d < bd then best, bd = e, d end
            end
        end
    end
    scan(enemiesFolder())
    if allowRS and not best and mob then scan(RS) end
    return best
end

local function bestClusterEnemy(mob, around)
    local ef = enemiesFolder()
    if not ef then return nil, nil, 0 end
    local list = {}
    for _, e in ipairs(ef:GetChildren()) do
        if (mob == nil or matchMobName(e.Name, mob)) and aliveEnemy(e) then
            local er = e:FindFirstChild("HumanoidRootPart")
            if er then
                list[#list + 1] = { model = e, pos = er.Position }
            end
        end
    end
    if #list == 0 then return nil, nil, 0 end
    if #list == 1 or not CFG.SmartCluster then
        local best, bd
        for _, item in ipairs(list) do
            local d = (item.pos - around).Magnitude
            if not bd or d < bd then best, bd = item, d end
        end
        return best.model, best.pos, 1
    end

    local groupR = math.min(CFG.BringRadius * 2, 320)
    local bestItem, bestCount, bestCenter, bestDist = nil, -1, nil, math.huge
    for _, a in ipairs(list) do
        local cnt, sum = 0, Vector3.zero
        for _, b in ipairs(list) do
            if (a.pos - b.pos).Magnitude <= groupR then
                cnt = cnt + 1
                sum = sum + b.pos
            end
        end
        local d = (a.pos - around).Magnitude
        if cnt > bestCount or (cnt == bestCount and d < bestDist) then
            bestItem = a.model
            bestCount = cnt
            bestCenter = sum / cnt
            bestDist = d
        end
    end
    return bestItem, bestCenter, bestCount
end

local lastBusoCheck = 0
function ensureBusoHaki()
    if not CFG.AutoBuso then return end
    local now = tick()
    if now - lastBusoCheck < 2.5 then return end
    lastBusoCheck = now
    local ch = plr.Character
    if not ch or ch:FindFirstChild("HasBuso") then return end
    local r = getCommF()
    if r then
        task.spawn(function()
            pcall(function() r:InvokeServer("Buso") end)
        end)
    end
end

local lastSkillCast = 0
function tryCastFarmSkills()
    if not CFG.AutoSkillZX or not VIM then return end
    local now = tick()
    if now - lastSkillCast < 1.4 then return end
    lastSkillCast = now
    pcall(function()
        VIM:SendKeyEvent(true, Enum.KeyCode.Z, false, game)
        task.wait(0.05)
        VIM:SendKeyEvent(false, Enum.KeyCode.Z, false, game)
        task.wait(0.12)
        VIM:SendKeyEvent(true, Enum.KeyCode.X, false, game)
        task.wait(0.05)
        VIM:SendKeyEvent(false, Enum.KeyCode.X, false, game)
    end)
end

function mobByLevel(level, around)
    local ef = enemiesFolder()
    if not ef then return nil end
    local bestName, bestLv
    for _, e in ipairs(ef:GetChildren()) do
        local eh0 = e:FindFirstChildOfClass("Humanoid")
        local isBossMob = eh0 and string.find(eh0.DisplayName, "[Boss]", 1, true) ~= nil
        if aliveEnemy(e) and not isBossMob then
            local lv = enemyLevel(e)
            if lv and lv <= level + 2 and (not bestLv or lv > bestLv) then
                bestName, bestLv = e.Name, lv
            end
        end
    end
    if bestName then return bestName, "mob level " .. tostring(bestLv) end
    local e = nearestEnemy(nil, around)
    if e then return e.Name, "mob gan nhat" end
    return nil
end

------------------------------------------------------------------ debug + SCAN DATA
local cachedRA, cachedRH
local function getHitRemotes()
    if cachedRA and cachedRA.Parent and cachedRH and cachedRH.Parent then
        return cachedRA, cachedRH
    end
    local m = RS:FindFirstChild("Modules")
    local n = m and m:FindFirstChild("Net")
    if n then
        cachedRA = n:FindFirstChild("RE/RegisterAttack") or n:FindFirstChild("RegisterAttack")
        cachedRH = n:FindFirstChild("RE/RegisterHit") or n:FindFirstChild("RegisterHit")
    end
    return cachedRA, cachedRH
end

hasRemote = function()
    local ra, rh = getHitRemotes()
    return ra ~= nil and rh ~= nil
end

function posStr(p)
    return string.format("(%.1f, %.1f, %.1f)", p.X, p.Y, p.Z)
end

-- Quet vat the quanh nguoi: Prompt / ClickDetector / TouchInterest / bang-bang / NPC
function scanNearbyObjects(radius, maxLines)
    local out = {}
    local root = hrp()
    if not root then return { "khong co HumanoidRootPart" } end
    local origin = root.Position
    local items = {}
    for _, d in ipairs(workspace:GetDescendants()) do
        local part, kind
        if d:IsA("ProximityPrompt") then
            part = d.Parent; kind = "Prompt[" .. tostring(d.ActionText) .. "/" .. tostring(d.ObjectText) .. "]"
        elseif d:IsA("ClickDetector") then
            part = d.Parent; kind = "ClickDetector"
        elseif d:IsA("TouchTransmitter") then
            part = d.Parent; kind = "TouchInterest"
        elseif d:IsA("BasePart") and (d.Material == Enum.Material.Ice or d.Material == Enum.Material.Glacier) then
            part = d; kind = "IcePart"
        elseif d:IsA("BasePart") then
            local n = string.lower(d.Name)
            if string.find(n, "icicle", 1, true) or string.find(n, "spike", 1, true) or string.find(n, "stalac", 1, true)
                or string.find(n, "drip", 1, true) or string.find(n, "drop", 1, true) or string.find(n, "water", 1, true) then
                part = d; kind = "NamedPart"
            end
        end
        if part and part:IsA("BasePart") then
            local dist = (part.Position - origin).Magnitude
            if dist <= radius then
                items[#items + 1] = {
                    dist = dist,
                    line = string.format("%s | %s | %s | pos=%s size=%s mat=%s",
                        kind, part:GetFullName(), part.ClassName, posStr(part.Position),
                        posStr(part.Size), tostring(part.Material)),
                }
            end
        end
    end
    table.sort(items, function(a, b) return a.dist < b.dist end)
    for i = 1, math.min(maxLines or 45, #items) do
        out[#out + 1] = string.format("  [%dm] %s", math.floor(items[i].dist), items[i].line)
    end
    if #items == 0 then out[1] = "  (khong thay gi trong ban kinh " .. radius .. "m)" end
    return out
end

function listNpcs(maxLines)
    local out = {}
    local function scanFolder(folder, label)
        if not folder then return end
        local n = 0
        for _, d in ipairs(folder:GetChildren()) do
            if d:IsA("Model") then
                local cf = extractTargetCF(d)
                out[#out + 1] = string.format("  [%s] %s @ %s", label, d.Name, cf and posStr(cf.Position) or "?")
                n = n + 1
                if n >= (maxLines or 60) then break end
            end
        end
    end
    scanFolder(workspace:FindFirstChild("NPCs"), "workspace.NPCs")
    scanFolder(RS:FindFirstChild("NPCs"), "RS.NPCs")
    if #out == 0 then out[1] = "  (khong thay folder NPCs)" end
    return out
end

function listRemotes(maxLines)
    local out = {}
    local n = 0
    for _, d in ipairs(RS:GetDescendants()) do
        if d:IsA("RemoteEvent") or d:IsA("RemoteFunction") then
            out[#out + 1] = "  " .. d.ClassName .. " " .. d:GetFullName()
            n = n + 1
            if n >= (maxLines or 80) then break end
        end
    end
    return out
end

function describeTool(t)
    local lines = {}
    if not t then return { "  (khong co tool)" } end
    lines[#lines + 1] = "  Tool=" .. t.Name .. " ToolTip=" .. tostring(t.ToolTip)
    local okA, attrs = pcall(function() return t:GetAttributes() end)
    if okA and type(attrs) == "table" then
        for k, v in pairs(attrs) do lines[#lines + 1] = "  attr " .. tostring(k) .. "=" .. tostring(v) end
    end
    for _, d in ipairs(t:GetDescendants()) do
        local extra = ""
        if d:IsA("ValueBase") then extra = " value=" .. tostring(d.Value) end
        if d:IsA("BasePart") then extra = " transp=" .. string.format("%.2f", d.Transparency) end
        lines[#lines + 1] = "  child " .. d.ClassName .. " " .. d.Name .. extra
        if #lines > 30 then break end
    end
    return lines
end

function scanDataReport()
    local lines = {}
    local function add(s) lines[#lines + 1] = tostring(s) end
    local root = hrp()
    add("========== BF SCAN DATA (v7.1) ==========")
    add("Time=" .. os.date("%Y-%m-%d %H:%M:%S") .. " | PlaceId=" .. tostring(game.PlaceId) .. " | Sea=" .. getCurrentSea())
    add("Pos=" .. (root and posStr(root.Position) or "nil"))
    add("")
    add("--- VAT THE QUANH NGUOI (120m): Prompt / Click / Touch / Ice / icicle / drop ---")
    for _, l in ipairs(scanNearbyObjects(120, 55)) do add(l) end
    add("")
    add("--- NPC (workspace.NPCs / RS.NPCs) ---")
    for _, l in ipairs(listNpcs(70)) do add(l) end
    add("")
    add("--- TOOL CUP ---")
    local cup = (plr.Character and plr.Character:FindFirstChild("Cup")) or plr.Backpack:FindFirstChild("Cup")
    for _, l in ipairs(describeTool(cup)) do add(l) end
    add("")
    add("--- REMOTES TRONG ReplicatedStorage ---")
    for _, l in ipairs(listRemotes(80)) do add(l) end
    add("")
    add("--- REMOTE KHAC GAME VUA GOI (tru Register*) (" .. #otherRemoteLog .. ") ---")
    for i = math.max(1, #otherRemoteLog - 25), #otherRemoteLog do add("  " .. otherRemoteLog[i]) end
    add("========== END SCAN ==========")
    return table.concat(lines, "\n")
end

local function dump()
    scanToolMastery()
    local lines = {}
    local function add(s) lines[#lines + 1] = tostring(s) end
    local r = getCommF()
    local beli, frags = getCurrency()
    local root = hrp()
    local eqTool = plr.Character and plr.Character:FindFirstChildOfClass("Tool")
    local ra, rh = getHitRemotes()

    add("========== BLOX FRUITS FULL DEBUG (v7.1) ==========")
    add("Time=" .. os.date("%Y-%m-%d %H:%M:%S") .. " | PlaceId=" .. tostring(game.PlaceId) .. " | Sea=" .. getCurrentSea())
    add("Level=" .. tostring(getLevel()) .. " | Beli=" .. fmtNum(beli) .. " | Frags=" .. fmtNum(frags))
    add("Pos=" .. (root and string.format("(%.1f, %.1f, %.1f)", root.Position.X, root.Position.Y, root.Position.Z) or "nil"))
    add("EquippedTool=" .. tostring(eqTool and (eqTool.Name .. " [" .. eqTool.ToolTip .. "]") or "none") .. " | CurrentMelee=" .. tostring(getCurrentMeleeTool()))
    add("Flags: Farm=" .. tostring(CFG.Enabled) .. " KillAura=" .. tostring(CFG.KillAura) .. " PvP=" .. tostring(CFG.KillAuraPlayers)
        .. " InstantHit=" .. tostring(CFG.InstantHit) .. " M1Effect=" .. tostring(CFG.M1Effect) .. " HitVFX=" .. tostring(CFG.HitVFX)
        .. " AutoBuso=" .. tostring(CFG.AutoBuso) .. " AutoMelee=" .. tostring(CFG.AutoMelee) .. " Selected=" .. tostring(CFG.SelectedMelee))
    add("SaberState: cupFilledFlag=" .. tostring(cupFilledFlag) .. " mobLeaderPatrolIdx=" .. tostring(mobLeaderPatrolIdx))
    add("Remotes: CommF=" .. tostring(r and r:GetFullName() or "nil")
        .. " | RegAttack=" .. tostring(ra and ra:GetFullName() or "nil")
        .. " | RegHit=" .. tostring(rh and rh:GetFullName() or "nil"))
    add("Quest: active=" .. tostring(questActive(true)) .. " | qText=" .. tostring(qText))

    add("")
    add("--- [1] COMBAT & ANIMATION ENGINE ---")
    local playingIds, playingCnt = getPlayingActionTracks()
    add("M1Method=" .. tostring(m1State.lastMethodUsed) .. " | HasController=" .. tostring(m1State.gcController ~= nil)
        .. " | HasCombatUtil=" .. tostring(m1State.combatUtil ~= nil) .. " | CachedAnims=" .. tostring(#m1State.cachedAnimIds))
    add("PlayingActionTracks(" .. playingCnt .. ")=" .. (#playingIds > 0 and table.concat(playingIds, ", ") or "none"))

    add("")
    add("--- [2] LIVE SERVER PROBES (ELECTRO / SABER / INVENTORY) ---")
    if r then
        local eState = invokeRet(r, "ElectroQuestState")
        local pState = invokeRet(r, "ProQuestProgress")
        local boltCnt = getLightningBoltCount(r)
        add("ElectroQuestState => " .. fmtVal(eState, 0))
        add("ElectroStateMachine=" .. tostring(electroStateName) .. " | Accepted=" .. tostring(electroQuestAccepted) .. " | Backoff=" .. tostring(meleeBackoffSec) .. "s | LightningBolt=" .. tostring(boltCnt))
        add("ProQuestProgress => " .. fmtVal(pState, 0))
    else
        add("Khong co CommF_ de probe server")
    end
    local madM = getMeleeById("Electric")
    local madCF, madName, madLive = findMeleeNpcCF(madM)
    local madDist = (root and madCF) and math.floor((root.Position - madCF.Position).Magnitude) or -1
    add("MadScientist: name=" .. tostring(madName) .. " | liveInWS=" .. tostring(madLive) .. " | dist=" .. tostring(madDist) .. "m")

    add("")
    add("--- [3] SKYLANDS DARK / FLASHING CLOUDS ---")
    scanSkylandsClouds()
    if #lastCloudScanList == 0 then
        add("Khong thay cloud part nao quanh Lower Skylands")
    else
        for i, cLine in ipairs(lastCloudScanList) do
            add("  [" .. i .. "] " .. cLine)
        end
    end

    add("")
    add("--- [4] SCRIPT CommF_ CALLS + SERVER RETURNS (" .. #scriptCallLog .. ") ---")
    for i = math.max(1, #scriptCallLog - 25), #scriptCallLog do
        add("  " .. scriptCallLog[i])
    end

    add("")
    add("--- [5] GAME CommF_ CALLS + SERVER RETURNS (" .. #commLog .. ") ---")
    for i = math.max(1, #commLog - 25), #commLog do
        add("  InvokeServer(" .. commLog[i] .. ")")
    end

    add("")
    add("--- [6] VAT THE GAN NGUOI (60m) ---")
    for _, l in ipairs(scanNearbyObjects(60, 25)) do add(l) end
    add("========== END FULL DEBUG ==========")
    return table.concat(lines, "\n")
end

function exportText(s, fileName, okMsg)
    print("[BF]\n" .. s)
    local copied = pcall(function()
        if setclipboard then setclipboard(s) else error("no clipboard") end
    end)
    local saved = false
    if writefile then
        saved = pcall(function() writefile(fileName, s) end)
    end
    if copied and saved then
        setStatus(okMsg .. " + luu " .. fileName)
    elseif copied then
        setStatus(okMsg .. " (clipboard)")
    elseif saved then
        setStatus("Da luu: " .. fileName)
    else
        setStatus("Xem trong console (F9)")
    end
end


------------------------------------------------------------------ v7.1: FULL SCAN CA SEA -> thu muc BF_Scan/
fullScanRunning = false

function dumpTableStr(v, depth, seen, maxDepth)
    depth = depth or 0
    maxDepth = maxDepth or 4
    local tv = type(v)
    if tv == "string" then return '"' .. v .. '"' end
    if tv ~= "table" then return tostring(v) end
    seen = seen or {}
    if seen[v] then return "{<cycle>}" end
    if depth >= maxDepth then return "{...}" end
    seen[v] = true
    local parts, n = {}, 0
    for k, x in pairs(v) do
        n = n + 1
        if n > 60 then parts[#parts + 1] = "...+more"; break end
        parts[#parts + 1] = string.rep("  ", depth + 1) .. tostring(k) .. " = " .. dumpTableStr(x, depth + 1, seen, maxDepth)
    end
    seen[v] = nil
    return "{\n" .. table.concat(parts, ",\n") .. "\n" .. string.rep("  ", depth) .. "}"
end

function writeChunks(name, lines, per)
    per = per or 15000
    pcall(function() if makefolder then makefolder("BF_Scan") end end)
    local files = 0
    local i = 1
    while i <= #lines do
        files = files + 1
        local j = math.min(i + per - 1, #lines)
        local fname = "BF_Scan/" .. name .. (#lines > per and ("_" .. files) or "") .. ".txt"
        pcall(function() writefile(fname, table.concat(lines, "\n", i, j)) end)
        i = j + 1
    end
    if #lines == 0 then pcall(function() writefile("BF_Scan/" .. name .. ".txt", "(trong)") end) end
    return files
end

function instLine(d)
    local base = d.ClassName .. " | " .. d:GetFullName()
    if d:IsA("BasePart") then
        return string.format("%s | pos=%s size=%s mat=%s transp=%.2f col=%s collide=%s",
            base, posStr(d.Position), posStr(d.Size), tostring(d.Material), d.Transparency,
            tostring(d.Color), tostring(d.CanCollide))
    elseif d:IsA("ProximityPrompt") then
        return base .. " | action=" .. tostring(d.ActionText) .. " object=" .. tostring(d.ObjectText) .. " hold=" .. tostring(d.HoldDuration)
    elseif d:IsA("ValueBase") then
        return base .. " | value=" .. tostring(d.Value)
    elseif d:IsA("Model") then
        local cf = extractTargetCF(d)
        return base .. (cf and (" | pos=" .. posStr(cf.Position)) or "")
    end
    return base
end

function fullScanTour(setMsg)
    -- bay qua cac cum EnemySpawns + NPC de StreamingEnabled load map
    local pts = {}
    local function add(p)
        for _, q in ipairs(pts) do
            if (q - p).Magnitude < 350 then return end
        end
        pts[#pts + 1] = p
    end
    local sf = spawnsFolder()
    if sf then
        for _, s in ipairs(sf:GetChildren()) do
            local cf = extractTargetCF(s)
            if cf then add(cf.Position) end
        end
    end
    for _, folder in ipairs({ workspace:FindFirstChild("NPCs"), RS:FindFirstChild("NPCs") }) do
        if folder then
            for _, m in ipairs(folder:GetChildren()) do
                local cf = extractTargetCF(m)
                if cf and cf.Position.Magnitude > 10 then add(cf.Position) end
            end
        end
    end
    local function stop() return not alive_script or not alive() or not fullScanRunning end
    questItemRunning = true
    setHold(true)
    for i, p in ipairs(pts) do
        if stop() then break end
        setMsg(string.format("FULL SCAN: bay qua diem %d/%d de load map...", i, #pts))
        goTo(CFrame.new(p + Vector3.new(0, 60, 0)), false, stop)
        task.wait(0.9)
    end
    setHold(false)
    questItemRunning = false
    return #pts
end

function runFullScan(doTour)
    if fullScanRunning then setStatus("FULL SCAN dang chay...") return end
    fullScanRunning = true
    task.spawn(function()
        local function msg(s) setStatus(s) end
        local okAll, errAll = pcall(function()
            local info = {}
            info[#info + 1] = "FULL SCAN v7.1 | " .. os.date("%Y-%m-%d %H:%M:%S") .. " | PlaceId=" .. tostring(game.PlaceId) .. " | Sea=" .. getCurrentSea()
            info[#info + 1] = "StreamingEnabled=" .. tostring(workspace.StreamingEnabled)
            local root = hrp()
            info[#info + 1] = "Pos=" .. (root and posStr(root.Position) or "nil")

            local tourN = 0
            if doTour then tourN = fullScanTour(msg) end
            info[#info + 1] = "TourPoints=" .. tourN

            -- 1. Toan bo workspace
            msg("FULL SCAN: doc workspace...")
            local ws, prompts, clicks, npcs, spawns = {}, {}, {}, {}, {}
            local n = 0
            for _, d in ipairs(workspace:GetDescendants()) do
                n = n + 1
                if n % 4000 == 0 then task.wait() end
                local full = d:GetFullName()
                if not string.find(full, "Players.", 1, true) and not string.find(full, "BF_", 1, true) then
                    ws[#ws + 1] = instLine(d)
                    if d:IsA("ProximityPrompt") then prompts[#prompts + 1] = instLine(d)
                    elseif d:IsA("ClickDetector") then clicks[#clicks + 1] = d:GetFullName() end
                end
            end
            for _, folder in ipairs({ workspace:FindFirstChild("NPCs"), RS:FindFirstChild("NPCs") }) do
                if folder then
                    for _, m in ipairs(folder:GetChildren()) do npcs[#npcs + 1] = instLine(m) end
                end
            end
            local sf = spawnsFolder()
            if sf then
                for _, s in ipairs(sf:GetChildren()) do spawns[#spawns + 1] = instLine(s) end
            end
            info[#info + 1] = "WorkspaceInstances=" .. #ws

            -- 2. ReplicatedStorage
            msg("FULL SCAN: doc ReplicatedStorage...")
            local rsLines, remotes, modules = {}, {}, {}
            for _, d in ipairs(RS:GetDescendants()) do
                rsLines[#rsLines + 1] = instLine(d)
                if d:IsA("RemoteEvent") or d:IsA("RemoteFunction") then
                    remotes[#remotes + 1] = d.ClassName .. " " .. d:GetFullName()
                elseif d:IsA("ModuleScript") then
                    modules[#modules + 1] = d
                end
            end

            -- 3. Du lieu cac ModuleScript (Quests, ...)
            msg("FULL SCAN: require " .. #modules .. " module...")
            local modLines = {}
            for i, mod in ipairs(modules) do
                if i % 10 == 0 then task.wait() end
                local ok, res = pcall(require, mod)
                modLines[#modLines + 1] = "=== " .. mod:GetFullName() .. " ==="
                if ok then
                    modLines[#modLines + 1] = dumpTableStr(res, 0, nil, 4)
                else
                    modLines[#modLines + 1] = "(khong require duoc: " .. tostring(res) .. ")"
                end
            end

            -- 4. Remote game da goi + CommF log
            local logLines = {}
            logLines[#logLines + 1] = "--- CommF_ ---"
            for _, l in ipairs(commLog) do logLines[#logLines + 1] = l end
            logLines[#logLines + 1] = "--- Remote khac ---"
            for _, l in ipairs(otherRemoteLog) do logLines[#logLines + 1] = l end
            logLines[#logLines + 1] = "--- Script CommF_ calls ---"
            for _, l in ipairs(scriptCallLog) do logLines[#logLines + 1] = l end

            msg("FULL SCAN: ghi file BF_Scan/ ...")
            local fw = 0
            fw = fw + writeChunks("00_info", info)
            fw = fw + writeChunks("01_workspace_all", ws)
            fw = fw + writeChunks("02_prompts", prompts)
            fw = fw + writeChunks("03_clickdetectors", clicks)
            fw = fw + writeChunks("04_npcs", npcs)
            fw = fw + writeChunks("05_enemy_spawns", spawns)
            fw = fw + writeChunks("06_replicatedstorage_tree", rsLines)
            fw = fw + writeChunks("07_remotes", remotes)
            fw = fw + writeChunks("08_module_data", modLines, 8000)
            fw = fw + writeChunks("09_remote_logs", logLines)

            local summary = table.concat(info, "\n") .. string.format(
                "\nPrompts=%d NPCs=%d Spawns=%d RSInstances=%d Remotes=%d Modules=%d Files=%d",
                #prompts, #npcs, #spawns, #rsLines, #remotes, #modules, fw)
            pcall(function() if setclipboard then setclipboard(summary) end end)
            msg(string.format("FULL SCAN XONG: %d file trong thu muc BF_Scan/ (workspace %d obj)", fw, #ws))
            notifyBF("FULL SCAN xong! Gui cac file trong thu muc workspace/BF_Scan cua executor", Color3.fromRGB(90, 255, 120))
        end)
        if not okAll then
            setStatus("Loi FULL SCAN: " .. tostring(errAll))
            warn("[BF FullScan] " .. tostring(errAll))
        end
        setHold(false)
        questItemRunning = false
        fullScanRunning = false
    end)
end

copyFullScan = function()
    if not writefile then
        setStatus("Executor khong co writefile -> khong luu file duoc")
        return
    end
    runFullScan(true)
end

copyDebug = function()
    exportText(dump(), "BF_Debug_" .. tostring(game.PlaceId) .. ".txt", "Da copy Full Debug")
end

copyScan = function()
    setStatus("Dang quet NPC / object...")
    task.spawn(function()
        local ok, res = pcall(scanDataReport)
        if ok then
            exportText(res, "BF_Scan_" .. tostring(game.PlaceId) .. ".txt", "Da copy Scan Data")
        else
            setStatus("Loi scan: " .. tostring(res))
        end
    end)
end

------------------------------------------------------------------ combat & real hit VFX (NO fake mouse clicking)
equipWeapon = function()
    if questItemRunning or questItemHoldLock or isHoldingQuestTool() then return end
    local h = hum()
    if not h or not plr.Character then return end
    scanToolMastery()
    local wantTip = (CFG.AutoMelee and autoMeleeNeedsFarm) and "Melee" or CFG.Weapon
    local function hasToolTip(tool, tip)
        return tool:IsA("Tool") and tool.ToolTip == tip
    end

    if CFG.AutoMelee and autoMeleeNeedsFarm and masteryTargetTool then
        local equipped = plr.Character:FindFirstChild(masteryTargetTool)
        if equipped and equipped:IsA("Tool") and equipped.ToolTip == "Melee" then return end
        local backpackTool = plr.Backpack:FindFirstChild(masteryTargetTool)
        if backpackTool and backpackTool:IsA("Tool") and backpackTool.ToolTip == "Melee" then
            h:EquipTool(backpackTool)
            return
        end
    end

    for _, t in ipairs(plr.Character:GetChildren()) do
        if hasToolTip(t, wantTip) and (not masteryTargetTool or not CFG.AutoMelee) then return end
    end
    for _, t in ipairs(plr.Backpack:GetChildren()) do
        if hasToolTip(t, wantTip) and (not masteryTargetTool or not CFG.AutoMelee) then h:EquipTool(t) return end
    end
    for _, fallbackTip in ipairs({ "Melee", "Sword", "Blox Fruit", "Gun" }) do
        for _, t in ipairs(plr.Character:GetChildren()) do
            if hasToolTip(t, fallbackTip) then return end
        end
        for _, t in ipairs(plr.Backpack:GetChildren()) do
            if hasToolTip(t, fallbackTip) then h:EquipTool(t) return end
        end
    end
end

triggerSwingFull = function()
    triggerSwing(false)
end

local lastInstantHit = 0
local lastM1Anim = 0
track(RunService.Heartbeat:Connect(function()
    if questItemRunning or questItemHoldLock or isHoldingQuestTool() then return end
    local farming = isFarmActive()
    if not (alive_script and (farming or CFG.KillAura) and alive()) then return end
    local now = tick()
    if now - lastInstantHit < CFG.AttackDelay then return end

    local root = hrp()
    if not root then return end

    local tool = plr.Character and plr.Character:FindFirstChildOfClass("Tool")
    if not tool then
        equipWeapon()
        tool = plr.Character and plr.Character:FindFirstChildOfClass("Tool")
        if not tool then return end
    end

    local targets, head = {}, nil
    local myPos = root.Position
    local ef = enemiesFolder()

    if ef then
        if CFG.MultiAttack then
            for _, e in ipairs(ef:GetChildren()) do
                if aliveEnemy(e) then
                    local er = e:FindFirstChild("HumanoidRootPart")
                    if er and (er.Position - myPos).Magnitude <= CFG.HitRange then
                        local part = e:FindFirstChild("Head") or er
                        head = head or part
                        targets[#targets + 1] = { e, part }
                    end
                end
            end
        else
            local chosen = (farming and curTargetModel and aliveEnemy(curTargetModel)) and curTargetModel or nil
            if not chosen then
                local bestD
                for _, e in ipairs(ef:GetChildren()) do
                    if aliveEnemy(e) then
                        local er = e:FindFirstChild("HumanoidRootPart")
                        if er then
                            local d = (er.Position - myPos).Magnitude
                            if d <= CFG.HitRange and (not bestD or d < bestD) then
                                chosen, bestD = e, d
                            end
                        end
                    end
                end
            end
            if chosen then
                local er = chosen:FindFirstChild("HumanoidRootPart")
                if er and (er.Position - myPos).Magnitude <= CFG.HitRange then
                    local part = chosen:FindFirstChild("Head") or er
                    head = part
                    targets[1] = { chosen, part }
                end
            end
        end
    end

    if CFG.KillAura and CFG.KillAuraPlayers then
        local cf = charsFolder()
        if cf then
            for _, ch in ipairs(cf:GetChildren()) do
                if aliveTargetPlayer(ch) then
                    local cr = ch:FindFirstChild("HumanoidRootPart")
                    if cr and (cr.Position - myPos).Magnitude <= CFG.HitRange then
                        local part = ch:FindFirstChild("Head") or cr
                        head = head or part
                        targets[#targets + 1] = { ch, part }
                        if not CFG.MultiAttack then break end
                    end
                end
            end
        end
    end

    if head and #targets > 0 then
        lastInstantHit = now
        for _, pair in ipairs(targets) do
            markHitProgress(pair[1])
        end

        local ra, rh = getHitRemotes()
        if CFG.InstantHit and ra and rh then
            for _ = 1, CFG.HitBurst do
                pcall(function() ra:FireServer(0) end)
                pcall(function() rh:FireServer(head, targets) end)
            end
            if CFG.M1Effect and (now - lastM1Anim >= 0.16) then
                lastM1Anim = now
                playNativeSwingAnimation(tool)
            end
            if CFG.HitVFX then
                for i = 1, math.min(#targets, 6) do
                    spawnHitImpactVFX(targets[i][1], targets[i][2], tool)
                end
            end
        else
            if now - lastM1Anim >= 0.18 then
                lastM1Anim = now
                triggerSwing(false)
            end
            if ra and rh then
                pcall(function() ra:FireServer(0) end)
                pcall(function() rh:FireServer(head, targets) end)
            end
            if CFG.HitVFX then
                for i = 1, math.min(#targets, 4) do
                    spawnHitImpactVFX(targets[i][1], targets[i][2], tool)
                end
            end
        end
    end
end))

------------------------------------------------------------------ auto stats loop
task.spawn(function()
    local statMap = {
        { key = "StatMelee",   remote = "Melee" },
        { key = "StatDefense", remote = "Defense" },
        { key = "StatSword",   remote = "Sword" },
        { key = "StatGun",     remote = "Gun" },
        { key = "StatFruit",   remote = "Demon Fruit" },
    }
    while alive_script do
        task.wait(0.6)
        if CFG.AutoStats then
            pcall(function()
                local data = plr:FindFirstChild("Data")
                local ptsObj = data and data:FindFirstChild("Points")
                local pts = ptsObj and tonumber(ptsObj.Value) or 0
                if pts <= 0 then return end

                local r = getCommF()
                if not r then return end

                local activeStats = {}
                for _, st in ipairs(statMap) do
                    if CFG[st.key] then
                        activeStats[#activeStats + 1] = st.remote
                    end
                end
                if #activeStats == 0 then return end

                for _, statName in ipairs(activeStats) do
                    if not CFG.AutoStats or not alive_script then break end
                    pts = ptsObj and tonumber(ptsObj.Value) or 0
                    if pts <= 0 then break end
                    local addAmt = math.min(CFG.StatAmount, pts)
                    if addAmt > 0 then
                        invokeRet(r, "AddPoint", statName, addAmt)
                        task.wait(0.15)
                    end
                end
            end)
        end
    end
end)

------------------------------------------------------------------ quest & item engine
function hasOwnedItem(r, names)
    local invCounts = getInventoryCounts(r)
    for _, want in ipairs(names) do
        local wantLow = string.lower(want)
        for k, cnt in pairs(invCounts) do
            local kLow = string.lower(tostring(k))
            if tonumber(cnt) and tonumber(cnt) > 0 and kLow == wantLow then
                return true, k
            end
        end
        for _, container in ipairs({ plr.Backpack, plr.Character }) do
            if container then
                for _, t in ipairs(container:GetChildren()) do
                    if t:IsA("Tool") and string.lower(t.Name) == wantLow then
                        return true, t.Name
                    end
                end
            end
        end
    end
    return false, nil
end

function equipToolByName(name)
    local h = hum()
    if not (h and plr.Character) then return false end
    local wantLow = string.lower(name)
    for _, t in ipairs(plr.Character:GetChildren()) do
        if t:IsA("Tool") and string.find(string.lower(t.Name), wantLow, 1, true) then return true end
    end
    for _, t in ipairs(plr.Backpack:GetChildren()) do
        if t:IsA("Tool") and string.find(string.lower(t.Name), wantLow, 1, true) then
            h:EquipTool(t)
            task.wait(0.2)
            return true
        end
    end
    return false
end

function touchPartSafe(part, interruptFn, holdSec)
    if not (part and part:IsA("BasePart") and part.Parent) then return false end
    local root = hrp()
    if not root then return false end
    if not goTo(part.CFrame * CFrame.new(0, 1.2, 0), false, interruptFn) then return false end
    if not alive_script or (interruptFn and interruptFn()) then return false end
    local tEnd = tick() + (holdSec or 0.25)
    while tick() < tEnd and alive_script and not (interruptFn and interruptFn()) and part.Parent do
        root = hrp()
        if not root then return false end
        if firetouchinterest then
            pcall(function()
                firetouchinterest(root, part, 0)
                task.wait(0.08)
                firetouchinterest(root, part, 1)
            end)
        else
            root.CFrame = part.CFrame
        end
        task.wait(0.1)
    end
    return true
end

function getEquippedToolByName(name)
    local ch = plr.Character
    if not ch then return nil end
    local wantLow = string.lower(name)
    for _, t in ipairs(ch:GetChildren()) do
        if t:IsA("Tool") and string.find(string.lower(t.Name), wantLow, 1, true) then
            return t
        end
    end
    return nil
end

function isCupFilled(cupTool)
    if not cupTool then return false end
    for _, attr in ipairs({ "Filled", "HasWater", "Water", "Full" }) do
        local av = cupTool:GetAttribute(attr)
        if av == true or av == 1 then return true end
        local childVal = cupTool:FindFirstChild(attr)
        if childVal and childVal:IsA("ValueBase") and (childVal.Value == true or childVal.Value == 1) then
            return true
        end
    end
    for _, d in ipairs(cupTool:GetDescendants()) do
        if d:IsA("BasePart") and d.Name ~= "Handle" then
            local n = string.lower(d.Name)
            if string.find(n, "water", 1, true) or string.find(n, "liquid", 1, true)
                or string.find(n, "fill", 1, true) or string.find(n, "drink", 1, true) then
                if d.Transparency < 0.9 then
                    return true
                end
            end
        end
    end
    for _, d in ipairs(cupTool:GetDescendants()) do
        if d:IsA("ParticleEmitter") and d.Enabled then
            return true
        end
    end
    return false
end

function findNpcByNames(names)
    local containers = { workspace:FindFirstChild("NPCs"), RS:FindFirstChild("NPCs"), workspace }
    for _, folder in ipairs(containers) do
        if folder then
            for _, nName in ipairs(names) do
                local npc = folder:FindFirstChild(nName, folder == workspace)
                local cf = extractTargetCF(npc)
                if cf and cf.Position.Magnitude > 10 then
                    return cf * CFrame.new(0, 0, 3), npc
                end
            end
        end
    end
    return nil, nil
end

------------------------------------------------------------------ v7.1: VUNG NUOC + NGON BANG (Saber v1 buoc 3)
-- Toa do vung nuoc thuc te (lay tu debug cua ban): (1397.6, 23.6, -1382.2)
POOL_POS = Vector3.new(1397.6, 23.6, -1382.2)
icicleCache = nil

-- Tim "ngon bang" treo tren vung nuoc: part bang/nhon nam phia tren, gan vung nuoc theo mat phang ngang
function findIcicleTip()
    if icicleCache and icicleCache.Parent then return icicleCache end
    local best, bestScore
    for _, d in ipairs(workspace:GetDescendants()) do
        if d:IsA("BasePart") and d.Position.Y > POOL_POS.Y + 3 and d.Position.Y < POOL_POS.Y + 120 then
            local horiz = Vector3.new(d.Position.X - POOL_POS.X, 0, d.Position.Z - POOL_POS.Z).Magnitude
            if horiz <= 55 then
                local n = string.lower(d.Name)
                local iceMat = d.Material == Enum.Material.Ice or d.Material == Enum.Material.Glacier
                local iceName = string.find(n, "ice", 1, true) or string.find(n, "icicle", 1, true)
                    or string.find(n, "spike", 1, true) or string.find(n, "stalac", 1, true)
                    or string.find(n, "drip", 1, true) or string.find(n, "drop", 1, true)
                local longThin = d.Size.Y > math.max(d.Size.X, d.Size.Z) * 1.2
                if iceMat or iceName then
                    -- uu tien: gan ngang, la hinh dai (nhon), nam cao hon mat nuoc vua phai
                    local score = horiz + (longThin and -12 or 0) + math.abs((d.Position.Y - POOL_POS.Y) - 14) * 0.35
                    if not bestScore or score < bestScore then
                        best, bestScore = d, score
                    end
                end
            end
        end
    end
    icicleCache = best
    return best
end

-- Diem cham: day (mui nhon) cua ngon bang
function icicleTouchCF(tip)
    if tip then
        local bottomY = tip.Position.Y - tip.Size.Y / 2
        return CFrame.new(tip.Position.X, bottomY + 0.6, tip.Position.Z), tip
    end
    return CFrame.new(POOL_POS + Vector3.new(0, 10, 0)), nil
end

function findDesertBurnPart()
    local map = workspace:FindFirstChild("Map")
    if not map then return nil end
    local desert = map:FindFirstChild("Desert")
    if desert then
        local burn = desert:FindFirstChild("Burn", true)
        if burn then
            local f = burn:FindFirstChild("Fire") or burn:FindFirstChildWhichIsA("BasePart", true)
            if f then return f end
        end
    end
    return nil
end

function getBountyHonor()
    local val = 0
    pcall(function()
        local ls = plr:FindFirstChild("leaderstats")
        local b = ls and (ls:FindFirstChild("Bounty/Honor") or ls:FindFirstChild("Bounty"))
        if b then val = tonumber(b.Value) or 0 end
    end)
    if val == 0 then
        pcall(function()
            local d = plr:FindFirstChild("Data")
            local b = d and (d:FindFirstChild("Bounty") or d:FindFirstChild("Honor"))
            if b then val = tonumber(b.Value) or 0 end
        end)
    end
    return val
end

------------------------------------------------------------------ v7.1: MOB LEADER (tim dong, tuan tra, khong dung im)
-- Diem du phong (toa do Sea 1 cu). Update 30 da doi map -> uu tien tim DONG truoc.
MOB_LEADER_PATROL = {
    Vector3.new(-2850, 14, 5350),
    Vector3.new(-1100, 14, 3900),
    Vector3.new(-1612, 37, 150),
    Vector3.new(1397, 40, -1382),
    Vector3.new(-2000, 30, -300),
}

function findMobLeaderCF()
    -- 1. Enemies / ReplicatedStorage (boss da load)
    local ef = enemiesFolder()
    if ef then
        for _, e in ipairs(ef:GetChildren()) do
            if matchMobName(e.Name, "Mob Leader") and e:FindFirstChild("HumanoidRootPart") then
                return e.HumanoidRootPart.CFrame, "Enemies"
            end
        end
    end
    for _, e in ipairs(RS:GetChildren()) do
        if e:IsA("Model") and matchMobName(e.Name, "Mob Leader") and e:FindFirstChild("HumanoidRootPart") then
            return e.HumanoidRootPart.CFrame, "ReplicatedStorage"
        end
    end
    -- 2. EnemySpawns
    local pts = spawnPoints("Mob Leader")
    if #pts > 0 then return pts[1], "EnemySpawns" end
    -- 3. Quet workspace (model ten Mob Leader o bat ky cho nao)
    for _, d in ipairs(workspace:GetDescendants()) do
        if d:IsA("Model") and matchMobName(d.Name, "Mob Leader") then
            local cf = extractTargetCF(d)
            if cf then return cf, "workspace" end
        end
    end
    return nil, nil
end

function patrolForMobLeader(stopIfOff)
    questItemRunning = true
    setHold(true)
    local cf, src = findMobLeaderCF()
    local target
    if cf then
        target = cf * CFrame.new(0, 14, 0)
        setStatus("Saber v1 [4/6]: Thấy Mob Leader (" .. tostring(src) .. "), đang bay tới...")
    else
        if mobLeaderPatrolIdx > #MOB_LEADER_PATROL then mobLeaderPatrolIdx = 1 end
        target = CFrame.new(MOB_LEADER_PATROL[mobLeaderPatrolIdx])
        setStatus(string.format("Saber v1 [4/6]: Tuần tra tìm Mob Leader (%d/%d)...", mobLeaderPatrolIdx, #MOB_LEADER_PATROL))
    end
    local arrived = goTo(target, false, stopIfOff)
    if arrived and not stopIfOff() then
        -- doi map stream vao, quet lien tuc ~5s; thay boss thi dung lai danh
        local t0 = tick()
        while tick() - t0 < 5 and not stopIfOff() do
            if hasAliveBoss("Mob Leader") or hasAliveMob("Mob Leader") then
                setHold(false)
                questItemRunning = false
                return true
            end
            local cf2 = findMobLeaderCF()
            if cf2 and (not cf or (cf2.Position - target.Position).Magnitude > 60) then
                break -- vua stream ra boss o cho khac -> lap lai de bay toi
            end
            task.wait(0.3)
        end
        if not cf then
            mobLeaderPatrolIdx = (mobLeaderPatrolIdx % #MOB_LEADER_PATROL) + 1
        end
    end
    setHold(false)
    questItemRunning = false
    return false
end

local function runSaberV1Step(r)
    local function stopIfOff()
        return not CFG.AutoSaberV1 or not alive_script or not alive()
    end

    if hasOwnedItem(r, { "Saber" }) then
        CFG.AutoSaberV1 = false
        questItemHoldLock = false
        questItemRunning = false
        questItemBossName, questItemBossTag = nil, nil
        if saberV1Paint then saberV1Paint() end
        local msg = "Đã sở hữu Saber v1!"
        setStatus(msg)
        notifyBF(msg, Color3.fromRGB(90, 255, 120))
        return
    end

    if getCurrentSea() ~= 1 then
        questItemHoldLock = false
        questItemBossName, questItemBossTag = nil, nil
        setStatus("IDLE [Saber v1]: Chỉ làm được ở Sea 1")
        return
    end
    if getLevel() < 200 then
        questItemHoldLock = false
        questItemBossName, questItemBossTag = nil, nil
        setStatus("IDLE [Saber v1]: Cần Lv.200+ (hiện Lv." .. getLevel() .. ")")
        return
    end

    local prog = invokeRet(r, "ProQuestProgress")
    if type(prog) ~= "table" then prog = {} end

    if prog.UsedRelic then
        questItemHoldLock = false
        if hasAliveBoss("Saber Expert") then
            questItemBossName = "Saber Expert"
            questItemBossTag = "Auto Saber v1"
            setStatus("Saber v1 [6/6]: Đang đánh Boss Saber Expert!")
        else
            questItemBossName, questItemBossTag = nil, nil
            setStatus("IDLE [Saber v1]: Đã mở cửa đền, chờ Boss Saber Expert spawn...")
        end
        return
    end

    questItemHoldLock = true
    questItemBossName, questItemBossTag = nil, nil
    stopMoving()

    -- 1. Bam 5 nut xanh o Jungle
    local needPlates = false
    if type(prog.Plates) == "table" then
        local pressed = 0
        for _, v in pairs(prog.Plates) do if v then pressed = pressed + 1 end end
        if pressed < 5 then needPlates = true end
    elseif not prog.UsedTorch then
        needPlates = true
    end

    if needPlates then
        local jungleCF = CFrame.new(-1612, 37, 150)
        local map = workspace:FindFirstChild("Map")
        local jungle = map and map:FindFirstChild("Jungle")
        local plates = jungle and jungle:FindFirstChild("QuestPlates")

        local loadedBtns = {}
        if plates then
            for i = 1, 5 do
                local plate = plates:FindFirstChild("Plate" .. i)
                local btn = plate and (plate:FindFirstChild("Button") or plate:FindFirstChildWhichIsA("BasePart"))
                if btn then loadedBtns[i] = btn end
            end
        end

        local loadedCount = 0
        for _ in pairs(loadedBtns) do loadedCount = loadedCount + 1 end

        questItemRunning = true
        setHold(true)
        if loadedCount < 5 or (hrp() and (hrp().Position - jungleCF.Position).Magnitude > 450) then
            setStatus("Saber v1 [1/6]: Bay tới Jungle load 5 nút bấm...")
            goTo(jungleCF, false, stopIfOff)
            task.wait(0.5)
            setHold(false)
            questItemRunning = false
            return
        end

        for i = 1, 5 do
            if stopIfOff() then break end
            local btn = loadedBtns[i]
            local isGreen = btn and (btn.Color.G > 0.55 and btn.Color.G > btn.Color.R + 0.2)
            if btn and not isGreen then
                setStatus("Saber v1 [1/6]: Bấm nút Jungle " .. i .. "/5...")
                touchPartSafe(btn, stopIfOff, 0.35)
                task.wait(0.25)
            end
        end
        setHold(false)
        questItemRunning = false
        return
    end

    -- 2. Lay Duoc (Torch) -> Dot cua sa mac
    if not prog.UsedTorch then
        questItemRunning = true
        setHold(true)

        if not equipToolByName("Torch") then
            setStatus("Saber v1 [2/6]: Bay tới Jungle lấy Đuốc (Torch)...")
            goTo(CFrame.new(-1610, 12, 163), false, stopIfOff)
            if stopIfOff() then setHold(false); questItemRunning = false; return end
            task.wait(0.4)
            local map = workspace:FindFirstChild("Map")
            local torchObj = map and map:FindFirstChild("Jungle") and map.Jungle:FindFirstChild("Torch", true)
            if torchObj and torchObj:IsA("BasePart") then
                touchPartSafe(torchObj, stopIfOff, 0.5)
            end
            task.wait(0.4)
        end

        if not stopIfOff() and equipToolByName("Torch") then
            setStatus("Saber v1 [2/6]: Bay tới nhà sa mạc đốt cửa...")
            local burnPart = findDesertBurnPart()
            local desertHouseCF = burnPart and (burnPart.CFrame * CFrame.new(0, 0, 2)) or CFrame.new(1114, 5, 4350)
            goTo(desertHouseCF, false, stopIfOff)
            if stopIfOff() then setHold(false); questItemRunning = false; return end
            task.wait(0.4)

            burnPart = findDesertBurnPart()
            if burnPart then
                setStatus("Saber v1 [2/6]: Đang giữ Đuốc đốt cửa (chờ cửa cháy hết)...")
                local tBurn = tick()
                while tick() - tBurn < 7 and not stopIfOff() do
                    equipToolByName("Torch")
                    local rRoot = hrp()
                    if rRoot and burnPart.Parent then
                        rRoot.CFrame = burnPart.CFrame * CFrame.new(0, 0, 1.5)
                        rRoot.AssemblyLinearVelocity = Vector3.zero
                        if firetouchinterest then
                            pcall(function()
                                firetouchinterest(rRoot, burnPart, 0)
                                task.wait(0.08)
                                firetouchinterest(rRoot, burnPart, 1)
                            end)
                        end
                    end
                    task.wait(0.35)
                    local checkP = invokeRet(r, "ProQuestProgress")
                    if type(checkP) == "table" and checkP.UsedTorch then
                        break
                    end
                    if not burnPart.Parent or burnPart.Transparency >= 0.95 then
                        break
                    end
                end
            else
                setStatus("Saber v1 [2/6]: Đang đứng sát cửa nhà sa mạc chờ load Burn...")
                task.wait(1.0)
            end
        end

        setHold(false)
        questItemRunning = false
        return
    end

    -- 3. Nhat Coc -> Hung nuoc o NGON BANG dao Tuyet -> Dua Sick Man  (v7.1 viet lai)
    if not prog.UsedCup then
        questItemRunning = true
        setHold(true)

        if not equipToolByName("Cup") then
            cupFilledFlag = false
            setStatus("Saber v1 [3/6]: Bay tới nhà sa mạc nhặt Cốc (Cup)...")
            goTo(CFrame.new(1113, 5, 4365), false, stopIfOff)
            if stopIfOff() then setHold(false); questItemRunning = false; return end
            task.wait(0.5)
            local map = workspace:FindFirstChild("Map")
            local cupObj = map and map:FindFirstChild("Desert") and map.Desert:FindFirstChild("Cup", true)
            if cupObj and cupObj:IsA("BasePart") then
                touchPartSafe(cupObj, stopIfOff, 0.5)
            end
            task.wait(0.4)
            if not equipToolByName("Cup") then
                setHold(false)
                questItemRunning = false
                return
            end
        end

        local cupTool = getEquippedToolByName("Cup")

        if cupTool and not cupFilledFlag and not isCupFilled(cupTool) then
            -- 3a. Bay toi dao Tuyet / vung nuoc
            if hrp() and (hrp().Position - POOL_POS).Magnitude > 120 then
                setStatus("Saber v1 [3/6]: Bay tới vũng nước hang đảo Tuyết...")
                goTo(CFrame.new(POOL_POS + Vector3.new(0, 14, 0)), false, stopIfOff)
                if stopIfOff() then setHold(false); questItemRunning = false; return end
                task.wait(0.6)
            end

            -- 3b. Tim ngon bang va bay toi mui nhon
            local tip = findIcicleTip()
            local touchCF, tipPart = icicleTouchCF(tip)
            setStatus(tip and ("Saber v1 [3/6]: Bay tới ngọn băng (" .. tip.Name .. ")...")
                or "Saber v1 [3/6]: Chưa thấy ngọn băng, đứng giữa vũng nước hứng...")
            goTo(touchCF, false, stopIfOff)
            if stopIfOff() then setHold(false); questItemRunning = false; return end

            -- 3c. Chạm ngọn băng + Activate Cup + goi FillCup voi dung Cup (Tool)
            local tFill = tick()
            local filled = false
            local jitter = {
                Vector3.new(0, 0, 0), Vector3.new(0, -1.2, 0), Vector3.new(1.5, 0, 0),
                Vector3.new(-1.5, 0, 0), Vector3.new(0, 0, 1.5), Vector3.new(0, 0, -1.5),
            }
            local attempt = 0
            while tick() - tFill < 14 and not stopIfOff() do
                equipToolByName("Cup")
                cupTool = getEquippedToolByName("Cup")
                if not cupTool then break end

                local rRoot = hrp()
                if rRoot then
                    attempt = attempt + 1
                    local off = jitter[(attempt - 1) % #jitter + 1]
                    rRoot.CFrame = touchCF * CFrame.new(off)
                    rRoot.AssemblyLinearVelocity = Vector3.zero
                    if tipPart and tipPart.Parent and firetouchinterest then
                        pcall(function()
                            firetouchinterest(rRoot, tipPart, 0)
                            task.wait(0.05)
                            firetouchinterest(rRoot, tipPart, 1)
                        end)
                    end
                end

                pcall(function() cupTool:Activate() end)

                -- FIX: truyen Cup (Tool) -> khong con "attempt to index nil with 'Name'"
                local ret = invokeRet(r, "ProQuestProgress", "FillCup", cupTool)
                if not isErrRet(ret) then
                    cupFilledFlag = true
                    filled = true
                    break
                end
                if isCupFilled(cupTool) then
                    cupFilledFlag = true
                    filled = true
                    break
                end
                task.wait(0.45)
            end

            if not filled then
                setStatus("Saber v1 [3/6]: Chưa hứng được nước. Bấm Scan Data đứng cạnh ngọn băng rồi gửi log!")
                setHold(false)
                questItemRunning = false
                return
            end
        end

        -- 3d. Dua Sick Man
        if not stopIfOff() and equipToolByName("Cup") then
            setStatus("Saber v1 [3/6]: Cốc ĐÃ CÓ NƯỚC! Đang bay lên đưa cho Sick Man...")
            local sickCF = select(1, findNpcByNames({ "Sick Man" })) or CFrame.new(1458, 88, -1389)
            goTo(sickCF, false, stopIfOff)
            if stopIfOff() then setHold(false); questItemRunning = false; return end
            task.wait(0.4)
            invokeRet(r, "ProQuestProgress", "SickMan")
            task.wait(0.6)
            local after = invokeRet(r, "ProQuestProgress")
            if not (type(after) == "table" and after.UsedCup) then
                -- Sick Man khong nhan -> coi nhu Coc chua day, hung lai o vong sau
                cupFilledFlag = false
                setStatus("Saber v1 [3/6]: Sick Man chưa nhận Cốc -> hứng lại nước ở ngọn băng...")
            else
                cupFilledFlag = false
            end
        end

        setHold(false)
        questItemRunning = false
        return
    end

    -- 4. Rich Man -> Mob Leader (v7.1: tim dong + tuan tra)
    if not prog.KilledMob then
        if not prog.TalkedSon then
            questItemRunning = true
            setHold(true)
            setStatus("Saber v1 [4/6]: Tới Pirate Village gặp Rich Man...")
            local richCF = select(1, findNpcByNames({ "Rich Man" })) or CFrame.new(-910, 14, 4077)
            goTo(richCF, false, stopIfOff)
            if stopIfOff() then setHold(false); questItemRunning = false; return end
            task.wait(0.35)
            invokeRet(r, "ProQuestProgress", "RichSon")
            task.wait(0.4)
            setHold(false)
            questItemRunning = false
            return
        end
        if hasAliveBoss("Mob Leader") or hasAliveMob("Mob Leader") then
            questItemHoldLock = false
            questItemBossName = "Mob Leader"
            questItemBossTag = "Auto Saber v1"
            setStatus("Saber v1 [4/6]: Đang hạ Mob Leader...")
            return
        else
            patrolForMobLeader(stopIfOff)
            return
        end
    end

    -- 5. Lay Relic -> Mo cua Jungle
    if not prog.UsedRelic then
        questItemRunning = true
        setHold(true)
        if not equipToolByName("Relic") then
            setStatus("Saber v1 [5/6]: Quay lại Rich Man nhận Relic...")
            local richCF = select(1, findNpcByNames({ "Rich Man" })) or CFrame.new(-910, 14, 4077)
            goTo(richCF, false, stopIfOff)
            if stopIfOff() then setHold(false); questItemRunning = false; return end
            task.wait(0.35)
            invokeRet(r, "ProQuestProgress", "RichSon")
            task.wait(0.5)
        end
        if not stopIfOff() and equipToolByName("Relic") then
            setStatus("Saber v1 [5/6]: Bay về Jungle mở cửa đền Saber Expert...")
            local doorCF = CFrame.new(-1406, 30, 4)
            goTo(doorCF, false, stopIfOff)
            if stopIfOff() then setHold(false); questItemRunning = false; return end
            local map = workspace:FindFirstChild("Map")
            local relicLock = map and map:FindFirstChild("Jungle") and map.Jungle:FindFirstChild("Relic", true)
            local tOpen = tick()
            while tick() - tOpen < 4 and not stopIfOff() do
                equipToolByName("Relic")
                if relicLock and relicLock:IsA("BasePart") then
                    touchPartSafe(relicLock, stopIfOff, 0.4)
                else
                    task.wait(0.4)
                end
                local checkP = invokeRet(r, "ProQuestProgress")
                if type(checkP) == "table" and checkP.UsedRelic then break end
            end
        end
        setHold(false)
        questItemRunning = false
        return
    end
end

function runSaberV2Step(r)
    questItemHoldLock = false
    if not hasOwnedItem(r, { "Saber" }) then
        questItemBossName, questItemBossTag = nil, nil
        setStatus("IDLE [Saber v2]: Chưa có Saber v1! Hãy bật Auto Saber v1 trước.")
        return
    end

    local bounty = getBountyHonor()
    if bounty < 1000000 then
        local bosses = getServerBosses()
        if #bosses > 0 then
            questItemBossName = bosses[1]
            questItemBossTag = "Auto Saber v2"
            setStatus(string.format("Auto Saber v2: Farm Boss %s kiếm 1M Bounty (%s/1,000,000)", bosses[1], fmtNum(bounty)))
        else
            questItemBossName, questItemBossTag = nil, nil
            setStatus(string.format("IDLE [Saber v2]: Thiếu %s Bounty (hiện %s/1M), chờ Boss spawn...", fmtNum(1000000 - bounty), fmtNum(bounty)))
        end
    else
        questItemBossName, questItemBossTag = nil, nil
        equipToolByName("Saber")
        setStatus(string.format("IDLE [Saber v2]: Đã đủ 1M+ Bounty (%s)! Cần hạ 1 player cùng tầm Lv để kích hoạt Saber v2.", fmtNum(bounty)))
    end
end

function runSimpleBossItemStep(r, cfgKey, paintFn, itemNames, itemLabel, reqSea, reqLv, bossName, areaCF, areaName)
    questItemHoldLock = false
    if hasOwnedItem(r, itemNames) then
        CFG[cfgKey] = false
        questItemBossName, questItemBossTag = nil, nil
        if paintFn then paintFn() end
        local msg = "Đã sở hữu " .. itemLabel .. "!"
        setStatus(msg)
        notifyBF(msg, Color3.fromRGB(90, 255, 120))
        return
    end

    if getCurrentSea() ~= reqSea then
        questItemBossName, questItemBossTag = nil, nil
        setStatus("IDLE [" .. itemLabel .. "]: Chỉ lấy được ở Sea " .. reqSea .. " (" .. bossName .. ")")
        return
    end
    if reqLv and getLevel() < reqLv then
        questItemBossName, questItemBossTag = nil, nil
        setStatus("IDLE [" .. itemLabel .. "]: Cần Lv." .. reqLv .. "+ (hiện Lv." .. getLevel() .. ")")
        return
    end

    if hasAliveBoss(bossName) then
        questItemBossName = bossName
        questItemBossTag = "Auto " .. itemLabel
        setStatus("Auto " .. itemLabel .. ": Đang đánh Boss " .. bossName .. "!")
    else
        questItemBossName, questItemBossTag = nil, nil
        if areaCF and hrp() and (hrp().Position - areaCF.Position).Magnitude > 900 then
            questItemRunning = true
            setHold(true)
            setStatus("Auto " .. itemLabel .. ": Bay tới " .. areaName .. " kiểm tra Boss " .. bossName .. "...")
            goTo(areaCF, false, function() return not CFG[cfgKey] or not alive_script end)
            task.wait(0.8)
            setHold(false)
            questItemRunning = false
            if hasAliveBoss(bossName) then
                questItemBossName = bossName
                questItemBossTag = "Auto " .. itemLabel
                return
            end
        end
        setStatus("IDLE [" .. itemLabel .. "]: Chờ Boss " .. bossName .. " spawn tại " .. areaName .. "...")
    end
end

task.spawn(function()
    local lastQI = 0
    while alive_script do
        task.wait(0.35)
        local anyQI = CFG.AutoSaberV1 or CFG.AutoSaberV2 or CFG.AutoSwanGlasses or CFG.AutoWardenSword or CFG.AutoPoleV1
        if anyQI and alive() and not isBuyingNpc and not isElectroQuestRunning and not questItemRunning then
            local now = tick()
            if now - lastQI >= 1.2 then
                lastQI = now
                local ok, err = pcall(function()
                    local r = getCommF()
                    if not r then
                        setStatus("Loi Quest/Item: khong thay CommF_")
                        return
                    end
                    if CFG.AutoSaberV1 then
                        runSaberV1Step(r)
                    elseif CFG.AutoSaberV2 then
                        runSaberV2Step(r)
                    elseif CFG.AutoSwanGlasses then
                        runSimpleBossItemStep(r, "AutoSwanGlasses", swanGlassesPaint,
                            { "Swan Glasses" }, "Kinh Don Swan", 2, 1000, "Don Swan",
                            CFrame.new(2288, 15, 905), "Mansion (Sea 2)")
                    elseif CFG.AutoWardenSword then
                        runSimpleBossItemStep(r, "AutoWardenSword", wardenSwordPaint,
                            { "Warden's Sword", "Wardens Sword" }, "Kiem Warden", 1, 1, "Chief Warden",
                            CFrame.new(5200, 38, 4740), "Prison (Sea 1)")
                    elseif CFG.AutoPoleV1 then
                        runSimpleBossItemStep(r, "AutoPoleV1", poleV1Paint,
                            { "Pole (1st Form)", "Pole (2nd Form)" }, "Pole v1", 1, 1, "Thunder God",
                            CFrame.new(-7895, 5547, -380), "Upper Skylands (Sea 1)")
                    end
                end)
                if not ok then
                    questItemRunning = false
                    questItemHoldLock = false
                    setHold(false)
                    setStatus("Loi Quest/Item: " .. tostring(err))
                    warn("[BF Quest/Item] " .. tostring(err))
                end
            end
        elseif not anyQI then
            questItemBossName, questItemBossTag = nil, nil
            questItemRunning = false
            questItemHoldLock = false
            lastQI = 0
        end
    end
end)

local lastSimSet = 0
local BRING_RADIUS_MULT = 2
local function bringMobs(mob, pos)
    local ef = enemiesFolder()
    if not ef then return 0 end
    local now = tick()
    if now - lastSimSet >= 0.35 then
        lastSimSet = now
        pcall(function()
            if sethiddenproperty then sethiddenproperty(plr, "SimulationRadius", math.huge) end
        end)
    end
    local effectiveRadius = CFG.BringRadius * BRING_RADIUS_MULT
    local targetCF = CFrame.new(pos)
    local grouped = 0
    for _, e in ipairs(ef:GetChildren()) do
        if (mob == nil or matchMobName(e.Name, mob)) and aliveEnemy(e) then
            local er = e:FindFirstChild("HumanoidRootPart")
            if er and (er.Position - pos).Magnitude <= effectiveRadius then
                grouped = grouped + 1
                er.CFrame = targetCF
                er.AssemblyLinearVelocity = Vector3.zero
                er.AssemblyAngularVelocity = Vector3.zero
                er.CanCollide = false
                local eh = e:FindFirstChildOfClass("Humanoid")
                if eh then
                    eh.WalkSpeed = 0
                    eh.JumpPower = 0
                end
            end
        end
    end
    return grouped
end

------------------------------------------------------------------ vong lap chinh
local lastStartT, lastPickT, failStreak = 0, 0, 0
local patrolMobName = nil
local patrolIdx = 1
local patrolCamps = {}
local lastCampRefresh = 0

resetQuest = function()
    current, lastStartT, lastPickT, failStreak = nil, 0, 0, 0
    cupFilledFlag = false
    mobLeaderPatrolIdx = 1
    icicleCache = nil
    if questActive(true) then abandonQuest() end
    setStatus("da reset quest")
end

local sessionStartLv = nil

local function decideMob()
    if CFG.AutoBoss and CFG.SelectedBoss ~= "" and hasAliveBoss(CFG.SelectedBoss) then
        return CFG.SelectedBoss, "Select Boss", false
    end
    if questItemBossName and hasAliveBoss(questItemBossName) then
        return questItemBossName, questItemBossTag or "Quest & Item Boss", false
    end
    if priorityBossName and hasAliveBoss(priorityBossName) then
        return priorityBossName, "Auto Melee Boss", false
    end
    local lvl = getLevel()
    if not sessionStartLv then sessionStartLv = lvl end
    local why
    if not Quests then
        why = "khong doc duoc bang Quests"
    else
        local active = questActive(true)
        if not current then
            local q = pickQuest(lvl)
            if q then
                if active and not questTextHas(q.mob) then
                    abandonQuest()
                    task.wait(0.2)
                    active = questActive(true)
                end
                current = q
            else
                why = "khong tim thay quest hop Lv " .. lvl
            end
        elseif not active and tick() - lastPickT > 0.35 then
            lastPickT = tick()
            local q = pickQuest(lvl)
            if q then current = q end
        end
        if current then
            if not active then
                local interval = failStreak >= 3 and 12 or (failStreak == 0 and 0.4 or 2.5)
                if tick() - lastStartT >= interval then
                    lastStartT = tick()
                    setStatus("Nhan nhanh quest " .. current.name .. " [" .. tostring(current.index) .. "]")
                    if startQuest(current) then failStreak = 0 else failStreak = failStreak + 1 end
                    active = questActive(true)
                end
            end
            if active then failStreak = 0 end
            local gained = math.max(0, lvl - (sessionStartLv or lvl))
            local tag = string.format("Q:%s[%s]%s", current.name, tostring(current.index), gained > 0 and (" +" .. gained .. "Lv") or "")
            if not active then tag = tag .. " | cho quest" end
            return current.mob, tag, true
        end
    end
    local root = hrp()
    local m, d = mobByLevel(lvl, root and root.Position or Vector3.new())
    return m, (why and (why .. " -> ") or "") .. tostring(d), false
end

task.spawn(function()
    while alive_script do
        task.wait(0.03)
        if isFarmActive() and alive() and not isElectroQuestRunning then
            local ok, err = pcall(function()
                local mob, src, isQuestMode = decideMob()
                if not mob then
                    setStatus("Lv " .. getLevel() .. ": khong thay mob nao quanh day.")
                    task.wait(0.6)
                    return
                end
                setHold(true)
                equipWeapon()
                ensureBusoHaki()
                local root = hrp()
                if not root then return end

                if patrolMobName ~= mob or #patrolCamps == 0 or (tick() - lastCampRefresh > 15) then
                    if patrolMobName ~= mob then
                        patrolMobName = mob
                        patrolIdx = 1
                    end
                    patrolCamps = getMobCamps(mob)
                    lastCampRefresh = tick()
                    if patrolIdx > #patrolCamps then patrolIdx = 1 end
                end

                local target, clusterPos, clusterCnt = bestClusterEnemy(mob, root.Position)
                if not target then
                    local rsMob = nearestEnemy(mob, root.Position, true)
                    if rsMob and rsMob.Parent == RS and rsMob:FindFirstChild("HumanoidRootPart") then
                        local hFly = CFG.InstantHit and CFG.FarHeight or CFG.FlyHeight
                        setStatus("Bay toi " .. mob .. " (load map)")
                        goTo(rsMob.HumanoidRootPart.CFrame * CFrame.new(0, hFly, 0), false, function()
                            return nearestEnemy(mob, hrp() and hrp().Position or Vector3.zero, false) ~= nil
                        end)
                        task.wait(0.2)
                        return
                    end

                    if #patrolCamps > 0 then
                        if patrolIdx < 1 or patrolIdx > #patrolCamps then patrolIdx = 1 end
                        local campCF = patrolCamps[patrolIdx]
                        local curCamp = patrolIdx
                        local totalCamps = #patrolCamps
                        local hFly = CFG.InstantHit and CFG.FarHeight or CFG.FlyHeight

                        setStatus(string.format("Quet bai %d/%d | %s", curCamp, totalCamps, mob))
                        goTo(campCF * CFrame.new(0, hFly, 0), false, function()
                            return nearestEnemy(mob, hrp() and hrp().Position or Vector3.zero, false) ~= nil
                        end)

                        local waitSec = (totalCamps > 1) and 0.45 or 1.0
                        local t1 = tick()
                        while alive_script and isFarmActive() and alive() and (tick() - t1 < waitSec) do
                            local rNow = hrp()
                            if rNow and nearestEnemy(mob, rNow.Position, false) then
                                break
                            end
                            task.wait(0.1)
                        end

                        local rCheck = hrp()
                        if not (rCheck and nearestEnemy(mob, rCheck.Position, false)) then
                            patrolIdx = (curCamp % totalCamps) + 1
                        end
                        return
                    end

                    setStatus("Lv " .. getLevel() .. ": cho mob quest spawn (" .. mob .. ")")
                    task.wait(0.4)
                    return
                end

                local er = target:FindFirstChild("HumanoidRootPart")
                local eh = target:FindFirstChildOfClass("Humanoid")
                if not (er and eh) then return end

                local anchor = (not isBossModel(target) and clusterPos) or er.Position

                if #patrolCamps > 1 then
                    local nearIdx, nearD = 1, math.huge
                    for idx, cCF in ipairs(patrolCamps) do
                        local d = (cCF.Position - anchor).Magnitude
                        if d < nearD then
                            nearIdx, nearD = idx, d
                        end
                    end
                    patrolIdx = (nearIdx % #patrolCamps) + 1
                end

                local h = CFG.InstantHit and CFG.FarHeight or CFG.FlyHeight
                local startHover = anchor + Vector3.new(0, h, 0)

                if (root.Position - startHover).Magnitude > 30 then
                    setStatus(string.format("Bay toi cum %d %s", clusterCnt or 1, target.Name))
                    goTo(CFrame.new(startHover), false, function() return not isFarmActive() end)
                end

                curTargetModel = target
                local t0 = tick()
                local mobName = target.Name
                local isBossTarget = isBossModel(target)
                local lastEquipCheck = 0
                local lastQuestPoll = tick()
                local hadQuestAtStart = isQuestMode and questActive()
                local lastStatusUpd = 0

                while alive_script and isFarmActive() and alive() and tick() - t0 < 28 do
                    if not (aliveEnemy(target) and er and er.Parent) then
                        if hadQuestAtStart and not questActive(true) then
                            break
                        end
                        if not isBossTarget then
                            local nextM = nearestEnemy(mobName, anchor, false)
                            if nextM then
                                local ner = nextM:FindFirstChild("HumanoidRootPart")
                                if ner and (ner.Position - anchor).Magnitude <= (CFG.BringRadius * BRING_RADIUS_MULT) then
                                    target = nextM
                                    er = ner
                                    curTargetModel = target
                                    t0 = tick()
                                else
                                    break
                                end
                            else
                                break
                            end
                        else
                            break
                        end
                    end

                    local now = tick()
                    h = CFG.InstantHit and CFG.FarHeight or CFG.FlyHeight
                    local me = anchor + Vector3.new(0, h, 0)

                    local r = hrp()
                    if not r then break end
                    r.CFrame = CFrame.lookAt(me, me + Vector3.new(0, -1, 0.001))
                    r.AssemblyLinearVelocity = Vector3.zero

                    local groupedCnt = 1
                    if not isBossTarget then
                        groupedCnt = bringMobs(mobName, anchor)
                    else
                        anchor = er.Position
                    end

                    if now - lastStatusUpd >= 0.45 then
                        lastStatusUpd = now
                        setStatus(string.format("Lv %d | x%d %s | %s", getLevel(), math.max(1, groupedCnt), mobName, tostring(src)))
                    end

                    if now - lastEquipCheck >= 0.25 then
                        lastEquipCheck = now
                        equipWeapon()
                        ensureBusoHaki()
                        if CFG.AutoSkillZX and groupedCnt >= 2 then
                            tryCastFarmSkills()
                        end
                    end

                    if hadQuestAtStart and (now - lastQuestPoll >= 0.6) then
                        lastQuestPoll = now
                        if not questActive(true) then
                            break
                        end
                    end

                    task.wait()
                end
            end)
            if not ok then
                setStatus("loi: " .. tostring(err))
                task.wait(0.8)
            end
        elseif not shouldKeepBuying() and not isElectroQuestRunning and not questItemRunning and not questItemHoldLock then
            setHold(false)
            stopMoving()
        end
    end
end)

track(plr.CharacterAdded:Connect(function()
    holder = nil
    isFlying = false
    isBuyingNpc = false
    manualBuyActive = false
    isElectroQuestRunning = false
    questItemRunning = false
    questItemHoldLock = false
    cupFilledFlag = false
    icicleCache = nil
    m1State.fallbackTracks = {}
    m1State.gcController = nil
    m1State.gcScanned = false
    m1State.toolName = nil
    task.wait(2)
end))

shutdownScript = function()
    alive_script = false
    CFG.Enabled = false
    CFG.KillAura = false
    CFG.KillAuraPlayers = false
    CFG.AutoStats = false
    CFG.AutoMelee = false
    CFG.AutoBoss = false
    CFG.AutoSaberV1 = false
    CFG.AutoSaberV2 = false
    CFG.AutoSwanGlasses = false
    CFG.AutoWardenSword = false
    CFG.AutoPoleV1 = false
    questItemBossName = nil
    questItemBossTag = nil
    questItemRunning = false
    questItemHoldLock = false
    isBuyingNpc = false
    manualBuyActive = false
    isElectroQuestRunning = false
    stopMoving()
    setHold(false)
    for _, c in ipairs(conns) do pcall(function() c:Disconnect() end) end
    if gui then pcall(function() gui:Destroy() end) end
    if getgenv then getgenv().BF_AUTOFARM_CLOSE = nil end
end

if getgenv then
    getgenv().BF_AUTOFARM_CLOSE = shutdownScript
end

setStatus(Quests and "san sang" or "khong doc duoc bang quest")
