local Players = game:GetService("Players")
local UserInputService = game:GetService("UserInputService")
local RunService = game:GetService("RunService")
local player = Players.LocalPlayer
local playerGui = player:WaitForChild("PlayerGui")

-- Список фейковых игроков (можно добавить своих)
local FAKE_PLAYERS = {
    "TbLBOBK9",
    "tilk.dhufiyunteggssxicsny",
    "GirlGame7703",
    "@actboxus350",
    "TkCAnzM320"
}

-- Создаем ScreenGui
local screenGui = Instance.new("ScreenGui")
screenGui.Name = "HighlightGui"
screenGui.Parent = playerGui

-- Создаем кнопку
local button = Instance.new("TextButton")
button.Name = "HighlightButton"
button.Size = UDim2.new(0, 200, 0, 50)
button.Position = UDim2.new(0.5, -100, 0.5, -25) -- Центр экрана
button.BackgroundColor3 = Color3.fromRGB(80, 80, 80)
button.Text = "Подсветить игроков"
button.TextColor3 = Color3.new(1, 1, 1)
button.Font = Enum.Font.SourceSansBold
button.TextSize = 16
button.Parent = screenGui

-- Переменная состояния
local highlighting = false
local highlightParts = {}

-- Функция создания фейк-персонажа
local function createFakeCharacter(playerName)
    local fakeChar = Instance.new("Model")
    fakeChar.Name = playerName
    
    local humanoidRootPart = Instance.new("Part")
    humanoidRootPart.Name = "HumanoidRootPart"
    humanoidRootPart.Size = Vector3.new(2, 2, 1)
    humanoidRootPart.Position = Vector3.new(math.random(-50, 50), 5, math.random(-50, 50))
    humanoidRootPart.Anchored = true
    humanoidRootPart.CanCollide = false
    humanoidRootPart.Transparency = 1
    humanoidRootPart.Parent = fakeChar
    
    local head = Instance.new("Part")
    head.Name = "Head"
    head.Size = Vector3.new(2, 1, 1)
    head.Position = humanoidRootPart.Position + Vector3.new(0, 1.5, 0)
    head.Anchored = true
    head.CanCollide = false
    head.Transparency = 1
    head.Parent = fakeChar
    
    local humanoid = Instance.new("Humanoid")
    humanoid.Parent = fakeChar
    
    fakeChar.Parent = workspace
    return fakeChar
end

-- Функция подсветки
local function highlightCharacter(char, color)
    if not char then return end
    
    for _, part in ipairs(char:GetDescendants()) do
        if part:IsA("BasePart") then
            if highlighting then
                local highlight = Instance.new("BoxHandleAdornment")
                highlight.Name = "PlayerHighlight"
                highlight.Adornee = part
                highlight.AlwaysOnTop = true
                highlight.ZIndex = 10
                highlight.Size = part.Size * 1.1
                highlight.Color3 = color or Color3.new(1, 0, 0)
                highlight.Transparency = 0.7
                highlight.Parent = part
                table.insert(highlightParts, highlight)
            else
                for _, child in ipairs(part:GetChildren()) do
                    if child.Name == "PlayerHighlight" then
                        child:Destroy()
                    end
                end
            end
        end
    end
end

-- Обработчик кнопки
button.MouseButton1Click:Connect(function()
    highlighting = not highlighting
    button.Text = highlighting and "Отключить подсветку" or "Подсветить игроков"
    
    -- Очищаем предыдущую подсветку
    for _, highlight in ipairs(highlightParts) do
        if highlight then
            highlight:Destroy()
        end
    end
    highlightParts = {}
    
    -- Подсвечиваем реальных игроков
    for _, plr in ipairs(Players:GetPlayers()) do
        if plr.Character then
            highlightCharacter(plr.Character)
        end
        plr.CharacterAdded:Connect(function(char)
            highlightCharacter(char)
        end)
    end
    
    -- Подсвечиваем фейковых игроков
    for _, fakeName in ipairs(FAKE_PLAYERS) do
        local fakeChar = workspace:FindFirstChild(fakeName) or createFakeCharacter(fakeName)
        highlightCharacter(fakeChar, Color3.new(1, 0.5, 0)) -- Оранжевый для фейков
    end
end)

-- Перетаскивание кнопки
local dragging = false
local dragStartPos, buttonStartPos

button.InputBegan:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.MouseButton1 then
        dragging = true
        dragStartPos = Vector2.new(input.Position.X, input.Position.Y)
        buttonStartPos = button.Position
        
        -- Остановка перетаскивания при отпускании кнопки
        local connection
        connection = input.Changed:Connect(function()
            if input.UserInputState == Enum.UserInputState.End then
                dragging = false
                connection:Disconnect()
            end
        end)
    end
end)

UserInputService.InputChanged:Connect(function(input)
    if dragging and input.UserInputType == Enum.UserInputType.MouseMovement then
        local delta = Vector2.new(input.Position.X, input.Position.Y) - dragStartPos
        button.Position = UDim2.new(
            buttonStartPos.X.Scale, 
            buttonStartPos.X.Offset + delta.X,
            buttonStartPos.Y.Scale, 
            buttonStartPos.Y.Offset + delta.Y
        )
    end
end)
