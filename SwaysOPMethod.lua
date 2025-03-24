if (not game:IsLoaded()) then
    game.Loaded:Wait();
end

-- Load the UI library with the purple theme
local UILibrary = loadstring(game:HttpGet("https://raw.githubusercontent.com/IncredibleMan111/TheIncredibleMethod/refs/heads/main/SwaysUI.lua"))();

local PlaceId = game.PlaceId

local Players = game:GetService("Players");
local HttpService = game:GetService("HttpService");
local Workspace = game:GetService("Workspace");
local Teams = game:GetService("Teams")
local UserInputService = game:GetService("UserInputService")
local RunService = game:GetService("RunService");

local CurrentCamera = Workspace.CurrentCamera
local WorldToViewportPoint = CurrentCamera.WorldToViewportPoint
local GetPartsObscuringTarget = CurrentCamera.GetPartsObscuringTarget

local Inset = game:GetService("GuiService"):GetGuiInset().Y

local FindFirstChild = game.FindFirstChild
local FindFirstChildWhichIsA = game.FindFirstChildWhichIsA
local IsA = game.IsA
local Vector2new = Vector2.new
local Vector3new = Vector3.new
local CFramenew = CFrame.new
local Color3new = Color3.new

local Tfind = table.find
local create = table.create
local format = string.format
local floor = math.floor
local gsub = string.gsub
local sub = string.sub
local lower = string.lower
local upper = string.upper
local random = math.random

local DefaultSettings = {
    ConfigName = "Default", -- Added config name
    Whitelist = {}, -- Added whitelist
    Esp = {
        NamesEnabled = false,
        DisplayNamesEnabled = false,
        DistanceEnabled = false,
        HealthEnabled = false,
        TracersEnabled = false,
        BoxEsp = false,
        TeamColors = false,
        Thickness = 1.5,
        TracerThickness = 1.6,
        Transparency = .9,
        TracerTrancparency = .7,
        Size = 16,
        RenderDistance = 9e9,
        Color = Color3.fromRGB(19, 130, 226),
        WhitelistColor = Color3.fromRGB(0, 255, 0), -- Added whitelist color
        OutlineColor = Color3new(),
        TracerTo = "Head",
        BlacklistedTeams = {}
    },
    Aimbot = {
        Enabled = false,
        SilentAim = false,
        Wallbang = false,
        ShowFov = false,
        Snaplines = true,
        ThirdPerson = false,
        FirstPerson = false,
        ClosestCharacter = false,
        ClosestCursor = true,
        Smoothness = 1,
        SilentAimHitChance = 24,
        FovThickness = 1,
        FovTransparency = 1,
        FovSize = 35,
        FovColor = Color3new(1, 1, 1),
        Aimlock = "Head",
        SilentAimRedirect = "Head",
        BlacklistedTeams = {}
    },
    WindowPosition = UDim2.new(0.5, -200, 0.5, -139);
    Version = 1.2
}

local EncodeConfig, DecodeConfig;
do
    local deepsearchset;
    deepsearchset = function(tbl, ret, value)
        if (type(tbl) == 'table') then
            local new = {}
            for i, v in next, tbl do
                new[i] = v
                if (type(v) == 'table') then
                    new[i] = deepsearchset(v, ret, value);
                end
                if (ret(i, v)) then
                    new[i] = value(i, v);
                end
            end
            return new
        end
    end

    DecodeConfig = function(Config)
        local DecodedConfig = deepsearchset(Config, function(Index, Value)
            return type(Value) == "table" and (Value.HSVColor or Value.Position);
        end, function(Index, Value)
            local Color = Value.HSVColor
            local Position = Value.Position
            if (Color) then
                return Color3.fromHSV(Color.H, Color.S, Color.V);
            end
            if (Position and Position.Y and Position.X) then
                return UDim2.new(UDim.new(Position.X.Scale, Position.X.Offset), UDim.new(Position.Y.Scale, Position.Y.Offset));
            else
                return DefaultSettings.WindowPosition;
            end
        end);
        return DecodedConfig
    end

    EncodeConfig = function(Config)
        local ToHSV = Color3new().ToHSV
        local EncodedConfig = deepsearchset(Config, function(Index, Value)
            return typeof(Value) == "Color3" or typeof(Value) == "UDim2"
        end, function(Index, Value)
            local Color = typeof(Value) == "Color3"
            local Position = typeof(Value) == "UDim2"
            if (Color) then
                local H, S, V = ToHSV(Value);
                return { HSVColor = { H = H, S = S, V = V } };
            end
            if (Position) then
                return { Position = {
                    X = { Scale = Value.X.Scale, Offset = Value.X.Offset };
                    Y = { Scale = Value.Y.Scale, Offset = Value.Y.Offset }
                } };
            end
        end)
        return EncodedConfig
    end
end

local GetConfig = function(ConfigName)
    local read, data = pcall(readfile, "SWAYSMENU/" .. ConfigName .. ".json");
    local canDecode, config = pcall(HttpService.JSONDecode, HttpService, data);
    if (read and canDecode) then
        local Decoded = DecodeConfig(config);
        if (Decoded.Version ~= DefaultSettings.Version) then
            local Encoded = HttpService:JSONEncode(EncodeConfig(DefaultSettings));
            writefile("SWAYSMENU/" .. ConfigName .. ".json", Encoded);
            return DefaultSettings;
        end
        return Decoded;
    else
        local Encoded = HttpService:JSONEncode(EncodeConfig(DefaultSettings));
        writefile("SWAYSMENU/" .. ConfigName .. ".json", Encoded);
        return DefaultSettings
    end
end

local SaveConfig = function(ConfigName)
    local Encoded = HttpService:JSONEncode(EncodeConfig(Settings));
    writefile("SWAYSMENU/" .. ConfigName .. ".json", Encoded);
end

local DeleteConfig = function(ConfigName)
    pcall(delfile, "SWAYSMENU/" .. ConfigName .. ".json");
end

local ListConfigs = function()
    local Configs = {}
    for _, File in pairs(listfiles("SWAYSMENU")) do
        if (File:match(".json$")) then
            table.insert(Configs, File:gsub("SWAYSMENU\\", ""):gsub(".json", ""));
        end
    end
    return Configs
end

-- Ensure SWAYSMENU folder exists
if not isfolder("SWAYSMENU") then
    makefolder("SWAYSMENU");
end

local Settings = GetConfig("Default");

local LocalPlayer = Players.LocalPlayer
local Mouse = LocalPlayer:GetMouse();
local MouseVector = Vector2new(Mouse.X, Mouse.Y);
local Characters = {}

local CustomGet = {
    [0] = function()
        return {}
    end
}

local Get;
if (CustomGet[PlaceId]) then
    Get = CustomGet[PlaceId]();
end

local GetCharacter = function(Player)
    if (Get) then
        return Get.GetCharacter(Player);
    end
    return Player.Character
end
local CharacterAdded = function(Player, Callback)
    if (Get) then
        return
    end
    Player.CharacterAdded:Connect(Callback);
end
local CharacterRemoving = function(Player, Callback)
    if (Get) then
        return
    end
    Player.CharacterRemoving:Connect(Callback);
end

local GetTeam = function(Player)
    if (Get) then
        return Get.GetTeam(Player);
    end
    return Player.Team
end

local Drawings = {}

local AimbotSettings = Settings.Aimbot
local EspSettings = Settings.Esp

local FOV = Drawing.new("Circle");
FOV.Color = AimbotSettings.FovColor
FOV.Thickness = AimbotSettings.FovThickness
FOV.Transparency = AimbotSettings.FovTransparency
FOV.Filled = false
FOV.Radius = AimbotSettings.FovSize

local Snaplines = Drawing.new("Line");
Snaplines.Color = AimbotSettings.FovColor
Snaplines.Thickness = .1
Snaplines.Transparency = 1
Snaplines.Visible = AimbotSettings.Snaplines

table.insert(Drawings, FOV);
table.insert(Drawings, Snaplines);

local HandlePlayer = function(Player)
    local Character = GetCharacter(Player);
    if (Character) then
        Characters[Player] = Character
    end
    CharacterAdded(Player, function(Char)
        Characters[Player] = Char
    end);
    CharacterRemoving(Player, function(Char)
        Characters[Player] = nil
        local PlayerDrawings = Drawings[Player]
        if (PlayerDrawings) then
            PlayerDrawings.Text.Visible = false
            PlayerDrawings.Box.Visible = false
            PlayerDrawings.Tracer.Visible = false
        end
    end);

    if (Player == LocalPlayer) then return; end

    local Text = Drawing.new("Text");
    Text.Color = EspSettings.Color
    Text.OutlineColor = EspSettings.OutlineColor
    Text.Size = EspSettings.Size
    Text.Transparency = EspSettings.Transparency
    Text.Center = true
    Text.Outline = true

    local Tracer = Drawing.new("Line");
    Tracer.Color = EspSettings.Color
    Tracer.From = Vector2new(CurrentCamera.ViewportSize.X / 2, CurrentCamera.ViewportSize.Y);
    Tracer.Thickness = EspSettings.TracerThickness
    Tracer.Transparency = EspSettings.TracerTrancparency

    local Box = Drawing.new("Quad");
    Box.Thickness = EspSettings.Thickness
    Box.Transparency = EspSettings.Transparency
    Box.Filled = false
    Box.Color = EspSettings.Color

    Drawings[Player] = { Text = Text, Tracer = Tracer, Box = Box }
end

for Index, Player in pairs(Players:GetPlayers()) do
    HandlePlayer(Player);
end
Players.PlayerAdded:Connect(function(Player)
    HandlePlayer(Player);
end);

Players.PlayerRemoving:Connect(function(Player)
    Characters[Player] = nil
    local PlayerDrawings = Drawings[Player]
    for Index, Drawing in pairs(PlayerDrawings or {}) do
        Drawing.Visible = false
    end
    Drawings[Player] = nil
end);

local SetProperties = function(Properties)
    for Player, PlayerDrawings in pairs(Drawings) do
        if (type(Player) ~= "number") then
            for Property, Value in pairs(Properties.Tracer or {}) do
                PlayerDrawings.Tracer[Property] = Value
            end
            for Property, Value in pairs(Properties.Text or {}) do
                PlayerDrawings.Text[Property] = Value
            end
            for Property, Value in pairs(Properties.Box or {}) do
                PlayerDrawings.Box[Property] = Value
            end
        end
    end
end

local GetClosestPlayerAndRender = function()
    MouseVector = Vector2new(Mouse.X, Mouse.Y + Inset);
    local Closest = create(4);
    local Vector2Distance = math.huge
    local Vector3DistanceOnScreen = math.huge
    local Vector3Distance = math.huge

    if (AimbotSettings.ShowFov) then
        FOV.Position = MouseVector
        FOV.Visible = true
        Snaplines.Visible = false
    else
        FOV.Visible = false
    end

    local LocalRoot = Characters[LocalPlayer] and FindFirstChild(Characters[LocalPlayer], "HumanoidRootPart");
    for Player, Character in pairs(Characters) do
        if (Player == LocalPlayer) then continue; end
        local PlayerDrawings = Drawings[Player]
        local PlayerRoot = FindFirstChild(Character, "HumanoidRootPart");
        local PlayerTeam = GetTeam(Player);
        if (PlayerRoot) then
            local Redirect = FindFirstChild(Character, AimbotSettings.Aimlock);
            if (not Redirect) then
                PlayerDrawings.Text.Visible = false
                PlayerDrawings.Box.Visible = false
                PlayerDrawings.Tracer.Visible = false
                continue;
            end
            local RedirectPos = Redirect.Position
            local Tuple, Visible = WorldToViewportPoint(CurrentCamera, RedirectPos);
            local CharacterVec2 = Vector2new(Tuple.X, Tuple.Y);
            local Vector2Magnitude = (MouseVector - CharacterVec2).Magnitude
            local Vector3Magnitude = LocalRoot and (RedirectPos - LocalRoot.Position).Magnitude or math.huge
            local InRenderDistance = Vector3Magnitude <= EspSettings.RenderDistance

            -- Check if player is whitelisted
            local IsWhitelisted = Tfind(Settings.Whitelist, Player.Name);
            if (IsWhitelisted) then
                PlayerDrawings.Text.Color = EspSettings.WhitelistColor
                PlayerDrawings.Box.Color = EspSettings.WhitelistColor
                PlayerDrawings.Tracer.Color = EspSettings.WhitelistColor
            else
                PlayerDrawings.Text.Color = EspSettings.Color
                PlayerDrawings.Box.Color = EspSettings.Color
                PlayerDrawings.Tracer.Color = EspSettings.Color
            end

            if (not Tfind(AimbotSettings.BlacklistedTeams, PlayerTeam) and not IsWhitelisted) then
                local InFovRadius = Vector2Magnitude <= FOV.Radius
                if (InFovRadius) then
                    if (Visible and Vector2Magnitude <= Vector2Distance and AimbotSettings.ClosestCursor) then
                        Vector2Distance = Vector2Magnitude
                        Closest = {Character, CharacterVec2, Player, Redirect}
                        if (AimbotSettings.Snaplines and AimbotSettings.ShowFov) then
                            Snaplines.Visible = true
                            Snaplines.From = MouseVector
                            Snaplines.To = CharacterVec2
                        else
                            Snaplines.Visible = false
                        end
                    end

                    if (Visible and Vector3Magnitude <= Vector3DistanceOnScreen and Settings.ClosestPlayer) then
                        Vector3DistanceOnScreen = Vector3Magnitude
                        Closest = {Character, CharacterVec2, Player, Redirect}
                    end
                end
            end

            if (InRenderDistance and Visible and not Tfind(EspSettings.BlacklistedTeams, PlayerTeam)) then
                local CharacterHumanoid = FindFirstChildWhichIsA(Character, "Humanoid") or { Health = 0, MaxHealth = 0 };
                PlayerDrawings.Text.Text = format("%s\n%s%s",
                        EspSettings.NamesEnabled and Player.Name or "",
                        EspSettings.DistanceEnabled and format("[%s]",
                            floor(Vector3Magnitude)
                        ) or "",
                        EspSettings.HealthEnabled and format(" [%s/%s]",
                            floor(CharacterHumanoid.Health),
                            floor(CharacterHumanoid.MaxHealth)
                        )  or ""
                    );

                PlayerDrawings.Text.Position = Vector2new(Tuple.X, Tuple.Y - 40);

                if (EspSettings.TracersEnabled) then
                    PlayerDrawings.Tracer.To = CharacterVec2
                end

                if (EspSettings.BoxEsp) then
                    local Parts = {}
                    for Index, Part in pairs(Character:GetChildren()) do
                        if (IsA(Part, "BasePart")) then
                            local ViewportPos = WorldToViewportPoint(CurrentCamera, Part.Position);
                            Parts[Part] = Vector2new(ViewportPos.X, ViewportPos.Y);
                        end
                    end

                    local Top, Bottom, Left, Right
                    local Distance = math.huge
                    local ClosestPart = nil
                    for i2, Pos in next, Parts do
                        local Mag = (Pos - Vector2new(Tuple.X, 0)).Magnitude;
                        if (Mag <= Distance) then
                            ClosestPart = Pos
                            Distance = Mag
                        end
                    end
                    Top = ClosestPart
                    ClosestPart = nil
                    Distance = math.huge
                    for i2, Pos in next, Parts do
                        local Mag = (Pos - Vector2new(tuple.X, CurrentCamera.ViewportSize.Y)).Magnitude;
                        if (Mag <= Distance) then
                            ClosestPart = Pos
                            Distance = Mag
                        end
                    end
                    Bottom = ClosestPart
                    ClosestPart = nil
                    Distance = math.huge
                    for i2, Pos in next, Parts do
                        local Mag = (Pos - Vector2new(0, Tuple.Y)).Magnitude;
                        if (Mag <= Distance) then
                            ClosestPart = Pos
                            Distance = Mag
                        end
                    end
                    Left = ClosestPart
                    ClosestPart = nil
                    Distance = math.huge
                    for i2, Pos in next, Parts do
                        local Mag = (Pos - Vector2new(CurrentCamera.ViewportSize.X, Tuple.Y)).Magnitude;
                        if (Mag <= Distance) then
                            ClosestPart = Pos
                            Distance = Mag
                        end
                    end
                    Right = ClosestPart
                    ClosestPart = nil
                    Distance = math.huge

                    PlayerDrawings.Box.PointA = Vector2new(Right.X, Top.Y);
                    PlayerDrawings.Box.PointB = Vector2new(Left.X, Top.Y);
                    PlayerDrawings.Box.PointC = Vector2new(Left.X, Bottom.Y);
                    PlayerDrawings.Box.PointD = Vector2new(Right.X, Bottom.Y);
                end

                if (EspSettings.TeamColors and not IsWhitelisted) then
                    local TeamColor;
                    if (PlayerTeam) then
                        local BrickTeamColor = PlayerTeam.TeamColor
                        TeamColor = BrickTeamColor.Color
                    else
                        TeamColor = Color3new(0.639216, 0.635294, 0.647059);
                    end
                    PlayerDrawings.Text.Color = TeamColor
                    PlayerDrawings.Box.Color = TeamColor
                    PlayerDrawings.Tracer.Color = TeamColor
                end

                PlayerDrawings.Text.Visible = true
                PlayerDrawings.Box.Visible = EspSettings.BoxEsp
                PlayerDrawings.Tracer.Visible = EspSettings.TracersEnabled
            else
                PlayerDrawings.Text.Visible = false
                PlayerDrawings.Box.Visible = false
                PlayerDrawings.Tracer.Visible = false
            end
        else
            PlayerDrawings.Text.Visible = false
            PlayerDrawings.Box.Visible = false
            PlayerDrawings.Tracer.Visible = false
        end
    end

    return unpack(Closest);
end

local Locked, SwitchedCamera = false, false
UserInputService.InputBegan:Connect(function(Inp)
    if (AimbotSettings.Enabled and Inp.UserInputType == Enum.UserInputType.MouseButton2) then
        Locked = true
        if (AimbotSettings.FirstPerson and LocalPlayer.CameraMode ~= Enum.CameraMode.LockFirstPerson) then
            LocalPlayer.CameraMode = Enum.CameraMode.LockFirstPerson
            SwitchedCamera = true
        end
    end
end);
UserInputService.InputEnded:Connect(function(Inp)
    if (AimbotSettings.Enabled and Inp.UserInputType == Enum.UserInputType.MouseButton2) then
        Locked = false
        if (SwitchedCamera) then
            LocalPlayer.CameraMode = Enum.CameraMode.Classic
        end
    end
end);

local ClosestCharacter, Vector, Player, Aimlock;
RunService.RenderStepped:Connect(function()
    ClosestCharacter, Vector, Player, Aimlock = GetClosestPlayerAndRender();
    if (Locked and AimbotSettings.Enabled and ClosestCharacter and not Tfind(Settings.Whitelist, Player.Name)) then
        if (AimbotSettings.FirstPerson) then
            if (syn) then
                CurrentCamera.CoordinateFrame = CFramenew(CurrentCamera.CoordinateFrame.p, Aimlock.Position);
            else
                mousemoverel((Vector.X - MouseVector.X) / AimbotSettings.Smoothness, (Vector.Y - MouseVector.Y) / AimbotSettings.Smoothness);
            end
        elseif (AimbotSettings.ThirdPerson) then
            mousemoveabs(Vector.X, Vector.Y);
        end
    end
end);

-- Initialize the UI with the purple theme
local MainUI = UILibrary.new(Color3.fromRGB(67, 7, 241)); -- Hex #4307f1
local Window = MainUI:LoadWindow('<font color="#4307f1">sways</font> method', UDim2.fromOffset(400, 279));
local ESP = Window.NewPage("esp");
local Aimbot = Window.NewPage("aimbot");
local Config = Window.NewPage("config"); -- Added Config tab
local EspSettingsUI = ESP.NewSection("Esp");
local TracerSettingsUI = ESP.NewSection("Tracers");
local SilentAim = Aimbot.NewSection("Silent Aim");
local Aimbot = Aimbot.NewSection("Aimbot");
local ConfigSettingsUI = Config.NewSection("Config"); -- Added Config section

-- Add Whitelist UI
local WhitelistUI = Config.NewSection("Whitelist"); -- Added Whitelist section
WhitelistUI.TextBox("Add Player", function(PlayerName)
    if (PlayerName and not Tfind(Settings.Whitelist, PlayerName)) then
        table.insert(Settings.Whitelist, PlayerName);
    end
end);
WhitelistUI.TextBox("Remove Player", function(PlayerName)
    if (PlayerName and Tfind(Settings.Whitelist, PlayerName)) then
        table.remove(Settings.Whitelist, Tfind(Settings.Whitelist, PlayerName));
    end
end);

-- Add Config UI
ConfigSettingsUI.TextBox("Save Config", function(ConfigName)
    if (ConfigName) then
        Settings.ConfigName = ConfigName;
        SaveConfig(ConfigName);
    end
end);
ConfigSettingsUI.Dropdown("Load Config", ListConfigs(), function(ConfigName)
    if (ConfigName) then
        Settings = GetConfig(ConfigName);
    end
end);
ConfigSettingsUI.Button("Delete Config", function()
    DeleteConfig(Settings.ConfigName);
end);

EspSettingsUI.Toggle("Show Names", EspSettings.NamesEnabled, function(Callback)
    EspSettings.NamesEnabled = Callback
end);
EspSettingsUI.Toggle("Show Health", EspSettings.HealthEnabled, function(Callback)
    EspSettings.HealthEnabled = Callback
end);
EspSettingsUI.Toggle("Show Distance", EspSettings.DistanceEnabled, function(Callback)
    EspSettings.DistanceEnabled = Callback
end);
EspSettingsUI.Toggle("Box Esp", EspSettings.BoxEsp, function(Callback)
    EspSettings.BoxEsp = Callback
    SetProperties({ Box = { Visible = Callback } });
end);
EspSettingsUI.Slider("Render Distance", { Min = 0, Max = 50000, Default = math.clamp(EspSettings.RenderDistance, 0, 50000), Step = 10 }, function(Callback)
    EspSettings.RenderDistance = Callback
end);
EspSettingsUI.Slider("Esp Size", { Min = 0, Max = 30, Default = EspSettings.Size, Step = 1}, function(Callback)
    EspSettings.Size = Callback
    SetProperties({ Text = { Size = Callback } });
end);
EspSettingsUI.ColorPicker("Esp Color", EspSettings.Color, function(Callback)
    EspSettings.TeamColors = false
    EspSettings.Color = Callback
    SetProperties({ Box = { Color = Callback }, Text = { Color = Callback }, Tracer = { Color = Callback } });
end);
EspSettingsUI.Toggle("Team Colors", EspSettings.TeamColors, function(Callback)
    EspSettings.TeamColors = Callback
    if (not Callback) then
        SetProperties({ Tracer = { Color = EspSettings.Color }; Box = { Color = EspSettings.Color }; Text = { Color = EspSettings.Color }  })
    end
end);
EspSettingsUI.Dropdown("Teams", {"Allies", "Enemies", "All"}, function(Callback)
    table.clear(EspSettings.BlacklistedTeams);
    if (Callback == "Enemies") then
        table.insert(EspSettings.BlacklistedTeams, LocalPlayer.Team);
    end
    if (Callback == "Allies") then
        local AllTeams = Teams:GetTeams();
        table.remove(AllTeams, table.find(AllTeams, LocalPlayer.Team));
        EspSettings.BlacklistedTeams = AllTeams
    end
end);
TracerSettingsUI.Toggle("Enable Tracers", EspSettings.TracersEnabled, function(Callback)
    EspSettings.TracersEnabled = Callback
    SetProperties({ Tracer = { Visible = Callback } });
end);
TracerSettingsUI.Dropdown("To", {"Head", "Torso"}, function(Callback)
    AimbotSettings.Aimlock = Callback == "Torso" and "HumanoidRootPart" or Callback
end);
TracerSettingsUI.Dropdown("From", {"Top", "Bottom", "Left", "Right"}, function(Callback)
    local ViewportSize = CurrentCamera.ViewportSize
    local From = Callback == "Top" and Vector2new(ViewportSize.X / 2, ViewportSize.Y - ViewportSize.Y) or Callback == "Bottom" and Vector2new(ViewportSize.X / 2, ViewportSize.Y) or Callback == "Left" and Vector2new(ViewportSize.X - ViewportSize.X, ViewportSize.Y / 2) or Callback == "Right" and Vector2new(ViewportSize.X, ViewportSize.Y / 2);
    EspSettings.TracerFrom = From
    SetProperties({ Tracer = { From = From } });
end);
TracerSettingsUI.Slider("Tracer Transparency", {Min = 0, Max = 1, Default = EspSettings.TracerTrancparency, Step = .1}, function(Callback)
    EspSettings.TracerTrancparency = Callback
    SetProperties({ Tracer = { Transparency = Callback } });
end);
TracerSettingsUI.Slider("Tracer Thickness", {Min = 0, Max = 5, Default = EspSettings.TracerThickness, Step = .1}, function(Callback)
    EspSettings.TracerThickness = Callback
    SetProperties({ Tracer = { Thickness = Callback } });
end);

SilentAim.Toggle("Silent Aim", AimbotSettings.SilentAim, function(Callback)
    AimbotSettings.SilentAim = Callback
end);
SilentAim.Toggle("Wallbang", AimbotSettings.Wallbang, function(Callback)
    AimbotSettings.Wallbang = Callback
end);
SilentAim.Dropdown("Redirect", {"Head", "Torso"}, function(Callback)
    AimbotSettings.SilentAimRedirect = Callback
end);
SilentAim.Slider("Hit Chance", {Min = 0, Max = 100, Default = AimbotSettings.SilentAimHitChance, Step = 1}, function(Callback)
    AimbotSettings.SilentAimHitChance = Callback
end);

SilentAim.Dropdown("Lock Type", {"Closest Cursor"}, function(Callback)
    if (Callback == "Closest Cursor") then
        AimbotSettings.ClosestCharacter = false
        AimbotSettings.ClosestCursor = true
    else
        AimbotSettings.ClosestCharacter = false
        AimbotSettings.ClosestCursor = true
    end
end);

Aimbot.Toggle("Aimbot (M2)", AimbotSettings.Enabled, function(Callback)
    AimbotSettings.Enabled = Callback
    if (not AimbotSettings.FirstPerson and not AimbotSettings.ThirdPerson) then
        AimbotSettings.FirstPerson = true
    end
end);
Aimbot.Slider("Aimbot Smoothness", {Min = 1, Max = 10, Default = AimbotSettings.Smoothness, Step = .5}, function(Callback)
    AimbotSettings.Smoothness = Callback
end);
local sortTeams = function(Callback)
    table.clear(AimbotSettings.BlacklistedTeams);
    if (Callback == "Enemies") then
        table.insert(AimbotSettings.BlacklistedTeams, LocalPlayer.Team);
    end
    if (Callback == "Allies") then
        local AllTeams = Teams:GetTeams();
        table.remove(AllTeams, table.find(AllTeams, LocalPlayer.Team));
        AimbotSettings.BlacklistedTeams = AllTeams
    end
end
Aimbot.Dropdown("Team Target", {"All"}, sortTeams);
sortTeams("Enemies");
Aimbot.Dropdown("Aimlock Type", {"First Person"}, function(callback)
    if (callback == "First Person") then
        AimbotSettings.ThirdPerson = false
        AimbotSettings.FirstPerson = true
    else
        AimbotSettings.ThirdPerson = false
        AimbotSettings.FirstPerson = true
    end
end);

Aimbot.Toggle("Show Fov", AimbotSettings.ShowFov, function(Callback)
    AimbotSettings.ShowFov = Callback
    FOV.Visible = Callback
end);
Aimbot.ColorPicker("Fov Color", AimbotSettings.FovColor, function(Callback)
    AimbotSettings.FovColor = Callback
    FOV.Color = Callback
    Snaplines.Color = Callback
end);
Aimbot.Slider("Fov Size", {Min = 0, Max = 500, Default = AimbotSettings.FovSize, Step = 5}, function(Callback)
    AimbotSettings.FovSize = Callback
    FOV.Radius = Callback
end);
Aimbot.Toggle("Enable Snaplines", AimbotSettings.Snaplines, function(Callback)
    AimbotSettings.Snaplines = Callback
end);
Window.SetPosition(Settings.WindowPosition);

if (gethui) then
    MainUI.UI.Parent = gethui();
else
    local protect_gui = (syn or getgenv()).protect_gui
    if (protect_gui) then
        protect_gui(MainUI.UI);
    end
    MainUI.UI.Parent = game:GetService("CoreGui");
end

while wait(5) do
    Settings.WindowPosition = Window.GetPosition();
    local Encoded = HttpService:JSONEncode(EncodeConfig(Settings));
    writefile("SWAYSMENU.json", Encoded);
end
