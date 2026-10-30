
local Library = {}

local TweenService = game:GetService("TweenService")
local UserInputService = game:GetService("UserInputService")

--==================================================
-- OEO LIB CONFIGURATION
--==================================================

local C = {
    Black = Color3.fromRGB(5, 5, 7),
    Background = Color3.fromRGB(12, 12, 15),
    Surface = Color3.fromRGB(25, 26, 30),
    Surface2 = Color3.fromRGB(38, 39, 44),
    White = Color3.fromRGB(255, 255, 255),
    Silver = Color3.fromRGB(205, 210, 220),
    Gray = Color3.fromRGB(115, 118, 125),
    Text = Color3.fromRGB(245, 245, 250),
    Muted = Color3.fromRGB(145, 148, 155)
}

local Chrome = ColorSequence.new({
    ColorSequenceKeypoint.new(0, Color3.fromRGB(35, 36, 40)),
    ColorSequenceKeypoint.new(0.16, Color3.fromRGB(245, 247, 250)),
    ColorSequenceKeypoint.new(0.30, Color3.fromRGB(100, 103, 110)),
    ColorSequenceKeypoint.new(0.48, Color3.fromRGB(255, 255, 255)),
    ColorSequenceKeypoint.new(0.63, Color3.fromRGB(85, 87, 94)),
    ColorSequenceKeypoint.new(0.80, Color3.fromRGB(220, 223, 230)),
    ColorSequenceKeypoint.new(1, Color3.fromRGB(45, 46, 52))
})

--==================================================
-- UTILITIES
--==================================================

local function New(class, props)
    local obj = Instance.new(class)

    for key, value in pairs(props) do
        obj[key] = value
    end

    return obj
end

local function Round(parent, radius)
    return New("UICorner", {
        Parent = parent,
        CornerRadius = UDim.new(0, radius)
    })
end

local function Animate(obj, props, duration)
    local tween = TweenService:Create(
        obj,
        TweenInfo.new(
            duration or 0.22,
            Enum.EasingStyle.Quint,
            Enum.EasingDirection.Out
        ),
        props
    )

    tween:Play()
    return tween
end

local function ChromeStroke(parent, thickness)
    local stroke = New("UIStroke", {
        Parent = parent,
        Thickness = thickness or 1.3,
        Color = C.Silver,
        Transparency = 0.12,
        ApplyStrokeMode = Enum.ApplyStrokeMode.Border
    })

    New("UIGradient", {
        Parent = stroke,
        Color = Chrome,
        Rotation = 45
    })

    return stroke
end

local function ChromeSurface(parent, radius, color)
    local frame = New("Frame", {
        Parent = parent,
        BackgroundColor3 = color or C.Surface,
        BorderSizePixel = 0
    })

    Round(frame, radius or 18)
    ChromeStroke(frame, 1.3)

    -- Dark metallic surface gradient
    New("UIGradient", {
        Parent = frame,
        Color = ColorSequence.new({
            ColorSequenceKeypoint.new(0, Color3.fromRGB(48, 49, 55)),
            ColorSequenceKeypoint.new(0.35, Color3.fromRGB(19, 20, 24)),
            ColorSequenceKeypoint.new(0.75, Color3.fromRGB(33, 34, 39)),
            ColorSequenceKeypoint.new(1, Color3.fromRGB(12, 12, 15))
        }),
        Rotation = 90
    })

    return frame
end

local function Text(parent, value, size, position, width)
    return New("TextLabel", {
        Parent = parent,
        BackgroundTransparency = 1,
        Position = position or UDim2.new(0, 15, 0, 0),
        Size = UDim2.new(1, -(width or 30), 1, 0),
        Font = Enum.Font.GothamMedium,
        Text = tostring(value or ""),
        TextColor3 = C.Text,
        TextSize = size or 12,
        TextXAlignment = Enum.TextXAlignment.Left
    })
end

--==================================================
-- WINDOW
--==================================================

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
        BackgroundColor3 = C.Black,
        BorderSizePixel = 0,
        Position = UDim2.new(0.5, -280, 0.5, -190),
        Size = UDim2.new(0, 560, 0, 380),
        ClipsDescendants = true
    })

    Round(Main, 23)
    ChromeStroke(Main, 2)

    New("UIGradient", {
        Parent = Main,
        Color = ColorSequence.new({
            ColorSequenceKeypoint.new(0, Color3.fromRGB(26, 27, 32)),
            ColorSequenceKeypoint.new(0.5, C.Black),
            ColorSequenceKeypoint.new(1, Color3.fromRGB(28, 29, 34))
        }),
        Rotation = 45
    })

    -- HEADER

    local Header = New("Frame", {
        Parent = Main,
        BackgroundColor3 = C.Background,
        BorderSizePixel = 0,
        Size = UDim2.new(1, 0, 0, 55)
    })

    local Logo = New("TextLabel", {
        Parent = Header,
        BackgroundTransparency = 1,
        Position = UDim2.new(0, 20, 0, 0),
        Size = UDim2.new(1, -85, 1, 0),
        Font = Enum.Font.GothamBlack,
        Text = options.Name or "OEO Lib",
        TextColor3 = C.White,
        TextSize = 23,
        TextXAlignment = Enum.TextXAlignment.Left
    })

    New("UIGradient", {
        Parent = Logo,
        Color = Chrome,
        Rotation = 0
    })

    local Close = New("TextButton", {
        Parent = Header,
        BackgroundColor3 = C.Surface2,
        Position = UDim2.new(1, -43, 0, 12),
        Size = UDim2.new(0, 29, 0, 29),
        BorderSizePixel = 0,
        Font = Enum.Font.GothamBold,
        Text = "×",
        TextColor3 = C.White,
        TextSize = 21,
        AutoButtonColor = false
    })

    Round(Close, 15)
    ChromeStroke(Close, 1)

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
        Parent = Main,
        BackgroundColor3 = C.Background,
        BorderSizePixel = 0,
        Position = UDim2.new(0, 0, 0, 55),
        Size = UDim2.new(0, 140, 1, -55)
    })

    local TabContainer = New("ScrollingFrame", {
        Parent = Sidebar,
        BackgroundTransparency = 1,
        Position = UDim2.new(0, 10, 0, 14),
        Size = UDim2.new(1, -20, 1, -25),
        BorderSizePixel = 0,
        ScrollBarThickness = 2,
        ScrollBarImageColor3 = C.Silver,
        AutomaticCanvasSize = Enum.AutomaticSize.Y,
        CanvasSize = UDim2.new(0, 0, 0, 0)
    })

    New("UIListLayout", {
        Parent = TabContainer,
        Padding = UDim.new(0, 9),
        SortOrder = Enum.SortOrder.LayoutOrder
    })

    -- PAGE AREA

    local Pages = New("Frame", {
        Parent = Main,
        BackgroundTransparency = 1,
        Position = UDim2.new(0, 150, 0, 65),
        Size = UDim2.new(1, -162, 1, -78),
        ClipsDescendants = true
    })

    --==================================================
    -- TAB SYSTEM
    --==================================================

    local Tabs = {}
    local TabCount = 0

    local function SelectTab(selected)
        for _, tab in ipairs(Tabs) do
            tab.Page.Visible = false

            Animate(tab.Button, {
                BackgroundColor3 = C.Surface
            })

            Animate(tab.Label, {
                TextColor3 = C.Muted
            })

            tab.Stroke.Transparency = 0.55
        end

        selected.Page.Visible = true

        Animate(selected.Button, {
            BackgroundColor3 = Color3.fromRGB(80, 82, 90)
        })

        Animate(selected.Label, {
            TextColor3 = C.White
        })

        selected.Stroke.Transparency = 0.05
    end

    function Tabs:CreateTab(name)
        name = name or "New Tab"
        TabCount += 1

        -- PILL TAB BUTTON

        local Button = New("TextButton", {
            Parent = TabContainer,
            Name = name .. "_Tab",
            BackgroundColor3 = C.Surface,
            BorderSizePixel = 0,
            Size = UDim2.new(1, 0, 0, 37),
            Text = "",
            AutoButtonColor = false,
            LayoutOrder = TabCount
        })

        Round(Button, 19)

        local ButtonStroke = ChromeStroke(Button, 1)

        local Label = Text(
            Button,
            name,
            12,
            UDim2.new(0, 15, 0, 0),
            25
        )

        local Page = New("ScrollingFrame", {
            Parent = Pages,
            Name = name .. "_Page",
            BackgroundTransparency = 1,
            BorderSizePixel = 0,
            Size = UDim2.new(1, 0, 1, 0),
            ScrollBarThickness = 3,
            ScrollBarImageColor3 = C.Silver,
            AutomaticCanvasSize = Enum.AutomaticSize.Y,
            CanvasSize = UDim2.new(0, 0, 0, 0),
            Visible = false
        })

        New("UIListLayout", {
            Parent = Page,
            Padding = UDim.new(0, 10),
            SortOrder = Enum.SortOrder.LayoutOrder
        })

        New("UIPadding", {
            Parent = Page,
            PaddingTop = UDim.new(0, 6),
            PaddingBottom = UDim.new(0, 10),
            PaddingLeft = UDim.new(0, 5),
            PaddingRight = UDim.new(0, 8)
        })

        local Tab = {
            Button = Button,
            Label = Label,
            Stroke = ButtonStroke,
            Page = Page
        }

        table.insert(Tabs, Tab)

        Button.MouseButton1Click:Connect(function()
            SelectTab(Tab)
        end)

        Button.MouseEnter:Connect(function()
            if not Page.Visible then
                Animate(Button, {
                    BackgroundColor3 = C.Surface2
                })
            end
        end)

        Button.MouseLeave:Connect(function()
            if not Page.Visible then
                Animate(Button, {
                    BackgroundColor3 = C.Surface
                })
            end
        end)

        if #Tabs == 1 then
            SelectTab(Tab)
        end

        --==================================================
        -- ELEMENT HELPERS
        --==================================================

        local function Element(height)
            local frame = ChromeSurface(
                Page,
                18,
                C.Surface
            )

            frame.Size = UDim2.new(1, 0, 0, height)

            return frame
        end

        --==================================================
        -- BUTTON
        --==================================================

        function Tab:CreateButton(options)
            options = options or {}

            local frame = Element(43)

            Text(
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
                Animate(frame, {
                    BackgroundColor3 = C.Silver
                }, 0.12)

                task.delay(0.15, function()
                    if frame.Parent then
                        Animate(frame, {
                            BackgroundColor3 = C.Surface
                        })
                    end
                end)

                if options.Callback then
                    task.spawn(options.Callback)
                end
            end)

            return frame
        end

        --==================================================
        -- TOGGLE
        --==================================================

        function Tab:CreateToggle(options)
            options = options or {}

            local state = options.Default == true

            local frame = Element(43)

            Text(
                frame,
                options.Name or "Toggle",
                12
            )

            local switch = New("Frame", {
                Parent = frame,
                BackgroundColor3 = state and C.Silver or C.Gray,
                BorderSizePixel = 0,
                Position = UDim2.new(1, -48, 0.5, -10),
                Size = UDim2.new(0, 37, 0, 20)
            })

            Round(switch, 15)

            local knob = New("Frame", {
                Parent = switch,
                BackgroundColor3 = C.White,
                BorderSizePixel = 0,
                Position = state
                    and UDim2.new(1, -18, 0, 2)
                    or UDim2.new(0, 2, 0, 2),
                Size = UDim2.new(0, 16, 0, 16)
            })

            Round(knob, 15)
            ChromeStroke(knob, 0.6)

            local click = New("TextButton", {
                Parent = frame,
                BackgroundTransparency = 1,
                Size = UDim2.new(1, 0, 1, 0),
                Text = ""
            })

            local function Update()
                Animate(switch, {
                    BackgroundColor3 = state and C.Silver or C.Gray
                })

                Animate(knob, {
                    Position = state
                        and UDim2.new(1, -18, 0, 2)
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

        --==================================================
        -- SLIDER
        --==================================================

        function Tab:CreateSlider(options)
            options = options or {}

            local minimum = options.Min or 0
            local maximum = options.Max or 100

            assert(maximum > minimum, "Invalid slider range")

            local value = math.clamp(
                options.Default or minimum,
                minimum,
                maximum
            )

            local frame = Element(62)

            local title = Text(
                frame,
                options.Name or "Slider",
                12,
                UDim2.new(0, 14, 0, 0),
                75
            )

            title.Size = UDim2.new(1, -85, 0, 30)

            local valueText = New("TextLabel", {
                Parent = frame,
                BackgroundTransparency = 1,
                Position = UDim2.new(1, -65, 0, 0),
                Size = UDim2.new(0, 50, 0, 30),
                Font = Enum.Font.GothamMedium,
                Text = tostring(value),
                TextColor3 = C.Silver,
                TextSize = 11
            })

            local bar = New("Frame", {
                Parent = frame,
                BackgroundColor3 = C.Gray,
                BorderSizePixel = 0,
                Position = UDim2.new(0, 14, 0, 40),
                Size = UDim2.new(1, -28, 0, 6)
            })

            Round(bar, 10)

            local fill = New("Frame", {
                Parent = bar,
                BackgroundColor3 = C.Silver,
                BorderSizePixel = 0,
                Size = UDim2.new(
                    (value - minimum) / (maximum - minimum),
                    0, 1, 0
                )
            })

            Round(fill, 10)
            New("UIGradient", {
                Parent = fill,
                Color = Chrome,
                Rotation = 0
            })

            local knob = New("Frame", {
                Parent = bar,
                BackgroundColor3 = C.White,
                BorderSizePixel = 0,
                AnchorPoint = Vector2.new(0.5, 0.5),
                Position = UDim2.new(
                    (value - minimum) / (maximum - minimum),
                    0, 0.5, 0
                ),
                Size = UDim2.new(0, 14, 0, 14)
            })

            Round(knob, 10)
            ChromeStroke(knob, 0.7)

            local draggingSlider = false

            local function SetValue(newValue)
                value = math.clamp(
                    math.floor(newValue + 0.5),
                    minimum,
                    maximum
                )

                local percent = (value - minimum) / (maximum - minimum)

                Animate(fill, {
                    Size = UDim2.new(percent, 0, 1, 0)
                })

                Animate(knob, {
                    Position = UDim2.new(percent, 0, 0.5, 0)
                })

                valueText.Text = tostring(value)

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

                SetValue(minimum + percent * (maximum - minimum))
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

        --==================================================
        -- LABEL
        --==================================================

        function Tab:CreateLabel(value)
            local frame = Element(37)

            local label = Text(
                frame,
                value or "Label",
                12
            )

            local object = {}

            function object:Set(newValue)
                label.Text = tostring(newValue)
            end

            return object
        end

        --==================================================
        -- SECTION
        --==================================================

        function Tab:CreateSection(value)
            local frame = New("Frame", {
                Parent = Page,
                BackgroundTransparency = 1,
                Size = UDim2.new(1, 0, 0, 27)
            })

            local label = New("TextLabel", {
                Parent = frame,
                BackgroundTransparency = 1,
                Size = UDim2.new(1, 0, 1, 0),
                Font = Enum.Font.GothamBold,
                Text = string.upper(value or "SECTION"),
                TextColor3 = C.Silver,
                TextSize = 11,
                TextXAlignment = Enum.TextXAlignment.Left
            })

            return label
        end

        return Tab
    end

    --==================================================
    -- WINDOW API
    --==================================================

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
