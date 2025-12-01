--[[
    ═══════════════════════════════════════════════════════
    AIMBOT ULTRA AGRESSIVO - MOBILE + PC
    PUXA 100% CRAVADO - ATÉ ATRAVÉS DE PAREDES
    ═══════════════════════════════════════════════════════
]]

repeat wait() until game:IsLoaded()

if _G.AimbotLoaded then
    return warn("❌ Já está rodando!")
end
_G.AimbotLoaded = true

-- ═══════════════════════════════════════════════════════
-- SERVIÇOS
-- ═══════════════════════════════════════════════════════

local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local UserInputService = game:GetService("UserInputService")
local Workspace = game:GetService("Workspace")
local Camera = Workspace.CurrentCamera
local LocalPlayer = Players.LocalPlayer

-- Detectar Mobile
local IsMobile = UserInputService.TouchEnabled and not UserInputService.KeyboardEnabled

-- ═══════════════════════════════════════════════════════
-- CONFIGURAÇÕES
-- ═══════════════════════════════════════════════════════

local Config = {
    -- ATIVAÇÃO
    Enabled = false,
    AutoLock = true, -- TRUE = Sempre ativo quando encontrar alvo
    
    -- ALVO
    AimPart = "Head", -- "Head", "HumanoidRootPart", "UpperTorso"
    
    -- FORÇA (0-1)
    LockPower = 1, -- 1 = TRAVA INSTANTÂNEA E TOTAL
    
    -- FOV
    FOV = 500, -- Grande para pegar alvos longe
    ShowFOV = true,
    
    -- VERIFICAÇÕES
    TeamCheck = true,
    WallCheck = false, -- FALSE = PUXA ATÉ ATRAVÉS DE PAREDES
    AliveCheck = true,
    
    -- PREDIÇÃO
    Prediction = true,
    PredictAmount = 0.133,
    
    -- DISTÂNCIA
    MaxDistance = 1000, -- Studs máximos
    
    -- MOBILE
    MobileButton = true, -- Mostrar botão na tela (Mobile)
}

-- ═══════════════════════════════════════════════════════
-- VARIÁVEIS
-- ═══════════════════════════════════════════════════════

local Target = nil
local FOVCircle = nil
local MobileButton = nil
local Locked = false

-- ═══════════════════════════════════════════════════════
-- CRIAR FOV CIRCLE (PC)
-- ═══════════════════════════════════════════════════════

if Drawing and not IsMobile then
    pcall(function()
        FOVCircle = Drawing.new("Circle")
        FOVCircle.Thickness = 2
        FOVCircle.NumSides = 100
        FOVCircle.Radius = Config.FOV
        FOVCircle.Filled = false
        FOVCircle.Visible = Config.ShowFOV
        FOVCircle.Color = Color3.fromRGB(255, 0, 0)
        FOVCircle.Transparency = 1
    end)
end

-- ═══════════════════════════════════════════════════════
-- CRIAR BOTÃO MOBILE
-- ═══════════════════════════════════════════════════════

if IsMobile and Config.MobileButton then
    local ScreenGui = Instance.new("ScreenGui")
    ScreenGui.Name = "AimbotMobile"
    ScreenGui.ResetOnSpawn = false
    ScreenGui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
    
    local Button = Instance.new("TextButton")
    Button.Name = "AimbotButton"
    Button.Parent = ScreenGui
    Button.BackgroundColor3 = Color3.fromRGB(255, 0, 0)
    Button.BorderSizePixel = 0
    Button.Position = UDim2.new(0.85, 0, 0.5, 0)
    Button.Size = UDim2.new(0, 80, 0, 80)
    Button.Font = Enum.Font.GothamBold
    Button.Text = "OFF"
    Button.TextColor3 = Color3.fromRGB(255, 255, 255)
    Button.TextSize = 20
    Button.TextWrapped = true
    
    -- Arredondar cantos
    local Corner = Instance.new("UICorner")
    Corner.CornerRadius = UDim.new(0, 12)
    Corner.Parent = Button
    
    -- Stroke
    local Stroke = Instance.new("UIStroke")
    Stroke.Color = Color3.fromRGB(255, 255, 255)
    Stroke.Thickness = 3
    Stroke.Parent = Button
    
    -- Função do botão
    Button.MouseButton1Click:Connect(function()
        Config.Enabled = not Config.Enabled
        Locked = Config.Enabled
        
        if Config.Enabled then
            Button.Text = "ON"
            Button.BackgroundColor3 = Color3.fromRGB(0, 255, 0)
            Stroke.Color = Color3.fromRGB(0, 255, 0)
        else
            Button.Text = "OFF"
            Button.BackgroundColor3 = Color3.fromRGB(255, 0, 0)
            Stroke.Color = Color3.fromRGB(255, 255, 255)
        end
    end)
    
    -- Arrastar botão
    local dragging = false
    local dragInput, mousePos, framePos
    
    Button.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.Touch then
            dragging = true
            mousePos = input.Position
            framePos = Button.Position
            
            input.Changed:Connect(function()
                if input.UserInputState == Enum.UserInputState.End then
                    dragging = false
                end
            end)
        end
    end)
    
    Button.InputChanged:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.Touch then
            dragInput = input
        end
    end)
    
    UserInputService.InputChanged:Connect(function(input)
        if input == dragInput and dragging then
            local delta = input.Position - mousePos
            Button.Position = UDim2.new(
                framePos.X.Scale,
                framePos.X.Offset + delta.X,
                framePos.Y.Scale,
                framePos.Y.Offset + delta.Y
            )
        end
    end)
    
    -- Parent para CoreGui (não é deletado ao morrer)
    pcall(function()
        ScreenGui.Parent = game:GetService("CoreGui")
    end)
    
    if not ScreenGui.Parent then
        ScreenGui.Parent = LocalPlayer:WaitForChild("PlayerGui")
    end
    
    MobileButton = Button
end

-- ═══════════════════════════════════════════════════════
-- FUNÇÕES
-- ═══════════════════════════════════════════════════════

-- Validar alvo
local function IsValid(player)
    if not player or player == LocalPlayer then return false end
    
    local char = player.Character
    if not char then return false end
    
    if Config.AliveCheck then
        local hum = char:FindFirstChildOfClass("Humanoid")
        if not hum or hum.Health <= 0 then return false end
    end
    
    if Config.TeamCheck and player.Team == LocalPlayer.Team then
        return false
    end
    
    return true
end

-- Pegar alvo mais próximo
local function GetTarget()
    local closest = nil
    local shortestDist = Config.MaxDistance
    
    for _, player in pairs(Players:GetPlayers()) do
        if IsValid(player) then
            local char = player.Character
            local part = char:FindFirstChild(Config.AimPart)
            
            if not part then
                part = char:FindFirstChild("Head") or char:FindFirstChild("HumanoidRootPart")
            end
            
            if part then
                local distance = (part.Position - Camera.CFrame.Position).Magnitude
                
                if distance < shortestDist then
                    -- Verificar se está na tela
                    local _, onScreen = Camera:WorldToViewportPoint(part.Position)
                    
                    if onScreen then
                        shortestDist = distance
                        closest = player
                    end
                end
            end
        end
    end
    
    return closest
end

-- LOCK TOTAL NO ALVO
local function LockTarget()
    if not Locked then return end
    if not Target or not Target.Character then 
        Target = nil
        return 
    end
    
    local part = Target.Character:FindFirstChild(Config.AimPart)
    if not part then
        part = Target.Character:FindFirstChild("Head")
    end
    if not part then return end
    
    -- Posição do alvo
    local targetPos = part.Position
    
    -- PREDIÇÃO
    if Config.Prediction then
        local velocity = part.AssemblyLinearVelocity or Vector3.new(0,0,0)
        targetPos = targetPos + (velocity * Config.PredictAmount)
    end
    
    -- TRAVAR CAMERA TOTALMENTE
    Camera.CFrame = CFrame.new(Camera.CFrame.Position, targetPos)
end

-- Atualizar FOV
local function UpdateFOV()
    if FOVCircle then
        pcall(function()
            local mouse = UserInputService:GetMouseLocation()
            FOVCircle.Position = mouse
            FOVCircle.Visible = Config.ShowFOV and Config.Enabled
            FOVCircle.Radius = Config.FOV
        end)
    end
end

-- ═══════════════════════════════════════════════════════
-- LOOP PRINCIPAL
-- ═══════════════════════════════════════════════════════

RunService.RenderStepped:Connect(function()
    UpdateFOV()
    
    if Config.Enabled or (Config.AutoLock and Locked) then
        -- Atualizar alvo a cada frame
        Target = GetTarget()
        
        -- Travar no alvo
        if Target then
            LockTarget()
        end
    end
end)

-- ═══════════════════════════════════════════════════════
-- CONTROLES PC
-- ═══════════════════════════════════════════════════════

if not IsMobile then
    -- Botão direito para ativar
    UserInputService.InputBegan:Connect(function(input, processed)
        if processed then return end
        
        -- Botão direito
        if input.UserInputType == Enum.UserInputType.MouseButton2 then
            Locked = true
            Config.Enabled = true
        end
        
        -- E para toggle
        if input.KeyCode == Enum.KeyCode.E then
            Config.Enabled = not Config.Enabled
            Locked = Config.Enabled
            print("🎯 AIMBOT:", Config.Enabled and "✅ ON" or "❌ OFF")
        end
        
        -- T para trocar parte
        if input.KeyCode == Enum.KeyCode.T then
            local parts = {"Head", "HumanoidRootPart", "UpperTorso"}
            local current = table.find(parts, Config.AimPart) or 1
            Config.AimPart = parts[(current % #parts) + 1]
            print("🎯 Mirando:", Config.AimPart)
        end
        
        -- F para FOV
        if input.KeyCode == Enum.KeyCode.F then
            Config.ShowFOV = not Config.ShowFOV
        end
    end)
    
    UserInputService.InputEnded:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton2 then
            Locked = false
            Config.Enabled = false
        end
    end)
end

-- ═══════════════════════════════════════════════════════
-- COMANDOS NO CHAT
-- ═══════════════════════════════════════════════════════

LocalPlayer.Chatted:Connect(function(msg)
    msg = msg:lower()
    
    if msg == "/aim" or msg == "/aimbot" then
        Config.Enabled = not Config.Enabled
        Locked = Config.Enabled
        
        if MobileButton then
            MobileButton.Text = Config.Enabled and "ON" or "OFF"
            MobileButton.BackgroundColor3 = Config.Enabled and Color3.fromRGB(0, 255, 0) or Color3.fromRGB(255, 0, 0)
        end
        
        print("🎯 AIMBOT:", Config.Enabled and "✅ ON" or "❌ OFF")
        
    elseif msg == "/head" then
        Config.AimPart = "Head"
        print("🎯 Alvo: CABEÇA")
        
    elseif msg == "/body" then
        Config.AimPart = "HumanoidRootPart"
        print("🎯 Alvo: CORPO")
        
    elseif msg == "/chest" or msg == "/torso" then
        Config.AimPart = "UpperTorso"
        print("🎯 Alvo: PEITO")
        
    elseif msg:sub(1, 4) == "/fov" then
        local fov = tonumber(msg:sub(6))
        if fov then
            Config.FOV = fov
            print("🎯 FOV:", fov)
        end
    end
end)

-- ═══════════════════════════════════════════════════════
-- INICIALIZAÇÃO
-- ═══════════════════════════════════════════════════════

print("╔════════════════════════════════════════╗")
print("║  🎯 AIMBOT ULTRA AGRESSIVO - ATIVO 🎯 ║")
print("╠════════════════════════════════════════╣")
print("║                                        ║")

if IsMobile then
    print("║  📱 MODO MOBILE ATIVADO                ║")
    print("║                                        ║")
    print("║  🔴 Use o BOTÃO na tela                ║")
    print("║  📍 Arraste para mover o botão         ║")
else
    print("║  🖥️ MODO PC ATIVADO                    ║")
    print("║                                        ║")
    print("║  • BOTÃO DIREITO - Ativar              ║")
    print("║  • E - Toggle ON/OFF                   ║")
    print("║  • T - Trocar parte                    ║")
    print("║  • F - Toggle FOV                      ║")
end

print("║                                        ║")
print("║  💬 COMANDOS NO CHAT:                  ║")
print("║  /aim - Toggle                         ║")
print("║  /head - Mirar cabeça                  ║")
print("║  /body - Mirar corpo                   ║")
print("║  /fov 300 - Mudar FOV                  ║")
print("║                                        ║")
print("║  ⚠️ WALLCHECK: DESATIVADO              ║")
print("║  🔥 PUXA ATÉ ATRAVÉS DE PAREDES        ║")
print("║  ⚡ TRAVA 100% INSTANTÂNEA              ║")
print("║                                        ║")
print("╚════════════════════════════════════════╝")

-- Notificação
game:GetService("StarterGui"):SetCore("SendNotification", {
    Title = "🎯 AIMBOT ULTRA";
    Text = IsMobile and "📱 Use o botão na tela!" or "✅ Segure BOTÃO DIREITO";
    Duration = 5;
})

if IsMobile then
    print("\n📱 MOBILE: Aperte o botão VERMELHO na tela para ativar!")
    print("📍 Arraste o botão para mudar de posição!")
else
    print("\n✅ PC: Segure o BOTÃO DIREITO DO MOUSE para travar!")
    print("💡 Digite /aim no chat para ativar permanente!")
end

print("\n🔥 AIMBOT CRAVADO 100% - SEM WALLCHECK - PUXA ATRAVÉS DE TUDO!\n")

-- Retornar configurações
return Config
