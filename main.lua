local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local Lighting = game:GetService("Lighting")
local TweenService = game:GetService("TweenService")
local LocalPlayer = Players.LocalPlayer
local playerGui = LocalPlayer:WaitForChild("PlayerGui")

-- === TUNGGU ===
repeat task.wait() until LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("HumanoidRootPart")
repeat task.wait() until workspace:FindFirstChild("Ghost")

local root = LocalPlayer.Character.HumanoidRootPart
local ghost = workspace.Ghost

-- === VARIABEL TOGGLE ===
local espEnabled = true
local boxEnabled = true
local tracerEnabled = true
local fullbrightEnabled = false
local guiMinimized = false
local fuseboxESPEnabled = false
local playerESPEnabled = false

-- === ESP OBJECTS ===
local billboard, label, box, attach1, attach2, beam
local fuseboxESPObjects = {}
local playerESPObjects = {}

-- === FULLBRIGHT ===
local originalLighting = {
    Brightness = Lighting.Brightness,
    Ambient = Lighting.Ambient,
    OutdoorAmbient = Lighting.OutdoorAmbient,
    ClockTime = Lighting.ClockTime,
    FogEnd = Lighting.FogEnd,
    GlobalShadows = Lighting.GlobalShadows
}

local function toggleFullbright()
    if fullbrightEnabled then
        Lighting.Brightness = 2
        Lighting.Ambient = Color3.fromRGB(255, 255, 255)
        Lighting.OutdoorAmbient = Color3.fromRGB(255, 255, 255)
        Lighting.ClockTime = 14
        Lighting.FogEnd = 100000
        Lighting.GlobalShadows = false
    else
        Lighting.Brightness = originalLighting.Brightness
        Lighting.Ambient = originalLighting.Ambient
        Lighting.OutdoorAmbient = originalLighting.OutdoorAmbient
        Lighting.ClockTime = originalLighting.ClockTime
        Lighting.FogEnd = originalLighting.FogEnd
        Lighting.GlobalShadows = originalLighting.GlobalShadows
    end
end

-- === CREATE ESP ===
local function createESP()
    if billboard then billboard:Destroy() end
    if box then box:Destroy() end
    if attach1 then attach1:Destroy() end
    if attach2 then attach2:Destroy() end
    if beam then beam:Destroy() end
    
    if not ghost or not ghost.Parent then return end
    
    billboard = Instance.new("BillboardGui", playerGui)
    billboard.Adornee = ghost
    billboard.Size = UDim2.fromOffset(220, 60)
    billboard.StudsOffset = Vector3.new(0, 3.5, 0)
    billboard.AlwaysOnTop = true
    
    label = Instance.new("TextLabel", billboard)
    label.Size = UDim2.fromScale(1,1)
    label.BackgroundTransparency = 1
    label.TextColor3 = Color3.new(1,1,1)
    label.TextStrokeTransparency = 0.7
    label.Font = Enum.Font.GothamBold
    label.TextSize = 16
    
    box = Instance.new("SelectionBox")
    box.Adornee = ghost
    box.LineThickness = 0.1
    box.Transparency = 0.3
    box.Parent = ghost
    
    if root then
        attach1 = Instance.new("Attachment", root)
        attach1.Visible = false
    end
    attach2 = Instance.new("Attachment", ghost)
    attach2.Visible = false
    
    beam = Instance.new("Beam")
    beam.Attachment0 = attach1
    beam.Attachment1 = attach2
    beam.Color = ColorSequence.new(Color3.fromRGB(200, 0, 0))
    beam.Width0 = 0.25
    beam.Width1 = 0.25
    beam.Transparency = NumberSequence.new(0.15)
    beam.FaceCamera = true
    beam.LightEmission = 1
    beam.LightInfluence = 0
    beam.Parent = workspace
end

-- === FUSEBOX ESP ===
local function clearFuseboxESP()
    for _, obj in pairs(fuseboxESPObjects) do
        if obj then obj:Destroy() end
    end
    fuseboxESPObjects = {}
end

local function createFuseboxESP()
    clearFuseboxESP()
    if not fuseboxESPEnabled then return end
    
    local fusebox = workspace:FindFirstChild("FuseBox", true)
    if fusebox and root then
        -- Billboard GUI
        local bb = Instance.new("BillboardGui", playerGui)
        bb.Adornee = fusebox
        bb.Size = UDim2.fromOffset(250, 50)
        bb.StudsOffset = Vector3.new(0, 3, 0)
        bb.AlwaysOnTop = true
        
        local lbl = Instance.new("TextLabel", bb)
        lbl.Size = UDim2.fromScale(1,1)
        lbl.BackgroundTransparency = 1
        lbl.TextColor3 = Color3.fromRGB(255, 255, 0)
        lbl.TextStrokeTransparency = 0.5
        lbl.Font = Enum.Font.GothamBold
        lbl.TextSize = 16
        
        -- Selection Box
        local selBox = Instance.new("SelectionBox")
        selBox.Adornee = fusebox
        selBox.LineThickness = 0.1
        selBox.Color3 = Color3.fromRGB(255, 255, 0)
        selBox.Parent = fusebox
        
        -- Tracer (Beam)
        local attachFusebox = Instance.new("Attachment", fusebox)
        attachFusebox.Visible = false
        
        local attachPlayer = Instance.new("Attachment", root)
        attachPlayer.Visible = false
        
        local fuseboxBeam = Instance.new("Beam")
        fuseboxBeam.Attachment0 = attachPlayer
        fuseboxBeam.Attachment1 = attachFusebox
        fuseboxBeam.Color = ColorSequence.new(Color3.fromRGB(255, 255, 0))
        fuseboxBeam.Width0 = 0.25
        fuseboxBeam.Width1 = 0.25
        fuseboxBeam.Transparency = NumberSequence.new(0.2)
        fuseboxBeam.FaceCamera = true
        fuseboxBeam.LightEmission = 1
        fuseboxBeam.LightInfluence = 0
        fuseboxBeam.Parent = workspace
        
        table.insert(fuseboxESPObjects, bb)
        table.insert(fuseboxESPObjects, selBox)
        table.insert(fuseboxESPObjects, attachFusebox)
        table.insert(fuseboxESPObjects, attachPlayer)
        table.insert(fuseboxESPObjects, fuseboxBeam)
        
        -- Update distance loop
        spawn(function()
            while bb.Parent and fuseboxESPEnabled do
                if fusebox and fusebox.Parent and root then
                    local fuseboxPos = fusebox:IsA("BasePart") and fusebox.Position or (fusebox:IsA("Model") and fusebox.PrimaryPart and fusebox.PrimaryPart.Position)
                    if fuseboxPos then
                        local dist = math.floor((fuseboxPos - root.Position).Magnitude)
                        lbl.Text = string.format("⚡ FUSEBOX | 📏 %d studs", dist)
                    end
                end
                task.wait(0.5)
            end
        end)
    end
end

-- === PLAYER ESP ===
local function clearPlayerESP()
    for _, obj in pairs(playerESPObjects) do
        if obj then obj:Destroy() end
    end
    playerESPObjects = {}
end

local function createPlayerESP()
    clearPlayerESP()
    if not playerESPEnabled then return end
    
    for _, player in pairs(Players:GetPlayers()) do
        if player ~= LocalPlayer and player.Character and player.Character:FindFirstChild("HumanoidRootPart") then
            local char = player.Character
            local hrp = char.HumanoidRootPart
            local hum = char:FindFirstChild("Humanoid")
            
            local bb = Instance.new("BillboardGui", playerGui)
            bb.Adornee = hrp
            bb.Size = UDim2.fromOffset(200, 80)
            bb.StudsOffset = Vector3.new(0, 3, 0)
            bb.AlwaysOnTop = true
            
            local lbl = Instance.new("TextLabel", bb)
            lbl.Size = UDim2.fromScale(1,1)
            lbl.BackgroundTransparency = 1
            lbl.TextColor3 = Color3.fromRGB(0, 255, 255)
            lbl.TextStrokeTransparency = 0.5
            lbl.Font = Enum.Font.GothamBold
            lbl.TextSize = 14
            
            local selBox = Instance.new("SelectionBox")
            selBox.Adornee = char
            selBox.LineThickness = 0.05
            selBox.Color3 = Color3.fromRGB(0, 255, 255)
            selBox.Parent = char
            
            table.insert(playerESPObjects, bb)
            table.insert(playerESPObjects, selBox)
            
            -- Update loop
            spawn(function()
                while bb.Parent and playerESPEnabled do
                    if hum and hrp and root then
                        local dist = math.floor((hrp.Position - root.Position).Magnitude)
                        local health = math.floor(hum.Health)
                        lbl.Text = string.format("👤 %s\n❤️ %d HP | 📏 %d studs", player.Name, health, dist)
                    end
                    task.wait(0.5)
                end
            end)
        end
    end
end

-- === CHECK NEW DETAILS ===
local function checkHandprints()
    local handprintsFolder = workspace:FindFirstChild("Handprints")
    if handprintsFolder then
        return #handprintsFolder:GetChildren() > 0
    end
    return false
end

local function checkFortuneTeller()
    local cursedHolder = workspace:FindFirstChild("CursedPossessionHolder")
    if not cursedHolder then
        return false
    end
    
    -- Cek semua item cursed (100-199) di CursedPossessionHolder
    for i = 100, 199 do
        local cursedItem = cursedHolder:FindFirstChild(tostring(i))
        if cursedItem then
            -- Cek apakah ada "Fortune Ticket" atau "FortuneTellerRig" di dalam cursed item
            local fortuneTicket = cursedItem:FindFirstChild("Fortune Ticket")
            local fortuneTellerRig = cursedItem:FindFirstChild("FortuneTellerRig")
            
            if fortuneTicket or fortuneTellerRig then
                return true
            end
        end
    end
    
    return false
end

local function checkMultipleCursed()
    local items = workspace:FindFirstChild("Items")
    if not items then return false end
    
    local cursedCount = 0
    for _, item in pairs(items:GetChildren()) do
        local itemNum = tonumber(item.Name)
        if itemNum and itemNum >= 100 and itemNum <= 199 then
            cursedCount = cursedCount + 1
            if cursedCount > 1 then
                return true
            end
        end
    end
    return false
end

-- === CHECK GHOST ORB ===
local function checkGhostOrb()
    local ghostOrb = workspace:FindFirstChild("GhostOrb")
    if ghostOrb then
        return true
    end
    
    -- Cek juga di dalam folder-folder yang mungkin mengandung ghost orb
    for _, obj in pairs(workspace:GetDescendants()) do
        if string.lower(tostring(obj.Name)) == "ghostorb" then
            return true
        end
    end
    
    return false
end

-- === CHECK NEW EVIDENCES ===
-- === PERBAIKAN CHECK WITHERED ===
local function checkWithered()
    local items = workspace:FindFirstChild("Items")
    if not items then return false end
    
    local item9 = items:FindFirstChild("9")
    if item9 then
        local photoRewardType = item9:GetAttribute("PhotoRewardType")
        -- Cek jika PhotoRewardType ada dan berisi nilai tertentu
        return photoRewardType ~= nil and photoRewardType ~= "" and string.lower(tostring(photoRewardType)) == "withered"
    end
    return false
end

-- === PERBAIKAN CHECK WRITING ===
local function checkWriting()
    local items = workspace:FindFirstChild("Items")
    if not items then return false end
    
    local item3 = items:FindFirstChild("3")
    if item3 then
        local photoRewardType = item3:GetAttribute("PhotoRewardType")
        -- Cek jika PhotoRewardType ada dan berisi nilai tertentu
        return photoRewardType ~= nil and photoRewardType ~= "" and string.lower(tostring(photoRewardType)) == "ghostwriting"
    end
    return false
end

-- === ALTERNATIVE CHECK WRITING & WITHERED (JIKA ADA NILAI STRING APAPUN) ===
local function checkWriting()
    local items = workspace:FindFirstChild("Items")
    if not items then return false end
    
    local item3 = items:FindFirstChild("3")
    if item3 then
        local photoRewardType = item3:GetAttribute("PhotoRewardType")
        -- Cek jika PhotoRewardType ada dan berisi nilai apapun
        return photoRewardType ~= nil and photoRewardType ~= ""
    end
    return false
end

local function checkWithered()
    local items = workspace:FindFirstChild("Items")
    if not items then return false end
    
    local item9 = items:FindFirstChild("9")
    if item9 then
        local photoRewardType = item9:GetAttribute("PhotoRewardType")
        -- Cek jika PhotoRewardType ada dan berisi nilai apapun
        return photoRewardType ~= nil and photoRewardType ~= ""
    end
    return false
end

local function getTemperature()
    local items = workspace:FindFirstChild("Items")
    if not items then return "Unknown" end
    
    local item2 = items:FindFirstChild("2")
    if item2 then
        local screen = item2:FindFirstChild("Screen")
        if screen then
            local surfaceGui = screen:FindFirstChild("SurfaceGui")
            if surfaceGui then
                local frame = surfaceGui:FindFirstChild("Frame")
                if frame then
                    local textLabel = frame:FindFirstChild("TextLabel")
                    if textLabel then
                        return textLabel.Text
                    end
                end
            end
        end
    end
    return "Unknown"
end

local function getDifficulty()
    local difficulty = workspace:GetAttribute("Difficulty")
    if difficulty then
        return tostring(difficulty)
    end
    return "Unknown"
end

-- === CHECK ENERGY ===
-- === PERBAIKAN CHECK ENERGY ===
local function getEnergy()
    local success, result = pcall(function()
        local energyMonitor = LocalPlayer.PlayerGui:FindFirstChild("EnergyMonitor")
        if not energyMonitor then return "Unknown" end
        
        local container = energyMonitor:FindFirstChild("Container")
        if not container then return "Unknown" end
        
        local playerList = container:FindFirstChild("PlayerList")
        if not playerList then return "Unknown" end
        
        -- Cari semua elemen yang mungkin mengandung nilai energy
        for _, child in pairs(playerList:GetChildren()) do
            -- Cek jika ini adalah SelectionImageObject atau Frame
            if child:IsA("Frame") or child:IsA("ImageButton") or child.ClassName == "SelectionImageObject" then
                -- Cari child bernama "Energy" atau teks yang mengandung nilai energy
                local energyChild = child:FindFirstChild("Energy")
                if energyChild then
                    if energyChild:IsA("TextLabel") then
                        return energyChild.Text
                    elseif energyChild:IsA("ImageLabel") then
                        -- Jika berupa gambar, coba baca dari atribut atau properti lain
                        return "Visual"
                    end
                end
                
                -- Coba cari TextLabel langsung di dalam child
                for _, descendant in pairs(child:GetDescendants()) do
                    if descendant:IsA("TextLabel") and string.find(string.lower(descendant.Text or ""), "energy") then
                        return descendant.Text
                    elseif descendant:IsA("TextLabel") and string.match(descendant.Text or "", "%d+%%?") then
                        return descendant.Text
                    end
                end
            end
        end
        
        return "Unknown"
    end)
    
    return success and result or "Unknown"
end

-- === VARIABEL LASER VISIBLE ===
local laserVisibleEver = false

-- === UPDATE TEXT & DETAILS (DENGAN SEMUA EVIDENCE) ===
local function updateAll()
    if not ghost or not ghost.Parent then return end
    
    local age = ghost:GetAttribute("Age") or "Unknown"
    local gender = ghost:GetAttribute("Gender") or "Unknown"
    local currentRoom = ghost:GetAttribute("CurrentRoom") or "Unknown"
    local favoriteRoom = ghost:GetAttribute("FavoriteRoom") or "Unknown"
    local invisibleLidar = ghost:GetAttribute("InvisibleOnLIDAR") or false
    local visualModel = ghost:GetAttribute("VisualModel") or "Unknown"
    local currentLaserVisible = ghost:GetAttribute("LaserVisible") or false
    
    -- Update laserVisibleEver jika currentLaserVisible true
    if currentLaserVisible then
        laserVisibleEver = true
    end
    
    -- Check semua details dan evidences
    local handprints = checkHandprints()
    local fortuneTeller = checkFortuneTeller()
    local multipleCursed = checkMultipleCursed()
    local ghostOrb = checkGhostOrb()
    local withered = checkWithered()
    local writing = checkWriting()
    local temperature = getTemperature()
    local energy = getEnergy()
    local difficulty = getDifficulty()
    
    if label then
        label.Text = "Ghost | Age: " .. age
    end
    
    -- Update ghost details
    if detailsAge then detailsAge.Text = "👤 Age: " .. age .. " years old" end
    if detailsGender then detailsGender.Text = "⚥ Gender: " .. gender end
    if detailsCurrent then detailsCurrent.Text = "📍 Current: " .. currentRoom end
    if detailsFavorite then detailsFavorite.Text = "⭐ Favorite: " .. favoriteRoom end
    if detailsLidar then detailsLidar.Text = "📡 Inv. LIDAR: " .. tostring(invisibleLidar) end
    if detailsModel then detailsModel.Text = "👁️ Model: " .. visualModel end
    
    -- Update evidences
    if detailsHandprints then detailsHandprints.Text = "👣 Handprints: " .. tostring(handprints) end
    if detailsLaser then detailsLaser.Text = "🔦 Laser Visible: " .. tostring(laserVisibleEver) end
    if detailsGhostOrb then detailsGhostOrb.Text = "👻 Ghost Orb: " .. tostring(ghostOrb) end
    if detailsWithered then detailsWithered.Text = "🍂 Withered: " .. tostring(withered) end
    if detailsWriting then detailsWriting.Text = "📝 Writing: " .. tostring(writing) end
    if detailsTemperature then detailsTemperature.Text = "🌡️ Temperature: " .. tostring(temperature) end
    if detailsEnergy then detailsEnergy.Text = "⚡ Energy: " .. tostring(energy) end
    if detailsMultiple then detailsMultiple.Text = "💀 Multiple Cursed: " .. tostring(multipleCursed) end
    if detailsFortune then detailsFortune.Text = "🔮 Fortune Teller: " .. tostring(fortuneTeller) end
    if detailsDifficulty then detailsDifficulty.Text = "🎯 Difficulty: " .. tostring(difficulty) end
    
    if vexLabel then
        vexLabel.Visible = invisibleLidar
        if invisibleLidar then
            vexLabel.Text = "⚠️ Ghost: Vex"
        end
    end
end

-- === FIND GROUND POSITION ===
local function findGroundPosition(position)
    local rayOrigin = position + Vector3.new(0, 10, 0)
    local rayDirection = Vector3.new(0, -100, 0)
    local raycastParams = RaycastParams.new()
    raycastParams.FilterType = Enum.RaycastFilterType.Blacklist
    raycastParams.FilterDescendantsInstances = {LocalPlayer.Character}
    
    local rayResult = workspace:Raycast(rayOrigin, rayDirection, raycastParams)
    if rayResult then
        return rayResult.Position + Vector3.new(0, 0.5, 0)
    end
    return position
end

-- === IMPROVED TP FUNCTIONS (WITH GROUND DETECTION) ===
local function tpAllItems()
    if not LocalPlayer.Character or not root then return end
    local items = workspace:FindFirstChild("Items")
    if not items then 
        warn("Items folder not found")
        return 
    end
    
    local count = 0
    for _, item in pairs(items:GetChildren()) do
        local itemNum = tonumber(item.Name)
        if itemNum and itemNum >= 1 and itemNum < 10 then
            if item:IsA("BasePart") or item:IsA("Model") then
                local targetPart = item:IsA("BasePart") and item or item:FindFirstChildWhichIsA("BasePart", true)
                if targetPart then
                    local groundPos = findGroundPosition(root.Position + Vector3.new(math.random(-5, 5), 0, math.random(-5, 5)))
                    
                    if targetPart:IsA("BasePart") then
                        targetPart.CFrame = CFrame.new(groundPos)
                        targetPart.Anchored = false
                        targetPart.CanCollide = true
                        targetPart.Velocity = Vector3.new(0, 0, 0)
                    elseif item:IsA("Model") and item.PrimaryPart then
                        item:SetPrimaryPartCFrame(CFrame.new(groundPos))
                    end
                    count = count + 1
                    task.wait(0.05)
                end
            end
        end
    end
    print("Teleported " .. count .. " items to ground")
end

local function tpCursedPossession()
    if not LocalPlayer.Character or not root then return end
    local items = workspace:FindFirstChild("Items")
    if not items then 
        warn("Items folder not found")
        return 
    end
    
    local count = 0
    for _, item in pairs(items:GetChildren()) do
        local itemNum = tonumber(item.Name)
        if itemNum and itemNum >= 100 then
            if item:IsA("BasePart") or item:IsA("Model") then
                local targetPart = item:IsA("BasePart") and item or item:FindFirstChildWhichIsA("BasePart", true)
                if targetPart then
                    local groundPos = findGroundPosition(root.Position + Vector3.new(math.random(-3, 3), 0, math.random(-3, 3)))
                    
                    if targetPart:IsA("BasePart") then
                        targetPart.CFrame = CFrame.new(groundPos)
                        targetPart.Anchored = false
                        targetPart.CanCollide = true
                        targetPart.Velocity = Vector3.new(0, 0, 0)
                    elseif item:IsA("Model") and item.PrimaryPart then
                        item:SetPrimaryPartCFrame(CFrame.new(groundPos))
                    end
                    count = count + 1
                    task.wait(0.05)
                end
            end
        end
    end
    print("Teleported " .. count .. " cursed possessions to ground")
end

local function tpHouseItems()
    if not LocalPlayer.Character or not root then return end
    local items = workspace:FindFirstChild("Items")
    if not items then 
        warn("Items folder not found")
        return 
    end
    
    local count = 0
    for _, item in pairs(items:GetChildren()) do
        local itemNum = tonumber(item.Name)
        if itemNum and itemNum >= 10 and itemNum < 100 then
            if item:IsA("BasePart") or item:IsA("Model") then
                local targetPart = item:IsA("BasePart") and item or item:FindFirstChildWhichIsA("BasePart", true)
                if targetPart then
                    local groundPos = findGroundPosition(root.Position + Vector3.new(math.random(-5, 5), 0, math.random(-5, 5)))
                    
                    if targetPart:IsA("BasePart") then
                        targetPart.CFrame = CFrame.new(groundPos)
                        targetPart.Anchored = false
                        targetPart.CanCollide = true
                        targetPart.Velocity = Vector3.new(0, 0, 0)
                    elseif item:IsA("Model") and item.PrimaryPart then
                        item:SetPrimaryPartCFrame(CFrame.new(groundPos))
                    end
                    count = count + 1
                    task.wait(0.05)
                end
            end
        end
    end
    print("Teleported " .. count .. " house items to ground")
end

-- === TOGGLE ELECTRONIC ITEMS ===
local function toggleElectronicItem(itemId)
    local character = LocalPlayer.Character
    if not character then return false end
    
    -- Cari item di karakter player berdasarkan ID
    local itemInHand = character:FindFirstChild(tostring(itemId))
    if itemInHand then
        local args = {[1] = itemInHand}
        game:GetService("ReplicatedStorage").Events.ToggleItemState:FireServer(unpack(args))
        return true
    end
    return false
end

-- === PERBAIKAN BRING ITEMS TO ME ===
local function bringItemsToMe()
    if not LocalPlayer.Character or not root then return end
    local items = workspace:FindFirstChild("Items")
    if not items then 
        warn("Items folder not found")
        return 
    end
    
    local ReplicatedStorage = game:GetService("ReplicatedStorage")
    
    -- Kumpulkan semua item regular (1-9) yang belum dekat dengan player
    local regularItems = {}
    for i = 1, 9 do
        local item = items:FindFirstChild(tostring(i))
        if item then
            -- Cek apakah item sudah dekat dengan player (dalam jarak 15 stud)
            local itemPos = item:IsA("BasePart") and item.Position or 
                           (item:IsA("Model") and item.PrimaryPart and item.PrimaryPart.Position)
            
            if itemPos then
                local distance = (itemPos - root.Position).Magnitude
                if distance > 15 then  -- Hanya ambil item yang jaraknya > 15 stud
                    table.insert(regularItems, item)
                    print("Item " .. item.Name .. " will be processed (distance: " .. math.floor(distance) .. " studs)")
                else
                    print("Item " .. item.Name .. " is already nearby (distance: " .. math.floor(distance) .. " studs), skipping")
                end
            else
                table.insert(regularItems, item)
            end
        end
    end
    
    if #regularItems == 0 then
        print("No regular items found that need to be brought (1-9)")
        return
    end
    
    print("Found " .. #regularItems .. " regular items to bring")
    
    -- Proses 3 item per batch
    for i = 1, #regularItems, 3 do
        local batchItems = {}
        
        -- Ambil maksimal 3 item untuk batch ini
        for j = i, math.min(i + 2, #regularItems) do
            table.insert(batchItems, regularItems[j])
        end
        
        print("Processing batch with " .. #batchItems .. " items")
        
        -- Pickup semua item dalam batch
        for _, item in ipairs(batchItems) do
            local args = {[1] = item}
            ReplicatedStorage.Events.RequestItemPickup:FireServer(unpack(args))
            print("Picked up item: " .. item.Name)
            task.wait(0.3)
        end
        
        -- Equip, toggle state, dan drop menggunakan hanya InvSlot1 untuk semua item
        for slot = 1, #batchItems do
            -- Equip InvSlot1
            local equipArgs = {[1] = "InvSlot1"}
            ReplicatedStorage.Events.RequestItemEquip:FireServer(unpack(equipArgs))
            print("Equipped InvSlot1")
            task.wait(0.2)
            
            -- Coba toggle electronic state untuk item yang dipegang
            local itemId = batchItems[slot].Name
            local success = toggleElectronicItem(itemId)
            if success then
                print("Toggled electronic state for item: " .. itemId)
            else
                print("Item " .. itemId .. " is not electronic or cannot be toggled")
            end
            task.wait(0.2)
            
            -- Drop InvSlot1
            local dropArgs = {[1] = "InvSlot1"}
            ReplicatedStorage.Events.RequestItemDrop:FireServer(unpack(dropArgs))
            print("Dropped from InvSlot1")
            task.wait(0.2)
        end
        
        print("Completed batch " .. math.ceil(i / 3) .. " of " .. math.ceil(#regularItems / 3))
        task.wait(0.5)
    end
    
    print("Finished bringing all items to your location")
end

-- === TURN ON ALL ELECTRONIC (INSTANT) ===
local function turnOnAllElectronic()
    local ReplicatedStorage = game:GetService("ReplicatedStorage")
    local items = workspace:FindFirstChild("Items")
    
    if not items then 
        warn("Items folder not found")
        return 
    end

    print("Turning on all electronic items instantly...")

    local electronicItems = {}
    
    -- Kumpulkan semua item elektronik dari dunia (1-99)
    for i = 1, 99 do
        local item = items:FindFirstChild(tostring(i))
        if item then
            table.insert(electronicItems, item)
        end
    end

    -- Kumpulkan juga item elektronik yang ada di inventory pemain
    local character = LocalPlayer.Character
    if character then
        for i = 1, 9 do
            local itemInHand = character:FindFirstChild(tostring(i))
            if itemInHand then
                table.insert(electronicItems, itemInHand)
            end
        end
    end

    if #electronicItems == 0 then
        print("No electronic items found")
        return
    end

    print("Found " .. #electronicItems .. " electronic items to turn on")

    -- Nyatakan semua item elektronik secara instan
    local turnedOnCount = 0
    for _, item in ipairs(electronicItems) do
        local args = {[1] = item}
        
        -- Coba toggle state item
        local success = pcall(function()
            ReplicatedStorage.Events.ToggleItemState:FireServer(unpack(args))
        end)
        
        if success then
            turnedOnCount = turnedOnCount + 1
            print("Turned on electronic item: " .. item.Name)
        else
            print("Failed to turn on item: " .. item.Name)
        end
        
        task.wait(0.05) -- Delay kecil untuk menghindari spam
    end

    print("Successfully turned on " .. turnedOnCount .. " electronic items")
end

-- === BRING CURSED ITEMS TO ME ===
local function bringCursedItemsToMe()
    if not LocalPlayer.Character or not root then return end
    local items = workspace:FindFirstChild("Items")
    if not items then 
        warn("Items folder not found")
        return 
    end
    
    local ReplicatedStorage = game:GetService("ReplicatedStorage")
    
    -- Kumpulkan semua cursed items (100-199) yang belum dekat dengan player
    local cursedItems = {}
    for i = 100, 199 do
        local item = items:FindFirstChild(tostring(i))
        if item then
            -- Cek apakah item sudah dekat dengan player (dalam jarak 15 stud)
            local itemPos = item:IsA("BasePart") and item.Position or 
                           (item:IsA("Model") and item.PrimaryPart and item.PrimaryPart.Position)
            
            if itemPos then
                local distance = (itemPos - root.Position).Magnitude
                if distance > 15 then  -- Hanya ambil item yang jaraknya > 15 stud
                    table.insert(cursedItems, item)
                    print("Cursed Item " .. item.Name .. " will be processed (distance: " .. math.floor(distance) .. " studs)")
                else
                    print("Cursed Item " .. item.Name .. " is already nearby (distance: " .. math.floor(distance) .. " studs), skipping")
                end
            else
                table.insert(cursedItems, item)
            end
        end
    end
    
    if #cursedItems == 0 then
        print("No cursed items found that need to be brought (100-199)")
        return
    end
    
    print("Found " .. #cursedItems .. " cursed items to bring")
    
    -- Proses 3 item per batch
    for i = 1, #cursedItems, 3 do
        local batchItems = {}
        
        -- Ambil maksimal 3 item untuk batch ini
        for j = i, math.min(i + 2, #cursedItems) do
            table.insert(batchItems, cursedItems[j])
        end
        
        print("Processing cursed batch with " .. #batchItems .. " items")
        
        -- Pickup semua item dalam batch
        for _, item in ipairs(batchItems) do
            local args = {[1] = item}
            ReplicatedStorage.Events.RequestItemPickup:FireServer(unpack(args))
            print("Picked up cursed item: " .. item.Name)
            task.wait(0.3)
        end
        
        -- Equip dan drop menggunakan hanya InvSlot1 untuk semua item
        for slot = 1, #batchItems do
            -- Equip InvSlot1
            local equipArgs = {[1] = "InvSlot1"}
            ReplicatedStorage.Events.RequestItemEquip:FireServer(unpack(equipArgs))
            print("Equipped InvSlot1 (cursed)")
            task.wait(0.2)
            
            -- Drop InvSlot1
            local dropArgs = {[1] = "InvSlot1"}
            ReplicatedStorage.Events.RequestItemDrop:FireServer(unpack(dropArgs))
            print("Dropped from InvSlot1 (cursed)")
            task.wait(0.2)
        end
        
        print("Completed cursed batch " .. math.ceil(i / 3) .. " of " .. math.ceil(#cursedItems / 3))
        task.wait(0.5)
    end
    
    print("Finished bringing all cursed items to your location")
end

-- === BRING HOUSE ITEMS TO ME ===
local function bringHouseItemsToMe()
    if not LocalPlayer.Character or not root then return end
    local items = workspace:FindFirstChild("Items")
    if not items then 
        warn("Items folder not found")
        return 
    end
    
    local ReplicatedStorage = game:GetService("ReplicatedStorage")
    
    -- Kumpulkan semua house items (10-99) yang belum dekat dengan player
    local houseItems = {}
    for i = 10, 99 do
        local item = items:FindFirstChild(tostring(i))
        if item then
            -- Cek apakah item sudah dekat dengan player (dalam jarak 15 stud)
            local itemPos = item:IsA("BasePart") and item.Position or 
                           (item:IsA("Model") and item.PrimaryPart and item.PrimaryPart.Position)
            
            if itemPos then
                local distance = (itemPos - root.Position).Magnitude
                if distance > 15 then  -- Hanya ambil item yang jaraknya > 15 stud
                    table.insert(houseItems, item)
                    print("House Item " .. item.Name .. " will be processed (distance: " .. math.floor(distance) .. " studs)")
                else
                    print("House Item " .. item.Name .. " is already nearby (distance: " .. math.floor(distance) .. " studs), skipping")
                end
            else
                table.insert(houseItems, item)
            end
        end
    end
    
    if #houseItems == 0 then
        print("No house items found that need to be brought (10-99)")
        return
    end
    
    print("Found " .. #houseItems .. " house items to bring")
    
    -- Proses 3 item per batch
    for i = 1, #houseItems, 3 do
        local batchItems = {}
        
        -- Ambil maksimal 3 item untuk batch ini
        for j = i, math.min(i + 2, #houseItems) do
            table.insert(batchItems, houseItems[j])
        end
        
        print("Processing house batch with " .. #batchItems .. " items")
        
        -- Pickup semua item dalam batch
        for _, item in ipairs(batchItems) do
            local args = {[1] = item}
            ReplicatedStorage.Events.RequestItemPickup:FireServer(unpack(args))
            print("Picked up house item: " .. item.Name)
            task.wait(0.3)
        end
        
        -- Equip dan drop menggunakan hanya InvSlot1 untuk semua item
        for slot = 1, #batchItems do
            -- Equip InvSlot1
            local equipArgs = {[1] = "InvSlot1"}
            ReplicatedStorage.Events.RequestItemEquip:FireServer(unpack(equipArgs))
            print("Equipped InvSlot1 (house)")
            task.wait(0.2)
            
            -- Drop InvSlot1
            local dropArgs = {[1] = "InvSlot1"}
            ReplicatedStorage.Events.RequestItemDrop:FireServer(unpack(dropArgs))
            print("Dropped from InvSlot1 (house)")
            task.wait(0.2)
        end
        
        print("Completed house batch " .. math.ceil(i / 3) .. " of " .. math.ceil(#houseItems / 3))
        task.wait(0.5)
    end
    
    print("Finished bringing all house items to your location")
end

-- === TP GHOST FUNCTIONS ===
local isTeleportingGhost = false
local function tpGhostToMe()
    if isTeleportingGhost then return end
    if not LocalPlayer.Character or not root or not ghost or not ghost.Parent then return end
    
    isTeleportingGhost = true
    local targetPos = root.CFrame + Vector3.new(0, 0, -5)
    local tweenInfo = TweenInfo.new(2, Enum.EasingStyle.Quad, Enum.EasingDirection.Out)
    
    if ghost:IsA("BasePart") then
        local tween = TweenService:Create(ghost, tweenInfo, {CFrame = targetPos})
        tween:Play()
        tween.Completed:Connect(function()
            isTeleportingGhost = false
        end)
    elseif ghost:IsA("Model") and ghost.PrimaryPart then
        local tween = TweenService:Create(ghost.PrimaryPart, tweenInfo, {CFrame = targetPos})
        tween:Play()
        tween.Completed:Connect(function()
            isTeleportingGhost = false
        end)
    else
        isTeleportingGhost = false
    end
end

local function tpToGhost()
    if not LocalPlayer.Character or not root or not ghost or not ghost.Parent then return end
    
    local ghostPos, ghostCFrame
    if ghost:IsA("BasePart") then
        ghostPos = ghost.Position
        ghostCFrame = ghost.CFrame
    elseif ghost:IsA("Model") and ghost.PrimaryPart then
        ghostPos = ghost.PrimaryPart.Position
        ghostCFrame = ghost.PrimaryPart.CFrame
    else
        local firstPart = ghost:FindFirstChildWhichIsA("BasePart")
        if firstPart then
            ghostPos = firstPart.Position
            ghostCFrame = firstPart.CFrame
        else
            warn("Cannot find position for Ghost")
            return
        end
    end
    
    -- Teleport ke depan ghost
    local lookVector = ghostCFrame.lookVector
    local offset = lookVector * 4 + Vector3.new(0, 1, 0) -- 4 stud di depan, 1 stud di atas
    root.CFrame = CFrame.new(ghostPos + offset, ghostPos)
    print("Teleported to front of Ghost")
end

local function tpToFusebox()
    if not LocalPlayer.Character or not root then return end
    
    local fusebox = workspace:FindFirstChild("FuseBox", true)
    if fusebox then
        local fuseboxPos, fuseboxCFrame
        if fusebox:IsA("BasePart") then
            fuseboxPos = fusebox.Position
            fuseboxCFrame = fusebox.CFrame
        elseif fusebox:IsA("Model") and fusebox.PrimaryPart then
            fuseboxPos = fusebox.PrimaryPart.Position
            fuseboxCFrame = fusebox.PrimaryPart.CFrame
        else
            local firstPart = fusebox:FindFirstChildWhichIsA("BasePart")
            if firstPart then
                fuseboxPos = firstPart.Position
                fuseboxCFrame = firstPart.CFrame
            else
                warn("Cannot find position for FuseBox")
                return
            end
        end
        
        -- Teleport ke depan fusebox (gunakan lookVector untuk menentukan arah depan)
        local lookVector = fuseboxCFrame.lookVector
        local offset = lookVector * 3 + Vector3.new(0, 2, 0) -- 3 stud di depan, 2 stud di atas
        root.CFrame = CFrame.new(fuseboxPos + offset, fuseboxPos)
        print("Teleported to front of FuseBox")
    else
        warn("FuseBox not found")
    end
end

local function deleteExitDoor()
    local doors = workspace:FindFirstChild("Doors")
    if doors then
        local exitDoor = doors:FindFirstChild("ExitDoor")
        if exitDoor then
            exitDoor:Destroy()
            print("Exit Door deleted")
        else
            warn("Exit Door not found")
        end
    else
        warn("Doors folder not found")
    end
end

-- === PERBAIKAN TP TO CURSED ITEMS ===
local function tpToCursedItems()
    if not LocalPlayer.Character or not root then return end
    
    -- Cari cursed item di folder Items (100-199)
    local items = workspace:FindFirstChild("Items")
    local cursedItem = nil
    
    if items then
        for i = 100, 199 do
            local item = items:FindFirstChild(tostring(i))
            if item then
                cursedItem = item
                break
            end
        end
    end
    
    -- Jika tidak ditemukan di Items, cari di CursedPossessionHolder
    if not cursedItem then
        local cursedHolder = workspace:FindFirstChild("CursedPossessionHolder")
        if cursedHolder then
            for _, child in pairs(cursedHolder:GetChildren()) do
                if child:IsA("Model") or child:IsA("BasePart") then
                    cursedItem = child
                    break
                end
            end
        end
    end
    
    if not cursedItem then
        warn("No cursed items found in Items (100-199) or CursedPossessionHolder")
        return
    end
    
    print("Found cursed item: " .. cursedItem.Name)
    
    -- Dapatkan posisi cursed item
    local cursedPos, cursedSize
    if cursedItem:IsA("BasePart") then
        cursedPos = cursedItem.Position
        cursedSize = cursedItem.Size
    elseif cursedItem:IsA("Model") and cursedItem.PrimaryPart then
        cursedPos = cursedItem.PrimaryPart.Position
        cursedSize = cursedItem.PrimaryPart.Size
    else
        -- Jika tidak bisa mendapatkan PrimaryPart, coba cari part pertama
        local firstPart = cursedItem:FindFirstChildWhichIsA("BasePart")
        if firstPart then
            cursedPos = firstPart.Position
            cursedSize = firstPart.Size
        else
            warn("Cannot find position for cursed item")
            return
        end
    end
    
    -- Tentukan posisi teleport berdasarkan ukuran item
    local offset
    if cursedSize.Y > 5 then
        -- Item tinggi (seperti Ouija Board), teleport di depan
        offset = Vector3.new(0, 0, 5)
    else
        -- Item pendek, teleport di tengah (sedikit ke atas)
        offset = Vector3.new(0, 2, 0)
    end
    
    -- Dapatkan CFrame cursed item untuk menentukan arah depan
    local cursedCFrame
    if cursedItem:IsA("BasePart") then
        cursedCFrame = cursedItem.CFrame
    elseif cursedItem:IsA("Model") and cursedItem.PrimaryPart then
        cursedCFrame = cursedItem.PrimaryPart.CFrame
    else
        local firstPart = cursedItem:FindFirstChildWhichIsA("BasePart")
        if firstPart then
            cursedCFrame = firstPart.CFrame
        else
            cursedCFrame = CFrame.new(cursedPos)
        end
    end
    
    -- Teleport ke posisi yang ditentukan dengan menghadap ke cursed item
    local lookVector = cursedCFrame.lookVector
    local teleportPos = cursedPos + (lookVector * offset.Z) + Vector3.new(0, offset.Y, 0)
    
    root.CFrame = CFrame.new(teleportPos, cursedPos)
    print("Teleported to Cursed Item")
end

-- === VARIABEL TOGGLE BARU ===
local allItemsESPEnabled = false
local cursedItemsESPEnabled = false

-- === ESP OBJECTS BARU ===
local allItemsESPObjects = {}
local cursedItemsESPObjects = {}

-- === CLEAR ESP FUNCTIONS ===
local function clearAllItemsESP()
    for _, obj in pairs(allItemsESPObjects) do
        if obj then 
            if obj.billboard then obj.billboard:Destroy() end
            if obj.box then obj.box:Destroy() end
            if obj.beam then obj.beam:Destroy() end
            if obj.attachItem then obj.attachItem:Destroy() end
            if obj.attachPlayer then obj.attachPlayer:Destroy() end
        end
    end
    allItemsESPObjects = {}
end

local function clearCursedItemsESP()
    for _, obj in pairs(cursedItemsESPObjects) do
        if obj then 
            if obj.billboard then obj.billboard:Destroy() end
            if obj.box then obj.box:Destroy() end
            if obj.beam then obj.beam:Destroy() end
            if obj.attachItem then obj.attachItem:Destroy() end
            if obj.attachPlayer then obj.attachPlayer:Destroy() end
        end
    end
    cursedItemsESPObjects = {}
end

-- === ESP ALL ITEMS ===
local function createAllItemsESP()
    clearAllItemsESP()
    if not allItemsESPEnabled then return end
    
    local items = workspace:FindFirstChild("Items")
    if not items then return end
    
    for _, item in pairs(items:GetChildren()) do
        local itemNum = tonumber(item.Name)
        if itemNum and itemNum >= 1 and itemNum <= 99 then -- Regular items (1-9) dan house items (10-99)
            spawn(function()
                local itemName = item:GetAttribute("ItemName") or "Unknown Item"
                
                -- Billboard GUI
                local billboard = Instance.new("BillboardGui")
                billboard.Adornee = item:IsA("BasePart") and item or (item.PrimaryPart or item:FindFirstChildWhichIsA("BasePart"))
                billboard.Size = UDim2.fromOffset(200, 50)
                billboard.StudsOffset = Vector3.new(0, 3, 0)
                billboard.AlwaysOnTop = true
                billboard.Parent = playerGui
                
                local label = Instance.new("TextLabel", billboard)
                label.Size = UDim2.fromScale(1, 1)
                label.BackgroundTransparency = 1
                label.TextColor3 = Color3.fromRGB(100, 255, 100) -- Hijau untuk regular items
                label.TextStrokeTransparency = 0.5
                label.Font = Enum.Font.GothamBold
                label.TextSize = 12
                label.Text = itemName
                
                -- Selection Box
                local box = Instance.new("SelectionBox")
                box.Adornee = item
                box.LineThickness = 0.05
                box.Color3 = Color3.fromRGB(100, 255, 100) -- Hijau untuk regular items
                box.Parent = item
                
                -- Tracer (Beam)
                local attachPlayer = Instance.new("Attachment", root)
                attachPlayer.Visible = false
                
                local attachItem = Instance.new("Attachment", item:IsA("BasePart") and item or (item.PrimaryPart or item:FindFirstChildWhichIsA("BasePart")))
                attachItem.Visible = false
                
                local beam = Instance.new("Beam")
                beam.Attachment0 = attachPlayer
                beam.Attachment1 = attachItem
                beam.Color = ColorSequence.new(Color3.fromRGB(100, 255, 100)) -- Hijau untuk regular items
                beam.Width0 = 0.15
                beam.Width1 = 0.15
                beam.Transparency = NumberSequence.new(0.3)
                beam.FaceCamera = true
                beam.LightEmission = 0.5
                beam.LightInfluence = 0
                beam.Parent = workspace
                
                -- Simpan ESP objects
                local espObject = {
                    billboard = billboard,
                    box = box,
                    beam = beam,
                    attachPlayer = attachPlayer,
                    attachItem = attachItem,
                    item = item
                }
                table.insert(allItemsESPObjects, espObject)
                
                -- Update loop untuk jarak
                while billboard.Parent and allItemsESPEnabled do
                    if item and item.Parent and root then
                        local itemPos = item:IsA("BasePart") and item.Position or 
                                      (item.PrimaryPart and item.PrimaryPart.Position or 
                                      (item:FindFirstChildWhichIsA("BasePart") and item:FindFirstChildWhichIsA("BasePart").Position))
                        if itemPos then
                            local distance = math.floor((itemPos - root.Position).Magnitude)
                            label.Text = string.format("%s\n📏 %d studs", itemName, distance)
                        end
                    else
                        break
                    end
                    task.wait(0.5)
                end
            end)
        end
    end
end

-- === ESP CURSED POSSESSION (IMPROVED) ===
local function createCursedItemsESP()
    clearCursedItemsESP()
    if not cursedItemsESPEnabled then return end
    
    local cursedItems = {}
    
    -- Cek di CursedPossessionHolder terlebih dahulu
    local cursedHolder = workspace:FindFirstChild("CursedPossessionHolder")
    if cursedHolder then
        for _, cursedItem in pairs(cursedHolder:GetChildren()) do
            table.insert(cursedItems, cursedItem)
        end
    end
    
    -- Jika tidak ada di CursedPossessionHolder, cek di Items (100-199)
    if #cursedItems == 0 then
        local items = workspace:FindFirstChild("Items")
        if items then
            for i = 100, 199 do
                local item = items:FindFirstChild(tostring(i))
                if item then
                    table.insert(cursedItems, item)
                end
            end
        end
    end
    
    if #cursedItems == 0 then
        print("No cursed items found in CursedPossessionHolder or Items (100-199)")
        return
    end
    
    print("Found " .. #cursedItems .. " cursed items for ESP")
    
    for _, cursedItem in pairs(cursedItems) do
        spawn(function()
            local itemName = cursedItem:GetAttribute("ItemName") or "Unknown Cursed Item"
            
            -- Billboard GUI
            local billboard = Instance.new("BillboardGui")
            billboard.Adornee = cursedItem:IsA("BasePart") and cursedItem or (cursedItem.PrimaryPart or cursedItem:FindFirstChildWhichIsA("BasePart"))
            billboard.Size = UDim2.fromOffset(250, 60)
            billboard.StudsOffset = Vector3.new(0, 3.5, 0)
            billboard.AlwaysOnTop = true
            billboard.Parent = playerGui
            
            local label = Instance.new("TextLabel", billboard)
            label.Size = UDim2.fromScale(1, 1)
            label.BackgroundTransparency = 1
            label.TextColor3 = Color3.fromRGB(255, 50, 50) -- Merah untuk cursed items
            label.TextStrokeTransparency = 0.5
            label.Font = Enum.Font.GothamBold
            label.TextSize = 13
            label.Text = "💀 " .. itemName
            
            -- Selection Box
            local box = Instance.new("SelectionBox")
            box.Adornee = cursedItem
            box.LineThickness = 0.08
            box.Color3 = Color3.fromRGB(255, 50, 50) -- Merah untuk cursed items
            box.Parent = cursedItem
            
            -- Tracer (Beam)
            local attachPlayer = Instance.new("Attachment", root)
            attachPlayer.Visible = false
            
            local attachItem = Instance.new("Attachment", cursedItem:IsA("BasePart") and cursedItem or (cursedItem.PrimaryPart or cursedItem:FindFirstChildWhichIsA("BasePart")))
            attachItem.Visible = false
            
            local beam = Instance.new("Beam")
            beam.Attachment0 = attachPlayer
            beam.Attachment1 = attachItem
            beam.Color = ColorSequence.new(Color3.fromRGB(255, 50, 50)) -- Merah untuk cursed items
            beam.Width0 = 0.2
            beam.Width1 = 0.2
            beam.Transparency = NumberSequence.new(0.2)
            beam.FaceCamera = true
            beam.LightEmission = 0.8
            beam.LightInfluence = 0
            beam.Parent = workspace
            
            -- Simpan ESP objects
            local espObject = {
                billboard = billboard,
                box = box,
                beam = beam,
                attachPlayer = attachPlayer,
                attachItem = attachItem,
                item = cursedItem
            }
            table.insert(cursedItemsESPObjects, espObject)
            
            -- Update loop untuk jarak
            while billboard.Parent and cursedItemsESPEnabled do
                if cursedItem and cursedItem.Parent and root then
                    local itemPos = cursedItem:IsA("BasePart") and cursedItem.Position or 
                                  (cursedItem.PrimaryPart and cursedItem.PrimaryPart.Position or 
                                  (cursedItem:FindFirstChildWhichIsA("BasePart") and cursedItem:FindFirstChildWhichIsA("BasePart").Position))
                    if itemPos then
                        local distance = math.floor((itemPos - root.Position).Magnitude)
                        label.Text = string.format("💀 %s\n📏 %d studs", itemName, distance)
                    end
                else
                    break
                end
                task.wait(0.5)
            end
        end)
    end
end

-- === MAIN GUI ===
local screenGui = Instance.new("ScreenGui")
screenGui.Name = "GhostESP"
screenGui.Parent = playerGui
screenGui.ResetOnSpawn = false

local mainFrame = Instance.new("Frame", screenGui)
mainFrame.Size = UDim2.fromOffset(650, 800)  -- Diperbesar
mainFrame.Position = UDim2.new(0.5, -325, 0.5, -425)  -- Diperbesar
mainFrame.BackgroundColor3 = Color3.fromRGB(20, 20, 25)
mainFrame.BorderSizePixel = 0
mainFrame.Active = true
mainFrame.Draggable = true

local corner = Instance.new("UICorner", mainFrame)
corner.CornerRadius = UDim.new(0, 12)

local gradient = Instance.new("UIGradient", mainFrame)
gradient.Color = ColorSequence.new{
    ColorSequenceKeypoint.new(0, Color3.fromRGB(20, 20, 25)),
    ColorSequenceKeypoint.new(1, Color3.fromRGB(30, 30, 40))
}
gradient.Rotation = 45

-- TITLE BAR
local titleBar = Instance.new("Frame", mainFrame)
titleBar.Size = UDim2.new(1, 0, 0, 40)
titleBar.BackgroundColor3 = Color3.fromRGB(15, 15, 20)
titleBar.BorderSizePixel = 0

local titleCorner = Instance.new("UICorner", titleBar)
titleCorner.CornerRadius = UDim.new(0, 12)

local title = Instance.new("TextLabel", titleBar)
title.Size = UDim2.new(0.7, 0, 1, 0)
title.Position = UDim2.fromScale(0.05, 0)
title.BackgroundTransparency = 1
title.Text = "👻 PHASMOPHOBIA ESP & TOOLS"
title.TextColor3 = Color3.fromRGB(100, 200, 255)
title.Font = Enum.Font.GothamBold
title.TextSize = 18
title.TextXAlignment = Enum.TextXAlignment.Left

local minimizeBtn = Instance.new("TextButton", titleBar)
minimizeBtn.Size = UDim2.fromOffset(35, 30)
minimizeBtn.Position = UDim2.new(1, -80, 0.5, -15)
minimizeBtn.BackgroundColor3 = Color3.fromRGB(255, 200, 0)
minimizeBtn.Text = "—"
minimizeBtn.Font = Enum.Font.GothamBold
minimizeBtn.TextSize = 18
minimizeBtn.TextColor3 = Color3.fromRGB(0, 0, 0)
local minCorner = Instance.new("UICorner", minimizeBtn)
minCorner.CornerRadius = UDim.new(0, 6)

local closeBtn = Instance.new("TextButton", titleBar)
closeBtn.Size = UDim2.fromOffset(35, 30)
closeBtn.Position = UDim2.new(1, -40, 0.5, -15)
closeBtn.BackgroundColor3 = Color3.fromRGB(255, 70, 70)
closeBtn.Text = "X"
closeBtn.Font = Enum.Font.GothamBold
closeBtn.TextSize = 18
closeBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
local closeCorner = Instance.new("UICorner", closeBtn)
closeCorner.CornerRadius = UDim.new(0, 6)

-- CONTENT FRAME
local contentFrame = Instance.new("Frame", mainFrame)
contentFrame.Size = UDim2.new(1, -20, 1, -50)
contentFrame.Position = UDim2.fromOffset(10, 45)
contentFrame.BackgroundTransparency = 1

local leftColumn = Instance.new("Frame", contentFrame)
leftColumn.Size = UDim2.fromScale(0.32, 1)
leftColumn.BackgroundTransparency = 1

local middleColumn = Instance.new("Frame", contentFrame)
middleColumn.Size = UDim2.fromScale(0.32, 1)
middleColumn.Position = UDim2.fromScale(0.34, 0)
middleColumn.BackgroundTransparency = 1

local rightColumn = Instance.new("Frame", contentFrame)
rightColumn.Size = UDim2.fromScale(0.32, 1)
rightColumn.Position = UDim2.fromScale(0.68, 0)
rightColumn.BackgroundTransparency = 1

-- === HELPER FUNCTIONS ===
local function createSectionTitle(parent, text, position, color)
    local title = Instance.new("TextLabel", parent)
    title.Size = UDim2.new(1, 0, 0, 25)
    title.Position = position
    title.BackgroundTransparency = 1
    title.Text = text
    title.TextColor3 = color
    title.Font = Enum.Font.GothamBold
    title.TextSize = 14
    title.TextXAlignment = Enum.TextXAlignment.Left
    return title
end

local function createButton(parent, text, position, color, ySize)
    local btn = Instance.new("TextButton", parent)
    btn.Size = UDim2.new(1, 0, 0, ySize or 35)
    btn.Position = position
    btn.BackgroundColor3 = color
    btn.Text = text
    btn.Font = Enum.Font.GothamBold
    btn.TextSize = 12
    btn.TextColor3 = Color3.new(1,1,1)
    local corner = Instance.new("UICorner", btn)
    corner.CornerRadius = UDim.new(0, 8)
    return btn
end

-- === LEFT COLUMN - ESP SECTION ===
createSectionTitle(leftColumn, "🔍 ESP & VISUALS", UDim2.fromScale(0, 0), Color3.fromRGB(100, 200, 255))

local espToggle = createButton(leftColumn, "✅ ESP TEXT: ON", UDim2.fromOffset(0, 30), Color3.fromRGB(0, 200, 0))
local boxToggle = createButton(leftColumn, "✅ RAINBOW BOX: ON", UDim2.fromOffset(0, 70), Color3.fromRGB(0, 200, 0))
local tracerToggle = createButton(leftColumn, "✅ TRACER: ON", UDim2.fromOffset(0, 110), Color3.fromRGB(0, 200, 0))
local fbToggle = createButton(leftColumn, "🔆 FULLBRIGHT: OFF", UDim2.fromOffset(0, 150), Color3.fromRGB(180, 180, 0))

createSectionTitle(leftColumn, "⚡ OTHER ESP", UDim2.fromOffset(0, 195), Color3.fromRGB(255, 200, 100))

local fuseboxESPToggle = createButton(leftColumn, "⚡ FUSEBOX ESP: OFF", UDim2.fromOffset(0, 225), Color3.fromRGB(180, 180, 0))
local playerESPToggle = createButton(leftColumn, "👥 PLAYER ESP: OFF", UDim2.fromOffset(0, 265), Color3.fromRGB(180, 180, 0))

-- TAMBAHKAN TOMBOL ESP BARU
local allItemsESPToggle = createButton(leftColumn, "📦 ESP ALL ITEMS: OFF", UDim2.fromOffset(0, 305), Color3.fromRGB(180, 180, 0))
local cursedItemsESPToggle = createButton(leftColumn, "💀 ESP CURSED ITEMS: OFF", UDim2.fromOffset(0, 345), Color3.fromRGB(180, 180, 0))

-- === MIDDLE COLUMN - TELEPORT SECTION ===
createSectionTitle(middleColumn, "📍 TELEPORT", UDim2.fromScale(0, 0), Color3.fromRGB(255, 150, 255))

local tpToGhostBtn = createButton(middleColumn, "👻 TP TO GHOST", UDim2.fromOffset(0, 30), Color3.fromRGB(200, 100, 255))
local tpGhostBtn = createButton(middleColumn, "👻 TP GHOST TO ME", UDim2.fromOffset(0, 70), Color3.fromRGB(180, 80, 255))
local tpFuseboxBtn = createButton(middleColumn, "⚡ TP TO FUSEBOX", UDim2.fromOffset(0, 110), Color3.fromRGB(255, 200, 0))
local tpToCursedBtn = createButton(middleColumn, "💀 TP TO CURSED ITEM", UDim2.fromOffset(0, 150), Color3.fromRGB(200, 50, 50))

createSectionTitle(middleColumn, "📦 ITEM TELEPORT", UDim2.fromOffset(0, 195), Color3.fromRGB(100, 255, 150))

local tpItemsBtn = createButton(middleColumn, "📦 TP ITEMS (1-9)", UDim2.fromOffset(0, 225), Color3.fromRGB(100, 150, 255))
local bringItemsBtn = createButton(middleColumn, "🚚 BRING ITEMS TO ME", UDim2.fromOffset(0, 265), Color3.fromRGB(80, 180, 255))
local bringHouseBtn = createButton(middleColumn, "🏠 BRING HOUSE ITEMS", UDim2.fromOffset(0, 305), Color3.fromRGB(255, 150, 100))
local bringCursedBtn = createButton(middleColumn, "💀 BRING CURSED ITEMS", UDim2.fromOffset(0, 345), Color3.fromRGB(200, 50, 50))
local tpHouseBtn = createButton(middleColumn, "🏠 TP HOUSE ITEMS", UDim2.fromOffset(0, 385), Color3.fromRGB(255, 150, 100))
local tpCursedBtn = createButton(middleColumn, "💀 TP CURSED ITEMS", UDim2.fromOffset(0, 425), Color3.fromRGB(200, 50, 50))

-- TAMBAHKAN TOMBOL TURN ON ALL ELECTRONIC
local turnOnElectronicBtn = createButton(middleColumn, "🔌 TURN ON ALL ELECTRONIC", UDim2.fromOffset(0, 465), Color3.fromRGB(255, 200, 0))

createSectionTitle(middleColumn, "🔧 UTILITIES", UDim2.fromOffset(0, 510), Color3.fromRGB(255, 100, 100))

local deleteExitBtn = createButton(middleColumn, "🚪 DELETE EXIT DOOR", UDim2.fromOffset(0, 540), Color3.fromRGB(255, 80, 80))

-- === RIGHT COLUMN - GHOST INFO ===
createSectionTitle(rightColumn, "👻 GHOST INFO", UDim2.fromScale(0, 0), Color3.fromRGB(0, 255, 200))

detailsAge = Instance.new("TextLabel", rightColumn)
detailsAge.Size = UDim2.new(1, 0, 0, 20)
detailsAge.Position = UDim2.fromOffset(0, 30)
detailsAge.BackgroundTransparency = 1
detailsAge.TextColor3 = Color3.fromRGB(255, 255, 100)
detailsAge.Font = Enum.Font.Gotham
detailsAge.TextSize = 12
detailsAge.TextXAlignment = Enum.TextXAlignment.Left

detailsGender = Instance.new("TextLabel", rightColumn)
detailsGender.Size = UDim2.new(1, 0, 0, 20)
detailsGender.Position = UDim2.fromOffset(0, 55)
detailsGender.BackgroundTransparency = 1
detailsGender.TextColor3 = Color3.fromRGB(255, 100, 255)
detailsGender.Font = Enum.Font.Gotham
detailsGender.TextSize = 12
detailsGender.TextXAlignment = Enum.TextXAlignment.Left

detailsCurrent = Instance.new("TextLabel", rightColumn)
detailsCurrent.Size = UDim2.new(1, 0, 0, 20)
detailsCurrent.Position = UDim2.fromOffset(0, 80)
detailsCurrent.BackgroundTransparency = 1
detailsCurrent.TextColor3 = Color3.fromRGB(100, 255, 100)
detailsCurrent.Font = Enum.Font.GothamBold
detailsCurrent.TextSize = 12
detailsCurrent.TextXAlignment = Enum.TextXAlignment.Left

detailsFavorite = Instance.new("TextLabel", rightColumn)
detailsFavorite.Size = UDim2.new(1, 0, 0, 20)
detailsFavorite.Position = UDim2.fromOffset(0, 105)
detailsFavorite.BackgroundTransparency = 1
detailsFavorite.TextColor3 = Color3.fromRGB(255, 200, 100)
detailsFavorite.Font = Enum.Font.GothamBold
detailsFavorite.TextSize = 12
detailsFavorite.TextXAlignment = Enum.TextXAlignment.Left

detailsLidar = Instance.new("TextLabel", rightColumn)
detailsLidar.Size = UDim2.new(1, 0, 0, 20)
detailsLidar.Position = UDim2.fromOffset(0, 130)
detailsLidar.BackgroundTransparency = 1
detailsLidar.TextColor3 = Color3.fromRGB(200, 200, 255)
detailsLidar.Font = Enum.Font.Gotham
detailsLidar.TextSize = 12
detailsLidar.TextXAlignment = Enum.TextXAlignment.Left

detailsModel = Instance.new("TextLabel", rightColumn)
detailsModel.Size = UDim2.new(1, 0, 0, 20)
detailsModel.Position = UDim2.fromOffset(0, 155)
detailsModel.BackgroundTransparency = 1
detailsModel.TextColor3 = Color3.fromRGB(150, 255, 255)
detailsModel.Font = Enum.Font.Gotham
detailsModel.TextSize = 12
detailsModel.TextXAlignment = Enum.TextXAlignment.Left

-- === EVIDENCES SECTION ===
createSectionTitle(rightColumn, "🔍 EVIDENCES", UDim2.fromOffset(0, 185), Color3.fromRGB(255, 165, 0))

-- Definisikan semua evidence dengan posisi yang teratur
local evidenceLabels = {
    {name = "Handprints", icon = "👣", color = Color3.fromRGB(255, 200, 150), bold = false},
    {name = "Laser", icon = "🔦", color = Color3.fromRGB(255, 150, 50), bold = true},
    {name = "GhostOrb", icon = "👻", color = Color3.fromRGB(100, 255, 200), bold = false},
    {name = "Withered", icon = "🍂", color = Color3.fromRGB(150, 100, 50), bold = false},
    {name = "Writing", icon = "📝", color = Color3.fromRGB(200, 200, 100), bold = false},
    {name = "Temperature", icon = "🌡️", color = Color3.fromRGB(100, 200, 255), bold = true},
    {name = "Energy", icon = "⚡", color = Color3.fromRGB(255, 255, 100), bold = true},
    {name = "Multiple Cursed Possession", icon = "💀", color = Color3.fromRGB(255, 100, 100), bold = true},
    {name = "Fortune Teller", icon = "🔮", color = Color3.fromRGB(200, 150, 255), bold = false},
    {name = "Difficulty", icon = "🎯", color = Color3.fromRGB(255, 100, 100), bold = true}
}

-- Buat UI untuk setiap evidence
for i, evidence in ipairs(evidenceLabels) do
    local detail = Instance.new("TextLabel", rightColumn)
    detail.Size = UDim2.new(1, 0, 0, 20)
    detail.Position = UDim2.fromOffset(0, 215 + (i * 25))
    detail.BackgroundTransparency = 1
    detail.TextColor3 = evidence.color
    detail.Font = evidence.bold and Enum.Font.GothamBold or Enum.Font.Gotham
    detail.TextSize = 12
    detail.TextXAlignment = Enum.TextXAlignment.Left
    detail.Name = "details" .. evidence.name
    
    -- Assign ke variabel global
    if evidence.name == "Handprints" then detailsHandprints = detail
    elseif evidence.name == "Laser" then detailsLaser = detail
    elseif evidence.name == "GhostOrb" then detailsGhostOrb = detail
    elseif evidence.name == "Withered" then detailsWithered = detail
    elseif evidence.name == "Writing" then detailsWriting = detail
    elseif evidence.name == "Temperature" then detailsTemperature = detail
    elseif evidence.name == "Energy" then detailsEnergy = detail
    elseif evidence.name == "Multiple Cursed Possession" then detailsMultiple = detail
    elseif evidence.name == "Fortune Teller" then detailsFortune = detail
    elseif evidence.name == "Difficulty" then detailsDifficulty = detail end
end

-- Vex Label (di bawah semua evidence)
vexLabel = Instance.new("TextLabel", rightColumn)
vexLabel.Size = UDim2.new(1, 0, 0, 30)
vexLabel.Position = UDim2.fromOffset(0, 215 + (11 * 25)) -- Setelah 10 evidence
vexLabel.BackgroundColor3 = Color3.fromRGB(50, 20, 20)
vexLabel.Text = "⚠️ Ghost: Vex"
vexLabel.TextColor3 = Color3.fromRGB(255, 100, 100)
vexLabel.Font = Enum.Font.GothamBold
vexLabel.TextSize = 14
vexLabel.Visible = false
local vexCorner = Instance.new("UICorner", vexLabel)
vexCorner.CornerRadius = UDim.new(0, 6)

-- MINIMIZED INDICATOR
local minimizedFrame = Instance.new("Frame", screenGui)
minimizedFrame.Size = UDim2.fromOffset(250, 45)
minimizedFrame.Position = UDim2.new(0.5, -125, 0.05, 0)
minimizedFrame.BackgroundColor3 = Color3.fromRGB(15, 15, 20)
minimizedFrame.BorderSizePixel = 0
minimizedFrame.Visible = false
minimizedFrame.Active = true
minimizedFrame.Draggable = true

local minCorner2 = Instance.new("UICorner", minimizedFrame)
minCorner2.CornerRadius = UDim.new(0, 10)

local minLabel = Instance.new("TextLabel", minimizedFrame)
minLabel.Size = UDim2.new(0.7, 0, 1, 0)
minLabel.BackgroundTransparency = 1
minLabel.Text = "👻 ESP TOOLS"
minLabel.TextColor3 = Color3.fromRGB(100, 200, 255)
minLabel.Font = Enum.Font.GothamBold
minLabel.TextSize = 16
minLabel.TextXAlignment = Enum.TextXAlignment.Left
minLabel.Position = UDim2.fromOffset(10, 0)

local restoreBtn = Instance.new("TextButton", minimizedFrame)
restoreBtn.Size = UDim2.fromOffset(35, 35)
restoreBtn.Position = UDim2.new(1, -40, 0.5, -17.5)
restoreBtn.BackgroundColor3 = Color3.fromRGB(100, 200, 100)
restoreBtn.Text = "▢"
restoreBtn.Font = Enum.Font.GothamBold
restoreBtn.TextSize = 18
local restoreCorner = Instance.new("UICorner", restoreBtn)
restoreCorner.CornerRadius = UDim.new(0, 6)

-- === TOGGLE FUNCTIONS ===
espToggle.MouseButton1Click:Connect(function()
    espEnabled = not espEnabled
    espToggle.Text = espEnabled and "✅ ESP TEXT: ON" or "❌ ESP TEXT: OFF"
    espToggle.BackgroundColor3 = espEnabled and Color3.fromRGB(0,200,0) or Color3.fromRGB(200,0,0)
    if not espEnabled and billboard then 
        billboard:Destroy() 
        billboard = nil 
    end
    if espEnabled then createESP() end
end)

boxToggle.MouseButton1Click:Connect(function()
    boxEnabled = not boxEnabled
    boxToggle.Text = boxEnabled and "✅ RAINBOW BOX: ON" or "❌ RAINBOW BOX: OFF"
    boxToggle.BackgroundColor3 = boxEnabled and Color3.fromRGB(0,200,0) or Color3.fromRGB(200,0,0)
    if box and not boxEnabled then 
        box:Destroy() 
        box = nil 
    end
    if boxEnabled and ghost then createESP() end
end)

tracerToggle.MouseButton1Click:Connect(function()
    tracerEnabled = not tracerEnabled
    tracerToggle.Text = tracerEnabled and "✅ TRACER: ON" or "❌ TRACER: OFF"
    tracerToggle.BackgroundColor3 = tracerEnabled and Color3.fromRGB(0,200,0) or Color3.fromRGB(200,0,0)
    if beam and not tracerEnabled then 
        beam:Destroy() 
        beam = nil 
    end
    if tracerEnabled and ghost then createESP() end
end)

fbToggle.MouseButton1Click:Connect(function()
    fullbrightEnabled = not fullbrightEnabled
    fbToggle.Text = fullbrightEnabled and "🔆 FULLBRIGHT: ON" or "🔆 FULLBRIGHT: OFF"
    fbToggle.BackgroundColor3 = fullbrightEnabled and Color3.fromRGB(0,200,0) or Color3.fromRGB(180,180,0)
    toggleFullbright()
end)

fuseboxESPToggle.MouseButton1Click:Connect(function()
    fuseboxESPEnabled = not fuseboxESPEnabled
    fuseboxESPToggle.Text = fuseboxESPEnabled and "⚡ FUSEBOX ESP: ON" or "⚡ FUSEBOX ESP: OFF"
    fuseboxESPToggle.BackgroundColor3 = fuseboxESPEnabled and Color3.fromRGB(0,200,0) or Color3.fromRGB(180,180,0)
    createFuseboxESP()
end)

playerESPToggle.MouseButton1Click:Connect(function()
    playerESPEnabled = not playerESPEnabled
    playerESPToggle.Text = playerESPEnabled and "👥 PLAYER ESP: ON" or "👥 PLAYER ESP: OFF"
    playerESPToggle.BackgroundColor3 = playerESPEnabled and Color3.fromRGB(0,200,0) or Color3.fromRGB(180,180,0)
    createPlayerESP()
end)

-- === TOGGLE FUNCTIONS BARU ===
allItemsESPToggle.MouseButton1Click:Connect(function()
    allItemsESPEnabled = not allItemsESPEnabled
    allItemsESPToggle.Text = allItemsESPEnabled and "📦 ESP ALL ITEMS: ON" or "📦 ESP ALL ITEMS: OFF"
    allItemsESPToggle.BackgroundColor3 = allItemsESPEnabled and Color3.fromRGB(0,200,0) or Color3.fromRGB(180,180,0)
    createAllItemsESP()
end)

cursedItemsESPToggle.MouseButton1Click:Connect(function()
    cursedItemsESPEnabled = not cursedItemsESPEnabled
    cursedItemsESPToggle.Text = cursedItemsESPEnabled and "💀 ESP CURSED ITEMS: ON" or "💀 ESP CURSED ITEMS: OFF"
    cursedItemsESPToggle.BackgroundColor3 = cursedItemsESPEnabled and Color3.fromRGB(0,200,0) or Color3.fromRGB(180,180,0)
    createCursedItemsESP()
end)

-- === TOOLS FUNCTIONS ===
tpItemsBtn.MouseButton1Click:Connect(tpAllItems)
bringItemsBtn.MouseButton1Click:Connect(bringItemsToMe)
bringHouseBtn.MouseButton1Click:Connect(bringHouseItemsToMe)
bringCursedBtn.MouseButton1Click:Connect(bringCursedItemsToMe)
tpHouseBtn.MouseButton1Click:Connect(tpHouseItems)
tpCursedBtn.MouseButton1Click:Connect(tpCursedPossession)
tpToCursedBtn.MouseButton1Click:Connect(tpToCursedItems)
tpGhostBtn.MouseButton1Click:Connect(tpGhostToMe)
tpToGhostBtn.MouseButton1Click:Connect(tpToGhost)
tpFuseboxBtn.MouseButton1Click:Connect(tpToFusebox)
turnOnElectronicBtn.MouseButton1Click:Connect(turnOnAllElectronic)  -- Tambahkan ini
deleteExitBtn.MouseButton1Click:Connect(deleteExitDoor)

-- === WINDOW CONTROLS ===
minimizeBtn.MouseButton1Click:Connect(function()
    guiMinimized = not guiMinimized
    mainFrame.Visible = not guiMinimized
    minimizedFrame.Visible = guiMinimized
end)

restoreBtn.MouseButton1Click:Connect(function()
    guiMinimized = false
    mainFrame.Visible = true
    minimizedFrame.Visible = false
end)

closeBtn.MouseButton1Click:Connect(function()
    screenGui:Destroy()
    if billboard then billboard:Destroy() end
    if box then box:Destroy() end
    if beam then beam:Destroy() end
    clearFuseboxESP()
    clearPlayerESP()
    clearAllItemsESP()  -- Tambahkan ini
    clearCursedItemsESP()  -- Tambahkan ini
    if fullbrightEnabled then toggleFullbright() end
end)

-- === INIT ===
createESP()
updateAll()

if ghost then
    ghost:GetAttributeChangedSignal("Age"):Connect(updateAll)
    ghost:GetAttributeChangedSignal("Gender"):Connect(updateAll)
    ghost:GetAttributeChangedSignal("CurrentRoom"):Connect(updateAll)
    ghost:GetAttributeChangedSignal("FavoriteRoom"):Connect(updateAll)
    ghost:GetAttributeChangedSignal("InvisibleOnLIDAR"):Connect(updateAll)
    ghost:GetAttributeChangedSignal("VisualModel"):Connect(updateAll)
    ghost:GetAttributeChangedSignal("LaserVisible"):Connect(updateAll)  -- Tambahkan ini
end

-- === RAINBOW ANIMATION ===
RunService.Heartbeat:Connect(function()
    if box and boxEnabled then
        box.Color3 = Color3.fromHSV(tick() % 1, 1, 1)
    end
end)

-- === AUTO UPDATE ===
spawn(function()
    while true do
        if ghost and ghost.Parent then
            updateAll()
        end
        task.wait(1)
    end
end)

-- Auto-refresh player ESP
spawn(function()
    while true do
        if playerESPEnabled then
            createPlayerESP()
        end
        task.wait(5)
    end
end)

-- Update root reference if character respawns
LocalPlayer.CharacterAdded:Connect(function(char)
    char:WaitForChild("HumanoidRootPart")
    root = char.HumanoidRootPart
    createESP()
    if fuseboxESPEnabled then createFuseboxESP() end
    if playerESPEnabled then createPlayerESP() end
end)

print("👻 Phasmophobia ESP & Tools loaded successfully!")
