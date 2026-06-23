-- ts file was generated at discord.gg/25ms


-- ts file was generated at discord.gg/25ms
getgenv().valid = "github"

-- ADD MISSING VARIABLES HERE
local versionn = "7.4.1"
local statusmm2 = "Online"
local scriptfree = "Free"
local SSH_mm2 = "Online"
local SSH_timebomb = "Online"
local icon1 = " 🔪"
local floatName = "FLY_NIGGER"
local GUN_PREDICTION_TIME = 0.125  -- Add this near the top
-- SIMPLE PREDICTION FUNCTION
local function GetGunPredictedPosition(targetRoot)
    if not targetRoot then return nil end
    local success, velocity = pcall(function() return targetRoot.AssemblyLinearVelocity end)
    if not success or not velocity then return targetRoot.Position end
    return targetRoot.Position + (velocity * GUN_PREDICTION_TIME)
end

local v1 = "en"  -- Default language
-- Cooldown tracking untuk Silent Aim Knife
getgenv()._knifeLastThrow = 0
-- Untuk Hybrid Prediction (tracking velocity untuk Extreme)
local _lastVelocities = {}
-- ==================== SERVICE DECLARATIONS ====================
local Players = game:GetService("Players")
local LocalPlayer = Players.LocalPlayer

if not LocalPlayer then
    LocalPlayer = Players.PlayerAdded:Wait()
end

local UserInputService = game:GetService("UserInputService")
local RunService = game:GetService("RunService")
local HttpService = game:GetService("HttpService")
local Workspace = game:GetService("Workspace")
local Camera = workspace.CurrentCamera
local CoreGui = game:GetService("CoreGui")

-- ==================== CLONEREF FALLBACK ====================
local cloneref = cloneref or clonereference or function(i) return i end

-- ==================== QUICK BUTTONS SYSTEM ====================
-- ... LANJUTKAN KODE QUICK BUTTONS DI SINI ...
-- ==================== QUICK BUTTONS SYSTEM ====================
-- PASTIKAN LocalPlayer SUDAH ADA
local Players = game:GetService("Players")
local LocalPlayer = Players.LocalPlayer

if not LocalPlayer then
    LocalPlayer = Players.PlayerAdded:Wait()
end

local SAVE_FILE = "ThunderHub_Layout.json"
local CreatedButtons = {}
local EditMode = false
local SelectedButton = nil
local MASTER_VIOLET = Color3.fromRGB(138, 43, 226)

-- ScreenGui untuk Quick Buttons
local screenGui = Instance.new("ScreenGui")
screenGui.Name = "ThunderHub_QuickButtons"
screenGui.ResetOnSpawn = false

-- ==================== SAFETY CHECK (FIX ERROR) ====================
local success, err = pcall(function()
    local playerGui = LocalPlayer:WaitForChild("PlayerGui", 10)
    if playerGui then
        screenGui.Parent = playerGui
    else
        screenGui.Parent = game:GetService("CoreGui")
        warn("Quick Buttons: Using CoreGui as fallback")
    end
end)

if not success then
    screenGui.Parent = game:GetService("CoreGui")
    warn("Quick Buttons: Error accessing PlayerGui, using CoreGui: " .. tostring(err))
end

-- Edit Status Label
local EditLabel = Instance.new("TextLabel")
EditLabel.Name = "EditStatusLabel"
EditLabel.Size = UDim2.new(0, 500, 0, 50)
EditLabel.Position = UDim2.new(0.5, 0, 0.4, 0)
EditLabel.AnchorPoint = Vector2.new(0.5, 0.5)
EditLabel.BackgroundTransparency = 1
EditLabel.Visible = false
EditLabel.Font = Enum.Font.GothamBold
EditLabel.TextColor3 = MASTER_VIOLET
EditLabel.TextSize = 22
EditLabel.TextStrokeTransparency = 0.5
EditLabel.Parent = screenGui

local function UpdateEditLabel()
    if EditMode and SelectedButton then
        EditLabel.Text = string.format("EDITING: %s", string.upper(SelectedButton.Name))
        EditLabel.Visible = true
    else
        EditLabel.Visible = false
    end
end

-- Fungsi Drag & Drop
local function makeDraggable(gui)
    local dragging, dragInput, dragStart, startPos
    gui.InputBegan:Connect(function(input)
        if not EditMode then return end
        if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
            if SelectedButton and SelectedButton ~= gui then
                SelectedButton.BackgroundColor3 = Color3.fromRGB(25, 25, 25)
            end
            SelectedButton = gui
            gui.BackgroundColor3 = MASTER_VIOLET
            UpdateEditLabel()
            dragging = true
            dragStart = input.Position
            startPos = gui.Position
            input.Changed:Connect(function()
                if input.UserInputState == Enum.UserInputState.End then dragging = false end
            end)
        end
    end)
    gui.InputChanged:Connect(function(input)
        if not EditMode then return end
        if input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch then
            dragInput = input
        end
    end)
    UserInputService.InputChanged:Connect(function(input)
        if input == dragInput and dragging then
            local delta = input.Position - dragStart
            gui.Position = UDim2.new(startPos.X.Scale, startPos.X.Offset + delta.X, startPos.Y.Scale, startPos.Y.Offset + delta.Y)
        end
    end)
end

-- Fungsi Save/Load Config
local function SaveConfig()
    local fullData = {}
    for _, btn in ipairs(CreatedButtons) do
        local corner = btn.UICorner.CornerRadius
        fullData[btn.Name] = {
            PosX_Scale = btn.Position.X.Scale, PosX_Offset = btn.Position.X.Offset,
            PosY_Scale = btn.Position.Y.Scale, PosY_Offset = btn.Position.Y.Offset,
            SizeX = btn.Size.X.Offset,
            SizeY = btn.Size.Y.Offset,
            Transparency = btn.BackgroundTransparency,
            CornerScale = corner.Scale,
            CornerOffset = corner.Offset,
        }
    end
    writefile(SAVE_FILE, HttpService:JSONEncode(fullData))
    sendnotification("Layout saved!")
end

local function LoadConfig()
    if isfile(SAVE_FILE) then
        local success, data = pcall(function() return HttpService:JSONDecode(readfile(SAVE_FILE)) end)
        if success then
            for _, btn in ipairs(CreatedButtons) do
                if data[btn.Name] then
                    local d = data[btn.Name]
                    btn.Position = UDim2.new(d.PosX_Scale, d.PosX_Offset, d.PosY_Scale, d.PosY_Offset)
                    btn.Size = UDim2.fromOffset(d.SizeX, d.SizeY)
                    btn.BackgroundTransparency = d.Transparency
                    btn.TextTransparency = d.Transparency
                    if btn.UIStroke then
                        btn.UIStroke.Transparency = d.Transparency
                    end
                    btn.UICorner.CornerRadius = UDim.new(d.CornerScale or 1, d.CornerOffset or 0)
                end
            end
        end
    end
end

-- Fungsi Create Button
local function createButton(name, pos, text, callback)
    local btn = Instance.new("TextButton")
    btn.Name = name
    btn.Size = UDim2.fromOffset(70, 70)
    btn.Position = pos
    btn.AnchorPoint = Vector2.new(0.5, 0.5)
    btn.BackgroundColor3 = Color3.fromRGB(25, 25, 25)
    btn.BackgroundTransparency = 0.4
    btn.Visible = true
    btn.Text = text
    btn.TextColor3 = Color3.fromRGB(255, 255, 255)
    btn.Font = Enum.Font.GothamMedium
    btn.TextScaled = true
    btn.Parent = screenGui

    local uc = Instance.new("UICorner", btn)
    uc.CornerRadius = UDim.new(1, 0)

    local st = Instance.new("UIStroke", btn)
    st.Thickness = 3
    st.ApplyStrokeMode = Enum.ApplyStrokeMode.Border
    st.Color = Color3.fromRGB(255, 255, 255)

    local gradient = Instance.new("UIGradient", st)
    gradient.Color = ColorSequence.new({
        ColorSequenceKeypoint.new(0, MASTER_VIOLET),
        ColorSequenceKeypoint.new(0.5, Color3.fromRGB(255, 255, 255)),
        ColorSequenceKeypoint.new(1, MASTER_VIOLET)
    })

    RunService.RenderStepped:Connect(function(dt)
        gradient.Rotation = (gradient.Rotation + (180 * dt)) % 360
    end)

    btn.MouseButton1Click:Connect(function()
        if not EditMode then callback() end
    end)

    makeDraggable(btn)
    table.insert(CreatedButtons, btn)
    return btn
end
-- ==================== QUICK BUTTON 1: SHOOT ====================
createButton("Shoot_Btn", UDim2.new(0.4, 0, 0.4, 0), "SHOOT", function()
    local Character = LocalPlayer.Character
    local Backpack = LocalPlayer:FindFirstChild("Backpack")
    if not Character or not Backpack then
        sendnotification("Character not ready!")
        return
    end

    local Gun = Backpack:FindFirstChild("Gun") or Character:FindFirstChild("Gun")
    if not Gun then
        sendnotification("No Gun!")
        return
    end

    -- Cek Murderer
    local Murderer = nil
    for _, plr in ipairs(game.Players:GetPlayers()) do
        if plr ~= LocalPlayer and plr.Character then
            if plr.Backpack:FindFirstChild("Knife") or plr.Character:FindFirstChild("Knife") then
                Murderer = plr
                break
            end
        end
    end
    if not Murderer or not Murderer.Character then
        sendnotification("No Murderer!")
        return
    end

    local MyRoot = Character:FindFirstChild("HumanoidRootPart")
    local TargetRoot = Murderer.Character:FindFirstChild("HumanoidRootPart")
    local ShootRemote = Gun:FindFirstChild("Shoot")
    if not (MyRoot and TargetRoot and ShootRemote) then
        sendnotification("Missing parts!")
        return
    end

    if Gun.Parent == Backpack then
        Gun.Parent = Character
        task.wait(0.05)
    end
    
    -- Prediksi posisi
    local PredictedPos = GetGunPredictedPosition(TargetRoot) or TargetRoot.Position
    
    -- Get attachment
    local Attachment = MyRoot:FindFirstChild("GunRaycastAttachment")
    local ShootCFrame = Attachment and Attachment.WorldCFrame or MyRoot.CFrame
    
    -- Tembak!
    ShootRemote:FireServer(ShootCFrame, CFrame.new(PredictedPos))
    
    sendnotification("🔫 Shot fired!")
end)
-- ==================== QUICK BUTTON 9: THROW ====================
-- ==================== QUICK BUTTON THROW (TERHUBUNG DENGAN SILENT AIM) ====================
createButton("Throw_Btn", UDim2.new(0.7, 0, 0.5, 0), "THROW", function()
    -- Panggil fungsi Silent Aim Knife
    if getgenv().KnifeAimEnabled then
        -- Cari keybind R dan jalankan fungsinya
        -- Atau panggil langsung fungsi throw
        if GetMurder() ~= vu14 then
            sendnotification("You're not Murderer!")
            return
        end
        
        -- CEK COOLDOWN
        local now = tick()
        local cooldown = getgenv().KnifePostCooldown or 0.5
        if getgenv()._knifeLastThrow and (now - getgenv()._knifeLastThrow) < cooldown then
            local remaining = math.floor((cooldown - (now - getgenv()._knifeLastThrow)) * 10) / 10
            sendnotification("⏱ Cooldown: " .. remaining .. "s")
            return
        end
        
        -- CEK KNIFE
        if not vu14.Character:FindFirstChild("Knife") then
            local humanoid = vu14.Character:FindFirstChild("Humanoid")
            if not vu14.Backpack:FindFirstChild("Knife") then
                sendnotification("No knife found!")
                return
            end
            humanoid:EquipTool(vu14.Backpack:FindFirstChild("Knife"))
            task.wait(0.1)
        end
        
        local knife = vu14.Backpack:FindFirstChild("Knife") or vu14.Character:FindFirstChild("Knife")
        if not knife then
            sendnotification("Knife not found!")
            return
        end
        
        -- DAPATKAN TARGET & PREDIKSI
        local target = GetKnifeTarget()
        if not target or not target.Character then
            sendnotification("No target in FOV!")
            return
        end
        
        local predictedPos = GetKnifePrediction()
        if not predictedPos then
            sendnotification("No target in FOV!")
            return
        end
        
        -- THROW
        local success = false
        local handleCFrame = knife.Handle and knife.Handle.CFrame or CFrame.new()
        local throwData = {handleCFrame, CFrame.new(predictedPos)}
        
        pcall(function()
            if vu14.Character.Knife and vu14.Character.Knife.Events and vu14.Character.Knife.Events.KnifeThrown then
                vu14.Character.Knife.Events.KnifeThrown:FireServer(unpack(throwData))
                success = true
            end
        end)
        
        if success then
            getgenv()._knifeLastThrow = tick()
            sendnotification("🗡️ Thrown! (Quick Button)")
        else
            sendnotification("❌ Failed to throw!")
        end
    else
        -- FALLBACK: Gunakan kode throw lama
        local Character = LocalPlayer.Character
        if not Character then
            sendnotification("No character!")
            return
        end
        
        local Knife = Character:FindFirstChild("Knife")
        if not Knife then
            local Backpack = LocalPlayer:FindFirstChild("Backpack")
            if Backpack then
                Knife = Backpack:FindFirstChild("Knife")
                if Knife then
                    Knife.Parent = Character
                    task.wait(0.05)
                    Knife = Character:FindFirstChild("Knife")
                end
            end
        end
        
        if not Knife then
            sendnotification("You need to be Murderer!")
            return
        end
        
        local ClosestTarget = nil
        local ClosestDistance = 50
        local MyPos = Character:FindFirstChild("HumanoidRootPart")
        
        if not MyPos then
            sendnotification("Character not ready!")
            return
        end
        
        for _, Player in ipairs(game.Players:GetPlayers()) do
            if Player ~= LocalPlayer and Player.Character then
                local TargetRoot = Player.Character:FindFirstChild("HumanoidRootPart")
                if TargetRoot then
                    local Dist = (MyPos.Position - TargetRoot.Position).Magnitude
                    if Dist < ClosestDistance then
                        ClosestDistance = Dist
                        ClosestTarget = Player
                    end
                end
            end
        end
        
        if not ClosestTarget or not ClosestTarget.Character then
            sendnotification("No target nearby!")
            return
        end
        
        local TargetRoot = ClosestTarget.Character:FindFirstChild("HumanoidRootPart")
        if not TargetRoot then
            sendnotification("Target not ready!")
            return
        end
        
        local Handle = Knife:FindFirstChild("Handle")
        if not Handle then
            sendnotification("Knife handle not found!")
            return
        end
        
        local Events = Knife:FindFirstChild("Events")
        if Events then
            local KnifeThrown = Events:FindFirstChild("KnifeThrown")
            if KnifeThrown then
                KnifeThrown:FireServer(Handle.CFrame, CFrame.new(TargetRoot.Position))
                sendnotification("🗡️ Knife thrown! (Fallback)")
            else
                sendnotification("KnifeThrown remote not found!")
            end
        else
            sendnotification("Events not found!")
        end
    end
end)
-- ==================== QUICK BUTTON 2: AIMBOT TOGGLE ====================
local AimbotQuickEnabled = false
local AimbotQuickConnection = nil

local function StartAimbotQuick()
    if AimbotQuickConnection then AimbotQuickConnection:Disconnect() end
    AimbotQuickConnection = RunService.RenderStepped:Connect(function()
        if not AimbotQuickEnabled then return end
        
        local ClosestTarget = nil
        local ClosestDistance = 250
        local ScreenCenter = Camera.ViewportSize / 2
        
        for _, Player in ipairs(game.Players:GetPlayers()) do
            if Player ~= LocalPlayer and Player.Character then
                local IsMurderer = false
                local BP = Player:FindFirstChild("Backpack")
                local Char = Player.Character
                if (BP and BP:FindFirstChild("Knife")) or (Char and Char:FindFirstChild("Knife")) then
                    IsMurderer = true
                end
                
                if IsMurderer then
                    local Head = Player.Character:FindFirstChild("Head")
                    if Head then
                        local ScreenPos, OnScreen = Camera:WorldToViewportPoint(Head.Position)
                        if OnScreen then
                            local DistanceFromCenter = (Vector2.new(ScreenPos.X, ScreenPos.Y) - ScreenCenter).Magnitude
                            if DistanceFromCenter < ClosestDistance then
                                ClosestDistance = DistanceFromCenter
                                ClosestTarget = Player
                            end
                        end
                    end
                end
            end
        end
        
        if ClosestTarget and ClosestTarget.Character and ClosestTarget.Character:FindFirstChild("Head") then
            local HeadPos = ClosestTarget.Character.Head.Position
            Camera.CFrame = CFrame.new(Camera.CFrame.Position, HeadPos)
        end
    end)
end

createButton("Aim_Btn", UDim2.new(0.5, 0, 0.85, 0), "AIM", function()
    AimbotQuickEnabled = not AimbotQuickEnabled
    if AimbotQuickEnabled then
        StartAimbotQuick()
        sendnotification("🎯 Aimbot ON")
    else
        if AimbotQuickConnection then
            AimbotQuickConnection:Disconnect()
            AimbotQuickConnection = nil
        end
        sendnotification("🎯 Aimbot OFF")
    end
end)

-- ==================== QUICK BUTTON 3: RUN ====================
createButton("Run_Btn", UDim2.new(0.5, 0, 0.7, 0), "RUN", function()
    local character = LocalPlayer.Character
    if character and character:FindFirstChild("Humanoid") then
        local humanoid = character.Humanoid
        local originalSpeed = humanoid.WalkSpeed
        humanoid.WalkSpeed = originalSpeed + 20
        sendnotification("🏃 Speed Boost ON!")
        task.delay(5, function()
            if humanoid and humanoid.Parent then
                humanoid.WalkSpeed = originalSpeed
                sendnotification("🏃 Speed Boost OFF")
            end
        end)
    end
end)

-- ==================== QUICK BUTTON 4: NINJA STEP ====================
do
    local NinjaEnabled = false
    local NinjaCooldown = 22
    local NinjaOnCooldown = false
    local NinjaAirLock = false

    local function getTool(char)
        return char:FindFirstChild("FakeBomb") or LocalPlayer.Backpack:FindFirstChild("FakeBomb")
    end

    local function dropBombAndBounce(char)
        if NinjaOnCooldown then return end
        local hum = char:FindFirstChild("Humanoid")
        local hrp = char:FindFirstChild("HumanoidRootPart")
        local tool = getTool(char)
        if not (hum and hrp and tool) then return end
        if tool.Parent ~= char then tool.Parent = char end
        task.wait(0.05)
        local rem = tool:FindFirstChild("Remote")
        if rem then
            local down = CFrame.lookAt(hrp.Position, hrp.Position - Vector3.new(0, 50, 0))
            rem:FireServer(down, 50)
            hum:ChangeState(Enum.HumanoidStateType.Jumping)
            NinjaOnCooldown = true
            task.delay(NinjaCooldown, function() NinjaOnCooldown = false end)
        end
    end

    local function setupNinja(char)
        local hum = char:WaitForChild("Humanoid")
        local hrp = char:WaitForChild("HumanoidRootPart")
        RunService.Heartbeat:Connect(function()
            if not NinjaEnabled or NinjaOnCooldown then return end
            if hum.FloorMaterial == Enum.Material.Air then
                if hrp.AssemblyLinearVelocity.Y < -2 then
                    if not NinjaAirLock then
                        NinjaAirLock = true
                        dropBombAndBounce(char)
                    end
                end
            else
                NinjaAirLock = false
            end
        end)
    end

    if LocalPlayer.Character then task.spawn(setupNinja, LocalPlayer.Character) end
    LocalPlayer.CharacterAdded:Connect(function(c) task.spawn(setupNinja, c) end)

    createButton("NinjaStep_Btn", UDim2.new(0.5, 0, 0.5, 0), "NINJA: OFF", function()
        NinjaEnabled = not NinjaEnabled
        for _, b in ipairs(CreatedButtons) do
            if b.Name == "NinjaStep_Btn" then
                b.Text = NinjaEnabled and "NINJA: ON" or "NINJA: OFF"
                break
            end
        end
        sendnotification("Ninja Step " .. (NinjaEnabled and "ON" or "OFF"))
    end)
end

-- ==================== QUICK BUTTON 5: GOD MODE ====================
createButton("GodMode_Btn", UDim2.new(0.6, 0, 0.7, 0), "GOD MODE", function()
    local Character = LocalPlayer.Character or LocalPlayer.CharacterAdded:Wait()
    local Humanoid = Character:WaitForChild("Humanoid")
    
    -- Simpan health asli
    local originalHealth = Humanoid.Health
    local maxHealth = Humanoid.MaxHealth
    
    -- Set health ke max
    Humanoid.Health = maxHealth
    
    -- Lock health agar tidak berkurang
    local connection
    connection = Humanoid.Changed:Connect(function(prop)
        if prop == "Health" and Humanoid.Health < maxHealth then
            Humanoid.Health = maxHealth
        end
    end)
    
    -- Hapus setelah 1 ronde atau jika mati
    task.delay(30, function()
        if connection then connection:Disconnect() end
        sendnotification("👑 God Mode OFF (30s expired)")
    end)
    
    sendnotification("👑 God Mode ON!")
end)

-- ==================== QUICK BUTTON 6: KILL ALL ====================
createButton("KillAll_Btn", UDim2.new(0.6, 0, 0.3, 0), "KILL ALL", function()
    local character = LocalPlayer.Character
    local backpack = LocalPlayer:FindFirstChild("Backpack")
    if not character or not backpack then return end
    local knife = character:FindFirstChild("Knife") or backpack:FindFirstChild("Knife")
    if not knife then
        sendnotification("You are not the Murderer!")
        return
    end
    local myRoot = character:FindFirstChild("HumanoidRootPart")
    local humanoid = character:FindFirstChild("Humanoid")
    if not (myRoot and humanoid) then return end
    if knife.Parent == backpack then humanoid:EquipTool(knife); task.wait() end
    
    -- Anchored semua player
    for _, plr in ipairs(game.Players:GetPlayers()) do
        if plr ~= LocalPlayer and plr.Character and plr.Character:FindFirstChild("HumanoidRootPart") then
            local enemyRoot = plr.Character.HumanoidRootPart
            enemyRoot.Anchored = true
            enemyRoot.CFrame = myRoot.CFrame * CFrame.new(0, 0, -2)
        end
    end
    
    -- Stab
    local stab = knife:FindFirstChild("Stab")
    if stab then stab:FireServer("Slash") end
    task.wait(0.1)
    
    -- Unanchor
    for _, plr in ipairs(game.Players:GetPlayers()) do
        if plr.Character and plr.Character:FindFirstChild("HumanoidRootPart") then
            plr.Character.HumanoidRootPart.Anchored = false
        end
    end
    if knife.Parent == character then knife.Parent = backpack end
    sendnotification("💀 Killed All!")
end)

-- ==================== QUICK BUTTON 7: INVISIBLE ====================
local InvisibleActive = false
local Character, Humanoid, HumanoidRoot = nil, nil, nil
local PartsList = {}

local function UpdateCharacter()
    Character = LocalPlayer.Character or LocalPlayer.CharacterAdded:Wait()
    Humanoid = Character:WaitForChild("Humanoid")
    HumanoidRoot = Character:WaitForChild("HumanoidRootPart")
    PartsList = {}
    for _, part in ipairs(Character:GetDescendants()) do
        if part:IsA("BasePart") and part.Transparency == 0 then
            table.insert(PartsList, part)
        end
    end
end

local function ToggleInvisibility()
    InvisibleActive = not InvisibleActive
    for _, part in ipairs(PartsList) do
        part.Transparency = InvisibleActive and 0.5 or 0
    end
end

RunService.Heartbeat:Connect(function()
    if InvisibleActive and HumanoidRoot and Humanoid then
        local originalCFrame = HumanoidRoot.CFrame
        local originalOffset = Humanoid.CameraOffset
        local downCFrame = originalCFrame * CFrame.new(0, -200000, 0)
        HumanoidRoot.CFrame = downCFrame
        Humanoid.CameraOffset = (downCFrame:ToObjectSpace(originalCFrame)).Position
        RunService.RenderStepped:Wait()
        HumanoidRoot.CFrame = originalCFrame
        Humanoid.CameraOffset = originalOffset
    end
end)

LocalPlayer.CharacterAdded:Connect(function()
    InvisibleActive = false
    UpdateCharacter()
end)

UpdateCharacter()

createButton("Invisible_Btn", UDim2.new(0.5, 0, 0.75, 0), "INVISIBLE", function()
    ToggleInvisibility()
    sendnotification("Invisible " .. (InvisibleActive and "ON" or "OFF"))
end)

-- ==================== QUICK BUTTON 8: GET GUN (FIXED - ANTI FLING) ====================
local quickGrabLock = false

createButton("Gun_Btn", UDim2.new(0.5, 0, 0.65, 0), "GET GUN", function()
    -- CEK LOCK
    if quickGrabLock then
        sendnotification("Please wait...")
        return
    end
    quickGrabLock = true
    
    -- CEK CHARACTER
    local char = LocalPlayer.Character
    if not char then
        sendnotification("Character not ready!")
        quickGrabLock = false
        return
    end
    
    local RootPart = char:FindFirstChild("HumanoidRootPart")
    if not RootPart then
        sendnotification("RootPart not found!")
        quickGrabLock = false
        return
    end
    
    -- CEK MURDERER
    local bp = LocalPlayer:FindFirstChild("Backpack")
    local isMurderer = false
    
    if char:FindFirstChild("Knife") then isMurderer = true end
    if bp and bp:FindFirstChild("Knife") then isMurderer = true end
    
    if isMurderer then
        WindUI:Notify({
            ["Title"] = "Grab Gun",
            ["Content"] = "You are the Murderer!",
            ["Duration"] = 2
        })
        quickGrabLock = false
        return
    end
    
    -- CARI GUNDROP
    local GunDrop = nil
    for _, Descendant in ipairs(Workspace:GetDescendants()) do
        if Descendant.Name == "GunDrop" and Descendant:IsA("BasePart") then
            GunDrop = Descendant
            break
        end
    end
    
    if not GunDrop then
        WindUI:Notify({
            ["Title"] = "Grab Gun",
            ["Content"] = "No gun drop found!",
            ["Duration"] = 2
        })
        quickGrabLock = false
        return
    end
    
    -- ===== ANTI FLING =====
    local OriginalPos = RootPart.Position
    
    -- MATIKAN PHYSICS
    local humanoid = char:FindFirstChild("Humanoid")
    if humanoid then
        humanoid.PlatformStand = true
    end
    
    -- RESET VELOCITY
    RootPart.AssemblyLinearVelocity = Vector3.new(0, 0, 0)
    RootPart.AssemblyAngularVelocity = Vector3.new(0, 0, 0)
    
    -- PINDAH KE GUNDROP (AMAN)
    RootPart.CFrame = GunDrop.CFrame + Vector3.new(0, 2, 0)
    
    task.wait(0.15)
    
    -- KEMBALI KE POSISI SEMULA
    RootPart.CFrame = CFrame.new(OriginalPos.X, OriginalPos.Y + 5, OriginalPos.Z)
    RootPart.AssemblyLinearVelocity = Vector3.new(0, 0, 0)
    
    task.wait(0.05)
    
    -- NYALAKAN PHYSICS KEMBALI
    if humanoid then
        humanoid.PlatformStand = false
    end
    
    WindUI:Notify({
        ["Title"] = "Grab Gun",
        ["Content"] = "🔫 Gun acquired!",
        ["Duration"] = 2
    })
    
    quickGrabLock = false
end)

-- ==================== LOAD SAVED CONFIG ====================
LoadConfig()

print("Kenzie Hub MM2 Loading...")
local vu2 = loadstring(game:HttpGet("https://github.com/Footagesus/WindUI/releases/latest/download/main.lua"))()
function missing(p3, p4, p5)
    if type(p4) ~= p3 then
        return p5
    else
        return p4
    end
end
-- ... rest of script continues
local vu6 = game:GetService("ReplicatedStorage")
local v7 = identifyexecutor or (getexecutorname or function()
    return "Another Executor 1.2"
end)
local vu8 = workspace.CurrentCamera
local vu9 = game:GetService("CoreGui")
local vu10 = game:GetService("RunService")
function sendnotification(p11)
    vu2:Notify({
        Title = "Kenzie Hub MM2",
        Content = p11,
        Icon = "scroll-text",
        Duration = 4.3,
        Background = "rbxassetid://116379998454359"
    })
end
local vu12 = game:GetService("Workspace")
local vu13 = game:GetService("Players")
local vu14 = vu13.LocalPlayer

print("PlayerGui \208\183\208\176\208\179\209\128\209\131\208\182\208\181\208\189")
local vu15 = game:GetService("Workspace")
FlingPower = 70000
proverka = false
permit = false
moveSpeed = 25
AllBool = false
local vu16 = vu14.Character
local _ = vu13.LocalPlayer
function getOrCreatesusSound()
    local v17 = vu6:FindFirstChild("susSound")
    if not v17 then
        v17 = Instance.new("Sound")
        v17.Name = "susSound"
        v17.SoundId = "rbxassetid://2027986581"
        v17.Parent = vu6
    end
    return v17
end
local vu18 = getOrCreatesusSound()
function CleanupFling()
    print("\239\191\189\209\139\208\183\208\190\208\178 \209\132\209\131\208\189\208\186\209\134\208\184\208\184 CleanupFling()")
    if getgenv().FPDH then
        vu12.FallenPartsDestroyHeight = getgenv().FPDH
    end
    local v19 = vu12:FindFirstChildOfClass("Camera")
    if v19 then
        if BV and BV.Parent then
            BV:Destroy()
            BV = nil
        end
        local v20 = game:GetService("Players").LocalPlayer
        local v21 = (v20.Character or v20.CharacterAdded:Wait()):FindFirstChildOfClass("Humanoid")
        if v21 then
            v19.CameraSubject = v21
            v21:ChangeState(Enum.HumanoidStateType.Seated)
        else
            warn("Humanoid \208\189\208\181 \208\189\208\176\208\185\208\180\208\181\208\189, \208\186\208\176\208\188\208\181\209\128\208\176 \208\189\208\181 \209\129\208\177\209\128\208\190\209\136\208\181\208\189\208\176.")
        end
    else
        warn("\239\191\189\208\176\208\188\208\181\209\128\208\176 \208\189\208\181 \208\189\208\176\208\185\208\180\208\181\208\189\208\176.")
    end
end

    function gradient(p22, p23, p24)
        local v25 = # p22
        local v26 = ""
        for v27 = 1, v25 do
            local v28 = (v27 - 1) / math.max(v25 - 1, 1)
            v26 = v26 .. "<font color=\"rgb(" .. math.floor((p23.R + (p24.R - p23.R) * v28) * 255) .. ", " .. math.floor((p23.G + (p24.G - p23.G) * v28) * 255) .. ", " .. math.floor((p23.B + (p24.B - p23.B) * v28) * 255) .. ")\">" .. p22:sub(v27, v27) .. "</font>"
        end
        return v26
    end
    local vu29 = game:GetService("HttpService")
    local v30 = missing("function", readfile, false)
    if v30 then
        v30 = missing("function", writefile, false)
    end
    DefaultLanguagee = "en"
    if v30 and (syn and isfile("configlanguage.json") or isfile and isfile("configlanguage.json")) then
        local v31, v32 = pcall(function()
            return vu29:JSONDecode(readfile("configlanguage.json"))
        end)
        if v31 and (v32 and v32.language) then
            DefaultLanguagee = v32.language
        end
    elseif getgenv().choice then
        DefaultLanguagee = getgenv().choice
    end
    Touchscreen = game:GetService("UserInputService").TouchEnabled
    launch = Touchscreen and "Pocket device [Mobile]" or "PC [Computer]"
    loadstring(game:HttpGet("https://raw.githubusercontent.com/snapsanix/Secrethub/refs/heads/main/OtherSCRIPTS/Statusforinfo", true))()
    vu2:Localization({
        Enabled = true,
        Prefix = "loc:",
        fly = {
            [v1] = {
ver = "\239\191\189\208\181\209\128\209\129\208\184\209\143 " .. versionn,
autofarm_info = "\239\191\189\208\189\209\130\208\184 \208\176\209\132\208\186 \208\178\208\186\208\187\209\142\209\135\208\176\208\181\209\130\209\129\209\143 \208\191\208\190 \208\180\208\181\209\132\208\190\208\187\209\130\209\131 \208\184 \208\176\208\189\209\130\208\184 \209\132\208\187\208\184\208\189\208\179, \208\178\208\186\208\187\208\176\208\180\208\186\208\184 \208\186\208\190\208\188\208\177\208\176\209\130 \208\184 \209\130\209\128\208\190\208\187\208\187\208\184\208\189\208\179 \208\177\208\187\208\190\208\186\208\184\209\128\209\131\209\142\209\130\209\129\209\143 \208\178\208\190 \208\178\209\128\208\181\208\188\209\143 \208\176\208\178\209\130\208\190\209\132\208\176\209\128\208\188\208\176",
report_how = "\239\191\189\209\139 \208\191\208\184\209\136\208\181\209\130\208\181 \208\188\208\189\208\181 \208\178 Telegram \209\129 \209\129\208\190\208\190\208\177\209\137\208\181\208\189\208\184\208\181\208\188 \208\190\208\177 \208\190\209\136\208\184\208\177\208\186\208\181. \208\146\208\176\209\136 \208\189\208\184\208\186, \208\178\209\139\208\177\209\128\208\176\208\189\208\189\208\176\209\143 \208\186\208\176\209\130\208\181\208\179\208\190\209\128\208\184\209\143 \208\184 \209\130\208\181\208\186\209\129\209\130 \208\182\208\176\208\187\208\190\208\177\209\139 \208\177\209\131\208\180\209\131\209\130 \208\190\209\130\208\190\208\177\209\128\208\176\208\182\208\181\208\189\209\139.",
status_script = "\239\191\189\209\130\208\176\209\130\209\131\209\129 \209\129\208\186\209\128\208\184\208\191\209\130\208\176: " .. statusmm2,
product_type = "\239\191\189\208\184\208\191 \208\191\209\128\208\190\208\180\209\131\208\186\209\130\208\176: " .. scriptfree,
script_version = "\239\191\189\208\181\209\128\209\129\208\184\209\143 \209\129\208\186\209\128\208\184\208\191\209\130\208\176: " .. versionn,
launched_from = "\239\191\189\208\176\208\191\209\131\209\137\208\181\208\189 \209\129: " .. launch,
executor = "\239\191\189\209\129\208\191\208\190\208\187\208\189\208\184\209\130\208\181\208\187\209\140: " .. v7(),
script_tester = "\239\191\189\208\181\209\129\209\130\208\181\209\128 \209\129\208\186\209\128\208\184\208\191\209\130\208\176: zsharki, qwizkoffc \208\184 rdiz890",
age = "\239\191\189\208\190\208\183\209\128\208\176\209\129\209\130 \208\176\208\186\208\186\208\176\209\131\208\189\209\130\208\176 " .. vu14.AccountAge .. " [\208\148\208\181\208\189\209\140]",
CHARACTER = "\239\191\189\208\181\209\128\209\129\208\190\208\189\208\176\208\182",
TELEPORT = "\239\191\189\208\181\208\187\208\181\208\191\208\190\209\128\209\130",
COMBAT = "\239\191\189\208\190\208\188\208\177\208\176\209\130",
TROLLING = "\239\191\189\209\128\208\190\208\187\208\187\208\184\208\189\208\179",
ESP = "\239\191\189\208\176\208\187\208\187\209\133\208\176\208\186",
VISUAL = "\239\191\189\208\184\208\183\209\131\208\176\208\187",
EMOTES = "\239\191\189\208\188\208\190\209\134\208\184\208\184",
OTHER = "\239\191\189\209\128\209\131\208\179\208\190\208\181",
AUTOFARM = "\239\191\189\208\178\209\130\208\190\209\132\208\176\209\128\208\188",
REPORT_BUGS = "\239\191\189\208\184\208\180\208\177\209\141\208\186",
HUB_STATUS = "\239\191\189\209\130\208\176\209\130\209\131\209\129 \209\133\208\176\208\177\208\176",
ABOUT_SCRIPT = "\239\191\189 \209\129\208\186\209\128\208\184\208\191\209\130\208\181",
ANOTHER_SCRIPT = "\239\191\189\209\130\208\190\209\128\208\176\209\143 \209\129\209\129\209\139\208\187\208\186\208\176",
SETTINGS = "\239\191\189\208\176\209\129\209\130\209\128\208\190\208\185\208\186\208\184",
ws = "\239\191\189\208\186\208\190\209\128\208\190\209\129\209\130\209\140 \209\133\208\190\208\180\209\140\208\177\209\139",
togws = "\239\191\189\208\186\208\187\209\142\209\135\208\184\209\130\209\140 \209\129\208\186\208\190\209\128\208\190\209\129\209\130\209\140 \209\133\208\190\208\180\209\140\208\177\209\139",
jump = "\239\191\189\208\184\208\187\208\176 \208\191\209\128\209\139\208\182\208\186\208\176",
togjump = "\239\191\189\208\186\208\187\209\142\209\135\208\184\209\130\209\140 \209\129\208\184\208\187\209\131 \208\191\209\128\209\139\208\182\208\186\208\176",
fly = "\239\191\189\208\190\208\187\208\181\209\130",
flyspeed = "\239\191\189\208\186\208\190\209\128\208\190\209\129\209\130\209\140 \208\191\208\190\208\187\208\181\209\130\208\176",
noclip = "\239\191\189\209\128\208\190\209\133\208\190\208\180 \209\129\208\186\208\178\208\190\208\183\209\140 \209\129\209\130\208\181\208\189\209\139",
infjump = "\239\191\189\208\181\209\129\208\186\208\190\208\189\208\181\209\135\208\189\209\139\208\185 \208\191\209\128\209\139\208\182\208\190\208\186",
fov = "\239\191\189\208\190\208\187\208\181 \208\183\209\128\208\181\208\189\208\184\209\143",
unlockcam = "\239\191\189\208\176\208\183\208\177\208\187\208\190\208\186\208\184\209\128\208\190\208\178\208\176\209\130\209\140 \208\186\208\176\208\188\208\181\209\128\209\131",
reset = "\239\191\189\208\188\208\181\209\128\208\181\209\130\209\140",
tpgunmode = "\239\191\189\208\181\208\187\208\181\208\191\208\190\209\128\209\130 \208\186 \208\190\209\128\209\131\208\182\208\184\209\142 (\209\128\208\181\208\182\208\184\208\188)",
grabgun = "\239\191\189\208\190\208\180\208\190\208\177\209\128\208\176\209\130\209\140 \208\190\209\128\209\131\208\182\208\184\208\181",
grabgunkey = "\239\191\189\208\187\208\176\208\178\208\184\209\136\208\176 \208\180\208\187\209\143 \208\191\208\190\208\180\208\177\208\190\209\128\208\176 \208\190\209\128\209\131\208\182\208\184\209\143",
toggrabgunkey = "\239\191\189\208\190\208\183\208\180\208\176\209\130\209\140 \208\186\208\187\208\176\208\178\208\184\209\136\209\131 \208\191\208\190\208\180\208\177\208\190\209\128\208\176 \208\190\209\128\209\131\208\182\208\184\209\143",
autograbgun = "\239\191\189\208\178\209\130\208\190\208\191\208\190\208\180\208\177\208\190\209\128 \208\190\209\128\209\131\208\182\208\184\209\143",
tptomap = "\239\191\189\208\181\208\187\208\181\208\191\208\190\209\128\209\130 \208\186 \208\186\208\176\209\128\209\130\208\181",
tptovote = "\239\191\189\208\181\208\187\208\181\208\191\208\190\209\128\209\130 \208\178 \208\186\208\190\208\188\208\189\208\176\209\130\209\131 \208\179\208\190\208\187\208\190\209\129\208\190\208\178\208\176\208\189\208\184\209\143",
tptolobby = "\239\191\189\208\181\208\187\208\181\208\191\208\190\209\128\209\130 \208\178 \208\187\208\190\208\177\208\177\208\184",
tptosecret = "\239\191\189\208\181\208\187\208\181\208\191\208\190\209\128\209\130 \208\178 \209\129\208\181\208\186\209\128\208\181\209\130\208\186\209\131",
tptorandom = "\239\191\189\208\181\208\187\208\181\208\191\208\190\209\128\209\130 \208\186 \209\129\208\187\209\131\209\135\208\176\208\185\208\189\208\190\208\188\209\131 \208\184\208\179\209\128\208\190\208\186\209\131",
tptoplayer = "\239\191\189\208\181\208\187\208\181\208\191\208\190\209\128\209\130 \208\186 \208\184\208\179\209\128\208\190\208\186\209\131",
tptomurder = "\239\191\189\208\181\208\187\208\181\208\191\208\190\209\128\209\130 \208\186 \209\131\208\177\208\184\208\185\209\134\208\181",
tptosheriff = "\239\191\189\208\181\208\187\208\181\208\191\208\190\209\128\209\130 \208\186 \209\136\208\181\209\128\208\184\209\132\209\131",
autododge = "\239\191\189\208\178\209\130\208\190\208\188\208\176\208\189\209\129 \208\190\209\130 \208\189\208\190\208\182\208\181\208\185",
godmode = "\239\191\189\208\190\208\191\208\190\208\187\208\189\208\184\209\130\208\181\208\187\209\140\208\189\208\176\209\143 \208\182\208\184\208\183\208\189\209\140",
descgodmode = "\239\191\189\208\178\208\181 \208\182\208\184\208\183\208\189\208\184 \208\189\208\176 \208\190\208\180\208\184\208\189 \209\128\208\176\209\131\208\189\208\180",
freeemotes = "\239\191\189\208\181\209\129\208\191\208\187\208\176\209\130\208\189\209\139\208\181 \209\141\208\188\208\190\209\134\208\184\208\184 \209\129 \208\156\208\176\209\128\208\186\208\181\209\130\208\191\208\187\208\181\208\185\209\129\208\176",
descfreeemotes = "\239\191\189\208\190\209\128\209\143\209\135\208\176\209\143 \208\186\208\187\208\176\208\178\208\184\209\136\208\176 - \208\183\208\176\208\191\209\143\209\130\208\176\209\143",
fakeknife = "\239\191\189\208\190\208\183\208\180\208\176\209\130\209\140 \209\132\208\181\208\185\208\186\208\190\208\178\209\139\208\185 \208\189\208\190\208\182",
sprint = "\239\191\189\208\181\208\179",
shootmurder = "\239\191\189\209\139\209\129\209\130\209\128\208\181\208\187\208\184\209\130\209\140 \208\178 \209\131\208\177\208\184\208\185\209\134\209\131",
viewsheriff = "\239\191\189\208\188\208\190\209\130\209\128\208\181\209\130\209\140 \208\183\208\176 \209\136\208\181\209\128\208\184\209\132\208\190\208\188",
silentaimtype = "\239\191\189\208\184\208\191 \209\130\208\184\209\133\208\190\208\179\208\190 \208\176\208\184\208\188\208\176 [\208\159\208\184\209\129\209\130\208\190\208\187\208\181\209\130]",
togsilentaim = "\239\191\189\208\184\209\133\208\184\208\185 \208\176\208\184\208\188 \208\189\208\176 \208\186\208\187\208\176\208\178\208\184\209\136\209\131 [\208\159\208\184\209\129\209\130\208\190\208\187\208\181\209\130]",
silentaim = "\239\191\189\208\184\209\133\208\184\208\185 \208\144\208\184\208\188 \208\154\208\187\208\176\208\178\208\184\209\136\208\176",
aimbot = "\239\191\189\208\184\208\188\208\177\208\190\209\130",
prediction = "\239\191\189\209\128\208\181\208\180\209\129\208\186\208\176\208\183\208\176\208\189\208\184\208\181 \208\180\208\178\208\184\208\182\208\181\208\189\208\184\209\143",
fovradius = "\239\191\189\208\176\208\180\208\184\209\131\209\129 FOV",
autokillall = "\239\191\189\208\178\209\130\208\190 \209\131\208\177\208\184\208\185\209\129\209\130\208\178\208\190 \208\178\209\129\208\181\209\133",
selectplayers = "\239\191\189\209\139\208\177\209\128\208\176\209\130\209\140 \208\184\208\179\209\128\208\190\208\186\208\190\208\178",
autokillselected = "\239\191\189\208\178\209\130\208\190 \209\131\208\177\208\184\208\185\209\129\209\130\208\178\208\190 \208\178\209\139\208\177\209\128\208\176\208\189\208\189\209\139\209\133",
killsheriff = "\239\191\189\208\177\208\184\209\130\209\140 \209\136\208\181\209\128\208\184\209\132\208\176",
autokillsheriff = "\239\191\189\208\178\209\130\208\190 \209\131\208\177\208\184\208\185\209\129\209\130\208\178\208\190 \209\136\208\181\209\128\208\184\209\132\208\176",
viewmurder = "\239\191\189\208\188\208\190\209\130\209\128\208\181\209\130\209\140 \208\183\208\176 \209\131\208\177\208\184\208\185\209\134\208\181\208\185",
knifeaura = "\239\191\189\208\177\208\184\208\185\209\129\209\130\208\178\208\181\208\189\208\189\208\176\209\143 \208\176\209\131\209\128\208\176 \208\189\208\190\208\182\208\176",
knifeaurarange = "\239\191\189\208\176\208\180\208\184\209\131\209\129 \208\176\209\131\209\128\209\139 \208\189\208\190\208\182\208\176",
selectplayerfling = "\239\191\189\209\139\208\177\209\128\208\176\209\130\209\140 \208\184\208\179\209\128\208\190\208\186\208\176 \208\180\208\187\209\143 \209\132\208\187\208\184\208\189\208\179\208\176",
flingplayer = "\239\191\189\208\187\208\184\208\189\208\179\208\190\208\178\208\176\209\130\209\140 \208\184\208\179\209\128\208\190\208\186\208\176",
flingmurder = "\239\191\189\208\187\208\184\208\189\208\179\208\190\208\178\208\176\209\130\209\140 \209\131\208\177\208\184\208\185\209\134\209\131",
flingsheriff = "\239\191\189\208\187\208\184\208\189\208\179\208\190\208\178\208\176\209\130\209\140 \209\136\208\181\209\128\208\184\209\132\208\176",
flingstrenght = "\239\191\189\208\184\208\187\208\176 \209\132\208\187\208\184\208\189\208\179\208\176",
layonback = "\239\191\189\208\181\209\135\209\140 \208\189\208\176 \209\129\208\191\208\184\208\189\209\131",
sitdown = "\239\191\189\208\181\209\129\209\130\209\140",
espplayers = "ESP \208\178\209\129\208\181\209\133 \208\184\208\179\209\128\208\190\208\186\208\190\208\178 [\208\191\208\176\209\130\209\135 2 \208\189\208\190\209\143\208\177\209\128\209\143]",
esptrans = "ESP \208\159\209\128\208\190\208\183\209\128\208\176\209\135\208\189\208\190\209\129\209\130\209\140 [\209\129\209\130\208\176\209\128\209\139\208\185]",
playersnameesp = "ESP \208\152\208\188\208\181\208\189\208\176",
espdropgun = "\239\191\189\208\190\208\186\208\176\208\183\208\176\209\130\209\140 \209\131\208\191\208\176\208\178\209\136\208\181\208\181 \208\190\209\128\209\131\208\182\208\184\208\181",
innoesp = "\239\191\189\208\190\208\186\208\176\208\183\208\176\209\130\209\140 \208\156\208\184\209\128\208\189\209\139\209\133",
sheresp = "\239\191\189\208\190\208\186\208\176\208\183\208\176\209\130\209\140 \208\168\208\181\209\128\208\184\209\132\208\176",
murdesp = "\239\191\189\208\190\208\186\208\176\208\183\208\176\209\130\209\140 \208\163\208\177\208\184\208\185\209\134\209\131",
showdead = "\239\191\189\208\190\208\186\208\176\208\183\208\176\209\130\209\140 \208\156\208\181\209\128\209\130\208\178\209\139\209\133",
boxesmurd = "\239\191\189\208\190\208\186\208\176\208\183\208\176\209\130\209\140 \208\177\208\190\208\186\209\129\209\139 \208\163\208\177\208\184\208\185\209\134\209\139",
boxessher = "\239\191\189\208\190\208\186\208\176\208\183\208\176\209\130\209\140 \208\177\208\190\208\186\209\129\209\139 \208\168\208\181\209\128\208\184\209\132\208\176",
boxesinno = "\239\191\189\208\190\208\186\208\176\208\183\208\176\209\130\209\140 \208\177\208\190\208\186\209\129\209\139 \208\156\208\184\209\128\208\189\209\139\209\133",
xray = "\239\191\189\208\181\208\189\209\130\208\179\208\181\208\189",
xraytrans = "\239\191\189\209\128\208\190\208\183\209\128\208\176\209\135\208\189\208\190\209\129\209\130\209\140 \209\128\208\181\208\189\209\130\208\179\208\181\208\189\208\176",
improvefps = "\239\191\189\208\191\209\130\208\184\208\188\208\184\208\183\208\176\209\134\208\184\209\143 FPS",
boombox = "\239\191\189\209\131\208\188\208\177\208\190\208\186\209\129",
hitboxexpander = "\239\191\189\208\176\209\129\209\136\208\184\209\128\208\184\209\130\208\181\208\187\209\140 \209\133\208\184\209\130\208\177\208\190\208\186\209\129\208\190\208\178",
hitboxsize = "\239\191\189\208\176\208\183\208\188\208\181\209\128 \209\133\208\184\209\130\208\177\208\190\208\186\209\129\208\176",
hitboxcolor = "\239\191\189\208\178\208\181\209\130 \209\133\208\184\209\130\208\177\208\190\208\186\209\129\208\176",
skyboxselector = "\239\191\189\209\139\208\177\208\190\209\128 \208\189\208\181\208\177\208\176",
customcursor = "\239\191\189\208\176\209\129\209\130\208\190\208\188\208\189\209\139\208\185 \208\186\209\131\209\128\209\129\208\190\209\128",
ninja = "\239\191\189\208\184\208\189\208\180\208\183\209\143",
sit = "\239\191\189\208\184\208\180\208\181\209\130\209\140",
headless = "\239\191\189\208\181\208\183\208\179\208\190\208\187\208\190\208\178\209\139\208\185",
dab = "\239\191\189\209\141\208\177",
zen = "\239\191\189\208\183\208\181\208\189",
floss = "\239\191\189\208\187\208\190\209\129\209\129",
zombie = "\239\191\189\208\190\208\188\208\177\208\184",
wave = "\239\191\189\209\128\208\184\208\178\208\181\209\130!",
cheer = "\239\191\189\208\191\208\187\208\190\208\180\208\184\209\128\208\190\208\178\208\176\209\130\209\140",
laugh = "\239\191\189\208\188\208\181\209\143\209\130\209\140\209\129\209\143",
breakgun = "\239\191\189\208\187\208\190\208\188\208\176\209\130\209\140 \208\191\208\184\209\129\209\130\208\190\208\187\208\181\209\130",
autobreakgun = "\239\191\189\208\178\209\130\208\190 \208\187\208\190\208\188\208\176\208\189\208\184\208\181 \208\191\208\184\209\129\209\130\208\190\208\187\208\181\209\130\208\176",
antitrap = "\239\191\189\208\189\209\130\208\184 \208\187\208\190\208\178\209\131\209\136\208\186\208\176",
antifling = "\239\191\189\208\189\209\130\208\184 \209\132\208\187\208\184\208\189\208\179",
antiafk = "\239\191\189\208\189\209\130\208\184 \208\176\209\132\208\186",
gundropnotify = "\239\191\189\208\178\208\181\208\180\208\190\208\188\208\187\208\181\208\189\208\184\208\181 \208\190\208\177 \208\191\208\190\209\143\208\178\208\187\208\181\208\189\208\184\208\184 \208\191\208\184\209\129\209\130\208\190\208\187\208\181\209\130\208\176",
exposeroles = "\239\191\189\208\176\208\183\208\190\208\177\208\187\208\176\209\135\208\184\209\130\209\140 \209\128\208\190\208\187\208\184 \208\178 \209\135\208\176\209\130",
devconsole = "\239\191\189\208\190\208\189\209\129\208\190\208\187\209\140 \209\128\208\176\208\183\209\128\208\176\208\177\208\190\209\130\209\135\208\184\208\186\208\176",
rejoin = "\239\191\189\208\181\209\128\208\181\208\191\208\190\208\180\208\186\208\187\209\142\209\135\208\184\209\130\209\140\209\129\209\143",
serverhop = "\239\191\189\208\188\208\181\208\189\208\184\209\130\209\140 \209\129\208\181\209\128\208\178\208\181\209\128",
autofarm = "\239\191\189\208\178\209\130\208\190\209\132\208\176\209\128\208\188",
descautofarm = "\239\191\189\208\178\209\130\208\190\208\188\208\176\209\130\208\184\209\135\208\181\209\129\208\186\208\184\208\185 \209\132\208\176\209\128\208\188 \208\188\208\190\208\189\208\181\209\130 \208\184 \208\181\209\137\208\181 \209\135\208\181\208\179\208\190-\209\130\208\190",
endround = "\239\191\189\208\176\208\178\208\181\209\128\209\136\208\184\209\130\209\140 \209\128\208\176\209\131\208\189\208\180, \208\181\209\129\208\187\208\184 \208\178\209\139 \208\188\208\181\209\128\209\130\208\178\209\139 \208\184\208\187\208\184 \208\189\208\181 \209\131\209\135\208\176\209\129\209\130\208\178\209\131\208\181\209\130\208\181 \208\178 \208\189\208\181\208\188",
descendround = "\239\191\189\208\184\209\128\208\189\209\139\208\185 = \209\132\208\187\208\184\208\189\208\179 \209\131\208\177\208\184\208\185\209\134\209\131 \n\208\168\208\181\209\128\208\184\209\132 = \209\132\208\187\208\184\208\189\208\179 \209\131\208\177\208\184\208\185\209\134\209\131",
endroundkill = "\239\191\189\208\177\208\184\209\130\209\140 \208\178\209\129\208\181\209\133 \208\191\208\190\209\129\208\187\208\181 \209\132\208\176\209\128\208\188\208\176",
descendroundkill = "\239\191\189\208\177\208\184\208\185\209\134\208\176 = \209\131\208\177\208\184\209\130\209\140 \208\178\209\129\208\181\209\133",
farmspeed = "\239\191\189\208\186\208\190\209\128\208\190\209\129\209\130\209\140 \208\176\208\178\209\130\208\190\209\132\208\176\209\128\208\188\208\176",
descfarmspeed = "\239\191\189\208\181\208\186\208\190\208\188\208\181\208\189\208\180\209\131\208\181\209\130\209\129\209\143 22, \209\135\209\130\208\190\208\177\209\139 \208\184\208\183\208\177\208\181\208\182\208\176\209\130\209\140 \208\176\208\189\209\130\208\184\209\135\208\184\209\130\208\176",
reportcategory = "\239\191\189\209\139\208\177\208\181\209\128\208\184\209\130\208\181 \208\186\208\176\209\130\208\181\208\179\208\190\209\128\208\184\209\142 \208\182\208\176\208\187\208\190\208\177\209\139",
placeholderreport = "\239\191\189\208\191\208\184\209\136\208\184\209\130\208\181 \208\191\209\128\208\190\208\177\208\187\208\181\208\188\209\131 (\208\189\208\176 \208\176\208\189\208\179\208\187\208\184\208\185\209\129\208\186\208\190\208\188 \208\184\208\187\208\184 \209\128\209\131\209\129\209\129\208\186\208\190\208\188)",
sendreport = "\239\191\189\209\130\208\191\209\128\208\176\208\178\208\184\209\130\209\140 \208\182\208\176\208\187\208\190\208\177\209\131",
youtube = "\239\191\189\208\190\208\185 \209\142\209\130\209\131\208\177 \208\154\208\176\208\189\208\176\208\187",
openhub = "\239\191\189\208\187\208\176\208\178\208\184\209\136\208\176 \208\180\208\187\209\143 \208\190\209\130\208\186\209\128\209\139\209\130\208\184\209\143 \209\129\208\186\209\128\208\184\208\191\209\130\208\176",
selecttheme = "\239\191\189\209\139\208\177\209\128\208\176\209\130\209\140 \209\130\208\181\208\188\209\131",
selectbackground = "\239\191\189\209\139\208\177\209\128\208\176\209\130\209\140 \209\132\208\190\208\189",
backgroundtrans = "\239\191\189\209\128\208\190\208\183\209\128\208\176\209\135\208\189\208\190\209\129\209\130\209\140 \209\132\208\190\208\189\208\176",
config = "\239\191\189\208\186\208\190\209\128\208\190 \208\177\209\131\208\180\209\131\209\130 \208\186\208\190\208\189\209\132\208\184\208\179\208\184, \208\189\208\176\208\178\208\181\209\128\208\189\208\190\208\181",
language = "\239\191\189\208\188\208\181\208\189\208\184\209\130\209\140 \209\143\208\183\209\139\208\186",
forgot = "\239\191\189\208\176\208\177\209\139\209\130\209\140 \209\143\208\183\209\139\208\186",
invis = "\239\191\189\208\181\208\178\208\184\208\180\208\184\208\188\208\190\209\129\209\130\209\140",
ragdoll = "\239\191\189\208\190\208\183\208\180\208\176\209\130\209\140 \208\184\208\189\209\129\209\130\209\128\209\131\208\188\208\181\208\189\209\130 \209\128\209\141\208\179\208\180\208\190\208\187\208\176",
bang = "\239\191\189\209\128\208\176\209\133\208\189\209\131\209\130\209\140",
inputbang = "\239\191\189\208\188\209\143 \209\134\208\181\208\187\208\184",
getsuck = "\239\191\189\209\139\208\181\208\177\208\176\209\130\209\140 \208\178 \209\128\208\190\209\130",
boxesdead = "\239\191\189\208\190\208\186\208\176\208\183\208\176\209\130\209\140 \208\177\208\190\208\186\209\129\209\139 \208\188\208\181\209\128\209\130\208\178\209\139\209\133",
coinaura = "\239\191\189\208\190\208\189\208\181\209\130\208\189\208\176\209\143 \208\144\209\131\209\128\208\176",
coinauraslider = "\239\191\189\208\190\208\189\208\181\209\130\208\189\208\176\209\143 \208\144\209\131\209\128\208\176 \208\191\208\190\208\187\208\183\209\131\208\189\208\190\208\186",
desccoinaura = "\239\191\189\208\178\208\181\208\187\208\184\209\135\208\184\208\178\208\176\208\181\209\130 \209\130\208\178\208\190\208\185 \209\133\208\184\209\130\208\177\208\190\208\186\209\129 \208\180\208\187\209\143 \208\191\208\190\208\180\208\177\208\184\209\128\208\176\208\189\208\184\209\143 \208\188\208\190\208\189\208\181\209\130",
espfix = "\239\191\189\208\189\209\130\208\184 \208\176\209\132\208\186 \208\178\208\186\208\187\209\142\209\135\208\176\208\181\209\130\209\129\209\143 \208\191\208\190 \208\180\208\181\209\132\208\190\208\187\209\130\209\131 \208\184 \208\176\208\189\209\130\208\184 \209\132\208\187\208\184\208\189\208\179, \208\178\208\186\208\187\208\176\208\180\208\186\208\184 \208\186\208\190\208\188\208\177\208\176\209\130 \208\184 \209\130\209\128\208\190\208\187\208\187\208\184\208\189\208\179 \208\177\208\187\208\190\208\186\208\184\209\128\209\131\209\142\209\130\209\129\209\143 \208\178\208\190 \208\178\209\128\208\181\208\188\209\143 \208\176\208\178\209\130\208\190\209\132\208\176\209\128\208\188\208\176",
autoshoot = "\239\191\189\208\178\209\130\208\190\209\129\209\130\209\128\208\181\208\187\209\140\208\177\208\176 \208\191\208\190 \209\131\208\177\208\184\208\185\209\134\208\181",
sliderautoshoot = "\239\191\189\208\176\208\180\208\184\209\131\209\129 \208\176\208\178\209\130\208\190\209\129\209\130\209\128\208\181\208\187\209\140\208\177\209\139",
viewplayer = "\239\191\189\208\188\208\190\209\130\209\128\208\181\209\130\209\140 \208\183\208\176 \208\178\209\139\208\177\209\128\208\176\208\189\208\189\209\139\208\188 \208\184\208\179\209\128\208\190\208\186\208\190\208\188",
stopview = "\239\191\189\209\128\208\181\208\186\209\128\208\176\209\130\208\184\209\130\209\140 \208\191\209\128\208\190\209\129\208\188\208\190\209\130\209\128",
safetp = "\239\191\189\209\128\208\190\208\178\208\181\208\189\209\140 \208\180\208\187\209\143 \208\191\208\190\208\180\208\177\208\184\209\128\208\176\208\189\208\184\209\143 \208\188\208\190\208\189\208\181\209\130",["3drender"] = "\239\191\189\208\177\209\128\208\176\209\130\209\140 3\208\180 \209\128\208\181\208\189\208\180\208\181\209\128",["3drenderdesc"] = "\239\191\189\208\190\208\188\208\190\208\179\208\176\208\181\209\130 \208\191\208\190\208\178\209\139\209\129\208\184\209\130\209\140 \208\191\209\128\208\190\208\184\208\183\208\178\208\190\208\180\208\184\209\130\208\181\208\187\209\140\208\189\208\190\209\129\209\130\209\140 \209\131\209\129\209\130\209\128\208\190\208\185\209\129\209\130\208\178\208\176 \208\178\208\190 \208\178\209\128\208\181\208\188\209\143 \209\132\208\176\209\128\208\188\208\176",
inputview = "\239\191\189\208\188\209\143 \209\134\208\181\208\187\208\184 \208\180\208\187\209\143 \208\191\209\128\208\190\209\129\208\188\208\190\209\130\209\128\208\176",
autoexposeroles = "\239\191\189\208\178\209\130\208\190 \209\128\208\176\208\183\208\190\208\177\208\187\208\176\209\135\208\181\208\189\208\184\208\181 \209\128\208\190\208\187\208\181\208\185 \208\178 \209\135\208\176\209\130",
togglefov = "\239\191\189\208\186\208\187\209\142\209\135\208\184\209\130\209\140 \208\191\208\190\208\187\208\181 \208\183\209\128\208\181\208\189\208\184\209\143",
cameranoclip = "\239\191\189\208\176\208\188\208\181\209\128\208\176 \208\189\208\190\209\131\208\186\208\187\208\184\208\191",
autoclutchbomb = "\239\191\189\208\178\208\190\208\185\208\189\208\190\208\185 \208\191\209\128\209\139\208\182\208\190\208\186 \208\177\208\190\208\188\208\177\208\190\208\185",
keybindclutch = "\239\191\189\208\186\208\187\209\142\209\135\208\184\209\130\209\140 \208\180\208\178\208\190\208\185\208\189\208\190\208\185 \208\191\209\128\209\139\208\182\208\190\208\186 \208\177\208\190\208\188\208\177\208\190\208\185",
speedglitchslider = "\239\191\189\208\190\208\187\208\183\209\131\208\189\208\190\208\186 \209\129\208\191\208\184\208\180\208\179\208\187\208\184\209\130\209\135",
fakespeedglitch = "\239\191\189\208\181\208\185\208\186 \209\129\208\191\208\184\208\180\208\179\208\187\208\184\209\130\209\135",
throwknife = "\239\191\189\208\177\208\184\208\185\209\129\209\130\208\178\208\181\208\189\208\189\208\176\209\143 \208\176\209\131\209\128\208\176 \208\187\208\181\209\130\209\143\209\137\208\181\208\179\208\190 \208\189\208\190\208\182\208\176",
throwaura = "\239\191\189\208\176\209\129\209\130\209\128\208\190\208\184\209\130\209\140 \208\176\209\131\209\128\209\131 \208\187\208\181\209\130\209\143\209\137\208\181\208\179\208\190 \208\189\208\190\208\182\208\176",
silentaimtypeKNIFE = "\239\191\189\208\184\208\191 \209\130\208\184\209\133\208\190\208\179\208\190 \208\176\208\184\208\188\208\176 [\208\157\208\190\208\182]",
selecttargetinfov = "\239\191\189\208\190\208\186\208\176\208\183\208\176\209\130\209\140 \208\178\209\139\208\177\209\128\208\176\208\189\208\189\209\131\209\142 \209\134\208\181\208\187\209\140",
showprediction = "\239\191\189\208\190\208\186\208\176\208\183\208\176\209\130\209\140 \208\191\209\128\208\181\208\180\209\129\208\186\208\176\208\183\208\176\208\189\208\184\208\181",
showfovcircle = "\239\191\189\208\190\208\186\208\176\208\183\208\176\209\130\209\140 \208\186\209\128\209\131\208\179 \208\190\208\177\208\189\208\176\209\128\209\131\208\182\208\181\208\189\208\184\209\143",
fovsizeknife = "\239\191\189\208\176\209\129\209\130\209\128\208\190\208\184\209\130\209\140 \208\186\209\128\209\131\208\179 \208\190\208\177\208\189\208\176\209\128\209\131\208\182\208\181\208\189\208\184\209\143",
togsilentaimKNIFE = "\239\191\189\208\190\208\183\208\180\208\176\209\130\209\140 \208\186\208\187\208\176\208\178\208\184\209\136\209\131 \209\130\208\184\209\133\208\190\208\179\208\190 \208\176\208\184\208\188\208\176",
silentaimKNIFE = "\239\191\189\208\184\209\133\208\184\208\185 \208\176\208\184\208\188 \208\189\208\176 \208\186\208\187\208\176\208\178\208\184\209\136\209\131 [\208\157\208\190\208\182]",
espcoins = "\239\191\189\208\190\208\186\208\176\208\183\208\176\209\130\209\140 \208\188\208\190\208\189\208\181\209\130\208\186\208\184",
seethrownknife = "\239\191\189\208\190\208\186\208\176\208\183\208\176\209\130\209\140 \208\187\208\181\209\130\209\143\209\137\208\184\208\185 \208\189\208\190\208\182",
hitboxtrans = "\239\191\189\208\176\209\129\209\130\209\128\208\190\208\184\209\130\209\140 \208\191\209\128\208\190\208\183\209\128\208\176\209\135\208\189\208\190\209\129\209\130\209\140 \209\133\208\184\209\130\208\177\208\190\208\186\209\129\208\190\208\178",
muteradio = "\239\191\189\209\131\209\130\208\189\209\131\209\130\209\140 \208\178\209\129\208\181 \208\177\209\131\208\188\208\177\208\190\208\186\209\129\209\139",
viewgundrop = "\239\191\189\208\188\208\190\209\130\209\128\208\181\209\130\209\140 \208\183\208\176 \208\191\208\176\208\178\209\136\208\184\208\188 \208\191\208\184\209\129\209\130\208\190\208\187\208\181\209\130\208\190\208\188",
showtimer = "\239\191\189\208\190\208\186\208\176\208\183\208\176\209\130\209\140 \208\178\209\128\208\181\208\188\209\143 \209\128\208\176\209\131\208\189\208\180\208\176",
inputteleport = "\239\191\189\208\188\209\143 \209\134\208\181\208\187\208\184 \208\180\208\187\209\143 \209\130\208\181\208\187\208\181\208\191\208\190\209\128\209\130\208\176",
inputfling = "\239\191\189\208\188\209\143 \209\134\208\181\208\187\208\184 \208\180\208\187\209\143 \209\132\208\187\208\184\208\189\208\179\208\176",
flingall = "\239\191\189\208\187\208\184\208\189\208\179\208\190\208\178\208\176\209\130\209\140 \208\178\209\129\208\181\209\133",
selectafterfarm = "\239\191\189\209\139\208\177\209\128\208\176\209\130\209\140 \209\141\208\178\208\181\208\189\209\130 \208\191\208\190\209\129\208\187\208\181 \209\132\208\176\209\128\208\188\208\176",
togafterfarm = "\239\191\189\208\178\208\181\208\189\209\130 \208\191\208\190\209\129\208\187\208\181 \209\132\208\176\209\128\208\188\208\176",
optimization = "\239\191\189\208\191\209\130\208\184\208\188\208\184\208\183\208\176\209\134\208\184\209\143 \208\184\208\179\209\128\209\139",
removedeadbody = "\239\191\189\208\180\208\176\208\187\209\143\209\130\209\140 \209\130\209\128\209\131\208\191\209\139",
removecoins = "\239\191\189\208\180\208\176\208\187\209\143\209\130\209\140 \208\188\208\190\208\189\208\181\209\130\209\139",
removeplayersaccesory = "\239\191\189\208\180\208\176\208\187\209\143\209\130\209\140 \208\176\208\186\209\129\208\181\209\129\209\129\209\131\208\176\209\128\209\139 \208\184\208\179\209\128\208\190\208\186\208\190\208\178",
lesslagoptim = "\239\191\189\208\177\209\128\208\176\209\130\209\140 \208\187\208\184\209\136\208\189\208\184\208\181 \208\187\208\176\208\179\208\184",
lowercpuload = "\239\191\189\208\184\208\183\208\186\208\176\209\143 \208\189\208\176\208\179\209\128\209\131\208\183\208\186\208\176 \208\189\208\176 \208\191\209\128\208\190\209\134\208\181\209\129\209\129\208\190\209\128",
showrole = "\239\191\189\208\190\208\186\208\176\208\183\208\176\209\130\209\140 \209\128\208\190\208\187\209\140",
trapgun = "\239\191\189\208\190\209\129\209\130\208\176\208\178\208\184\209\130\209\140 \208\187\208\190\208\178\209\131\209\136\208\186\209\131 \208\191\208\190\208\180 \208\191\208\184\209\129\209\130\208\190\208\187\208\181\209\130",
removeshadow = "\239\191\189\208\177\209\128\208\176\209\130\209\140 \209\130\208\181\208\189\208\184"},
            en = {
ver = "Version " .. versionn,
autofarm_info = "Anti-AFK is enabled by default, and anti-fling is also enabled. The Combat and Trolling tabs are blocked while autofarm is running.",
report_how = "You ping me on Telegram with a message about your report. Your nickname, selected category, and message will be displayed.",
status_script = "Status of the script: " .. statusmm2,
product_type = "Product type: " .. scriptfree,
script_version = "Script version: " .. versionn,
launched_from = "Launched from: " .. launch,
executor = "Executor: " .. v7(),
script_tester = "Script tester: zsharki, qwizkoffc and rdiz890",
age = "Account Age " .. vu14.AccountAge .. " [Day]",
CHARACTER = "Character",
TELEPORT = "Teleport",
COMBAT = "Combat",
TROLLING = "Trolling",
ESP = "ESP",
VISUAL = "Visual",
EMOTES = "Emotes",
OTHER = "Other",
AUTOFARM = "Autofarm",
REPORT_BUGS = "Feedback",
HUB_STATUS = "Hub Status",
ABOUT_SCRIPT = "About Script",
ANOTHER_SCRIPT = "Another Script",
SETTINGS = "Settings",
ws = "Walkspeed",
togws = "Enable Walkspeed",
jump = "Jumppower",
togjump = "Enable Jumppower",
fly = "Fly",
flyspeed = "Fly Speed",
noclip = "Noclip",
infjump = "Infinite Jump",
fov = "FOV",
unlockcam = "Unlock Camera",
reset = "Respawn",
tpgunmode = "Tp To Gun Mode",
grabgun = "Grab Gun",
grabgunkey = "Grab Gun Keybind",
toggrabgunkey = "Toggle Grab Gun Keybind",
autograbgun = "Auto Grab Gun",
tptomap = "Teleport to Map",
tptovote = "Teleport to Voting Room",
tptolobby = "Teleport to Lobby",
tptosecret = "Teleport to Secret",
tptorandom = "Teleport to Random Player",
tptoplayer = "Teleport to Player",
tptomurder = "Teleport to Murderer",
tptosheriff = "Teleport to Sheriff",
autododge = "Auto Dodge Knifes",
godmode = "Extra life",
descgodmode = "Two Lives only for 1 round",
freeemotes = "Free Emotes from Marketplace",
descfreeemotes = "Keybind is comma [,]",
fakeknife = "Create Fake Knife",
sprint = "Sprint",
shootmurder = "Shoot Murderer",
viewsheriff = "View Sheriff",
silentaimtype = "Silent Aim Type [Gun]",
togsilentaim = "Toggle Silent Aim [Gun]",
silentaim = "Silent Aim Keybind [Gun]",
aimbot = "Aimbot",
prediction = "Prediction Movement",
fovradius = "FOV Radius",
autokillall = "Auto Kill All",
selectplayers = "Select Players",
autokillselected = "Auto Kill Selected Players",
killsheriff = "Kill Sheriff",
autokillsheriff = "Auto Kill Sheriff",
viewmurder = "View Murderer",
knifeaura = "Knife Aura",
knifeaurarange = "Knife Aura Range",
selectplayerfling = "Select Player",
flingplayer = "Fling Player",
flingmurder = "Fling Murderer",
flingsheriff = "Fling Sheriff",
flingstrenght = "Fling Strength",
layonback = "Lay On Back",
sitdown = "Sit Down",
espplayers = "ESP All [fix 2st November]",
esptrans = "ESP Transparency [old]",
playersnameesp = "ESP Names",
espdropgun = "ESP Dropped Gun",
innoesp = "Innocent ESP",
sheresp = "Sheriff ESP",
murdesp = "Murderer ESP",
showdead = "Dead ESP",
boxesmurd = "Show Boxes Murderer",
boxessher = "Show Boxes Sheriff",
boxesinno = "Show Boxes Innocents",
xray = "Xray",
xraytrans = "Xray Transparency",
improvefps = "Improve FPS",
boombox = "Boombox",
hitboxexpander = "Hitbox Expander",
hitboxsize = "Hitbox Size",
hitboxcolor = "Hitbox Color",
skyboxselector = "Skybox Selector",
customcursor = "Custom Cursor",
ninja = "Ninja",
sit = "Sit",
headless = "Headless",
dab = "Dab",
zen = "Zen",
floss = "Floss",
zombie = "Zombie",
wave = "Wave",
cheer = "Cheer",
laugh = "Laugh",
breakgun = "Break Gun",
autobreakgun = "Auto Break Gun",
antitrap = "Anti Trap",
antifling = "Anti Fling",
antiafk = "Anti AFK",
gundropnotify = "Gun Drop Notify",
exposeroles = "Expose Roles",
devconsole = "Developer Console",
rejoin = "Rejoin",
serverhop = "Server Hop",
autofarm = "Autofarm",
descautofarm = "Automatically farms Coins/Candy",
endround = "End the round if dead or not in it.",
descendround = "Innocent = fling murderer \nSheriff = fling murderer",
endroundkill = "Kill all when you\'re done farming",
descendroundkill = "Murderer = kill all",
farmspeed = "Autofarm Speed",
descfarmspeed = "Recommended: 22 to avoid Anticheat",
selectafterfarm = "Select an action after farming coins",
togafterfarm = "Action after farming coins",
reportcategory = "Select a Report Category",
placeholderreport = "Describe the problem (English or Russian)",
sendreport = "Send Report",
youtube = "My YouTube Channel",
openhub = "Keybind to Open hub",
selecttheme = "Select Theme",
selectbackground = "Select Background",
backgroundtrans = "Background Transparency",
config = "Config [Soon]",
language = "Change language",
forgot = "Forget language",
invis = "Invisible",
ragdoll = "Create Ragdoll Tool",
bang = "Bang",
inputbang = "Target name",
getsuck = "Fuck in the mouth",
boxesdead = "Show Boxes Dead",
coinaura = "Coin Aura",
desccoinaura = "Increases your hitbox for picking up coins",
coinauraslider = "Coin Aura Slider",
espfix = "On November 1, Nikilis killed esp. I\'ll fix it soon (a rough version is working for now).",
autoshoot = "Autoshoot the murderer",
sliderautoshoot = "Auto-shoot radius",
viewplayer = "View selected player",
inputview = "Target name",
stopview = "Stop viewing",
safetp = "Choose coin-collecting level",["3drender"] = "Disable 3d Render",["3drenderdesc"] = "helps increase fps during farming",
autoexposeroles = "Auto expose roles",
togglefov = "Enable FOV",
cameranoclip = "Camera noclip",
autoclutchbomb = "Auto clutch bomb",
keybindclutch = "Enable auto clutch bomb keybind",
speedglitchslider = "speedglitch adjust",
fakespeedglitch = "Fake speedglitch",
throwknife = "Throw knife aura",
throwaura = "Throw knife aura adjust",
silentaimtypeKNIFE = "Silent Aim Type [Knife]",
selecttargetinfov = "Show target",
showprediction = "Show prediction",
showfovcircle = "FOV circle",
fovsizeknife = "FOV circle size",
togsilentaimKNIFE = "Toggle Silent Aim [Knife]",
silentaimKNIFE = "Silent Aim Keybind [Knife]",
espcoins = "Show coins",
seethrownknife = "Show thrown knife",
hitboxtrans = "Hitbox transparency",
muteradio = "Mute all boomboxes",
viewgundrop = "View dropped gun",
showtimer = "Show timer",
inputteleport = "Teleport target",
inputfling = "Fling target",
flingall = "Fling All",
optimization = "Optimization",
removedeadbody = "Remove dead body",
removecoins = "Remove coins",
removeplayersaccesory = "Remove players acessorys",
lesslagoptim = "Improve fps",
lowercpuload = "Lower cpu load",
showrole = "Show role",
trapgun = "Trap on gundrop",
removeshadow = "Remove Shadows"}
        }
    })
    vu2:SetLanguage(DefaultLanguagee)
    vu2:SetNotificationLower(true)
    local vu33 = vu2:CreateWindow({
        Title = "Thunder Hub MM2" .. icon1,
        Icon = "square-code",
        Author = gradient("by CBO LOVER & Kavo", Color3.fromHex("#6a329f"), Color3.fromHex("#ffd966")),
        Folder = "Thunder MM2",
        Size = UDim2.fromOffset(580, 460),
        MinSize = Vector2.new(560, 350),
        MaxSize = Vector2.new(850, 560),
        Transparent = true,
        Theme = "Rose",
        Resizable = true,
        Background = "rbxassetid://",
        BackgroundImageTransparency = nil,
        User = {
            Enabled = true,
            Callback = function()
                loadstring(game:HttpGet("https://raw.githubusercontent.com/Roma77799/Secrethub/refs/heads/main/OtherSCRIPTS/easteregg", true))()
            end,
            Anonymous = false
        },
        SideBarWidth = 200,
        HideSearchBar = true,
        ScrollBarEnabled = false
    })
    vu33:SetToggleKey(Enum.KeyCode.G)
    vu2:SetTheme("Crimson")
    vu33:Tag({
        Title = "loc:ver",
        Color = Color3.fromHex("#30ff6a")
    })
    local vu34 = {
        character = vu33:Tab({
            Title = "loc:CHARACTER",
            Icon = "person-standing"
        }),
        teleport = vu33:Tab({
            Title = "loc:TELEPORT",
            Icon = "arrow-left-right"
        }),
        combat = vu33:Tab({
            Title = "loc:COMBAT",
            Icon = "swords",
            Locked = false
        }),
        troll = vu33:Tab({
            Title = "loc:TROLLING",
            Icon = "angry",
            Locked = false
        }),
        esp = vu33:Tab({
            Title = "loc:ESP",
            Icon = "person-standing"
        }),
        visual = vu33:Tab({
            Title = "loc:VISUAL",
            Icon = "eye"
        }),
        emotes = vu33:Tab({
            Title = "loc:EMOTES",
            Icon = "smile"
        }),
        other = vu33:Tab({
            Title = "loc:OTHER",
            Icon = "power"
        }),
        autofarm = vu33:Tab({
            Title = "loc:AUTOFARM",
            Icon = "puzzle"
        }),
        report = vu33:Tab({
            Title = "loc:REPORT_BUGS",
            Icon = "bug"
        }),
        status = vu33:Tab({
            Title = "loc:HUB_STATUS",
            Icon = "siren"
        }),
        changelog = vu33:Tab({
            Title = "loc:ABOUT_SCRIPT",
            Icon = "badge-info"
        }),
        another = vu33:Tab({
            Title = "loc:ANOTHER_SCRIPT",
            Icon = "unlink"
        }),
        divider1 = vu33:Divider(),
        settings = vu33:Tab({
            Title = "loc:SETTINGS",
            Icon = "settings"
        }),
        be = vu33:Divider()
    }
    vu33:SelectTab(2)
    defualtwalkspeed = 16
    defualtjumppower = 50
    newwalkspeed = defualtwalkspeed
    newjumppower = defualtjumppower
    _G.vu35 = 50
_G.vu36 = nil
_G.vu37 = nil
    local vu38 = nil
    local vu39 = nil
    local vu40 = nil
    local vu41 = nil
    local vu42 = game.Players.LocalPlayer
    local vu43 = {
        W = false,
        S = false,
        A = false,
        D = false,
        Moving = false
    }
    function startFly()
        if vu42.Character and (vu42.Character.Head and not vu41) then
            vu36 = vu42.Character
            vu37 = vu36.Humanoid
            vu37.PlatformStand = true
            vu40 = vu12:WaitForChild("Camera")
            vu38 = Instance.new("BodyVelocity")
            vu39 = Instance.new("BodyAngularVelocity")
            local v44 = vu38
            local v45 = vu38
            local v46 = vu38
            local v47 = Vector3.new(0, 0, 0)
            local v48 = Vector3.new(10000, 10000, 10000)
            v46.P = 1000
            v45.MaxForce = v48
            v44.Velocity = v47
            local v49 = vu39
            local v50 = vu39
            local v51 = vu39
            local v52 = Vector3.new(0, 0, 0)
            local v53 = Vector3.new(10000, 10000, 10000)
            v51.P = 1000
            v50.MaxTorque = v53
            v49.AngularVelocity = v52
            vu38.Parent = vu36.Head
            vu39.Parent = vu36.Head
            vu41 = true
            vu37.Died:connect(function()
                vu41 = false
            end)
        end
    end
    function endFly()
        if vu42.Character and vu41 then
            vu37.PlatformStand = false
            vu38:Destroy()
            vu39:Destroy()
            vu41 = false
        end
    end
    function setVec(p54)
        return p54 * (vu35 / p54.Magnitude)
    end
    vu34.character:Slider({
        Title = "loc:ws",
        Value = {
            Min = 16,
            Max = 500,
            Default = 16
        },
        Callback = function(p55)
            newwalkspeed = tonumber(p55)
        end
    })
    vu34.character:Toggle({
        Title = "loc:togws",
        Value = false,
        Callback = function(p56)
            loopwalkspeed = p56
            while loopwalkspeed do
                vu14.Character:WaitForChild("Humanoid").WalkSpeed = newwalkspeed
                wait()
            end
            wait()
            vu14.Character:WaitForChild("Humanoid").WalkSpeed = defualtwalkspeed
            wait()
        end
    })
    vu34.character:Slider({
        Title = "loc:jump",
        Value = {
            Min = 50,
            Max = 500,
            Default = 50
        },
        Callback = function(p57)
            newjumppower = tonumber(p57)
        end
    })
    vu34.character:Toggle({
        Title = "loc:togjump",
        Value = false,
        Callback = function(p58)
            loopjumppower = p58
            while loopjumppower do
                vu14.Character:WaitForChild("Humanoid").JumpPower = newjumppower
                wait()
            end
            wait()
            vu14.Character:WaitForChild("Humanoid").JumpPower = defualtjumppower
            wait()
        end
    })
    vu34.character:Slider({
        Title = "loc:flyspeed",
        Value = {
            Min = 50,
            Max = 500,
            Default = vu35
        },
        Callback = function(p59)
            vu35 = tonumber(p59)
        end
    })
    vu34.character:Toggle({
        Title = "loc:fly",
        Value = false,
        Callback = function(p60)
            if flyfirst ~= true then
                flyfirst = true
                game:GetService("UserInputService").InputBegan:connect(function(p61, p62)
                    if not p62 then
                        local v63, v64, v65 = pairs(vu43)
                        while true do
                            local v66
                            v65, v66 = v63(v64, v65)
                            if v65 == nil then
                                break
                            end
                            if v65 ~= "Moving" and p61.KeyCode == Enum.KeyCode[v65] then
                                vu43[v65] = true
                                vu43.Moving = true
                            end
                        end
                    end
                end)
                game:GetService("UserInputService").InputEnded:connect(function(p67, p68)
                    if not p68 then
                        local v69, v70, v71 = pairs(vu43)
                        local v72 = false
                        while true do
                            local v73
                            v71, v73 = v69(v70, v71)
                            if v71 == nil then
                                break
                            end
                            if v71 ~= "Moving" then
                                if p67.KeyCode == Enum.KeyCode[v71] then
                                    vu43[v71] = false
                                end
                                if vu43[v71] then
                                    v72 = true
                                end
                            end
                        end
                        vu43.Moving = v72
                    end
                end)
                game:GetService("RunService").Heartbeat:connect(function(p74)
                    if vu41 and (vu36 and vu36.PrimaryPart) then
                        local v75 = vu36.PrimaryPart.Position
                        local v76 = vu40.CFrame
                        local v77, v78, v79 = v76:toEulerAnglesXYZ()
                        vu36:SetPrimaryPartCFrame(CFrame.new(v75.x, v75.y, v75.z) * CFrame.Angles(v77, v78, v79))
                        if vu43.Moving then
                            local v80 = Vector3.new()
                            if vu43.W then
                                v80 = v80 + setVec(v76.lookVector)
                            end
                            if vu43.S then
                                v80 = v80 - setVec(v76.lookVector)
                            end
                            if vu43.A then
                                v80 = v80 - setVec(v76.rightVector)
                            end
                            if vu43.D then
                                v80 = v80 + setVec(v76.rightVector)
                            end
                            vu36:TranslateBy(v80 * p74)
                        end
                    end
                end)
            end
            if p60 == true then
                startFly()
            elseif p60 == false then
                endFly()
            end
        end
    })
    vu34.character:Toggle({
        Title = "loc:noclip",
        Value = false,
        Callback = function(p81)
            loopnoclip = p81
            while loopnoclip do
                function loopnoclipfix()
                    local v82, v83, v84 = pairs(game.Workspace:GetChildren())
                    while true do
                        local v85
                        v84, v85 = v82(v83, v84)
                        if v84 == nil then
                            break
                        end
                        if v85.Name == game.Players.LocalPlayer.Name then
                            local v86, v87, v88 = pairs(game.Workspace[game.Players.LocalPlayer.Name]:GetChildren())
                            while true do
                                local v89
                                v88, v89 = v86(v87, v88)
                                if v88 == nil then
                                    break
                                end
                                if v89:IsA("BasePart") then
                                    v89.CanCollide = false
                                end
                            end
                        end
                    end
                    wait()
                end
                wait()
                pcall(loopnoclipfix)
            end
        end
    })
    local v90 = game:GetService("UserInputService")
    local vu91 = false
    vu34.character:Toggle({
        Title = "loc:infjump",
        Compact = true,
        Callback = function(p92)
            vu91 = p92
        end
    })
    v90.JumpRequest:Connect(function()
        local v93 = vu91 and vu14.Character and vu14.Character:FindFirstChildOfClass("Humanoid")
        if v93 then
            v93:ChangeState("Jumping")
        end
    end)
    getgenv().config = {
        FOV = 80,
        FOVEnabled = false
    }
    vu34.character:Slider({
        Title = "loc:fov",
        Value = {
            Min = 0,
            Max = 120,
            Default = 70
        },
        Callback = function(p94)
            getgenv().config.FOV = p94
            if getgenv().config.FOVEnabled then
                vu12.CurrentCamera.FieldOfView = p94
            end
        end
    })
    vu34.character:Toggle({
        Title = "loc:togglefov",
        Value = false,
        Callback = function(p95)
            getgenv().config.FOVEnabled = p95
            if p95 then
                vu12.CurrentCamera.FieldOfView = getgenv().config.FOV
            else
                vu12.CurrentCamera.FieldOfView = 70
            end
        end
    })
    local vu96 = 0.2
    local vu97 = false
    vu34.character:Toggle({
        Title = "loc:cameranoclip",
        Value = false,
        Callback = function(p98)
            vu97 = p98
        end
    })
    local vu99 = {}
    local vu100 = {}
    local vu101 = {
        front = 1,
        back = 1,
        vertical = 1,
        horizontal = 3
    }
    local vu102 = OverlapParams.new()
    vu102.FilterType = Enum.RaycastFilterType.Exclude
    function makeTransparent(p103, p104)
        if p103:IsA("BasePart") and p103.Transparency < 1 then
            p104[p103] = true
            if not vu99[p103] then
                vu99[p103] = p103.Transparency
            end
            p103.Transparency = 0.5
        end
    end
    vu10.RenderStepped:Connect(function()
        if vu97 then
            local v105 = vu14.Character
            if v105 then
                local v106 = v105:FindFirstChild("Head")
                local v107 = v105:FindFirstChild("HumanoidRootPart")
                local v108 = v105:FindFirstChild("UpperTorso")
                if v106 and v107 then
                    local v109 = vu8.CFrame.Position
                    local v110 = v109 - vu8.CFrame.LookVector * 3
                    vu102.FilterDescendantsInstances = {
                        v105
                    }
                    local v111 = pairs
                    local v112 = {}
                    local v113 = vu15
                    local v114 = vu15
                    local v115 = vu15
                    __set_list(v112, 1, {
                        vu15:GetPartBoundsInRadius(v109, vu101.front, vu102),
                        v113:GetPartBoundsInRadius(v110, vu101.back, vu102),
                        v114:GetPartBoundsInRadius(v109, vu101.vertical, vu102),
                        v115:GetPartBoundsInRadius(v109, vu101.horizontal, vu102)
                    })
                    local v116, v117, v118 = v111(v112)
                    local v119 = {}
                    while true do
                        local v120
                        v118, v120 = v116(v117, v118)
                        if v118 == nil then
                            break
                        end
                        local v121, v122, v123 = pairs(v120)
                        while true do
                            local v124
                            v123, v124 = v121(v122, v123)
                            if v123 == nil then
                                break
                            end
                            v119[v124] = true
                        end
                    end
                    local vu125 = {}
                    local v126 = RaycastParams.new()
                    v126.FilterType = Enum.RaycastFilterType.Exclude
                    v126.FilterDescendantsInstances = {
                        v105
                    }
                    v126.IgnoreWater = true
                    local v127 = ipairs
                    local v128 = {}
                    local v129 = v106.Position
                    local v130 = v107.Position
                    if v108 then
                        v108 = v108.Position
                    end
                    __set_list(v128, 1, {
                        v129,
                        v130,
                        v108
                    })
                    local v131, v132, v133 = v127(v128)
                    while true do
                        local v134, v135 = v131(v132, v133)
                        if v134 == nil then
                            break
                        end
                        v133 = v134
                        if v135 then
                            local v136 = vu15:Raycast(v109, v135 - v109, v126)
                            if v136 and v136.Instance then
                                makeTransparent(v136.Instance, vu125)
                            end
                        end
                    end
                    local v137, v138, v139 = pairs(v119)
                    while true do
                        v139 = v137(v138, v139)
                        if v139 == nil then
                            break
                        end
                        makeTransparent(v139, vu125)
                    end
                    local v140, v141, v142 = pairs(vu99)
                    while true do
                        local vu143, vu144 = v140(v141, v142)
                        if vu143 == nil then
                            break
                        end
                        v142 = vu143
                        if not (vu125[vu143] or vu100[vu143]) then
                            vu100[vu143] = true
                            task.delay(vu96, function()
                                if vu143 and (vu143:IsDescendantOf(vu15) and not vu125[vu143]) then
                                    vu143.Transparency = vu144
                                    vu99[vu143] = nil
                                end
                                vu100[vu143] = nil
                            end)
                        end
                    end
                end
            else
                return
            end
        else
            return
        end
    end)
    vu34.character:Toggle({
        Title = "loc:unlockcam",
        Value = false,
        Callback = function(p145)
            local v146 = game.Players.LocalPlayer
            if p145 then
                v146.CameraMaxZoomDistance = 99999999999
                v146.CameraMinZoomDistance = 0.5
            else
                v146.CameraMaxZoomDistance = 15
                v146.CameraMinZoomDistance = 0.5
            end
        end
    })
    vu34.character:Button({
        Title = "loc:reset",
        Desc = "",
        Callback = function()
            game.Players.LocalPlayer.Character.Humanoid.Health = 0
        end
    })
    vu34.teleport:Section({
        Title = "Grabber"
    })
    grabber = false
    gunsupport = false
    local vu147 = typeof(firetouchinterest) == "function"
    local v149 = vu34.teleport:Dropdown({
        Title = "loc:tpgunmode",
        Values = {
            "Default",
            "Remote"
        },
        Value = "Default",
        Callback = function(p148)
            if p148 == "Remote" then
                gunsupport = true
            else
                gunsupport = false
            end
        end
    })
    if not vu147 then
        v149:Lock()
        sendnotification("firetouchinterest not supported, locked to default teleport")
    end
    local function vu160()
        local v150 = vu14.Character
        local v151 = vu14.Backpack
        if not (v150 or v151) then
            return false
        end
        local v152, v153, v154 = ipairs({
            v150,
            v151
        })
        while true do
            local v155
            v154, v155 = v152(v153, v154)
            if v154 == nil then
                break
            end
            if v155 then
                local v156, v157, v158 = ipairs(v155:GetChildren())
                while true do
                    local v159
                    v158, v159 = v156(v157, v158)
                    if v158 == nil then
                        break
                    end
                    if v159:IsA("Tool") and v159.Name == "Knife" then
                        return true
                    end
                end
            end
        end
        return false
    end
    local function vu171()
        if vu160() then
            return
        end
        local v161 = vu15
        local v162, v163, v164 = ipairs(v161:GetChildren())
        local v165 = nil
        while true do
            local v166
            v164, v166 = v162(v163, v164)
            if v164 == nil then
                v166 = v165
                break
            end
            if v166:IsA("Model") and v166:FindFirstChild("GunDrop") then
                break
            end
        end
        if v166 then
            local v167 = v166:FindFirstChild("GunDrop")
            if v167 then
                local v168 = vu14.Character
                if v168 and v168:FindFirstChild("HumanoidRootPart") then
                    local v169 = v168.HumanoidRootPart
                    local v170 = v169.Position
                    v169.CFrame = v167.CFrame
                    task.wait(0.2)
                    v169.CFrame = CFrame.new(v170.X, v170.Y + 5, v170.Z)
                else
                    sendnotification("Character not ready")
                end
            else
                sendnotification("Wait for the Sheriff\'s death to grab the gun")
                return
            end
        else
            sendnotification("Wait for the Sheriff\'s death to grab the gun")
            return
        end
    end
    local function vu181()
        if not vu147 then
            vu171()
            return
        end
        if vu160() then
            return
        end
        local v172 = vu15
        local v173, v174, v175 = ipairs(v172:GetChildren())
        local v176 = nil
        while true do
            local v177
            v175, v177 = v173(v174, v175)
            if v175 == nil then
                v177 = v176
                break
            end
            if v177:IsA("Model") and v177:FindFirstChild("GunDrop") then
                break
            end
        end
        if v177 then
            local v178 = v177:FindFirstChild("GunDrop")
            if v178 then
                local v179 = vu14.Character
                if v179 and v179:FindFirstChild("HumanoidRootPart") then
                    local v180 = v179.HumanoidRootPart
                    firetouchinterest(v180, v178, 0)
                    task.wait(0.1)
                    firetouchinterest(v180, v178, 1)
                else
                    sendnotification("Character not ready")
                end
            else
                sendnotification("Wait for the Sheriff\'s death to grab the gun")
                return
            end
        else
            sendnotification("Wait for the Sheriff\'s death to grab the gun")
            return
        end
    end
-- ==================== GRAB GUN (ANTI FLING) ====================
local grabLock = false  -- Lock agar tidak double call

vu34.teleport:Button({
    Title = "loc:grabgun",
    Callback = function()
        if grabLock then 
            sendnotification("Please wait...")
            return 
        end
        
        grabLock = true
        
        -- CEK MURDERER
        local char = vu14.Character
        local bp = vu14:FindFirstChild("Backpack")
        local isMurderer = false
        
        if char and char:FindFirstChild("Knife") then
            isMurderer = true
        end
        if bp and bp:FindFirstChild("Knife") then
            isMurderer = true
        end
        
        if isMurderer then
            WindUI:Notify({
                ["Title"] = "Grab Gun",
                ["Content"] = "You are the Murderer!",
                ["Duration"] = 2
            })
            grabLock = false
            return
        end
        
        -- CARI GUNDROP
        local GunDrop = nil
        for _, Descendant in ipairs(Workspace:GetDescendants()) do
            if Descendant.Name == "GunDrop" and Descendant:IsA("BasePart") then
                GunDrop = Descendant
                break
            end
        end
        
        if not GunDrop then
            WindUI:Notify({
                ["Title"] = "Grab Gun",
                ["Content"] = "No gun drop found!",
                ["Duration"] = 2
            })
            grabLock = false
            return
        end
        
        local RootPart = vu14.Character and vu14.Character:FindFirstChild("HumanoidRootPart")
        if not RootPart then
            grabLock = false
            return
        end
        
        -- ===== ANTI FLING: Simpan posisi & velocity =====
        local OriginalPos = RootPart.Position
        local OriginalVel = RootPart.AssemblyLinearVelocity
        
        -- MATIKAN PHYSICS SEMENTARA
        local humanoid = vu14.Character:FindFirstChild("Humanoid")
        if humanoid then
            humanoid.PlatformStand = true
        end
        
        -- Pindah ke gun drop (tanpa fling)
        RootPart.CFrame = GunDrop.CFrame + Vector3.new(0, 2, 0)
        RootPart.AssemblyLinearVelocity = Vector3.new(0, 0, 0)
        RootPart.AssemblyAngularVelocity = Vector3.new(0, 0, 0)
        
        task.wait(0.15)
        
        -- Kembali ke posisi semula dengan aman
        RootPart.CFrame = CFrame.new(OriginalPos.X, OriginalPos.Y + 5, OriginalPos.Z)
        RootPart.AssemblyLinearVelocity = Vector3.new(0, 0, 0)
        
        task.wait(0.05)
        
        -- NYALAKAN PHYSICS KEMBALI
        if humanoid then
            humanoid.PlatformStand = false
        end
        
        WindUI:Notify({
            ["Title"] = "Grab Gun",
            ["Content"] = "Gun acquired!",
            ["Duration"] = 2
        })
        
        grabLock = false
    end
})
vu34.teleport:Keybind({
    Title = "loc:grabgunkey",
    Value = "Y",
    Callback = function()
        if not grabber then return end
        if grabLock then 
            sendnotification("Please wait...")
            return 
        end
        
        grabLock = true
        
        -- CEK MURDERER
        local char = vu14.Character
        local bp = vu14:FindFirstChild("Backpack")
        local isMurderer = false
        
        if char and char:FindFirstChild("Knife") then isMurderer = true end
        if bp and bp:FindFirstChild("Knife") then isMurderer = true end
        
        if isMurderer then
            WindUI:Notify({
                ["Title"] = "Grab Gun",
                ["Content"] = "You are the Murderer!",
                ["Duration"] = 2
            })
            grabLock = false
            return
        end
        
        local GunDrop = nil
        for _, Descendant in ipairs(Workspace:GetDescendants()) do
            if Descendant.Name == "GunDrop" and Descendant:IsA("BasePart") then
                GunDrop = Descendant
                break
            end
        end
        
        if not GunDrop then
            WindUI:Notify({
                ["Title"] = "Grab Gun",
                ["Content"] = "No gun drop found!",
                ["Duration"] = 2
            })
            grabLock = false
            return
        end
        
        local RootPart = vu14.Character and vu14.Character:FindFirstChild("HumanoidRootPart")
        if not RootPart then
            grabLock = false
            return
        end
        
        -- ANTI FLING
        local OriginalPos = RootPart.Position
        local humanoid = vu14.Character:FindFirstChild("Humanoid")
        if humanoid then
            humanoid.PlatformStand = true
        end
        
        RootPart.CFrame = GunDrop.CFrame + Vector3.new(0, 2, 0)
        RootPart.AssemblyLinearVelocity = Vector3.new(0, 0, 0)
        RootPart.AssemblyAngularVelocity = Vector3.new(0, 0, 0)
        
        task.wait(0.15)
        
        RootPart.CFrame = CFrame.new(OriginalPos.X, OriginalPos.Y + 5, OriginalPos.Z)
        RootPart.AssemblyLinearVelocity = Vector3.new(0, 0, 0)
        
        task.wait(0.05)
        
        if humanoid then
            humanoid.PlatformStand = false
        end
        
        WindUI:Notify({
            ["Title"] = "Grab Gun",
            ["Content"] = "Gun acquired!",
            ["Duration"] = 2
        })
        
        grabLock = false
    end
})
 -- ==================== AUTO GRAB GUN (FIXED) ====================
local grabLock = false

vu34.teleport:Toggle({
    Title = "loc:autograbgun",
    Compact = true,
    Callback = function(p185)
        if vu183 then
            vu183:Disconnect()
            vu183 = nil
        end
        if vu184 then
            vu184:Disconnect()
            vu184 = nil
        end
        if p185 then
            local function SafeGrabGun()
                if grabLock then return end
                grabLock = true
                
                -- CEK MURDERER
                local char = vu14.Character
                local bp = vu14:FindFirstChild("Backpack")
                local isMurderer = false
                
                if char and char:FindFirstChild("Knife") then isMurderer = true end
                if bp and bp:FindFirstChild("Knife") then isMurderer = true end
                
                if isMurderer then
                    grabLock = false
                    return
                end
                
                -- CARI GUNDROP
                local GunDrop = nil
                for _, Descendant in ipairs(Workspace:GetDescendants()) do
                    if Descendant.Name == "GunDrop" and Descendant:IsA("BasePart") then
                        GunDrop = Descendant
                        break
                    end
                end
                
                if not GunDrop then
                    grabLock = false
                    return
                end
                
                local RootPart = vu14.Character and vu14.Character:FindFirstChild("HumanoidRootPart")
                if not RootPart then
                    grabLock = false
                    return
                end
                
                -- ANTI FLING
                local OriginalPos = RootPart.Position
                local humanoid = vu14.Character:FindFirstChild("Humanoid")
                if humanoid then
                    humanoid.PlatformStand = true
                end
                
                RootPart.CFrame = GunDrop.CFrame + Vector3.new(0, 2, 0)
                RootPart.AssemblyLinearVelocity = Vector3.new(0, 0, 0)
                RootPart.AssemblyAngularVelocity = Vector3.new(0, 0, 0)
                
                task.wait(0.15)
                
                RootPart.CFrame = CFrame.new(OriginalPos.X, OriginalPos.Y + 5, OriginalPos.Z)
                RootPart.AssemblyLinearVelocity = Vector3.new(0, 0, 0)
                
                task.wait(0.05)
                
                if humanoid then
                    humanoid.PlatformStand = false
                end
                
                grabLock = false
            end
            
            vu183 = vu12.ChildAdded:Connect(function(p189)
                if p189.Name == "GunDrop" then
                    task.wait(0.1)
                    SafeGrabGun()
                end
            end)
            
            vu184 = vu12.DescendantAdded:Connect(function(p190)
                if p190.Name == "GunDrop" then
                    task.wait(0.1)
                    SafeGrabGun()
                end
            end)
            
            -- CEK GUNDROP YANG SUDAH ADA
            for _, descendant in ipairs(vu12:GetDescendants()) do
                if descendant.Name == "GunDrop" then
                    task.wait(0.1)
                    SafeGrabGun()
                    break
                end
            end
        end
    end
})
    vu34.teleport:Button({
        Title = "loc:tptomap",
        Callback = function()
            local v197 = game.Players.LocalPlayer.Character
            if v197 then
                v197 = game.Players.LocalPlayer.Character:FindFirstChild("HumanoidRootPart")
            end
            local v198 = vu12
            local v199, v200, v201 = pairs(v198:GetDescendants())
            while true do
                local v202
                v201, v202 = v199(v200, v201)
                if v201 == nil then
                    break
                end
                if v202.Name ~= "Spawn" or not v197 then
                    if v202.Name == "PlayerSpawn" and v197 then
                        v197.CFrame = CFrame.new(v202.Position) * CFrame.new(0, 2.5, 0)
                    end
                else
                    v197.CFrame = CFrame.new(v202.Position) * CFrame.new(0, 2.5, 0)
                end
            end
        end
    })
    vu34.teleport:Button({
        Title = "loc:tptovote",
        Callback = function()
            game.Players.LocalPlayer.Character.HumanoidRootPart.CFrame = CFrame.new(- 4993.42041, 288.661469, 73.101631)
        end
    })
    vu34.teleport:Button({
        Title = "loc:tptolobby",
        Callback = function()
            local v203 = game.Players.LocalPlayer.Character
            if v203 then
                v203 = game.Players.LocalPlayer.Character:FindFirstChild("HumanoidRootPart")
            end
            local v204 = vu12.Lobby.Spawns:GetChildren()
            if v203 and # v204 > 0 then
                v203.CFrame = v204[math.random(# v204)].CFrame + Vector3.new(0, 3, 0)
            end
        end
    })
    vu34.teleport:Button({
        Title = "loc:tptosecret",
        Callback = function()
            game.Players.LocalPlayer.Character.HumanoidRootPart.CFrame = CFrame.new(- 5011.48877, 304.701508, 81.616966)
        end
    })
    local function vu210()
        local v205, v206, v207 = ipairs(game:GetService("Players"):GetPlayers())
        local v208 = {}
        while true do
            local v209
            v207, v209 = v205(v206, v207)
            if v207 == nil then
                break
            end
            if v209 ~= game.Players.LocalPlayer then
                table.insert(v208, v209.Name)
            end
        end
        return v208
    end
    vu34.teleport:Button({
        Title = "loc:tptorandom",
        Compact = true,
        Callback = function()
            local v211 = vu210()
            if # v211 <= 0 then
                vu2:Notify({
                    Title = "Error",
                    Content = "No players to teleport to!",
                    Duration = 3
                })
            else
                local v212 = game:GetService("Players")[v211[math.random(1, # v211)] ]
                if v212 then
                    if v212.Character and v212.Character:FindFirstChild("HumanoidRootPart") then
                        game.Players.LocalPlayer.Character.HumanoidRootPart.CFrame = v212.Character.HumanoidRootPart.CFrame
                        vu2:Notify({
                            Title = "Teleported",
                            Content = "Teleported to: " .. v212.Name,
                            Duration = 3
                        })
                    else
                        sendnotification("Target not found")
                    end
                end
            end
        end
    })
    vu34.teleport:Section({
        Title = "Teleport To Humanoid"
    })
    local vu213 = ""
    vu34.teleport:Input({
        Title = "loc:inputteleport",
        Type = "Input",
        Placeholder = "...",
        Callback = function(p214)
            vu213 = p214:lower()
        end
    })
    vu34.teleport:Button({
        Title = "loc:tptoplayer",
        Callback = function()
            if vu213 == "" then
                return sendnotification("Write name nigga")
            end
            local v215 = GetTarget(vu213)
            if v215 then
                if v215.Character and v215.Character:FindFirstChild("HumanoidRootPart") then
                    game.Players.LocalPlayer.Character:WaitForChild("HumanoidRootPart").CFrame = CFrame.new(v215.Character.HumanoidRootPart.Position)
                else
                    sendnotification("Wait for child")
                end
            else
                sendnotification("Target not found")
                vu213 = ""
            end
        end
    })
    vu34.teleport:Button({
        Title = "loc:tptomurder",
        Callback = function()
            local v216 = vu13
            local v217, v218, v219 = pairs(v216:GetPlayers())
            while true do
                local v220
                v219, v220 = v217(v218, v219)
                if v219 == nil then
                    break
                end
                if v220.Character and (v220.Character:FindFirstChild("Knife") or v220.Backpack and v220.Backpack:FindFirstChild("Knife")) then
                    game.Players.LocalPlayer.Character.HumanoidRootPart.CFrame = v220.Character.HumanoidRootPart.CFrame
                end
            end
        end
    })
    vu34.teleport:Button({
        Title = "loc:tptosheriff",
        Callback = function()
            local v221 = vu13
            local v222, v223, v224 = pairs(v221:GetPlayers())
            while true do
                local v225
                v224, v225 = v222(v223, v224)
                if v224 == nil then
                    break
                end
                if v225.Character and (v225.Character:FindFirstChild("Gun") or v225.Backpack and v225.Backpack:FindFirstChild("Gun")) then
                    game.Players.LocalPlayer.Character.HumanoidRootPart.CFrame = v225.Character.HumanoidRootPart.CFrame
                end
            end
        end
    })

    vu34.combat:Section({
        Title = gradient("Combat Universal", Color3.fromHex("#8FCE00"), Color3.fromHex("#8FCE00"))
    })
    getgenv().DodgeKnife = false
    local vu226 = 9
    local vu227 = 25
    local vu228 = nil
    local vu229 = nil
    local vu230 = {}
    function removeAllKnives()
        local v231 = vu12
        local v232, v233, v234 = ipairs(v231:GetChildren())
        while true do
            local v235
            v234, v235 = v232(v233, v234)
            if v234 == nil then
                break
            end
            if v235:IsA("Model") and v235.Name == "ThrowingKnife" then
                v235:Destroy()
            end
        end
    end
    function isPathClear(p236, p237)
        local v238 = RaycastParams.new()
        v238.FilterType = Enum.RaycastFilterType.Blacklist
        v238.FilterDescendantsInstances = {
            vu14.Character
        }
        return not vu12:Raycast(p236, p237 - p236, v238)
    end
    local function vu246(p239)
        if vu14.Character and vu14.Character:FindFirstChild("HumanoidRootPart") then
            if vu14.Backpack:FindFirstChild("Knife") or vu14.Character:FindFirstChild("Knife") then
                return
            end
            local v240 = vu14.Character.HumanoidRootPart.Position
            local v241 = p239:FindFirstChild("BladePosition")
            if v241 and v241:IsA("BasePart") then
                local v242 = v241.Position
                if (v240 - v242).Magnitude <= vu226 then
                    local v243 = (v240 - v242).Unit
                    local v244 = v242 + Vector3.new(- v243.Z, 0, v243.X) * vu226
                    local v245 = Vector3.new(v244.X, v240.Y, v244.Z)
                    if isPathClear(v240, v245) then
                        vu14.Character.HumanoidRootPart.CFrame = CFrame.new(v245)
                    end
                end
            end
        end
    end
    function onKnifeAdded(p247)
        if p247:IsA("Model") and p247.Name == "ThrowingKnife" then
            table.insert(vu230, p247)
        end
    end
    function updateKnives()
        local v248, v249, v250 = ipairs(vu230)
        while true do
            local v251
            v250, v251 = v248(v249, v250)
            if v250 == nil then
                break
            end
            if v251 and v251.Parent then
                local v252 = v251:FindFirstChild("BladePosition")
                if v252 and v252:IsA("BasePart") then
                    local v253 = v252.Position
                    if vu14.Character and (vu14.Character:FindFirstChild("HumanoidRootPart") and (vu14.Character.HumanoidRootPart.Position - v253).Magnitude <= vu227) then
                        vu246(v251)
                    end
                end
            end
        end
    end
    function toggleDetection()
        if getgenv().DodgeKnife then
            removeAllKnives()
            vu230 = {}
            vu228 = vu12.DescendantAdded:Connect(onKnifeAdded)
            vu229 = vu10.Heartbeat:Connect(updateKnives)
        else
            if vu228 then
                vu228:Disconnect()
            end
            if vu229 then
                vu229:Disconnect()
            end
            vu230 = {}
        end
    end
    vu34.combat:Toggle({
        Title = "loc:autododge",
        Value = false,
        Callback = function(p254)
            getgenv().DodgeKnife = p254
            toggleDetection()
        end
    })
    local vu261 = vu34.combat:Toggle({
        Title = "loc:invis",
        Value = false,
        Callback = function(p255)
            local v256 = vu14.Character or vu14.CharacterAdded:Wait()
            if p255 then
                local v257 = v256.HumanoidRootPart.CFrame
                v256:MoveTo(Vector3.new(- 25.95, 84, 3537.55))
                task.wait(0.1)
                local v258 = Instance.new("Seat", game.Workspace)
                v258.Anchored = false
                v258.CanCollide = false
                v258.Name = "xd"
                v258.Transparency = 1
                v258.Position = Vector3.new(- 25.95, 84, 3537.55)
                local v259 = Instance.new("Weld", v258)
                v259.Part0 = v258
                v259.Part1 = v256.HumanoidRootPart
                task.wait()
                v256.HumanoidRootPart.CFrame = v257
            else
                local v260 = vu12:FindFirstChild("xd")
                if v260 then
                    v260:Destroy()
                end
            end
        end
    })
    local vu262 = nil
    local vu263 = nil
    vu34.combat:Toggle({
        Title = "loc:godmode",
        Desc = "loc:descgodmode",
        Value = false,
        Callback = function(p264)
            if p264 then
                local function vu267(p265)
                    local vu266 = p265:WaitForChild("Humanoid")
                    vu266.Health = vu266.MaxHealth
                    vu262 = vu266.Changed:Connect(function()
                        if vu266.Health < vu266.MaxHealth then
                            vu266.Health = vu266.MaxHealth
                        end
                    end)
                end
                vu267(vu14.Character or vu14.CharacterAdded:Wait())
                vu263 = vu14.CharacterAdded:Connect(function(p268)
                    vu267(p268)
                end)
            else
                vu262:Disconnect()
                vu263:Disconnect()
            end
        end
    })
    local vu269 = true
    local vu270 = 2
    local vu271 = game:GetService("ReplicatedStorage")
    local vu272 = game:GetService("CoreGui")
 function useBomb()
    if vu269 then
        vu269 = false
        local v273 = vu14:FindFirstChild("Backpack")
        local v274 = vu14.Character or vu14.CharacterAdded:Wait()
        
        -- GANTI: Cari GoldBomb BUKAN FakeBomb
        local v275 = v273:FindFirstChild("GoldBomb") or v274:FindFirstChild("GoldBomb")
        if not v275 then
            -- SPAWN GOLDBOMB
            vu271.Remotes.Extras.ReplicateToy:InvokeServer("GoldBomb")
            task.wait(0.3)
            v275 = v273:FindFirstChild("GoldBomb") or v274:FindFirstChild("GoldBomb")
        end
        
        if v275 then
            v275.Parent = v274
            if v275:IsDescendantOf(v274) then
                local hum = v274:FindFirstChildOfClass("Humanoid")
                if hum then
                    hum:ChangeState(Enum.HumanoidStateType.Jumping)
                    hum.JumpPower = 53
                    
                    -- PAKAI REMOTE GOLDBOMB
                    local remote = v275:FindFirstChild("Remote")
                    if remote then
                        remote:FireServer(v274.HumanoidRootPart.CFrame * CFrame.new(0, -3, 0), 50)
                    end
                    
                    task.wait(0.3)
                    v275.Parent = v273
                    hum.JumpPower = 51
                end
            end
        end
        
        -- COOLDOWN TIMER (TETAP SAMA)
        local v276 = vu272:FindFirstChild("bomb")
        if v276 then
            v276:Destroy()
        end
        local v277 = Instance.new("ScreenGui", vu272)
        v277.Name = "bomb"
        local v278 = Instance.new("TextLabel")
        v278.Size = UDim2.new(0, 200, 0, 50)
        v278.Position = UDim2.new(0.5, -100, 0, 50)
        v278.BackgroundTransparency = 0.5
        v278.TextColor3 = Color3.new(255, 0, 0)
        v278.TextScaled = true
        v278.Text = ""
        v278.Parent = v277
        
        local v279 = time()
        local v280 = vu14.Character
        while time() - v279 < vu270 do
            if vu14.Character ~= v280 then
                v277:Destroy()
                vu269 = true
                return
            end
            v278.Text = "Cooldown: " .. vu270 - math.floor(time() - v279) .. "s"
            task.wait(1)
        end
        v277:Destroy()
        vu269 = true
    end
end
    vu34.combat:Keybind({
        Title = "loc:autoclutchbomb",
        Value = "X",
        Callback = function()
            if autobomb then
                useBomb()
            end
        end
    })
    vu34.combat:Toggle({
        Title = "loc:keybindclutch",
        Value = false,
        Callback = function(p281)
            autobomb = p281
        end
    })
    local vu282 = game.Players.LocalPlayer
    local vu283 = nil
    local vu284 = nil
    local v285 = Instance.new("Animation")
    v285.AnimationId = "rbxassetid://2467567750"
    local v286 = Instance.new("Animation")
    v286.AnimationId = "rbxassetid://1957890538"
    local vu287 = {
        v285,
        v286
    }
    local vu288 = {}
    local function vu301()
        if vu282.Character then
            local vu289 = nil
            local v290, _ = pcall(function()
                vu289 = vu12:WaitForChild("Lobby"):WaitForChild("MainLobby"):WaitForChild("Parts"):WaitForChild("Handle")
            end)
            if v290 and vu289 then
                vu283 = Instance.new("Tool")
                vu283.Name = "Fake Knife"
                vu283.CanBeDropped = false
                vu283.Grip = CFrame.new(0, - 1.16999984, 0.0699999481)
                vu283.GripForward = Vector3.new(0, 0, - 1)
                vu283.GripPos = Vector3.new(0, - 1.17, 0.07)
                vu283.GripRight = Vector3.new(1, 0, 0)
                vu283.GripUp = Vector3.new(0, 1, 0)
                local v291 = vu289
                local v292 = vu289.Clone(v291)
                v292.Name = "Handle"
                v292.Size = Vector3.new(0.3106, 3.421, 1.0877)
                v292.Transparency = 0
                v292.CanCollide = false
                v292.Anchored = false
                v292.Parent = vu283
                local vu293 = Instance.new("Sound")
                vu293.SoundId = "rbxassetid://142247768"
                vu293.Volume = 1
                if vu282.Character then
                    vu293.Parent = vu282.Character:WaitForChild("HumanoidRootPart")
                end
                table.insert(vu288, vu282:GetMouse().Button1Down:Connect(function()
                    if vu283 and vu283.Parent == vu282.Character then
                        vu282.Character.Humanoid:LoadAnimation(vu287[math.random(1, 2)]):Play()
                    end
                end))
                local function vu296(p294)
                    local v295 = p294.Parent
                    if v295:FindFirstChildOfClass("Humanoid") and v295 ~= vu282.Character then
                        vu293:Stop()
                        vu293:Play()
                    end
                end
                local function vu299(p297)
                    local v298 = p297:FindFirstChild("RightHand", true)
                    if v298 and v298:IsA("BasePart") then
                        table.insert(vu288, v298.Touched:Connect(vu296))
                    end
                end
                vu299(vu282.Character)
                vu283.Parent = vu282.Backpack
                table.insert(vu288, vu282.CharacterAdded:Connect(function(p300)
                    if vu283 then
                        vu283.Parent = vu282.Backpack
                        vu293.Parent = p300:WaitForChild("HumanoidRootPart")
                        vu299(p300)
                    end
                end))
            else
                warn("\239\191\189\208\181 \208\189\208\176\208\185\208\180\208\181\208\189 Part \208\189\208\190\208\182\208\176")
            end
        else
            return
        end
    end
    local function vu306()
        local v302, v303, v304 = ipairs(vu288)
        while true do
            local v305
            v304, v305 = v302(v303, v304)
            if v304 == nil then
                break
            end
            if v305.Connected then
                v305:Disconnect()
            end
        end
        vu288 = {}
    end
    vu34.combat:Toggle({
        Title = "loc:fakeknife",
        Value = false,
        Callback = function(p307)
            if p307 then
                if not vu283 then
                    vu301()
                end
            else
                if vu283 then
                    vu283:Destroy()
                    vu283 = nil
                    vu284 = nil
                end
                vu306()
            end
        end
    })
    vu14.CharacterAdded:Connect(function(p308)
        getgenv().char = p308
        getgenv().humanoid = getgenv().char:WaitForChild("Humanoid")
    end)
    if vu14.Character then
        getgenv().char = vu14.Character
        getgenv().humanoid = getgenv().char:WaitForChild("Humanoid")
    end
    getgenv().heartbeatConnection = nil
    getgenv().glitchPower = 15
    getgenv().acceleration = 0.3
    vu34.combat:Slider({
        Title = "loc:speedglitchslider",
        Step = 1,
        Value = {
            Min = 1,
            Max = 120,
            Default = 15
        },
        Callback = function(p309)
            getgenv().glitchPower = p309
        end
    })
    vu34.combat:Toggle({
        Title = "loc:fakespeedglitch",
        Value = false,
        Callback = function(p310)
            if p310 then
                getgenv().heartbeatConnection = game:GetService("RunService").Heartbeat:Connect(function()
                    local v311 = getgenv().humanoid:GetState()
                    if v311 == Enum.HumanoidStateType.Jumping or v311 == Enum.HumanoidStateType.Freefall then
                        local v312 = getgenv().humanoid.MoveDirection
                        if v312.Magnitude > 0 then
                            getgenv().acceleration = math.min(getgenv().acceleration + 0.05, 1)
                            local v313 = getgenv().glitchPower * getgenv().acceleration
                            getgenv().char:TranslateBy(v312.Unit * v313 / 150)
                        end
                    end
                end)
            else
                if getgenv().heartbeatConnection then
                    getgenv().heartbeatConnection:Disconnect()
                    getgenv().heartbeatConnection = nil
                end
                getgenv().acceleration = 0.3
            end
        end
    })
    vu34.combat:Section({
        Title = gradient("Combat Sheriff", Color3.fromHex("#2986CC"), Color3.fromHex("#2986CC"))
    })
    getgenv().shoot = false
    function GetMurder()
        local v314 = game:GetService("Players")
        local v315, v316, v317 = pairs(v314:GetPlayers())
        while true do
            local v318
            v317, v318 = v315(v316, v317)
            if v317 == nil then
                break
            end
            if v318.Character and (v318.Character:FindFirstChild("Knife") or v318.Backpack and v318.Backpack:FindFirstChild("Knife")) then
                return v318
            end
        end
        return nil
    end
    function GetSheriff()
        local v319 = game:GetService("Players")
        local v320, v321, v322 = pairs(v319:GetPlayers())
        while true do
            local v323
            v322, v323 = v320(v321, v322)
            if v322 == nil then
                break
            end
            if v323.Character and (v323.Character:FindFirstChild("Gun") or v323.Backpack and v323.Backpack:FindFirstChild("Gun")) then
                return v323
            end
        end
        return nil
    end
    function onUpdate()
        if GetSheriff() == vu14 and getgenv().shoot then
            local v324 = GetMurder()
            if not v324 then
                return
            end
            local v325 = v324.Character
            if not v325 then
                return
            end
            local v326 = v325:FindFirstChild("HumanoidRootPart")
            if not v326 then
                return
            end
            local v327 = v326.Position
            if not vu14.Character then
                return
            end
            local v328 = vu14.Character:FindFirstChild("HumanoidRootPart")
            if not v328 then
                return
            end
            local v329 = v327 - v328.Position
            local v330 = RaycastParams.new()
            v330.FilterType = Enum.RaycastFilterType.Exclude
            v330.FilterDescendantsInstances = {
                vu14.Character
            }
            local v331 = vu12:Raycast(v328.Position, v329, v330)
            if (not v331 or v331.Instance.Parent == v324.Character) and (vu14.Character:FindFirstChild("Gun") or vu14.Backpack:FindFirstChild("Gun")) then
                vu14.Character.Humanoid:EquipTool(game:GetService("Players").LocalPlayer.Backpack:FindFirstChild("Gun"))
                local v332 = GetMurder()
                local v333 = v332.Character:FindFirstChild("UpperTorso")
                local v334 = v332.Character:FindFirstChild("Humanoid")
                if not v333 then
                    return
                end
                if not v334 then
                    return
                end
                local _ = v333.Position
                Vector3.new()
                local v335 = v333.AssemblyLinearVelocity
                local v336 = v334.MoveDirection
                local _ = v333.CFrame.LookVector
                local _ = v335.Y <= 0
                local v337 = vu14
                local v338 = (v333.Position + v335 * Vector3.new(0, 0.5, 0) * 0.14 + v336 * 2.8) * (v337:GetNetworkPing() * 1000 * 0 + 1)
                local v339 = vu14.Character
                local v340 = v339:FindFirstChild("HumanoidRootPart")
                local v341 = nil
                if v340 then
                    local v342 = v340:FindFirstChild("GunRaycastAttachment")
                    if v342 then
                        v341 = v342.WorldCFrame
                    end
                end
                local v343 = CFrame.new(v338)
                v339.Gun.Shoot:FireServer(v341, v343)
            end
        end
    end
    radius = 14
    vu34.combat:Toggle({
        Title = "loc:autoshoot",
        Value = false,
        Callback = function(p344)
            getgenv().shoot = p344
            if p344 then
                getgenv().cn = vu10.RenderStepped:Connect(onUpdate)
                task.spawn(function()
                    local v345 = 0
                    while getgenv().shoot do
                        if GetSheriff() ~= vu14 then
                            task.wait(1)
                        else
                            (vu14.Character or vu14.CharacterAdded:Wait()):WaitForChild("HumanoidRootPart")
                            local v346 = GetMurder()
                            if v346 then
                                local v347 = v346.Character:FindFirstChild("HumanoidRootPart")
                                if v347 then
                                    local v348 = math.cos(math.rad(v345)) * radius
                                    local v349 = math.sin(math.rad(v345)) * radius
                                    vu14.Character:SetPrimaryPartCFrame(v347.CFrame * CFrame.new(v348, 0, v349))
                                    v345 = (v345 + 5) % 360
                                    task.wait(0.03)
                                end
                            else
                                task.wait(0.4)
                            end
                        end
                    end
                end)
            elseif getgenv().cn then
                getgenv().cn:Disconnect()
                getgenv().cn = nil
            end
        end
    })
    vu34.combat:Slider({
        Title = "loc:sliderautoshoot",
        Value = {
            Min = 5,
            Max = 16,
            Default = radius
        },
        Callback = function(p350)
            radius = p350
        end
    })
    vu34.combat:Divider()
    local vu351 = false

-- REPLACE WITH THIS SIMPLIFIED VERSION
local vu351 = false
vu34.combat:Toggle({
    Title = "loc:togsilentaim",
    Value = false,
    Callback = function(p354)
        vu351 = p354
    end
})

vu34.combat:Keybind({
    Title = "loc:silentaim",
    Value = "Q",
    Callback = function()
        if vu351 == true then
            if GetSheriff() ~= vu14 then
                print("You're not sheriff/hero.")
                return
            end
            local v355 = GetMurder()
            if not v355 then
                print("No murderer to shoot.")
                return
            end
            if not vu14.Character:FindFirstChild("Gun") then
                local v356 = vu14.Character:FindFirstChild("Humanoid")
                if not vu14.Backpack:FindFirstChild("Gun") then
                    print("You don't have the gun..?")
                    return
                end
                v356:EquipTool(vu14.Backpack:FindFirstChild("Gun"))
                task.wait(0.05)
            end
            local v357 = v355.Character:FindFirstChild("HumanoidRootPart")
            if not v357 then
                print("Could not find the murderer's HumanoidRootPart.")
                return
            end
            
            -- Prediksi
            local PredictedPos = GetGunPredictedPosition(v357) or v357.Position
            
            local v367 = vu14.Character
            local v368 = v367:FindFirstChild("HumanoidRootPart")
            local v369 = nil
            if v368 then
                local v370 = v368:FindFirstChild("GunRaycastAttachment")
                if v370 then
                    v369 = v370.WorldCFrame
                end
            end
            local v371 = CFrame.new(PredictedPos)
            if v369 then
                v367.Gun.Shoot:FireServer(v369, v371)
            else
                v367.Gun.Shoot:FireServer(v368.CFrame, v371)
            end
        end
    end
})
    AimbotEnabled = false
    PredictMovement = false
    vu34.combat:Toggle({
        Title = "loc:aimbot",
        Value = false,
        Callback = function(p372)
            AimbotEnabled = p372
        end
    })
    local vu373 = 240
    local vu374 = "HumanoidRootPart"
    vu34.combat:Toggle({
        Title = "loc:prediction",
        Value = false,
        Callback = function(p375)
            PredictMovement = p375
        end
    })
    vu34.combat:Slider({
        Title = "loc:fovradius",
        Value = {
            Min = 80,
            Max = 340,
            Default = 240
        },
        Callback = function(p376)
            vu373 = tonumber(p376)
        end
    })
    local v377 = game:GetService("Workspace")
    local vu378 = game:GetService("UserInputService")
    local vu379 = vu14:GetMouse()
    local vu380 = v377.CurrentCamera
    local vu381 = Vector3.new(0, 0.1, 0)
    local vu382 = 0.2
    function GetClosestPlayerToMouse()
        local v383 = vu373
        local v384 = vu13
        local v385, v386, v387 = pairs(v384:GetPlayers())
        local v388 = nil
        while true do
            local v389
            v387, v389 = v385(v386, v387)
            if v387 == nil then
                break
            end
            if v389.Character and (v389.Character:FindFirstChild("Knife") ~= nil or v389.Backpack and v389.Backpack:FindFirstChild("Knife") ~= nil) and (v389.Character:FindFirstChild(vu374) and v389 ~= vu14 and v389.Character:FindFirstChildOfClass("Humanoid").Health > 0) then
                local v390, v391 = vu380:WorldToViewportPoint(v389.Character[vu374].Position)
                if v391 then
                    local v392 = (Vector2.new(tonumber(vu379.X), tonumber(vu379.Y)) - Vector2.new(v390.X, v390.Y)).Magnitude
                    if v392 < v383 then
                        v388 = v389.Character
                        v383 = v392
                    end
                end
            end
        end
        return v388, v383 < vu373
    end
    function LockCursor()
        vu378.MouseBehavior = Enum.MouseBehavior.LockCenter
    end
    function UnlockCursor()
        vu378.MouseBehavior = Enum.MouseBehavior.Default
    end
    vu378.InputBegan:Connect(function(p393)
        if p393.UserInputType == Enum.UserInputType.MouseButton2 and AimbotEnabled then
            local v394, v395 = GetClosestPlayerToMouse()
            if v395 then
                LockCursor()
            end
            while vu378:IsMouseButtonPressed(Enum.UserInputType.MouseButton2) and AimbotEnabled do
                if v394 then
                    local v396 = PredictMovement and v394[vu374].CFrame + v394[vu374].Velocity * vu382 + vu381 or v394[vu374].CFrame
                    vu380.CFrame = CFrame.lookAt(vu380.CFrame.Position, v396.Position)
                end
                task.wait()
            end
            UnlockCursor()
        end
    end)
    vu34.combat:Section({
        Title = gradient("Combat Murderer", Color3.fromHex("#FF0000"), Color3.fromHex("#FF0000"))
    })
    function EquipTool()
        local v397 = next
        local v398, v399 = game.Players.LocalPlayer.Backpack:GetChildren()
        while true do
            local v400
            v399, v400 = v397(v398, v399)
            if v399 == nil then
                break
            end
            if v400.Name == "Knife" then
                game.Players.LocalPlayer.Backpack.Knife.Parent = game.Players.LocalPlayer.Character
            end
        end
    end
    vu34.combat:Toggle({
        Title = "loc:autokillall",
        Value = false,
        Callback = function(p401)
            autokillallloop = p401
            while autokillallloop do
                function autokillallloopfix()
                    EquipTool()
                    wait()
                    local v402 = game.Players.LocalPlayer.Character
                    local v403
                    if v402 then
                        v403 = v402:FindFirstChild("Knife")
                    else
                        v403 = v402
                    end
                    wait()
                    local v404, v405, v406 = ipairs(game.Players:GetPlayers())
                    while true do
                        local v407
                        v406, v407 = v404(v405, v406)
                        if v406 == nil then
                            break
                        end
                        if v407 ~= game.Players.LocalPlayer then
                            wait()
                            local v408 = v407.Character
                            if v408 then
                                v408 = v408:FindFirstChild("HumanoidRootPart")
                            end
                            if v408 and v402 then
                                game:GetService("Players").LocalPlayer.Character.Knife.Events.KnifeStabbed:FireServer()
                                firetouchinterest(v408, v403.Handle, 1)
                                firetouchinterest(v408, v403.Handle, 0)
                                game:GetService("Players").LocalPlayer.Character:WaitForChild("Knife"):WaitForChild("Events"):WaitForChild("HandleTouched"):FireServer(unpack({
                                    v408
                                }))
                            end
                        end
                    end
                    wait()
                end
                wait()
                pcall(autokillallloopfix)
            end
        end
    })
    vu34.combat:Button({
        Title = "loc:killsheriff",
        Callback = function()
            local vu409 = game:GetService("Players").LocalPlayer
            if vu409.Backpack:FindFirstChild("Knife") or vu409.Character:FindFirstChild("Knife") then
                pcall(function()
                    EquipTool()
                    task.wait()
                    local v410 = vu409.Character
                    local v411
                    if v410 then
                        v411 = v410:FindFirstChild("Knife")
                    else
                        v411 = v410
                    end
                    if v411 then
                        local v412 = GetSheriff()
                        if v412 and v410 then
                            local v413 = v412.Character
                            if v413 then
                                v413 = v413:FindFirstChild("HumanoidRootPart")
                            end
                            if v413 then
                                game:GetService("Players").LocalPlayer.Character.Knife.Events.KnifeStabbed:FireServer()
                                firetouchinterest(v413, v411.Handle, 1)
                                firetouchinterest(v413, v411.Handle, 0)
                                game:GetService("Players").LocalPlayer.Character:WaitForChild("Knife"):WaitForChild("Events"):WaitForChild("HandleTouched"):FireServer(unpack({
                                    v413
                                }))
                            end
                        end
                    end
                end)
            else
                sendnotification("You are not a murderer!")
            end
        end
    })
    vu34.combat:Toggle({
        Title = "loc:autokillsheriff",
        Value = false,
        Callback = function(p414)
            autokillshloop = p414
            while autokillshloop do
                pcall(function()
                    EquipTool()
                    wait()
                    local v415 = game.Players.LocalPlayer.Character
                    local v416
                    if v415 then
                        v416 = v415:FindFirstChild("Knife")
                    else
                        v416 = v415
                    end
                    if v416 then
                        local v417 = GetSheriff()
                        if v417 and v415 then
                            local v418 = v417.Character
                            if v418 then
                                v418 = v418:FindFirstChild("HumanoidRootPart")
                            end
                            if v418 then
                                game:GetService("Players").LocalPlayer.Character.Knife.Events.KnifeStabbed:FireServer()
                                firetouchinterest(v418, v416.Handle, 1)
                                firetouchinterest(v418, v416.Handle, 0)
                                game:GetService("Players").LocalPlayer.Character:WaitForChild("Knife"):WaitForChild("Events"):WaitForChild("HandleTouched"):FireServer(unpack({
                                    v418
                                }))
                            end
                        end
                    end
                end)
                wait(0.2)
            end
        end
    })
    vu34.combat:Divider()
    kniferangenum = 20
    vu34.combat:Toggle({
        Title = "loc:knifeaura",
        Value = false,
        Callback = function(p419)
            knifeauraloop = p419
            while knifeauraloop do
                function thtrhthtr()
                    local v420, v421, v422 = pairs(game.Players:GetPlayers())
                    while true do
                        local v423
                        v422, v423 = v420(v421, v422)
                        if v422 == nil then
                            break
                        end
                        if v423 ~= game.Players.LocalPlayer and game.Players.LocalPlayer:DistanceFromCharacter(v423.Character.HumanoidRootPart.Position) < kniferangenum then
                            EquipTool()
                            wait()
                            local v424 = game.Players.LocalPlayer.Character
                            local v425
                            if v424 then
                                v425 = v424:FindFirstChild("Knife")
                            else
                                v425 = v424
                            end
                            wait()
                            local v426 = v423.Character
                            if v426 then
                                v426 = v426:FindFirstChild("HumanoidRootPart")
                            end
                            if v426 and v424 then
                                game:GetService("Players").LocalPlayer.Character.Knife.Events.KnifeStabbed:FireServer()
                                firetouchinterest(v426, v425.Handle, 1)
                                firetouchinterest(v426, v425.Handle, 0)
                                game:GetService("Players").LocalPlayer.Character:WaitForChild("Knife"):WaitForChild("Events"):WaitForChild("HandleTouched"):FireServer(unpack({
                                    v426
                                }))
                            end
                        end
                    end
                end
                wait()
                pcall(thtrhthtr)
            end
        end
    })
    vu34.combat:Slider({
        Title = "loc:knifeaurarange",
        Value = {
            Min = 5,
            Max = 300,
            Default = 20
        },
        Callback = function(p427)
            kniferangenum = tonumber(p427)
        end
    })
    vu34.combat:Divider()
    getgenv().throwingKnifeActive = false
    getgenv().throwingKnifeReach = 8
    vu34.combat:Toggle({
        Title = "loc:throwknife",
        Value = false,
        Callback = function(p428)
            getgenv().throwingKnifeActive = p428
        end
    })
    vu34.combat:Slider({
        Title = "loc:throwaura",
        Value = {
            Min = 5,
            Max = 300,
            Default = 8
        },
        Callback = function(p429)
            getgenv().throwingKnifeReach = tonumber(p429)
        end
    })
    game:GetService("RunService").RenderStepped:Connect(function()
        if getgenv().throwingKnifeActive then
            local v430 = game.Players.LocalPlayer
            local v431 = v430.Character
            if v431 then
                local v432 = v431:FindFirstChild("HumanoidRootPart")
                local v433 = v431:FindFirstChild("Knife")
                if v433 and v432 then
                    local v434 = vu12
                    local v435, v436, v437 = ipairs(v434:GetChildren())
                    while true do
                        local v438
                        v437, v438 = v435(v436, v437)
                        if v437 == nil then
                            break
                        end
                        if v438:IsA("Model") and v438.Name == "ThrowingKnife" then
                            local v439 = v438:FindFirstChild("BladePosition")
                            local v440 = v439 and v439.Position or v433.Handle.Position
                            local v441, v442, v443 = ipairs(game.Players:GetPlayers())
                            while true do
                                local v444
                                v443, v444 = v441(v442, v443)
                                if v443 == nil then
                                    break
                                end
                                if v444 ~= v430 and v444.Character and v444.Character:FindFirstChild("HumanoidRootPart") then
                                    local v445 = v444.Character.HumanoidRootPart
                                    local v446 = v444.Character:FindFirstChild("Humanoid")
                                    if v446 and (v446.Health > 0 and (v440 - v445.Position).Magnitude <= getgenv().throwingKnifeReach) then
                                        game:GetService("Players").LocalPlayer.Character.Knife.Events.KnifeStabbed:FireServer()
                                        firetouchinterest(v445, v433.Handle, 1)
                                        firetouchinterest(v445, v433.Handle, 0)
                                        game:GetService("Players").LocalPlayer.Character:WaitForChild("Knife"):WaitForChild("Events"):WaitForChild("HandleTouched"):FireServer(unpack({
                                            v445
                                        }))
                                    end
                                end
                            end
                        end
                    end
                end
            else
                return
            end
        else
            return
        end
    end)
    vu34.combat:Divider()
    getgenv().KnifeSilentAim = {
        CurrentPrediction = Vector3.zero
    }
    local vu447 = 16
    getgenv().KnifeFOVColor = Color3.fromRGB(255, 0, 0)
    getgenv().KnifeAimEnabled = false
    getgenv().KnifeTargetingMode = "Everyone"
    getgenv().KnifeUseFOV = false
    getgenv().KnifeShowPrediction = false
    getgenv().KnifeShowFOV = false
    getgenv().KnifeFOVSize = 90
    getgenv().KnifeFOVColor = Color3.fromRGB(255, 0, 0)
    -- ==================== MODE PREDIKSI ====================
    -- ==================== TAMBAHAN FITUR BARU ====================
-- Mode Throw: Instant atau Animated
getgenv().KnifeThrowMode = "Animated"  -- "Instant" atau "Animated"
-- Cooldown setelah throw (dalam detik)
getgenv().KnifePostCooldown = 0.5
-- Delay animasi (hanya untuk mode Animated)
getgenv().KnifeAnimDelay = 0.75
    local vu448 = Drawing.new("Circle")
    vu448.Color = getgenv().KnifeFOVColor
    vu448.Radius = getgenv().KnifeFOVSize
    vu448.Thickness = 1
    vu448.Filled = false
    local v449 = "Visible"
    local v450 = getgenv().KnifeShowFOV
    if v450 then
        v450 = getgenv().KnifeAimEnabled
    end
    vu448[v449] = v450
    local vu451 = Drawing.new("Circle")
    vu451.Color = Color3.new(0, 1, 0)
    vu451.Radius = 4
    vu451.Thickness = 1
    vu451.Filled = false
    local v452 = "Visible"
    local v453 = getgenv().KnifeShowPrediction
    if v453 then
        v453 = getgenv().KnifeAimEnabled
    end
    vu451[v452] = v453
    function UpdateCirclePosition()
        vu448.Position = Vector2.new(vu8.ViewportSize.X / 2, vu8.ViewportSize.Y / 2)
    end
    UpdateCirclePosition()
    vu8:GetPropertyChangedSignal("ViewportSize"):Connect(UpdateCirclePosition)
    function HasGun(p454)
        local v455 = p454:FindFirstChild("Backpack")
        local v456 = p454.Character
        local v457 = v455 and v455:FindFirstChild("Gun")
        if v457 then
            v456 = v457
        elseif v456 then
            v456 = v456:FindFirstChild("Gun")
        end
        return v456
    end
    function IsInsideFOV(p458)
        if getgenv().KnifeUseFOV then
            local v459, v460 = vu8:WorldToViewportPoint(p458)
            if v460 then
                return (Vector2.new(v459.X, v459.Y) - Vector2.new(vu8.ViewportSize.X / 2, vu8.ViewportSize.Y / 2)).Magnitude <= getgenv().KnifeFOVSize
            else
                return false
            end
        else
            return true
        end
    end
vu34.combat:Dropdown({
    Title = "loc:silentaimtypeKNIFE",
    Values = {
        "Only Sheriff",
        "Everyone"
    },
    Value = "Everyone",
    Callback = function(p461)
        getgenv().KnifeTargetingMode = p461
    end
})


-- Dropdown Throw Mode (Instant / Animated)
vu34.combat:Dropdown({
    Title = "Throw Mode",
    Desc = "Instant = langsung lempar | Animated = dengan animasi",
    Values = {"Instant", "Animated"},
    Value = "Animated",
    Callback = function(Selected)
        getgenv().KnifeThrowMode = Selected
        sendnotification("Throw mode: " .. Selected)
    end
})

-- Slider Cooldown
vu34.combat:Slider({
    Title = "Post Throw Cooldown (s)",
    Desc = "Jeda setelah melempar sebelum bisa lempar lagi",
    Step = 0.1,
    Value = {
        Min = 0.1,
        Max = 5,
        Default = 0.5
    },
    Callback = function(Value)
        getgenv().KnifePostCooldown = Value
    end
})

-- Slider Animasi Delay (hanya untuk mode Animated)
vu34.combat:Slider({
    Title = "Animation Delay (s)",
    Desc = "Durasi animasi lempar (hanya untuk mode Animated)",
    Step = 0.05,
    Value = {
        Min = 0.1,
        Max = 2,
        Default = 0.75
    },
    Callback = function(Value)
        getgenv().KnifeAnimDelay = Value
    end
})

    vu34.combat:Toggle({
        Title = "loc:selecttargetinfov",
        Value = false,
        Callback = function(p462)
            getgenv().KnifeUseFOV = p462
        end
    })
    vu34.combat:Toggle({
        Title = "loc:showprediction",
        Value = false,
        Callback = function(p463)
            getgenv().KnifeShowPrediction = p463
            local v464 = vu451
            if p463 then
                p463 = getgenv().KnifeAimEnabled
            end
            v464.Visible = p463
        end
    })
    vu34.combat:Toggle({
        Title = "loc:showfovcircle",
        Value = false,
        Callback = function(p465)
            getgenv().KnifeShowFOV = p465
            local v466 = vu448
            if p465 then
                p465 = getgenv().KnifeAimEnabled
            end
            v466.Visible = p465
        end
    })
    vu34.combat:Slider({
        Title = "loc:fovsizeknife",
        Step = 1,
        Value = {
            Min = 30,
            Max = 300,
            Default = 90
        },
        Callback = function(p467)
            local v468 = tonumber(p467)
            if v468 then
                getgenv().KnifeFOVSize = math.clamp(v468, 50, 500)
                vu448.Radius = getgenv().KnifeFOVSize
            end
        end
    })
    function GetKnifeTarget()
        if getgenv().KnifeAimEnabled then
            local v469 = nil
            local v470 = math.huge
            local v471 = vu14.Character
            if v471 then
                v471 = vu14.Character.PrimaryPart
            end
            if v471 then
                local v472 = vu13
                local v473, v474, v475 = pairs(v472:GetPlayers())
                while true do
                    local v476
                    v475, v476 = v473(v474, v475)
                    if v475 == nil then
                        break
                    end
                    if v476 ~= vu14 then
                        local v477 = v476.Character
                        if v477 then
                            v477 = v476.Character.PrimaryPart
                        end
                        if v477 then
                            local v478 = (v471.Position - v477.Position).Magnitude
                            if IsInsideFOV(v477.Position) and v478 < v470 then
                                if getgenv().KnifeTargetingMode == "Only Sheriff" and HasGun(v476) then
                                    return v476
                                end
                                if getgenv().KnifeTargetingMode == "Everyone" then
                                    v469 = v476
                                    v470 = v478
                                end
                            end
                        end
                    end
                end
                return v469
            end
        end
    end
-- ==================== FUNGSI PREDIKSI DENGAN 3 MODE ====================
local _lastVelocities = {}  -- Untuk mode Extreme

-- ==================== HYBRID PREDICTION (LEGACY + EXTREME + NEW) ====================
-- Rating: ⭐⭐⭐⭐⭐ (5/5) - Akurat untuk semua skenario
function GetKnifePrediction()
    if getgenv().KnifeAimEnabled then
        local target = GetKnifeTarget()
        if target then
            local targetChar = target.Character
            if targetChar then
                local primaryPart = targetChar.PrimaryPart
                if primaryPart then
                    local velocity = primaryPart.AssemblyLinearVelocity
                    local pos = primaryPart.Position
                    local humanoid = targetChar:FindFirstChildOfClass("Humanoid")
                    local moveDir = humanoid and humanoid.MoveDirection or Vector3.new()
                    
                    -- ===== 1. LEGACY PREDICTION (DARI KODE LAMA) =====
                    -- Untuk target diam atau lari lurus
                    local predLegacy = pos + Vector3.new(velocity.X, 0, velocity.Z) * 0.16
                    
                    -- ===== 2. EXTREME PREDICTION (AGRESIF + AKSELERASI) =====
                    -- Untuk target zigzag dan unpredictable
                    local targetKey = tostring(primaryPart)
                    local lastVel = _lastVelocities[targetKey] or velocity
                    local accel = (velocity - lastVel) / 0.1
                    _lastVelocities[targetKey] = velocity
                    task.delay(2, function() _lastVelocities[targetKey] = nil end)
                    
                    local predExtreme = pos + velocity * 0.22 + 0.5 * accel * (0.22 ^ 2)
                    if velocity.Magnitude > 0 then
                        local cross = velocity.Unit:Cross(moveDir)
                        predExtreme = predExtreme + moveDir * 2 + cross * 1.5
                    end
                    
                    -- ===== 3. NEW PREDICTION (KOMPENSASI LOMPATAN) =====
                    -- Untuk target spam jump
                    local isJumping = humanoid and (humanoid.FloorMaterial == Enum.Material.Air) or false
                    local jumpBonus = isJumping and Vector3.new(0, 7.5, 0) or Vector3.new(0, 0, 0)
                    local predNew = pos + velocity * 0.4 + moveDir * 2.5 + jumpBonus
                    
                    -- ===== GABUNGAN: RATA-RATA KETIGANYA =====
                    local predictedPos = (predLegacy + predExtreme + predNew) / 3
                    
                    -- ===== SHOW PREDICTION DOT =====
                    if getgenv().KnifeShowPrediction then
                        local screenPos, onScreen = vu8:WorldToViewportPoint(predictedPos)
                        if onScreen then
                            vu451.Position = Vector2.new(screenPos.X, screenPos.Y)
                            vu451.Visible = true
                        else
                            vu451.Visible = false
                        end
                    end
                    
                    return predictedPos
                end
            end
        end
        vu451.Visible = false
        return nil
    end
end
-- ==================== PREDIKSI DENGAN KOMPENSASI DELAY ====================
local function GetKnifePredictionWithCompensation(targetChar, delay)
    if not targetChar then return nil end
    
    local primaryPart = targetChar.PrimaryPart
    if not primaryPart then return nil end
    
    local velocity = primaryPart.AssemblyLinearVelocity
    local pos = primaryPart.Position
    local humanoid = targetChar:FindFirstChildOfClass("Humanoid")
    local moveDir = humanoid and humanoid.MoveDirection or Vector3.new()
    
    -- Kompensasi delay (semakin lama delay, semakin jauh prediksi)
    local compensationFactor = 1 + (delay * 0.2)  -- Tambah 20% per detik delay
    
    if getgenv().KnifePredictionMode == "Default" then
        local predTime = (getgenv().KnifePredictionTime or 0.16) * compensationFactor
        return pos + Vector3.new(velocity.X, 0, velocity.Z) * predTime + moveDir * (delay * 0.3)
        
    elseif getgenv().KnifePredictionMode == "Extreme" then
        local targetKey = tostring(primaryPart)
        local lastVel = _lastVelocities[targetKey] or velocity
        local accel = (velocity - lastVel) / 0.1
        _lastVelocities[targetKey] = velocity
        task.delay(2, function() _lastVelocities[targetKey] = nil end)
        
        local predTimeExtreme = 0.22 * compensationFactor
        local predictedPos = pos + velocity * predTimeExtreme + 0.5 * accel * (predTimeExtreme ^ 2)
        
        if velocity.Magnitude > 0 then
            local cross = velocity.Unit:Cross(moveDir)
            predictedPos = predictedPos + moveDir * (2 + delay) + cross * (1.5 + delay)
        end
        return predictedPos
        
    elseif getgenv().KnifePredictionMode == "Legacy" then
        local predTime = (16 / 100) * compensationFactor
        return pos + Vector3.new(velocity.X, 0, velocity.Z) * predTime + moveDir * (delay * 0.3)
    end
    
    return pos
end
vu10.RenderStepped:Connect(function()
    if getgenv().KnifeAimEnabled then
        vu448.Visible = getgenv().KnifeShowFOV
        local pred = GetKnifePrediction()
        if pred then
            getgenv().KnifeSilentAim.CurrentPrediction = pred
        end
    else
        vu448.Visible = false
        vu451.Visible = false
    end
end)
    vu34.combat:Toggle({
        Title = "loc:togsilentaimKNIFE",
        Value = false,
        Callback = function(p486)
            getgenv().KnifeAimEnabled = p486
        end
    })
    local vu487 = {}
vu34.combat:Keybind({
    Title = "loc:silentaimKNIFE",
    Value = "R",
    Callback = function()
        if not getgenv().KnifeAimEnabled then
            sendnotification("Silent Aim Knife is disabled!")
            return
        end
        
        if GetMurder() ~= vu14 then
            sendnotification("You're not Murderer.")
            return
        end
        
        -- ===== CEK COOLDOWN =====
        local now = tick()
        local cooldown = getgenv().KnifePostCooldown or 0.5
        if getgenv()._knifeLastThrow and (now - getgenv()._knifeLastThrow) < cooldown then
            local remaining = math.floor((cooldown - (now - getgenv()._knifeLastThrow)) * 10) / 10
            sendnotification("⏱ Cooldown: " .. remaining .. "s")
            return
        end
        
        -- ===== CEK KNIFE =====
        if not vu14.Character:FindFirstChild("Knife") then
            local humanoid = vu14.Character:FindFirstChild("Humanoid")
            if not vu14.Backpack:FindFirstChild("Knife") then
                sendnotification("No knife found!")
                return
            end
            humanoid:EquipTool(vu14.Backpack:FindFirstChild("Knife"))
            task.wait(0.1)
        end
        
        local knife = vu14.Backpack:FindFirstChild("Knife") or vu14.Character:FindFirstChild("Knife")
        if not knife then
            sendnotification("Knife not found!")
            return
        end
        
        -- ===== DAPATKAN TARGET & PREDIKSI AWAL =====
        local target = GetKnifeTarget()
        if not target or not target.Character then
            sendnotification("No target in FOV!")
            return
        end
        
        local predictedPos = GetKnifePrediction()
        if not predictedPos then
            sendnotification("No target in FOV!")
            return
        end
        
        -- ===== INSTANT vs ANIMATED =====
        local success = false
        
        if getgenv().KnifeThrowMode == "Instant" then
            -- INSTANT: Langsung lempar
            local handleCFrame = knife.Handle and knife.Handle.CFrame or CFrame.new()
            local throwData = {handleCFrame, CFrame.new(predictedPos)}
            
            pcall(function()
                if vu14.Character.Knife and vu14.Character.Knife.Events and vu14.Character.Knife.Events.KnifeThrown then
                    vu14.Character.Knife.Events.KnifeThrown:FireServer(unpack(throwData))
                    success = true
                end
            end)
        else
            -- ===== ANIMATED: Dengan animasi =====
            local chargeAnim = nil
            local throwAnim = nil
            local knifeClient = knife:FindFirstChild("KnifeClient")
            if knifeClient then
                chargeAnim = knifeClient:FindFirstChild("ThrowCharge")
                throwAnim = knifeClient:FindFirstChild("Throwknife")
            end
            
            local humanoid = vu14.Character:FindFirstChildOfClass("Humanoid")
            local animTrack = nil
            local animDelay = getgenv().KnifeAnimDelay or 0.75
            
            -- Play charge animation
            if chargeAnim and humanoid then
                animTrack = humanoid:LoadAnimation(chargeAnim)
                if animTrack then animTrack:Play() end
            end
            
            task.wait(animDelay)
            
            -- Play throw animation
            if throwAnim and humanoid then
                if animTrack then animTrack:Stop() end
                animTrack = humanoid:LoadAnimation(throwAnim)
                if animTrack then animTrack:Play() end
            end
            
            task.wait(0.05)
            
            -- Throw
            local handleCFrame = knife.Handle and knife.Handle.CFrame or CFrame.new()
            local throwData = {handleCFrame, CFrame.new(predictedPos)}
            
            pcall(function()
                if vu14.Character.Knife and vu14.Character.Knife.Events and vu14.Character.Knife.Events.KnifeThrown then
                    vu14.Character.Knife.Events.KnifeThrown:FireServer(unpack(throwData))
                    success = true
                end
            end)
            
            task.wait(0.2)
            if animTrack and animTrack.IsPlaying then animTrack:Stop() end
        end
        
        -- ===== UPDATE COOLDOWN =====
        if success then
            getgenv()._knifeLastThrow = tick()
            sendnotification("🗡️ Thrown! (Hybrid | " .. getgenv().KnifeThrowMode .. ")")
        else
            sendnotification("❌ Failed to throw!")
        end
    end
})  -- ✅ HANYA SATU KURUNG TUTUP
    vu34.troll:Section({
        Title = "Fling"
    })
    local vu493 = ""
    vu34.troll:Input({
        Title = "loc:inputfling",
        Type = "Input",
        Placeholder = "...",
        Callback = function(p494)
            vu493 = p494:lower()
        end
    })
    getgenv().alr = false
    function miniFling(p495)
        getgenv().alr = true
        local v496 = {
            p495
        }
        local vu497 = game:GetService("Players")
        local vu498 = vu497.LocalPlayer
        if not getgenv().FPDH then
            getgenv().FPDH = vu12.FallenPartsDestroyHeight
        end;
        (function(pu499)
            local vu500 = vu498.Character
            local vu501
            if vu500 then
                vu501 = vu500:FindFirstChildOfClass("Humanoid")
            else
                vu501 = vu500
            end
            local vu502
            if vu501 then
                vu502 = vu501.RootPart
            else
                vu502 = vu501
            end
            if pu499 and (vu500 and (vu501 and vu502)) then
                local vu503 = pu499.Character
                if vu503 then
                    local vu504 = nil
                    local v505 = nil
                    local v506 = nil
                    local v507 = nil
                    local vu508
                    if vu503:FindFirstChildOfClass("Humanoid") then
                        vu508 = vu503:FindFirstChildOfClass("Humanoid")
                    else
                        vu508 = nil
                    end
                    if vu508 and vu508.RootPart then
                        vu504 = vu508.RootPart
                    end
                    if vu503:FindFirstChild("Head") then
                        v505 = vu503.Head
                    end
                    if vu503:FindFirstChildOfClass("Accessory") then
                        v506 = vu503:FindFirstChildOfClass("Accessory")
                    end
                    if v506 and v506:FindFirstChild("Handle") then
                        v507 = v506.Handle
                    end
                    if vu500 and (vu501 and (vu502 and vu502.Velocity.Magnitude < 50)) then
                        getgenv().OldPos = vu502.CFrame
                    end
                    if v505 then
                        if v505.Velocity.Magnitude > 500 then
                            sendnotification("Target Head \209\129\208\187\208\184\209\136\208\186\208\190\208\188 \208\177\209\139\209\129\209\130\209\128\208\190 \208\180\208\178\208\184\208\182\208\181\209\130\209\129\209\143")
                            getgenv().alr = false
                            return
                        end
                    elseif not v505 and (v507 and v507.Velocity.Magnitude > 500) then
                        sendnotification("Target Handle \209\129\208\187\208\184\209\136\208\186\208\190\208\188 \208\177\209\139\209\129\209\130\209\128\208\190 \208\180\208\178\208\184\208\182\208\181\209\130\209\129\209\143")
                        getgenv().alr = false
                        return
                    end
                    vu12.CurrentCamera.CameraSubject = v505 or (v507 or (vu508 or vu501))
                    if vu503:FindFirstChildWhichIsA("BasePart") then
                        local function vu512(p509, p510, p511)
                            if vu502 and vu500 then
                                vu502.CFrame = CFrame.new(p509.Position) * p510 * p511
                                if vu500.PrimaryPart then
                                    vu500:SetPrimaryPartCFrame(CFrame.new(p509.Position) * p510 * p511)
                                end
                                vu502.Velocity = Vector3.new(90000000, 900000000, 90000000)
                                vu502.RotVelocity = Vector3.new(900000000, 900000000, 900000000)
                            end
                        end
                        local function v517(p513)
                            local v514 = tick()
                            local v515 = 2
                            local v516 = 0
                            while true do
                                if not (vu502 and (vu508 and (p513 and p513.Parent))) then
                                    getgenv().alr = false
                                    break
                                end
                                if p513.Velocity.Magnitude >= 50 then
                                    vu512(p513, CFrame.new(0, 1.5, vu508.WalkSpeed), CFrame.Angles(math.rad(90), 0, 0))
                                    task.wait()
                                    vu512(p513, CFrame.new(0, - 1.5, - vu508.WalkSpeed), CFrame.Angles(0, 0, 0))
                                    task.wait()
                                    vu512(p513, CFrame.new(0, 1.5, vu508.WalkSpeed), CFrame.Angles(math.rad(90), 0, 0))
                                    task.wait()
                                    vu512(p513, CFrame.new(0, 1.5, vu504.Velocity.Magnitude / 1.25), CFrame.Angles(math.rad(90), 0, 0))
                                    task.wait()
                                    vu512(p513, CFrame.new(0, - 1.5, - vu504.Velocity.Magnitude / 1.25), CFrame.Angles(0, 0, 0))
                                    task.wait()
                                    vu512(p513, CFrame.new(0, 1.5, vu504.Velocity.Magnitude / 1.25), CFrame.Angles(math.rad(90), 0, 0))
                                    task.wait()
                                    vu512(p513, CFrame.new(0, - 1.5, 0), CFrame.Angles(math.rad(90), 0, 0))
                                    task.wait()
                                    vu512(p513, CFrame.new(0, - 1.5, 0), CFrame.Angles(0, 0, 0))
                                    task.wait()
                                    vu512(p513, CFrame.new(0, - 1.5, 0), CFrame.Angles(math.rad(- 90), 0, 0))
                                    task.wait()
                                    vu512(p513, CFrame.new(0, - 1.5, 0), CFrame.Angles(0, 0, 0))
                                    task.wait()
                                else
                                    v516 = v516 + 100
                                    vu512(p513, CFrame.new(0, 1.5, 0) + vu508.MoveDirection * p513.Velocity.Magnitude / 1.25, CFrame.Angles(math.rad(v516), 0, 0))
                                    task.wait()
                                    vu512(p513, CFrame.new(0, - 1.5, 0) + vu508.MoveDirection * p513.Velocity.Magnitude / 1.25, CFrame.Angles(math.rad(v516), 0, 0))
                                    task.wait()
                                    vu512(p513, CFrame.new(2.25, 1.5, - 2.25) + vu508.MoveDirection * p513.Velocity.Magnitude / 1.25, CFrame.Angles(math.rad(v516), 0, 0))
                                    task.wait()
                                    vu512(p513, CFrame.new(- 2.25, - 1.5, 2.25) + vu508.MoveDirection * p513.Velocity.Magnitude / 1.25, CFrame.Angles(math.rad(v516), 0, 0))
                                    task.wait()
                                    vu512(p513, CFrame.new(0, 1.5, 0) + vu508.MoveDirection, CFrame.Angles(math.rad(v516), 0, 0))
                                    task.wait()
                                    vu512(p513, CFrame.new(0, - 1.5, 0) + vu508.MoveDirection, CFrame.Angles(math.rad(v516), 0, 0))
                                    task.wait()
                                end
                                if p513.Velocity.Magnitude > 500 or (p513.Parent ~= pu499.Character or (pu499.Parent ~= vu497 or (pu499.Character ~= vu503 or (vu508.Sit or (vu501.Health <= 0 or tick() > v514 + v515))))) then
                                    break
                                end
                            end
                        end
                        vu12.FallenPartsDestroyHeight = 0 / 0
                        local v518 = Instance.new("BodyVelocity")
                        v518.Name = "EpixVel"
                        v518.Parent = vu502
                        v518.Velocity = Vector3.new(900000000, 900000000, 900000000)
                        v518.MaxForce = Vector3.new(1 / 0, 1 / 0, 1 / 0)
                        vu501:SetStateEnabled(Enum.HumanoidStateType.Seated, false)
                        pcall(function()
                            sendnotification("\239\191\189\208\176\209\135\208\176\208\187\208\190 \209\132\208\187\208\184\208\189\208\179\208\176")
                        end)
                        if vu504 and v505 then
                            if (vu504.CFrame.p - v505.CFrame.p).Magnitude <= 5 then
                                v517(vu504)
                            else
                                v517(v505)
                            end
                        elseif vu504 and not v505 then
                            v517(vu504)
                        elseif vu504 or not v505 then
                            if not vu504 and (not v505 and (v506 and v507)) then
                                v517(v507)
                            end
                        else
                            v517(v505)
                        end
                        v518:Destroy()
                        vu501:SetStateEnabled(Enum.HumanoidStateType.Seated, true)
                        vu12.CurrentCamera.CameraSubject = vu501
                        if getgenv().OldPos and (vu500 and (vu501 and vu502)) then
                            print("\239\191\189\208\176\209\135\208\176\208\187\208\190 \208\178\208\190\208\183\208\178\209\128\208\176\209\130\208\176")
                            while vu502 and (vu500 and vu501) do
                                local v519 = getgenv().OldPos * CFrame.new(0, 0.5, 0)
                                vu502.CFrame = v519
                                if vu500.PrimaryPart then
                                    vu500:SetPrimaryPartCFrame(v519)
                                end
                                vu501:ChangeState("GettingUp")
                                local v520, v521, v522 = ipairs(vu500:GetChildren())
                                while true do
                                    local v523
                                    v522, v523 = v520(v521, v522)
                                    if v522 == nil then
                                        break
                                    end
                                    if v523:IsA("BasePart") then
                                        v523.Velocity = Vector3.new()
                                        v523.RotVelocity = Vector3.new()
                                    end
                                end
                                task.wait()
                                if (vu502.Position - getgenv().OldPos.p).Magnitude < 10 then
                                    break
                                end
                            end
                            print("\239\191\189\208\190\208\183\208\178\209\128\208\176\209\130 \208\183\208\176\208\178\208\181\209\128\209\136\209\145\208\189")
                            getgenv().alr = false
                        end
                        vu12.FallenPartsDestroyHeight = getgenv().FPDH
                    else
                        sendnotification("Target \208\189\208\181 \208\184\208\188\208\181\208\181\209\130 BasePart")
                        getgenv().alr = false
                    end
                else
                    sendnotification("\239\191\189\208\181\208\187\209\140 \208\189\208\181 \208\184\208\188\208\181\208\181\209\130 Character")
                    getgenv().alr = false
                    return
                end
            else
                sendnotification("\239\191\189\208\190\208\186\208\176\208\187\209\140\208\189\209\139\208\185 \208\191\208\181\209\128\209\129\208\190\208\189\208\176\208\182 \208\184\208\187\208\184 RootPart \208\189\208\181 \208\189\208\176\208\185\208\180\208\181\208\189")
                getgenv().alr = false
                return
            end
        end)(v496[1])
        vu12.FallenPartsDestroyHeight = - 50000
        getgenv().alr = false
    end
    function GetTarget(p524)
        local v525 = vu13
        local v526, v527, v528 = pairs(v525:GetPlayers())
        while true do
            local v529
            v528, v529 = v526(v527, v528)
            if v528 == nil then
                break
            end
            if v529 ~= vu14 and (v529.Name:lower():find(p524) or v529.DisplayName:lower():find(p524)) then
                return v529
            end
        end
        return nil
    end
    local vu530 = nil
    local vu531 = false
    local function vu533(pu532)
        repeat
            task.wait(0.05)
        until not vu531
        vu531 = true
        pcall(function()
            miniFling(pu532)
        end)
        vu531 = false
        getgenv().alr = false
    end
    local vu536 = vu34.troll:Toggle({
        Title = "loc:flingplayer",
        Value = false,
        Callback = function(p534)
            enb = p534
            if p534 then
                if vu530 then
                    sendnotification("\239\191\189\209\128\209\131\208\179\208\190\208\185 \209\132\208\187\208\184\208\189\208\179 \209\131\208\182\208\181 \208\176\208\186\209\130\208\184\208\178\208\181\208\189: " .. vu530)
                    return false
                end
                vu530 = "flingplayer"
                task.spawn(function()
                    while enb do
                        local v535 = GetTarget(vu493)
                        if v535 then
                            vu533(v535)
                            repeat
                                task.wait(0.5)
                            until not getgenv().alr
                        end
                        task.wait()
                    end
                    vu530 = nil
                end)
            end
        end
    })
    local vu542 = vu34.troll:Toggle({
        Title = "loc:flingall",
        Value = false,
        Callback = function(p537)
            mm = p537
            if p537 then
                if vu530 then
                    sendnotification("\239\191\189\209\128\209\131\208\179\208\190\208\185 \209\132\208\187\208\184\208\189\208\179 \209\131\208\182\208\181 \208\176\208\186\209\130\208\184\208\178\208\181\208\189: " .. vu530)
                    return false
                end
                vu530 = "flingall"
                task.spawn(function()
                    while mm do
                        local v538, v539, v540 = ipairs(game.Players:GetPlayers())
                        while true do
                            local v541
                            v540, v541 = v538(v539, v540)
                            if v540 == nil then
                                break
                            end
                            if v541 ~= vu14 then
                                vu533(v541)
                                repeat
                                    task.wait(0.5)
                                until not getgenv().alr
                            end
                        end
                        task.wait(0.1)
                    end
                    vu530 = nil
                end)
            end
        end
    })
    local vu545 = vu34.troll:Toggle({
        Title = "loc:flingmurder",
        Value = false,
        Callback = function(p543)
            mm = p543
            if p543 then
                if vu530 then
                    sendnotification("\239\191\189\209\128\209\131\208\179\208\190\208\185 \209\132\208\187\208\184\208\189\208\179 \209\131\208\182\208\181 \208\176\208\186\209\130\208\184\208\178\208\181\208\189: " .. vu530)
                    return false
                end
                vu530 = "flingmurder"
                task.spawn(function()
                    while mm do
                        local v544 = GetMurder()
                        if v544 then
                            vu533(v544)
                            repeat
                                task.wait(0.5)
                            until not getgenv().alr
                        end
                        task.wait()
                    end
                    vu530 = nil
                end)
            end
        end
    })
    local vu548 = vu34.troll:Toggle({
        Title = "loc:flingsheriff",
        Value = false,
        Callback = function(p546)
            mm = p546
            if p546 then
                if vu530 then
                    sendnotification("\239\191\189\209\128\209\131\208\179\208\190\208\185 \209\132\208\187\208\184\208\189\208\179 \209\131\208\182\208\181 \208\176\208\186\209\130\208\184\208\178\208\181\208\189: " .. vu530)
                    return false
                end
                vu530 = "flingsheriff"
                task.spawn(function()
                    while mm do
                        local v547 = GetSheriff()
                        if v547 then
                            vu533(v547)
                            repeat
                                task.wait(0.5)
                            until not getgenv().alr
                        end
                        task.wait()
                    end
                    vu530 = nil
                end)
            end
        end
    })
    -- ==================== TROLLING TAB - PLAYER SELECTION SYSTEM ====================
-- Tambahkan setelah Section "Fling" (di sekitar line 2000-an)
-- Cari "vu34.troll:Section({ Title = "Fling" })" lalu tambahkan setelah itu

-- ==================== PLAYER SELECTION SYSTEM ====================
vu34.troll:Section({
    Title = "Player Selection",
    Icon = "users"
})

local SelectedTarget = nil
local SelectedTargetName = ""

-- Input untuk memilih target player
vu34.troll:Input({
    Title = "Select Target Player",
    Desc = "Enter player name to target",
    Placeholder = "Player name...",
    Callback = function(Text)
        SelectedTargetName = Text:lower()
        SelectedTarget = nil
        
        if SelectedTargetName ~= "" then
            for _, Player in ipairs(game.Players:GetPlayers()) do
                if Player ~= LocalPlayer then
                    if Player.Name:lower():find(SelectedTargetName) or Player.DisplayName:lower():find(SelectedTargetName) then
                        SelectedTarget = Player
                        sendnotification("✅ Target selected: " .. Player.Name)
                        break
                    end
                end
            end
            if not SelectedTarget then
                sendnotification("❌ Player not found!")
            end
        end
    end
})

-- Button untuk menampilkan target yang dipilih
vu34.troll:Button({
    Title = "Show Selected Target",
    Callback = function()
        if SelectedTarget then
            sendnotification("🎯 Current target: " .. SelectedTarget.Name)
        else
            sendnotification("❌ No target selected!")
        end
    end
})


    vu34.troll:Section({
        Title = "Gang Bang"
    })
    local vu549 = game:GetService("TweenService")
    targetName = ""
    targetPlayer = nil
    bangFollowing = false
    bangAnimationId = "10714068222"
    bangAnimTrack = nil
    bangCoroutine = nil
    bangCharConnection = nil
    gsRunning = false
    gsAnimationId = "5918726674"
    gsAnimTrack = nil
    gsCoroutine = nil
    gsCharConnection = nil
    gsOriginalGravity = nil
    vu34.troll:Input({
        Title = "loc:inputbang",
        Type = "Input",
        Placeholder = "...",
        Callback = function(p550)
            targetName = p550:lower()
        end
    })
    local function vu556()
        local v551 = vu13
        local v552, v553, v554 = pairs(v551:GetPlayers())
        while true do
            local v555
            v554, v555 = v552(v553, v554)
            if v554 == nil then
                break
            end
            if (string.find(v555.Name:lower(), targetName) or string.find(v555.DisplayName:lower(), targetName)) and v555 ~= vu14 then
                return v555
            end
        end
        return nil
    end
    local function vu561(p557, p558)
        if p557 then
            local v559 = Instance.new("Animation")
            v559.AnimationId = "rbxassetid://" .. p558
            local v560 = p557:LoadAnimation(v559)
            v560:Play()
            return v560
        end
    end
    local function vu562()
        bangFollowing = false
        if bangAnimTrack then
            bangAnimTrack:Stop()
            bangAnimTrack = nil
        end
        bangCoroutine = nil
        if bangCharConnection then
            bangCharConnection:Disconnect()
            bangCharConnection = nil
        end
    end
    local function vu563()
        gsRunning = false
        if gsAnimTrack then
            gsAnimTrack:Stop()
            gsAnimTrack = nil
        end
        if gsCoroutine then
            gsCoroutine = nil
        end
        if gsCharConnection then
            gsCharConnection:Disconnect()
            gsCharConnection = nil
        end
        if gsOriginalGravity then
            vu12.Gravity = gsOriginalGravity
            gsOriginalGravity = nil
        end
    end
    vu34.troll:Toggle({
        Title = "loc:bang",
        Value = false,
        Callback = function(p564)
            if p564 then
                targetPlayer = vu556()
                if targetPlayer then
                    bangFollowing = true
                    local function v570()
                        while bangFollowing do
                            local v565 = vu14.Character
                            local v566
                            if v565 then
                                v566 = v565:FindFirstChildOfClass("Humanoid")
                            else
                                v566 = v565
                            end
                            if v565 then
                                v565 = v565:FindFirstChild("HumanoidRootPart")
                            end
                            local v567 = targetPlayer.Character
                            if v567 then
                                v567 = v567:FindFirstChild("HumanoidRootPart")
                            end
                            if v566 and (v565 and v567) then
                                if not (bangAnimTrack and bangAnimTrack.IsPlaying) then
                                    bangAnimTrack = vu561(v566, bangAnimationId)
                                    bangAnimTrack:AdjustSpeed(2)
                                end
                                local v568 = v567.CFrame * CFrame.new(0, 0, 1)
                                local v569 = v567.CFrame * CFrame.new(0, 0, 2.5)
                                vu549:Create(v565, TweenInfo.new(0.2), {
                                    CFrame = v568
                                }):Play()
                                wait(0.2)
                                vu549:Create(v565, TweenInfo.new(0.2), {
                                    CFrame = v569
                                }):Play()
                                wait(0.2)
                            else
                                wait(0.5)
                            end
                        end
                        if bangAnimTrack then
                            bangAnimTrack:Stop()
                            bangAnimTrack = nil
                        end
                    end
                    bangCoroutine = coroutine.wrap(v570)
                    bangCoroutine()
                    bangCharConnection = vu14.CharacterAdded:Connect(function(p571)
                        if bangFollowing then
                            local v572 = p571:WaitForChild("Humanoid")
                            if bangAnimTrack then
                                bangAnimTrack:Stop()
                            end
                            bangAnimTrack = vu561(v572, bangAnimationId)
                            bangAnimTrack:AdjustSpeed(2)
                        end
                    end)
                else
                    print("Target not found for Bang!")
                    vu562()
                end
            else
                vu562()
                return
            end
        end
    })
    vu34.troll:Toggle({
        Title = "loc:getsuck",
        Value = false,
        Callback = function(p573)
            if p573 then
                targetPlayer = vu556()
                if targetPlayer then
                    gsRunning = true
                    gsOriginalGravity = vu12.Gravity
                    vu12.Gravity = 0
                    local function v579()
                        local v574 = vu14.Character
                        local v575
                        if v574 then
                            v575 = v574:FindFirstChildOfClass("Humanoid")
                        else
                            v575 = v574
                        end
                        if v574 then
                            v574:FindFirstChild("HumanoidRootPart")
                        end
                        local v576 = targetPlayer.Character
                        if v576 then
                            v576:FindFirstChild("HumanoidRootPart")
                        end
                        if v575 then
                            gsAnimTrack = vu561(v575, gsAnimationId)
                            gsAnimTrack:AdjustSpeed(2)
                        end
                        while gsRunning do
                            local v577 = vu14.Character
                            if v577 then
                                v577 = v577:FindFirstChild("HumanoidRootPart")
                            end
                            local v578 = targetPlayer.Character
                            if v578 then
                                v578 = targetPlayer.Character:FindFirstChild("HumanoidRootPart")
                            end
                            if v577 and v578 then
                                v577.CFrame = v578.CFrame * CFrame.new(0, 2.3, - 1.1) * CFrame.Angles(0, math.pi, 0)
                                v577.Velocity = Vector3.new(0, 0, 0)
                            else
                                wait(0.5)
                            end
                            vu10.Heartbeat:Wait()
                        end
                        if gsAnimTrack then
                            gsAnimTrack:Stop()
                            gsAnimTrack = nil
                        end
                        if gsOriginalGravity then
                            vu12.Gravity = gsOriginalGravity
                            gsOriginalGravity = nil
                        end
                    end
                    gsCoroutine = coroutine.wrap(v579)
                    gsCoroutine()
                    gsCharConnection = vu14.CharacterAdded:Connect(function(p580)
                        if gsRunning then
                            local v581 = p580:WaitForChild("Humanoid")
                            if gsAnimTrack then
                                gsAnimTrack:Stop()
                            end
                            gsAnimTrack = vu561(v581, gsAnimationId)
                            gsAnimTrack:AdjustSpeed(2)
                        end
                    end)
                else
                    print("Target not found for Get Sucked!")
                    vu563()
                end
            else
                vu563()
                return
            end
        end
    })
    vu34.troll:Section({
        Title = "Fake Die"
    })
    vu34.troll:Button({
        Title = "loc:layonback",
        Callback = function()
            local v582 = game:GetService("Players").LocalPlayer.Character
            if v582 then
                v582 = game:GetService("Players").LocalPlayer.Character:FindFirstChildOfClass("Humanoid")
            end
            if v582 then
                v582.Sit = true
                task.wait(0.1)
                v582.RootPart.CFrame = v582.RootPart.CFrame * CFrame.Angles(math.pi * 0.5, 0, 0)
                local v583, v584, v585 = ipairs(v582:GetPlayingAnimationTracks())
                while true do
                    local v586
                    v585, v586 = v583(v584, v585)
                    if v585 == nil then
                        break
                    end
                    v586:Stop()
                end
                wait()
            end
        end
    })
    vu34.troll:Button({
        Title = "loc:sitdown",
        Callback = function()
            game:GetService("Players").LocalPlayer.Character:FindFirstChildOfClass("Humanoid").Sit = true
            wait()
        end
    })
    vu34.esp:Section({
        Title = "Esp"
    })
    local vu587 = Instance.new("Folder", vu9)
    vu587.Name = "ESP Holder"
    local function v591(pu588)
        local vu589 = Instance.new("BillboardGui", vu587)
        vu589.Name = pu588.Name
        vu589.AlwaysOnTop = true
        vu589.Size = UDim2.fromOffset(200, 50)
        vu589.ExtentsOffset = Vector3.new(0, 3, 0)
        vu589.Enabled = false
        local vu590 = Instance.new("TextLabel", vu589)
        vu590.TextSize = 15
        vu590.Text = pu588.Name
        vu590.Font = Enum.Font.Legacy
        vu590.BackgroundTransparency = 1
        vu590.Size = UDim2.fromScale(1, 1)
        vu590.TextStrokeTransparency = 0
        vu590.TextStrokeColor3 = Color3.new(0, 0, 0)
        if getgenv().AllEsp then
            vu589.Enabled = true
        end
        repeat
            wait()
            pcall(function()
                vu589.Adornee = pu588.Character.Head
                if pu588.Character:FindFirstChild("Knife") or pu588.Backpack:FindFirstChild("Knife") then
                    vu590.TextColor3 = Color3.new(1, 0, 0)
                    if not vu589.Enabled and getgenv().MurderEsp then
                        vu589.Enabled = true
                    end
                elseif pu588.Character:FindFirstChild("Gun") or pu588.Backpack:FindFirstChild("Gun") then
                    vu590.TextColor3 = Color3.new(0, 0, 1)
                    if not vu589.Enabled and getgenv().SheriffEsp then
                        vu589.Enabled = true
                    end
                else
                    vu590.TextColor3 = Color3.new(0, 1, 0)
                end
            end)
        until not pu588.Parent
    end
    local v592, v593, v594 = pairs(vu13:GetPlayers())
    local vu595 = vu282
    local vu596 = vu533
    local vu597 = vu530
    local vu598 = vu587
    local vu599 = vu271
    while true do
        local v600, v601 = v592(v593, v594)
        if v600 == nil then
            break
        end
        v594 = v600
        if v601 ~= vu14 then
            coroutine.wrap(v591)(v601)
        end
    end
    vu13.PlayerAdded:Connect(v591)
    vu13.PlayerRemoving:Connect(function(p602)
        vu598[p602.Name]:Destroy()
    end)
    vu34.esp:Toggle({
        Title = "loc:playersnameesp",
        Value = false,
        Callback = function(p603)
            getgenv().AllEsp = p603
            local v604 = vu598
            local v605, v606, v607 = pairs(v604:GetChildren())
            while true do
                local v608
                v607, v608 = v605(v606, v607)
                if v607 == nil then
                    break
                end
                if v608:IsA("BillboardGui") and vu13[tostring(v608.Name)] then
                    if getgenv().AllEsp then
                        v608.Enabled = true
                    else
                        v608.Enabled = false
                    end
                end
            end
        end
    })
    local vu609 = false
    local vu610 = game:GetService("CollectionService")
    function highlightGunDrop(p611)
        if p611 and not p611:FindFirstChild("Esp_gun") then
            local v612 = Instance.new("BillboardGui", p611)
            v612.Name = "Esp_gun"
            v612.Size = UDim2.new(0, 100, 0, 50)
            v612.StudsOffset = Vector3.new(0, 2, 0)
            v612.AlwaysOnTop = true
            local v613 = Instance.new("TextLabel", v612)
            v613.Size = UDim2.new(1, 0, 1, 0)
            v613.BackgroundTransparency = 1
            v613.Text = "Dropped Gun"
            v613.TextColor3 = Color3.fromRGB(255, 0, 0)
            v613.TextStrokeTransparency = 0
            v613.TextStrokeColor3 = Color3.fromRGB(0, 0, 0)
            v613.TextScaled = true
        end
    end
    function stopESP()
        local v614 = vu610
        local v615, v616, v617 = pairs(v614:GetTagged("GunDrop"))
        while true do
            local v618
            v617, v618 = v615(v616, v617)
            if v617 == nil then
                break
            end
            local v619 = v618:FindFirstChild("Esp_gun")
            if v619 then
                v619:Destroy()
            end
        end
    end
    function startESP()
        local v620 = vu610
        local v621, v622, v623 = pairs(v620:GetTagged("GunDrop"))
        while true do
            local v624
            v623, v624 = v621(v622, v623)
            if v623 == nil then
                break
            end
            highlightGunDrop(v624)
        end
    end
    vu34.esp:Toggle({
        Title = "loc:espdropgun",
        Value = false,
        Callback = function(p625)
            vu609 = p625
            if p625 then
                vu610:GetInstanceAddedSignal("GunDrop"):Connect(function(p626)
                    if vu609 then
                        highlightGunDrop(p626)
                    end
                end)
                vu610:GetInstanceRemovedSignal("GunDrop"):Connect(function(p627)
                    local v628 = vu609 and p627:FindFirstChild("Esp_gun")
                    if v628 then
                        v628:Destroy()
                    end
                end)
                startESP()
            else
                stopESP()
            end
        end
    })
    getgenv().seeCoins = false
    local vu629 = {}
    local vu630 = nil
    local function vu634(p631)
        if getgenv().seeCoins then
            if p631:IsA("BasePart") and not vu629[p631] then
                local v632 = Instance.new("BoxHandleAdornment")
                v632.Size = Vector3.new(2, 2, 2)
                local v633 = Color3.fromRGB(100, 255, 100)
                v632.Parent = p631
                v632.Adornee = p631
                v632.ZIndex = 1
                v632.AlwaysOnTop = true
                v632.Transparency = 0.7
                v632.Color3 = v633
                vu629[p631] = v632
            end
        end
    end
    vu34.esp:Toggle({
        Title = "loc:espcoins",
        Value = false,
        Callback = function(p635)
            getgenv().seeCoins = p635
            if vu630 then
                vu630:Disconnect()
            end
            local v636, v637, v638 = pairs(vu629)
            while true do
                local v639
                v638, v639 = v636(v637, v638)
                if v638 == nil then
                    break
                end
                v639:Destroy()
            end
            table.clear(vu629)
            if p635 then
                local v640, v641, v642 = pairs(game.Workspace:GetDescendants())
                while true do
                    local v643
                    v642, v643 = v640(v641, v642)
                    if v642 == nil then
                        break
                    end
                    if v643:IsA("Model") and v643.Name == "CoinContainer" then
                        local v644, v645, v646 = pairs(v643:GetChildren())
                        while true do
                            local v647
                            v646, v647 = v644(v645, v646)
                            if v646 == nil then
                                break
                            end
                            if v647:IsA("BasePart") then
                                vu634(v647)
                            end
                        end
                    end
                end
                vu630 = game.Workspace.DescendantAdded:Connect(function(p648)
                    if p648:IsA("BasePart") and (p648.Parent and p648.Parent.Name == "CoinContainer") then
                        vu634(p648)
                    end
                end)
            end
        end
    })
    getgenv().thrownTOG = false
    function addHighlight(p649)
        if getgenv().thrownTOG and not p649:FindFirstChild("Highlight") then
            local v650 = Instance.new("Highlight")
            v650.FillColor = Color3.fromRGB(0, 200, 160)
            v650.OutlineColor = Color3.fromRGB(0, 200, 160)
            v650.FillTransparency = 0
            v650.DepthMode = Enum.HighlightDepthMode.AlwaysOnTop
            v650.OutlineTransparency = 0
            v650.Adornee = p649
            v650.Parent = p649
        end
    end
    vu12.DescendantAdded:Connect(function(p651)
        if getgenv().thrownTOG and (p651:IsA("Model") and p651.Name == "ThrowingKnife") then
            addHighlight(p651)
        end
    end)
    vu34.esp:Toggle({
        Title = "loc:seethrownknife",
        Value = false,
        Callback = function(p652)
            getgenv().thrownTOG = p652
            if not p652 then
                local v653 = vu12
                local v654, v655, v656 = ipairs(v653:GetDescendants())
                while true do
                    local v657
                    v656, v657 = v654(v655, v656)
                    if v656 == nil then
                        break
                    end
                    if v657:IsA("Model") and v657.Name == "ThrowingKnife" then
                        local v658 = v657:FindFirstChild("Highlight")
                        if v658 then
                            v658:Destroy()
                        end
                    end
                end
            end
        end
    })
    local vu659 = game:GetService("ReplicatedStorage")
    local vu660 = {}
    local vu661 = {
        HighlightMurderer = false,
        HighlightSheriff = false,
        HighlightInnocent = false
    }
    function AnyESPEnabled()
        return vu661.HighlightMurderer or (vu661.HighlightSheriff or vu661.HighlightInnocent)
    end
    local function vu671()
        local v662 = vu13
        local v663, v664, v665 = ipairs(v662:GetPlayers())
        while true do
            local v666
            v665, v666 = v663(v664, v665)
            if v665 == nil then
                break
            end
            if v666.Backpack and v666.Backpack:FindFirstChild("Knife") then
                return v666
            end
            if v666.Character and v666.Character:FindFirstChild("Knife") then
                return v666
            end
        end
        if vu660 then
            local v667, v668, v669 = pairs(vu660)
            while true do
                local v670
                v669, v670 = v667(v668, v669)
                if v669 == nil then
                    break
                end
                if v670.Role == "Murderer" then
                    return vu13:FindFirstChild(v669)
                end
            end
        end
        return nil
    end
    local function vu681()
        local v672 = vu13
        local v673, v674, v675 = ipairs(v672:GetPlayers())
        while true do
            local v676
            v675, v676 = v673(v674, v675)
            if v675 == nil then
                break
            end
            if v676.Backpack and v676.Backpack:FindFirstChild("Gun") then
                return v676
            end
            if v676.Character and v676.Character:FindFirstChild("Gun") then
                return v676
            end
        end
        if vu660 then
            local v677, v678, v679 = pairs(vu660)
            while true do
                local v680
                v679, v680 = v677(v678, v679)
                if v679 == nil then
                    break
                end
                if v680.Role == "Sheriff" then
                    return vu13:FindFirstChild(v679)
                end
            end
        end
        return nil
    end
    function getESP(p682)
        if p682.Character then
            local v683 = p682.Character:FindFirstChild("PlayerESP")
            if not v683 then
                v683 = Instance.new("Highlight")
                v683.Name = "PlayerESP"
                v683.DepthMode = Enum.HighlightDepthMode.AlwaysOnTop
                v683.FillTransparency = 0.5
                v683.Adornee = p682.Character
                v683.Parent = p682.Character
            end
            return v683
        end
    end
    function clearESP()
        local v684 = vu13
        local v685, v686, v687 = ipairs(v684:GetPlayers())
        while true do
            local v688
            v687, v688 = v685(v686, v687)
            if v687 == nil then
                break
            end
            if v688.Character and v688.Character:FindFirstChild("PlayerESP") then
                v688.Character.PlayerESP:Destroy()
            end
        end
    end
    function updateESP()
        if AnyESPEnabled() then
            local v689 = vu671()
            local v690 = vu681()
            local v691 = vu13
            local v692, v693, v694 = ipairs(v691:GetPlayers())
            while true do
                local v695
                v694, v695 = v692(v693, v694)
                if v694 == nil then
                    break
                end
                if v695 ~= vu14 and v695.Character then
                    local v696 = getESP(v695)
                    if v696 then
                        local v697 = nil
                        local v698 = false
                        if vu661.HighlightMurderer and v695 == v689 then
                            v697 = Color3.fromRGB(255, 0, 0)
                            v698 = true
                        elseif vu661.HighlightSheriff and v695 == v690 then
                            v697 = Color3.fromRGB(0, 0, 255)
                            v698 = true
                        elseif vu661.HighlightInnocent and (v695 ~= v689 and v695 ~= v690) then
                            v697 = Color3.fromRGB(0, 255, 0)
                            v698 = true
                        end
                        v696.Enabled = v698
                        if v698 then
                            v696.FillColor = v697
                            v696.OutlineColor = v697
                        end
                    end
                end
            end
        else
            clearESP()
        end
    end
    local v699 = vu659
    vu659.WaitForChild(v699, "Remotes"):WaitForChild("Gameplay"):WaitForChild("PlayerDataChanged", 5).OnClientEvent:Connect(function(p700)
        vu660 = p700
        updateESP()
    end)
    task.spawn(function()
        while true do
            repeat
                task.wait(1.7)
            until AnyESPEnabled()
            updateESP()
        end
    end)
    vu34.esp:Toggle({
        Title = "loc:murdesp",
        Value = false,
        Callback = function(p701)
            vu661.HighlightMurderer = p701
            if AnyESPEnabled() then
                updateESP()
            else
                clearESP()
            end
        end
    })
    vu34.esp:Toggle({
        Title = "loc:sheresp",
        Value = false,
        Callback = function(p702)
            vu661.HighlightSheriff = p702
            if AnyESPEnabled() then
                updateESP()
            else
                clearESP()
            end
        end
    })
    vu34.esp:Toggle({
        Title = "loc:innoesp",
        Value = false,
        Callback = function(p703)
            vu661.HighlightInnocent = p703
            if AnyESPEnabled() then
                updateESP()
            else
                clearESP()
            end
        end
    })
    vu34.visual:Section({
        Title = "Visual"
    })
    ChangeXray = false
    XrayTransparency = 0.9
    function XrayFunction()
        local function vu710(p704, p705)
            local v706, v707, v708 = pairs(p704:GetChildren())
            while true do
                local v709
                v708, v709 = v706(v707, v708)
                if v708 == nil then
                    break
                end
                if v709:IsA("BasePart") and not (v709.Parent:FindFirstChild("Humanoid") or v709.Parent.Parent:FindFirstChild("Humanoid")) then
                    v709.LocalTransparencyModifier = p705
                end
                vu710(v709, p705)
            end
        end;
        (function(p711)
            if p711 then
                if ChangeXray then
                    vu710(vu12, XrayTransparency)
                else
                    vu710(vu12, 0)
                end
            else
                vu710(vu12, 0)
            end
        end)(true)
    end
    vu34.visual:Toggle({
        Title = "loc:xray",
        Value = false,
        Callback = function(p712)
            ChangeXray = p712
            XrayFunction()
        end
    })
    vu34.visual:Slider({
        Title = "loc:xraytrans",
        Value = {
            Min = 0,
            Max = 10,
            Default = 9
        },
        Callback = function(p713)
            XrayTransparency = p713 * 0.1
            if ChangeXray then
                XrayFunction()
            end
        end
    })
    vu34.visual:Section({
        Title = "Improve fps"
    })
    getgenv().antiLag = false
    getgenv().removeRaggy = false
    getgenv().destroyCoins = false
    local vu714 = {
        coinConnections = {},
        coinContainerConnection = nil,
        getCoinContainer = function()
            return vu15:FindFirstChild("CoinContainer", true)
        end
    }
    local vu715 = nil
    function vu714.attachCoinListener(pu716)
        if not vu714.coinConnections[pu716] then
            vu715 = pu716.Touched:Connect(function(p717)
                if getgenv().destroyCoins then
                    local v718 = p717.Parent
                    if v718 and vu13:GetPlayerFromCharacter(v718) then
                        if vu715.Connected then
                            vu715:Disconnect()
                        end
                        vu714.coinConnections[pu716] = nil
                        task.wait(0.1)
                        if pu716 and pu716.Parent then
                            pu716:Destroy()
                        end
                    end
                end
            end)
            vu714.coinConnections[pu716] = vu715
        end
    end
    function vu714.detachAllCoinListeners()
        local v719, v720, v721 = pairs(vu714.coinConnections)
        while true do
            local v722
            v721, v722 = v719(v720, v721)
            if v721 == nil then
                break
            end
            if v722.Connected then
                v722:Disconnect()
            end
        end
        vu714.coinConnections = {}
        if vu714.coinContainerConnection then
            vu714.coinContainerConnection:Disconnect()
            vu714.coinContainerConnection = nil
        end
    end
    function vu714.monitorCoins()
        local v723 = vu714.getCoinContainer()
        if v723 then
            local v724, v725, v726 = ipairs(v723:GetChildren())
            while true do
                local v727
                v726, v727 = v724(v725, v726)
                if v726 == nil then
                    break
                end
                if v727.Name == "Coin_Server" and v727:IsA("BasePart") then
                    vu714.attachCoinListener(v727)
                end
            end
            vu714.coinContainerConnection = v723.ChildAdded:Connect(function(p728)
                if p728.Name == "Coin_Server" and p728:IsA("BasePart") then
                    vu714.attachCoinListener(p728)
                end
            end)
        end
    end
    function vu714.destroyTargetModels()
        local v729 = vu15
        local v730, v731, v732 = ipairs(v729:GetDescendants())
        while true do
            local v733
            v732, v733 = v730(v731, v732)
            if v732 == nil then
                break
            end
            if v733:IsA("Model") and table.find({
                "Raggy",
                "GlitchProof"
            }, v733.Name) then
                v733:Destroy()
            end
        end
    end
    function vu714.clearLag()
        local v734 = vu15
        local v735, v736, v737 = ipairs(v734:GetChildren())
        while true do
            local v738
            v737, v738 = v735(v736, v737)
            if v737 == nil then
                break
            end
            if v738:IsA("Folder") and table.find({
                "Footsteps",
                "WeaponDisplays"
            }, v738.Name) then
                v738:Destroy()
            end
        end
        local v739 = vu13
        local v740, v741, v742 = ipairs(v739:GetPlayers())
        while true do
            local v743
            v742, v743 = v740(v741, v742)
            if v742 == nil then
                break
            end
            local v744 = v743.Character
            if v744 then
                local v745, v746, v747 = ipairs({
                    "KnifeDisplay",
                    "GunDisplay",
                    "Pet"
                })
                while true do
                    local v748
                    v747, v748 = v745(v746, v747)
                    if v747 == nil then
                        break
                    end
                    local v749 = v744:FindFirstChild(v748)
                    if v749 then
                        v749:Destroy()
                    end
                end
                local v750, v751, v752 = ipairs(v744:GetChildren())
                while true do
                    local v753
                    v752, v753 = v750(v751, v752)
                    if v752 == nil then
                        break
                    end
                    if v753:IsA("Tool") then
                        local v754 = v753:FindFirstChild("Handle")
                        if v754 then
                            v754 = v753.Handle:FindFirstChild("Chroma")
                        end
                        if v754 then
                            v754:Destroy()
                        end
                    end
                end
            end
        end
        local v755 = vu15
        local v756, v757, v758 = ipairs(v755:GetChildren())
        while true do
            local v759
            v758, v759 = v756(v757, v758)
            if v758 == nil then
                break
            end
            if v759:IsA("Model") or v759:IsA("Part") then
                local v760 = v759:FindFirstChild("Handle")
                if v760 then
                    v760 = v759.Handle:FindFirstChild("Chroma")
                end
                if v760 then
                    v760:Destroy()
                end
            end
        end
    end
    vu15.ChildAdded:Connect(function(p761)
        if getgenv().antiLag then
            if p761:IsA("Folder") and table.find({
                "Footsteps",
                "WeaponDisplays"
            }, p761.Name) then
                p761:Destroy()
            elseif p761:IsA("Model") or p761:IsA("Part") then
                local v762 = p761:FindFirstChild("Handle")
                if v762 then
                    v762 = p761.Handle:FindFirstChild("Chroma")
                end
                if v762 then
                    v762:Destroy()
                end
            end
        end
        if getgenv().removeRaggy then
            vu714.destroyTargetModels()
        end
    end)
    vu13.PlayerAdded:Connect(function(p763)
        p763.CharacterAdded:Connect(function(_)
            if getgenv().antiLag then
                vu714.clearLag()
            end
        end)
    end)
    vu34.visual:Toggle({
        Title = "loc:optimization",
        Value = false,
        Callback = function(p764)
            getgenv().antiLag = p764
            if getgenv().antiLag then
                vu714.clearLag()
            end
        end
    })
    vu34.visual:Toggle({
        Title = "loc:removedeadbody",
        Value = false,
        Callback = function(p765)
            getgenv().removeRaggy = p765
            if p765 then
                vu714.destroyTargetModels()
            end
        end
    })
    vu34.visual:Toggle({
        Title = "loc:removecoins",
        Value = false,
        Callback = function(p766)
            getgenv().destroyCoins = p766
            if p766 then
                vu714.monitorCoins()
            else
                vu714.detachAllCoinListeners()
            end
        end
    })
    vu34.visual:Toggle({
        Title = "loc:removeshadow",
        Value = false,
        Callback = function(p767)
            game.Lighting.GlobalShadows = not p767
        end
    })
    vu34.visual:Toggle({
        Title = "loc:removeplayersaccesory",
        Value = false,
        Callback = function(p768)
            if p768 then
                local v769, v770, v771 = pairs(game:GetService("Players"):GetPlayers())
                while true do
                    local v772
                    v771, v772 = v769(v770, v771)
                    if v771 == nil then
                        break
                    end
                    if v772 ~= game:GetService("Players").LocalPlayer and v772.Character then
                        local v773, v774, v775 = pairs(v772.Character:GetChildren())
                        while true do
                            local v776
                            v775, v776 = v773(v774, v775)
                            if v775 == nil then
                                break
                            end
                            if v776:IsA("Accessory") then
                                v776:Destroy()
                            end
                        end
                    end
                end
            end
        end
    })
    local vu777 = game:GetService("Lighting")
    local vu778 = {}
    vu34.visual:Toggle({
        Title = "loc:lesslagoptim",
        Value = false,
        Callback = function(p779)
            if p779 then
                vu777.GlobalShadows = false
                vu777.FogEnd = 9000000000
                local v780 = vu12
                local v781, v782, v783 = pairs(v780:GetDescendants())
                while true do
                    local v784
                    v783, v784 = v781(v782, v783)
                    if v783 == nil then
                        break
                    end
                    if v784:IsA("ParticleEmitter") or v784:IsA("Trail") then
                        vu778[v784] = v784.Enabled
                        v784.Enabled = false
                    end
                end
            else
                vu777.GlobalShadows = true
                vu777.FogEnd = 100000
                local v785, v786, v787 = pairs(vu778)
                while true do
                    local v788
                    v787, v788 = v785(v786, v787)
                    if v787 == nil then
                        break
                    end
                    if v787 and v787.Parent then
                        v787.Enabled = v788
                    end
                end
                vu778 = {}
            end
        end
    })
    local vu789 = {
        Textures = false,
        VisualEffects = true,
        Parts = true,
        Particles = true,
        Sky = true
    }
    local vu790 = {
        FullBright = true
    }
    local vu791 = {}
    local function vu794(p792, p793)
        if not vu791[p792] then
            vu791[p792] = p793
        end
    end
    vu34.visual:Toggle({
        Title = "loc:lowercpuload",
        Value = false,
        Callback = function(p795)
            if p795 then
                local v796 = next
                local v797, v798 = game:GetDescendants()
                while true do
                    local v799
                    v798, v799 = v796(v797, v798)
                    if v798 == nil then
                        break
                    end
                    if vu789.Parts and v799:IsA("BasePart") then
                        vu794(v799, {
                            Material = v799.Material
                        })
                        v799.Material = Enum.Material.SmoothPlastic
                    end
                    if vu789.Particles and (v799:IsA("ParticleEmitter") or (v799:IsA("Smoke") or (v799:IsA("Explosion") or (v799:IsA("Sparkles") or v799:IsA("Fire"))))) then
                        vu794(v799, {
                            Enabled = v799.Enabled
                        })
                        v799.Enabled = false
                    end
                    if vu789.VisualEffects and (v799:IsA("BloomEffect") or (v799:IsA("BlurEffect") or (v799:IsA("DepthOfFieldEffect") or v799:IsA("SunRaysEffect")))) then
                        vu794(v799, {
                            Enabled = v799.Enabled
                        })
                        v799.Enabled = false
                    end
                    if vu789.Textures and (v799:IsA("Decal") or v799:IsA("Texture")) then
                        vu794(v799, {
                            Texture = v799.Texture
                        })
                        v799.Texture = ""
                    end
                    if vu789.Sky and v799:IsA("Sky") then
                        vu794(v799, {
                            Parent = v799.Parent
                        })
                        v799.Parent = nil
                    end
                end
                if vu790.FullBright then
                    vu794(game.Lighting, {
                        Brightness = game.Lighting.Brightness,
                        OutdoorAmbient = game.Lighting.OutdoorAmbient
                    })
                    game.Lighting.Brightness = - 1
                    game.Lighting.OutdoorAmbient = Color3.fromRGB(255, 255, 255)
                end
            else
                local v800, v801, v802 = pairs(vu791)
                while true do
                    local v803
                    v802, v803 = v800(v801, v802)
                    if v802 == nil then
                        break
                    end
                    if v802 and v802.Parent ~= nil or v803.Parent then
                        local v804, v805, v806 = pairs(v803)
                        local v807 = v802
                        while true do
                            local v808
                            v806, v808 = v804(v805, v806)
                            if v806 == nil then
                                break
                            end
                            v807[v806] = v808
                        end
                    end
                end
                vu791 = {}
            end
        end
    })
    local vu809 = game:GetService("Lighting")
    local vu810 = {
        Default = {
            Bk = "",
            Dn = "",
            Ft = "",
            Lf = "",
            Rt = "",
            Up = ""
        },
        ["Default MM2 Summer"] = {
            Bk = "http://www.roblox.com/asset/?version=1&id=135483466",
            Dn = "http://www.roblox.com/asset/?version=1&id=135483484",
            Ft = "http://www.roblox.com/asset/?version=1&id=135483461",
            Lf = "http://www.roblox.com/asset/?version=1&id=135483495",
            Rt = "http://www.roblox.com/asset/?version=1&id=135483499",
            Up = "http://www.roblox.com/asset/?version=1&id=135483475"
        },
        Sunset = {
            Bk = "rbxassetid://600830446",
            Dn = "rbxassetid://600831635",
            Ft = "rbxassetid://600832720",
            Lf = "rbxassetid://600886090",
            Rt = "rbxassetid://600833862",
            Up = "rbxassetid://600835177"
        },
        Arctic = {
            Bk = "rbxassetid://225469390",
            Dn = "rbxassetid://225469395",
            Ft = "rbxassetid://225469403",
            Lf = "rbxassetid://225469450",
            Rt = "rbxassetid://225469471",
            Up = "rbxassetid://225469481"
        },
        Space = {
            Bk = "rbxassetid://166509999",
            Dn = "rbxassetid://166510057",
            Ft = "rbxassetid://166510116",
            Lf = "rbxassetid://166510092",
            Rt = "rbxassetid://166510131",
            Up = "rbxassetid://166510114"
        },
        ["Pink Skies"] = {
            Bk = "rbxassetid://151165214",
            Dn = "rbxassetid://151165197",
            Ft = "rbxassetid://151165224",
            Lf = "rbxassetid://151165191",
            Rt = "rbxassetid://151165206",
            Up = "rbxassetid://151165227"
        },
        ["Blue Night"] = {
            Bk = "rbxassetid://12064107",
            Dn = "rbxassetid://12064152",
            Ft = "rbxassetid://12064121",
            Lf = "rbxassetid://12063984",
            Rt = "rbxassetid://12064115",
            Up = "rbxassetid://12064131"
        },
        ["Red Night"] = {
            Bk = "rbxassetid://401664839",
            Dn = "rbxassetid://401664862",
            Ft = "rbxassetid://401664960",
            Lf = "rbxassetid://401664881",
            Rt = "rbxassetid://401664901",
            Up = "rbxassetid://401664936"
        },
        ["Purple Sunset"] = {
            Bk = "rbxassetid://264908339",
            Dn = "rbxassetid://264907909",
            Ft = "rbxassetid://264909420",
            Lf = "rbxassetid://264909758",
            Rt = "rbxassetid://264908886",
            Up = "rbxassetid://264907379"
        },
        ["Blossom Daylight"] = {
            Bk = "rbxassetid://271042516",
            Dn = "rbxassetid://271077243",
            Ft = "rbxassetid://271042556",
            Lf = "rbxassetid://271042310",
            Rt = "rbxassetid://271042467",
            Up = "rbxassetid://271077958"
        },
        ["Blue Nebula"] = {
            Bk = "rbxassetid://135207744",
            Dn = "rbxassetid://135207662",
            Ft = "rbxassetid://135207770",
            Lf = "rbxassetid://135207615",
            Rt = "rbxassetid://135207695",
            Up = "rbxassetid://135207794"
        },
        ["Blue Planet"] = {
            Bk = "rbxassetid://218955819",
            Dn = "rbxassetid://218953419",
            Ft = "rbxassetid://218954524",
            Lf = "rbxassetid://218958493",
            Rt = "rbxassetid://218957134",
            Up = "rbxassetid://218950090"
        },
        ["Deep Space"] = {
            Bk = "rbxassetid://159248188",
            Dn = "rbxassetid://159248183",
            Ft = "rbxassetid://159248187",
            Lf = "rbxassetid://159248173",
            Rt = "rbxassetid://159248192",
            Up = "rbxassetid://159248176"
        }
    }
    function ApplySkybox(p811)
        if vu809:FindFirstChildOfClass("Sky") then
            vu809:FindFirstChildOfClass("Sky"):Destroy()
        end
        if p811 ~= "Default" then
            local v812 = Instance.new("Sky")
            v812.Parent = vu809
            local v813, v814, v815 = pairs(vu810[p811])
            while true do
                local v816
                v815, v816 = v813(v814, v815)
                if v815 == nil then
                    break
                end
                v812["Skybox" .. v815] = v816
            end
        end
    end
    vu34.visual:Dropdown({
        Title = "loc:skyboxselector",
        Values = {
            "Default",
            "Default MM2 Summer",
            "Sunset",
            "Arctic",
            "Space",
            "Pink Skies",
            "Blue Night",
            "Red Night",
            "Purple Sunset",
            "Blossom Daylight",
            "Blue Nebula",
            "Blue Planet",
            "Deep Space"
        },
        Value = "Default",
        Callback = function(p817)
            ApplySkybox(p817)
        end
    })
    vu34.visual:Section({
        Title = "Hitbox Expander"
    })
    getgenv().Hitboxexpander = false
    getgenv().HitboxSettings = {
        Size = Vector3.new(10, 10, 10),
        Color = Color3.fromRGB(169, 169, 169),
        Material = Enum.Material.Plastic,
        Collision = false,
        Transparency = 7
    }
    getgenv().GetCharacterParent = function(p818)
        repeat
            wait()
        until p818.Character
        return p818.Character
    end
    getgenv().ApplyBoxProperties = function(p819)
        local v820 = getgenv().GetCharacterParent(p819)
        if v820 then
            local v821 = v820:FindFirstChild("HumanoidRootPart")
            if v821 then
                if getgenv().Hitboxexpander then
                    v821.Size = getgenv().HitboxSettings.Size
                    v821.Color = getgenv().HitboxSettings.Color
                    v821.Material = getgenv().HitboxSettings.Material
                    v821.CanCollide = false
                    v821.Transparency = getgenv().HitboxSettings.Transparency * 0.1
                else
                    v821.Size = Vector3.new(2, 2, 1)
                    v821.Color = Color3.fromRGB(255, 255, 255)
                    v821.Material = Enum.Material.SmoothPlastic
                    v821.CanCollide = false
                    v821.Transparency = 1
                end
            end
        else
            return
        end
    end
    getgenv().StartUpdatingHitboxes = function()
        getgenv().playerAddedConnection = vu13.PlayerAdded:Connect(function(p822)
            if p822 ~= vu14 then
                getgenv().ApplyBoxProperties(p822)
            end
        end)
        getgenv().heartbeatConnection = vu10.Heartbeat:Connect(function()
            if getgenv().Hitboxexpander then
                local v823 = vu13
                local v824, v825, v826 = ipairs(v823:GetPlayers())
                while true do
                    local v827
                    v826, v827 = v824(v825, v826)
                    if v826 == nil then
                        break
                    end
                    if v827 ~= vu14 then
                        getgenv().ApplyBoxProperties(v827)
                    end
                end
            end
        end)
    end
    getgenv().StopUpdatingHitboxes = function()
        if getgenv().playerAddedConnection then
            getgenv().playerAddedConnection:Disconnect()
            getgenv().playerAddedConnection = nil
        end
        if getgenv().heartbeatConnection then
            getgenv().heartbeatConnection:Disconnect()
            getgenv().heartbeatConnection = nil
        end
    end
    vu34.visual:Toggle({
        Title = "loc:hitboxexpander",
        Value = false,
        Callback = function(p828)
            getgenv().Hitboxexpander = p828
            if getgenv().Hitboxexpander then
                getgenv().StartUpdatingHitboxes()
                local v829 = vu13
                local v830, v831, v832 = ipairs(v829:GetPlayers())
                while true do
                    local v833
                    v832, v833 = v830(v831, v832)
                    if v832 == nil then
                        break
                    end
                    if v833 ~= vu14 then
                        getgenv().ApplyBoxProperties(v833)
                    end
                end
            else
                getgenv().StopUpdatingHitboxes()
            end
        end
    })
    vu34.visual:Slider({
        Title = "loc:hitboxsize",
        Value = {
            Min = 5,
            Max = 100,
            Default = false
        },
        Callback = function(p834)
            getgenv().HitboxSettings.Size = Vector3.new(p834, p834, p834)
        end
    })
    vu34.visual:Slider({
        Title = "loc:hitboxtrans",
        Value = {
            Min = 1,
            Max = 10,
            Default = 5
        },
        Callback = function(p835)
            getgenv().HitboxSettings.Transparency = p835
        end
    })
    vu34.visual:Colorpicker({
        Title = "loc:hitboxcolor",
        Default = Color3.fromRGB(169, 169, 169),
        Transparency = 0,
        Locked = false,
        Callback = function(p836)
            getgenv().HitboxSettings.Color = p836
        end
    })
    vu34.emotes:Section({
        Title = "Emotes"
    })
    vu34.emotes:Button({
        Title = "loc:ninja",
        Callback = function()
            vu599.Remotes.Misc.PlayEmote:Fire("ninja")
        end
    })
    vu34.emotes:Button({
        Title = "loc:sit",
        Callback = function()
            vu599.Remotes.Misc.PlayEmote:Fire("sit")
        end
    })
    vu34.emotes:Button({
        Title = "loc:headless",
        Callback = function()
            vu599.Remotes.Misc.PlayEmote:Fire("headless")
        end
    })
    vu34.emotes:Button({
        Title = "loc:dab",
        Callback = function()
            vu599.Remotes.Misc.PlayEmote:Fire("dab")
        end
    })
    vu34.emotes:Button({
        Title = "loc:zen",
        Callback = function()
            vu599.Remotes.Misc.PlayEmote:Fire("zen")
        end
    })
    vu34.emotes:Button({
        Title = "loc:floss",
        Callback = function()
            vu599.Remotes.Misc.PlayEmote:Fire("floss")
        end
    })
    vu34.emotes:Button({
        Title = "loc:zombie",
        Callback = function()
            vu599.Remotes.Misc.PlayEmote:Fire("zombie")
        end
    })
    vu34.emotes:Button({
        Title = "loc:wave",
        Callback = function()
            vu599.Remotes.Misc.PlayEmote:Fire("wave")
        end
    })
    vu34.emotes:Button({
        Title = "loc:cheer",
        Callback = function()
            vu599.Remotes.Misc.PlayEmote:Fire("cheer")
        end
    })
    vu34.emotes:Button({
        Title = "loc:laugh",
        Callback = function()
            vu599.Remotes.Misc.PlayEmote:Fire("laugh")
        end
    })
    vu34.other:Section({
        Title = "Fun"
    })
    game:GetService("ReplicatedStorage").Remotes.Gameplay.RoleSelect.OnClientEvent:Connect(function(p837)
        if getgenv().nb then
            local v838 = game:GetService("ReplicatedStorage"):WaitForChild("Remotes"):WaitForChild("Extras"):WaitForChild("GetChance"):InvokeServer()
            if p837 == "Innocent" then
                sel = gradient(p837, Color3.fromRGB(0, 255, 0), Color3.fromRGB(0, 255, 0))
            elseif p837 == "Murderer" then
                sel = gradient(p837, Color3.fromRGB(255, 0, 0), Color3.fromRGB(255, 0, 0))
            elseif p837 == "Sheriff" then
                sel = gradient(p837, Color3.fromRGB(0, 0, 255), Color3.fromRGB(0, 0, 255))
            end
            sendnotification("Role: " .. sel .. " and chance for murderer: " .. v838)
            sel = nil
        end
    end)
    vu34.other:Toggle({
        Title = "loc:showrole",
        Value = false,
        Callback = function(p839)
            getgenv().nb = p839
        end
    })
    local vu840 = false
    local vu841 = nil
    local vu842 = nil
    local function vu844()
        if vu842 then
            vu842:Destroy()
        end
        vu842 = Instance.new("ScreenGui")
        vu842.Name = "TimerGui"
        vu842.Parent = vu9
        local v843 = Instance.new("TextLabel")
        v843.Name = "TimerText"
        v843.BackgroundTransparency = 1
        v843.TextColor3 = Color3.new(1, 1, 1)
        v843.TextStrokeColor3 = Color3.new(0, 0, 0)
        v843.TextStrokeTransparency = 0.5
        v843.TextScaled = true
        v843.AnchorPoint = Vector2.new(0.5, 0.5)
        v843.Position = UDim2.new(0.5, 0, 0.1, 0)
        v843.Size = UDim2.new(0, 200, 0, 50)
        v843.Font = Enum.Font.GothamBold
        v843.Text = "0:00"
        v843.Parent = vu842
        return v843
    end
    local function vu850(p845)
        while vu840 do
            local v846, v847 = pcall(function()
                return vu659.Remotes.Extras.GetTimer:InvokeServer()
            end)
            if v846 and v847 > 0 then
                local v848 = math.floor(v847 / 60)
                local v849 = v847 - v848 * 60
                p845.Text = v848 .. ":" .. (v849 < 10 and "0" .. v849 or tostring(v849))
                p845.TextColor3 = v847 <= 10 and Color3.new(139, 0, 255) or Color3.new(1, 1, 1)
            else
                p845.Text = "0:00"
                for _ = 1, 3 do
                    if not vu840 then
                        return
                    end
                    p845.TextColor3 = Color3.new(1, 0, 0)
                    task.wait(0.5)
                    if not vu840 then
                        return
                    end
                    p845.TextColor3 = Color3.new(1, 1, 1)
                    task.wait(0.5)
                end
                repeat
                    task.wait(1)
                until not vu840 or vu659.Remotes.Extras.GetTimer:InvokeServer() > 0
            end
            task.wait(0.9)
        end
    end
    vu34.other:Toggle({
        Title = "loc:showtimer",
        Value = false,
        Callback = function(p851)
            vu840 = p851
            if vu840 then
                local vu852 = vu844()
                vu841 = task.spawn(function()
                    vu850(vu852)
                end)
            elseif vu841 then
                vu840 = false
                vu841 = nil
                if vu842 then
                    vu842:Destroy()
                    vu842 = nil
                end
            end
        end
    })
    vu34.other:Button({
        Title = "loc:trapgun",
        Callback = function()
            if GetMurder() ~= vu14 or not vu16 then
                sendnotification("u not murder")
                return
            else
                local v853 = vu12
                local v854, v855, v856 = pairs(v853:GetChildren())
                local _ = nil
                repeat
                    local v857
                    v856, v857 = v854(v855, v856)
                    local v858 = v856 == nil or v857:FindFirstChild("GunDrop")
                until v858
                if v858 then
                    local v859 = {
                        CFrame.new(v858.Position.X, v858.Position.Y, v858.Position.Z, 0.7621428370475769, - 6.621179160504198e-9, 0.6474089026451111, 2.9349132013578583e-9, 1, 6.772159277801393e-9, - 0.6474089026451111, - 3.261263925580238e-9, 0.7621428370475769)
                    }
                    game:GetService("Players").LocalPlayer.Character.Trap.Activate:FireServer(unpack(v859))
                else
                    sendnotification("Gundrop not found")
                end
            end
        end
    })
    getgenv().MuteRadiosEnabled = false
    vu34.other:Toggle({
        Title = "loc:muteradio",
        Value = false,
        Callback = function(p860)
            getgenv().MuteRadiosEnabled = p860
            local v861 = vu13
            local v862, v863, v864 = pairs(v861:GetPlayers())
            while true do
                local v865
                v864, v865 = v862(v863, v864)
                if v864 == nil then
                    break
                end
                if v865 ~= vu14 then
                    local v866 = v865.Character and v865.Character:FindFirstChild("Radio")
                    if v866 then
                        v866 = v865.Character.Radio:FindFirstChildOfClass("Sound")
                    end
                    if v866 then
                        v866.Volume = p860 and 0 or 0.5
                    end
                end
            end
        end
    })
    vu34.other:Section({
        Title = "Protection"
    })
    vu34.other:Toggle({
        Title = "loc:antitrap",
        Value = false,
        Callback = function(p867)
            antitraploop = p867
            while antitraploop do
                function antitraploopfix()
                    if vu14.Character:WaitForChild("Humanoid").WalkSpeed == 0.009999999776482582 then
                        vu14.Character:WaitForChild("Humanoid").WalkSpeed = 16
                    end
                    wait()
                end
                wait()
                pcall(antitraploopfix)
            end
        end
    })
    getgenv()._afConnection = getgenv()._afConnection or nil
    local vu878 = vu34.other:Toggle({
        Title = "loc:antifling",
        Value = false,
        Callback = function(p868)
            if p868 then
                if getgenv()._afConnection then
                    getgenv()._afConnection:Disconnect()
                end
                getgenv()._afConnection = vu10.RenderStepped:Connect(function()
                    local v869 = vu13
                    local v870, v871, v872 = ipairs(v869:GetPlayers())
                    while true do
                        local v873
                        v872, v873 = v870(v871, v872)
                        if v872 == nil then
                            break
                        end
                        if v873 ~= vu595 and v873.Character then
                            local v874, v875, v876 = ipairs(v873.Character:GetChildren())
                            while true do
                                local v877
                                v876, v877 = v874(v875, v876)
                                if v876 == nil then
                                    break
                                end
                                if v877:IsA("BasePart") and v877.CanCollide then
                                    v877.CanCollide = false
                                end
                            end
                        end
                    end
                end)
            elseif getgenv()._afConnection then
                getgenv()._afConnection:Disconnect()
                getgenv()._afConnection = nil
            end
        end
    })
    getgenv().connection = nil
    vu34.other:Toggle({
        Title = "loc:antiafk",
        Value = false,
        Callback = function(p879)
            if p879 then
                local vu880 = game:GetService("VirtualUser")
                getgenv().connection = game:GetService("Players").LocalPlayer.Idled:Connect(function()
                    vu880:CaptureController()
                    vu880:ClickButton2(Vector2.new())
                end)
            elseif getgenv().connection then
                getgenv().connection:Disconnect()
                getgenv().connection = nil
            end
        end
    }):Set(true)
    vu34.other:Section({
        Title = "Spectator"
    })
    local vu881 = ""
    local vu882 = nil
    local vu883 = nil
    vu34.other:Input({
        Title = "loc:inputview",
        Type = "Input",
        Placeholder = "...",
        Callback = function(p884)
            vu881 = p884:lower()
        end
    })
    function findTargetforView()
        local v885 = vu13
        local v886, v887, v888 = pairs(v885:GetPlayers())
        while true do
            local v889
            v888, v889 = v886(v887, v888)
            if v888 == nil then
                break
            end
            if (string.find(v889.Name:lower(), vu881) or string.find(v889.DisplayName:lower(), vu881)) and v889 ~= vu14 then
                return v889
            end
        end
        return nil
    end
    function startView(pu890)
        if vu883 then
            vu882 = nil
            vu883 = nil
        end
        if pu890 and pu890.Character and pu890.Character:FindFirstChild("Humanoid") then
            vu882 = pu890
            vu883 = spawn(function()
                while vu882 == pu890 do
                    if not (pu890.Parent and pu890.Character and pu890.Character:FindFirstChild("Humanoid")) then
                        game.Workspace.CurrentCamera.CameraSubject = vu14.Character:WaitForChild("Humanoid")
                        vu882 = nil
                        break
                    end
                    game.Workspace.CurrentCamera.CameraSubject = pu890.Character.Humanoid
                    wait(0.3)
                end
            end)
        else
            sendnotification("Target Not Found!")
            game.Workspace.CurrentCamera.CameraSubject = vu14.Character:WaitForChild("Humanoid")
            vu882 = nil
        end
    end
    function viewGunDrop(pu891)
        vu882 = pu891
        vu883 = spawn(function()
            while vu882 == pu891 do
                if not (pu891 and pu891.Parent) then
                    game.Workspace.CurrentCamera.CameraSubject = vu14.Character:WaitForChild("Humanoid")
                    vu882 = nil
                    break
                end
                game.Workspace.CurrentCamera.CameraSubject = pu891
                wait(0.3)
            end
        end)
    end
    vu34.other:Button({
        Title = "loc:viewplayer",
        Locked = false,
        Callback = function()
            local v892 = findTargetforView()
            startView(v892)
        end
    })
    vu34.other:Button({
        Title = "loc:viewmurder",
        Locked = false,
        Callback = function()
            local v893 = GetMurder()
            startView(v893)
        end
    })
    vu34.other:Button({
        Title = "loc:viewsheriff",
        Locked = false,
        Callback = function()
            local v894 = GetSheriff()
            startView(v894)
        end
    })
    getgenv().gundropcon = nil
    vu34.other:Button({
        Title = "loc:viewgundrop",
        Locked = false,
        Callback = function()
            if getgenv().gundropcon then
                getgenv().gundropcon:Disconnect()
            end
            getgenv().gundropcon = vu12.DescendantAdded:Connect(function(p895)
                if p895.Name == "GunDrop" and p895:IsA("BasePart") then
                    viewGunDrop(p895)
                end
            end)
            local v896 = vu12:FindFirstChild("GunDrop", true)
            if v896 then
                viewGunDrop(v896)
            else
                sendnotification("Target not found")
            end
        end
    })
    vu34.other:Button({
        Title = "loc:stopview",
        Locked = false,
        Callback = function()
            vu882 = nil
            vu883 = nil
            pcall(function()
                if getgenv().gundropcon then
                    getgenv().gundropcon:Disconnect()
                end
                game.Workspace.CurrentCamera.CameraSubject = vu14.Character:WaitForChild("Humanoid")
            end)
        end
    })
    vu34.other:Section({
        Title = "Notify"
    })
    local vu897 = false
    local vu898 = false
    local vu899 = nil
    local function vu906()
        local v900 = vu12
        local v901, v902, v903 = ipairs(v900:GetChildren())
        local v904 = false
        while true do
            local v905
            v903, v905 = v901(v902, v903)
            if v903 == nil then
                break
            end
            if v905:IsA("Model") and v905:FindFirstChild("GunDrop") then
                v904 = true
                break
            end
        end
        if v904 then
            if not vu897 then
                sendnotification("Gun has Dropped")
                vu897 = true
            end
        elseif vu897 then
            sendnotification("Gun has been picked up")
            vu897 = false
        end
    end
    local function vu907()
        if not vu898 then
            vu899 = vu10.Stepped:Connect(vu906)
            vu898 = true
            print("Monitoring started")
        end
    end
    local function vu908()
        if vu898 then
            vu899:Disconnect()
            vu898 = false
            print("Monitoring stopped")
        end
    end
    vu34.other:Toggle({
        Title = "loc:gundropnotify",
        Value = false,
        Callback = function(p909)
            if p909 then
                vu907()
            else
                vu908()
            end
        end
    })
    function findMurderer()
        local v910, v911, v912 = ipairs(game.Players:GetPlayers())
        while true do
            local v913
            v912, v913 = v910(v911, v912)
            if v912 == nil then
                break
            end
            if v913.Backpack:FindFirstChild("Knife") then
                return v913
            end
        end
        local v914, v915, v916 = ipairs(game.Players:GetPlayers())
        while true do
            local v917
            v916, v917 = v914(v915, v916)
            if v916 == nil then
                break
            end
            if v917.Character and v917.Character:FindFirstChild("Knife") then
                return v917
            end
        end
        if vu660 then
            local v918 = vu660
            local v919 = nil
            local v920 = nil
            while true do
                local v921
                v920, v921 = v918(v919, v920)
                if v920 == nil then
                    break
                end
                if v921.Role == "Murderer" and game.Players:FindFirstChild(v920) then
                    return game.Players:FindFirstChild(v920)
                end
            end
        end
        return nil
    end
    function findSheriff()
        local v922, v923, v924 = ipairs(game.Players:GetPlayers())
        while true do
            local v925
            v924, v925 = v922(v923, v924)
            if v924 == nil then
                break
            end
            if v925.Backpack:FindFirstChild("Gun") then
                return v925
            end
        end
        local v926, v927, v928 = ipairs(game.Players:GetPlayers())
        while true do
            local v929
            v928, v929 = v926(v927, v928)
            if v928 == nil then
                break
            end
            if v929.Character and v929.Character:FindFirstChild("Gun") then
                return v929
            end
        end
        if vu660 then
            local v930 = vu660
            local v931 = nil
            local v932 = nil
            while true do
                local v933
                v932, v933 = v930(v931, v932)
                if v932 == nil then
                    break
                end
                if v933.Role == "Sheriff" and game.Players:FindFirstChild(v932) then
                    return game.Players:FindFirstChild(v932)
                end
            end
        end
        return nil
    end
    function RevealRoles()
        local v934 = game:GetService("TextChatService"):WaitForChild("TextChannels"):GetChildren()
        local v935, v936, v937 = ipairs(v934)
        while true do
            local v938
            v937, v938 = v935(v936, v937)
            if v937 == nil then
                break
            end
            if v938.Name ~= "RBXSystem" then
                local v939 = findMurderer()
                local v940 = findSheriff()
                local v941 = not v939 and "Not yet" or v939.Name
                local v942 = not v940 and "Not yet" or v940.Name
                v938:SendAsync((string.format("Murderer : %s and Sheriff : %s", v941, v942)))
            end
        end
    end
    getgenv().roles = false
    vu34.other:Toggle({
        Title = "loc:autoexposeroles",
        Value = false,
        Callback = function(p943)
            if p943 then
                RevealRoles()
            end
            getgenv().roles = p943
        end
    })
    vu34.other:Button({
        Title = "loc:exposeroles",
        Callback = function()
            RevealRoles()
        end
    })
    vu34.other:Section({
        Title = "Server"
    })
    vu34.other:Button({
        Title = "loc:devconsole",
        Callback = function()
            game.StarterGui:SetCore("DevConsoleVisible", true)
            wait()
        end
    })
    vu34.other:Button({
        Title = "loc:rejoin",
        Callback = function()
            game:GetService("TeleportService"):TeleportToPlaceInstance(game.PlaceId, game.JobId, game:GetService("Players").LocalPlayer)
        end
    })
    local vu944 = game:GetService("TeleportService")
    vu34.other:Button({
        Title = "loc:serverhop",
        Callback = function()
            vu944:Teleport(game.PlaceId)
        end
    })
    vu34.autofarm:Section({
        Title = "Autofarm"
    })
    local vu945 = game:GetService("Players").LocalPlayer
    local vu946 = game:GetService("TweenService")
    local vu947 = game:GetService("ReplicatedStorage")
    local v948 = vu947
    local v949 = vu947.WaitForChild(v948, "Remotes"):WaitForChild("Gameplay"):WaitForChild("CoinCollected")
    local v950 = vu947
    local v951 = vu947.WaitForChild(v950, "Remotes"):WaitForChild("Gameplay"):WaitForChild("RoundEndFade")
    getgenv().runnings = false
    afterfarm = false
    selector = "Afk"
    fullbag = false
    roundend = false
    startround = false
    movespeed = 20
    notinround = true
    resetmurderer = false
    local function vu956()
        if vu945.Character then
            local v952, v953, v954 = pairs(vu945.Character:GetDescendants())
            while true do
                local vu955
                v954, vu955 = v952(v953, v954)
                if v954 == nil then
                    break
                end
                if vu955:IsA("BasePart") and (vu955.CanCollide and (not floatName or vu955.Name ~= floatName)) then
                    pcall(function()
                        vu955.CanCollide = false
                    end)
                end
            end
        end
    end
    local function vu972()
        local v957 = {}
        if not (vu945.Character and vu945.Character:FindFirstChild("HumanoidRootPart")) then
            return nil
        end
        local vu958 = vu945.Character.HumanoidRootPart.Position
        local v959 = vu15
        local v960, v961, v962 = pairs(v959:GetChildren())
        while true do
            local v963
            v962, v963 = v960(v961, v962)
            if v962 == nil then
                break
            end
            if v963:IsA("Model") and v963:FindFirstChild("CoinContainer") then
                local v964, v965, v966 = pairs(v963.CoinContainer:GetChildren())
                while true do
                    local vu967
                    v966, vu967 = v964(v965, v966)
                    if v966 == nil then
                        break
                    end
                    if vu967.Name == "Coin_Server" and (not vu967:FindFirstChild("CollectedCoin") and vu967:FindFirstChild("TouchInterest")) then
                        local v968, v969 = pcall(function()
                            return (vu958 - vu967.Position).Magnitude
                        end)
                        if v968 and (v969 and v969 < 200) then
                            table.insert(v957, {
                                Coin = vu967,
                                Distance = v969
                            })
                        end
                    end
                end
            end
        end
        table.sort(v957, function(p970, p971)
            return p970.Distance < p971.Distance
        end)
        return v957[1] and v957[1].Coin or nil
    end
    v949.OnClientEvent:Connect(function(_, p973, p974)
        if p973 == p974 and getgenv().runnings then
            fullbag = true
            warn("[AutoFarm] \208\161\209\131\208\188\208\186\208\176 \208\191\208\190\208\187\208\189\208\176\209\143!")
        end
    end)
    game:GetService("ReplicatedStorage").Remotes.Gameplay.CoinsStarted.OnClientEvent:Connect(function()
        if getgenv().roles then
            RevealRoles()
        end
        if getgenv().runnings then
            startround = true
            roundend = false
            print("[autofarm] \208\156\208\190\208\189\208\181\209\130\208\186\208\184 \208\191\208\190\209\143\208\178\208\184\208\187\208\184\209\129\209\140 \208\189\208\176 \208\186\208\176\209\128\209\130\208\181")
        end
    end)
    v951.OnClientEvent:Connect(function()
        if getgenv().runnings then
            startround = false
            fullbag = false
            roundend = true
            warn("[AutoFarm] \208\160\208\176\209\131\208\189\208\180 \208\183\208\176\208\186\208\190\208\189\209\135\208\184\208\187\209\129\209\143")
        end
    end)
    function GetAfterRun()
        local v975 = vu12
        local v976, v977, v978 = ipairs(v975:GetChildren())
        while true do
            local v979
            v978, v979 = v976(v977, v978)
            if v978 == nil then
                break
            end
            local v980 = v979:FindFirstChild("CoinContainer")
            if v980 then
                local v981, v982, v983 = ipairs(v980:GetChildren())
                while true do
                    local v984
                    v983, v984 = v981(v982, v983)
                    if v983 == nil then
                        break
                    end
                    if v984.Name == "Coin_Server" then
                        return true
                    end
                end
            end
        end
        return false
    end
    function getMap()
        local v985 = vu12
        local v986, v987, v988 = ipairs(v985:GetChildren())
        while true do
            local v989
            v988, v989 = v986(v987, v988)
            if v988 == nil then
                break
            end
            if v989:FindFirstChild("CoinContainer") and v989:FindFirstChild("Spawns") then
                return v989
            end
        end
        return nil
    end
    function Teleport_to_map(_)
        if getMap() then
            local v990 = getMap():FindFirstChild("Spawns")
            if v990 then
                local v991 = v990:GetChildren()
                local v992 = v991[math.random(1, # v991)]
                game.Players.LocalPlayer.Character:MoveTo(v992.Position)
            else
                print(111)
            end
        else
            print("map not found")
        end
    end
    lift = - 4
    vu34.autofarm:Toggle({
        Title = "loc:autofarm",
        Value = getgenv().runnings,
        Callback = function(p993)
            getgenv().runnings = p993
            if p993 then
                warn("[AutoFarm] \208\146\208\186\208\187\209\142\209\135\208\181\208\189\208\190")
                vu34.troll.Locked = true
                vu34.combat.Locked = true
                sendnotification("trolling and combat locked")
                vu878:Set(true)
                vu542:Set(false)
                vu536:Set(false)
                vu545:Set(false)
                vu548:Set(false)
                vu261:Set(false)
                task.spawn(function()
                    while getgenv().runnings do
                        print("[AutoFarm] \208\166\208\184\208\186\208\187 \208\183\208\176\208\191\209\131\209\137\208\181\208\189")
                        local vu994 = vu945.Character
                        if vu994 then
                            vu994 = vu945.Character:FindFirstChild("HumanoidRootPart")
                        end
                        if vu994 then
                            local vu995 = vu947:FindFirstChild("GetPlayerData", true)
                            if not vu995 then
                                return
                            end
                            local v996, v997 = pcall(function()
                                return vu995:InvokeServer()
                            end)
                            if v996 and type(v997) == "table" then
                                local v998 = v997[vu14.Name]
                                if v998 then
                                    if v998.Dead == true or v998.Killed == true then
                                        if resetmurderer then
                                            print("\239\191\189\208\186\208\187\209\142\209\135\208\181\208\189 end round...")
                                            local v999 = GetMurder()
                                            if v999 then
                                                if vu597 then
                                                    vu597 = "autofarmfling1"
                                                end
                                                while v999 and (getgenv().runnings and resetmurderer) do
                                                    vu596(v999)
                                                    repeat
                                                        task.wait(0.5)
                                                    until not getgenv().alr
                                                    v999 = GetMurder()
                                                end
                                            else
                                                vu597 = nil
                                                warn("\239\191\189\208\176\209\128\208\180\208\181\209\128\208\176 \208\189\208\181\209\130, \208\191\209\128\208\190\208\191\209\131\209\129\208\186\208\176\208\181\208\188")
                                            end
                                            vu597 = nil
                                            roundend = true
                                        end
                                        roundend = true
                                        startround = false
                                        print("\239\191\189\208\176\209\130\208\176 \208\184\208\188\208\181\208\181\209\130\209\129\209\143 \208\184 \208\184\208\179\209\128\208\190\208\186 \208\178\208\189\208\181 \209\128\208\176\209\131\208\189\208\180\208\176")
                                    else
                                        roundend = false
                                        if GetAfterRun() then
                                            startround = true
                                        end
                                        print("\239\191\189\208\176\209\130\208\176 \208\184\208\188\208\181\208\181\209\130\209\129\209\143 \208\184 \208\184\208\179\209\128\208\190\208\186 \208\178 \209\128\208\176\209\131\208\189\208\180\208\181")
                                    end
                                else
                                    if resetmurderer then
                                        print("\239\191\189\208\186\208\187\209\142\209\135\208\181\208\189 end round...")
                                        local v1000 = GetMurder()
                                        if v1000 then
                                            while v1000 and (getgenv().runnings and resetmurderer) do
                                                miniFling(v1000)
                                                task.wait(2.4)
                                                v1000 = GetMurder()
                                            end
                                            print("\239\191\189\208\187\208\184\208\189\208\179 \209\129\208\190\209\129\209\130\208\190\209\143\208\187\209\129\209\143 \208\184 \209\131\208\177\208\184\208\185\209\134\209\139 \208\189\208\181\209\130\209\131")
                                        else
                                            print("\239\191\189\208\177\208\184\208\185\209\134\208\176 \208\191\209\128\208\190\208\191\208\176\208\187 \208\184 \209\132\208\187\208\184\208\189\208\179\208\176 \208\189\208\181 \208\177\209\131\208\180\208\181\209\130")
                                        end
                                    end
                                    roundend = true
                                    startround = false
                                    warn("\239\191\189\208\176\208\189\208\189\209\139\209\133 \208\180\208\187\209\143 \208\184\208\179\209\128\208\190\208\186\208\176 \208\189\208\181\209\130")
                                end
                            end
                            if roundend then
                                print("\239\191\189\208\176\209\131\208\189\208\180 \208\183\208\176\208\186\208\190\208\189\209\135\208\184\208\187\209\129\209\143 \226\128\148 \208\182\208\180\208\181\208\188 \208\189\208\190\208\178\209\139\208\185")
                                fullbag = false
                                task.wait(1)
                            elseif startround then
                                print("[AutoFarm] \208\160\208\176\209\131\208\189\208\180 \208\178 \208\191\209\128\208\190\209\134\208\181\209\129\209\129\208\181")
                                if GetMurder() then
                                    if fullbag then
                                        print("[AutoFarm] \208\161\209\131\208\188\208\186\208\176 \208\191\208\190\208\187\208\189\208\176\209\143 \226\128\148 \208\178\209\139\209\133\208\190\208\180\208\184\208\188 \208\184\208\183 \209\134\208\184\208\186\208\187\208\176")
                                        if afterfarm then
                                            if selector ~= "Afk" then
                                                if selector == "End Round" then
                                                    pcall(function()
                                                        local v1001 = vu994:FindFirstChild("FLY_NIGGER")
                                                        if v1001 then
                                                            v1001:Destroy()
                                                            print("BodyVelocity \209\131\208\180\208\176\208\187\209\145\208\189")
                                                        end
                                                    end)
                                                    local vu1002 = vu14.Character
                                                    local v1003 = false
                                                    if vu1002 then
                                                        v1003 = vu1002:FindFirstChild("Knife") and true or (vu14.Backpack:FindFirstChild("Knife") and true or v1003)
                                                    end
                                                    pcall(function()
                                                        local v1004 = vu12.Lobby.Spawns:GetChildren()
                                                        if vu994 and # v1004 > 0 then
                                                            vu994.CFrame = v1004[math.random(# v1004)].CFrame + Vector3.new(0, 3, 0)
                                                        end
                                                    end)
                                                    fullbag = false
                                                    if not v1003 then
                                                        local v1005 = GetMurder()
                                                        if v1005 then
                                                            if vu597 then
                                                                vu597 = "autofarmfling2"
                                                            end
                                                            while v1005 and (getgenv().runnings and resetmurderer) do
                                                                vu596(v1005)
                                                                repeat
                                                                    task.wait(0.5)
                                                                until not getgenv().alr
                                                                v1005 = GetMurder()
                                                            end
                                                        else
                                                            vu597 = nil
                                                            warn("\239\191\189\208\176\209\128\208\180\208\181\209\128\208\176 \208\189\208\181\209\130, \208\191\209\128\208\190\208\191\209\131\209\129\208\186\208\176\208\181\208\188")
                                                        end
                                                        vu597 = nil
                                                        roundend = true
                                                    end
                                                    warn("\239\191\189 \209\131\208\177\208\184\208\185\209\134\208\176 \208\184 \208\188\208\181\209\136\208\190\208\186 \208\191\208\190\208\187\208\190\208\189. \208\157\208\176\209\135\208\184\208\189\208\176\209\142 \208\176\208\178\209\130\208\190\209\131\208\177\208\184\208\185\209\129\209\130\208\178\208\190.")
                                                    for _ = 1, 25 do
                                                        pcall(function()
                                                            EquipTool()
                                                            task.wait()
                                                            local v1006 = vu1002:FindFirstChild("Knife")
                                                            local v1007, v1008, v1009 = ipairs(game.Players:GetPlayers())
                                                            while true do
                                                                local v1010
                                                                v1009, v1010 = v1007(v1008, v1009)
                                                                if v1009 == nil then
                                                                    break
                                                                end
                                                                if v1010 ~= vu14 and v1010.Character and v1010.Character:FindFirstChild("HumanoidRootPart") then
                                                                    local v1011 = v1010.Character.HumanoidRootPart
                                                                    game:GetService("Players").LocalPlayer.Character.Knife.Events.KnifeStabbed:FireServer()
                                                                    firetouchinterest(v1011, v1006.Handle, 1)
                                                                    firetouchinterest(v1011, v1006.Handle, 0)
                                                                    game:GetService("Players").LocalPlayer.Character:WaitForChild("Knife"):WaitForChild("Events"):WaitForChild("HandleTouched"):FireServer(unpack({
                                                                        v1011
                                                                    }))
                                                                end
                                                            end
                                                        end)
                                                        task.wait()
                                                    end
                                                    roundend = true
                                                end
                                            else
                                                pcall(function()
                                                    local v1012 = vu994:FindFirstChild("FLY_NIGGER")
                                                    if v1012 then
                                                        v1012:Destroy()
                                                        print("BodyVelocity \209\131\208\180\208\176\208\187\209\145\208\189")
                                                    end
                                                end)
                                                if vu945.Character and vu945.Character:FindFirstChild("HumanoidRootPart") then
                                                    local v1013 = vu12.Lobby.Spawns:GetChildren()
                                                    if vu994 and # v1013 > 0 then
                                                        vu994.CFrame = v1013[math.random(# v1013)].CFrame + Vector3.new(0, 3, 0)
                                                    end
                                                end
                                                fullbag = false
                                                roundend = true
                                            end
                                        else
                                            fullbag = false
                                            roundend = true
                                            local v1014 = vu945.Character
                                            if v1014 then
                                                v1014 = vu945.Character:FindFirstChildOfClass("Humanoid")
                                            end
                                            if v1014 and v1014.Health > 0 then
                                                v1014.Health = 0
                                            end
                                        end
                                    else
                                        print("\239\191\189\208\176\208\191\208\190\208\187\208\189\209\143\208\181\208\188 \208\188\208\181\209\136\208\190\208\186...")
                                    end
                                    local vu1015 = vu972()
                                    if vu1015 and vu994 then
                                        print("[AutoFarm] \208\164\208\176\209\128\208\188\208\184\208\188 \208\188\208\190\208\189\208\181\209\130\209\131: ", vu1015.Name)
                                        vu956()
                                        if not vu994:FindFirstChild("FLY_NIGGER") then
                                            local v1016 = Instance.new("BodyVelocity", vu994)
                                            v1016.MaxForce = Vector3.new(9000000000, 9000000000, 9000000000)
                                            v1016.Name = "FLY_NIGGER"
                                        end
                                        if not vu945.Character then
                                            return
                                        end
                                        local v1017 = vu945.Character:WaitForChild("HumanoidRootPart")
                                        local v1018 = (vu994.Position - vu1015.Position).Magnitude / movespeed
                                        local v1019 = vu946
                                        local v1020 = {
                                            CFrame = CFrame.new(vu1015.Position + Vector3.new(0, lift, 0))
                                        }
                                        local v1021 = v1019:Create(v1017, TweenInfo.new(v1018, Enum.EasingStyle.Linear, Enum.EasingDirection.Out), v1020)
                                        v1021:Play()
                                        v1021.Completed:Wait()
                                        if vu1015 and vu1015.Parent then
                                            vu956()
                                            pcall(function()
                                                firetouchinterest(vu1015, vu994, 0)
                                                firetouchinterest(vu1015, vu994, 1)
                                            end)
                                            pcall(function()
                                                vu1015:Destroy()
                                            end)
                                        end
                                    else
                                        print("[AutoFarm] \208\157\208\181\209\130 \208\191\208\190\208\180\209\133\208\190\208\180\209\143\209\137\208\181\208\185 \208\188\208\190\208\189\208\181\209\130\209\139, \208\182\208\180\209\145\208\188 0.5 \209\129\208\181\208\186")
                                        task.wait(0.5)
                                    end
                                    print("\239\191\189\208\184\208\186\208\187 \208\178\208\189\208\184\208\183\209\131 :3")
                                else
                                    warn("[Autofarm] \208\163\208\177\208\184\208\185\209\134\208\176 \209\131\208\188\208\181\209\128, \208\190\209\129\209\130\208\176\208\189\208\190\208\178\208\186\208\176 \208\176\208\178\209\130\208\190\209\132\208\176\209\128\208\188\208\176 \208\180\208\190 \209\129\208\187\208\181\208\180\209\131\209\142\209\137\208\181\208\185 \208\184\208\179\209\128\209\139")
                                    fullbag = false
                                    roundend = true
                                    startround = false
                                    pcall(function()
                                        if vu994 then
                                            local v1022 = vu994:FindFirstChild("FLY_NIGGER")
                                            if v1022 then
                                                v1022:Destroy()
                                                print("BodyVelocity \209\131\208\180\208\176\208\187\209\145\208\189")
                                            end
                                            vu994.CFrame = CFrame.new(vu994.Position + Vector3.new(0, 7, 0))
                                        end
                                    end)
                                    task.wait(1)
                                end
                            else
                                fullbag = false
                                print("\239\191\189\208\180\208\181\208\188 coincontainer")
                                task.wait(1)
                            end
                        else
                            print("\239\191\189\208\180\208\181\208\188 \208\191\208\190\209\143\208\178\208\187\208\181\208\189\208\184\209\143 hrp")
                            task.wait(0.5)
                        end
                    end
                    pcall(function()
                        local v1023 = vu945.Character
                        if v1023 then
                            v1023 = vu945.Character:FindFirstChild("HumanoidRootPart")
                        end
                        if v1023 then
                            local v1024 = v1023:FindFirstChild("FLY_NIGGER")
                            if v1024 then
                                v1024:Destroy()
                                print("BodyVelocity \209\131\208\180\208\176\208\187\209\145\208\189")
                            end
                            v1023.CFrame = CFrame.new(v1023.Position + Vector3.new(0, 7, 0))
                        end
                    end)
                    print("[AutoFarm] \208\166\208\184\208\186\208\187 \209\132\208\176\209\128\208\188\208\176 \208\183\208\176\208\178\208\181\209\128\209\136\209\145\208\189")
                end)
            else
                warn("[AutoFarm] \208\146\209\139\208\186\208\187\209\142\209\135\208\181\208\189\208\190")
                vu34.troll.Locked = false
                vu34.combat.Locked = false
                sendnotification("trolling and combat unlocked")
                vu878:Set(false)
                roundend = true
                startround = false
                fullbag = false
                pcall(function()
                    local v1025 = vu945.Character
                    if v1025 then
                        v1025 = vu945.Character:FindFirstChild("HumanoidRootPart")
                    end
                    if v1025 then
                        local v1026 = v1025:FindFirstChild("FLY_NIGGER")
                        if v1026 then
                            v1026:Destroy()
                            print("BodyVelocity \209\131\208\180\208\176\208\187\209\145\208\189")
                        end
                        v1025.CFrame = CFrame.new(v1025.Position + Vector3.new(0, 7, 0))
                    end
                end)
            end
        end
    })
    vu34.autofarm:Slider({
        Title = "loc:safetp",
        Desc = "",
        Value = {
            Min = - 5,
            Max = 1,
            Default = lift
        },
        Callback = function(p1027)
            lift = p1027
        end
    })
    vu34.autofarm:Slider({
        Title = "loc:farmspeed",
        Desc = "loc:descfarmspeed",
        Value = {
            Min = 19,
            Max = 24,
            Default = movespeed
        },
        Callback = function(p1028)
            movespeed = p1028
        end
    })
    vu34.autofarm:Toggle({
        Title = "loc:endround",
        Desc = "loc:descendround",
        Value = resetmurderer,
        Callback = function(p1029)
            resetmurderer = p1029
        end
    })
    vu34.autofarm:Dropdown({
        Title = "loc:selectafterfarm",
        Values = {
            "Afk",
            "End Round"
        },
        Value = selector,
        Callback = function(p1030)
            selector = p1030
        end
    })
    vu34.autofarm:Toggle({
        Title = "loc:togafterfarm",
        Value = afterfarm,
        Callback = function(p1031)
            afterfarm = p1031
        end
    })
    vu34.autofarm:Toggle({
        Title = "loc:3drender",
        Desc = "loc:3drenderdesc",
        Value = false,
        Callback = function(p1032)
            vu10:Set3dRenderingEnabled(not p1032)
        end
    })
    vu34.autofarm:Paragraph({
        Title = "loc:autofarm_info"
    })
    loadstring(game:HttpGet("https://raw.githubusercontent.com/Roma77799/Secrethub/refs/heads/main/OtherSCRIPTS/GAMESTATUS"))()
    vu34.status:Section({
        Title = "Thunder Hub Status"
    })
    vu34.status:Paragraph({
        Title = "Thunder Hub Murder Mystery 2",
        Desc = SSH_mm2
    })
    vu34.status:Paragraph({
        Title = "Thunder Hub TimeBomb Duels",
        Desc = SSH_timebomb
    })
    vu34.report:Section({
        Title = "Report Bugs"
    })
    reportButtonPresses = 0
    chatId = - 1002853777462
    botToken = "8432656507:AAEpuoT4W15g_9iNBxFmTAQTwF9ZLtkBdRo"
    reportsid = 29143
    reportcat = nil
    reportinput = nil
    function identifyexploit()
        local v1033, v1034 = pcall(identifyexecutor)
        if v1033 then
            return v1034
        end
        local v1035 = SENTINEL_LOADED and "Sentinel" or XPROTECT and "SirHurt"
        if not v1035 then
            local v1036 = PROTOSMASHER_LOADED
            v1035 = v1036 and "Protosmasher" or v1036
        end
        return v1035
    end
    reportdrop = vu34.report:Dropdown({
        Title = "loc:reportcategory",
        Values = {
            "CHARACTER",
            "COMBAT",
            "TELEPORT",
            "TROLLING",
            "ESP",
            "VISUAl",
            "EMOTES",
            "OTHER",
            "AUTOFARM",
            "SETTINGS"
        },
        Multi = false,
        Callback = function(p1037)
            reportcat = p1037
        end
    })
    vu34.report:Input({
        Title = "loc:placeholderreport",
        Value = "",
        Placeholder = "...",
        Type = "Textarea",
        Callback = function(p1038)
            print("text entered: " .. p1038)
            reportinput = p1038
        end
    })
    vu34.report:Button({
        Title = "loc:sendreport",
        Callback = function()
            if reportcat == nil or reportinput == "" then
                sendnotification("Fill in the dropdown field nigga")
                return
            else
                reportButtonPresses = reportButtonPresses + 1
                if reportButtonPresses <= 10 then
                    local v1039 = vu14.Name
                    local v1040 = vu14.DisplayName
                    local v1041 = game.PlaceId
                    local v1042 = identifyexecutor and identifyexecutor() or "Unknown"
                    local v1043 = reportcat or "Unknown"
                    local v1044 = reportinput or "No description provided"
                    local v1045 = "*New Report Received!*\n" .. "*Player Information*\n" .. "```\n" .. "Username: " .. v1039 .. "\n" .. "Display Name: " .. v1040 .. "\n" .. "Account Age: " .. tostring(vu14.AccountAge) .. "\n" .. "Executor: " .. v1042 .. "\n" .. "Place ID: " .. tostring(v1041) .. "\n" .. "```\n" .. "*Category:* " .. v1043 .. "\n" .. "*Message:* " .. v1044
                    local v1046 = "https://api.telegram.org/bot" .. botToken .. "/sendMessage"
                    local v1047 = {
                        chat_id = chatId,
                        text = v1045,
                        parse_mode = "Markdown"
                    }
                    if reportsid then
                        v1047.message_thread_id = reportsid
                    end
                    local v1048 = game:GetService("HttpService"):JSONEncode(v1047)
                    local v1049 = not http_request and syn
                    if v1049 then
                        v1049 = syn.request
                    end
                    if v1049 then
                        v1049({
                            Url = v1046,
                            Method = "POST",
                            Headers = {
                                ["Content-Type"] = "application/json"
                            },
                            Body = v1048
                        })
                        vu18:Play()
                        sendnotification("Report successfully sent to Telegram!")
                    else
                        sendnotification("Failed to send report: HTTP requests not supported.")
                    end
                else
                    game.Players.LocalPlayer:Kick("Thunder HUB - You have been kicked for spamming reports.")
                end
            end
        end
    })
    vu34.report:Paragraph({
        Title = "loc:report_how"
    })
    vu34.changelog:Section({
        Title = "About Script"
    })
    vu34.changelog:Paragraph({
        Title = "loc:status_script"
    })
    vu34.changelog:Paragraph({
        Title = "loc:product_type"
    })
    vu34.changelog:Paragraph({
        Title = "loc:script_version"
    })
    vu34.changelog:Paragraph({
        Title = "loc:launched_from"
    })
    vu34.changelog:Paragraph({
        Title = "loc:executor"
    })
    vu34.changelog:Paragraph({
        Title = "loc:age"
    })
    vu34.changelog:Section({
        Title = "Credits"
    })
    vu34.changelog:Button({
        Title = "loc:youtube",
        Callback = function()
            setclipboard("https://youtube.com/@snapsan?si=ZF3AY7iivGUnTpOc")
            vu18:Play()
            sendnotification("Youtube Channel Link Copy To Clipboard")
        end
    })
    vu34.changelog:Paragraph({
        Title = "loc:script_tester"
    })
    vu34.another:Section({
        Title = "Second link to the script, mirror"
    })
    vu34.another:Code({
        Title = "ThunderX Hub",
        Code = "loadstring(game:HttpGet(\'https://raw.githubusercontent.com/thunderXhub/ThunderXHUB/refs/heads/main/loader\'))()"
    })
    vu34.settings:Section({
        Title = "Settings"
    })
    -- ==================== QUICK BUTTONS SETTINGS ====================
vu34.settings:Section({
    Title = "Quick Buttons",
    Icon = "grid"
})

-- Enable All Buttons
vu34.settings:Toggle({
    Title = "Enable All Buttons",
    Desc = "Show/hide all quick buttons",
    Value = true,
    Callback = function(State)
        for _, btn in ipairs(CreatedButtons) do
            btn.Visible = State
        end
    end
})

-- Edit Layout Toggle
local EditModeToggle = vu34.settings:Toggle({
    Title = "Edit Layout",
    Desc = "Toggle to move buttons around",
    Value = false,
    Callback = function(State)
        EditMode = State
        if not EditMode and SelectedButton then
            SelectedButton.BackgroundColor3 = Color3.fromRGB(25, 25, 25)
            SelectedButton = nil
        end
        UpdateEditLabel()
    end
})

-- ==================== GLOBAL BUTTON STYLING ====================
vu34.settings:Section({
    Title = "Global Button Style",
    Icon = "paintbrush"
})

-- Global Opacity
vu34.settings:Slider({
    Title = "Global Opacity",
    Desc = "Change opacity for all buttons",
    Step = 0.05,
    Value = {
        Min = 0.1,
        Max = 1,
        Default = 0.4
    },
    Callback = function(Value)
        for _, btn in ipairs(CreatedButtons) do
            btn.BackgroundTransparency = 1 - Value
            btn.TextTransparency = 1 - Value
            if btn.UIStroke then
                btn.UIStroke.Transparency = 1 - Value
            end
        end
    end
})

-- Global Scale
vu34.settings:Slider({
    Title = "Global Scale",
    Desc = "Change size for all buttons",
    Step = 5,
    Value = {
        Min = 40,
        Max = 150,
        Default = 70
    },
    Callback = function(Value)
        for _, btn in ipairs(CreatedButtons) do
            local ratio = btn.Size.Y.Offset / btn.Size.X.Offset
            btn.Size = UDim2.fromOffset(Value, Value * ratio)
        end
    end
})

-- Global Shape Dropdown
local shapeConfigs = {
    Circle = {corner = UDim.new(1, 0), forceSquare = true},
    Square = {corner = UDim.new(0, 0), forceSquare = true},
    ["Rounded Rectangle"] = {corner = UDim.new(0, 12), forceSquare = false},
    Capsule = {corner = UDim.new(1, 0), forceSquare = false},
    ["Sharp Rectangle"] = {corner = UDim.new(0, 0), forceSquare = false},
}
local shapes = {"Circle", "Square", "Rounded Rectangle", "Capsule", "Sharp Rectangle"}

vu34.settings:Dropdown({
    Title = "Global Shape",
    Desc = "Change shape for all buttons",
    Values = shapes,
    Value = "Circle",
    Callback = function(Selected)
        local cfg = shapeConfigs[Selected]
        for _, btn in ipairs(CreatedButtons) do
            local w = btn.Size.X.Offset
            btn.Size = UDim2.fromOffset(w, cfg.forceSquare and w or w * 0.6)
            btn.UICorner.CornerRadius = cfg.corner
        end
    end
})

-- Reset All Buttons
vu34.settings:Button({
    Title = "Reset All Buttons",
    Desc = "Reset all buttons to default",
    Callback = function()
        for _, btn in ipairs(CreatedButtons) do
            btn.Size = UDim2.fromOffset(70, 70)
            btn.BackgroundTransparency = 0.4
            btn.TextTransparency = 0
            if btn.UIStroke then
                btn.UIStroke.Transparency = 0
            end
            btn.UICorner.CornerRadius = UDim.new(1, 0)
        end
        sendnotification("All buttons reset!")
    end
})

-- Save Layout Button
vu34.settings:Button({
    Title = "Save Layout",
    Desc = "Save current button layout",
    Callback = SaveConfig
})
-- ==================== INDIVIDUAL BUTTON EDITOR ====================
vu34.settings:Section({
    Title = "Individual Button Editor",
    Icon = "settings"
})

-- Buat GUI Editor untuk individual button
local EditGui = Instance.new("ScreenGui")
EditGui.Name = "ButtonEditor"
EditGui.ResetOnSpawn = false
EditGui.DisplayOrder = 100
EditGui.Parent = cloneref(LocalPlayer:WaitForChild("PlayerGui"))

local MainFrame = Instance.new("Frame")
MainFrame.Name = "MainFrame"
MainFrame.Size = UDim2.new(0, 240, 0, 245)
MainFrame.Position = UDim2.new(0.5, -120, 0.5, -122)
MainFrame.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
MainFrame.Active = true
MainFrame.Visible = false
MainFrame.Parent = EditGui
Instance.new("UICorner", MainFrame).CornerRadius = UDim.new(0, 12)

-- Header (drag area)
local Header = Instance.new("Frame")
Header.Size = UDim2.new(1, 0, 0, 30)
Header.BackgroundTransparency = 1
Header.Parent = MainFrame

local draggingWidget, dragStart, startPos
Header.InputBegan:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
        draggingWidget = true
        dragStart = input.Position
        startPos = MainFrame.Position
    end
end)
UserInputService.InputChanged:Connect(function(input)
    if draggingWidget and (input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch) then
        local delta = input.Position - dragStart
        MainFrame.Position = UDim2.new(startPos.X.Scale, startPos.X.Offset + delta.X, startPos.Y.Scale, startPos.Y.Offset + delta.Y)
    end
end)
UserInputService.InputEnded:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
        draggingWidget = false
    end
end)

local Content = Instance.new("Frame")
Content.Size = UDim2.new(1, 0, 1, -30)
Content.Position = UDim2.new(0, 0, 0, 30)
Content.BackgroundTransparency = 1
Content.Parent = MainFrame

-- Label helper
local function createLabel(text, pos, parent, size, alignment, isBold)
    local label = Instance.new("TextLabel")
    label.Text = text
    label.Size = UDim2.new(1, -24, 0, 15)
    label.Position = pos
    label.BackgroundTransparency = 1
    label.TextColor3 = isBold and Color3.fromRGB(40, 40, 40) or Color3.fromRGB(120, 120, 120)
    label.TextXAlignment = alignment or Enum.TextXAlignment.Left
    label.Font = isBold and Enum.Font.GothamBold or Enum.Font.Gotham
    label.TextSize = size or 11
    label.Parent = parent
    return label
end

createLabel("SELECTED BUTTON", UDim2.new(0, 12, 0, 5), Content, 10, nil, true)
local NameLabel = createLabel("No Selection", UDim2.new(0, 12, 0, 18), Content, 12, nil, false)

-- Slider Opacity
local function createSlider(name, pos, parent, onChange, getCurrent)
    local container = Instance.new("Frame", parent)
    container.Size = UDim2.new(1, -24, 0, 35)
    container.Position = pos
    container.BackgroundTransparency = 1

    createLabel(name, UDim2.new(0, 0, 0, 0), container, 10, nil, true)
    local valLabel = createLabel("0", UDim2.new(0, 0, 0, 0), container, 10, Enum.TextXAlignment.Right, true)
    valLabel.TextColor3 = MASTER_VIOLET

    local track = Instance.new("TextButton", container)
    track.Size = UDim2.new(1, 0, 0, 4)
    track.Position = UDim2.new(0, 0, 0, 22)
    track.BackgroundColor3 = Color3.fromRGB(230, 230, 230)
    track.BorderSizePixel = 0
    track.Text = ""

    local knob = Instance.new("Frame", track)
    knob.Size = UDim2.new(0, 14, 0, 14)
    knob.AnchorPoint = Vector2.new(0.5, 0.5)
    knob.Position = UDim2.new(0, 0, 0.5, 0)
    knob.BackgroundColor3 = MASTER_VIOLET
    Instance.new("UICorner", knob).CornerRadius = UDim.new(1, 0)

    local isSliding = false
    local function move(input)
        local ratio = math.clamp((input.Position.X - track.AbsolutePosition.X) / track.AbsoluteSize.X, 0, 1)
        knob.Position = UDim2.new(ratio, 0, 0.5, 0)
        valLabel.Text = tostring(math.round(ratio * 100))
        if SelectedButton then onChange(ratio) end
    end

    track.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
            isSliding = true
            move(input)
        end
    end)
    UserInputService.InputChanged:Connect(function(input)
        if isSliding and (input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch) then
            move(input)
        end
    end)
    UserInputService.InputEnded:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
            isSliding = false
        end
    end)

    RunService.RenderStepped:Connect(function()
        if not isSliding and SelectedButton and getCurrent then
            local p = getCurrent()
            knob.Position = UDim2.new(p, 0, 0.5, 0)
            valLabel.Text = tostring(math.round(p * 100))
        end
    end)
end

createSlider("OPACITY", UDim2.new(0, 12, 0, 45), Content, 
    function(p) 
        SelectedButton.BackgroundTransparency = 1-p 
        SelectedButton.TextTransparency = 1-p 
        if SelectedButton.UIStroke then
            SelectedButton.UIStroke.Transparency = 1-p 
        end
    end,
    function() return 1 - SelectedButton.BackgroundTransparency end
)

createSlider("SCALE", UDim2.new(0, 12, 0, 85), Content, 
    function(p) 
        local s = 30 + (p * 220) 
        local ratio = SelectedButton.Size.Y.Offset / SelectedButton.Size.X.Offset 
        SelectedButton.Size = UDim2.fromOffset(s, s*ratio) 
    end,
    function() return (SelectedButton.Size.X.Offset - 30) / 220 end
)

createLabel("SHAPE", UDim2.new(0, 12, 0, 130), Content, 10, nil, true)
local ShapeBtn = Instance.new("TextButton", Content)
ShapeBtn.Size = UDim2.new(1, -24, 0, 26)
ShapeBtn.Position = UDim2.new(0, 12, 0, 148)
ShapeBtn.BackgroundColor3 = Color3.fromRGB(245, 245, 245)
ShapeBtn.Text = "  Select Shape..."
ShapeBtn.TextColor3 = Color3.fromRGB(100, 100, 100)
ShapeBtn.TextXAlignment = Enum.TextXAlignment.Left
ShapeBtn.Font = Enum.Font.Gotham
Instance.new("UICorner", ShapeBtn).CornerRadius = UDim.new(0, 6)

local Dropdown = Instance.new("ScrollingFrame", ShapeBtn)
Dropdown.Size = UDim2.new(1, 0, 0, 0)
Dropdown.Position = UDim2.new(0, 0, 1, 5)
Dropdown.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
Dropdown.BorderSizePixel = 0
Dropdown.ZIndex = 500
Dropdown.Visible = false
Instance.new("UICorner", Dropdown).CornerRadius = UDim.new(0, 6)
Instance.new("UIStroke", Dropdown).Transparency = 0.8

for i, sName in ipairs(shapes) do
    local b = Instance.new("TextButton", Dropdown)
    b.Size = UDim2.new(1, 0, 0, 25)
    b.Position = UDim2.new(0, 0, 0, (i-1)*25)
    b.BackgroundTransparency = 1
    b.Text = "  " .. sName
    b.TextColor3 = Color3.fromRGB(80, 80, 80)
    b.Font = Enum.Font.Gotham
    b.TextSize = 10
    b.TextXAlignment = Enum.TextXAlignment.Left
    b.ZIndex = 501
    b.MouseButton1Click:Connect(function()
        if SelectedButton then
            local cfg = shapeConfigs[sName]
            local w = SelectedButton.Size.X.Offset
            SelectedButton.Size = UDim2.fromOffset(w, cfg.forceSquare and w or w * 0.6)
            SelectedButton.UICorner.CornerRadius = cfg.corner
            ShapeBtn.Text = "  " .. sName
            Dropdown.Visible = false
            Dropdown.Size = UDim2.new(1, 0, 0, 0)
        end
    end)
end

ShapeBtn.MouseButton1Click:Connect(function()
    Dropdown.Visible = not Dropdown.Visible
    Dropdown.Size = Dropdown.Visible and UDim2.new(1, 0, 0, 125) or UDim2.new(1, 0, 0, 0)
end)

-- Buttons: Reset, Exit, Save
local ResetBtn = Instance.new("TextButton", Content)
ResetBtn.Size = UDim2.new(0, 65, 0, 26)
ResetBtn.Position = UDim2.new(0, 12, 1, -35)
ResetBtn.BackgroundColor3 = Color3.fromRGB(200, 200, 200)
ResetBtn.Text = "Reset"
ResetBtn.Font = Enum.Font.GothamBold
Instance.new("UICorner", ResetBtn).CornerRadius = UDim.new(0, 6)

local ExitBtn = Instance.new("TextButton", Content)
ExitBtn.Size = UDim2.new(0, 65, 0, 26)
ExitBtn.Position = UDim2.new(0.5, -32, 1, -35)
ExitBtn.BackgroundColor3 = Color3.fromRGB(255, 80, 80)
ExitBtn.Text = "EXIT"
ExitBtn.TextColor3 = Color3.new(1,1,1)
ExitBtn.Font = Enum.Font.GothamBold
Instance.new("UICorner", ExitBtn).CornerRadius = UDim.new(0, 6)

local SaveBtn = Instance.new("TextButton", Content)
SaveBtn.Size = UDim2.new(0, 65, 0, 26)
SaveBtn.Position = UDim2.new(1, -77, 1, -35)
SaveBtn.BackgroundColor3 = MASTER_VIOLET
SaveBtn.Text = "Save"
SaveBtn.TextColor3 = Color3.new(1,1,1)
SaveBtn.Font = Enum.Font.GothamBold
Instance.new("UICorner", SaveBtn).CornerRadius = UDim.new(0, 6)

ResetBtn.MouseButton1Click:Connect(function()
    if SelectedButton then
        SelectedButton.Size = UDim2.fromOffset(70, 70)
        SelectedButton.BackgroundTransparency = 0.4
        SelectedButton.TextTransparency = 0
        if SelectedButton.UIStroke then
            SelectedButton.UIStroke.Transparency = 0
        end
        SelectedButton.UICorner.CornerRadius = UDim.new(1, 0)
    end
end)

ExitBtn.MouseButton1Click:Connect(function()
    EditMode = false
    MainFrame.Visible = false
    if SelectedButton then SelectedButton.BackgroundColor3 = Color3.fromRGB(25, 25, 25) end
    SelectedButton = nil
    UpdateEditLabel()
    EditModeToggle:Set(false)
end)

SaveBtn.MouseButton1Click:Connect(SaveConfig)

RunService.Heartbeat:Connect(function()
    MainFrame.Visible = EditMode and SelectedButton ~= nil
    if SelectedButton then NameLabel.Text = SelectedButton.Name end
end)
    vu34.settings:Keybind({
        Title = "loc:openhub",
        Value = "G",
        Callback = function(p1050)
            vu33:SetToggleKey(Enum.KeyCode[p1050])
        end
    })
    LangList = {
        en = "English",
        [v1] = "\239\191\189\209\131\209\129\209\129\208\186\208\184\208\185"
    }
    vu34.settings:Dropdown({
        Title = "loc:language",
        Values = {
            LangList.en,
            LangList[v1]
        },
        Callback = function(p1051)
            local v1052, v1053, v1054 = pairs(LangList)
            while true do
                local v1055
                v1054, v1055 = v1052(v1053, v1054)
                if v1054 == nil then
                    break
                end
                if v1055 == p1051 then
                    vu2:SetLanguage(v1054)
                end
            end
        end
    })
    vu34.settings:Button({
        Title = "loc:forgot",
        Callback = function()
            if type(readfile) == "function" and (type(writefile) == "function" and type(delfile) == "function") and isfile("configlanguage.json") then
                pcall(function()
                    delfile("configlanguage.json")
                end)
            else
                sendnotification("unsupported feature or reseted")
            end
            print("Language config reset.")
        end
    })
    themeValues = {}
    local v1056, v1057, v1058 = pairs(vu2:GetThemes())
    while true do
        local v1059
        v1058, v1059 = v1056(v1057, v1058)
        if v1058 == nil then
            break
        end
        table.insert(themeValues, v1058)
    end
    themeDropdown = vu34.settings:Dropdown({
        Title = "loc:selecttheme",
        Multi = false,
        AllowNone = false,
        Value = nil,
        Values = themeValues,
        Callback = function(p1060)
            vu2:SetTheme(p1060)
        end
    })
    themeDropdown:Select(vu2:GetCurrentTheme())
    vu34.settings:Section({
        Title = "Set Background"
    })
    backgrounds = {
        "rbxassetid://140079841906330",
        "rbxassetid://100725763584702",
        "rbxassetid://78521600730119",
        "rbxassetid://138070842",
        "rbxassetid://111385647298205",
        "rbxassetid://127427174065900",
        "rbxassetid://16049721756",
        "rbxassetid://15729794400",
        "rbxassetid://18685588755",
        "Clear"
    }
    transparency = 0.6
    vu34.settings:Dropdown({
        Title = "loc:selectbackground",
        Values = backgrounds,
        Callback = function(p1061)
            vu33:SetBackgroundImage(p1061)
            vu33:SetBackgroundImageTransparency(transparency)
        end
    })
    vu34.settings:Slider({
        Title = "loc:backgroundtrans",
        Value = {
            Min = 0,
            Max = 10,
            Default = 6
        },
        Callback = function(p1062)
            transparency = p1062 * 0.1
            vu33:SetBackgroundImageTransparency(transparency)
        end
    })
    vu34.settings:Section({
        Title = "Configs"
    })
    vu34.settings:Button({
        Title = "loc:config",
        Locked = true
    })
    print("Thunder Hub MM2 Loaded\226\156\133")
    vu18:Play()
    game.StarterGui:SetCore("SendNotification", {
        Title = "Thunder HUB",
        Icon = "rbxassetid://78521600730119",
        Text = "Murder Mystery 2 Version " .. versionn,
        Duration = 4
    })
    loadstring(game:HttpGet("https://raw.githubusercontent.com/Roma77799/Secrethub/refs/heads/main/Secret/changelogmm2", true))()
    loadstring(game:HttpGet("https://raw.githubusercontent.com/Roma77799/Secrethub/refs/heads/main/Secret/voting", true))()
