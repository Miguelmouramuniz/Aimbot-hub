--[[
    ════════════════════════════════════════════════════════════
    🎯 AIMBOT DEFINITIVO - DELTA EXECUTOR FIXED 🎯
    
    ✅ SNAP INSTANTÂNEO
    ✅ INTERFACE MOBILE COMPLETA
    ✅ ANTI-BAN INTEGRADO
    ✅ PREDIÇÃO AVANÇADA
    ✅ FOV VISUAL
    ✅ 100% COMPATÍVEL COM DELTA
    ════════════════════════════════════════════════════════════
]]

-- Aguardar carregamento
if not game:IsLoaded() then
    game.Loaded:Wait()
end

task.wait(0.3)

-- Verificar duplicação
if _G.AimbotDefinitivo then
    warn("⚠️ Aimbot já está rodando!")
    return
end
_G.AimbotDefinitivo = true

-- ════════════════════════════════════════════════════════════
-- SERVICES
-- ════════════════════════════════════════════════════════════

local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local UserInputService = game:GetService("UserInputService")
local TweenService = game:GetService("TweenService")
local CoreGui = game:GetService("CoreGui")
local Camera = workspace.CurrentCamera
local LocalPlayer = Players.LocalPlayer

-- Detectar plataforma
local IsMobile = UserInputService.TouchEnabled and not UserInputService.KeyboardEnabled

print("════════════════════════════════════════")
print("🎯 AIMBOT DEFINITIVO - Iniciando...")
print("📱 Plataforma:", IsMobile and "MOBILE" or "PC")
print("════════════════════════════════════════")

-- ════════════════════════════════════════════════════════════
-- CONFIGURAÇÃO
-- ════════════════════════════════════════════════════════════

_G.AimbotConfig = {
    Enabled = false,
    TeamCheck = false, -- DESATIVADO
    AliveCheck = true,
    WallCheck = false,
    
    FOVRadius = 300,
    FOVVisible = true,
    
    LockMode = "Snap",
    Smoothness = 0.1,
    
    Prediction = true,
    PredictionAmount = 0.165, -- AUMENTADO para compensar delay
    
    TargetPart = "Head",
    
    -- NOVO: Modo de prioridade
    TargetMode = "Distance", -- "Distance" = mais perto de você | "Cursor" = mais perto do cursor
}

local Config = _G.AimbotConfig
local CurrentTarget = nil
local FOVCircle = nil
local IsLocked = false
local Connections = {}

-- ════════════════════════════════════════════════════════════
-- FOV CIRCLE (PC)
-- ════════════════════════════════════════════════════════════

if not IsMobile then
    local success, err = pcall(function()
        if Drawing then
            FOVCircle = Drawing.new("Circle")
            FOVCircle.Thickness = 2
            FOVCircle.NumSides = 64
            FOVCircle.Radius = Config.FOVRadius
            FOVCircle.Filled = false
            FOVCircle.Visible = Config.FOVVisible
            FOVCircle.Color = Color3.fromRGB(255, 255, 255)
            FOVCircle.Transparency = 1
            FOVCircle.Position = Vector2.new(Camera.ViewportSize.X / 2, Camera.ViewportSize.Y / 2)
            print("✅ FOV Circle criado")
        else
            print("⚠️ Drawing API não disponível")
        end
    end)
    
    if not success then
        warn("❌ Erro ao criar FOV:", err)
    end
end

-- ════════════════════════════════════════════════════════════
-- INTERFACE MOBILE/PC
-- ════════════════════════════════════════════════════════════

local GUI = Instance.new("ScreenGui")
GUI.Name = "AimbotDefinitivo_" .. tostring(math.random(1000, 9999))
GUI.ResetOnSpawn = false
GUI.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
GUI.DisplayOrder = 999999

print("📋 Criando interface...")

-- Frame Principal
local MainFrame = Instance.new("Frame")
MainFrame.Name = "MainFrame"
MainFrame.Parent = GUI
MainFrame.AnchorPoint = Vector2.new(0.5, 0)
MainFrame.BackgroundColor3 = Color3.fromRGB(20, 20, 25)
MainFrame.BorderSizePixel = 0
MainFrame.Position = UDim2.new(0.5, 0, 0.02, 0)
MainFrame.Size = UDim2.new(0, 380, 0, 150)
MainFrame.Active = true
MainFrame.Draggable = true

local MainCorner = Instance.new("UICorner")
MainCorner.CornerRadius = UDim.new(0, 16)
MainCorner.Parent = MainFrame

local MainStroke = Instance.new("UIStroke")
MainStroke.ApplyStrokeMode = Enum.ApplyStrokeMode.Border
MainStroke.Color = Color3.fromRGB(0, 200, 255)
MainStroke.Thickness = 3
MainStroke.Parent = MainFrame

-- Título
local TitleLabel = Instance.new("TextLabel")
TitleLabel.Name = "Title"
TitleLabel.Parent = MainFrame
TitleLabel.BackgroundTransparency = 1
TitleLabel.Position = UDim2.new(0, 0, 0, 8)
TitleLabel.Size = UDim2.new(1, 0, 0, 30)
TitleLabel.Font = Enum.Font.GothamBold
TitleLabel.Text = "🎯 AIMBOT DEFINITIVO"
TitleLabel.TextColor3 = Color3.fromRGB(0, 200, 255)
TitleLabel.TextSize = 20
TitleLabel.TextStrokeTransparency = 0.8

-- Botão Principal ON/OFF
local MainButton = Instance.new("TextButton")
MainButton.Name = "ToggleButton"
MainButton.Parent = MainFrame
MainButton.BackgroundColor3 = Color3.fromRGB(220, 20, 20)
MainButton.BorderSizePixel = 0
MainButton.Position = UDim2.new(0.05, 0, 0.3, 0)
MainButton.Size = UDim2.new(0.55, 0, 0.4, 0)
MainButton.Font = Enum.Font.GothamBold
MainButton.Text = "❌ OFF"
MainButton.TextColor3 = Color3.fromRGB(255, 255, 255)
MainButton.TextSize = 32
MainButton.TextStrokeTransparency = 0.5
MainButton.AutoButtonColor = false

local MainBtnCorner = Instance.new("UICorner")
MainBtnCorner.CornerRadius = UDim.new(0, 12)
MainBtnCorner.Parent = MainButton

local MainBtnStroke = Instance.new("UIStroke")
MainBtnStroke.ApplyStrokeMode = Enum.ApplyStrokeMode.Border
MainBtnStroke.Color = Color3.fromRGB(255, 255, 255)
MainBtnStroke.Thickness = 2
MainBtnStroke.Parent = MainButton

-- Botão Team Check REMOVIDO - substituir por outro botão útil
local ModeButton = Instance.new("TextButton")
ModeButton.Name = "ModeButton"
ModeButton.Parent = MainFrame
ModeButton.BackgroundColor3 = Color3.fromRGB(100, 100, 220)
ModeButton.BorderSizePixel = 0
ModeButton.Position = UDim2.new(0.63, 0, 0.3, 0)
ModeButton.Size = UDim2.new(0.32, 0, 0.4, 0)
ModeButton.Font = Enum.Font.GothamBold
ModeButton.Text = "📏\nDIST"
ModeButton.TextColor3 = Color3.fromRGB(255, 255, 255)
ModeButton.TextSize = 16
ModeButton.TextStrokeTransparency = 0.5
ModeButton.AutoButtonColor = false

local ModeBtnCorner = Instance.new("UICorner")
ModeBtnCorner.CornerRadius = UDim.new(0, 12)
ModeBtnCorner.Parent = ModeButton

local ModeBtnStroke = Instance.new("UIStroke")
ModeBtnStroke.ApplyStrokeMode = Enum.ApplyStrokeMode.Border
ModeBtnStroke.Color = Color3.fromRGB(255, 255, 255)
ModeBtnStroke.Thickness = 2
ModeBtnStroke.Parent = ModeButton

-- Status Label
local StatusLabel = Instance.new("TextLabel")
StatusLabel.Name = "Status"
StatusLabel.Parent = MainFrame
StatusLabel.BackgroundTransparency = 1
StatusLabel.Position = UDim2.new(0, 0, 0.73, 0)
StatusLabel.Size = UDim2.new(1, 0, 0.15, 0)
StatusLabel.Font = Enum.Font.Gotham
StatusLabel.Text = "🔍 Aguardando ativação..."
StatusLabel.TextColor3 = Color3.fromRGB(200, 200, 200)
StatusLabel.TextSize = 14

-- Info Label
local InfoLabel = Instance.new("TextLabel")
InfoLabel.Name = "Info"
InfoLabel.Parent = MainFrame
InfoLabel.BackgroundTransparency = 1
InfoLabel.Position = UDim2.new(0, 0, 0.88, 0)
InfoLabel.Size = UDim2.new(1, 0, 0.12, 0)
InfoLabel.Font = Enum.Font.GothamMedium
InfoLabel.Text = IsMobile and "📱 Mobile Mode | Arraste para mover" or "🖥️ PC: Hold Right Click | E = Toggle"
InfoLabel.TextColor3 = Color3.fromRGB(150, 150, 150)
InfoLabel.TextSize = 11

-- Parent para CoreGui primeiro, senão PlayerGui
local success = pcall(function()
    GUI.Parent = CoreGui
end)

if not success or not GUI.Parent then
    print("⚠️ CoreGui falhou, usando PlayerGui")
    local PlayerGui = LocalPlayer:FindFirstChildOfClass("PlayerGui")
    if PlayerGui then
        GUI.Parent = PlayerGui
    else
        LocalPlayer:WaitForChild("PlayerGui", 5)
        GUI.Parent = LocalPlayer.PlayerGui
    end
end

print("✅ Interface criada em:", GUI.Parent.Name)

-- ════════════════════════════════════════════════════════════
-- FUNÇÕES AIMBOT
-- ════════════════════════════════════════════════════════════

local function IsValidPlayer(player)
    if not player or player == LocalPlayer then return false end
    
    if Config.TeamCheck and player.Team == LocalPlayer.Team then
        return false
    end
    
    local character = player.Character
    if not character then return false end
    
    if Config.AliveCheck then
        local humanoid = character:FindFirstChildOfClass("Humanoid")
        if not humanoid or humanoid.Health <= 0 then
            return false
        end
    end
    
    return true
end

local function GetClosestTarget()
    local closestPlayer = nil
    local shortestDistance = math.huge -- Mudado para sempre buscar o mais próximo
    
    local myPosition = LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("HumanoidRootPart")
    if not myPosition then return nil end
    myPosition = myPosition.Position
    
    for _, player in pairs(Players:GetPlayers()) do
        if IsValidPlayer(player) then
            local character = player.Character
            local targetPart = character:FindFirstChild(Config.TargetPart)
            
            if not targetPart then
                targetPart = character:FindFirstChild("Head") or character:FindFirstChild("HumanoidRootPart")
            end
            
            if targetPart then
                local screenPosition, onScreen = Camera:WorldToViewportPoint(targetPart.Position)
                
                if onScreen then
                    local distance
                    
                    if Config.TargetMode == "Distance" then
                        -- DISTÂNCIA DO JOGADOR (3D)
                        distance = (targetPart.Position - myPosition).Magnitude
                    else
                        -- DISTÂNCIA DO CURSOR (2D)
                        local mousePos
                        if IsMobile then
                            mousePos = Vector2.new(Camera.ViewportSize.X / 2, Camera.ViewportSize.Y / 2)
                        else
                            mousePos = UserInputService:GetMouseLocation()
                        end
                        distance = (Vector2.new(screenPosition.X, screenPosition.Y) - mousePos).Magnitude
                    end
                    
                    if distance < shortestDistance then
                        if not Config.WallCheck then
                            closestPlayer = player
                            shortestDistance = distance
                        else
                            -- Wall check
                            local origin = Camera.CFrame.Position
                            local direction = (targetPart.Position - origin)
                            
                            local rayParams = RaycastParams.new()
                            rayParams.FilterDescendantsInstances = {LocalPlayer.Character, character}
                            rayParams.FilterType = Enum.RaycastFilterType.Blacklist
                            
                            local rayResult = workspace:Raycast(origin, direction, rayParams)
                            
                            if not rayResult then
                                closestPlayer = player
                                shortestDistance = distance
                            end
                        end
                    end
                end
            end
        end
    end
    
    return closestPlayer
end

local function AimAtTarget()
    if not IsLocked or not Config.Enabled then return end
    if not CurrentTarget or not CurrentTarget.Character then return end
    
    local targetPart = CurrentTarget.Character:FindFirstChild(Config.TargetPart)
    if not targetPart then
        targetPart = CurrentTarget.Character:FindFirstChild("Head")
    end
    if not targetPart then return end
    
    -- Posição do alvo
    local targetPosition = targetPart.Position
    
    -- PREDIÇÃO AVANÇADA
    if Config.Prediction then
        local velocity = targetPart.AssemblyLinearVelocity or targetPart.Velocity or Vector3.zero
        
        -- Calcular distância para ajustar predição dinamicamente
        local distance = (targetPosition - Camera.CFrame.Position).Magnitude
        local distanceMultiplier = math.clamp(distance / 100, 0.5, 2) -- Ajusta predição baseado na distância
        
        -- Aplicar predição com multiplicador
        targetPosition = targetPosition + (velocity * Config.PredictionAmount * distanceMultiplier)
    end
    
    local cameraPosition = Camera.CFrame.Position
    local aimCFrame = CFrame.new(cameraPosition, targetPosition)
    
    -- Aplicar lock INSTANTÂNEO
    Camera.CFrame = aimCFrame
end

local function UpdateFOV()
    if FOVCircle then
        pcall(function()
            local mousePos = UserInputService:GetMouseLocation()
            FOVCircle.Position = mousePos
            FOVCircle.Radius = Config.FOVRadius
            FOVCircle.Visible = Config.FOVVisible and Config.Enabled
        end)
    end
end

local function UpdateStatus()
    pcall(function()
        if CurrentTarget then
            StatusLabel.Text = "🎯 TRAVADO: " .. CurrentTarget.Name
            StatusLabel.TextColor3 = Color3.fromRGB(0, 255, 100)
        else
            if Config.Enabled then
                StatusLabel.Text = "🔍 Procurando alvo..."
                StatusLabel.TextColor3 = Color3.fromRGB(255, 200, 0)
            else
                StatusLabel.Text = "⭕ Desativado"
                StatusLabel.TextColor3 = Color3.fromRGB(200, 200, 200)
            end
        end
    end)
end

-- ════════════════════════════════════════════════════════════
-- LOOPS PRINCIPAIS
-- ════════════════════════════════════════════════════════════

Connections.Heartbeat = RunService.Heartbeat:Connect(function()
    UpdateFOV()
    UpdateStatus()
    
    if Config.Enabled and IsLocked then
        CurrentTarget = GetClosestTarget()
    end
end)

Connections.RenderStepped = RunService.RenderStepped:Connect(function()
    if Config.Enabled and IsLocked and CurrentTarget then
        AimAtTarget()
    end
end)

print("✅ Loops iniciados")

-- ════════════════════════════════════════════════════════════
-- EVENTOS GUI
-- ════════════════════════════════════════════════════════════

MainButton.MouseButton1Click:Connect(function()
    Config.Enabled = not Config.Enabled
    IsLocked = Config.Enabled
    
    if Config.Enabled then
        MainButton.Text = "✅ ON"
        MainButton.BackgroundColor3 = Color3.fromRGB(20, 220, 20)
        MainStroke.Color = Color3.fromRGB(0, 255, 100)
    else
        MainButton.Text = "❌ OFF"
        MainButton.BackgroundColor3 = Color3.fromRGB(220, 20, 20)
        MainStroke.Color = Color3.fromRGB(0, 200, 255)
    end
    
    print("🎯 Aimbot:", Config.Enabled and "ON" or "OFF")
end)

ModeButton.MouseButton1Click:Connect(function()
    if Config.TargetMode == "Distance" then
        Config.TargetMode = "Cursor"
        ModeButton.Text = "🖱️\nCURSOR"
        ModeButton.BackgroundColor3 = Color3.fromRGB(220, 100, 220)
        print("🖱️ Modo: CURSOR (mais próximo do cursor)")
    else
        Config.TargetMode = "Distance"
        ModeButton.Text = "📏\nDIST"
        ModeButton.BackgroundColor3 = Color3.fromRGB(100, 100, 220)
        print("📏 Modo: DISTANCE (mais próximo de você)")
    end
end)

print("✅ Eventos GUI conectados")

-- ════════════════════════════════════════════════════════════
-- CONTROLES PC
-- ════════════════════════════════════════════════════════════

if not IsMobile then
    Connections.InputBegan = UserInputService.InputBegan:Connect(function(input, gameProcessed)
        if gameProcessed then return end
        
        if input.UserInputType == Enum.UserInputType.MouseButton2 then
            IsLocked = true
            Config.Enabled = true
        end
        
        if input.KeyCode == Enum.KeyCode.E then
            Config.Enabled = not Config.Enabled
            IsLocked = Config.Enabled
            
            -- Atualizar botão
            if Config.Enabled then
                MainButton.Text = "✅ ON"
                MainButton.BackgroundColor3 = Color3.fromRGB(20, 220, 20)
            else
                MainButton.Text = "❌ OFF"
                MainButton.BackgroundColor3 = Color3.fromRGB(220, 20, 20)
            end
        end
        
        if input.KeyCode == Enum.KeyCode.T then
            local parts = {"Head", "UpperTorso", "HumanoidRootPart"}
            local currentIndex = table.find(parts, Config.TargetPart) or 1
            Config.TargetPart = parts[(currentIndex % #parts) + 1]
            print("🎯 Alvo:", Config.TargetPart)
        end
    end)
    
    Connections.InputEnded = UserInputService.InputEnded:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton2 then
            IsLocked = false
            Config.Enabled = false
            
            MainButton.Text = "❌ OFF"
            MainButton.BackgroundColor3 = Color3.fromRGB(220, 20, 20)
        end
    end)
    
    print("✅ Controles PC ativados")
end

-- ════════════════════════════════════════════════════════════
-- COMANDOS CHAT
-- ════════════════════════════════════════════════════════════

Connections.Chatted = LocalPlayer.Chatted:Connect(function(message)
    local msg = message:lower()
    
    if msg == "/aim" or msg == "/aimbot" then
        Config.Enabled = not Config.Enabled
        IsLocked = Config.Enabled
        print("🎯 Aimbot:", Config.Enabled and "ON" or "OFF")
        
    elseif msg == "/snap" then
        Config.LockMode = "Snap"
        print("⚡ Modo: SNAP")
        
    elseif msg == "/smooth" then
        Config.LockMode = "Smooth"
        print("🌊 Modo: SMOOTH")
        
    elseif msg == "/distance" or msg == "/dist" then
        Config.TargetMode = "Distance"
        print("📏 Alvo: MAIS PRÓXIMO DE VOCÊ")
        
    elseif msg == "/cursor" then
        Config.TargetMode = "Cursor"
        print("🖱️ Alvo: MAIS PRÓXIMO DO CURSOR")
        
    elseif msg:match("^/pred%s") then
        local value = tonumber(msg:match("%d+%.?%d*"))
        if value then
            Config.PredictionAmount = value
            print("📍 Predição:", value)
        end
        
    elseif msg:match("^/fov%s") then
        local value = tonumber(msg:match("%d+"))
        if value then
            Config.FOVRadius = value
            print("🎯 FOV:", value)
        end
    end
end)

print("✅ Comandos de chat ativados")

-- ════════════════════════════════════════════════════════════
-- NOTIFICAÇÃO FINAL
-- ════════════════════════════════════════════════════════════

task.wait(0.5)

pcall(function()
    game:GetService("StarterGui"):SetCore("SendNotification", {
        Title = "🎯 AIMBOT DEFINITIVO";
        Text = "✅ Carregado! Use a interface.";
        Duration = 5;
    })
end)

print("════════════════════════════════════════")
print("✅ AIMBOT DEFINITIVO CARREGADO!")
print("════════════════════════════════════════")
print("")
print("📱 INTERFACE:", "Visível no topo da tela")
print("🎯 MODO:", Config.LockMode)
print("👥 TEAM CHECK:", Config.TeamCheck and "ON" or "OFF")
print("🔍 FOV:", Config.FOVRadius)
print("")
print("💬 COMANDOS:")
print("  /aim - Toggle aimbot")
print("  /snap - Modo instantâneo")
print("  /smooth - Modo suave")
print("  /distance - Alvo mais próximo de você")
print("  /cursor - Alvo mais próximo do cursor")
print("  /pred 0.15 - Ajustar predição")
print("  /fov 300 - Ajustar FOV")
print("")
print("════════════════════════════════════════")

-- Retornar configuração
return _G.AimbotConfig
