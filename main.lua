
local Library = {}

--==================================================
-- OEO LIB | LIQUID CHROME
--==================================================

local TweenService = game:GetService("TweenService")
local UserInputService = game:GetService("UserInputService")

local C = {
    Black = Color3.fromRGB(4, 4, 6),
    Dark = Color3.fromRGB(12, 12, 15),
    Panel = Color3.fromRGB(23, 24, 28),
    Panel2 = Color3.fromRGB(35, 36, 41),
    White = Color3.fromRGB(255, 255, 255),
    Silver = Color3.fromRGB(210, 215, 224),
    Gray = Color3.fromRGB(105, 108, 116),
    Muted = Color3.fromRGB(155, 158, 166)
}

local Chrome = ColorSequence.new({
    ColorSequenceKeypoint.new(0, Color3.fromRGB(35, 36, 42)),
    ColorSequenceKeypoint.new(0.12, Color3.fromRGB(235, 238, 245)),
    ColorSequenceKeypoint.new(0.24, Color3.fromRGB(90, 93, 101)),
    ColorSequenceKeypoint.new(0.40, Color3.fromRGB(255, 255, 255)),
    ColorSequenceKeypoint.new(0.57, Color3.fromRGB(65, 67, 74)),
    ColorSequenceKeypoint.new(0.73, Color3.fromRGB(220, 224, 232)),
    ColorSequenceKeypoint.new(0.87, Color3.fromRGB(95, 97, 105)),
    ColorSequenceKeypoint.new(1, Color3.fromRGB(245, 247, 250))
})

local DarkMetal = ColorSequence.new({
    ColorSequenceKeypoint.new(0, Color3.fromRGB(57, 59, 66)),
    ColorSequenceKeypoint.new(0.18, Color3.fromRGB(24, 25, 30)),
    ColorSequenceKeypoint.new(0.55, Color3.fromRGB(8, 8, 11)),
    ColorSequenceKeypoint.new(0.82, Color3.fromRGB(30, 31, 37)),
    ColorSequenceKeypoint.new(1, Color3.fromRGB(12, 12, 16))
})

--==================================================
-- UTILITIES
--==================================================

local function New(class, properties)
    local obj = Instance.new(class)

    for key, value in pairs(properties) do
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

local function Gradient(parent, colors, rotation)
    return New("UIGradient", {
        Parent = parent,
        Color = colors,
        Rotation = rotation or 90
    })
end

local function Animate(obj, properties, duration)
    local tween = TweenService:Create(
        obj,
        TweenInfo.new(
            duration or 0.2,
            Enum.EasingStyle.Quint,
            Enum.EasingDirection.Out
        ),
        properties
    )

    tween:Play()
    return tween
end

local function TrackConnection(connections, connection)
    table.insert(connections, connection)
    return connection
end

--==================================================
-- CHROME SURFACE SYSTEM
--==================================================

local function ChromeSurface(parent, size, radius, zindex)
    -- Outer metallic shell

    local shell = New("Frame", {
        Parent = parent,
        BackgroundColor3 = C.Silver,
        BorderSizePixel = 0,
        Size = size,
        ClipsDescendants = true,
        ZIndex = zindex or 1
    })

    Round(shell, radius or 18)
    Gradient(shell, Chrome, 0)

    -- Dark inner surface

    local face = New("Frame", {
        Parent = shell,
        BackgroundColor3 = C.Black,
        BorderSizePixel = 0,
        Position = UDim2.new(0, 2, 0, 2),
        Size = UDim2.new(1, -4, 1, -4),
        ClipsDescendants = true,
        ZIndex = (zindex or 1) + 1
    })

    Round(face, math.max(2, (radius or 18) - 2))
    Gradient(face, DarkMetal, 90)

    -- Upper metallic reflection

    local highlight = New("Frame", {
        Parent = face,
        BackgroundColor3 = C.White,
        BackgroundTransparency = 0.45,
        BorderSizePixel = 0,
        Position = UDim2.new(0, 15, 0, 0),
        Size = UDim2.new(0.55, 0, 0, 1),
        ZIndex = (zindex or 1) + 2
    })

    Gradient(highlight, ColorSequence.new({
        ColorSequenceKeypoint.new(0, Color3.fromRGB(45, 46, 52)),
        ColorSequenceKeypoint.new(0.5, C.White),
        ColorSequenceKeypoint.new(1, Color3.fromRGB(45, 46, 52))
    }), 0)

    return shell, face
end

local function Text(parent, value, size, position, dimensions)
    return New("TextLabel", {
        Parent = parent,
        BackgroundTransparency = 1,
        Position = position or UDim2.new(0, 14, 0, 0),
        Size = dimensions or UDim2.new(1, -28, 1, 0),
        Font = Enum.Font.GothamMedium,
        Text = tostring(value or ""),
        TextColor3 = C.White,
        TextSize = size or 12,
        TextXAlignment = Enum.TextXAlignment.Left,
        ZIndex = parent.ZIndex + 2
    })
end

--==================================================
-- CREATE WINDOW
--==================================================

function Library:CreateWindow(options)
    options = options or {}

    local Connections = {}
    local Destroyed = false

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

    --==================================================
    -- MAIN OUTER SHELL
    --==================================================

    local Outer = New("Frame", {
        Name = "OEO_Outer",
        Parent = GUI,
        BackgroundColor3 = C.Silver,
        BorderSizePixel = 0,
        Position = UDim2.new(0.5, -290, 0.5, -205),
        Size = UDim2.new(0, 580, 0, 410),
        ClipsDescendants = true,
        ZIndex = 1
    })

    Round(Outer, 25)
    Gradient(Outer, Chrome, 35)

    -- Main black body

    local Main = New("Frame", {
        Name = "Main",
        Parent = Outer,
        BackgroundColor3 = C.Black,
        BorderSizePixel = 0,
        Position = UDim2.new(0, 3, 0, 3),
        Size = UDim2.new(1, -6, 1, -6),
        ClipsDescendants = true,
        ZIndex = 2
    })

    Round(Main, 22)
    Gradient(Main, DarkMetal, 90)

    --==================================================
    -- HEADER
    --==================================================

    local HeaderShell, Header = ChromeSurface(
        Main,
        UDim2.new(1, -14, 0, 54),
        19,
        4
    )

    HeaderShell.Position = UDim2.new(0, 7, 0, 7)

    -- Window title

    local Logo = New("TextLabel", {
        Parent = Header,
        BackgroundTransparency = 1,
        Position = UDim2.new(0, 17, 0, 0),
        Size = UDim2.new(1, -85, 1, 0),
        Font = Enum.Font.GothamBlack,
        Text = options.Name or "OEO Lib",
        TextColor3 = C.White,
        TextSize = 24,
        TextXAlignment = Enum.TextXAlignment.Left,
        ZIndex = 7
    })

    Gradient(Logo, Chrome, 0)

    -- Close button

    local CloseShell, Close = ChromeSurface(
        Header,
        UDim2.new(0, 34, 0, 34),
        18,
        8
    )

    CloseShell.Position = UDim2.new(1, -45, 0.5, -17)

    local CloseText = New("TextButton", {
        Parent = Close,
        BackgroundTransparency = 1,
        Size = UDim2.new(1, 0, 1, 0),
        Font = Enum.Font.GothamBold,
        Text = "×",
        TextColor3 = C.White,
        TextSize = 21,
        ZIndex = 11
    })

    TrackConnection(Connections,
        CloseText.MouseButton1Click:Connect(function()
            GUI:Destroy()
        end)
    )

    --==================================================
    -- WINDOW DRAGGING
    --==================================================

    local dragging = false
    local dragStart
    local startPosition

    TrackConnection(Connections,
        Header.InputBegan:Connect(function(input)
            if input.UserInputType == Enum.UserInputType.MouseButton1
            or input.UserInputType == Enum.UserInputType.Touch then

                dragging = true
                dragStart = input.Position
                startPosition = Outer.Position
            end
        end)
    )

    TrackConnection(Connections,
        UserInputService.InputChanged:Connect(function(input)
            if dragging and (
                input.UserInputType == Enum.UserInputType.MouseMovement
                or input.UserInputType == Enum.UserInputType.Touch
            ) then

                local delta = input.Position - dragStart

                Outer.Position = UDim2.new(
                    startPosition.X.Scale,
                    startPosition.X.Offset + delta.X,
                    startPosition.Y.Scale,
                    startPosition.Y.Offset + delta.Y
                )
            end
        end)
    )

    TrackConnection(Connections,
        UserInputService.InputEnded:Connect(function(input)
            if input.UserInputType == Enum.UserInputType.MouseButton1
            or input.UserInputType == Enum.UserInputType.Touch then
                dragging = false
            end
        end)
    )

    --==================================================
    -- SIDEBAR
    --==================================================

    local SidebarShell, Sidebar = ChromeSurface(
        Main,
        UDim2.new(0, 143, 1, -75),
        20,
        4
    )

    SidebarShell.Position = UDim2.new(0, 7, 0, 68)

    -- Tab list

    local TabContainer = New("ScrollingFrame", {
        Parent = Sidebar,
        BackgroundTransparency = 1,
        BorderSizePixel = 0,
        Position = UDim2.new(0, 9, 0, 12),
        Size = UDim2.new(1, -18, 1, -24),
        ScrollBarThickness = 2,
        ScrollBarImageColor3 = C.Silver,
        AutomaticCanvasSize = Enum.AutomaticSize.Y,
        CanvasSize = UDim2.new(0, 0, 0, 0),
        ZIndex = 8
    })

    New("UIListLayout", {
        Parent = TabContainer,
        Padding = UDim.new(0, 9),
        SortOrder = Enum.SortOrder.LayoutOrder
    })

    --==================================================
    -- PAGE CONTAINER
    --==================================================

    local Pages = New("Frame", {
        Parent = Main,
        BackgroundTransparency = 1,
        Position = UDim2.new(0, 158, 0, 70),
        Size = UDim2.new(1, -169, 1, -82),
        ClipsDescendants = true,
        ZIndex = 4
    })

    --==================================================
    -- TAB SYSTEM
    --==================================================

    local Tabs = {}
    local TabCount = 0

    local function SelectTab(selected)
        for _, tab in ipairs(Tabs) do
            tab.Page.Visible = false

            Animate(tab.Face, {
                BackgroundColor3 = C.Surface
            })

            Animate(tab.Label, {
                TextColor3 = C.Muted
            })

            tab.Shell.BackgroundColor3 = C.Gray
        end

        selected.Page.Visible = true

        Animate(selected.Face, {
            BackgroundColor3 = Color3.fromRGB(65, 67, 74)
        })

        Animate(selected.Label, {
            TextColor3 = C.White
        })

        selected.Shell.BackgroundColor3 = C.Silver
    end

    --==================================================
    -- CREATE TAB
    --==================================================

    function Tabs:CreateTab(name)
        name = name or "New Tab"
        TabCount += 1

        -- Rounded metallic tab

        local ButtonShell, ButtonFace = ChromeSurface(
            TabContainer,
            UDim2.new(1, 0, 0, 42),
            22,
            8
        )

        ButtonShell.Name = name .. "_Tab"
        ButtonShell.LayoutOrder = TabCount

        local Label = Text(
            ButtonFace,
            name,
            12,
            UDim2.new(0, 14, 0, 0),
            UDim2.new(1, -25, 1, 0)
        )

        local Click = New("TextButton", {
            Parent = ButtonFace,
            BackgroundTransparency = 1,
            Size = UDim2.new(1, 0, 1, 0),
            Text = "",
            ZIndex = 12
        })

        -- Page

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
            Visible = false,
            ZIndex = 5
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
            Shell = ButtonShell,
            Face = ButtonFace,
            Label = Label,
            Page = Page
        }

        table.insert(Tabs, Tab)

        TrackConnection(Connections,
            Click.MouseButton1Click:Connect(function()
                SelectTab(Tab)
            end)
        )

        if #Tabs == 1 then
            SelectTab(Tab)
        end

        --==================================================
        -- ELEMENT CREATOR
        --==================================================

        local function Element(height, radius)
            local shell, face = ChromeSurface(
                Page,
                UDim2.new(1, 0, 0, height),
                radius or 17,
                7
            )

            return shell, face
        end

        --==================================================
        -- BUTTON
        --==================================================

        function Tab:CreateButton(options)
            options = options or {}

            local shell, face = Element(44, 20)

            local label = Text(
                face,
                options.Name or "Button",
                12
            )

            local click = New("TextButton", {
                Parent = face,
                BackgroundTransparency = 1,
                Size = UDim2.new(1, 0, 1, 0),
                Text = "",
                ZIndex = 12
            })

            TrackConnection(Connections,
                click.MouseButton1Click:Connect(function()
                    Animate(face, {
                        BackgroundColor3 = Color3.fromRGB(85, 87, 95)
                    }, 0.12)

                    task.delay(0.16, function()
                        if face.Parent then
                            Animate(face, {
                                BackgroundColor3 = C.Panel
                            })
                        end
                    end)

                    if options.Callback then
                        task.spawn(options.Callback)
                    end
                end)
            )

            TrackConnection(Connections,
                click.MouseEnter:Connect(function()
                    Animate(face, {
                        BackgroundColor3 = C.Panel2
                    })
                end)
            )

            TrackConnection(Connections,
                click.MouseLeave:Connect(function()
                    Animate(face, {
                        BackgroundColor3 = C.Panel
                    })
                end)
            )

            return {
                Shell = shell,
                Frame = face,
                Label = label
            }
        end

        --==================================================
        -- TOGGLE
        --==================================================

        function Tab:CreateToggle(options)
            options = options or {}

            local state = options.Default == true

            local shell, face = Element(44, 20)

            Text(face, options.Name or "Toggle", 12)

            -- Chrome switch shell

            local switchShell, switch = ChromeSurface(
                face,
                UDim2.new(0, 39, 0, 23),
                15,
                10
            )

            switchShell.Position = UDim2.new(1, -49, 0.5, -11)

            local knob = New("Frame", {
                Parent = switch,
                BackgroundColor3 = C.White,
                BorderSizePixel = 0,
                Position = state
                    and UDim2.new(1, -18, 0, 2)
                    or UDim2.new(0, 2, 0, 2),
                Size = UDim2.new(0, 15, 0, 15),
                ZIndex = 14
            })

            Round(knob, 15)

            New("UIStroke", {
                Parent = knob,
                Color = C.Silver,
                Thickness = 1
            })

            local click = New("TextButton", {
                Parent = face,
                BackgroundTransparency = 1,
                Size = UDim2.new(1, 0, 1, 0),
                Text = "",
                ZIndex = 16
            })

            local function Update()
                Animate(knob, {
                    Position = state
                        and UDim2.new(1, -18, 0, 2)
                        or UDim2.new(0, 2, 0, 2)
                })

                Animate(switch, {
                    BackgroundColor3 = state
                        and Color3.fromRGB(150, 153, 162)
                        or C.Panel2
                })

                if options.Callback then
                    task.spawn(options.Callback, state)
                end
            end

            TrackConnection(Connections,
                click.MouseButton1Click:Connect(function()
                    state = not state
                    Update()
                end)
            )

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

            assert(maximum > minimum, "Max must exceed Min")

            local value = math.clamp(
                options.Default or minimum,
                minimum,
                maximum
            )

            local shell, face = Element(65, 20)

            local title = Text(
                face,
                options.Name or "Slider",
                12,
                UDim2.new(0, 13, 0, 0),
                UDim2.new(1, -85, 0, 31)
            )

            local valueLabel = New("TextLabel", {
                Parent = face,
                BackgroundTransparency = 1,
                Position = UDim2.new(1, -65, 0, 0),
                Size = UDim2.new(0, 50, 0, 31),
                Font = Enum.Font.GothamMedium,
                Text = tostring(value),
                TextColor3 = C.Silver,
                TextSize = 11,
                ZIndex = 10
            })

            -- Track shell

            local trackShell, track = ChromeSurface(
                face,
                UDim2.new(1, -28, 0, 12),
                9,
                10
            )

            trackShell.Position = UDim2.new(0, 14, 0, 41)

            -- Fill

            local fill = New("Frame", {
                Parent = track,
                BackgroundColor3 = C.Silver,
                BorderSizePixel = 0,
                Size = UDim2.new(
                    (value - minimum) / (maximum - minimum),
                    0, 1, 0
                ),
                ZIndex = 12
            })

            Round(fill, 9)
            Gradient(fill, Chrome, 0)

            -- Spherical knob

            local knob = New("Frame", {
                Parent = track,
                BackgroundColor3 = C.Silver,
                BorderSizePixel = 0,
                AnchorPoint = Vector2.new(0.5, 0.5),
                Position = UDim2.new(
                    (value - minimum) / (maximum - minimum),
                    0, 0.5, 0
                ),
                Size = UDim2.new(0, 19, 0, 19),
                ZIndex = 15
            })

            Round(knob, 20)
            Gradient(knob, Chrome, 45)

            New("UIStroke", {
                Parent = knob,
                Color = C.White,
                Thickness = 1
            })

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

                valueLabel.Text = tostring(value)

                if options.Callback then
                    task.spawn(options.Callback, value)
                end
            end

            local function Update(input)
                local percent = math.clamp(
                    (input.Position.X - track.AbsolutePosition.X)
                    / track.AbsoluteSize.X,
                    0,
                    1
                )

                SetValue(minimum + percent * (maximum - minimum))
            end

            local click = New("TextButton", {
                Parent = trackShell,
                BackgroundTransparency = 1,
                Position = UDim2.new(0, -5, 0, -8),
                Size = UDim2.new(1, 10, 1, 16),
                Text = "",
                ZIndex = 20
            })

            TrackConnection(Connections,
                click.InputBegan:Connect(function(input)
                    if input.UserInputType == Enum.UserInputType.MouseButton1
                    or input.UserInputType == Enum.UserInputType.Touch then
                        draggingSlider = true
                        Update(input)
                    end
                end)
            )

            local changedConnection = UserInputService.InputChanged:Connect(function(input)
                if draggingSlider and (
                    input.UserInputType == Enum.UserInputType.MouseMovement
                    or input.UserInputType == Enum.UserInputType.Touch
                ) then
                    Update(input)
                end
            end)

            TrackConnection(Connections, changedConnection)

            TrackConnection(Connections,
                UserInputService.InputEnded:Connect(function(input)
                    if input.UserInputType == Enum.UserInputType.MouseButton1
                    or input.UserInputType == Enum.UserInputType.Touch then
                        draggingSlider = false
                    end
                end)
            )

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
            local shell, face = Element(40, 20)

            local label = Text(
                face,
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
            local section = New("TextLabel", {
                Parent = Page,
                BackgroundTransparency = 1,
                Size = UDim2.new(1, 0, 0, 28),
                Font = Enum.Font.GothamBold,
                Text = string.upper(value or "SECTION"),
                TextColor3 = C.Silver,
                TextSize = 11,
                TextXAlignment = Enum.TextXAlignment.Left,
                ZIndex = 8
            })

            Gradient(section, Chrome, 0)

            return section
        end

        return Tab
    end

    --==================================================
    -- WINDOW API
    --==================================================

    local Window = {}

    Window.GUI = GUI
    Window.Frame = Outer
    Window.Tabs = Tabs

    function Window:CreateTab(name)
        return Tabs:CreateTab(name)
    end

    function Window:SetTitle(name)
        Logo.Text = tostring(name)
    end

    function Window:Destroy()
        if Destroyed then
            return
        end

        Destroyed = true

        for _, connection in ipairs(Connections) do
            pcall(function()
                connection:Disconnect()
            end)
        end

        GUI:Destroy()
    end

    return Window
end

return Library
