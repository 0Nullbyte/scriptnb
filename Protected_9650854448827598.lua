local engine = loadstring(game:HttpGet("https://raw.githubusercontent.com/Singularity5490/rbimgui-2/main/rbimgui-2.lua"))()

local window1 = engine.new({
    text = "Native BeansBay [1.5.6]",
    size = UDim2.new(0, 300, 0, 600),
})

local tabMisc = window1.new({
    text = " Misc",
})

local tabHitbox = window1.new({
    text = " Hitbox",
})

window1.open()

local RunService = game:GetService("RunService")
local Workspace = game:GetService("Workspace")
local Players = game:GetService("Players")
local UserInputService = game:GetService("UserInputService")

local player = Players.LocalPlayer
local mouse = player:GetMouse()
local tab1 = window1.new({
    text = " Main",
})

local label2 = tab1.new("label", {
    text = "Ayham Scripter",
    color = Color3.new(255, 1, 1),
})



-- ESP Box
local espBoxEnabled = false
local espBoxSwitch = tab1.new("switch", {
    text = "Toggle EspBox",
})
espBoxSwitch.set(false)
espBoxSwitch.event:Connect(function(enabled)
    espBoxEnabled = enabled
    print("EspBox enabled:", espBoxEnabled)
end)

-- Filter Dead
local filterDeadEnabled = false
local filterDeadSwitch = tab1.new("switch", {
    text = "Filter Dead/Logged",
})
filterDeadSwitch.set(false)
filterDeadSwitch.event:Connect(function(enabled)
    filterDeadEnabled = enabled
    print("Filter Dead enabled:", filterDeadEnabled)
end)

-- Rainbow ESP
local rainbowEspEnabled = false
local rainbowEspSwitch = tab1.new("switch", {
    text = "Toggle Rainbow ESP",
})
rainbowEspSwitch.set(false)
rainbowEspSwitch.event:Connect(function(enabled)
    rainbowEspEnabled = enabled
    print("Rainbow ESP enabled:", rainbowEspEnabled)
end)

-- Box Outline
local boxOutlineEnabled = false
local boxOutlineSwitch = tab1.new("switch", {
    text = "Toggle Box Outline",
})
boxOutlineSwitch.set(false)
boxOutlineSwitch.event:Connect(function(enabled)
    boxOutlineEnabled = enabled
    print("Box Outline enabled:", boxOutlineEnabled)
end)

-- Box Fill
local boxFillEnabled = false
local boxFillSwitch = tab1.new("switch", {
    text = "Toggle Box Fill",
})
boxFillSwitch.set(false)
boxFillSwitch.event:Connect(function(enabled)
    boxFillEnabled = enabled
    print("Box Fill enabled:", boxFillEnabled)
end)

local modelPositions = {}

local cachedBeams = {}
local cachedCircles = {}
local cachedAttachments = {}

local function generateRandomString()
    local chars = "abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789"
    local length = math.random(8, 16)
    local result = ""
    for i = 1, length do
        local randNum = math.random(1, #chars)
        result = result .. string.sub(chars, randNum, randNum)
    end
    return result
end

local function encryptValue(value)
    return typeof(value) == "number" and value + math.pi or value
end

local function decryptValue(value)
    return typeof(value) == "number" and value - math.pi or value
end

local function cleanupESP(modelId)
    if cachedBeams[modelId] then
        for _, beam in pairs(cachedBeams[modelId]) do
            beam.Enabled = false
            beam:Remove()
        end
        cachedBeams[modelId] = nil
    end
    if cachedAttachments[modelId] then
        for _, att in pairs(cachedAttachments[modelId]) do
            att:Destroy()
        end
        cachedAttachments[modelId] = nil
    end
    if cachedCircles[modelId] then
        for _, circle in pairs(cachedCircles[modelId]) do
            circle.Visible = false
            circle:Remove()
        end
        cachedCircles[modelId] = nil
    end
end

local function isModelValid(model)
    return model and model:IsA("Model") 
        and model:FindFirstChild("Head") 
        and model:FindFirstChild("HumanoidRootPart")
        and (not filterDeadEnabled or 
            (model:FindFirstChildOfClass("Humanoid") and 
             model:FindFirstChildOfClass("Humanoid").Health > 0))
end

RunService.RenderStepped:Connect(function()
    if espBoxEnabled or nameEspEnabled then
        for _, model in pairs(Workspace:GetChildren()) do
            local success, err = pcall(function()
                if isModelValid(model) then
                    local head = model.Head
                    local rootPart = model.HumanoidRootPart
                    local parts = {
                        "LeftFoot", "LeftHand", "LeftLowerArm", "LeftLowerLeg", "LeftUpperArm", "LeftUpperLeg",
                        "RightFoot", "RightHand", "RightLowerArm", "RightLowerLeg", "RightUpperArm", "RightUpperLeg",
                        "Torso", "Head", "HumanoidRootPart", "LowerTorso"
                    }

                    local minX, minY, maxX, maxY = math.huge, math.huge, -math.huge, -math.huge

                    for _, partName in ipairs(parts) do
                        local part = model:FindFirstChild(partName)
                        if part then
                            local partPosition = part.Position
                            local partScreenPosition, partOnScreen = workspace.CurrentCamera:WorldToViewportPoint(partPosition)
                            if partOnScreen then
                                minX = math.min(minX, partScreenPosition.X)
                                minY = math.min(minY, partScreenPosition.Y)
                                maxX = math.max(maxX, partScreenPosition.X)
                                maxY = math.max(maxY, partScreenPosition.Y)
                            end
                        end
                    end

                    if minX < math.huge and minY < math.huge and maxX > -math.huge and maxY > -math.huge then
                        if filterDeadEnabled then
                            local humanoid = model:FindFirstChildOfClass("Humanoid")
                            if humanoid and humanoid.Health <= 0 then
                                return
                            end

                            local modelId = model:GetDebugId()
                            if not modelPositions[modelId] then
                                modelPositions[modelId] = {position = rootPart.Position, lastMoved = tick()}
                            else
                                if (modelPositions[modelId].position - rootPart.Position).Magnitude < 0.1 then
                                    if tick() - modelPositions[modelId].lastMoved > 5 then
                                        return
                                    end
                                else
                                    modelPositions[modelId].position = rootPart.Position
                                    modelPositions[modelId].lastMoved = tick()
                                end
                            end
                        end

                        if espBoxEnabled then
                            local box = Drawing.new("Square")
                            box.Size = Vector2.new(maxX - minX, maxY - minY)
                            box.Position = Vector2.new(minX, minY)
                            box.Color = rainbowEspEnabled and Color3.fromHSV(tick() % 5 / 5, 1, 1) or Color3.new(1, 1, 1)  -- Rainbow or white color
                            box.Thickness = 1
                            box.Transparency = 1
                            box.Visible = true

                            if boxOutlineEnabled then
                                local outline = Drawing.new("Square")
                                outline.Size = box.Size
                                outline.Position = box.Position
                                outline.Color = Color3.new(0, 0, 0)  
                                outline.Thickness = 3
                                outline.Transparency = 1
                                outline.Visible = true

                                RunService.RenderStepped:Wait()
                                outline:Remove()
                            end

                            if boxFillEnabled then
                                local fill = Drawing.new("Square")
                                fill.Size = box.Size
                                fill.Position = box.Position
                                fill.Color = Color3.new(0, 0, 0)  
                                fill.Transparency = 0.5  
                                fill.Filled = true
                                fill.Visible = true

                                RunService.RenderStepped:Wait()
                                fill:Remove()
                            end

                            RunService.RenderStepped:Wait()
                            box:Remove()
                        end

                        if nameEspEnabled then
                            local playerName = head:FindFirstChild("NameEspGui")
                            if not playerName then
                                playerName = Instance.new("BillboardGui", head)
                                playerName.Name = "NameEspGui"
                                playerName.Size = UDim2.new(0, 200, 0, 50)
                                playerName.StudsOffset = Vector3.new(0, 2, 0)
                                playerName.AlwaysOnTop = true

                                local textLabel = Instance.new("TextLabel", playerName)
                                textLabel.Size = UDim2.new(1, 0, 1, 0)
                                textLabel.BackgroundTransparency = 1
                                textLabel.TextColor3 = rainbowEspEnabled and Color3.fromHSV(tick() % 5 / 5, 1, 1) or Color3.new(1, 1, 1)  -- Rainbow or white color
                                textLabel.TextStrokeTransparency = 0.5
                                textLabel.Text = model.Name
                            else
                                playerName.Tag.TextColor3 = rainbowEspEnabled and Color3.fromHSV(tick() % 5 / 5, 1, 1) or Color3.new(1, 1, 1)  -- Update to rainbow or white color
                            end
                        else
                            local playerName = head:FindFirstChild("NameEspGui")
                            if playerName then
                                playerName:Destroy()
                            end
                        end
                    end
                end
            end)
            if not success then
                cleanupESP(model:GetDebugId())
            end
        end
    end
end)

-- Hitbox Extender
local hitboxExtenderEnabled = false
local hitboxExtenderSwitch = tabHitbox.new("switch", {
    text = "Toggle Hitbox Extender",
})
hitboxExtenderSwitch.set(false)
hitboxExtenderSwitch.event:Connect(function(enabled)
    hitboxExtenderEnabled = enabled
    print("Hitbox Extender enabled:", hitboxExtenderEnabled)
end)

local hitboxSizeX = 1
local hitboxSizeY = 1
local hitboxSizeZ = 1

local hitboxSliderX = tabHitbox.new("slider", {
    text = "Head Hitbox Size X",
    color = Color3.new(0.5, 0.8, 0.5),
    min = 1,
    max = 20,
    value = hitboxSizeX,
    rounding = 1,
})
hitboxSliderX.event:Connect(function(value)
    hitboxSizeX = value
    print("Head Hitbox Size X set to: " .. value)
end)

local hitboxSliderY = tabHitbox.new("slider", {
    text = "Head Hitbox Size Y",
    color = Color3.new(0.5, 0.8, 0.5),
    min = 1,
    max = 20,
    value = hitboxSizeY,
    rounding = 1,
})
hitboxSliderY.event:Connect(function(value)
    hitboxSizeY = value
    print("Head Hitbox Size Y set to: " .. value)
end)

local hitboxSliderZ = tabHitbox.new("slider", {
    text = "Head Hitbox Size Z",
    color = Color3.new(0.5, 0.8, 0.5),
    min = 1,
    max = 20,
    value = hitboxSizeZ,
    rounding = 1,
})
hitboxSliderZ.event:Connect(function(value)
    hitboxSizeZ = value
    print("Head Hitbox Size Z set to: " .. value)
end)

RunService.RenderStepped:Connect(function()
    if hitboxExtenderEnabled then
        for _, model in pairs(Workspace:GetChildren()) do
            if model:IsA("Model") and model:FindFirstChild("Head") then
                local head = model.Head
                local humanoid = model:FindFirstChildOfClass("Humanoid")

                if filterDeadEnabled and humanoid and humanoid.Health <= 0 then
                    return
                end

                head.Size = Vector3.new(hitboxSizeX, hitboxSizeY, hitboxSizeZ)
                head.CanCollide = true  
                head.Massless = false 
            end
        end
    else
        for _, model in pairs(Workspace:GetChildren()) do
            if model:IsA("Model") and model:FindFirstChild("Head") then
                local head = model.Head
                head.Size = Vector3.new(1, 1, 1)  
                head.CanCollide = true 
                head.Massless = false  
            end
        end
    end
end)

local fovValue = 70
local sliderFov = tab1.new("slider", {
    text = "Camera FOV",
    color = Color3.new(0.5, 0.8, 0.5),
    min = 70,
    max = 120,
    value = fovValue,
    rounding = 1,
})
sliderFov.event:Connect(function(value)
    fovValue = value
    print("Camera FOV set to: " .. value)
end)

RunService.RenderStepped:Connect(function()
    workspace.CurrentCamera.FieldOfView = fovValue
end)

local glowHammerEnabled = false
local glowHammerSwitch = tabMisc.new("switch", {
    text = "Toggle GlowHammer",
})
glowHammerSwitch.set(false)
glowHammerSwitch.event:Connect(function(enabled)
    glowHammerEnabled = enabled
    print("GlowHammer enabled:", glowHammerEnabled)
end)

RunService.RenderStepped:Connect(function()
    if glowHammerEnabled then
        local hammerTop = workspace.Const.Ignore.Hammer:FindFirstChild("Top")
        local hammerPart = workspace.Const.Ignore.Hammer:FindFirstChild("Part")

        if hammerTop then
            hammerTop.Material = Enum.Material.Neon
            hammerTop.Color = Color3.fromHSV(tick() % 5 / 5, 1, 1)
        end

        if hammerPart then
            hammerPart.Material = Enum.Material.Neon
            hammerPart.Color = Color3.fromHSV(tick() % 5 / 5, 1, 1)
        end
    else
        local hammerTop = workspace.Const.Ignore.Hammer:FindFirstChild("Top")
        local hammerPart = workspace.Const.Ignore.Hammer:FindFirstChild("Part")

        if hammerTop then
            hammerTop.Material = Enum.Material.Plastic
            hammerTop.Color = Color3.new(1, 1, 1)  
        end

        if hammerPart then
            hammerPart.Material = Enum.Material.Plastic
            hammerPart.Color = Color3.new(1, 1, 1)  
        end
    end
end)

local crosshairEnabled = false

local crosshairSwitch = tabMisc.new("switch", {
    text = "Toggle Crosshair",
})
crosshairSwitch.set(false)
crosshairSwitch.event:Connect(function(enabled)
    crosshairEnabled = enabled
    print("Crosshair enabled:", crosshairEnabled)

    local playerGui = game:GetService("Players").LocalPlayer.PlayerGui
    local controllerMouse = playerGui:FindFirstChild("GameUI") and playerGui.GameUI:FindFirstChild("ControllerMouse")
    
    if controllerMouse then
        controllerMouse.Visible = enabled
        if enabled then
            controllerMouse.Text = game:GetService("Players").LocalPlayer.Name 
        end
    end
end)

local nameEspEnabled = false
local nameEspSwitch = tab1.new("switch", {
    text = "Toggle Name ESP [Broken]",
})
nameEspSwitch.set(false)
nameEspSwitch.event:Connect(function(enabled)
    nameEspEnabled = enabled
    print("Name ESP enabled:", nameEspEnabled)
    
    if not enabled then
        for _, model in pairs(Workspace:GetChildren()) do
            if model:IsA("Model") and model:FindFirstChild("Head") then
                local head = model.Head
                if head:FindFirstChild("ESP") then
                    head.ESP:Destroy()
                end
            end
        end
    end
end)

local function updateNameEsp(model)
    if not model:IsA("Model") or not model:FindFirstChild("Head") then
        return
    end

    local head = model.Head

    if head:FindFirstChild("ESP") then
        head.ESP:Destroy()
    end

    if nameEspEnabled then
        local espGui = Instance.new("BillboardGui")
        espGui.Name = "ESP"
        espGui.Parent = head
        espGui.Size = UDim2.new(4, 0, 1.5, 0) 
        espGui.StudsOffset = Vector3.new(0, 3, 0) 
        espGui.AlwaysOnTop = true
        espGui.Adornee = head
        espGui.MaxDistance = 1000 

        local tag = Instance.new("TextLabel")
        tag.Name = "Tag"
        tag.Parent = espGui
        tag.Size = UDim2.new(1, 0, 1, 0)
        tag.BackgroundTransparency = 1
        tag.TextStrokeTransparency = 0.5
        tag.TextStrokeColor3 = Color3.new(0, 0, 0)
        tag.TextColor3 = rainbowEspEnabled and Color3.fromHSV(tick() % 5 / 5, 1, 1) or Color3.new(1, 1, 1)  -- Rainbow or white color
        tag.TextSize = 18
        tag.Font = Enum.Font.GothamBold

        local playerNameTag = head:FindFirstChild("ESP") and head.ESP:FindFirstChild("Tag")
        tag.Text = playerNameTag and playerNameTag.Text or model.Name
    end
end

RunService.RenderStepped:Connect(function()
    if nameEspEnabled then
        for _, model in pairs(Workspace:GetChildren()) do
            if model:IsA("Model") and model:FindFirstChild("Head") and model:FindFirstChild("HumanoidRootPart") then
                local head = model.Head
                if filterDeadEnabled then
                    local humanoid = model:FindFirstChildOfClass("Humanoid")
                    if humanoid and humanoid.Health <= 0 then
                        if head:FindFirstChild("ESP") then
                            head.ESP.Enabled = false
                        end
                        return
                    end
                end

                if not head:FindFirstChild("ESP") then
                    updateNameEsp(model)
                else
                    local esp = head.ESP
                    esp.Enabled = true
                    esp.Tag.TextColor3 = rainbowEspEnabled and Color3.fromHSV(tick() % 5 / 5, 1, 1) or Color3.new(1, 1, 1)
                    local playerNameTag = head:FindFirstChild("ESP") and head.ESP:FindFirstChild("Tag")
                    esp.Tag.Text = playerNameTag and playerNameTag.Text or model.Name
                end
            end
        end
    end
end)

local function updatePlayerNameTags()
    for index, model in pairs(Workspace:GetChildren()) do
        if model:IsA("Model") and model:FindFirstChild("Head") and model:FindFirstChild("HumanoidRootPart") then
            local head = model.Head
            if head:FindFirstChild("ESP") and head.ESP:FindFirstChild("Tag") then
                local espTag = head.ESP.Tag
                print("Player Model Index:", index, "Player Name:", espTag.Text)
            else
                warn("ESP or Tag not found for player model at index:", index)
            end
        end
    end
end

updatePlayerNameTags()
for _, model in pairs(Workspace:GetChildren()) do
    if model:IsA("Model") and model:FindFirstChild("Head") and model:FindFirstChild("HumanoidRootPart") then
        print("Players found")
    end
end

local function getPlayerFromModel(model)
    for _, player in ipairs(Players:GetPlayers()) do
        if player.Character and player.Character == model then
            return player
        end
    end
    return nil
end

local function encryptText(text)
    local encrypted = ""
    for i = 1, #text do
        local char = string.byte(text, i)
        encrypted = encrypted .. string.char(char + 3)  
    end
    return encrypted
end

local function updateNameEsp(model)
    if not model:IsA("Model") or not model:FindFirstChild("Head") then
        return
    end

    local head = model.Head
    if head:FindFirstChild("ESP") then
        head.ESP:Destroy()
    end

    if nameEspEnabled then
        local espGui = Instance.new("BillboardGui")
        espGui.Name = "ESP"
        espGui.Parent = head
        espGui.Size = UDim2.new(4, 0, 1.5, 0)
        espGui.StudsOffset = Vector3.new(0, 3, 0)
        espGui.AlwaysOnTop = true
        espGui.Adornee = head
        espGui.MaxDistance = 1000

        local tag = Instance.new("TextLabel")
        tag.Name = "Tag"
        tag.Parent = espGui
        tag.Size = UDim2.new(1, 0, 1, 0)
        tag.BackgroundTransparency = 1
        tag.TextStrokeTransparency = 0.5
        tag.TextStrokeColor3 = Color3.new(0, 0, 0)
        tag.TextColor3 = Color3.new(1, 1, 1)
        tag.TextSize = 18
        tag.Font = Enum.Font.GothamBold

        local player = getPlayerFromModel(model)
        tag.Text = encryptText(player and player.Name or model.Name)
    end
end

RunService.RenderStepped:Connect(function()
    if nameEspEnabled then
        for _, model in pairs(Workspace:GetChildren()) do
            if model:IsA("Model") and model:FindFirstChild("Head") and model:FindFirstChild("HumanoidRootPart") then
                local head = model.Head

                if filterDeadEnabled then
                    local humanoid = model:FindFirstChildOfClass("Humanoid")
                    if humanoid and humanoid.Health <= 0 then
                        if head:FindFirstChild("ESP") then
                            head.ESP.Enabled = false
                        end
                        return
                    end
                end

                if not head:FindFirstChild("ESP") then
                    updateNameEsp(model)
                else
                    local esp = head.ESP
                    esp.Enabled = true
                    esp.Tag.TextColor3 = rainbowEspEnabled and Color3.fromHSV(tick() % 5 / 5, 1, 1) or Color3.new(1, 1, 1)
                    
                    local player = getPlayerFromModel(model)
                    esp.Tag.Text = encryptText(player and player.Name or model.Name)
                end
            end
        end
    end
end)

workspace.ChildRemoved:Connect(function(child)
    if child:IsA("Model") then
        local modelId = child:GetDebugId()
        cleanupESP(modelId)
    end
end)

game:GetService("Players").PlayerRemoving:Connect(function(player)
    if player.Character then
        local modelId = player.Character:GetDebugId()
        cleanupESP(modelId)
    end
end)

workspace.DescendantRemoving:Connect(function(descendant)
    if descendant:IsA("Humanoid") then
        local model = descendant.Parent
        if model then
            local modelId = model:GetDebugId()
            cleanupESP(modelId)
        end
    end
end)

game:GetService("Players").PlayerRemoving:Connect(function(player)
    local model = player.Character
    if model then
        local modelId = model:GetDebugId()
        if cachedBeams[modelId] then
            for _, beam in pairs(cachedBeams[modelId]) do
                beam:Destroy()
            end
            for _, att in pairs(cachedAttachments[modelId]) do
                att:Destroy()
            end
            for _, circle in pairs(cachedCircles[modelId]) do
                circle:Remove()
            end
            cachedBeams[modelId] = nil
            cachedAttachments[modelId] = nil
            cachedCircles[modelId] = nil
        end
    end
end)


