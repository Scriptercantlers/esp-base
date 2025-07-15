local Players = game:GetService("Players")
local RunService = game:GetService("RunService")

-- Настройки
local MAX_DISTANCE = 3000 -- Максимальная дистанция отображения (3000 studs)
local UPDATE_INTERVAL = 0.2 -- Интервал обновления дистанции

-- Создаем кнопку
local screenGui = Instance.new("ScreenGui")
screenGui.Name = "HighlightGUI"
screenGui.Parent = game.Players.LocalPlayer:WaitForChild("PlayerGui")

local button = Instance.new("TextButton")
button.Name = "HighlightButton"
button.Size = UDim2.new(0, 200, 0, 50)
button.Position = UDim2.new(0.5, -100, 0.5, -25)
button.Text = "Подсветить игроков"
button.BackgroundColor3 = Color3.new(0.2, 0.2, 0.8)
button.TextColor3 = Color3.new(1, 1, 1)
button.Font = Enum.Font.SourceSansBold
button.TextSize = 18
button.Parent = screenGui

-- Таблица для хранения подключений
local connections = {}

-- Функция для создания метки с ником и дистанцией
local function createNameTag(character, name, isPlayer)
	local billboardGui = Instance.new("BillboardGui")
	billboardGui.Name = "NameTag"
	billboardGui.Adornee = character:FindFirstChild("Head") or character:WaitForChild("Head", 5)
	billboardGui.Size = UDim2.new(0, 200, 0, 50)
	billboardGui.StudsOffset = Vector3.new(0, 2.5, 0)
	billboardGui.AlwaysOnTop = true
	billboardGui.LightInfluence = 1
	billboardGui.MaxDistance = MAX_DISTANCE
	billboardGui.Parent = character

	local textLabel = Instance.new("TextLabel")
	textLabel.Name = "TagLabel"
	textLabel.Size = UDim2.new(1, 0, 0.6, 0)
	textLabel.BackgroundTransparency = 1
	textLabel.Text = name
	textLabel.TextColor3 = isPlayer and Color3.new(1, 1, 1) or Color3.new(1, 0.5, 0.5)
	textLabel.Font = Enum.Font.SourceSansBold
	textLabel.TextSize = 20
	textLabel.TextStrokeTransparency = 0.5
	textLabel.TextStrokeColor3 = Color3.new(0, 0, 0)
	textLabel.Parent = billboardGui

	-- Лейбл для дистанции (красный с четкой обводкой)
	local distanceLabel = Instance.new("TextLabel")
	distanceLabel.Name = "DistanceLabel"
	distanceLabel.Size = UDim2.new(1, 0, 0.4, 0)
	distanceLabel.Position = UDim2.new(0, 0, 0.6, 0)
	distanceLabel.BackgroundTransparency = 1
	distanceLabel.Text = "0 studs"
	distanceLabel.TextColor3 = Color3.new(1, 0.3, 0.3) -- Ярко-красный
	distanceLabel.Font = Enum.Font.SourceSansBold
	distanceLabel.TextSize = 18
	distanceLabel.TextStrokeTransparency = 0.2 -- Четкая обводка
	distanceLabel.TextStrokeColor3 = Color3.new(0, 0, 0) -- Черная обводка
	distanceLabel.Parent = billboardGui

	return billboardGui
end

-- Функция для обновления дистанции
local function updateDistanceTags(localPlayer)
	if not localPlayer.Character or not localPlayer.Character:FindFirstChild("HumanoidRootPart") then
		return
	end

	local localRoot = localPlayer.Character.HumanoidRootPart
	local localPosition = localRoot.Position

	-- Для игроков
	for _, player in ipairs(Players:GetPlayers()) do
		if player ~= localPlayer and player.Character then
			local humanoidRoot = player.Character:FindFirstChild("HumanoidRootPart")
			local nameTag = player.Character:FindFirstChild("NameTag")

			if humanoidRoot and nameTag then
				local distance = (humanoidRoot.Position - localPosition).Magnitude
				local distanceLabel = nameTag:FindFirstChild("DistanceLabel")
				if distanceLabel then
					if distance <= MAX_DISTANCE then
						distanceLabel.Text = string.format("%.0f studs", distance)
						nameTag.Enabled = true
					else
						nameTag.Enabled = false
					end
				end
			end
		end
	end

	-- Для ботов/NPC
	for _, descendant in ipairs(workspace:GetDescendants()) do
		if descendant:IsA("Model") and descendant:FindFirstChildOfClass("Humanoid") and not Players:GetPlayerFromCharacter(descendant) then
			local humanoidRoot = descendant:FindFirstChild("HumanoidRootPart")
			local nameTag = descendant:FindFirstChild("NameTag")

			if humanoidRoot and nameTag then
				local distance = (humanoidRoot.Position - localPosition).Magnitude
				local distanceLabel = nameTag:FindFirstChild("DistanceLabel")
				if distanceLabel then
					if distance <= MAX_DISTANCE then
						distanceLabel.Text = string.format("%.0f studs", distance)
						nameTag.Enabled = true
					else
						nameTag.Enabled = false
					end
				end
			end
		end
	end
end

-- Функция для подсветки персонажей
local function highlightCharacters(enable, localPlayer)
	-- Очищаем предыдущие подключения
	for _, connection in pairs(connections) do
		connection:Disconnect()
	end
	connections = {}

	if enable then
		-- Подключение для обновления дистанции
		connections.distanceUpdate = RunService.Heartbeat:Connect(function()
			updateDistanceTags(localPlayer)
		end)
	end

	-- Обработка игроков
	for _, player in ipairs(Players:GetPlayers()) do
		if player.Character then
			local humanoid = player.Character:FindFirstChildOfClass("Humanoid")
			if humanoid then
				-- Подсветка
				local highlight = player.Character:FindFirstChild("PlayerHighlight")
				if enable then
					if not highlight then
						highlight = Instance.new("Highlight")
						highlight.Name = "PlayerHighlight"
						highlight.FillColor = Color3.new(1, 0, 0)
						highlight.OutlineColor = Color3.new(1, 0, 0)
						highlight.Parent = player.Character
					end

					-- Метка с ником
					if not player.Character:FindFirstChild("NameTag") then
						createNameTag(player.Character, player.Name, true)
					end
				else
					if highlight then highlight:Destroy() end
					local tag = player.Character:FindFirstChild("NameTag")
					if tag then tag:Destroy() end
				end
			end
		end

		if enable then
			connections[player] = player.CharacterAdded:Connect(function(character)
				task.wait(1)
				local humanoid = character:WaitForChildOfClass("Humanoid")
				local highlight = Instance.new("Highlight")
				highlight.Name = "PlayerHighlight"
				highlight.FillColor = Color3.new(1, 0, 0)
				highlight.OutlineColor = Color3.new(1, 0, 0)
				highlight.Parent = character

				createNameTag(character, player.Name, true)
			end)
		end
	end

	-- Обработка ботов/NPC
	for _, descendant in ipairs(workspace:GetDescendants()) do
		if descendant:IsA("Model") and descendant:FindFirstChildOfClass("Humanoid") and not Players:GetPlayerFromCharacter(descendant) then
			local highlight = descendant:FindFirstChild("NPC_Highlight")
			if enable then
				if not highlight then
					highlight = Instance.new("Highlight")
					highlight.Name = "NPC_Highlight"
					highlight.FillColor = Color3.new(1, 0.5, 0.5)
					highlight.OutlineColor = Color3.new(1, 0.5, 0.5)
					highlight.Parent = descendant
				end

				if not descendant:FindFirstChild("NameTag") then
					local npcName = descendant.Name
					if descendant:FindFirstChild("DisplayName") then
						npcName = descendant.DisplayName.Value
					end
					createNameTag(descendant, npcName, false)
				end
			else
				if highlight then highlight:Destroy() end
				local tag = descendant:FindFirstChild("NameTag")
				if tag then tag:Destroy() end
			end
		end
	end

	if enable then
		connections.botAdded = workspace.DescendantAdded:Connect(function(descendant)
			if descendant:IsA("Model") and descendant:FindFirstChildOfClass("Humanoid") and not Players:GetPlayerFromCharacter(descendant) then
				task.wait(1)

				local highlight = Instance.new("Highlight")
				highlight.Name = "NPC_Highlight"
				highlight.FillColor = Color3.new(1, 0.5, 0.5)
				highlight.OutlineColor = Color3.new(1, 0.5, 0.5)
				highlight.Parent = descendant

				local npcName = descendant.Name
				if descendant:FindFirstChild("DisplayName") then
					npcName = descendant.DisplayName.Value
				end
				createNameTag(descendant, npcName, false)
			end
		end)
	end
end

-- Обработчик кнопки
local isHighlighted = false
local localPlayer = Players.LocalPlayer
button.MouseButton1Click:Connect(function()
	isHighlighted = not isHighlighted

	if isHighlighted then
		button.Text = "перестать подсвечивать далбаебов"
		highlightCharacters(true, localPlayer)
	else
		button.Text = "подсвети далбаебов"
		highlightCharacters(false, localPlayer)
	end
end)

-- Инициализация
if isHighlighted then
	for _, player in ipairs(Players:GetPlayers()) do
		if player.Character then
			local highlight = Instance.new("Highlight")
			highlight.Name = "PlayerHighlight"
			highlight.FillColor = Color3.new(1, 0, 0)
			highlight.OutlineColor = Color3.new(1, 0, 0)
			highlight.Parent = player.Character

			createNameTag(player.Character, player.Name, true)
		end
	end
end

-- Переменные для перетаскивания кнопки
local dragging = false
local dragStartPos, buttonStartPos

-- Функция начала перетаскивания
local function startDrag(input)
	if input.UserInputType == Enum.UserInputType.MouseButton1 then
		dragging = true
		dragStartPos = Vector2.new(input.Position.X, input.Position.Y)
		buttonStartPos = button.Position

		-- Обработчик окончания перетаскивания
		local connection
		connection = input.Changed:Connect(function()
			if input.UserInputState == Enum.UserInputState.End then
				dragging = false
				connection:Disconnect()
			end
		end)
	end
end

-- Подключение обработчиков
button.InputBegan:Connect(startDrag)

game:GetService("UserInputService").InputChanged:Connect(function(input)
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
