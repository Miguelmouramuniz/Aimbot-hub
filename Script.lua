--[[
    ═══════════════════════════════════════════════════════
    Auto Lock Headshot v3.0 - Delta Executor FIXED
    ═══════════════════════════════════════════════════════
]]

-- Aguardar jogo carregar
repeat task.wait() until game:IsLoaded()

-- Verificar dupla execução
if _G.DeltaAimbotLoaded then
    warn("[Delta] Script já está rodando!")
    return
end
_G.DeltaAimbotLoaded = true

-- ═══════════════════════════════════════════════════════
-- SERVICES
-- ═══════════════════════════════════════════════════════

local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local UserInputService = game:GetService("UserInputService")
local Workspace = game:GetService("Workspace")

local Camera = Workspace.CurrentCamera
local LocalPlayer = Players.LocalPlayer
local Mouse = LocalPlayer:GetMouse()

-- ═══════════════════════════════════════════════════════
-- BYPASS ANTI-CHEAT (SIMPLIFICADO)
-- ═══════════════════════════════════════════════════════

local function SetupBypass()
    local success, err = pcall(function()
        local mt = getrawmetatable(game)
        local oldNamecall = mt.__namecall
        
        setreadonly(mt, false)
        
        mt.__namecall = newcclosure(function(self, ...)
            local method = getnamecallmethod()
            local args = {...}
            
            -- Bloquear reports/kicks
            if method == "FireServer" or method == "InvokeServer" then
                local remoteName = tostring(self)
                if remoteName:match("Ban") or remoteName:match("Kick") or 
                   remoteName:match("Report") or remoteName:match("Flag") then
                    return
                end
            end
            
            return oldNamecall(self, ...)
        end)
        
        setreadonly(mt, true)
    end)
    
    if not success then
        warn("[Delta Bypass] Falhou:", err)
    end
end

pcall(SetupBypass)

-- ═══════════════════════════════════════════════════════
-- CONFIGURAÇÕES
-- ═══════════════════════════════════════════════════════

_G.AimbotConfig = {
    -- Básico
    Enabled = false,
    TeamCheck = true,
    VisibleCheck = true,
    
    -- Alvo
    TargetPart = "Head", -- Head, UpperTorso, HumanoidRootPart
    
    -- FOV
    FOVEnabled = true,
    FOVSize = 100,
    ShowFOV = true,
    
    -- Suavização
    Smoothing = true,
    Smoothness = 0.2, -- 0 = instant, 1 = muito suave
    
    -- Predição
    Prediction = true,
    PredictionAmount = 0.12,
    
    -- Anti-Ban
    Humanize = true,
    MissChance = 0.08, -- 8% chance de errar
    RandomDelay = true,
    MinDelay = 0.02,
    MaxDelay = 0.06,
    MaxLockTime = 3.0,
    Shake = 0.15,
}

local Config = _G.AimbotConfig

-- ═══════════════════════════════════════════════════════
-- VARIÁVEIS
-- ═══════════════════════════════════════════════════════

local FOVCircle
local CurrentTarget
local IsActive = false
local LockStartTime = 0
local LastTarget = nil

-- ═══════════════════════════════════════════════════════
-- FUNÇÕES FOV
-- ═══════════════════════════════════════════════════════

local function CreateFOV()
    -- Verificar se Drawing existe
    if not Drawing then
        warn("[Delta] Drawing API não disponível - FOV desabilitado")
        Config.ShowFOV = false
        return
    end
    
    local success = pcall(function()
        FOVCircle = Drawing.new("Circle")
        FOVCircle.Visible = Config.ShowFOV
        FOVCircle.Thickness = 2
        FOVCircle.Color = Color3.fromRGB(255, 255, 255)
        FOVCircle.Transparency = 1
        FOVCircle.Radius = Config.FOVSize
        FOVCircle.Filled = false
        FOVCircle.NumSides = 64
        FOVCircle.Position = Vector2.new(Camera.ViewportSize.X / 2, Camera.ViewportSize.Y / 2)
    end)
    
    if not success then
        warn("[Delta] Erro ao criar FOV")
        Config.ShowFOV = false
    end
end

local function UpdateFOV()
    if not FOVCircle then return end
    
    pcall(function()
        local mouseLocation = UserInputService:GetMouseLocation()
        FOVCircle.Position = mouseLocation
        FOVCircle.Radius = Config.FOVSize
        FOVCircle.Visible = Config.ShowFOV and Config.Enabled
    end)
end

-- ═══════════════════════════════════════════════════════
-- FUNÇÕES DE VALIDAÇÃO
-- ═══════════════════════════════════════════════════════

local function IsAlive(player)
    if not player or not player.Character then return false end
    
    local humanoid = player.Character:FindFirstChildOfClass("Humanoid")
    return humanoid and humanoid.Health > 0
end

local function IsVisible(targetPart)
    if not Config.VisibleCheck then return true end
    
    local character = LocalPlayer.Character
    if not character then return false end
    
    local origin = Camera.CFrame.Position
    local direction = (targetPart.Position - origin)
    
    local params = RaycastParams.new()
    params.FilterDescendantsInstances = {character, targetPart.Parent}
    params.FilterType = Enum.RaycastFilterType.Blacklist
    
    local result = Workspace:Raycast(origin, direction, params)
    
    return not result or result.Instance:IsDescendantOf(targetPart.Parent)
end

local function IsValidTarget(player)
    if player == LocalPlayer then return false end
    if not IsAlive(player) then return false end
    
    if Config.TeamCheck then
        if player.Team == LocalPlayer.Team then
            return false
        end
    end
    
    return true
end

-- ═══════════════════════════════════════════════════════
-- SISTEMA DE MIRA
-- ═══════════════════════════════════════════════════════

local function GetPredictedPosition(part)
    if not Config.Prediction then
        return part.Position
    end
    
    local velocity = part.AssemblyLinearVelocity or Vector3.new(0, 0, 0)
    return part.Position + (velocity * Config.PredictionAmount)
end

local function ApplyHumanization(position)
    if not Config.Humanize then return position end
    
    -- Adicionar shake
    if Config.Shake > 0 then
        local shake = Vector3.new(
            (math.random() - 0.5) * Config.Shake,
            (math.random() - 0.5) * Config.Shake,
            (math.random() - 0.5) * Config.Shake
        )
        position = position + shake
    end
    
    -- Miss chance
    if Config.MissChance > 0 then
        if math.random() < Config.MissChance then
            local missOffset = Vector3.new(
                (math.random() - 0.5) * 2,
                (math.random() - 0.5) * 2,
                0
            )
            position = position + missOffset
        end
    end
    
    return position
end

local function GetBestTarget()
    local bestTarget = nil
    local bestDistance = math.huge
    
    for _, player in ipairs(Players:GetPlayers()) do
        if IsValidTarget(player) then
            local character = player.Character
            if character then
                local part = character:FindFirstChild(Config.TargetPart)
                
                if not part then
                    part = character:FindFirstChild("Head")
                end
                
                if part then
                    -- Verificar se está na tela
                    local screenPos, onScreen = Camera:WorldToViewportPoint(part.Position)
                    
                    if onScreen then
                        -- Calcular distância do mouse
                        local mousePos = UserInputService:GetMouseLocation()
                        local distance = (Vector2.new(screenPos.X, screenPos.Y) - mousePos).Magnitude
                        
                        -- Verificar FOV
                        if Config.FOVEnabled and distance > Config.FOVSize then
                            continue
                        end
                        
                        -- Verificar visibilidade
                        if not IsVisible(part) then
                            continue
                        end
                        
                        if distance < bestDistance then
                            bestDistance = distance
                            bestTarget = player
                        end
                    end
                end
            end
        end
    end
    
    return bestTarget
end

local function AimAt(target)
    if not target or not target.Character then return end
    
    local part = target.Character:FindFirstChild(Config.TargetPart)
    if not part then
        part = target.Character:FindFirstChild("Head")
    end
    if not part then return end
    
    -- Anti-Ban: Verificar tempo de lock
    if Config.Humanize then
        if LastTarget ~= target then
            LockStartTime = tick()
            LastTarget = target
        elseif tick() - LockStartTime > Config.MaxLockTime then
            -- Forçar cooldown
            task.wait(0.3)
            LockStartTime = tick()
        end
    end
    
    -- Calcular posição
    local targetPos = GetPredictedPosition(part)
    targetPos = ApplyHumanization(targetPos)
    
    local cameraPos = Camera.CFrame.Position
    local lookAt = CFrame.new(cameraPos, targetPos)
    
    -- Aplicar suavização
    if Config.Smoothing then
        Camera.CFrame = Camera.CFrame:Lerp(lookAt, 1 - Config.Smoothness)
    else
        Camera.CFrame = lookAt
    end
    
    -- Delay natural
    if Config.Humanize and Config.RandomDelay then
        local delay = math.random(Config.MinDelay * 100, Config.MaxDelay * 100) / 100
        task.wait(delay)
    end
end

-- ═══════════════════════════════════════════════════════
-- LOOP PRINCIPAL
-- ═══════════════════════════════════════════════════════

local function MainLoop()
    UpdateFOV()
    
    if Config.Enabled and IsActive then
        CurrentTarget = GetBestTarget()
        if CurrentTarget then
            AimAt(CurrentTarget)
        end
    end
end

-- Conectar loop
local connection = RunService.RenderStepped:Connect(MainLoop)

-- ═══════════════════════════════════════════════════════
-- CONTROLES
-- ═══════════════════════════════════════════════════════

UserInputService.InputBegan:Connect(function(input, gameProcessed)
    if gameProcessed then return end
    
    -- Botão direito do mouse
    if input.UserInputType == Enum.UserInputType.MouseButton2 then
        IsActive = true
        Config.Enabled = true
    end
    
    -- Toggle com E
    if input.KeyCode == Enum.KeyCode.E then
        Config.Enabled = not Config.Enabled
        IsActive = Config.Enabled
        
        local msg = Config.Enabled and "✅ AIMBOT ON" or "❌ AIMBOT OFF"
        print("[Delta]", msg)
        
        game.StarterGui:SetCore("SendNotification", {
            Title = "Delta Aimbot";
            Text = msg;
            Duration = 2;
        })
    end
    
    -- Trocar parte com T
    if input.KeyCode == Enum.KeyCode.T then
        local parts = {"Head", "UpperTorso", "HumanoidRootPart"}
        local current = table.find(parts, Config.TargetPart) or 1
        Config.TargetPart = parts[(current % #parts) + 1]
        
        print("[Delta] Alvo:", Config.TargetPart)
        game.StarterGui:SetCore("SendNotification", {
            Title = "Delta Aimbot";
            Text = "Alvo: " .. Config.TargetPart;
            Duration = 2;
        })
    end
    
    -- Toggle FOV com F
    if input.KeyCode == Enum.KeyCode.F then
        Config.ShowFOV = not Config.ShowFOV
        print("[Delta] FOV:", Config.ShowFOV and "ON" or "OFF")
    end
    
    -- Descarregar com Delete
    if input.KeyCode == Enum.KeyCode.Delete then
        print("[Delta] Descarregando...")
        
        connection:Disconnect()
        
        if FOVCircle then
            pcall(function() FOVCircle:Remove() end)
        end
        
        _G.DeltaAimbotLoaded = nil
        _G.AimbotConfig = nil
        
        game.StarterGui:SetCore("SendNotification", {
            Title = "Delta Aimbot";
            Text = "✅ Descarregado!";
            Duration = 2;
        })
        
        print("[Delta] ✅ Descarregado com sucesso!")
    end
end)

UserInputService.InputEnded:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.MouseButton2 then
        IsActive = false
        Config.Enabled = false
    end
end)

-- ═══════════════════════════════════════════════════════
-- INICIALIZAÇÃO
-- ═══════════════════════════════════════════════════════

CreateFOV()

-- Mensagem de carregamento
print("╔════════════════════════════════════════╗")
print("║  🎯 DELTA AIMBOT V3.0 - CARREGADO 🎯  ║")
print("╠════════════════════════════════════════╣")
print("║                                        ║")
print("║  Controles:                            ║")
print("║  • Botão Direito - Ativar              ║")
print("║  • E - Toggle                          ║")
print("║  • T - Trocar Parte                    ║")
print("║  • F - Toggle FOV                      ║")
print("║  • Delete - Descarregar                ║")
print("║                                        ║")
print("║  🛡️ Anti-Ban Ativo                     ║")
print("║                                        ║")
print("╚════════════════════════════════════════╝")

game.StarterGui:SetCore("SendNotification", {
    Title = "🎯 Delta Aimbot";
    Text = "✅ Carregado com sucesso!";
    Duration = 3;
})

print("[Delta] ✅ Script carregado com sucesso!")
print("[Delta] Configurações: _G.AimbotConfig")

-- Retornar configurações
return _G.AimbotConfig
