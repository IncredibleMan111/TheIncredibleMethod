-- Pegasus UI Library (Edited to match reg.lua usage)

local UILibrary = {}
UILibrary.__index = UILibrary

-- Create new UI
function UILibrary.new(accentColor)
    local self = setmetatable({}, UILibrary)

    -- ScreenGui setup
    local ScreenGui = Instance.new("ScreenGui")
    ScreenGui.Name = "PegasusUI"
    ScreenGui.ResetOnSpawn = false

    if syn and syn.protect_gui then
        syn.protect_gui(ScreenGui)
    elseif gethui then
        ScreenGui.Parent = gethui()
    else
        ScreenGui.Parent = game:GetService("CoreGui")
    end

    self.UI = ScreenGui
    self.Accent = accentColor or Color3.fromRGB(67, 7, 241)
    self.Windows = {}

    return self
end

-- Load a new window
function UILibrary:LoadWindow(title, size)
    local WindowLibrary = {}
    WindowLibrary.__index = WindowLibrary

    -- Create main frame
    local Window = Instance.new("Frame")
    Window.Name = "MainWindow"
    Window.Size = size or UDim2.fromOffset(400, 300)
    Window.Position = UDim2.new(0.5, -200, 0.5, -150)
    Window.AnchorPoint = Vector2.new(0, 0)
    Window.BackgroundColor3 = Color3.fromRGB(25, 25, 25)
    Window.BorderSizePixel = 0
    Window.Parent = self.UI

    -- Title label
    local Title = Instance.new("TextLabel")
    Title.Size = UDim2.new(1, 0, 0, 30)
    Title.BackgroundTransparency = 1
    Title.Text = title or "Window"
    Title.TextColor3 = Color3.fromRGB(255, 255, 255)
    Title.Font = Enum.Font.SourceSansBold
    Title.TextSize = 18
    Title.Parent = Window

    -- Container for pages
    local Container = Instance.new("Frame")
    Container.Size = UDim2.new(1, 0, 1, -30)
    Container.Position = UDim2.new(0, 0, 0, 30)
    Container.BackgroundTransparency = 1
    Container.Parent = Window

    WindowLibrary.Main = Window
    WindowLibrary.Container = Container
    WindowLibrary.Pages = {}

    -- Functions
    function WindowLibrary.NewPage(name)
        local PageLibrary = {}
        PageLibrary.__index = PageLibrary

        -- Page container
        local Page = Instance.new("ScrollingFrame")
        Page.Name = name or "Page"
        Page.Size = UDim2.new(1, 0, 1, 0)
        Page.CanvasSize = UDim2.new(0, 0, 0, 0)
        Page.ScrollBarThickness = 4
        Page.Visible = (#WindowLibrary.Pages == 0)
        Page.Parent = Container

        PageLibrary.Main = Page
        PageLibrary.Sections = {}

        function PageLibrary.NewSection(name)
            local SectionLibrary = {}
            SectionLibrary.__index = SectionLibrary

            local Section = Instance.new("Frame")
            Section.Name = name or "Section"
            Section.Size = UDim2.new(1, -10, 0, 120)
            Section.BackgroundColor3 = Color3.fromRGB(35, 35, 35)
            Section.BorderSizePixel = 0
            Section.Position = UDim2.new(0, 5, 0, (#PageLibrary.Sections * 125) + 5)
            Section.Parent = Page

            local Title = Instance.new("TextLabel")
            Title.Size = UDim2.new(1, 0, 0, 20)
            Title.BackgroundTransparency = 1
            Title.Text = name or "Section"
            Title.TextColor3 = Color3.fromRGB(255, 255, 255)
            Title.Font = Enum.Font.SourceSansBold
            Title.TextSize = 16
            Title.TextXAlignment = Enum.TextXAlignment.Left
            Title.Parent = Section

            SectionLibrary.Main = Section

            -- Element creation methods
            function SectionLibrary.Toggle(text, default, callback)
                local Button = Instance.new("TextButton")
                Button.Size = UDim2.new(1, -10, 0, 25)
                Button.Position = UDim2.new(0, 5, 0, 25)
                Button.BackgroundColor3 = Color3.fromRGB(50, 50, 50)
                Button.TextColor3 = Color3.fromRGB(255, 255, 255)
                Button.Text = text
                Button.Font = Enum.Font.SourceSans
                Button.TextSize = 14
                Button.Parent = Section

                local enabled = default or false
                Button.MouseButton1Click:Connect(function()
                    enabled = not enabled
                    if callback then callback(enabled) end
                end)
            end

            function SectionLibrary.Slider(text, opts, callback)
                -- Minimal slider mockup (no real drag logic, just calls callback)
                local Label = Instance.new("TextLabel")
                Label.Size = UDim2.new(1, -10, 0, 25)
                Label.Position = UDim2.new(0, 5, 0, 55)
                Label.BackgroundTransparency = 1
                Label.Text = string.format("%s [%s]", text, opts.Default or 0)
                Label.TextColor3 = Color3.fromRGB(255, 255, 255)
                Label.Font = Enum.Font.SourceSans
                Label.TextSize = 14
                Label.TextXAlignment = Enum.TextXAlignment.Left
                Label.Parent = Section

                if callback then callback(opts.Default or 0) end
            end

            function SectionLibrary.Dropdown(text, list, callback)
                local Button = Instance.new("TextButton")
                Button.Size = UDim2.new(1, -10, 0, 25)
                Button.Position = UDim2.new(0, 5, 0, 85)
                Button.BackgroundColor3 = Color3.fromRGB(50, 50, 50)
                Button.TextColor3 = Color3.fromRGB(255, 255, 255)
                Button.Text = text .. " ▼"
                Button.Font = Enum.Font.SourceSans
                Button.TextSize = 14
                Button.Parent = Section

                Button.MouseButton1Click:Connect(function()
                    if callback then callback(list[1]) end -- Always pick first for mockup
                end)
            end

            function SectionLibrary.ColorPicker(text, default, callback)
                local Button = Instance.new("TextButton")
                Button.Size = UDim2.new(1, -10, 0, 25)
                Button.Position = UDim2.new(0, 5, 0, 115)
                Button.BackgroundColor3 = default or Color3.fromRGB(255, 0, 0)
                Button.Text = text
                Button.TextColor3 = Color3.fromRGB(255, 255, 255)
                Button.Font = Enum.Font.SourceSans
                Button.TextSize = 14
                Button.Parent = Section

                Button.MouseButton1Click:Connect(function()
                    if callback then callback(Button.BackgroundColor3) end
                end)
            end

            table.insert(PageLibrary.Sections, SectionLibrary)
            return SectionLibrary
        end

        table.insert(WindowLibrary.Pages, PageLibrary)
        return PageLibrary
    end

    function WindowLibrary.SetPosition(pos)
        Window.Position = pos
    end

    function WindowLibrary.GetPosition()
        return Window.Position
    end

    return WindowLibrary
end

return UILibrary
