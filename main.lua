
local Library = {}

local TweenService = game:GetService("TweenService")
local UserInputService = game:GetService("UserInputService")
local CoreGui = game:GetService("CoreGui")

local Colors = {
    Background = Color3.fromRGB(18, 18, 18),
    Sidebar = Color3.fromRGB(34, 34, 34),
    Page = Color3.fromRGB(34, 34, 34),
    Button = Color3.fromRGB(115, 49, 37),
    Active = Color3.fromRGB(255, 109, 83),
    Text = Color3.fromRGB(255, 255, 255),
    Muted = Color3.fromRGB(160, 160, 160),
    Element = Color3.fromRGB(45, 45, 45),
    Bar = Color3.fromRGB(65, 65, 65)
}

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

local function Tween(object, properties)
    local tween = TweenService:Create(
        object,
        TweenInfo.new(0.2, Enum.EasingStyle.Quad, Enum.EasingDirection.Out),
        properties
    )

    tween:Play()
    return tween
end

function Library:CreateWindow()
    local GUI = New("ScreenGui", {
        Name = "CustomExecutorLibrary",
        ResetOnSpawn = false,
        ZIndexBehavior = Enum.ZIndexBehavior.Sibling
    })

    local success = pcall(function()
        GUI.Parent = CoreGui
    end)

    if not success then
        GUI:Destroy()
        error("Unable to parent GUI to CoreGui")
    end

    local FRAME = New("Frame", {
        Name = "FRAME",
        Parent = GUI,
        BackgroundColor3 = Colors.Background,
        BorderSizePixel = 0,
        Position = UDim2.new(0.5, -215, 0.5, -130),
        Size = UDim2.new(0, 430, 0, 260),
        ClipsDescendants = true
    })

    Corner(FRAME, 9)

    local SIDEBAR = New("Frame", {
        Name = "SIDEBAR",
        Parent = FRAME,
        BackgroundColor3 = Colors.Sidebar,
        BorderSizePixel = 0,
        Size = UDim2.new(0, 110, 1, 0)
    })

    Corner(SIDEBAR, 9)

    New("Frame", {
        Parent = SIDEBAR,
        BackgroundColor3 = Colors.Bar,
        BorderSizePixel = 0,
        Position = UDim2.new(1, -6, 0, 0),
        Size = UDim2.new(0, 6, 1, 0)
    })

    local TABS = New("Frame", {
        Name = "TABS",
        Parent = SIDEBAR,
        BackgroundTransparency = 1,
        Position = UDim2.new(0, 6, 0, 8),
        Size = UDim2.new(1, -18, 1, -16)
    })

    New("UIListLayout", {
        Parent = TABS,
        SortOrder = Enum.SortOrder.LayoutOrder,
        Padding = UDim.new(0, 5)
    })

    local PAGES = New("Frame", {
        Name = "PAGES",
        Parent = FRAME,
        BackgroundColor3 = Colors.Page,
        BorderSizePixel = 0,
        Position = UDim2.new(0, 118, 0, 7),
        Size = UDim2.new(1, -125, 1, -14),
        ClipsDescendants = true
    })

    Corner(PAGES, 5)

    -- Window dragging

    local dragging = false
    local dragStart
    local startPosition

    FRAME.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1
        or input.UserInputType == Enum.UserInputType.Touch then

            dragging = true
            dragStart = input.Position
            startPosition = FRAME.Position
        end
    end)

    UserInputService.InputChanged:Connect(function(input)
        if dragging and (
            input.UserInputType == Enum.UserInputType.MouseMovement
            or input.UserInputType == Enum.UserInputType.Touch
        ) then

            local delta = input.Position - dragStart

            FRAME.Position = UDim2.new(
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

    local Tabs = {}
    local TabCount = 0

    local function SelectTab(selected)
        for _, tab in ipairs(Tabs) do
            tab.Page.Visible = false

            Tween(tab.Button, {
                BackgroundColor3 = Colors.Button
            })
        end

        selected.Page.Visible = true

        Tween(selected.Button, {
            BackgroundColor3 = Colors.Active
        })
    end

    local function CreateElement(parent, height)
        return New("Frame", {
            Parent = parent,
            BackgroundColor3 = Colors.Element,
            BorderSizePixel = 0,
            Size = UDim2.new(1, -4, 0, height)
        })
    end

    local function CreateText(parent, text, size)
        return New("TextLabel", {
            Parent = parent,
            BackgroundTransparency = 1,
            Size = UDim2.new(1, -16, 1, 0),
            Position = UDim2.new(0, 8, 0, 0),
            Font = Enum.Font.Gotham,
            Text = text,
            TextColor3 = Colors.Text,
            TextSize = size or 13,
            TextXAlignment = Enum.TextXAlignment.Left
        })
    end

    function Tabs:CreateTab(TabName)
        TabName = TabName or "New Tab"
        TabCount = TabCount + 1

        local TABBUTTON = New("TextButton", {
            Name = "TABBUTTON",
            Parent = TABS,
            BackgroundColor3 = Colors.Button,
            BorderSizePixel = 0,
            Size = UDim2.new(1, 0, 0, 28),
            Font = Enum.Font.Gotham,
            Text = TabName,
            TextColor3 = Colors.Text,
            TextSize = 13,
            LayoutOrder = TabCount,
            AutoButtonColor = false
        })

        Corner(TABBUTTON, 5)

        local PAGE = New("ScrollingFrame", {
            Name = TabName .. "_PAGE",
            Parent = PAGES,
            BackgroundTransparency = 1,
            BorderSizePixel = 0,
            Size = UDim2.new(1, 0, 1, 0),
            ScrollBarThickness = 4,
            ScrollBarImageColor3 = Colors.Active,
            CanvasSize = UDim2.new(0, 0, 0, 0),
            AutomaticCanvasSize = Enum.AutomaticSize.Y,
            Visible = false
        })

        New("UIListLayout", {
            Parent = PAGE,
            HorizontalAlignment = Enum.HorizontalAlignment.Center,
            SortOrder = Enum.SortOrder.LayoutOrder,
            Padding = UDim.new(0, 6)
        })

        New("UIPadding", {
            Parent = PAGE,
            PaddingTop = UDim.new(0, 6),
            PaddingBottom = UDim.new(0, 6),
            PaddingLeft = UDim.new(0, 5),
            PaddingRight = UDim.new(0, 5)
        })

        local Tab = {
            Button = TABBUTTON,
            Page = PAGE
        }

        table.insert(Tabs, Tab)

        TABBUTTON.MouseButton1Click:Connect(function()
            SelectTab(Tab)
        end)

        if #Tabs == 1 then
            SelectTab(Tab)
        end

        -- BUTTON

        function Tab:CreateButton(options)
            options = options or {}

            local button = CreateElement(PAGE, 32)
            Corner(button, 5)

            local text = CreateText(
                button,
                options.Name or "Button",
                13
            )

            local click = New("TextButton", {
                Parent = button,
                BackgroundTransparency = 1,
                Size = UDim2.new(1, 0, 1, 0),
                Text = ""
            })

            click.MouseButton1Click:Connect(function()
                Tween(button, {
                    BackgroundColor3 = Colors.Active
                })

                task.delay(0.2, function()
                    if button.Parent then
                        Tween(button, {
                            BackgroundColor3 = Colors.Element
                        })
                    end
                end)

                if options.Callback then
                    task.spawn(options.Callback)
                end
            end)

            return button
        end

        -- TOGGLE

        function Tab:CreateToggle(options)
            options = options or {}

            local state = options.Default or false

            local toggle = CreateElement(PAGE, 32)
            Corner(toggle, 5)

            CreateText(toggle, options.Name or "Toggle", 13)

            local indicator = New("Frame", {
                Parent = toggle,
                BackgroundColor3 = state and Colors.Active or Colors.Muted,
                Position = UDim2.new(1, -35, 0.5, -8),
                Size = UDim2.new(0, 25, 0, 16),
                BorderSizePixel = 0
            })

            Corner(indicator, 8)

            local circle = New("Frame", {
                Parent = indicator,
                BackgroundColor3 = Colors.Text,
                Position = state and UDim2.new(1, -13, 0, 2) or UDim2.new(0, 2, 0, 2),
                Size = UDim2.new(0, 12, 0, 12),
                BorderSizePixel = 0
            })

            Corner(circle, 8)

            local click = New("TextButton", {
                Parent = toggle,
                BackgroundTransparency = 1,
                Size = UDim2.new(1, 0, 1, 0),
                Text = ""
            })

            local function Update()
                Tween(indicator, {
                    BackgroundColor3 = state and Colors.Active or Colors.Muted
                })

                Tween(circle, {
                    Position = state
                        and UDim2.new(1, -13, 0, 2)
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
                state = not not value
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
            local value = math.clamp(
                options.Default or minimum,
                minimum,
                maximum
            )

            local slider = CreateElement(PAGE, 52)
            Corner(slider, 5)

            local title = CreateText(
                slider,
                options.Name or "Slider",
                13
            )

            title.Size = UDim2.new(1, -65, 0, 24)

            local valueLabel = New("TextLabel", {
                Parent = slider,
                BackgroundTransparency = 1,
                Position = UDim2.new(1, -55, 0, 0),
                Size = UDim2.new(0, 45, 0, 24),
                Font = Enum.Font.Gotham,
                TextColor3 = Colors.Text,
                TextSize = 12,
                Text = tostring(value)
            })

            local bar = New("Frame", {
                Parent = slider,
                BackgroundColor3 = Colors.Bar,
                BorderSizePixel = 0,
                Position = UDim2.new(0, 9, 0, 32),
                Size = UDim2.new(1, -18, 0, 7)
            })

            Corner(bar, 5)

            local fill = New("Frame", {
                Parent = bar,
                BackgroundColor3 = Colors.Active,
                BorderSizePixel = 0,
                Size = UDim2.new(
                    (value - minimum) / (maximum - minimum),
                    0, 1, 0
                )
            })

            Corner(fill, 5)

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
            local label = CreateElement(PAGE, 28)
            Corner(label, 5)

            local textLabel = CreateText(label, text or "Label", 13)

            local object = {}

            function object:Set(newText)
                textLabel.Text = tostring(newText)
            end

            return object
        end

        -- SECTION

        function Tab:CreateSection(text)
            local section = New("TextLabel", {
                Parent = PAGE,
                BackgroundTransparency = 1,
                Size = UDim2.new(1, -4, 0, 25),
                Font = Enum.Font.GothamBold,
                Text = text or "Section",
                TextColor3 = Colors.Active,
                TextSize = 13,
                TextXAlignment = Enum.TextXAlignment.Left
            })

            return section
        end

        return Tab
    end

    local Window = {}

    Window.Tabs = Tabs
    Window.GUI = GUI
    Window.Frame = FRAME

    function Window:CreateTab(name)
        return Tabs:CreateTab(name)
    end

    function Window:Destroy()
        GUI:Destroy()
    end

    return Window
end

return Library
