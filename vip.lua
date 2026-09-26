--[[
    ================================================================
    RITO HUB - BLOX FRUITS ALL-IN-ONE SCRIPT
    Supported: Sea 1, Sea 2, Sea 3
    UI Library: Orion Library
    Platform: RScripts.net Release
    Developer: Rito
    ================================================================
--]]

-- Load Orion Library
local OrionLib = loadstring(game:HttpGet('https://raw.githubusercontent.com/shlexware/Orion/main/source'))()
local Window = OrionLib:MakeWindow({
    Name = "Rito Hub | Blox Fruits All-In-One", 
    HidePremium = false, 
    SaveConfig = true, 
    ConfigFolder = "RitoHubConfig",
    IntroText = "Welcome to Rito Hub"
})

-- Services
local Players = game:GetService("Players")
local TweenService = game:GetService("TweenService")
local VirtualUser = game:GetService("VirtualUser")
local Workspace = game:GetService("Workspace")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local TeleportService = game:GetService("TeleportService")
local HttpService = game:GetService("HttpService")
local Lighting = game:GetService("Lighting")

local LocalPlayer = Players.LocalPlayer

-- Global Settings
_G.AutoFarm = false
_G.FastAttack = true
_G.SelectWeapon = "Melee"

_G.AutoRaid = false
_G.SelectedRaid = "Flame"
_G.AutoBuyChip = true

_G.ESP_Player = false
_G.ESP_Fruit = false

-- Anti-AFK Handler
LocalPlayer.Idled:Connect(function()
    VirtualUser:Button2Down(Vector2.new(0, 0), Workspace.CurrentCamera.CFrame)
    task.wait(1)
    VirtualUser:Button2Up(Vector2.new(0, 0), Workspace.CurrentCamera.CFrame)
end)

-- Core Helpers
local function GetSea()
    local placeId = game.PlaceId
    if placeId == 2753915549 then return 1
    elseif placeId == 4442272183 then return 2
    elseif placeId == 7449423635 then return 3 end
    return 1
end

local function EquipWeapon(weaponType)
    local character = LocalPlayer.Character
    if not character then return end
    for _, tool in pairs(LocalPlayer.Backpack:GetChildren()) do
        if tool:IsA("Tool") and tool.ToolTip == weaponType then
            character.Humanoid:EquipTool(tool)
        end
    end
end

local function FastAttack()
    if _G.FastAttack then
        pcall(function()
            VirtualUser:CaptureController()
            VirtualUser:ClickButton1(Vector2.new(50, 50))
        end)
    end
end

-- =================================================================
-- TABS & UI ELEMENTS
-- =================================================================

-- 1. Auto Farm Tab
local MainTab = Window:MakeTab({Name = "Auto Farm", Icon = "rbxassetid://4483345998", PremiumOnly = false})

MainTab:AddToggle({
    Name = "Auto Farm Level & Quái",
    Default = false,
    Callback = function(Value) _G.AutoFarm = Value end    
})

MainTab:AddToggle({
    Name = "Fast Attack (Đánh Nhanh)",
    Default = true,
    Callback = function(Value) _G.FastAttack = Value end    
})

MainTab:AddDropdown({
    Name = "Chọn Vũ Khí Sử Dụng",
    Default = "Melee",
    Options = {"Melee", "Sword", "Blox Fruit"},
    Callback = function(Value) _G.SelectWeapon = Value end
})

-- 2. Auto Raid Tab
local RaidTab = Window:MakeTab({Name = "Auto Raid", Icon = "rbxassetid://4483345998", PremiumOnly = false})

RaidTab:AddToggle({
    Name = "Auto Raid (Dungeon)",
    Default = false,
    Callback = function(Value) _G.AutoRaid = Value end
})

RaidTab:AddToggle({
    Name = "Auto Mua Chip Raid",
    Default = true,
    Callback = function(Value) _G.AutoBuyChip = Value end
})

RaidTab:AddDropdown({
    Name = "Chọn Loại Raid",
    Default = "Flame",
    Options = {"Flame", "Ice", "Quake", "Light", "Dark", "Rumble", "Magma", "Buddha", "Sand"},
    Callback = function(Value) _G.SelectedRaid = Value end
})

-- 3. Visual / ESP Tab
local ESPTab = Window:MakeTab({Name = "Visual / ESP", Icon = "rbxassetid://4483345998", PremiumOnly = false})

ESPTab:AddToggle({
    Name = "ESP Player (Người chơi)",
    Default = false,
    Callback = function(Value) _G.ESP_Player = Value end
})

ESPTab:AddToggle({
    Name = "ESP Devil Fruit (Trái Ác Quỷ)",
    Default = false,
    Callback = function(Value) _G.ESP_Fruit = Value end
})

-- 4. Sea Events Config UI Tab
local SeaTab = Window:MakeTab({Name = "Sea Events", Icon = "rbxassetid://4483345998", PremiumOnly = false})

SeaTab:AddSection({Name = "Cấu Hình Săn Event"})
SeaTab:AddToggle({Name = "Cấu hình Săn Sea Beast", Default = false, Callback = function(v) end})
SeaTab:AddToggle({Name = "Cấu hình Săn Tàu Ma", Default = false, Callback = function(v) end})

-- 5. System & Misc Tab
local SettingsTab = Window:MakeTab({Name = "Hệ Thống / Misc", Icon = "rbxassetid://4483345998", PremiumOnly = false})

SettingsTab:AddSection({Name = "Quản Lý Server"})
SettingsTab:AddButton({
    Name = "Kết Nối Lại Server (Rejoin)",
    Callback = function() TeleportService:Teleport(game.PlaceId, LocalPlayer) end
})

SettingsTab:AddButton({
    Name = "Đổi Server Ngẫu Nhiên (Server Hop)",
    Callback = function()
        pcall(function()
            local servers = HttpService:JSONDecode(game:HttpGet("https://games.roblox.com/v1/games/" .. game.PlaceId .. "/servers/Public?sortOrder=Asc&limit=100"))
            for _, server in pairs(servers.data) do
                if server.id ~= game.JobId and server.playing < server.maxPlayers then
                    TeleportService:TeleportToPlaceInstance(game.PlaceId, server.id, LocalPlayer)
                    break
                end
            end
        end)
    end
})

SettingsTab:AddSection({Name = "Tối Ưu Hóa Game"})
SettingsTab:AddButton({
    Name = "Bật Chế Độ Giảm Lag (FPS Boost)",
    Callback = function()
        pcall(function()
            Lighting.GlobalShadows = false
            for _, v in pairs(Workspace:GetDescendants()) do
                if v:IsA("BasePart") then
                    v.Material = Enum.Material.SmoothPlastic
                elseif v:IsA("Decal") or v:IsA("Texture") then
                    v:Destroy()
                elseif v:IsA("ParticleEmitter") then
                    v.Enabled = false
                end
            end
        end)
    end
})

-- Hotkey Toggle UI (Right Control Key)
OrionLib:Init()
