-- // Comet Library
-- // Made by re_sistance
-- // You can copy and make your own remix lol.
-- Services
if debugX then
	warn('loading lol')
end
local function getService(name)
    local service = game:GetService(name)
    return if cloneref then cloneref(service) else service
end

local UserInputService = getService("UserInputService")
local TweenService = getService("TweenService")
local RunService = getService("RunService")
local Players = getService("Players")
local HttpService = getService("HttpService")

local LocalPlayer = Players.LocalPlayer
local Mouse = LocalPlayer:GetMouse()

-- Library Table
local CometLib = {
    Elements = {},
    ThemeObjects = {},
    Connections = {},
    Flags = {},
    Themes = {},
    SelectedTheme = "Default",
    Folder = nil,
    SaveCfg = false
}

-- Default Themes
CometLib.Themes = {
    Default = {
        Main = Color3.fromRGB(25, 25, 25),
        Secondary = Color3.fromRGB(32, 32, 32),
        MainColor = Color3.fromRGB(16, 16, 16),
        SecondaryColor = Color3.fromRGB(22, 22, 22),
        Text = Color3.fromRGB(240, 240, 240),
        TextDark = Color3.fromRGB(150, 150, 150),
        TextColor = Color3.fromRGB(240, 240, 240),
        Stroke = Color3.fromRGB(60, 60, 60),
        Divider = Color3.fromRGB(60, 60, 60),
        TabBackground = Color3.fromRGB(80, 80, 80),
        TabStroke = Color3.fromRGB(85, 85, 85),
        TabBackgroundSelected = Color3.fromRGB(210, 210, 210),
        TabTextColor = Color3.fromRGB(240, 240, 240),
        SelectedTabTextColor = Color3.fromRGB(50, 50, 50),
        SliderColor = Color3.fromRGB(255, 255, 255),
        ToggleEnabled = Color3.fromRGB(255, 255, 255),
        ToggleDisabled = Color3.fromRGB(139, 139, 139),
        CardButton = Color3.fromRGB(230, 230, 230),
        NotificationActionsBackground = Color3.fromRGB(230, 230, 230),
        ImageColor = Color3.fromRGB(255, 255, 255),
        TweenInfo = TweenInfo.new(0.25, Enum.EasingStyle.Quint)
    },
    RobloxDark = {
        Main = Color3.fromRGB(25, 25, 25),
        Secondary = Color3.fromRGB(32, 32, 32),
        MainColor = Color3.fromRGB(16, 16, 16),
        SecondaryColor = Color3.fromRGB(22, 22, 22),
        Text = Color3.fromRGB(240, 240, 240),
        TextDark = Color3.fromRGB(150, 150, 150),
        TextColor = Color3.fromRGB(240, 240, 240),
        Stroke = Color3.fromRGB(60, 60, 60),
        Divider = Color3.fromRGB(60, 60, 60),
        TabBackground = Color3.fromRGB(80, 80, 80),
        TabStroke = Color3.fromRGB(85, 85, 85),
        TabBackgroundSelected = Color3.fromRGB(210, 210, 210),
        TabTextColor = Color3.fromRGB(240, 240, 240),
        SelectedTabTextColor = Color3.fromRGB(50, 50, 50),
        SliderColor = Color3.fromRGB(255, 255, 255),
        ToggleEnabled = Color3.fromRGB(255, 255, 255),
        ToggleDisabled = Color3.fromRGB(139, 139, 139),
        CardButton = Color3.fromRGB(230, 230, 230),
        NotificationActionsBackground = Color3.fromRGB(230, 230, 230),
        ImageColor = Color3.fromRGB(255, 255, 255),
        TweenInfo = TweenInfo.new(0.25, Enum.EasingStyle.Quint)
    }
}

function CometLib:CustomizeTheme(overrides)
    local theme = table.clone(self.Themes[self.SelectedTheme])
    for k, v in pairs(overrides) do
        theme[k] = v
    end
    self.Themes["Custom"] = theme
    self.SelectedTheme = "Custom"
end

function CometLib:GetTheme()
    return self.Themes[self.SelectedTheme]
end

function CometLib:SetTheme(themeName)
    if self.Themes[themeName] then
        self.SelectedTheme = themeName
    else
        warn("Theme does not exist: " .. tostring(themeName))
    end
end

function CometLib:SaveThemePreference()
    if writefile then
        local data = HttpService:JSONEncode({ Theme = self.SelectedTheme })
        writefile("CometThemePreference.json", data)
    end
end

function CometLib:LoadThemePreference()
    if isfile and isfile("CometThemePreference.json") then
        local data = HttpService:JSONDecode(readfile("CometThemePreference.json"))
        if data and data.Theme and self.Themes[data.Theme] then
            self:SetTheme(data.Theme)
        end
    end
end

----==[[ Feather Icons ]]==----
local Icons = {}
local Success, Response = pcall(function()
    local Icons = useStudio and require(script.Parent.icons) or loadWithTimeout('https://raw.githubusercontent.com/SiriusSoftwareLtd/Rayfield/refs/heads/main/icons.lua')
end)
if not Success then warn("Failed to load Feather Icons: " .. tostring(Response)) end

local function GetIcon(IconName)
    return Icons[IconName] or IconName
end

-- Converts ID to asset URI. Returns rbxassetid://0 if ID is not a number
local function GetAssetUri(id)
    local assetUri = "rbxassetid://0"
    if type(id) == "number" then
        assetUri = "rbxassetid://" .. id
    elseif type(id) == "string" and not Icons then
        warn("Comet | Cannot use Lucide icons as icons library is not loaded")
    else
        warn("Comet | The icon argument must either be an icon ID (number) or a Lucide icon name (string)")
    end
    return assetUri
end

-- Element Constructor
local function CreateElement(name, func)
    CometLib.Elements[name] = func
end

CreateElement("Image", function(ImageID, props)
    local ImageNew = Instance.new("ImageLabel")
    ImageNew.BackgroundTransparency = 1
    ImageNew.Image = GetIcon(ImageID)
    if typeof(props) == "table" then
        for k, v in pairs(props) do
            ImageNew[k] = v
        end
    end
    return ImageNew
end)

-- Main UI Creator
function CometLib:MakeWindow(options)
    local CoreGui = getService("CoreGui")
    local UIS = getService("UserInputService")

    local ScreenGui = Instance.new("ScreenGui", CoreGui)
    ScreenGui.Name = "CometWindow"
    ScreenGui.ResetOnSpawn = false

    local Frame = Instance.new("Frame", ScreenGui)
    Frame.Size = UDim2.new(0, 450, 0, 300)
    Frame.Position = UDim2.new(0.5, -225, 0.5, -150)
    Frame.BackgroundColor3 = CometLib.Themes[CometLib.SelectedTheme].Main
    Frame.BorderSizePixel = 0
    Frame.Name = options.Name or "Window"

    local Title = Instance.new("TextLabel", Frame)
    Title.Text = options.Name or "Comet UI"
    Title.Size = UDim2.new(1, 0, 0, 30)
    Title.BackgroundTransparency = 1
    Title.TextColor3 = Color3.fromRGB(255, 255, 255)
    Title.Font = Enum.Font.GothamBold
    Title.TextSize = 18

    -- Dragging
    local dragging, dragInput, dragStart, startPos

    Frame.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 then
            dragging = true
            dragStart = input.Position
            startPos = Frame.Position

            input.Changed:Connect(function()
                if input.UserInputState == Enum.UserInputState.End then
                    dragging = false
                end
            end)
        end
    end)

    Frame.InputChanged:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseMovement then
            dragInput = input
        end
    end)

    UIS.InputChanged:Connect(function(input)
        if input == dragInput and dragging then
            local delta = input.Position - dragStart
            Frame.Position = UDim2.new(startPos.X.Scale, startPos.X.Offset + delta.X, startPos.Y.Scale, startPos.Y.Offset + delta.Y)
        end
    end)

    local TabHolder = Instance.new("Frame", Frame)
    TabHolder.Size = UDim2.new(0, 120, 1, -30)
    TabHolder.Position = UDim2.new(0, 0, 0, 30)
    TabHolder.BackgroundColor3 = CometLib.Themes[CometLib.SelectedTheme].Secondary
    TabHolder.BorderSizePixel = 0

    local Pages = Instance.new("Frame", Frame)
    Pages.Size = UDim2.new(1, -120, 1, -30)
    Pages.Position = UDim2.new(0, 120, 0, 30)
    Pages.BackgroundColor3 = CometLib.Themes[CometLib.SelectedTheme].MainColor
    Pages.BorderSizePixel = 0

    local Tabs = {}

    function CometLib:MakeTab(tabData)
        local Button = Instance.new("TextButton", TabHolder)
        Button.Text = tabData.Name
        Button.Size = UDim2.new(1, 0, 0, 40)
        Button.BackgroundColor3 = CometLib.Themes[CometLib.SelectedTheme].TabBackground
        Button.TextColor3 = CometLib.Themes[CometLib.SelectedTheme].TabTextColor
        Button.Font = Enum.Font.Gotham
        Button.TextSize = 14

        local Page = Instance.new("ScrollingFrame", Pages)
        Page.Size = UDim2.new(1, 0, 1, 0)
        Page.Visible = false
        Page.ScrollBarThickness = 6
        Page.CanvasSize = UDim2.new(0, 0, 0, 0)
        Page.AutomaticCanvasSize = Enum.AutomaticSize.Y
        Page.BackgroundTransparency = 1

        local UIList = Instance.new("UIListLayout", Page)
        UIList.Padding = UDim.new(0, 6)
        UIList.SortOrder = Enum.SortOrder.LayoutOrder

        Button.MouseButton1Click:Connect(function()
            for _, t in pairs(Tabs) do
                t.Page.Visible = false
            end
            Page.Visible = true
        end)

        Tabs[#Tabs + 1] = { Page = Page }

        local tabAPI = {}

        function tabAPI:AddButton(data)
            local Btn = Instance.new("TextButton", Page)
            Btn.Text = data.Name
            Btn.Size = UDim2.new(1, -12, 0, 40)
            Btn.Position = UDim2.new(0, 6, 0, 0)
            Btn.BackgroundColor3 = Color3.fromRGB(45, 45, 45)
            Btn.TextColor3 = Color3.fromRGB(255, 255, 255)
            Btn.Font = Enum.Font.Gotham
            Btn.TextSize = 14
            Btn.AutoButtonColor = true

            Btn.MouseButton1Click:Connect(function()
                if data.Callback then
                    data.Callback()
                end
            end)
        end

        return tabAPI
    end

    return CometLib
end

return CometLib
