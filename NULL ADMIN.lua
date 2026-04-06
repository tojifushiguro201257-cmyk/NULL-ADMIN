-- =====================================================================
-- NULLADMIN 
-- =====================================================================

if getgenv().NullAdminLoaded then return end
getgenv().NullAdminLoaded = true

-- ================= SERVICIOS =================
local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local StarterGui = game:GetService("StarterGui")
local CoreGui = game:GetService("CoreGui")
local TextChatService = game:GetService("TextChatService")
local TeleportService = game:GetService("TeleportService")

local LocalPlayer = Players.LocalPlayer
local Camera = workspace.CurrentCamera

-- ================= CONFIGURACIÓN =================
getgenv().NullAdminConfig = { Prefix = ";", Cooldown = 0 }
local Config = getgenv().NullAdminConfig
local States = { Connections = {}, LoopKills = {}, ESP = {}, Fly = false, AntiVoid = false }

local NullAdmin = { Commands = {}, Aliases = {} }
NullAdmin.Executor = (identifyexecutor and identifyexecutor()) or "Delta"

-- ================= MOTOR DE RESOLUCIÓN =================
function NullAdmin.GetPlayer(str)
    str = string.lower(str or "me")
    if str == "me" then return {LocalPlayer} end
    if str == "all" then return Players:GetPlayers() end
    if str == "others" then
        local t = {}
        for _, p in ipairs(Players:GetPlayers()) do if p ~= LocalPlayer then table.insert(t, p) end end
        return t
    end
    local res = {}
    for _, p in ipairs(Players:GetPlayers()) do
        if p.Name:lower():sub(1, #str) == str or p.DisplayName:lower():sub(1, #str) == str then
            table.insert(res, p)
        end
    end
    return res
end

function NullAdmin.AddCommand(name, aliases, desc, func)
    NullAdmin.Commands[name:lower()] = { Name = name, Aliases = aliases, Description = desc, Execute = func }
    for _, a in ipairs(aliases) do NullAdmin.Aliases[a:lower()] = name:lower() end
end

-- ================= MOTOR FE KILL (FLING) =================
local function FE_Kill(target)
    if not target or target == LocalPlayer or not target.Character then return end
    local char = LocalPlayer.Character
    local tchar = target.Character
    local hrp = char:FindFirstChild("HumanoidRootPart")
    local thrp = tchar:FindFirstChild("HumanoidRootPart")
    
    if hrp and thrp then
        local oldCF = hrp.CFrame
        local bav = Instance.new("BodyAngularVelocity", hrp)
        bav.AngularVelocity = Vector3.new(0, 999999, 0)
        bav.MaxTorque = Vector3.new(0, math.huge, 0)
        bav.P = math.huge

        for i = 1, 15 do
            if not tchar or not thrp then break end
            hrp.CFrame = thrp.CFrame
            RunService.Heartbeat:Wait()
        end
        bav:Destroy()
        hrp.CFrame = oldCF
        hrp.AssemblyLinearVelocity = Vector3.new(0,0,0)
    end
end

-- ================= INTERFAZ INTEGRADA =================
local targetGui = (gethui and gethui()) or CoreGui
local MainGui = Instance.new("ScreenGui", targetGui)
MainGui.Name = "NullAdmin"

local MainFrame = Instance.new("Frame", MainGui)
MainFrame.Size = UDim2.new(0, 350, 0, 40)
MainFrame.Position = UDim2.new(0.5, -175, 0, 60)
MainFrame.BackgroundColor3 = Color3.fromRGB(0, 0, 0)
MainFrame.BorderSizePixel = 0
MainFrame.Active = true
MainFrame.Draggable = true
Instance.new("UIStroke", MainFrame).Color = Color3.new(1, 1, 1)

local Title = Instance.new("TextButton", MainFrame)
Title.Size = UDim2.new(1, 0, 0, 40)
Title.BackgroundTransparency = 1
Title.Text = "NULL ADMIN V2"
Title.TextColor3 = Color3.new(1, 1, 1)
Title.Font = Enum.Font.RobotoMono
Title.TextSize = 15

local Input = Instance.new("TextBox", MainFrame)
Input.Size = UDim2.new(1, -10, 0, 30)
Input.Position = UDim2.new(0, 5, 0, 45)
Input.BackgroundColor3 = Color3.fromRGB(15, 15, 15)
Input.TextColor3 = Color3.new(1, 1, 1)
Input.PlaceholderText = "> Ingrese Comando"
Input.Font = Enum.Font.RobotoMono
Input.TextSize = 14
Input.Visible = false
Instance.new("UIStroke", Input).Color = Color3.new(0.3, 0.3, 0.3)

-- LISTA DE COMANDOS
local CmdList = Instance.new("Frame", MainGui)
CmdList.Size = UDim2.new(0, 300, 0, 380)
CmdList.Position = UDim2.new(0.5, 185, 0, 60)
CmdList.BackgroundColor3 = Color3.fromRGB(0, 0, 0)
CmdList.Visible = false
CmdList.Active = true
CmdList.Draggable = true
Instance.new("UIStroke", CmdList).Color = Color3.new(1, 1, 1)

local ListHeader = Instance.new("TextLabel", CmdList)
ListHeader.Size = UDim2.new(1, -40, 0, 35)
ListHeader.BackgroundTransparency = 1
ListHeader.Text = "  TERMINAL CMDS"
ListHeader.TextColor3 = Color3.new(1, 1, 1)
ListHeader.Font = Enum.Font.RobotoMono
ListHeader.TextSize = 14
ListHeader.TextXAlignment = Enum.TextXAlignment.Left

local CloseBtn = Instance.new("TextButton", CmdList)
CloseBtn.Size = UDim2.new(0, 35, 0, 35)
CloseBtn.Position = UDim2.new(1, -35, 0, 0)
CloseBtn.BackgroundColor3 = Color3.fromRGB(20, 20, 20)
CloseBtn.Text = "X"
CloseBtn.TextColor3 = Color3.new(1, 1, 1)
CloseBtn.Font = Enum.Font.RobotoMono
CloseBtn.TextSize = 18
Instance.new("UIStroke", CloseBtn).Color = Color3.new(1, 1, 1)

local Scroll = Instance.new("ScrollingFrame", CmdList)
Scroll.Size = UDim2.new(1, -10, 1, -45)
Scroll.Position = UDim2.new(0, 5, 0, 40)
Scroll.BackgroundTransparency = 1
Scroll.ScrollBarThickness = 4
Scroll.CanvasSize = UDim2.new(0, 0, 0, 0)
Instance.new("UIListLayout", Scroll).Padding = UDim.new(0, 3)

-- ================= REGISTRO DE COMANDOS =================

NullAdmin.AddCommand("cmds", {"help"}, "Muestra comandos", function()
    if not CmdList.Visible then
        for _, v in ipairs(Scroll:GetChildren()) do if v:IsA("TextLabel") then v:Destroy() end end
        local sorted = {}
        for n in pairs(NullAdmin.Commands) do table.insert(sorted, n) end
        table.sort(sorted)
        for _, name in ipairs(sorted) do
            local l = Instance.new("TextLabel", Scroll)
            l.Size = UDim2.new(1, 0, 0, 22); l.BackgroundTransparency = 1; l.Font = Enum.Font.RobotoMono
            l.Text = " [" .. Config.Prefix .. name .. "] " .. NullAdmin.Commands[name].Description
            l.TextColor3 = Color3.new(1,1,1); l.TextSize = 11; l.TextXAlignment = Enum.TextXAlignment.Left
        end
        Scroll.CanvasSize = UDim2.new(0, 0, 0, #sorted * 25)
    end
    CmdList.Visible = not CmdList.Visible
end)

-- COMANDOS DE MOVIMIENTO / ACCIÓN
NullAdmin.AddCommand("speed", {"ws"}, "Velocidad", function(c, args) pcall(function() c.Character.Humanoid.WalkSpeed = tonumber(args[1]) or 16 end) end)
NullAdmin.AddCommand("jump", {"jp"}, "Salto", function(c, args) pcall(function() c.Character.Humanoid.JumpPower = tonumber(args[1]) or 50; c.Character.Humanoid.UseJumpPower = true end) end)
NullAdmin.AddCommand("hipheight", {"hh"}, "Altura cadera", function(c, args) pcall(function() c.Character.Humanoid.HipHeight = tonumber(args[1]) or 2 end) end)
NullAdmin.AddCommand("kill", {"die"}, "Elimina (Fling)", function(c, args) for _, t in ipairs(NullAdmin.GetPlayer(args[1])) do FE_Kill(t) end end)
NullAdmin.AddCommand("loopkill", {"lk"}, "Loop Kill", function(c, args) local t = NullAdmin.GetPlayer(args[1])[1] if t and t ~= LocalPlayer then States.LoopKills[t.Name] = RunService.Heartbeat:Connect(function() FE_Kill(t) end) end end)
NullAdmin.AddCommand("unloopkill", {"unlk"}, "Para Loopkill", function(c, args) local t = NullAdmin.GetPlayer(args[1])[1] if t and States.LoopKills[t.Name] then States.LoopKills[t.Name]:Disconnect(); States.LoopKills[t.Name] = nil end end)
NullAdmin.AddCommand("bring", {"tp"}, "Traer con Fling", function(c, args) for _, t in ipairs(NullAdmin.GetPlayer(args[1])) do for i=1,8 do FE_Kill(t) end end end)
NullAdmin.AddCommand("god", {"inv"}, "Vida infinita", function(c) if States.Connections["god"] then return end States.Connections["god"] = c.Character.Humanoid.HealthChanged:Connect(function() c.Character.Humanoid.Health = 100 end) end)
NullAdmin.AddCommand("ungod", {}, "Quita Dios", function() if States.Connections["god"] then States.Connections["god"]:Disconnect(); States.Connections["god"] = nil end end)
NullAdmin.AddCommand("noclip", {"nc"}, "Sin paredes", function() if States.Connections["nc"] then return end States.Connections["nc"] = RunService.Stepped:Connect(function() if LocalPlayer.Character then for _, v in pairs(LocalPlayer.Character:GetDescendants()) do if v:IsA("BasePart") then v.CanCollide = false end end end end) end)
NullAdmin.AddCommand("clip", {"unnc"}, "Con paredes", function() if States.Connections["nc"] then States.Connections["nc"]:Disconnect(); States.Connections["nc"] = nil end end)
NullAdmin.AddCommand("esp", {}, "Ver jugadores", function() for _, p in ipairs(Players:GetPlayers()) do if p ~= LocalPlayer and p.Character then local h = p.Character:FindFirstChild("Highlight") or Instance.new("Highlight", p.Character) h.FillColor = Color3.new(1,1,1) end end end)
NullAdmin.AddCommand("unesp", {}, "Quita ESP", function() for _, p in ipairs(Players:GetPlayers()) do if p.Character and p.Character:FindFirstChild("Highlight") then p.Character.Highlight:Destroy() end end end)
NullAdmin.AddCommand("fly", {}, "Volar", function() if States.Fly then return end States.Fly = true local bv = Instance.new("BodyVelocity", LocalPlayer.Character.HumanoidRootPart) bv.Velocity = Vector3.new(0,0,0); bv.MaxForce = Vector3.new(math.huge, math.huge, math.huge) States.Connections["fly"] = RunService.Heartbeat:Connect(function() bv.Velocity = Camera.CFrame.LookVector * 100 end) end)
NullAdmin.AddCommand("unfly", {}, "No volar", function() States.Fly = false if States.Connections["fly"] then States.Connections["fly"]:Disconnect() end if LocalPlayer.Character.HumanoidRootPart:FindFirstChild("BodyVelocity") then LocalPlayer.Character.HumanoidRootPart.BodyVelocity:Destroy() end end)
NullAdmin.AddCommand("goto", {"to"}, "Ir a alguien", function(c, args) local t = NullAdmin.GetPlayer(args[1])[1] if t and t.Character then c.Character.HumanoidRootPart.CFrame = t.Character.HumanoidRootPart.CFrame end end)
NullAdmin.AddCommand("re", {"respawn"}, "Reaparecer", function(c) c:LoadCharacter() end)
NullAdmin.AddCommand("rejoin", {"rj"}, "Reiniciar", function() TeleportService:Teleport(game.PlaceId, LocalPlayer) end)
NullAdmin.AddCommand("sit", {}, "Sentarse", function(c) c.Character.Humanoid.Sit = true end)
NullAdmin.AddCommand("btools", {"bt"}, "F3X local", function() local bp = LocalPlayer:FindFirstChildOfClass("Backpack") if bp then for i = 1, 4 do Instance.new("HopperBin", bp).BinType = i end end end)

-- NUEVO COMANDO: ANTIVOID
NullAdmin.AddCommand("antivoid", {"av"}, "Evita caer al vacio", function()
    if States.AntiVoid then return end
    States.AntiVoid = true
    local lastPos = LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("HumanoidRootPart") and LocalPlayer.Character.HumanoidRootPart.CFrame or CFrame.new(0, 50, 0)
    
    States.Connections["antivoid"] = RunService.Heartbeat:Connect(function()
        if LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("HumanoidRootPart") then
            local hrp = LocalPlayer.Character.HumanoidRootPart
            if hrp.Position.Y > 0 then
                lastPos = hrp.CFrame
            elseif hrp.Position.Y < -50 then -- Punto de retorno
                hrp.Velocity = Vector3.new(0,0,0)
                hrp.CFrame = lastPos + Vector3.new(0, 2, 0)
            end
        end
    end)
    StarterGui:SetCore("SendNotification", {Title = "SISTEMA", Text = "Anti-Void Activado", Duration = 2})
end)

NullAdmin.AddCommand("unantivoid", {"unav"}, "Quita Anti-Void", function()
    States.AntiVoid = false
    if States.Connections["antivoid"] then 
        States.Connections["antivoid"]:Disconnect() 
        States.Connections["antivoid"] = nil 
    end
    StarterGui:SetCore("SendNotification", {Title = "SISTEMA", Text = "Anti-Void Desactivado", Duration = 2})
end)

-- ================= LÓGICA DE INTERFAZ =================

local function Execute(msg)
    if msg:sub(1, #Config.Prefix) ~= Config.Prefix then return end
    local args = msg:sub(#Config.Prefix + 1):split(" ")
    local cmdName = table.remove(args, 1):lower()
    local realName = NullAdmin.Commands[cmdName] and cmdName or NullAdmin.Aliases[cmdName]
    if realName then pcall(function() NullAdmin.Commands[realName].Execute(LocalPlayer, args) end) end
end

Input.FocusLost:Connect(function(enter)
    if enter then Execute(Input.Text); Input.Text = "" end
end)

Title.MouseButton1Click:Connect(function()
    Input.Visible = not Input.Visible
    MainFrame.Size = Input.Visible and UDim2.new(0, 350, 0, 85) or UDim2.new(0, 350, 0, 40)
end)

CloseBtn.MouseButton1Click:Connect(function() CmdList.Visible = false end)

if TextChatService.ChatVersion == Enum.ChatVersion.TextChatService then
    TextChatService.MessageReceived:Connect(function(m) if m.TextSource and m.TextSource.UserId == LocalPlayer.UserId then Execute(m.Text) end end)
else
    LocalPlayer.Chatted:Connect(Execute)
end

StarterGui:SetCore("SendNotification", {Title = "NullAdmin V11", Text = "Anti-Void Añadido", Duration = 3})

