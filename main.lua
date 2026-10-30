--[[
    OEO Lib
    Liquid Chrome Edition
    Animated Executor UI
]]

local OEO = {}

local Players = game:GetService("Players")
local UserInputService = game:GetService("UserInputService")
local TweenService = game:GetService("TweenService")
local CoreGui = game:GetService("CoreGui")

local Player = Players.LocalPlayer

local Parent
pcall(function()
    Parent = gethui()
end)

Parent = Parent or CoreGui

pcall(function()
    local old = Parent:FindFirstChild("OEO_Lib")
    if old then old:Destroy() end
end)

local ScreenGui = Instance.new("ScreenGui")
ScreenGui.Name = "OEO_Lib"
ScreenGui.ResetOnSpawn = false
ScreenGui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling

pcall(function()
    ScreenGui.Parent = Parent
end)

if not ScreenGui.Parent then
    ScreenGui.Parent = Player:WaitForChild("PlayerGui")
end

local Theme = {
    OuterTransparency = 0.18,
    FaceTransparency = 0.22,
    ElementTransparency = 0.25,

    Text = Color3.fromRGB(235, 235, 242),
    Muted = Color3.fromRGB(145, 148, 160),

    Silver = Color3.fromRGB(195, 202, 220),
    Dark = Color3.fromRGB(15, 16, 21),
}

local Connections = {}
local LibraryDestroyed = false

local function Connect(signal, callback)
    local connection = signal:Connect(callback)
    table.insert(Connections, connection)
    return connection
end

local function Tween(object, duration, properties, style, direction)
    local info = TweenInfo.new(
        duration,
        style or Enum.EasingStyle.Quart,
        direction or Enum.EasingDirection.Out
    )

    local animation = TweenService:Create(object, info, properties)
    animation:Play()

    return animation
end

local function Corner(parent, radius)
    local corner = Instance.new("UICorner")
    corner.CornerRadius = UDim.new(0, radius or 8)
    corner.Parent = parent
    return corner
end

local function AddStroke(parent, color, transparency, thickness)
    local stroke = Instance.new("UIStroke")
    stroke.Color = color or Theme.Silver
    stroke.Transparency = transparency or 0.4
    stroke.Thickness = thickness or 1
    stroke.Parent = parent
    return stroke
end

local function AddGradient(parent, colors, rotation)
    local gradient = Instance.new("UIGradient")
    gradient.Color = ColorSequence.new(colors)
    gradient.Rotation = rotation or 90
    gradient.Parent = parent
    return gradient
end

local function MakeText(parent, text, size, color, font)
    local label = Instance.new("TextLabel")
    label.BackgroundTransparency = 1
    label.Text = text or ""
    label.TextSize = size or 13
    label.TextColor3 = color or Theme.Text
    label.Font = font or Enum.Font.Gotham
    label.TextXAlignment = Enum.TextXAlignment.Left
    label.TextYAlignment = Enum.TextYAlignment.Center
    label.Parent = parent
    return label
end

-- Chrome surface
local function ChromeSurface(parent, size, radius, zindex)
    local shell = Instance.new("Frame")
    shell.Name = "ChromeShell"
    shell.Size = size
    shell.BackgroundColor3 = Color3.fromRGB(180, 185, 200)
    shell.BackgroundTransparency = Theme.OuterTransparency
    shell.BorderSizePixel = 0
    shell.ZIndex = zindex or 1
    shell.Parent = parent

    Corner(shell, radius or 10)

    local chrome = AddGradient(shell, {
        Color3.fromRGB(235, 240, 250),
        Color3.fromRGB(85, 90, 105),
        Color3.fromRGB(205, 210, 225),
        Color3.fromRGB(55, 60, 75),
        Color3.fromRGB(220, 225, 240),
    }, 45)

    local face = Instance.new("Frame")
    face.Name = "GlassFace"
    face.Position = UDim2.fromOffset(1, 1)
    face.Size = UDim2.new(1, -2, 1, -2)
    face.BackgroundColor3 = Theme.Dark
    face.BackgroundTransparency = Theme.FaceTransparency
    face.BorderSizePixel = 0
    face.ZIndex = (zindex or 1) + 1
    face.Parent = shell

    Corner(face, math.max((radius or 10) - 1, 0))

    AddGradient(face, {
        Color3.fromRGB(42, 44, 54),
        Color3.fromRGB(13, 14, 19),
        Color3.fromRGB(27, 29, 37),
    }, 90)

    local highlight = Instance.new("Frame")
    highlight.Name = "TopHighlight"
    highlight.Position = UDim2.fromOffset(10, 1)
    highlight.Size = UDim2.new(1, -20, 0, 1)
    highlight.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
    highlight.BackgroundTransparency = 0.55
    highlight.BorderSizePixel = 0
    highlight.ZIndex = (zindex or 1) + 2
    highlight.Parent = face

    -- Subtle chrome shimmer
    task.spawn(function()
        while shell.Parent and not LibraryDestroyed do
            chrome.Offset = Vector2.new(-1, 0)

            local animation = TweenService:Create(
                chrome,
                TweenInfo.new(
                    3.5,
                    Enum.EasingStyle.Sine,
                    Enum.EasingDirection.InOut
                ),
                {Offset = Vector2.new(1, 0)}
            )

            animation:Play()
            animation.Completed:Wait()
            task.wait(1.5)
        end
    end)

    return shell, face
end

-- Animated button
local function MakeButton(parent, text, size, zindex)
    local shell, face = ChromeSurface(parent, size, 7, zindex or 8)

    shell.BackgroundTransparency = Theme.ElementTransparency
    face.BackgroundTransparency = Theme.ElementTransparency

    local stroke = AddStroke(face, Theme.Silver, 0.8, 1)

    local button = Instance.new("TextButton")
    button.Name = "Button"
    button.Size = UDim2.fromScale(1, 1)
    button.BackgroundTransparency = 1
    button.Text = text or ""
    button.TextColor3 = Theme.Text
    button.TextSize = 13
    button.Font = Enum.Font.GothamMedium
    button.AutoButtonColor = false
    button.ZIndex = (zindex or 8) + 3
    button.Parent = face

    Connect(button.MouseEnter, function()
        Tween(face, 0.18, {
            BackgroundTransparency = 0.08
        })

        Tween(stroke, 0.18, {
            Transparency = 0.25
        })
    end)

    Connect(button.MouseLeave, function()
        Tween(face, 0.18, {
            BackgroundTransparency = Theme.ElementTransparency
        })

        Tween(stroke, 0.18, {
            Transparency = 0.8
        })
    end)

    Connect(button.MouseButton1Down, function()
        Tween(face, 0.08, {
            BackgroundTransparency = 0
        }, Enum.EasingStyle.Quad)
    end)

    Connect(button.MouseButton1Up, function()
        Tween(face, 0.15, {
            BackgroundTransparency = 0.08
        })
    end)

    return shell, face, button
end

-- Window
function OEO:CreateWindow(options)
    options = options or {}

    local Window = {}
    Window.Tabs = {}
    Window.ActiveTab = nil

    local width = options.Width or 570
    local height = options.Height or 390

    local MainShell, Main = ChromeSurface(
        ScreenGui,
        UDim2.fromOffset(width, height),
        13,
        1
    )

    MainShell.Name = "OEO_Window"
    MainShell.AnchorPoint = Vector2.new(0.5, 0.5)
    MainShell.Position = UDim2.fromScale(0.5, 0.5)
    MainShell.ClipsDescendants = true

    MainShell.Size = UDim2.fromOffset(width * 0.92, height * 0.92)

    Main.BackgroundTransparency = Theme.FaceTransparency
    Main.ClipsDescendants = true

    local MainStroke = AddStroke(Main, Theme.Silver, 0.65, 1)

    -- Open animation
    Tween(
        MainShell,
        0.55,
        {Size = UDim2.fromOffset(width, height)},
        Enum.EasingStyle.Back
    )

    Tween(MainStroke, 0.7, {
        Transparency = 0.25
    })

    -- Header
    local HeaderShell, Header = ChromeSurface(
        Main,
        UDim2.new(1, -12, 0, 43),
        9,
        5
    )

    HeaderShell.Position = UDim2.fromOffset(6, 6)
    HeaderShell.BackgroundTransparency = Theme.ElementTransparency
    Header.BackgroundTransparency = Theme.ElementTransparency

    local Title = MakeText(
        Header,
        options.Name or "OEO Lib",
        15,
        Theme.Text,
        Enum.Font.GothamBold
    )

    Title.Position = UDim2.fromOffset(13, 0)
    Title.Size = UDim2.new(1, -55, 1, 0)

    local Close = Instance.new("TextButton")
    Close.Name = "Close"
    Close.BackgroundTransparency = 1
    Close.Size = UDim2.fromOffset(34, 34)
    Close.Position = UDim2.new(1, -38, 0, 4)
    Close.Text = "×"
    Close.TextSize = 23
    Close.TextColor3 = Theme.Text
    Close.Font = Enum.Font.Gotham
    Close.ZIndex = 10
    Close.Parent = Header

    Connect(Close.MouseEnter, function()
        Tween(Close, 0.15, {
            TextColor3 = Color3.fromRGB(255, 100, 110)
        })
    end)

    Connect(Close.MouseLeave, function()
        Tween(Close, 0.15, {
            TextColor3 = Theme.Text
        })
    end)

    local closed = false

    local function CloseWindow()
        if closed then return end
        closed = true

        Tween(MainShell, 0.3, {
            Size = UDim2.fromOffset(width * 0.85, height * 0.85)
        }, Enum.EasingStyle.Back, Enum.EasingDirection.In)

        task.wait(0.3)

        if MainShell.Parent then
            MainShell.Visible = false
        end

        closed = false
    end

    Connect(Close.MouseButton1Click, CloseWindow)

    -- Dragging
    local dragging = false
    local dragStart
    local startPosition

    Connect(Header.InputBegan, function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1
            or input.UserInputType == Enum.UserInputType.Touch then

            dragging = true
            dragStart = input.Position
            startPosition = MainShell.Position
        end
    end)

    Connect(UserInputService.InputChanged, function(input)
        if dragging and (
            input.UserInputType == Enum.UserInputType.MouseMovement
            or input.UserInputType == Enum.UserInputType.Touch
        ) then
            local delta = input.Position - dragStart

            MainShell.Position = UDim2.new(
                startPosition.X.Scale,
                startPosition.X.Offset + delta.X,
                startPosition.Y.Scale,
                startPosition.Y.Offset + delta.Y
            )
        end
    end)

    Connect(UserInputService.InputEnded, function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1
            or input.UserInputType == Enum.UserInputType.Touch then
            dragging = false
        end
    end)

    -- Sidebar
    local SidebarShell, Sidebar = ChromeSurface(
        Main,
        UDim2.new(0, 137, 1, -61),
        9,
        5
    )

    SidebarShell.Position = UDim2.fromOffset(6, 55)
    SidebarShell.BackgroundTransparency = Theme.ElementTransparency
    Sidebar.BackgroundTransparency = Theme.ElementTransparency

    local TabList = Instance.new("ScrollingFrame")
    TabList.Name = "TabList"
    TabList.BackgroundTransparency = 1
    TabList.BorderSizePixel = 0
    TabList.Size = UDim2.new(1, -10, 1, -10)
    TabList.Position = UDim2.fromOffset(5, 5)
    TabList.ScrollBarThickness = 2
    TabList.ScrollBarImageColor3 = Theme.Silver
    TabList.AutomaticCanvasSize = Enum.AutomaticSize.Y
    TabList.CanvasSize = UDim2.new()
    TabList.Parent = Sidebar

    local TabLayout = Instance.new("UIListLayout")
    TabLayout.Padding = UDim.new(0, 6)
    TabLayout.SortOrder = Enum.SortOrder.LayoutOrder
    TabLayout.Parent = TabList

    -- Main content
    local ContentShell, Content = ChromeSurface(
        Main,
        UDim2.new(1, -155, 1, -61),
        9,
        5
    )

    ContentShell.Position = UDim2.fromOffset(149, 55)
    ContentShell.BackgroundTransparency = Theme.ElementTransparency
    Content.BackgroundTransparency = Theme.ElementTransparency

    Window.Main = MainShell
    Window.Content = Content

    -- Tab switching
    local function SwitchTab(tab)
        if Window.ActiveTab == tab then return end

        for _, existing in ipairs(Window.Tabs) do
            existing.Page.Visible = false

            Tween(existing.TabFace, 0.18, {
                BackgroundTransparency = Theme.ElementTransparency
            })

            Tween(existing.TabStroke, 0.18, {
                Transparency = 0.8
            })

            existing.TabText.TextColor3 = Theme.Muted
        end

        tab.Page.Visible = true
        tab.Page.Position = UDim2.fromOffset(7, 13)

        Tween(tab.Page, 0.22, {
            Position = UDim2.fromOffset(7, 7)
        })

        Tween(tab.TabFace, 0.18, {
            BackgroundTransparency = 0.06
        })

        Tween(tab.TabStroke, 0.18, {
            Transparency = 0.2
        })

        tab.TabText.TextColor3 = Theme.Text
        Window.ActiveTab = tab
    end

    -- Create tab
    function Window:CreateTab(name)
        local Tab = {}

        local tabShell, tabFace, tabButton = MakeButton(
            TabList,
            "",
            UDim2.new(1, 0, 0, 34),
            8
        )

        tabButton:Destroy()

        local tabStroke = AddStroke(tabFace, Theme.Silver, 0.8, 1)

        local tabText = MakeText(
            tabFace,
            name or "Tab",
            12,
            Theme.Muted,
            Enum.Font.GothamMedium
        )

        tabText.Position = UDim2.fromOffset(11, 0)
        tabText.Size = UDim2.new(1, -15, 1, 0)

        local Page = Instance.new("ScrollingFrame")
        Page.Name = (name or "Tab") .. "_Page"
        Page.BackgroundTransparency = 1
        Page.BorderSizePixel = 0
        Page.Size = UDim2.new(1, -14, 1, -14)
        Page.Position = UDim2.fromOffset(7, 7)
        Page.ScrollBarThickness = 2
        Page.ScrollBarImageColor3 = Theme.Silver
        Page.AutomaticCanvasSize = Enum.AutomaticSize.Y
        Page.CanvasSize = UDim2.new()
        Page.Visible = false
        Page.Parent = Content

        local Layout = Instance.new("UIListLayout")
        Layout.Padding = UDim.new(0, 8)
        Layout.SortOrder = Enum.SortOrder.LayoutOrder
        Layout.Parent = Page

        local Padding = Instance.new("UIPadding")
        Padding.PaddingBottom = UDim.new(0, 5)
        Padding.Parent = Page

        Tab.Page = Page
        Tab.TabFace = tabFace
        Tab.TabText = tabText
        Tab.TabStroke = tabStroke

        Connect(tabShell.InputBegan, function(input)
            if input.UserInputType == Enum.UserInputType.MouseButton1
                or input.UserInputType == Enum.UserInputType.Touch then
                SwitchTab(Tab)
            end
        end)

        table.insert(Window.Tabs, Tab)

        if not Window.ActiveTab then
            SwitchTab(Tab)
        end

        -- Section
        function Tab:CreateSection(text)
            local section = MakeText(
                Page,
                string.upper(text or "SECTION"),
                11,
                Theme.Muted,
                Enum.Font.GothamBold
            )

            section.Size = UDim2.new(1, -5, 0, 22)
            return section
        end

        -- Label
        function Tab:CreateLabel(text)
            local shell, face = ChromeSurface(
                Page,
                UDim2.new(1, -3, 0, 32),
                7,
                8
            )

            shell.BackgroundTransparency = Theme.ElementTransparency
            face.BackgroundTransparency = Theme.ElementTransparency

            local label = MakeText(face, text or "Label", 12, Theme.Text)
            label.Position = UDim2.fromOffset(10, 0)
            label.Size = UDim2.new(1, -20, 1, 0)

            return {
                Set = function(_, newText)
                    label.Text = tostring(newText)
                end
            }
        end

        -- Button
        function Tab:CreateButton(text, callback)
            local shell, face, button = MakeButton(
                Page,
                text or "Button",
                UDim2.new(1, -3, 0, 34),
                8
            )

            Connect(button.MouseButton1Click, function()
                if callback then
                    task.spawn(callback)
                end
            end)

            return {
                SetText = function(_, newText)
                    button.Text = tostring(newText)
                end
            }
        end

        -- Toggle
        function Tab:CreateToggle(text, default, callback)
            local shell, face = ChromeSurface(
                Page,
                UDim2.new(1, -3, 0, 36),
                7,
                8
            )

            shell.BackgroundTransparency = Theme.ElementTransparency
            face.BackgroundTransparency = Theme.ElementTransparency

            local label = MakeText(face, text or "Toggle", 12, Theme.Text)
            label.Position = UDim2.fromOffset(10, 0)
            label.Size = UDim2.new(1, -55, 1, 0)

            local switch = Instance.new("Frame")
            switch.Size = UDim2.fromOffset(30, 16)
            switch.Position = UDim2.new(1, -40, 0.5, -8)
            switch.BackgroundColor3 = Color3.fromRGB(65, 67, 77)
            switch.BackgroundTransparency = 0.1
            switch.BorderSizePixel = 0
            switch.ZIndex = 10
            switch.Parent = face
            Corner(switch, 10)

            local switchStroke = AddStroke(switch, Theme.Silver, 0.8, 1)

            local knob = Instance.new("Frame")
            knob.Size = UDim2.fromOffset(12, 12)
            knob.Position = UDim2.fromOffset(2, 2)
            knob.BackgroundColor3 = Color3.fromRGB(225, 230, 240)
            knob.BorderSizePixel = 0
            knob.ZIndex = 11
            knob.Parent = switch
            Corner(knob, 10)

            local hitbox = Instance.new("TextButton")
            hitbox.Size = UDim2.fromScale(1, 1)
            hitbox.BackgroundTransparency = 1
            hitbox.Text = ""
            hitbox.ZIndex = 12
            hitbox.Parent = face

            local state = default == true

            local function Update()
                Tween(knob, 0.2, {
                    Position = state
                        and UDim2.new(1, -14, 0, 2)
                        or UDim2.fromOffset(2, 2)
                })

                Tween(switch, 0.2, {
                    BackgroundColor3 = state
                        and Color3.fromRGB(165, 175, 195)
                        or Color3.fromRGB(65, 67, 77)
                })

                Tween(switchStroke, 0.2, {
                    Transparency = state and 0.25 or 0.8
                })

                if callback then
                    task.spawn(callback, state)
                end
            end

            Connect(hitbox.MouseButton1Click, function()
                state = not state
                Update()
            end)

            Update()

            return {
                Set = function(_, value)
                    state = value == true
                    Update()
                end,

                Get = function()
                    return state
                end
            }
        end

        -- Slider
        function Tab:CreateSlider(text, min, max, default, callback)
            min = min or 0
            max = max or 100

            assert(max > min, "Slider max must be greater than min")

            default = math.clamp(default or min, min, max)

            local shell, face = ChromeSurface(
                Page,
                UDim2.new(1, -3, 0, 53),
                7,
                8
            )

            shell.BackgroundTransparency = Theme.ElementTransparency
            face.BackgroundTransparency = Theme.ElementTransparency

            local label = MakeText(face, text or "Slider", 12, Theme.Text)
            label.Position = UDim2.fromOffset(10, 2)
            label.Size = UDim2.new(1, -75, 0, 22)

            local valueLabel = MakeText(face, tostring(default), 11, Theme.Muted)
            valueLabel.TextXAlignment = Enum.TextXAlignment.Right
            valueLabel.Position = UDim2.new(1, -60, 0, 2)
            valueLabel.Size = UDim2.fromOffset(48, 22)

            local bar = Instance.new("Frame")
            bar.Position = UDim2.new(0, 10, 0, 33)
            bar.Size = UDim2.new(1, -20, 0, 5)
            bar.BackgroundColor3 = Color3.fromRGB(65, 67, 77)
            bar.BorderSizePixel = 0
            bar.Parent = face
            Corner(bar, 5)

            local fill = Instance.new("Frame")
            fill.Size = UDim2.new((default - min) / (max - min), 0, 1, 0)
            fill.BackgroundColor3 = Theme.Silver
            fill.BorderSizePixel = 0
            fill.Parent = bar
            Corner(fill, 5)

            local knob = Instance.new("Frame")
            knob.AnchorPoint = Vector2.new(0.5, 0.5)
            knob.Size = UDim2.fromOffset(11, 11)
            knob.Position = UDim2.new((default - min) / (max - min), 0, 0.5, 0)
            knob.BackgroundColor3 = Color3.fromRGB(240, 243, 250)
            knob.BorderSizePixel = 0
            knob.ZIndex = 3
            knob.Parent = bar
            Corner(knob, 10)
            AddStroke(knob, Theme.Silver, 0.25, 1)

            local draggingSlider = false
            local value = default

            local function SetValue(inputX, animated)
                local percent = math.clamp(
                    (inputX - bar.AbsolutePosition.X) / bar.AbsoluteSize.X,
                    0,
                    1
                )

                value = math.floor((min + (max - min) * percent) * 100) / 100

                local size = UDim2.new(percent, 0, 1, 0)
                local position = UDim2.new(percent, 0, 0.5, 0)

                if animated then
                    Tween(fill, 0.08, {Size = size})
                    Tween(knob, 0.08, {Position = position})
                else
                    fill.Size = size
                    knob.Position = position
                end

                valueLabel.Text = tostring(value)

                if callback then
                    task.spawn(callback, value)
                end
            end

            Connect(bar.InputBegan, function(input)
                if input.UserInputType == Enum.UserInputType.MouseButton1
                    or input.UserInputType == Enum.UserInputType.Touch then
                    draggingSlider = true
                    SetValue(input.Position.X, true)
                end
            end)

            Connect(UserInputService.InputChanged, function(input)
                if draggingSlider and (
                    input.UserInputType == Enum.UserInputType.MouseMovement
                    or input.UserInputType == Enum.UserInputType.Touch
                ) then
                    SetValue(input.Position.X, false)
                end
            end)

            Connect(UserInputService.InputEnded, function(input)
                if input.UserInputType == Enum.UserInputType.MouseButton1
                    or input.UserInputType == Enum.UserInputType.Touch then
                    draggingSlider = false
                end
            end)

            return {
                Set = function(_, newValue)
                    value = math.clamp(newValue, min, max)

                    local percent = (value - min) / (max - min)

                    Tween(fill, 0.15, {
                        Size = UDim2.new(percent, 0, 1, 0)
                    })

                    Tween(knob, 0.15, {
                        Position = UDim2.new(percent, 0, 0.5, 0)
                    })

                    valueLabel.Text = tostring(value)

                    if callback then
                        task.spawn(callback, value)
                    end
                end,

                Get = function()
                    return value
                end
            }
        end

        return Tab
    end

    function Window:SetTitle(text)
        Title.Text = tostring(text)
    end

    function Window:SetVisible(state)
        if state then
            MainShell.Visible = true
            MainShell.Size = UDim2.fromOffset(width * 0.92, height * 0.92)

            Tween(MainShell, 0.35, {
                Size = UDim2.fromOffset(width, height)
            }, Enum.EasingStyle.Back)
        else
            Tween(MainShell, 0.25, {
                Size = UDim2.fromOffset(width * 0.92, height * 0.92)
            }, Enum.EasingStyle.Back, Enum.EasingDirection.In)

            task.wait(0.25)
            MainShell.Visible = false
        end
    end

    function Window:Destroy()
        MainShell:Destroy()
    end

    return Window
end

function OEO:Destroy()
    LibraryDestroyed = true

    for _, connection in ipairs(Connections) do
        pcall(function()
            connection:Disconnect()
        end)
    end

    table.clear(Connections)

    pcall(function()
        ScreenGui:Destroy()
    end)
end

-- Example usage
local Window = OEO:CreateWindow({
    Name = "OEO Lib",
    Width = 570,
    Height = 390
})

local MainTab = Window:CreateTab("Main")

MainTab:CreateSection("General")

MainTab:CreateButton("Example Button", function()
    print("Button clicked!")
end)

MainTab:CreateToggle("Example Toggle", false, function(value)
    print("Toggle:", value)
end)

MainTab:CreateSlider("Example Slider", 0, 100, 50, function(value)
    print("Slider:", value)
end)

MainTab:CreateLabel("Welcome to OEO Lib")

local SettingsTab = Window:CreateTab("Settings")

SettingsTab:CreateSection("Interface")

SettingsTab:CreateToggle("Example Setting", true, function(value)
    print("Setting:", value)
end)

return OEO
