--[[
    ═══════════════════════════════════════════════════════
    AIMBOT SNAP INSTANTÂNEO - BRUTAL
    COLA NA CABEÇA IMEDIATAMENTE - SEM LERDEZA
    ═══════════════════════════════════════════════════════
]]

repeat wait() until game:IsLoaded()

if _G.BrutalAim then return end
_G.BrutalAim = true

-- ═══════════════════════════════════════════════════════
-- SERVIÇOS
-- ═══════════════════════════════════════════════════════

local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local UserInputService = game:GetService("UserInputService")
local Workspace = game:GetService("Workspace")
local Camera = Workspace.CurrentCamera
local LocalPlayer = Players.LocalPlayer

local IsMobile = UserInputService.TouchEnabled and not UserInputService.KeyboardEnabled

-- ═══════════════════════════════════════════════════════
-- CONFIG
-- ═══════════════════════════════════════════════════════

local Settings = {
    Active = false,
    AimPart = "Head", -- SEMPRE NA CABEÇA
    TeamCheck = true,
    FOV = 1000, -- FOV GIGANTE
    Prediction = true,
    PredictValue = 0.165, -- Ajuste conforme ping
    AutoShoot = false, -- Atirar automaticamente
}

local Target = nil
local FOVCircle = nil

-- ═══════════════════════════════════════════════════════
-- FOV CIRCLE
-- ═══════════════════════════════════════════════════════

if Drawing and not IsMobile then
    FOVCircle = Drawing.new("Circle")
    FOVCircle.Thickness = 1
    FOVCircle.NumSides = 100
    FOVCircle.Radius = Settings.FOV
    FOVCircle.Filled = false
    FOVCircle.Visible = true
    FOVCircle.Color = Color3.fromRGB(255, 0, 0)
    FOVCircle.Transparency = 0.5
end

-- ═══════════════════════════════════════════════════════
-- BOTÃO MOBILE
-- ═══════════════════════════════════════════════════════

local MobileBtn = nil

if IsMobile then
    local sg = Instance.new("ScreenGui")
    sg.Name = "BrutalAim"
    sg.ResetOnSpawn = false
    sg.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
    
    local btn = Instance.new("TextButton")
    btn.Parent = sg
    btn.BackgroundColor3 = Color3.fromRGB(255, 0, 0)
    btn.BorderSizePixel = 0
    btn.Position = UDim2.new(0.88, 0, 0.45, 0)
    btn.Size = UDim2.new(0, 70, 0, 70)
    btn.Font = Enum.Font.GothamBold
    btn.Text = "AIM\nOFF"
    btn.TextColor3 = Color3.white
    btn.TextSize = 18
    btn.TextWrapped = true
    
    local corner = Instance.new("UICorner")
    corner.CornerRadius = UDim.new(1, 0)
    corner.Parent = btn
    
    btn.MouseButton1Click:Connect(function()
        Settings.Active = not Settings.Active
        btn.Text = Settings.Active and "AIM\nON" or "AIM\nOFF"
        btn.BackgroundColor3 = Settings.Active and Color3.fromRGB(0, 255, 0) or Color3.fromRGB(255, 0, 0)
    end)
    
    pcall(function()
        sg.Parent = game:GetService("CoreGui")
    end)
    
    if not sg.Parent then
        sg.Parent = LocalPlayer:WaitForChild("PlayerGui")
    end
    
    MobileBtn = btn
end

-- ═══════════════════════════════════════════════════════
-- FUNÇÕES CORE
-- ═══════════════════════════════════════════════════════

local function IsValid(plr)
    if not plr or plr == LocalPlayer then return false end
    
    if Settings.TeamCheck and plr.Team == LocalPlayer.Team then
        return false
    end
    
    local char = plr.Character
    if not char then return false end
    
    local hum = char:FindFirstChildOfClass("Humanoid")
    if not hum or hum.Health <= 0 then return false end
    
    return true
end

local function GetClosest()
    local closest = nil
    local minDist = Settings.FOV
    
    local mousePos = IsMobile and Vector2.new(Camera.ViewportSize.X/2, Camera.ViewportSize.Y/2) or UserInputService:GetMouseLocation()
    
    for _, plr in pairs(Players:GetPlayers()) do
        if IsValid(plr) then
            local char = plr.Character
            local head = char:FindFirstChild(Settings.AimPart)
            
            if head then
                local pos, onScreen = Camera:WorldToViewportPoint(head.Position)
                
                if onScreen then
                    local dist = (Vector2.new(pos.X, pos.Y) - mousePos).Magnitude
                    
                    if dist < minDist then
                        minDist = dist
                        closest = plr
                    end
                end
            end
        end
    end
    
    return closest
end

-- ═══════════════════════════════════════════════════════
-- SNAP INSTANTÂNEO
-- ═══════════════════════════════════════════════════════

local function SnapToHead()
    if not Settings.Active then return end
    if not Target or not Target.Character then return end
    
    local head = Target.Character:FindFirstChild(Settings.AimPart)
    if not head then return end
    
    -- Posição do alvo
    local targetPos = head.Position
    
    -- PREDIÇÃO
    if Settings.Prediction then
        local vel = head.AssemblyLinearVelocity or Vector3.zero
        targetPos = targetPos + (vel * Settings.PredictValue)
    end
    
    -- SNAP INSTANTÂNEO - SEM LERP, SEM SUAVIZAÇÃO
    Camera.CFrame = CFrame.new(Camera.CFrame.Position, targetPos)
    
    -- Auto shoot
    if Settings.AutoShoot and mouse1press then
        mouse1press()
        wait(0.01)
        mouse1release()
    end
end

-- ═══════════════════════════════════════════════════════
-- LOOP
-- ═══════════════════════════════════════════════════════

RunService.Heartbeat:Connect(function()
    if FOVCircle then
        local mp = UserInputService:GetMouseLocation()
        FOVCircle.Position = mp
        FOVCircle.Visible = Settings.Active
    end
    
    if Settings.Active then
        Target = GetClosest()
        SnapToHead()
    end
end)

-- Loop adicional no RenderStepped para ser ainda mais rápido
RunService.RenderStepped:Connect(function()
    if Settings.Active then
        SnapToHead()
    end
end)

-- ═══════════════════════════════════════════════════════
-- CONTROLES PC
-- ═══════════════════════════════════════════════════════

if not IsMobile then
    UserInputService.InputBegan:Connect(function(input, gpe)
        if gpe then return end
        
        -- Botão direito
        if input.UserInputType == Enum.UserInputType.MouseButton2 then
            Settings.Active = true
        end
        
        -- Q = Toggle
        if input.KeyCode == Enum.KeyCode.Q then
            Settings.Active = not Settings.Active
            print("🎯", Settings.Active and "ON" or "OFF")
        end
        
        -- C = AutoShoot
        if input.KeyCode == Enum.KeyCode.C then
            Settings.AutoShoot = not Settings.AutoShoot
            print("🔫 AutoShoot:", Settings.AutoShoot and "ON" or "OFF")
        end
    end)
    
    UserInputService.InputEnded:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton2 then
            Settings.Active = false
        end
    end)
end

-- ═══════════════════════════════════════════════════════
-- COMANDOS CHAT
-- ═══════════════════════════════════════════════════════

LocalPlayer.Chatted:Connect(function(msg)
    msg = msg:lower()
    
    if msg == "/aim" then
        Settings.Active = not Settings.Active
        if MobileBtn then
            MobileBtn.Text = Settings.Active and "AIM\nON" or "AIM\nOFF"
            MobileBtn.BackgroundColor3 = Settings.Active and Color3.fromRGB(0, 255, 0) or Color3.fromRGB(255, 0, 0)
        end
        print("🎯", Settings.Active and "ON" or "OFF")
        
    elseif msg == "/autoshoot" then
        Settings.AutoShoot = not Settings.AutoShoot
        print("🔫 AutoShoot:", Settings.AutoShoot and "ON" or "OFF")
        
    elseif msg:match("^/predict%s") then
        local val = tonumber(msg:match("%d+%.?%d*"))
        if val then
            Settings.PredictValue = val
            print("📍 Predição:", val)
        end
    end
end)

-- ═══════════════════════════════════════════════════════
-- INIT
-- ═══════════════════════════════════════════════════════

print("╔════════════════════════════════════════╗")
print("║   🎯 AIMBOT SNAP INSTANTÂNEO 🎯       ║")
print("╠════════════════════════════════════════╣")

if IsMobile then
    print("║  📱 MOBILE: Use o botão na tela       ║")
    print("║  🔴 Vermelho = OFF                     ║")
    print("║  🟢 Verde = ON                         ║")
else
    print("║  🖥️ PC CONTROLES:                      ║")
    print("║  • SEGURAR BOTÃO DIREITO = Ativar     ║")
    print("║  • Q = Toggle ON/OFF                  ║")
    print("║  • C = AutoShoot ON/OFF               ║")
end

print("║                                        ║")
print("║  💬 COMANDOS CHAT:                     ║")
print("║  /aim - Toggle                         ║")
print("║  /autoshoot - Auto atirar              ║")
print("║  /predict 0.15 - Ajustar predição      ║")
print("║                                        ║")
print("║  ⚡ SNAP INSTANTÂNEO                    ║")
print("║  🎯 COLA NA CABEÇA SEM DELAY           ║")
print("║  🔥 SEM SUAVIZAÇÃO                     ║")
print("║                                        ║")
print("╚════════════════════════════════════════╝")

game.StarterGui:SetCore("SendNotification", {
    Title = "⚡ SNAP AIMBOT";
    Text = IsMobile and "📱 Use o botão!" or "🖱️ Segure botão direito!";
    Duration = 4;
})

if IsMobile then
    print("\n📱 APERTE O BOTÃO VERMELHO para ativar!")
else
    print("\n🖱️ SEGURE O BOTÃO DIREITO DO MOUSE!")
end

print("🔥 AIMBOT SNAP - COLA INSTANTÂNEO NA CABEÇA!\n")

return Settings
