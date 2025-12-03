--[[
    ═══════════════════════════════════════════════════════
    ⚡ SPEED SONIC EXE 💥 - NOCLIP + WALK SPEED ⚡
    
    Tema: Roxo com raios pretos
    Interface: Mobile horizontal arrastável
    Animação: Entrada épica com raios
    ═══════════════════════════════════════════════════════
]]

-- Verificar duplicação
if _G.SonicEXESpeed then
    warn("⚠️ Speed Sonic EXE já está rodando!")
    return
end
_G.SonicEXESpeed = true

-- ═══════════════════════════════════════════════════════
-- SERVICES
-- ═══════════════════════════════════════════════════════

local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local TweenService = game:GetService("TweenService")
local UserInputService = game:GetService("UserInputService")

local LocalPlayer = Players.LocalPlayer
local Character = LocalPlayer.Character or LocalPlayer.CharacterAdded:Wait()
local Humanoid = Character:WaitForChild("Humanoid")

-- ═══════════════════════════════════════════════════════
-- CONFIGURAÇÕES
-- ═══════════════════════════════════════════════════════

local Config = {
    DefaultSpeed = 16,
    CurrentSpeed = 16,
    MaxSpeed = 500,
    NoclipEnabled = false,
    SpeedEnabled = false,
}

local Connections = {}

-- ═══════════════════════════════════════════════════════
-- CRIAR GUI
-- ═══════════════════════════════════════════════════════

local ScreenGui = Instance.new("ScreenGui")
ScreenGui.Name = "SonicEXEGui"
ScreenGui.ResetOnSpawn = false
ScreenGui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling

pcall(function()
    ScreenGui.Parent = game:GetService("CoreGui")
end)

if not ScreenGui.Parent then
    ScreenGui.Parent = LocalPlayer:WaitForChild("PlayerGui")
end

-- ═══════════════════════════════════════════════════════
-- FRAME PRINCIPAL - HORIZONTAL
-- ═══════════════════════════════════════════════════════

local MainFrame = Instance.new("Frame")
MainFrame.Name = "MainFrame"
MainFrame.Parent = ScreenGui
MainFrame.AnchorPoint = Vector2.new(0.5, 0.5)
MainFrame.BackgroundColor3 = Color3.fromRGB(40, 0, 60)
MainFrame.BorderSizePixel = 0
MainFrame.Position = UDim2.new(0.5, 0, 0.5, 0)
MainFrame.Size = UDim2.new(0, 500, 0, 180)
MainFrame.Active = true
MainFrame.Draggable = true
MainFrame.ClipsDescendants = true

-- Começar invisível para animação
MainFrame.BackgroundTransparency = 1
MainFrame.Size = UDim2.new(0, 0, 0, 0)

local MainCorner = Instance.new("UICorner")
MainCorner.CornerRadius = UDim.new(0, 20)
MainCorner.Parent = MainFrame

-- Borda com gradiente roxo
local MainStroke = Instance.new("UIStroke")
MainStroke.Color = Color3.fromRGB(150, 0, 255)
MainStroke.Thickness = 4
MainStroke.Transparency = 1
MainStroke.Parent = MainFrame

-- Gradiente roxo
local Gradient = Instance.new("UIGradient")
Gradient.Color = ColorSequence.new{
    ColorSequenceKeypoint.new(0, Color3.fromRGB(60, 0, 100)),
    ColorSequenceKeypoint.new(0.5, Color3.fromRGB(40, 0, 60)),
    ColorSequenceKeypoint.new(1, Color3.fromRGB(20, 0, 40))
}
Gradient.Rotation = 45
Gradient.Parent = MainFrame

-- ═══════════════════════════════════════════════════════
-- EFEITO DE RAIOS (BACKGROUND)
-- ═══════════════════════════════════════════════════════

local function CreateLightning()
    for i = 1, 5 do
        local Lightning = Instance.new("Frame")
        Lightning.Name = "Lightning" .. i
        Lightning.Parent = MainFrame
        Lightning.BackgroundColor3 = Color3.fromRGB(0, 0, 0)
        Lightning.BorderSizePixel = 0
        Lightning.Position = UDim2.new(math.random(0, 100) / 100, 0, 0, 0)
        Lightning.Size = UDim2.new(0, 2, 1, 0)
        Lightning.ZIndex = 0
        Lightning.Rotation = math.random(-5, 5)
        
        -- Animar raios
        spawn(function()
            while Lightning.Parent do
                local tween = TweenService:Create(Lightning, TweenInfo.new(0.1, Enum.EasingStyle.Linear), {
                    BackgroundTransparency = math.random(50, 90) / 100
                })
                tween:Play()
                wait(0.1)
            end
        end)
    end
end

CreateLightning()

-- ═══════════════════════════════════════════════════════
-- TÍTULO COM RAIOS
-- ═══════════════════════════════════════════════════════

local TitleFrame = Instance.new("Frame")
TitleFrame.Name = "TitleFrame"
TitleFrame.Parent = MainFrame
TitleFrame.BackgroundTransparency = 1
TitleFrame.Position = UDim2.new(0, 15, 0, 10)
TitleFrame.Size = UDim2.new(1, -30, 0, 40)

local Title = Instance.new("TextLabel")
Title.Name = "Title"
Title.Parent = TitleFrame
Title.BackgroundTransparency = 1
Title.Size = UDim2.new(1, 0, 1, 0)
Title.Font = Enum.Font.GothamBold
Title.Text = "⚡ SPEED SONIC EXE 💥"
Title.TextColor3 = Color3.fromRGB(255, 50, 255)
Title.TextSize = 24
Title.TextStrokeTransparency = 0.5
Title.TextStrokeColor3 = Color3.fromRGB(0, 0, 0)

-- Efeito de brilho no título
local TitleGlow = Instance.new("TextLabel")
TitleGlow.Name = "TitleGlow"
TitleGlow.Parent = TitleFrame
TitleGlow.BackgroundTransparency = 1
TitleGlow.Position = UDim2.new(0, 2, 0, 2)
TitleGlow.Size = UDim2.new(1, 0, 1, 0)
TitleGlow.Font = Enum.Font.GothamBold
TitleGlow.Text = "⚡ SPEED SONIC EXE 💥"
TitleGlow.TextColor3 = Color3.fromRGB(150, 0, 255)
TitleGlow.TextSize = 24
TitleGlow.TextTransparency = 0.5
TitleGlow.ZIndex = 0

-- Animar brilho
spawn(function()
    while TitleGlow.Parent do
        TweenService:Create(TitleGlow, TweenInfo.new(0.5, Enum.EasingStyle.Sine, Enum.EasingDirection.InOut), {
            TextTransparency = 0.8
        }):Play()
        wait(0.5)
        TweenService:Create(TitleGlow, TweenInfo.new(0.5, Enum.EasingStyle.Sine, Enum.EasingDirection.InOut), {
            TextTransparency = 0.3
        }):Play()
        wait(0.5)
    end
end)

-- ═══════════════════════════════════════════════════════
-- CONTAINER DOS BOTÕES
-- ═══════════════════════════════════════════════════════

local ButtonContainer = Instance.new("Frame")
ButtonContainer.Name = "ButtonContainer"
ButtonContainer.Parent = MainFrame
ButtonContainer.BackgroundTransparency = 1
ButtonContainer.Position = UDim2.new(0, 15, 0, 60)
ButtonContainer.Size = UDim2.new(1, -30, 0, 110)

-- ═══════════════════════════════════════════════════════
-- FUNÇÃO PARA CRIAR BOTÃO COM ESTILO RAIO
-- ═══════════════════════════════════════════════════════

local function CreateLightningButton(name, text, position, color)
    local Button = Instance.new("TextButton")
    Button.Name = name
    Button.Parent = ButtonContainer
    Button.BackgroundColor3 = color
    Button.BorderSizePixel = 0
    Button.Position = position
    Button.Size = UDim2.new(0, 150, 0, 50)
    Button.Font = Enum.Font.GothamBold
    Button.Text = text
    Button.TextColor3 = Color3.fromRGB(255, 255, 255)
    Button.TextSize = 16
    Button.TextStrokeTransparency = 0.5
    Button.AutoButtonColor = false
    
    local BtnCorner = Instance.new("UICorner")
    BtnCorner.CornerRadius = UDim.new(0, 12)
    BtnCorner.Parent = Button
    
    -- Borda estilo raio
    local BtnStroke = Instance.new("UIStroke")
    BtnStroke.Color = Color3.fromRGB(150, 0, 255)
    BtnStroke.Thickness = 3
    BtnStroke.Parent = Button
    
    -- Gradiente
    local BtnGradient = Instance.new("UIGradient")
    BtnGradient.Color = ColorSequence.new{
        ColorSequenceKeypoint.new(0, color),
        ColorSequenceKeypoint.new(1, Color3.new(color.R * 0.7, color.G * 0.7, color.B * 0.7))
    }
    BtnGradient.Rotation = 45
    BtnGradient.Parent = Button
    
    -- Efeito de raio interno
    local LightningEffect = Instance.new("Frame")
    LightningEffect.Name = "Lightning"
    LightningEffect.Parent = Button
    LightningEffect.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
    LightningEffect.BackgroundTransparency = 0.9
    LightningEffect.BorderSizePixel = 0
    LightningEffect.Position = UDim2.new(0, 0, 0, 0)
    LightningEffect.Size = UDim2.new(0, 0, 1, 0)
    
    local LightCorner = Instance.new("UICorner")
    LightCorner.CornerRadius = UDim.new(0, 12)
    LightCorner.Parent = LightningEffect
    
    -- Animação de clique
    Button.MouseButton1Down:Connect(function()
        TweenService:Create(Button, TweenInfo.new(0.1), {
            Size = UDim2.new(0, 145, 0, 48)
        }):Play()
        
        -- Efeito de raio ao clicar
        TweenService:Create(LightningEffect, TweenInfo.new(0.3, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), {
            Size = UDim2.new(1, 0, 1, 0),
            BackgroundTransparency = 1
        }):Play()
    end)
    
    Button.MouseButton1Up:Connect(function()
        TweenService:Create(Button, TweenInfo.new(0.1), {
            Size = UDim2.new(0, 150, 0, 50)
        }):Play()
        
        LightningEffect.Size = UDim2.new(0, 0, 1, 0)
        LightningEffect.BackgroundTransparency = 0.9
    end)
    
    return Button
end

-- ═══════════════════════════════════════════════════════
-- CRIAR BOTÕES
-- ═══════════════════════════════════════════════════════

-- Botão Speed
local SpeedButton = CreateLightningButton(
    "SpeedButton",
    "⚡ SPEED: OFF",
    UDim2.new(0, 0, 0, 0),
    Color3.fromRGB(60, 0, 100)
)

-- Botão Noclip
local NoclipButton = CreateLightningButton(
    "NoclipButton",
    "👻 NOCLIP: OFF",
    UDim2.new(0, 165, 0, 0),
    Color3.fromRGB(80, 0, 120)
)

-- Botão Reset
local ResetButton = CreateLightningButton(
    "ResetButton",
    "🔄 RESET",
    UDim2.new(0, 330, 0, 0),
    Color3.fromRGB(100, 0, 80)
)

-- ═══════════════════════════════════════════════════════
-- CONTROLE DE VELOCIDADE
-- ═══════════════════════════════════════════════════════

local SpeedContainer = Instance.new("Frame")
SpeedContainer.Name = "SpeedContainer"
SpeedContainer.Parent = ButtonContainer
SpeedContainer.BackgroundTransparency = 1
SpeedContainer.Position = UDim2.new(0, 0, 0, 60)
SpeedContainer.Size = UDim2.new(1, 0, 0, 45)

local SpeedLabel = Instance.new("TextLabel")
SpeedLabel.Name = "SpeedLabel"
SpeedLabel.Parent = SpeedContainer
SpeedLabel.BackgroundTransparency = 1
SpeedLabel.Position = UDim2.new(0, 0, 0, 0)
SpeedLabel.Size = UDim2.new(0, 150, 0, 20)
SpeedLabel.Font = Enum.Font.GothamBold
SpeedLabel.Text = "💨 VELOCIDADE: 16"
SpeedLabel.TextColor3 = Color3.fromRGB(255, 255, 255)
SpeedLabel.TextSize = 14
SpeedLabel.TextXAlignment = Enum.TextXAlignment.Left

-- Slider
local SliderBG = Instance.new("Frame")
SliderBG.Name = "SliderBG"
SliderBG.Parent = SpeedContainer
SliderBG.BackgroundColor3 = Color3.fromRGB(20, 0, 40)
SliderBG.BorderSizePixel = 0
SliderBG.Position = UDim2.new(0, 0, 0, 25)
SliderBG.Size = UDim2.new(0, 320, 0, 15)

local SliderCorner = Instance.new("UICorner")
SliderCorner.CornerRadius = UDim.new(1, 0)
SliderCorner.Parent = SliderBG

local SliderStroke = Instance.new("UIStroke")
SliderStroke.Color = Color3.fromRGB(150, 0, 255)
SliderStroke.Thickness = 2
SliderStroke.Parent = SliderBG

local SliderFill = Instance.new("Frame")
SliderFill.Name = "SliderFill"
SliderFill.Parent = SliderBG
SliderFill.BackgroundColor3 = Color3.fromRGB(150, 0, 255)
SliderFill.BorderSizePixel = 0
SliderFill.Size = UDim2.new(0, 0, 1, 0)

local FillCorner = Instance.new("UICorner")
FillCorner.CornerRadius = UDim.new(1, 0)
FillCorner.Parent = SliderFill

-- Gradiente no slider
local SliderGradient = Instance.new("UIGradient")
SliderGradient.Color = ColorSequence.new{
    ColorSequenceKeypoint.new(0, Color3.fromRGB(150, 0, 255)),
    ColorSequenceKeypoint.new(1, Color3.fromRGB(255, 50, 255))
}
SliderGradient.Parent = SliderFill

-- Botões +/-
local MinusBtn = Instance.new("TextButton")
MinusBtn.Name = "MinusBtn"
MinusBtn.Parent = SpeedContainer
MinusBtn.BackgroundColor3 = Color3.fromRGB(80, 0, 120)
MinusBtn.BorderSizePixel = 0
MinusBtn.Position = UDim2.new(0, 330, 0, 25)
MinusBtn.Size = UDim2.new(0, 70, 0, 15)
MinusBtn.Font = Enum.Font.GothamBold
MinusBtn.Text = "➖"
MinusBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
MinusBtn.TextSize = 12

local MinusCorner = Instance.new("UICorner")
MinusCorner.CornerRadius = UDim.new(1, 0)
MinusCorner.Parent = MinusBtn

local PlusBtn = Instance.new("TextButton")
PlusBtn.Name = "PlusBtn"
PlusBtn.Parent = SpeedContainer
PlusBtn.BackgroundColor3 = Color3.fromRGB(80, 0, 120)
PlusBtn.BorderSizePixel = 0
PlusBtn.Position = UDim2.new(0, 410, 0, 25)
PlusBtn.Size = UDim2.new(0, 70, 0, 15)
PlusBtn.Font = Enum.Font.GothamBold
PlusBtn.Text = "➕"
PlusBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
PlusBtn.TextSize = 12

local PlusCorner = Instance.new("UICorner")
PlusCorner.CornerRadius = UDim.new(1, 0)
PlusCorner.Parent = PlusBtn

-- ═══════════════════════════════════════════════════════
-- ANIMAÇÃO DE ENTRADA
-- ═══════════════════════════════════════════════════════

local function PlayIntroAnimation()
    -- Raios aparecem primeiro
    for i = 1, 3 do
        local Lightning = Instance.new("ImageLabel")
        Lightning.Name = "IntroLightning"
        Lightning.Parent = ScreenGui
        Lightning.BackgroundTransparency = 1
        Lightning.Position = UDim2.new(0.5, math.random(-200, 200), 0.5, math.random(-100, 100))
        Lightning.Size = UDim2.new(0, 100, 0, 100)
        Lightning.Image = "rbxasset://textures/ui/GuiImagePlaceholder.png"
        Lightning.ImageColor3 = Color3.fromRGB(150, 0, 255)
        Lightning.ImageTransparency = 1
        Lightning.ZIndex = 10
        
        TweenService:Create(Lightning, TweenInfo.new(0.3), {
            ImageTransparency = 0,
            Rotation = 360
        }):Play()
        
        wait(0.1)
        
        TweenService:Create(Lightning, TweenInfo.new(0.3), {
            ImageTransparency = 1
        }):Play()
        
        game:GetService("Debris"):AddItem(Lightning, 0.6)
    end
    
    wait(0.2)
    
    -- Janela aparece
    TweenService:Create(MainFrame, TweenInfo.new(0.5, Enum.EasingStyle.Back, Enum.EasingDirection.Out), {
        Size = UDim2.new(0, 500, 0, 180),
        BackgroundTransparency = 0
    }):Play()
    
    TweenService:Create(MainStroke, TweenInfo.new(0.5), {
        Transparency = 0
    }):Play()
    
    wait(0.3)
    
    -- Botões aparecem
    for _, button in pairs(ButtonContainer:GetChildren()) do
        if button:IsA("TextButton") or button:IsA("Frame") then
            button.Position = button.Position + UDim2.new(0, -50, 0, 0)
            TweenService:Create(button, TweenInfo.new(0.4, Enum.EasingStyle.Back, Enum.EasingDirection.Out), {
                Position = button.Position + UDim2.new(0, 50, 0, 0)
            }):Play()
            wait(0.1)
        end
    end
end

-- ═══════════════════════════════════════════════════════
-- FUNÇÕES
-- ═══════════════════════════════════════════════════════

local function UpdateSpeedDisplay(speed)
    Config.CurrentSpeed = speed
    SpeedLabel.Text = "💨 VELOCIDADE: " .. math.floor(speed)
    
    local percent = math.min(speed / Config.MaxSpeed, 1)
    TweenService:Create(SliderFill, TweenInfo.new(0.3), {
        Size = UDim2.new(percent, 0, 1, 0)
    }):Play()
end

local function SetSpeed(enabled)
    Config.SpeedEnabled = enabled
    
    if enabled then
        Humanoid.WalkSpeed = Config.CurrentSpeed
        SpeedButton.Text = "⚡ SPEED: ON"
        SpeedButton.BackgroundColor3 = Color3.fromRGB(0, 200, 100)
    else
        Humanoid.WalkSpeed = Config.DefaultSpeed
        SpeedButton.Text = "⚡ SPEED: OFF"
        SpeedButton.BackgroundColor3 = Color3.fromRGB(60, 0, 100)
    end
end

local function SetNoclip(enabled)
    Config.NoclipEnabled = enabled
    
    if enabled then
        Connections.Noclip = RunService.Stepped:Connect(function()
            for _, part in pairs(Character:GetDescendants()) do
                if part:IsA("BasePart") then
                    part.CanCollide = false
                end
            end
        end)
        
        NoclipButton.Text = "👻 NOCLIP: ON"
        NoclipButton.BackgroundColor3 = Color3.fromRGB(0, 200, 100)
    else
        if Connections.Noclip then
            Connections.Noclip:Disconnect()
        end
        
        for _, part in pairs(Character:GetDescendants()) do
            if part:IsA("BasePart") then
                part.CanCollide = true
            end
        end
        
        NoclipButton.Text = "👻 NOCLIP: OFF"
        NoclipButton.BackgroundColor3 = Color3.fromRGB(80, 0, 120)
    end
end

local function ResetAll()
    SetSpeed(false)
    SetNoclip(false)
    UpdateSpeedDisplay(Config.DefaultSpeed)
end

-- ═══════════════════════════════════════════════════════
-- EVENTOS
-- ═══════════════════════════════════════════════════════

SpeedButton.MouseButton1Click:Connect(function()
    SetSpeed(not Config.SpeedEnabled)
end)

NoclipButton.MouseButton1Click:Connect(function()
    SetNoclip(not Config.NoclipEnabled)
end)

ResetButton.MouseButton1Click:Connect(function()
    ResetAll()
end)

MinusBtn.MouseButton1Click:Connect(function()
    local newSpeed = math.max(Config.CurrentSpeed - 10, Config.DefaultSpeed)
    UpdateSpeedDisplay(newSpeed)
    if Config.SpeedEnabled then
        Humanoid.WalkSpeed = newSpeed
    end
end)

PlusBtn.MouseButton1Click:Connect(function()
    local newSpeed = math.min(Config.CurrentSpeed + 10, Config.MaxSpeed)
    UpdateSpeedDisplay(newSpeed)
    if Config.SpeedEnabled then
        Humanoid.WalkSpeed = newSpeed
    end
end)

-- Atualizar speed quando mudar
Connections.SpeedUpdate = RunService.Heartbeat:Connect(function()
    if Config.SpeedEnabled then
        Humanoid.WalkSpeed = Config.CurrentSpeed
    end
end)

-- Reset ao morrer
LocalPlayer.CharacterAdded:Connect(function(char)
    Character = char
    Humanoid = char:WaitForChild("Humanoid")
    ResetAll()
end)

-- ═══════════════════════════════════════════════════════
-- INICIALIZAÇÃO
-- ═══════════════════════════════════════════════════════

UpdateSpeedDisplay(Config.DefaultSpeed)
PlayIntroAnimation()

print("╔════════════════════════════════════════╗")
print("║  ⚡ SPEED SONIC EXE 💥 - ATIVADO ⚡   ║")
print("╠════════════════════════════════════════╣")
print("║                                        ║")
print("║  ⚡ Speed: Velocidade personalizável  ║")
print("║  👻 Noclip: Atravessar paredes        ║")
print("║  🎨 Tema: Roxo com raios pretos       ║")
print("║  📱 Interface: Mobile horizontal       ║")
print("║  ✨ Animação: Entrada épica           ║")
print("║                                        ║")
print("╚════════════════════════════════════════╝")

game:GetService("StarterGui"):SetCore("SendNotification", {
    Title = "⚡ SPEED SONIC EXE 💥";
    Text = "Carregado com sucesso!";
    Duration = 5;
})
