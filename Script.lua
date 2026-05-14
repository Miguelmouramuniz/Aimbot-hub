--[[ 
    HORIONX HUB V7 - SUPREME EDITION ⚡
    MONITORAMENTO: FPS + PING (ABA VISUAL)
    MELHORIA: ESP BONE + CHECK DE PAREDE + FILTRO DE ARENA
    STATUS: TUDO SOB CONTROLE, MIGUEL! 😈
]]

task.wait(0.5)

local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local UserInputService = game:GetService("UserInputService")
local Lighting = game:GetService("Lighting")
local Stats = game:GetService("Stats")
local Camera = workspace.CurrentCamera
local LocalPlayer = Players.LocalPlayer

local originalMaterials = {}
local originalShadows = Lighting.GlobalShadows

if _G.PainelAtivo then pcall(function() _G.PainelAtivo:Destroy() end) end

_G.Configs = _G.Configs or {
    Aimbot = false, AimLock = false, AimForca = 0.15, DistanciaMax = 350,
    ESP = false, SpinBot = false, SpinVelocidade = 50,
    AntiLag = false, Shaders = false, AntiShakeVisual = false
}

local CC = Lighting:FindFirstChild("HX_CC") or Instance.new("ColorCorrectionEffect", Lighting)
CC.Name = "HX_CC"

-- ==========================================
-- FUNÇÕES DE SUPORTE
-- ==========================================
local function IsVisible(targetPart)
    local ignoreList = {LocalPlayer.Character, targetPart.Parent}
    local parts = Camera:GetPartsObscuringTarget({targetPart.Position}, ignoreList)
    return #parts == 0
end

local function AplicarAntiLag(estado)
    if estado then
        Lighting.GlobalShadows = false
        Lighting.Brightness = 0
        Lighting.FogEnd = 9e9
        for _, v in pairs(workspace:GetDescendants()) do
            if v:IsA("BasePart") and not v:IsDescendantOf(LocalPlayer.Character) then
                if not originalMaterials[v] then originalMaterials[v] = v.Material end
                v.Material = Enum.Material.SmoothPlastic; v.CastShadow = false
            end
        end
    else
        Lighting.GlobalShadows = originalShadows
        Lighting.Brightness = 2
        for part, mat in pairs(originalMaterials) do if part.Parent then part.Material = mat; part.CastShadow = true end end
    end
end

-- ==========================================
-- 1. INTERFACE HORIONX (ESTRUTURA ORIGINAL)
-- ==========================================
local Screen = Instance.new("ScreenGui", game:GetService("CoreGui")); Screen.Name = "Horionx_Supreme"; _G.PainelAtivo = Screen

local OpenBtn = Instance.new("TextButton", Screen)
OpenBtn.Size = UDim2.new(0, 45, 0, 45); OpenBtn.Position = UDim2.new(0, 15, 0, 15); OpenBtn.BackgroundColor3 = Color3.fromRGB(20, 5, 30); OpenBtn.Text = "VIP"; OpenBtn.TextColor3 = Color3.fromRGB(180, 50, 255); OpenBtn.Font = "GothamBold"; Instance.new("UICorner", OpenBtn).CornerRadius = UDim.new(1, 0); Instance.new("UIStroke", OpenBtn).Color = Color3.fromRGB(138, 43, 226)

local Main = Instance.new("Frame", Screen)
Main.Size = UDim2.new(0, 360, 0, 340); Main.Position = UDim2.new(0.5, -180, 0.5, -170); Main.BackgroundColor3 = Color3.fromRGB(10, 5, 15); Main.Visible = false; Main.Active = true; Main.Draggable = true
Instance.new("UICorner", Main).CornerRadius = UDim.new(0, 12); Instance.new("UIStroke", Main).Color = Color3.fromRGB(138, 43, 226); Instance.new("UIStroke", Main).Thickness = 2

local TopBar = Instance.new("Frame", Main); TopBar.Size = UDim2.new(1, 0, 0, 40); TopBar.BackgroundColor3 = Color3.fromRGB(20, 10, 35); Instance.new("UICorner", TopBar)
local Title = Instance.new("TextLabel", TopBar); Title.Size = UDim2.new(1, -50, 1, 0); Title.Position = UDim2.new(0, 15, 0, 0); Title.BackgroundTransparency = 1; Title.Text = "HORIONX <font color='#8A2BE2'>HUB</font> V7 ⚡"; Title.RichText = true; Title.TextColor3 = Color3.new(1,1,1); Title.Font = "GothamBold"; Title.TextSize = 16; Title.TextXAlignment = "Left"

local CloseBtn = Instance.new("TextButton", TopBar); CloseBtn.Size = UDim2.new(0, 28, 0, 28); CloseBtn.Position = UDim2.new(1, -35, 0, 6); CloseBtn.BackgroundColor3 = Color3.fromRGB(200, 40, 40); CloseBtn.Text = "X"; CloseBtn.TextColor3 = Color3.new(1,1,1); Instance.new("UICorner", CloseBtn)

local TabContainer = Instance.new("Frame", Main); TabContainer.Size = UDim2.new(1, 0, 0, 35); TabContainer.Position = UDim2.new(0, 0, 0, 40); TabContainer.BackgroundColor3 = Color3.fromRGB(15, 10, 25); Instance.new("UIListLayout", TabContainer).FillDirection = "Horizontal"
local Content = Instance.new("Frame", Main); Content.Size = UDim2.new(1, -20, 1, -120); Content.Position = UDim2.new(0, 10, 0, 80); Content.BackgroundTransparency = 1

local function CreateTab(name)
    local btn = Instance.new("TextButton", TabContainer); btn.Size = UDim2.new(0.333, 0, 1, 0); btn.BackgroundColor3 = Color3.fromRGB(15, 10, 25); btn.Text = name; btn.TextColor3 = Color3.fromRGB(150, 150, 150); btn.Font = "GothamSemibold"; btn.BorderSizePixel = 0
    local page = Instance.new("ScrollingFrame", Content); page.Size = UDim2.new(1, 0, 1, 0); page.BackgroundTransparency = 1; page.Visible = false; page.ScrollBarThickness = 0; Instance.new("UIListLayout", page).Padding = UDim.new(0, 8)
    btn.MouseButton1Click:Connect(function()
        for _, v in pairs(Content:GetChildren()) do if v:IsA("ScrollingFrame") then v.Visible = false end end
        for _, v in pairs(TabContainer:GetChildren()) do if v:IsA("TextButton") then v.TextColor3 = Color3.fromRGB(150, 150, 150); v.BackgroundColor3 = Color3.fromRGB(15, 10, 25) end end
        page.Visible = true; btn.TextColor3 = Color3.new(1,1,1); btn.BackgroundColor3 = Color3.fromRGB(40, 15, 65)
    end)
    return page
end

local function CreateToggle(parent, text, key)
    local f = Instance.new("TextButton", parent); f.Size = UDim2.new(1, -10, 0, 35); f.BackgroundColor3 = Color3.fromRGB(25, 15, 40); f.Text = "   " .. text; f.TextColor3 = Color3.new(0.9,0.9,0.9); f.Font = "Gotham"; f.TextXAlignment = "Left"; Instance.new("UICorner", f)
    local ind = Instance.new("Frame", f); ind.Size = UDim2.new(0, 12, 0, 12); ind.Position = UDim2.new(1, -25, 0.5, -6); ind.BackgroundColor3 = _G.Configs[key] and Color3.fromRGB(138, 43, 226) or Color3.fromRGB(50, 20, 60); Instance.new("UICorner", ind)
    f.MouseButton1Click:Connect(function() 
        _G.Configs[key] = not _G.Configs[key] 
        ind.BackgroundColor3 = _G.Configs[key] and Color3.fromRGB(138, 43, 226) or Color3.fromRGB(50, 20, 60)
        if key == "AntiLag" then AplicarAntiLag(_G.Configs[key]) end
        if key == "Shaders" then CC.Enabled = _G.Configs.Shaders; if _G.Configs.Shaders then CC.Saturation = 0.6; CC.Contrast = 0.4 end end
    end)
end

local function CreateSlider(parent, text, min, max, key)
    local f = Instance.new("Frame", parent); f.Size = UDim2.new(1, -10, 0, 45); f.BackgroundColor3 = Color3.fromRGB(25, 15, 40); Instance.new("UICorner", f)
    local l = Instance.new("TextLabel", f); l.Size = UDim2.new(1, -10, 0, 20); l.Position = UDim2.new(0, 10, 0, 2); l.BackgroundTransparency = 1; l.Text = text .. ": " .. (key == "AimForca" and string.format("%.2f", _G.Configs[key]) or _G.Configs[key]); l.TextColor3 = Color3.new(0.8,0.8,0.8); l.Font = "Gotham"; l.TextSize = 12; l.TextXAlignment = "Left"
    local bg = Instance.new("Frame", f); bg.Size = UDim2.new(1, -20, 0, 6); bg.Position = UDim2.new(0, 10, 0, 30); bg.BackgroundColor3 = Color3.fromRGB(40, 40, 40); Instance.new("UICorner", bg)
    local fill = Instance.new("Frame", bg); fill.Size = UDim2.new(math.clamp((_G.Configs[key]-min)/(max-min), 0, 1), 0, 1, 0); fill.BackgroundColor3 = Color3.fromRGB(138, 43, 226); Instance.new("UICorner", fill)
    local btn = Instance.new("TextButton", bg); btn.Size = UDim2.new(1, 0, 1, 0); btn.BackgroundTransparency = 1; btn.Text = ""
    local sliding = false
    btn.InputBegan:Connect(function(i) if i.UserInputType == Enum.UserInputType.MouseButton1 or i.UserInputType == Enum.UserInputType.Touch then sliding = true end end)
    UserInputService.InputEnded:Connect(function(i) if i.UserInputType == Enum.UserInputType.MouseButton1 or i.UserInputType == Enum.UserInputType.Touch then sliding = false end end)
    RunService.RenderStepped:Connect(function()
        if sliding and Main.Visible then
            local p = math.clamp((UserInputService:GetMouseLocation().X - bg.AbsolutePosition.X) / bg.AbsoluteSize.X, 0, 1)
            local v = min + (max - min) * p; if key ~= "AimForca" then v = math.floor(v) end
            _G.Configs[key] = v; l.Text = text .. ": " .. (key == "AimForca" and string.format("%.2f", v) or v); fill.Size = UDim2.new(p, 0, 1, 0)
        end
    end)
end

local TabA = CreateTab("Combate"); local TabV = CreateTab("Visual"); local TabE = CreateTab("Extras")
CreateToggle(TabA, "Aimbot Visível", "Aimbot"); CreateToggle(TabA, "AimLock (Varar)", "AimLock")
CreateSlider(TabA, "Força Suave", 0.01, 1, "AimForca")
CreateSlider(TabA, "Raio Arena", 50, 600, "DistanciaMax")
CreateToggle(TabV, "ESP SKELETON VIP", "ESP"); CreateToggle(TabV, "ANTI-LAG NITRO", "AntiLag"); CreateToggle(TabV, "SHADER RTX", "Shaders")
CreateToggle(TabE, "Anti-Shake", "AntiShakeVisual"); CreateToggle(TabE, "SpinBot", "SpinBot")
CreateSlider(TabE, "Velocidade Spin", 10, 300, "SpinVelocidade")

local StatFrame = Instance.new("Frame", TabV); StatFrame.Size = UDim2.new(1, -10, 0, 30); StatFrame.BackgroundColor3 = Color3.fromRGB(15, 5, 20); Instance.new("UICorner", StatFrame)
local FpsLabel = Instance.new("TextLabel", StatFrame); FpsLabel.Size = UDim2.new(0.5, -10, 1, 0); FpsLabel.Position = UDim2.new(0, 10, 0, 0); FpsLabel.BackgroundTransparency = 1; FpsLabel.Text = "fps: 0"; FpsLabel.TextColor3 = Color3.new(1,1,1); FpsLabel.Font = "Gotham"; FpsLabel.TextSize = 10; FpsLabel.TextXAlignment = "Left"
local PingLabel = Instance.new("TextLabel", StatFrame); PingLabel.Size = UDim2.new(0.5, -10, 1, 0); PingLabel.Position = UDim2.new(0.5, 0, 0, 0); PingLabel.BackgroundTransparency = 1; PingLabel.Text = "ping: 0ms"; PingLabel.TextColor3 = Color3.new(1,1,1); PingLabel.Font = "Gotham"; PingLabel.TextSize = 10; PingLabel.TextXAlignment = "Right"

OpenBtn.MouseButton1Click:Connect(function() Main.Visible = true; OpenBtn.Visible = false end); CloseBtn.MouseButton1Click:Connect(function() Main.Visible = false; OpenBtn.Visible = true end)
TabA.Visible = true

-- ==========================================
-- 2. MOTORES (MELHORADOS)
-- ==========================================
local lastTime = tick(); local frameCount = 0
RunService.Heartbeat:Connect(function()
    frameCount = frameCount + 1
    if tick() - lastTime >= 1 then
        FpsLabel.Text = "fps: " .. frameCount
        PingLabel.Text = "ping: " .. math.floor(Stats.Network.ServerStatsItem["Data Ping"]:GetValue()) .. "ms"
        frameCount = 0; lastTime = tick()
    end

    if _G.Configs.SpinBot and LocalPlayer.Character then
        LocalPlayer.Character.HumanoidRootPart.CFrame = LocalPlayer.Character.HumanoidRootPart.CFrame * CFrame.Angles(0, math.rad(_G.Configs.SpinVelocidade), 0)
    end

    -- ESP BONE E VIDA
    for _, p in pairs(Players:GetPlayers()) do
        if p ~= LocalPlayer and p.Character and p.Character:FindFirstChild("HumanoidRootPart") then
            local char = p.Character
            local esp = char:FindFirstChild("HX_ESP") or Instance.new("Highlight", char); esp.Name = "HX_ESP"
            local dist = (LocalPlayer.Character.HumanoidRootPart.Position - char.HumanoidRootPart.Position).Magnitude
            
            if _G.Configs.ESP and char.Humanoid.Health > 0 and dist <= _G.Configs.DistanciaMax then
                esp.Enabled = true; esp.FillTransparency = 0.5; esp.OutlineColor = Color3.fromRGB(138, 43, 226)
                
                -- Barra de Vida Lateral
                local hum = char:FindFirstChild("Humanoid")
                local bg = char.HumanoidRootPart:FindFirstChild("LifeGui") or Instance.new("BillboardGui", char.HumanoidRootPart)
                bg.Name = "LifeGui"; bg.AlwaysOnTop = true; bg.Size = UDim2.new(4,0,5,0); bg.ExtentsOffset = Vector3.new(2.5, 0, 0)
                local bar = bg:FindFirstChild("Bar") or Instance.new("Frame", bg); bar.Name = "Bar"; bar.Size = UDim2.new(0.15, 0, hum.Health/hum.MaxHealth, 0); bar.Position = UDim2.new(0,0,1-hum.Health/hum.MaxHealth,0); bar.BackgroundColor3 = Color3.new(0,1,0); bar.BorderSizePixel = 0
            else 
                esp.Enabled = false
                if char.HumanoidRootPart:FindFirstChild("LifeGui") then char.HumanoidRootPart.LifeGui:Destroy() end
            end
        end
    end
end)

RunService.RenderStepped:Connect(function()
    local target = nil; local menorDist = _G.Configs.DistanciaMax
    for _, p in pairs(Players:GetPlayers()) do
        if p ~= LocalPlayer and p.Character and p.Character:FindFirstChild("Head") and p.Character.Humanoid.Health > 0 then
            local dist = (LocalPlayer.Character.HumanoidRootPart.Position - p.Character.HumanoidRootPart.Position).Magnitude
            if dist < menorDist then
                local head = p.Character.Head
                if _G.Configs.AimLock then
                    target = head; menorDist = dist
                elseif _G.Configs.Aimbot and IsVisible(head) then
                    target = head; menorDist = dist
                end
            end
        end
    end
    if target then
        if _G.Configs.AimLock then Camera.CFrame = CFrame.new(Camera.CFrame.Position, target.Position)
        elseif _G.Configs.Aimbot then Camera.CFrame = Camera.CFrame:Lerp(CFrame.new(Camera.CFrame.Position, target.Position), _G.Configs.AimForca) end
    end
end)
