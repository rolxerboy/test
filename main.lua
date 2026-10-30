
local Library = {}

-- OEO LIB | LIQUID CHROME
-- Executor UI Library

local Players = game:GetService("Players")
local TweenService = game:GetService("TweenService")
local UserInputService = game:GetService("UserInputService")

local Colors = {
    Black = Color3.fromRGB(5, 5, 7),
    Dark = Color3.fromRGB(15, 15, 18),
    Panel = Color3.fromRGB(24, 24, 27),
    Silver = Color3.fromRGB(205, 210, 218),
    White = Color3.fromRGB(255, 255, 255),
    Gray = Color3.fromRGB(110, 112, 120),
    Muted = Color3.fromRGB(145, 148, 155)
}

local Chrome = ColorSequence.new({
    ColorSequenceKeypoint.new(0, Color3.fromRGB(15, 15, 18)),
    ColorSequenceKeypoint.new(0.13, Color3.fromRGB(235, 238, 245)),
    ColorSequenceKeypoint.new(0.25, Color3.fromRGB(75, 78, 85)),
    ColorSequenceKeypoint.new(0.39, Color3.fromRGB(255, 255, 255)),
    ColorSequenceKeypoint.new(0.53, Color3.fromRGB(65, 67, 74)),
    ColorSequenceKeypoint.new(0.68, Color3.fromRGB(230, 233, 240)),
    ColorSequenceKeypoint.new(0.82, Color3.fromRGB(90, 92, 100)),
    ColorSequenceKeypoint.new(1, Color3.fromRGB(245, 245, 250))
})

local function New(class, properties)
    local object = Instance.new(class)

    for property, value in pairs(properties) do
        object[property] = value
    end

    return object
end

local function Corner(parent, radius)
    return New("UICorner", {
        CornerRadius = UDim.new(0, radius),
        Parent = parent
    })
end

local function Stroke(parent, color, thickness, transparency)
    return New("UIStroke", {
        Parent = parent,
        Color = color or Colors.Silver,
        Thickness = thickness or 1,
        Transparency = transparency or 0
    })
end

local function Gradient(parent, rotation)
    return New("UIGradient", {
        Parent = parent,
        Color = Chrome,
        Rotation = rotation or 0
    })
end

local function Tween(object, properties, duration)
    local tween = TweenService:Create(
        object,
        TweenInfo.new(
            duration or 0.2,
            Enum.EasingStyle.Quart,
            Enum.EasingDirection.Out
        ),
        properties
    )

    tween:Play()
    return tween
end

local function CreateChromeFrame(parent, size, position, radius)
    local frame = New("Frame", {
        Parent = parent,
        Size = size,
        Position = position,
        BackgroundColor3 = Colors.Silver,
        BorderSizePixel = 0
    })

    Corner(frame, radius or 7)
    Gradient(frame, 90)
    Stroke(frame, Colors.White, 1, 0.25)

    return frame
end

local function CreateText(parent, text, size, position)
    local label = New("TextLabel", {
        Parent = parent,
        BackgroundTransparency = 1,
        Position = position or UDim2.new(0, 12, 0, 0),
        Size = UDim2.new(1, -24, 1, 0),
        Font = Enum.Font.Gotham,
        Text = text or "",
        TextColor3 = Colors.White,
        TextSize = size or 13,
        TextXAlignment = Enum.TextXAlignment.Left
    })

    return label
end

function Library:CreateWindow(options)
    options = options or {}

    local GUI = New("ScreenGui", {
        Name = "OEO_Lib",
        ResetOnSpawn = false,
        ZIndexBehavior = Enum.ZIndexBehavior.Sibling
    })

    local parent

    if typeof(gethui) == "function" then
        local success, result = pcall(gethui)
        if success then
            parent = result
        end
    end

    if not parent then
        parent = game:GetService("CoreGui")
    end

    GUI.Parent = parent

    -- MAIN WINDOW

    local Main = New("Frame", {
        Name = "Main",
        Parent = GUI,
        BackgroundColor3 = Colors.Black,
        BorderSizePixel = 0,
        Position = UDim2.new(0.5, -280, 0.5, -190),
        Size = UDim2.new(0, 560, 0, 380),
        ClipsDescendants = true
    })

    Corner(Main, 12)
    Stroke(Main, Colors.Silver, 1.5, 0.1)

    -- WINDOW BACKGROUND

    local BackgroundGradient = New("UIGradient", {
        Parent = Main,
        Color = ColorSequence.new({
            ColorSequenceKeypoint.new(0, Color3.fromRGB(5, 5, 7)),
            ColorSequenceKeypoint.new(0.5, Color3.fromRGB(28, 28, 33)),
            ColorSequenceKeypoint.new(1, Color3.fromRGB(5, 5, 7))
        }),
        Rotation = 45
    })

    -- HEADER

    local Header = New("Frame", {
        Name = "Header",
        Parent = Main,
        BackgroundColor3 = Colors.Dark,
        BorderSizePixel = 0,
        Size = UDim2.new(1, 0, 0, 48)
    })

    local HeaderLine = New("Frame", {
        Parent = Header,
        BackgroundColor3 = Colors.Silver,
        BorderSizePixel = 0,
        Position = UDim2.new(0, 0, 1, -1),
        Size = UDim2.new(1, 0, 0, 1)
    })

    Gradient(HeaderLine, 0)

    -- LOGO

    local Logo = New("TextLabel", {
        Name = "Logo",
        Parent = Header,
        BackgroundTransparency = 1,
        Position = UDim2.new(0, 17, 0, 0),
        Size = UDim2.new(0, 150, 1, 0),
        Font = Enum.Font.GothamBlack,
        Text = "OEO Lib",
        TextColor3 = Colors.White,
        TextSize = 25,
        TextXAlignment = Enum.TextXAlignment.Left
    })

    Gradient(Logo, 0)

    local Subtitle = New("TextLabel", {
        Parent = Header,
        BackgroundTransparency = 1,
        Position = UDim2.new(0, 155, 0, 3),
        Size = UDim2.new(0, 180, 1, 0),
        Font = Enum.Font.Gotham,
        Text = "LIQUID CHROME",
        TextColor3 = Colors.Muted,
        TextSize = 9,
        TextXAlignment = Enum.TextXAlignment.Left
    })

    -- CLOSE BUTTON

    local Close = New("TextButton", {
        Parent = Header,
        BackgroundColor3 = Colors.Panel,
        BorderSizePixel = 0,
        Position = UDim2.new(1, -39, 0, 11),
        Size = UDim2.new(0, 27, 0, 27),
        Font = Enum.Font.GothamBold,
        Text = "×",
        TextColor3 = Colors.White,
        TextSize = 20,
        AutoButtonColor = false
    })

    Corner(Close, 6)
    Stroke(Close, Colors.Silver, 1, 0.45)

    Close.MouseButton1Click:Connect(function()
        GUI:Destroy()
    end)

    -- DRAGGING

    local dragging = false
    local dragStart
    local startPosition

    Header.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1
        or input.UserInputType == Enum.UserInputType.Touch then

            dragging = true
            dragStart = input.Position
            startPosition = Main.Position
        end
    end)

    UserInputService.InputChanged:Connect(function(input)
        if dragging and (
            input.UserInputType == Enum.UserInputType.MouseMovement
            or input.UserInputType == Enum.UserInputType.Touch
        ) then

            local delta = input.Position - dragStart

            Main.Position = UDim2.new(
                startPosition.X.Scale,
                startPosition.X.Offset + delta.X,
                startPosition.Y.Scale,
                startPosition.Y.Offset + delta.Y
            )
        end
    end)

    UserInputService.InputEnded:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1
        or input.UserInputType == Enum.UserInputType.Touch then
            dragging = false
        end
    end)

    -- SIDEBAR

    local Sidebar = New("Frame", {
        Name = "Sidebar",
        Parent = Main,
        BackgroundColor3 = Colors.Dark,
        BorderSizePixel = 0,
        Position = UDim2.new(0, 0, 0, 49),
        Size = UDim2.new(0, 135, 1, -49)
    })

    local SidebarLine = New("Frame", {
        Parent = Sidebar,
        BackgroundColor3 = Colors.Silver,
        BorderSizePixel = 0,
        Position = UDim2.new(1, -1, 0, 0),
        Size = UDim2.new(0, 1, 1, 0)
    })

    Gradient(SidebarLine, 90)

    local TabContainer = New("ScrollingFrame", {
        Name = "TabContainer",
        Parent = Sidebar,
        BackgroundTransparency = 1,
        BorderSizePixel = 0,
        Position = UDim2.new(0, 9, 0, 13),
        Size = UDim2.new(1, -18, 1, -25),
        ScrollBarThickness = 2,
        ScrollBarImageColor3 = Colors.Silver,
        AutomaticCanvasSize = Enum.AutomaticSize.Y,
        CanvasSize = UDim2.new(0, 0, 0, 0)
    })

    New("UIListLayout", {
        Parent = TabContainer,
        SortOrder = Enum.SortOrder.LayoutOrder,
        Padding = UDim.new(0, 7)
    })

    -- PAGE CONTAINER

    local Pages = New("Frame", {
        Name = "Pages",
        Parent = Main,
        BackgroundTransparency = 1,
        Position = UDim2.new(0, 146, 0, 60),
        Size = UDim2.new(1, -157, 1, -72),
        ClipsDescendants = true
    })

    -- TAB SYSTEM

    local Tabs = {}
    local TabCount = 0

    local function SelectTab(selected)
        for _, tab in ipairs(Tabs) do
            tab.Page.Visible = false

            Tween(tab.Button, {
                BackgroundColor3 = Colors.Panel
            })

            Tween(tab.Label, {
                TextColor3 = Colors.Muted
            })

            tab.ButtonStroke.Transparency = 0.65
        end

        selected.Page.Visible = true

        Tween(selected.Button, {
            BackgroundColor3 = Color3.fromRGB(90, 92, 100)
        })

        Tween(selected.Label, {
            TextColor3 = Colors.White
        })

        selected.ButtonStroke.Transparency = 0.05
    end

    -- TAB CREATION

    function Tabs:CreateTab(name)
        name = name or "New Tab"
        TabCount = TabCount + 1

        local Button = New("TextButton", {
            Parent = TabContainer,
            Name = name .. "_Tab",
            BackgroundColor3 = Colors.Panel,
            BorderSizePixel = 0,
            Size = UDim2.new(1, 0, 0, 34),
            Text = "",
            AutoButtonColor = false,
            LayoutOrder = TabCount
        })

        Corner(Button, 6)

        local ButtonStroke = Stroke(Button, Colors.Silver, 1, 0.65)

        local Label = New("TextLabel", {
            Parent = Button,
            BackgroundTransparency = 1,
            Position = UDim2.new(0, 10, 0, 0),
            Size = UDim2.new(1, -20, 1, 0),
            Font = Enum.Font.GothamMedium,
            Text = name,
            TextColor3 = Colors.Muted,
            TextSize = 12,
            TextXAlignment = Enum.TextXAlignment.Left
        })

        local Page = New("ScrollingFrame", {
            Parent = Pages,
            Name = name .. "_Page",
            BackgroundTransparency = 1,
            BorderSizePixel = 0,
            Size = UDim2.new(1, 0, 1, 0),
            ScrollBarThickness = 3,
            ScrollBarImageColor3 = Colors.Silver,
            CanvasSize = UDim2.new(0, 0, 0, 0),
            AutomaticCanvasSize = Enum.AutomaticSize.Y,
            Visible = false
        })

        New("UIListLayout", {
            Parent = Page,
            SortOrder = Enum.SortOrder.LayoutOrder,
            Padding = UDim.new(0, 9)
        })

        New("UIPadding", {
            Parent = Page,
            PaddingTop = UDim.new(0, 5),
            PaddingBottom = UDim.new(0, 8),
            PaddingLeft = UDim.new(0, 4),
            PaddingRight = UDim.new(0, 7)
        })

        local Tab = {
            Button = Button,
            ButtonStroke = ButtonStroke,
            Label = Label,
            Page = Page
        }

        table.insert(Tabs, Tab)

        Button.MouseButton1Click:Connect(function()
            SelectTab(Tab)
        end)

        Button.MouseEnter:Connect(function()
            if Page.Visible then return end

            Tween(Button, {
                BackgroundColor3 = Color3.fromRGB(45, 45, 50)
            })
        end)

        Button.MouseLeave:Connect(function()
            if Page.Visible then return end

            Tween(Button, {
                BackgroundColor3 = Colors.Panel
            })
        end)

        if #Tabs == 1 then
            SelectTab(Tab)
        end

        -- ELEMENT CREATOR

        local function Element(height)
            local frame = New("Frame", {
                Parent = Page,
                BackgroundColor3 = Colors.Panel,
                BorderSizePixel = 0,
                Size = UDim2.new(1, 0, 0, height)
            })

            Corner(frame, 7)
            Stroke(frame, Colors.Silver, 1, 0.8)

            return frame
        end

        -- BUTTON

        function Tab:CreateButton(options)
            options = options or {}

            local frame = Element(38)

            local label = CreateText(
                frame,
                options.Name or "Button",
                12
            )

            local click = New("TextButton", {
                Parent = frame,
                BackgroundTransparency = 1,
                Size = UDim2.new(1, 0, 1, 0),
                Text = ""
            })

            click.MouseButton1Click:Connect(function()
                Tween(frame, {
                    BackgroundColor3 = Color3.fromRGB(95, 97, 105)
                })

                task.delay(0.2, function()
                    if frame.Parent then
                        Tween(frame, {
                            BackgroundColor3 = Colors.Panel
                        })
                    end
                end)

                if options.Callback then
                    task.spawn(options.Callback)
                end
            end)

            click.MouseEnter:Connect(function()
                Tween(frame, {
                    BackgroundColor3 = Color3.fromRGB(48, 48, 53)
                })
            end)

            click.MouseLeave:Connect(function()
                Tween(frame, {
                    BackgroundColor3 = Colors.Panel
                })
            end)

            return frame
        end

        -- TOGGLE

        function Tab:CreateToggle(options)
            options = options or {}

            local state = options.Default == true

            local frame = Element(38)

            CreateText(
                frame,
                options.Name or "Toggle",
                12
            )

            local indicator = New("Frame", {
                Parent = frame,
                BackgroundColor3 = state and Colors.Silver or Colors.Gray,
                BorderSizePixel = 0,
                Position = UDim2.new(1, -43, 0.5, -9),
                Size = UDim2.new(0, 31, 0, 18)
            })

            Corner(indicator, 10)

            local circle = New("Frame", {
                Parent = indicator,
                BackgroundColor3 = Colors.White,
                BorderSizePixel = 0,
                Position = state and UDim2.new(1, -16, 0, 2)
                    or UDim2.new(0, 2, 0, 2),
                Size = UDim2.new(0, 14, 0, 14)
            })

            Corner(circle, 10)

            local click = New("TextButton", {
                Parent = frame,
                BackgroundTransparency = 1,
                Size = UDim2.new(1, 0, 1, 0),
                Text = ""
            })

            local function Update()
                Tween(indicator, {
                    BackgroundColor3 = state and Colors.Silver or Colors.Gray
                })

                Tween(circle, {
                    Position = state
                        and UDim2.new(1, -16, 0, 2)
                        or UDim2.new(0, 2, 0, 2)
                })

                if options.Callback then
                    task.spawn(options.Callback, state)
                end
            end

            click.MouseButton1Click:Connect(function()
                state = not state
                Update()
            end)

            local object = {}

            function object:Set(value)
                state = value == true
                Update()
            end

            function object:Get()
                return state
            end

            return object
        end

        -- SLIDER

        function Tab:CreateSlider(options)
            options = options or {}

            local minimum = options.Min or 0
            local maximum = options.Max or 100

            assert(maximum > minimum, "Slider Max must be greater than Min")

            local value = math.clamp(
                options.Default or minimum,
                minimum,
                maximum
            )

            local frame = Element(55)

            local title = CreateText(
                frame,
                options.Name or "Slider",
                12,
                UDim2.new(0, 10, 0, 0)
            )

            title.Size = UDim2.new(1, -75, 0, 25)

            local valueLabel = New("TextLabel", {
                Parent = frame,
                BackgroundTransparency = 1,
                Position = UDim2.new(1, -65, 0, 0),
                Size = UDim2.new(0, 55, 0, 25),
                Font = Enum.Font.Gotham,
                Text = tostring(value),
                TextColor3 = Colors.Silver,
                TextSize = 11,
                TextXAlignment = Enum.TextXAlignment.Right
            })

            local bar = New("Frame", {
                Parent = frame,
                BackgroundColor3 = Colors.Gray,
                BorderSizePixel = 0,
                Position = UDim2.new(0, 10, 0, 35),
                Size = UDim2.new(1, -20, 0, 5)
            })

            Corner(bar, 5)

            local fill = New("Frame", {
                Parent = bar,
                BackgroundColor3 = Colors.Silver,
                BorderSizePixel = 0,
                Size = UDim2.new(
                    (value - minimum) / (maximum - minimum),
                    0, 1, 0
                )
            })

            Corner(fill, 5)
            Gradient(fill, 0)

            local draggingSlider = false

            local function SetValue(newValue)
                value = math.clamp(
                    math.floor(newValue + 0.5),
                    minimum,
                    maximum
                )

                local percent = (value - minimum) / (maximum - minimum)

                Tween(fill, {
                    Size = UDim2.new(percent, 0, 1, 0)
                })

                valueLabel.Text = tostring(value)

                if options.Callback then
                    task.spawn(options.Callback, value)
                end
            end

            local function Update(input)
                local percent = math.clamp(
                    (input.Position.X - bar.AbsolutePosition.X)
                    / bar.AbsoluteSize.X,
                    0,
                    1
                )

                SetValue(minimum + (maximum - minimum) * percent)
            end

            local click = New("TextButton", {
                Parent = bar,
                BackgroundTransparency = 1,
                Size = UDim2.new(1, 0, 1, 0),
                Text = ""
            })

            click.MouseButton1Down:Connect(function()
                draggingSlider = true
                Update({
                    Position = UserInputService:GetMouseLocation()
                })
            end)

            UserInputService.InputChanged:Connect(function(input)
                if draggingSlider and (
                    input.UserInputType == Enum.UserInputType.MouseMovement
                    or input.UserInputType == Enum.UserInputType.Touch
                ) then
                    Update(input)
                end
            end)

            UserInputService.InputEnded:Connect(function(input)
                if input.UserInputType == Enum.UserInputType.MouseButton1
                or input.UserInputType == Enum.UserInputType.Touch then
                    draggingSlider = false
                end
            end)

            local object = {}

            function object:Set(newValue)
                SetValue(newValue)
            end

            function object:Get()
                return value
            end

            return object
        end

        -- LABEL

        function Tab:CreateLabel(text)
            local frame = Element(32)

            local label = CreateText(
                frame,
                text or "Label",
                12
            )

            local object = {}

            function object:Set(newText)
                label.Text = tostring(newText)
            end

            return object
        end

        -- SECTION

        function Tab:CreateSection(text)
            local section = New("TextLabel", {
                Parent = Page,
                BackgroundTransparency = 1,
                Size = UDim2.new(1, 0, 0, 25),
                Font = Enum.Font.GothamBold,
                Text = string.upper(text or "SECTION"),
                TextColor3 = Colors.Silver,
                TextSize = 12,
                TextXAlignment = Enum.TextXAlignment.Left
            })

            Gradient(section, 0)

            return section
        end

        return Tab
    end

    local Window = {}

    Window.GUI = GUI
    Window.Frame = Main
    Window.Tabs = Tabs

    function Window:CreateTab(name)
        return Tabs:CreateTab(name)
    end

    function Window:Destroy()
        GUI:Destroy()
    end

    return Window
end

return Library
