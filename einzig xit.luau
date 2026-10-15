-- einzig xit | v2.3.0 | Discord @zerox_zl
-- Cliente Roblox/Luau; sem bibliotecas ou funções específicas de executor.
-- Física, rede, câmera e toque reais precisam de teste na experiência de destino.
-- O limite configurado é uma solicitação; a medição usa deslocamento observado.
-- Colisões e controladores do jogo podem limitar o voo, especialmente em alta velocidade.
local VERSION = "2.3.0"
local CONFIG = {
    -- Imagens enviadas ao Roblox; mantenha as permissões dos recursos.
    ArtworkAssetId = "", -- Compatibilidade: usado quando HeaderArtworkAssetId está vazio.
    HeaderArtworkAssetId = "107860051763690",
    MonogramAssetId = "89835230707877",
    InstagramLogoAssetId = "",
    DiscordLogoAssetId = "",
    InstagramProfileUrl = "https://www.instagram.com/zerox_zl/",
    DiscordProfileUrl = "https://discord.com/users/1157850896097607761",
    -- Limites finitos: {mínimo, máximo, passo}. Os padrões devem estar nesses intervalos.
    -- O segundo número de flightSpeed é o teto ajustável (padrão 1000; limite lógico 5000).
    MovementLimits = {flightSpeed={25,1000,1}, groundSpeed={8,120,1}},
    FlightSpeedIncrement = 25,
    FlightDynamics = {accelerationTime=0.10,brakingTime=0.06,steeringTime=0.07,maxForce=20000000,
        sampleInterval=0.15,measurementTime=0.25,graceSeconds=0.8,stallSeconds=1.6,
        collisionMargin=0.75},
    RelationshipMode = "teams", -- "teams": equipes nativas; "custom": Adapters.customRelationship.
}
local Theme = {width=800,height=520,header=50,footer=30,sidebar=160,gap=12,padding=16,corner=14}

local LogoMasks = {
    instagram={{5,0,1,1,1},{6,0,1,1,2},{7,0,2,1,3},{9,0,14,1,4},{23,0,2,1,3},{25,0,1,1,2},{26,0,1,1,1},{4,1,1,1,3},{5,1,22,1,4},{27,1,1,1,3},{2,2,1,1,1},{3,2,11,1,4},{14,2,6,1,3},{20,2,9,1,4},{29,2,1,1,1},{2,3,4,1,4},{6,3,1,1,2},{7,3,1,1,1},{24,3,1,1,1},{25,3,1,1,2},{26,3,4,1,4},{1,4,1,1,3},{2,4,2,1,4},{4,4,1,1,3},{5,4,1,1,1},{26,4,1,1,1},{27,4,1,1,3},{28,4,2,1,4},{30,4,1,1,3},{0,5,1,1,1},{1,5,3,1,4},{4,5,1,1,1},{23,5,1,1,1},{24,5,1,1,2},{25,5,1,1,1},{27,5,1,1,1},{28,5,3,1,4},{31,5,1,1,1},{0,6,1,1,2},{1,6,2,3,4},{3,6,1,1,2},{22,6,1,1,1},{23,6,3,3,4},{26,6,1,1,1},{28,6,1,1,2},{29,6,2,3,4},{31,6,1,1,2},{0,7,1,2,3},{3,7,1,1,1},{15,7,2,1,1},{22,7,1,1,2},{26,7,1,1,2},{28,7,1,1,1},{31,7,1,2,3},{12,8,1,1,2},{13,8,1,1,3},{14,8,4,1,4},{18,8,1,1,3},{19,8,1,1,2},{26,8,1,1,1},{0,9,3,14,4},{10,9,1,1,1},{11,9,1,1,3},{12,9,8,1,4},{20,9,1,1,3},{21,9,1,1,1},{24,9,1,1,1},{29,9,3,14,4},{9,10,1,1,1},{10,10,5,1,4},{15,10,2,1,3},{17,10,5,1,4},{22,10,1,1,1},{9,11,1,1,3},{10,11,3,1,4},{13,11,1,1,1},{18,11,1,1,1},{19,11,3,1,4},{22,11,1,1,3},{8,12,1,1,2},{9,12,3,1,4},{20,12,3,1,4},{23,12,1,1,2},{8,13,1,1,3},{9,13,2,1,4},{11,13,1,1,1},{20,13,1,1,1},{21,13,2,1,4},{23,13,1,1,3},{8,14,3,1,4},{21,14,3,1,4},{7,15,1,2,1},{8,15,2,2,4},{10,15,1,2,3},{21,15,1,2,3},{22,15,2,2,4},{24,15,1,2,1},{8,17,3,1,4},{21,17,3,1,4},{8,18,1,1,3},{9,18,2,1,4},{11,18,1,1,1},{20,18,1,1,1},{21,18,2,1,4},{23,18,1,1,3},{8,19,1,1,2},{9,19,3,1,4},{20,19,3,1,4},{23,19,1,1,2},{9,20,1,1,3},{10,20,3,1,4},{13,20,1,1,1},{18,20,1,1,1},{19,20,3,1,4},{22,20,1,1,3},{9,21,1,1,1},{10,21,5,1,4},{15,21,2,1,3},{17,21,5,1,4},{22,21,1,1,1},{10,22,1,1,1},{11,22,1,1,3},{12,22,8,1,4},{20,22,1,1,3},{21,22,1,1,1},{0,23,1,2,3},{1,23,2,3,4},{12,23,1,1,2},{13,23,1,1,3},{14,23,4,1,4},{18,23,1,1,3},{19,23,1,1,2},{29,23,2,3,4},{31,23,1,2,3},{3,24,1,1,1},{15,24,2,1,1},{28,24,1,1,1},{0,25,1,1,2},{3,25,1,1,2},{28,25,1,1,2},{31,25,1,1,2},{0,26,1,1,1},{1,26,3,1,4},{4,26,1,1,1},{27,26,1,1,1},{28,26,3,1,4},{31,26,1,1,1},{1,27,1,1,3},{2,27,2,1,4},{4,27,1,1,3},{5,27,1,1,1},{26,27,1,1,1},{27,27,1,1,3},{28,27,2,1,4},{30,27,1,1,3},{2,28,4,1,4},{6,28,1,1,2},{7,28,1,1,1},{24,28,1,1,1},{25,28,1,1,2},{26,28,4,1,4},{2,29,1,1,1},{3,29,9,1,4},{12,29,8,1,3},{20,29,9,1,4},{29,29,1,1,1},{4,30,1,1,3},{5,30,22,1,4},{27,30,1,1,3},{5,31,1,1,1},{6,31,1,1,2},{7,31,2,1,3},{9,31,14,1,4},{23,31,2,1,3},{25,31,1,1,2},{26,31,1,1,1}},
    discord={{7,4,1,1,1},{8,4,1,1,2},{9,4,1,1,3},{10,4,1,1,4},{11,4,1,1,3},{20,4,1,1,3},{21,4,1,1,4},{22,4,1,1,3},{23,4,1,1,2},{24,4,1,1,1},{5,5,1,1,2},{6,5,1,1,3},{7,5,5,1,4},{12,5,8,1,3},{20,5,5,1,4},{25,5,1,1,3},{26,5,1,1,2},{4,6,1,1,2},{5,6,22,1,4},{27,6,1,1,2},{3,7,1,1,1},{4,7,24,2,4},{28,7,1,1,1},{3,8,1,1,3},{28,8,1,1,3},{2,9,1,1,1},{3,9,26,2,4},{29,9,1,1,1},{2,10,1,1,3},{29,10,1,1,3},{1,11,1,1,1},{2,11,28,3,4},{30,11,1,1,1},{1,12,1,1,2},{30,12,1,1,2},{1,13,1,1,3},{30,13,1,1,3},{0,14,1,1,1},{1,14,8,1,4},{9,14,1,1,1},{11,14,1,1,1},{12,14,1,1,3},{13,14,6,1,4},{19,14,1,1,3},{20,14,1,1,1},{22,14,1,1,1},{23,14,8,1,4},{31,14,1,2,1},{0,15,1,2,2},{1,15,7,2,4},{8,15,1,1,1},{13,15,1,1,3},{14,15,4,4,4},{18,15,1,1,3},{23,15,1,1,1},{24,15,7,2,4},{13,16,1,2,2},{18,16,1,2,2},{31,16,1,1,2},{0,17,1,2,3},{1,17,6,1,4},{7,17,1,1,3},{24,17,1,1,3},{25,17,6,1,4},{31,17,1,2,3},{1,18,7,1,4},{13,18,1,1,3},{18,18,1,1,3},{24,18,7,1,4},{0,19,8,1,4},{8,19,1,1,3},{12,19,1,1,1},{13,19,6,1,4},{19,19,1,1,1},{23,19,1,1,3},{24,19,8,1,4},{0,20,9,1,4},{9,20,1,1,3},{10,20,1,1,2},{11,20,1,1,3},{12,20,8,1,4},{20,20,1,1,3},{21,20,1,1,2},{22,20,1,1,3},{23,20,9,1,4},{0,21,32,2,4},{0,23,7,1,4},{7,23,2,1,3},{9,23,14,1,4},{23,23,2,1,3},{25,23,7,1,4},{0,24,1,1,1},{1,24,6,1,4},{7,24,1,1,3},{8,24,2,1,1},{10,24,1,1,2},{11,24,1,1,3},{12,24,8,1,4},{20,24,1,1,3},{21,24,1,1,2},{22,24,2,1,1},{24,24,1,1,3},{25,24,6,1,4},{31,24,1,1,1},{2,25,1,1,3},{3,25,6,1,4},{9,25,1,1,3},{13,25,2,1,1},{15,25,2,1,2},{17,25,2,1,1},{22,25,1,1,3},{23,25,6,1,4},{29,25,1,1,3},{3,26,1,1,1},{4,26,1,1,3},{5,26,4,1,4},{9,26,1,1,1},{22,26,1,1,1},{23,26,4,1,4},{27,26,1,1,3},{28,26,1,1,1},{5,27,1,1,1},{6,27,1,1,2},{7,27,1,1,4},{8,27,1,1,3},{23,27,1,1,3},{24,27,1,1,4},{25,27,1,1,2},{26,27,1,1,1}},
}

local Players = game:GetService("Players")
local UserInputService = game:GetService("UserInputService")
local RunService = game:GetService("RunService")
local Workspace = game:GetService("Workspace")
local TweenService = game:GetService("TweenService")
local GuiService = game:GetService("GuiService")
local ContentProvider = game:GetService("ContentProvider")
local localPlayer = Players.LocalPlayer
if not localPlayer then
    warn("einzig xit: execute como LocalScript no cliente.")
    return
end
local playerGui = localPlayer:WaitForChild("PlayerGui")
local RUNTIME_NAME = "EinzigXit_Runtime_v2"
local RENDER_NAME = "EinzigXit_Camera_v2"

-- A synchronous shutdown handshake prevents duplicate UI, loops and markers.
for _,runtimeName in ipairs({RUNTIME_NAME,"PainelJogadores_Runtime_v1"}) do
 local previous = playerGui:FindFirstChild(runtimeName)
 if previous then
    local shutdown = previous:FindFirstChild("EncerrarInstancia")
    if shutdown and shutdown:IsA("BindableFunction") and previous:GetAttribute("Inicializado") then
        local succeeded=pcall(function() shutdown:Invoke() end)
        if not succeeded then
            warn("einzig xit: a instância anterior não encerrou corretamente. Reinicie o teste.")
            return
        end
    else
        warn("einzig xit: já existe uma interface sem encerramento disponível. Reinicie o teste.")
        return
    end
    if previous.Parent then previous:Destroy() end
 end
end

local Palette = {
    background = Color3.fromRGB(9, 7, 15),
    card = Color3.fromRGB(25, 18, 38),
    input = Color3.fromRGB(35, 25, 50),
    hover = Color3.fromRGB(55, 32, 81),
    border = Color3.fromRGB(70, 47, 95),
    surfaceTop = Color3.fromRGB(26, 17, 43),
    surfaceBottom = Color3.fromRGB(12, 8, 21),
    cardTop = Color3.fromRGB(34, 23, 50),
    cardBottom = Color3.fromRGB(21, 15, 34),
    track = Color3.fromRGB(62, 45, 80),
    accent = Color3.fromRGB(168, 85, 247),
    primary = Color3.fromRGB(139, 92, 246),
    light = Color3.fromRGB(196, 181, 253),
    text = Color3.fromRGB(245, 241, 255),
    muted = Color3.fromRGB(191, 181, 207),
    green = Color3.fromRGB(90, 224, 146),
    yellow = Color3.fromRGB(255, 201, 86),
    red = Color3.fromRGB(255, 99, 124),
}
local Defaults = {
    enabled = true, mode = "selected", showName = true, showHealth = true,
    showBar = true, showDistance = true, showOutline = true, hideDead = true,
    reduceOverlap = true, color = Palette.accent, textSize = 12,
    transparency = 0, maxDistance = 1500, shortcut = Enum.KeyCode.RightShift,
    interval = 0.1, sort = "name", compact = true, espScale = 100, backgroundOpacity = 28,
    showUsername = false, reduceEffects = false,
    aimEnabled = false, aimPart = "head", aimMode = "always",
    aimKey = Enum.UserInputType.MouseButton2, smoothing = 35, aimDistance = 1500,
    ignoreTeam = true, checkWalls = true, markedOnly = false, retainTarget = true,
    showFov = true, fovRadius = 120, fovColor = Palette.accent, fovThickness = 1,
    fovTransparency = 25,
    espAudience = "all", noRecoil = false,
    flightEnabled = false, flightSpeed = 150, flightMode = "manual",
    speedEnabled = false, groundSpeed = 32,
}
local State = {
    alive = true, records = {}, connections = {}, popupConnections = {},
    controls = {}, pages = {}, tabs = {}, query = "", activeTab = "Início",
    minimized = false, visible = true, dragging = nil, toastUntil = 0,
    markerElapsed = 0, listElapsed = 0, needsUpdate = true, ready = false,
    faults = {}, diagnostics = {}, tweens = {}, tweenGoals = {}, ambient = {}, columns = {},
    focused = true, uiPointers = {}, cameraConnections = {},
    assetWatches = {}, assetLoads = {}, responsive = {}, subtab = "Ajustes", social = {},
    aim = {target=nil, held=false, toggled=false, bound=false, camera=nil,
        elapsed=0, status="Desativado", reason="", touchInput=nil},
    motion = {character=nil,humanoid=nil,root=nil,characterConnections={},humanoidConnections={},
        held={},inputConnections={},leases={},statuses={flight="Desativado",speed="Desativado"},
        flightConnections={},elapsed=0,nativeBlocked=true,flyVisible=false,flyMinimized=false,
        followPaused=false,manualExpanded=false,observedSpeed=nil},
    recoil = {status="Desativado"},
}
local UI, App, Build, Aim, Visual = {}, {}, {}, {}, {}
local Movement, Recoil, Adapters, Ownership = {}, {}, {}, {}
local Settings
local Values={}
for key,value in pairs(Defaults) do Values[key]=value end
local Ranges={textSize={10,18,1},transparency={0,100,1},maxDistance={50,10000,50},
    espScale={75,160,5},backgroundOpacity={0,100,1},smoothing={0,100,1},
    aimDistance={50,10000,50},fovRadius={30,400,5},fovThickness={1,4,1},fovTransparency={0,100,1},
    flightSpeed=CONFIG.MovementLimits.flightSpeed,groundSpeed=CONFIG.MovementLimits.groundSpeed}
local Choices={mode={"selected","all"},sort={"name","distance","health"},interval={0.05,0.1,0.2},
    aimPart={"head","torso","root"},aimMode={"always","hold","toggle"},
    espAudience={"all","enemies"},
    flightMode={"manual","camera"},
    shortcut={Enum.KeyCode.RightShift,Enum.KeyCode.F4,Enum.KeyCode.F6,Enum.KeyCode.F7,Enum.KeyCode.F8,Enum.KeyCode.P,Enum.KeyCode.M},
    aimKey={Enum.UserInputType.MouseButton2,Enum.KeyCode.LeftAlt,Enum.KeyCode.RightAlt,Enum.KeyCode.Q,
        Enum.KeyCode.E,Enum.KeyCode.F,Enum.KeyCode.C,Enum.KeyCode.V}}
local function validSetting(key,value)
    if Defaults[key]==nil then return false end
    if Ranges[key] then
        local r=Ranges[key]
        return type(value)=="number" and value==value and value>=r[1] and value<=r[2]
            and math.abs((value-r[1])/r[3]-math.floor((value-r[1])/r[3]+0.5))<0.00001
    elseif Choices[key] then
        for _,allowed in ipairs(Choices[key]) do if value==allowed then return true end end
        return false
    elseif typeof(Defaults[key])=="Color3" then
        return typeof(value)=="Color3" and value.R==value.R and value.G==value.G and value.B==value.B
            and value.R>=0 and value.R<=1 and value.G>=0 and value.G<=1 and value.B>=0 and value.B<=1
    end
    return type(value)=="boolean"
end
Settings=setmetatable({}, {
    __index=Values,
    __newindex=function(_,key,value)
        -- Somente compatibilidade com preferências antigas; não armazena nem aplica essas chaves.
        if key=="jumpEnabled" or key=="jumpIntensity" then return end
        if not validSetting(key,value) then
            if App.diagnostic then App.diagnostic("config:"..tostring(key),"Valor inválido. A configuração anterior foi mantida.") end
            return
        end
        local feature=({flightEnabled="flight",speedEnabled="speed",noRecoil="recoil"})[key]
        if feature and value then State.faults[feature]=nil State.faults.motion=nil end
        -- Resolve an intervening respawn before accepting deliberate activation.
        if value and feature and feature~="recoil" and State.ready and Movement.refreshCharacter then
            if not App.guard("motion",Movement.refreshCharacter) then return end
        end
        local previousValue=Values[key]
        Values[key]=value
        if key=="flightMode" and previousValue~=value and Movement.clearInputs then
            Movement.clearInputs(false) State.motion.followPaused=false
            if State.motion.flight then State.motion.flight.grace=CONFIG.FlightDynamics.graceSeconds end
            if Aim.release then Aim.release(false) end
        end
        if key=="flightSpeed" and previousValue~=value and State.motion.flight and Movement.applySpeed then
            App.guard("flight",Movement.applySpeed)
        end
        if feature=="recoil" then State.recoil.status=value and "Aguardando arma" or "Desativado"
        elseif feature then State.motion.statuses[feature]=value and "Aguardando ativação" or "Desativado" end
        if key=="enabled" and value then State.faults.esp=nil end
        if key=="aimEnabled" then
            if value then State.faults.aim=nil
            elseif Aim.release then Aim.release(true) end
        end
        if key=="aimKey" or key=="aimMode" or key=="aimPart" then
            if Aim.release then Aim.release(true) end
        end
    end,
})

local function connect(bag, signal, callback, feature)
    local connection
    connection = signal:Connect(function(...)
        if State.alive then
            if App.guard then
                local ok=App.guard(feature or "ui",callback,...)
                if not ok and (not feature or feature=="ui") then connection:Disconnect() end
            else callback(...) end
        end
    end)
    bag[#bag + 1] = connection
    return connection
end
local function disconnect(bag)
    for _, connection in ipairs(bag) do connection:Disconnect() end
    table.clear(bag)
end
local function create(class, properties, parent)
    local instance = Instance.new(class)
    for property, value in pairs(properties or {}) do instance[property] = value end
    instance.Parent = parent
    return instance
end
local function put(instance, property, value)
    if instance[property] ~= value then instance[property] = value end
end
local function round(value) return math.floor(value + 0.5) end
local function finite(value)
    return type(value) == "number" and value == value and math.abs(value) < math.huge
end
local function fold(value)
    local replacements = {
        ["Á"]="a", ["À"]="a", ["Â"]="a", ["Ã"]="a", ["Ä"]="a",
        ["á"]="a", ["à"]="a", ["â"]="a", ["ã"]="a", ["ä"]="a",
        ["É"]="e", ["Ê"]="e", ["é"]="e", ["ê"]="e", ["Í"]="i", ["í"]="i",
        ["Ó"]="o", ["Ô"]="o", ["Õ"]="o", ["ó"]="o", ["ô"]="o", ["õ"]="o",
        ["Ú"]="u", ["Ü"]="u", ["ú"]="u", ["ü"]="u", ["Ç"]="c", ["ç"]="c",
    }
    for from, to in pairs(replacements) do value = string.gsub(value, from, to) end
    return string.lower(value)
end
local function marked(record)
    return Settings.mode == "all" or record.selected
end
local function corner(parent, radius)
    return create("UICorner", {CornerRadius=UDim.new(0, radius or 6)}, parent)
end
local function stroke(parent, color, transparency, thickness)
    return create("UIStroke", {Color=color or Palette.border,
        Transparency=transparency or 0, Thickness=thickness or 1,
        ApplyStrokeMode=Enum.ApplyStrokeMode.Border}, parent)
end
local function padding(parent, amount)
    return create("UIPadding", {PaddingTop=UDim.new(0,amount), PaddingBottom=UDim.new(0,amount),
        PaddingLeft=UDim.new(0,amount), PaddingRight=UDim.new(0,amount)}, parent)
end
local function textLabel(parent, text, size, position, textSize, color)
    return create("TextLabel", {BackgroundTransparency=1, BorderSizePixel=0,
        Size=size or UDim2.new(1,0,0,22), Position=position or UDim2.new(),
        Text=text, TextSize=textSize or 13, TextColor3=color or Palette.text,
        Font=Enum.Font.Gotham, TextXAlignment=Enum.TextXAlignment.Left,
        TextYAlignment=Enum.TextYAlignment.Center, RichText=false, AutoLocalize=false}, parent)
end

UI.screen = create("ScreenGui", {Name=RUNTIME_NAME, ResetOnSpawn=false,
    ZIndexBehavior=Enum.ZIndexBehavior.Sibling, DisplayOrder=50,
    ScreenInsets=Enum.ScreenInsets.CoreUISafeInsets, ClipToDeviceSafeArea=true}, playerGui)
UI.world = create("Folder", {Name="EinzigXit_ContornosLocais"}, Workspace)
UI.shutdown = create("BindableFunction", {Name="EncerrarInstancia"}, UI.screen)

function App.clearMarker(record)
    if record.billboard then record.billboard:Destroy() end
    if record.highlight then record.highlight:Destroy() end
    record.billboard, record.highlight, record.marker = nil, nil, nil
end
function App.stop(fromDestroying)
    if not State.alive then return end
    if Movement.shutdown then pcall(Movement.shutdown) end
    if Recoil.stop then pcall(Recoil.stop) end
    if Aim.release then Aim.release(true) end
    pcall(function() RunService:UnbindFromRenderStep(RENDER_NAME) end)
    State.aim.bound=false
    State.alive = false
    for _,load in pairs(State.assetLoads) do
        load.expired=true
        if load.thread then pcall(task.cancel,load.thread) load.thread=nil end
    end
    table.clear(State.assetLoads)
    if App.endDrag then pcall(App.endDrag) end
    disconnect(State.connections)
    disconnect(State.popupConnections)
    disconnect(State.cameraConnections)
    for _,tween in pairs(State.tweens) do pcall(function() tween:Cancel() end) end
    table.clear(State.tweens) table.clear(State.tweenGoals) table.clear(State.uiPointers)
    for _, record in pairs(State.records) do
        disconnect(record.connections)
        pcall(App.clearMarker,record)
    end
    table.clear(State.records)
    table.clear(State.controls)
    table.clear(State.ambient)
    table.clear(State.assetWatches) table.clear(State.responsive) table.clear(State.social)
    if UI.world then UI.world:Destroy() end
    if UI.fovScreen then UI.fovScreen:Destroy() end
    if not fromDestroying and UI.screen then UI.screen:Destroy() end
end
UI.shutdown.OnInvoke = function() App.stop(false) return true end
UI.screen:SetAttribute("Inicializado", true)
connect(State.connections, UI.screen.Destroying, function() App.stop(true) end)
-- Some client hosts do not expose an owning LocalScript. The runtime GUI still
-- provides the mandatory shutdown handshake and external-destruction cleanup.
if script and typeof(script)=="Instance" then
    connect(State.connections, script.Destroying, function() App.stop(false) end)
end

function App.notice(message)
    if not State.alive or not UI.toast then return end
    UI.toast.Text = "einzig xit · "..message
    UI.toast.Visible = true
    State.toastUntil = os.clock() + 4
end
function App.diagnostic(key,message,detail)
    local now=os.clock()
    if State.diagnostics[key] and now-State.diagnostics[key]<8 then return end
    State.diagnostics[key]=now
    pcall(App.notice,message)
    if detail then
        local line=string.match(tostring(detail),"[^\r\n]+") or "Erro desconhecido"
        warn("einzig xit · "..message.." ["..line:sub(1,130).."]")
    end
end
function App.guard(feature,callback,...)
    if not State.alive or (feature~="ui" and State.faults[feature]) then return false end
    local ok,result=pcall(callback,...)
    if ok then return true,result end
    if feature=="aim" then
        State.faults.aim=true Values.aimEnabled=false
        pcall(Aim.release,true)
        pcall(function() RunService:UnbindFromRenderStep(RENDER_NAME) end)
        State.aim.bound=false
        if UI.fovCircle then UI.fovCircle.Visible=false end
        pcall(Aim.status,"Desativado","Mira pausada por erro. Ative novamente para tentar.")
        App.diagnostic("aim","Mira pausada por erro; câmera liberada. Ative novamente para tentar.",result)
    elseif feature=="esp" then
        State.faults.esp=true Values.enabled=false
        for _,record in pairs(State.records) do pcall(App.clearMarker,record) end
        if UI.footer then UI.footer.Text="ESP pausado por erro" end
        if UI.homeEsp then UI.homeEsp.Text="ESP pausado por erro" end
        App.diagnostic("esp","ESP pausado por erro. Ative novamente para tentar.",result)
    elseif feature=="flight" or feature=="speed" then
        State.faults[feature]=true
        pcall(Movement.stopFeature,feature,"Pausado por erro. Ative novamente.")
        App.diagnostic(feature,"Recurso de movimento pausado por erro; controles liberados.",result)
    elseif feature=="motion" then
        State.faults.motion=true
        pcall(Movement.shutdown)
        for _,name in ipairs({"flight","speed"}) do State.motion.statuses[name]="Pausado por erro. Ative novamente." end
        pcall(Movement.sync)
        App.diagnostic("motion","Movimento pausado por erro; controles liberados.",result)
    elseif feature=="recoil" then
        State.faults.recoil=true Values.noRecoil=false
        pcall(Recoil.stop,"Pausado por erro. Ative novamente.")
        App.diagnostic("recoil","No Recoil pausado por erro.",result)
    elseif feature=="decor" then
        State.faults.decor=true Values.reduceEffects=true
        for _,tween in pairs(State.tweens) do pcall(function() tween:Cancel() end) end
        if Visual.settle then pcall(Visual.settle) end
        App.diagnostic("decor","Efeitos visuais pausados por erro.",result)
    else
        Values.aimEnabled=false
        pcall(Aim.release,true)
        pcall(function() RunService:UnbindFromRenderStep(RENDER_NAME) end)
        State.aim.bound=false
        pcall(App.endDrag)
        App.diagnostic("ui","Ação interrompida por erro. A mira foi desligada; reabra o painel se necessário.",result)
    end
    if UI.fovCircle and not Settings.aimEnabled then UI.fovCircle.Visible=false end
    pcall(App.syncControls)
    return false
end
function App.uiPoint(position)
    local inset=GuiService:GetGuiInset()
    return Vector2.new(position.X-inset.X,position.Y-inset.Y)
end
function App.closePopup()
    disconnect(State.popupConnections)
    if UI.popup then UI.popup:Destroy() UI.popup = nil end
end
function App.hideTooltip()
    if UI.tooltip then UI.tooltip.Visible = false end
end
function App.placeTooltip()
    if not UI.tooltip or not UI.tooltip.Visible then return end
    local point = App.uiPoint(UserInputService:GetMouseLocation()) - UI.area.AbsolutePosition
    local area = UI.area.AbsoluteSize
    UI.tooltip.Position = UDim2.fromOffset(
        math.clamp(point.X + 14, 4, math.max(4, area.X - UI.tooltip.AbsoluteSize.X - 4)),
        math.clamp(point.Y + 18, 4, math.max(4, area.Y - UI.tooltip.AbsoluteSize.Y - 4)))
end
local function tooltip(target, message, bag)
    connect(bag or State.connections, target.MouseEnter, function()
        if State.visible and not State.dragging and not UI.popup and not UI.modal.Visible and not (UI.socialModal and UI.socialModal.Visible) then
            UI.tooltip.Text = type(message)=="function" and message() or message
            UI.tooltip.Visible = true
            App.placeTooltip()
        end
    end)
    connect(bag or State.connections, target.MouseLeave, App.hideTooltip)
end
local function button(parent, text, size, position, callback, bag)
    local object = create("TextButton", {Size=size or UDim2.new(1,0,0,36),
        Position=position or UDim2.new(), BackgroundColor3=Palette.input,
        BorderSizePixel=0, Text=text, TextColor3=Palette.text, Font=Enum.Font.GothamMedium,
        TextSize=14, AutoButtonColor=false, AutoLocalize=false, RichText=false,
        TextTruncate=Enum.TextTruncate.AtEnd}, parent)
    corner(object, 8)
    stroke(object, Palette.border, 0.18)
    local glint=create("Frame",{Name="Realce",Position=UDim2.fromOffset(8,1),
        Size=UDim2.new(1,-16,0,1),BackgroundColor3=Palette.light,BackgroundTransparency=1,
        BorderSizePixel=0,Active=false},object)
    corner(glint,1)
    connect(bag or State.connections,object.MouseEnter,function()
        object:SetAttribute("Sobre",true)
        if Visual.feedback then Visual.feedback(object) end
    end)
    connect(bag or State.connections,object.MouseLeave,function()
        object:SetAttribute("Sobre",false) object:SetAttribute("Pressionado",false)
        if Visual.feedback then Visual.feedback(object) end
    end)
    connect(bag or State.connections,object.InputBegan,function(input)
        if input.UserInputType==Enum.UserInputType.MouseButton1 or input.UserInputType==Enum.UserInputType.Touch then
            object:SetAttribute("Pressionado",true)
            if Visual.feedback then Visual.feedback(object) end
        end
    end)
    connect(bag or State.connections,object.InputEnded,function()
        object:SetAttribute("Pressionado",false)
        if Visual.feedback then Visual.feedback(object) end
    end)
    if callback then connect(bag or State.connections, object.Activated, callback) end
    return object
end
local function textBox(parent, placeholder, size, position)
    local object = create("TextBox", {Size=size, Position=position or UDim2.new(),
        BackgroundColor3=Palette.input, BorderSizePixel=0, Text="",
        PlaceholderText=placeholder, PlaceholderColor3=Palette.muted,
        TextColor3=Palette.text, TextSize=13, Font=Enum.Font.Gotham,
        TextXAlignment=Enum.TextXAlignment.Left, ClearTextOnFocus=false,
        MultiLine=false, RichText=false, AutoLocalize=false}, parent)
    corner(object,7) local edge=stroke(object,Palette.border,0.05) padding(object,8)
    connect(State.connections,object.Focused,function() Visual.tween(edge,{Color=Palette.primary}) end)
    connect(State.connections,object.FocusLost,function() Visual.tween(edge,{Color=Palette.border}) end)
    return object
end
local function vertical(parent, gap)
    return create("UIListLayout", {SortOrder=Enum.SortOrder.LayoutOrder,
        Padding=UDim.new(0,gap or 8)}, parent)
end
local function section(parent, title)
    local card = create("Frame", {Size=UDim2.new(1,-2,0,0), AutomaticSize=Enum.AutomaticSize.Y,
        BackgroundColor3=Palette.card, BorderSizePixel=0}, parent)
    corner(card,10) stroke(card,Palette.border,0.18) padding(card,12) vertical(card,7)
    card.BackgroundColor3=Color3.new(1,1,1)
    create("UIGradient",{Name="FundoDoCartao",Color=ColorSequence.new(Palette.cardTop,Palette.cardBottom),Rotation=82},card)
    local heading=create("Frame",{Name="TituloDaSecao",Size=UDim2.new(1,0,0,24),BackgroundTransparency=1},card)
    local accent=create("Frame",{Position=UDim2.fromOffset(0,6),Size=UDim2.fromOffset(3,12),
        BackgroundColor3=Palette.primary,BorderSizePixel=0},heading) corner(accent,2)
    local label = textLabel(heading,title,UDim2.new(1,-12,1,0),UDim2.fromOffset(12,0),14,Palette.text)
    label.Font = Enum.Font.GothamBold
    label.TextTruncate=Enum.TextTruncate.AtEnd
    return card
end
local function paragraph(parent, text, height)
    local label = textLabel(parent,text,UDim2.new(1,0,0,height or 44),nil,12,Palette.muted)
    label.TextWrapped = true
    return label
end
function App.syncControls()
    for _, refresh in ipairs(State.controls) do refresh() end
end
function App.changed()
    State.needsUpdate = true
    App.syncControls()
    if App.refreshPreview then App.refreshPreview() end
    if State.ready then
        App.guard("motion",Movement.reconcile)
        App.guard("recoil",Recoil.reconcile)
        App.guard("aim",Aim.reconcile)
        App.guard("esp",App.update,true)
        App.guard("decor",Visual.refresh)
    end
end
local function toggle(parent, label, key, isSwitch)
    local row = button(parent,"",UDim2.new(1,0,0,UserInputService.TouchEnabled and 40 or 34),nil,function()
        Settings[key] = not Settings[key]
        App.changed()
    end)
    row.BackgroundColor3 = Palette.input
    local name = textLabel(row,label,UDim2.new(1,-60,1,0),UDim2.fromOffset(8,0),13)
    name.TextTruncate = Enum.TextTruncate.AtEnd
    local box = create("Frame", {AnchorPoint=Vector2.new(1,0.5),
        Position=UDim2.new(1,-9,0.5,0), Size=UDim2.fromOffset(isSwitch and 38 or 20,20),
        BorderSizePixel=0},row)
    corner(box,isSwitch and 10 or 3)
    stroke(box,Palette.light,0.78,1)
    local indicator
    if isSwitch then
        indicator = create("Frame", {Size=UDim2.fromOffset(14,14),BackgroundColor3=Palette.text,
            BorderSizePixel=0},box)
        corner(indicator,7)
    else
        indicator = Build.icon(box,"check",16,UDim2.fromOffset(2,2),Palette.background)
    end
    local function refresh()
        box.BackgroundColor3 = Settings[key] and Palette.accent or Palette.track
        if isSwitch then
            local goal=UDim2.fromOffset(Settings[key] and 21 or 3,3)
            if Visual.tween then Visual.tween(indicator,{Position=goal}) else indicator.Position=goal end
        else
            indicator.Visible = Settings[key]
        end
    end
    State.controls[#State.controls+1]=refresh refresh()
    tooltip(row,label)
    return row
end
function App.dropdown(anchor, options, currentValue, choose)
    App.closePopup() App.hideTooltip()
    if Aim.release then Aim.release(false) end
    local layer = create("Frame", {Size=UDim2.fromScale(1,1),BackgroundTransparency=1,
        ZIndex=80},UI.area)
    UI.popup = layer
    local outside=button(layer,"",UDim2.fromScale(1,1),nil,App.closePopup,State.popupConnections)
    outside.BackgroundTransparency=1
    outside:FindFirstChildOfClass("UIStroke").Enabled=false
    local size = UI.area.AbsoluteSize
    local origin = anchor.AbsolutePosition - UI.area.AbsolutePosition
    local width = math.min(math.max(anchor.AbsoluteSize.X,230),size.X-12)
    local height = math.min(#options*36+8,math.max(50,size.Y-16))
    local x = math.clamp(origin.X,6,math.max(6,size.X-width-6))
    local y = origin.Y + anchor.AbsoluteSize.Y+5
    if y+height>size.Y-6 then y=origin.Y-height-5 end
    y=math.clamp(y,6,math.max(6,size.Y-height-6))
    local menu=create("ScrollingFrame", {Position=UDim2.fromOffset(x,y),Size=UDim2.fromOffset(width,height),
        BackgroundColor3=Palette.background,BorderSizePixel=0,ScrollBarThickness=3,
        ScrollBarImageColor3=Palette.accent,CanvasSize=UDim2.fromOffset(0,#options*36+8),
        ScrollingDirection=Enum.ScrollingDirection.Y,ZIndex=2},layer)
    corner(menu,6) stroke(menu,Palette.accent,0.1)
    for index,option in ipairs(options) do
        local item=button(menu,"",
            UDim2.new(1,-8,0,32),UDim2.fromOffset(4,4+(index-1)*36),function()
                App.closePopup()
                choose(option.value)
            end,State.popupConnections)
        Build.buttonText(item,option.label,27,8,13)
        if option.value==currentValue then Build.icon(item,"check",14,UDim2.fromOffset(7,9),Palette.light) end
        item.BackgroundColor3=option.value==currentValue and Palette.hover or Palette.input
    end
end
local function dropdown(parent,label,key,options)
    local frame=create("Frame",{Size=UDim2.new(1,0,0,56),BackgroundTransparency=1},parent)
    textLabel(frame,label,UDim2.new(1,0,0,18),nil,12,Palette.muted)
    local control
    control=button(frame,"",UDim2.new(1,0,0,34),UDim2.fromOffset(0,21),function()
        App.dropdown(control,options,Settings[key],function(value)
            Settings[key]=value App.changed()
        end)
    end)
    local caption=Build.buttonText(control,"",9,28,13)
    Build.icon(control,"down",12,UDim2.new(1,-18,0.5,-6),Palette.light)
    local function refresh()
        for _,option in ipairs(options) do
            if option.value==Settings[key] then caption.Text=option.label break end
        end
    end
    State.controls[#State.controls+1]=refresh refresh()
    tooltip(control,function() return label..": "..caption.Text end)
    return control
end
local function slider(parent,label,key,minimum,maximum,step,suffix,options)
    options=options or {}
    local increment=options.increment or step
    local valueWidth=options.wide and 68 or 58
    local unitWidth=options.wide and 34 or 27
    local rightWidth=valueWidth+unitWidth+5
    local frame=create("Frame",{Size=UDim2.new(1,0,0,options.wide and 70 or 58),BackgroundTransparency=1},parent)
    local caption=textLabel(frame,label,UDim2.new(1,-rightWidth-6,0,26),nil,options.wide and 12 or 13)
    caption.TextTruncate=options.wide and Enum.TextTruncate.None or Enum.TextTruncate.AtEnd
    caption.TextWrapped=options.wide or false
    tooltip(caption,options.logarithmic and (label..": "..minimum.."–"..maximum.." "..suffix..". Ajuste gradual, com mais precisão nas velocidades menores.") or label)
    local valueBox=textBox(frame,"",UDim2.fromOffset(valueWidth,26),UDim2.new(1,-rightWidth,0,0))
    valueBox.TextXAlignment=Enum.TextXAlignment.Center
    textLabel(frame,suffix or "",UDim2.fromOffset(unitWidth,26),UDim2.new(1,-unitWidth,0,0),11,Palette.muted)
    if options.logarithmic then tooltip(valueBox,"Velocidade solicitada. Digite de "..minimum.." a "..maximum.." un./s; a leitura Medida mostra o deslocamento observado.") end
    local hit=button(frame,"",UDim2.new(1,options.wide and -96 or -64,0,options.wide and 40 or 30),UDim2.fromOffset(options.wide and 48 or 32,28))
    hit.BackgroundTransparency=1
    hit:FindFirstChildOfClass("UIStroke").Enabled=false
    local track=create("Frame",{Size=UDim2.new(1,0,0,6),Position=UDim2.new(0,0,0.5,-3),
        BackgroundColor3=Palette.input,BorderSizePixel=0},hit)
    corner(track,3)
    local fill=create("Frame",{Size=UDim2.fromScale(0,1),BackgroundColor3=Palette.accent,
        BorderSizePixel=0},track) corner(fill,3)
    local thumb=create("Frame",{Size=UDim2.fromOffset(14,14),AnchorPoint=Vector2.new(0.5,0.5),
        BackgroundColor3=Palette.text,BorderSizePixel=0},track) corner(thumb,7)
    local function apply(value)
        if not finite(value) or value<minimum or value>maximum then
            App.diagnostic("number:"..key,"Valor inválido. Use um número entre "..minimum.." e "..maximum..".")
            App.syncControls() return
        end
        Settings[key]=round((value-minimum)/step)*step+minimum
        App.changed()
    end
    local function fromPointer(position)
        if hit.AbsoluteSize.X<=0 then return end
        local ratio=math.clamp((App.uiPoint(position).X-hit.AbsolutePosition.X)/hit.AbsoluteSize.X,0,1)
        apply(options.logarithmic and minimum*(maximum/minimum)^ratio or minimum+(maximum-minimum)*ratio)
    end
    connect(State.connections,hit.InputBegan,function(input)
        if input.UserInputType==Enum.UserInputType.MouseButton1 or input.UserInputType==Enum.UserInputType.Touch then
            App.hideTooltip()
            App.endDrag()
            if Aim.release then Aim.release(false) end
            local scroll=hit:FindFirstAncestorOfClass("ScrollingFrame")
            if scroll then scroll.ScrollingEnabled=false end
            State.dragging={kind="slider",input=input,move=fromPointer,scroll=scroll,key=key}
            App.watchDrag(input)
            if key=="flightSpeed" then Movement.clearInputs(false,false) end
            fromPointer(input.Position)
        end
    end)
    local buttonWidth=options.wide and 40 or 28
    local buttonHeight=options.wide and 40 or 30
    tooltip(button(frame,"−",UDim2.fromOffset(buttonWidth,buttonHeight),UDim2.fromOffset(0,28),function() apply(math.max(minimum,Settings[key]-increment)) end),"Diminuir "..label)
    tooltip(button(frame,"+",UDim2.fromOffset(buttonWidth,buttonHeight),UDim2.new(1,-buttonWidth,0,28),function() apply(math.min(maximum,Settings[key]+increment)) end),"Aumentar "..label)
    connect(State.connections,valueBox.FocusLost,function()
        local value=tonumber((string.gsub(valueBox.Text,",",".")))
        if finite(value) then apply(value) else
            App.notice("Digite um número válido.") App.syncControls()
        end
    end)
    local function refresh()
        local ratio=options.logarithmic and math.log(Settings[key]/minimum)/math.log(maximum/minimum)
            or (Settings[key]-minimum)/(maximum-minimum)
        fill.Size=UDim2.fromScale(ratio,1)
        thumb.Position=UDim2.fromScale(ratio,0.5)
        if not valueBox:IsFocused() then valueBox.Text=tostring(Settings[key]) end
    end
    State.controls[#State.controls+1]=refresh refresh()
    return frame,valueBox,hit
end

function Visual.tween(object,goals,duration)
    if not object.Parent then return end
    local changed=false
    for key,value in pairs(goals) do if object[key]~=value then changed=true break end end
    if not changed then return end
    if State.tweens[object] then State.tweens[object]:Cancel() State.tweens[object]=nil end
    if Settings.reduceEffects or not State.ready or not State.visible or State.minimized then
        for key,value in pairs(goals) do object[key]=value end
        return
    end
    local tween=TweenService:Create(object,TweenInfo.new(duration or 0.14,Enum.EasingStyle.Quad,Enum.EasingDirection.Out),goals)
    State.tweens[object]=tween State.tweenGoals[object]=goals tween:Play()
end
function Visual.feedback(control)
    local pressed=control:GetAttribute("Pressionado")
    local highlighted=pressed or control:GetAttribute("Sobre") or control:GetAttribute("Selecionado")
    local edge=control:FindFirstChildOfClass("UIStroke")
    if edge and edge.Enabled then
        Visual.tween(edge,{Color=pressed and Palette.light or highlighted and Palette.primary or Palette.border,
            Transparency=highlighted and 0.04 or (control:GetAttribute("BordaEmRepouso") or 0.18),
            Thickness=pressed and 1.5 or 1})
    end
    local glint=control:FindFirstChild("Realce")
    if glint then Visual.tween(glint,{BackgroundTransparency=pressed and 0.3 or highlighted and 0.66 or 1}) end
    for _,piece in ipairs(control:GetDescendants()) do
        local base=piece:GetAttribute("CorDoIcone")
        if base then
            local color=highlighted and Palette.text or base
            if piece:IsA("UIStroke") then Visual.tween(piece,{Color=color})
            else Visual.tween(piece,{BackgroundColor3=color}) end
        end
    end
end
function Visual.addAmbient(object,goals,duration,page)
    local base={}
    for key in pairs(goals) do base[key]=object[key] end
    State.ambient[#State.ambient+1]={object=object,goals=goals,base=base,duration=duration,page=page,running=false}
end
function Visual.settle()
    for object,tween in pairs(State.tweens) do
        tween:Cancel()
        if object.Parent then
            for key,value in pairs(State.tweenGoals[object] or {}) do object[key]=value end
        end
    end
    table.clear(State.tweens) table.clear(State.tweenGoals)
    for _,effect in ipairs(State.ambient) do
        effect.running=false
        if effect.object.Parent then
            for key,value in pairs(effect.base) do effect.object[key]=value end
        end
    end
end
function Visual.isVisible(object)
    local node=object
    while node do
        if node:IsA("GuiObject") and not node.Visible then return false end
        node=node.Parent
    end
    return true
end
function Visual.refresh()
    local active=not Settings.reduceEffects and State.visible and not State.minimized
    State.decorActive=active
    if not active then Visual.settle() return end
    for _,effect in ipairs(State.ambient) do
        local object=effect.object
        local run=object.Parent~=nil and (not effect.page or effect.page==State.activeTab) and Visual.isVisible(object)
        if effect.running~=run then
            if State.tweens[object] then State.tweens[object]:Cancel() State.tweens[object]=nil end
            State.tweenGoals[object]=nil effect.running=run
            if object.Parent then
                for key,value in pairs(effect.base) do object[key]=value end
                if run then
                    local tween=TweenService:Create(object,TweenInfo.new(effect.duration,Enum.EasingStyle.Sine,
                        Enum.EasingDirection.InOut,-1,true),effect.goals)
                    State.tweens[object]=tween State.tweenGoals[object]=effect.base tween:Play()
                end
            end
        end
    end
end
function Visual.sweep()
    Visual.checkAssets()
    -- Destroyed dropdowns and departed rows must not survive via tween references.
    for object,tween in pairs(State.tweens) do
        if not object.Parent or tween.PlaybackState==Enum.PlaybackState.Completed then
            tween:Cancel() State.tweens[object]=nil State.tweenGoals[object]=nil
        end
    end
end
function Build.buttonText(control,label,left,right,size)
    control.Text=""
    local caption=textLabel(control,label,UDim2.new(1,-left-right,1,0),UDim2.fromOffset(left,0),size or 13)
    caption.Name="TextoBotao" caption.Font=Enum.Font.GothamMedium caption.TextTruncate=Enum.TextTruncate.AtEnd
    return caption
end
-- Thin-line graphics use supported GUI primitives, never font-symbol icons.
function Build.icon(parent,kind,size,position,color)
    local holder=create("Frame",{Name="Icone_"..kind,Size=UDim2.fromOffset(size,size),
        Position=position or UDim2.new(),BackgroundTransparency=1},parent)
    color=color or Palette.light
    local function line(x1,y1,x2,y2)
        local dx,dy=x2-x1,y2-y1
        return create("Frame",{AnchorPoint=Vector2.new(0.5,0.5),BorderSizePixel=0,
            Position=UDim2.fromScale((x1+x2)/48,(y1+y2)/48),
            Size=UDim2.new(math.sqrt(dx*dx+dy*dy)/24,0,0,1.5),
            Rotation=math.deg(math.atan2(dy,dx)),BackgroundColor3=color},holder)
    end
    local function ring(x,y,w,h,radius)
        local shape=create("Frame",{Position=UDim2.fromScale(x/24,y/24),Size=UDim2.fromScale(w/24,h/24),
            BorderSizePixel=0,BackgroundTransparency=1},holder)
        corner(shape,radius or size) stroke(shape,color,0,1.5) return shape
    end
    if kind=="down" then line(5,8,12,15) line(12,15,19,8)
    elseif kind=="right" then line(8,5,15,12) line(15,12,8,19)
    elseif kind=="check" then line(4,12,10,18) line(10,18,21,5)
    elseif kind=="close" then line(5,5,19,19) line(19,5,5,19)
    elseif kind=="home" then
        line(2,11,12,2) line(12,2,22,11) line(5,9,5,22) line(19,9,19,22)
        line(5,22,19,22) line(10,22,10,14) line(14,22,14,14) line(10,14,14,14)
    elseif kind=="users" then
        ring(5,2,8,8) ring(2,13,14,9,3) ring(15,4,5,5) line(18,13,22,16) line(22,16,22,22)
    elseif kind=="fly" then
        line(2,10,22,2) line(22,2,15,22) line(15,22,10,14) line(10,14,2,10) line(10,14,22,2)
    elseif kind=="camera" then
        ring(2,6,20,15,3) ring(8,10,8,8) line(6,6,8,2) line(8,2,16,2) line(16,2,18,6)
    elseif kind=="aim" or kind=="mark" then
        ring(4,4,16,16) line(12,0,12,7) line(12,17,12,24) line(0,12,7,12) line(17,12,24,12)
        if kind=="mark" then ring(10,10,4,4) end
    elseif kind=="paint" then
        line(8,14,19,2) line(19,2,23,3) line(23,3,11,17) line(8,14,11,17)
        ring(2,16,7,6,3) line(2,21,0,23)
    elseif kind=="settings" then
        line(3,5,21,5) line(3,12,21,12) line(3,19,21,19)
        ring(6,3,4,4) ring(15,10,4,4) ring(8,17,4,4)
    elseif kind=="credits" then
        ring(4,1,16,22,2) line(8,7,16,7) line(8,12,16,12) line(8,17,13,17)
    elseif kind=="link" then ring(2,7,12,8,4) ring(10,9,12,8,4)
    elseif kind=="circle" then ring(3,3,18,18)
    else line(12,2,12,22) line(2,12,22,12) end
    for _,piece in ipairs(holder:GetDescendants()) do
        if piece:IsA("UIStroke") then piece:SetAttribute("CorDoIcone",color)
        elseif piece:IsA("Frame") and piece.BackgroundTransparency~=1 then piece:SetAttribute("CorDoIcone",color) end
    end
    return holder
end

-- Request only configured UI images, once per URI, without blocking the panel.
-- Keeping ImageLabel.Visible true avoids depending on a hidden image rendering
-- before making it visible. The fallback stays underneath until IsLoaded.
function Visual.preloadAssets()
    for _,load in pairs(State.assetLoads) do
        if not load.started then
            load.started=true load.deadline=os.clock()+20
            load.thread=task.defer(function()
                if not State.alive or load.expired then return end
                local ok=pcall(function()
                    ContentProvider:PreloadAsync({load.image},function(_,status)
                        if not State.alive or load.expired then return end
                        if status==Enum.AssetFetchStatus.Success then load.status="success"
                        elseif status==Enum.AssetFetchStatus.TimedOut then load.status="timeout"
                        else load.status="failure" end
                    end)
                end)
                if not State.alive or load.expired then return end
                if not ok then load.status="error"
                elseif not load.status then
                    load.status=load.image.IsLoaded and "success" or "unconfirmed"
                end
                load.finished=true load.thread=nil
            end)
        end
    end
end

function Build.asset(parent,assetKey,size,position,scaleType,fallback)
    local uri=State.assets[assetKey] or ""
    if uri=="" then return nil end
    local image=create("ImageLabel",{Name=assetKey,Image=uri,Size=size,Position=position or UDim2.new(),
        ScaleType=scaleType or Enum.ScaleType.Fit,BackgroundTransparency=1,Visible=true},parent)
    local load=State.assetLoads[uri]
    if not load then
        local names={HeaderArtworkAssetId="Banner",MonogramAssetId="Monograma",
            InstagramLogoAssetId="Logo do Instagram",DiscordLogoAssetId="Logo do Discord"}
        load={image=image,label=names[assetKey] or "Imagem",uri=uri}
        State.assetLoads[uri]=load
    end
    local function loaded()
        if not State.alive or not image.Parent then return end
        if image.IsLoaded then load.anyLoaded=true end
        if fallback and fallback.Parent then fallback.Visible=not image.IsLoaded end
    end
    connect(State.connections,image:GetPropertyChangedSignal("IsLoaded"),loaded)
    State.assetWatches[#State.assetWatches+1]={image=image,load=load}
    loaded()
    if State.ready then Visual.preloadAssets() end
    return image
end

function Visual.checkAssets()
    for _,load in pairs(State.assetLoads) do
        if load.started and not load.finished and os.clock()>=load.deadline then
            load.expired=true load.finished=true load.status="timeout"
            if load.thread then pcall(task.cancel,load.thread) load.thread=nil end
        end
    end
    for i=#State.assetWatches,1,-1 do
        local watch=State.assetWatches[i]
        if not watch.image.Parent or watch.image.IsLoaded then table.remove(State.assetWatches,i)
        elseif watch.load.finished then
            local load=watch.load
            if load.status~="success" and not load.anyLoaded and not load.reported then
                load.reported=true
                local reason=load.status=="timeout" and "carregamento demorou mais que o esperado"
                    or load.status=="error" and "erro ao solicitar a imagem"
                    or load.status=="unconfirmed" and "carregamento não confirmado"
                    or "o Roblox não conseguiu carregar a imagem"
                App.diagnostic("asset:"..load.uri,load.label..": "..reason..". Visual alternativo ativo.",
                    load.label.." | "..load.uri.." | "..reason)
            end
            table.remove(State.assetWatches,i)
        end
    end
end

function Build.emblem(parent,size,position)
    local holder=create("Frame",{Size=UDim2.fromOffset(size,size),Position=position or UDim2.new(),BackgroundTransparency=1},parent)
    local fallback=textLabel(holder,"E",UDim2.fromScale(1,1),nil,size*0.85,Palette.light)
    fallback.Font=Enum.Font.Garamond fallback.TextXAlignment=Enum.TextXAlignment.Center
    Build.asset(holder,"MonogramAssetId",UDim2.fromScale(1,1),nil,Enum.ScaleType.Fit,fallback)
    return holder
end

-- Decorative geometry is created once, uses no external assets and never
-- intercepts input. Ambient motion uses a small number of native tweens.
function Build.seal(parent,size,position,animated)
    local holder=create("Frame",{Name="SeloEinzig",Size=UDim2.fromOffset(size,size),
        Position=position or UDim2.new(),BackgroundTransparency=1,Active=false},parent)
    for i=3,1,-1 do
        local halo=create("Frame",{Position=UDim2.fromOffset(-i*2,-i*2),Size=UDim2.new(1,i*4,1,i*4),
            BackgroundTransparency=1,Active=false},holder)
        corner(halo,size) stroke(halo,Palette.primary,0.9+i*0.02,2)
    end
    local disc=create("Frame",{Size=UDim2.fromScale(1,1),BackgroundColor3=Color3.new(1,1,1),
        BorderSizePixel=0,Active=false},holder)
    corner(disc,size)
    create("UIGradient",{Color=ColorSequence.new(Palette.hover,Palette.surfaceBottom),Rotation=45},disc)
    local rim=stroke(disc,Palette.primary,0.46,1)
    if animated then Visual.addAmbient(rim,{Transparency=0.2},5) end
    local inner=create("Frame",{Position=UDim2.fromOffset(5,5),Size=UDim2.new(1,-10,1,-10),
        BackgroundTransparency=1,Active=false},disc)
    corner(inner,size) stroke(inner,Palette.light,0.84,1)
    Build.emblem(disc,math.floor(size*0.8),UDim2.fromOffset(math.floor(size*0.1),math.floor(size*0.1)))
    for i=0,3 do
        local angle=math.rad(i*90)
        create("Frame",{Name="DetalheDoSelo",AnchorPoint=Vector2.new(0.5,0.5),Size=UDim2.fromOffset(4,4),
            Position=UDim2.fromOffset(size/2+math.cos(angle)*size/2,size/2+math.sin(angle)*size/2),
            Rotation=45,BackgroundColor3=Palette.light,BackgroundTransparency=0.28,BorderSizePixel=0,Active=false},holder)
    end
    return holder
end

function Build.floral(parent)
    local art=create("Frame",{Name="OrnamentoFloral",Size=UDim2.fromOffset(224,168),
        AnchorPoint=Vector2.new(1,1),Position=UDim2.new(1,-6,1,-Theme.footer-7),
        BackgroundTransparency=1,Active=false,ZIndex=0},parent)
    local function line(x1,y1,x2,y2)
        local dx,dy=x2-x1,y2-y1
        create("Frame",{AnchorPoint=Vector2.new(0.5,0.5),Position=UDim2.fromOffset((x1+x2)/2,(y1+y2)/2),
            Size=UDim2.fromOffset(math.sqrt(dx*dx+dy*dy),1),Rotation=math.deg(math.atan2(dy,dx)),
            BackgroundColor3=Palette.light,BackgroundTransparency=0.86,BorderSizePixel=0,Active=false},art)
    end
    local function petal(x,y,w,h,rotation,alpha)
        local shape=create("Frame",{Name="Petala",AnchorPoint=Vector2.new(0.5,0.5),
            Position=UDim2.fromOffset(x,y),Size=UDim2.fromOffset(w,h),Rotation=rotation,
            BackgroundColor3=Palette.light,BackgroundTransparency=alpha,BorderSizePixel=0,Active=false},art)
        corner(shape,math.max(w,h)) return shape
    end
    line(211,157,150,120) line(150,120,117,83) line(117,83,66,47) line(150,120,177,64)
    for _,flower in ipairs({{65,44,1},{118,83,1.25},{178,61,0.7}}) do
        local x,y,s=flower[1],flower[2],flower[3]
        for i=0,4 do
            local a=math.rad(i*72-90)
            local shape=petal(x+math.cos(a)*10*s,y+math.sin(a)*10*s,11*s,19*s,i*72,0.96)
            stroke(shape,Palette.light,0.89,1)
        end
        petal(x,y,3*s,3*s,0,0.52)
    end
    petal(144,100,7,22,-42,0.92) petal(100,81,7,18,58,0.91)
    petal(179,132,8,25,54,0.93) petal(164,98,7,19,-24,0.9)
    for i,point in ipairs({{32,116},{83,135},{204,40},{141,32}}) do
        local x,y=point[1],point[2]
        local shape=petal(x,y,5+i%2,12+i%3,28+i*31,0.88+i*0.015)
        if i<=2 then Visual.addAmbient(shape,{Position=UDim2.fromOffset(x+4,y-5),Rotation=shape.Rotation+10},11+i*2) end
    end
    return art
end

function Build.chrome()
    UI.shadow=create("Frame",{Name="SombraSuave",Size=UDim2.fromScale(1,1),
        BackgroundTransparency=1,Active=false,ZIndex=0},UI.window)
    for i=6,1,-1 do
        local margin=i*3+2
        local layer=create("Frame",{Position=UDim2.fromOffset(-margin,-margin+5),
            Size=UDim2.new(1,margin*2,1,margin*2),BackgroundColor3=Color3.new(0,0,0),
            BackgroundTransparency=0.94,BorderSizePixel=0,Active=false},UI.shadow)
        corner(layer,Theme.corner+margin)
    end
    for i=3,1,-1 do
        local halo=create("Frame",{Position=UDim2.fromOffset(-i*2,-i*2),Size=UDim2.new(1,i*4,1,i*4),
            BackgroundTransparency=1,Active=false},UI.shadow)
        corner(halo,Theme.corner+i*2) stroke(halo,Palette.primary,0.88+i*0.03,2)
    end
    UI.surface=create("Frame",{Name="Superficie",Size=UDim2.fromScale(1,1),BackgroundColor3=Color3.new(1,1,1),
        BorderSizePixel=0,ClipsDescendants=true,Active=false,ZIndex=2},UI.window)
    corner(UI.surface,Theme.corner)
    create("UIGradient",{Name="FundoVioleta",Color=ColorSequence.new(Palette.surfaceTop,Palette.surfaceBottom),Rotation=68},UI.surface)
    local frame=create("Frame",{Name="Moldura",Size=UDim2.fromScale(1,1),BackgroundTransparency=1,Active=false,ZIndex=3},UI.window)
    corner(frame,Theme.corner) stroke(frame,Palette.primary,0.3,1)
    local light=create("Frame",{Position=UDim2.fromOffset(20,1),Size=UDim2.new(1,-40,0,1),
        BackgroundColor3=Palette.light,BackgroundTransparency=0.6,BorderSizePixel=0,Active=false},frame)
    create("UIGradient",{Transparency=NumberSequence.new(0.05,1)},light)
end

function Build.columns(page,minimum)
    local holder=create("Frame",{Size=UDim2.new(1,-2,0,0),AutomaticSize=Enum.AutomaticSize.Y,BackgroundTransparency=1},page)
    local layout=vertical(holder,Theme.gap)
    local left=create("Frame",{Size=UDim2.new(1,0,0,0),AutomaticSize=Enum.AutomaticSize.Y,
        BackgroundTransparency=1,LayoutOrder=1},holder) vertical(left,Theme.gap)
    local right=create("Frame",{Size=UDim2.new(1,0,0,0),AutomaticSize=Enum.AutomaticSize.Y,
        BackgroundTransparency=1,LayoutOrder=2},holder) vertical(right,Theme.gap)
    local group={holder=holder,layout=layout,left=left,right=right,minimum=minimum or 555}
    State.columns[#State.columns+1]=group
    connect(State.connections,holder:GetPropertyChangedSignal("AbsoluteSize"),function() App.reflowColumns(group) end)
    return left,right,holder
end

function App.reflowColumns(group)
    local split=group.holder.AbsoluteSize.X>=group.minimum
    group.layout.FillDirection=split and Enum.FillDirection.Horizontal or Enum.FillDirection.Vertical
    local size=split and UDim2.new(0.5,-Theme.gap/2,0,0) or UDim2.new(1,0,0,0)
    put(group.left,"Size",size) put(group.right,"Size",size)
end

function Build.banner(parent,height,subtitle)
    local banner=create("Frame",{Name="BannerEinzig",Size=UDim2.new(1,-2,0,height),BackgroundColor3=Color3.new(1,1,1),
        BorderSizePixel=0,ClipsDescendants=true},parent)
    corner(banner,11) stroke(banner,Palette.primary,0.57)
    create("UIGradient",{Color=ColorSequence.new(Palette.hover,Palette.surfaceBottom),Rotation=12},banner)
    -- A clean ornament is retained when the separately supplied anime image is not configured.
    local fallback=create("Frame",{Size=UDim2.fromScale(1,1),BackgroundTransparency=1},banner)
    for i=1,9 do
        local leaf=create("Frame",{Size=UDim2.fromOffset(7+i%3,20+i%4*3),Rotation=30+i*21,
            Position=UDim2.fromScale(0.6+(i*0.079)%0.35,(i*0.27)%0.85),
            BackgroundColor3=Palette.light,BackgroundTransparency=0.86,BorderSizePixel=0},fallback)
        corner(leaf,9)
    end
    local note=textLabel(fallback,"Arte opcional",UDim2.fromOffset(94,18),UDim2.new(1,-103,1,-24),11,Palette.muted)
    note.TextXAlignment=Enum.TextXAlignment.Right
    local artwork=Build.asset(banner,"HeaderArtworkAssetId",UDim2.fromScale(1,1),nil,Enum.ScaleType.Crop,fallback)
    if artwork then corner(artwork,11) end
    local shade=create("Frame",{Size=UDim2.fromScale(0.72,1),BackgroundColor3=Palette.background,BorderSizePixel=0},banner)
    corner(shade,11) create("UIGradient",{Transparency=NumberSequence.new(0.04,1)},shade)
    local name=textLabel(banner,"einzig xit",UDim2.new(0.62,-20,0,44),UDim2.fromOffset(18,height/2-34),36)
    name.Font=Enum.Font.Garamond name.TextTruncate=Enum.TextTruncate.AtEnd
    local line=textLabel(banner,subtitle,UDim2.new(0.6,-18,0,26),UDim2.fromOffset(19,height/2+10),12,Palette.light)
    line.TextWrapped=true
    local accent=create("Frame",{Position=UDim2.fromOffset(20,height-14),Size=UDim2.fromOffset(50,1),
        BackgroundColor3=Palette.light,BackgroundTransparency=0.18,BorderSizePixel=0,Active=false},banner)
    local shine=create("UIGradient",{Transparency=NumberSequence.new(0.05,1)},accent)
    Visual.addAmbient(shine,{Offset=Vector2.new(0.6,0)},6,parent.Name)
    return banner
end

function Build.heading(parent,title,subtitle)
    local holder=create("Frame",{Size=UDim2.new(1,-2,0,subtitle and 50 or 34),BackgroundTransparency=1},parent)
    local heading=textLabel(holder,title,UDim2.new(1,0,0,29),nil,22)
    heading.Font=Enum.Font.GothamBold heading.TextTruncate=Enum.TextTruncate.AtEnd
    if subtitle then textLabel(holder,subtitle,UDim2.new(1,0,0,18),UDim2.fromOffset(0,30),12,Palette.muted) end
    return holder
end

function Build.help(parent,message,compact)
    local holder=create("Frame",{Size=UDim2.new(1,0,0,26),BackgroundTransparency=1},parent)
    local description=textLabel(holder,message,UDim2.new(1,-6,0,0),UDim2.fromOffset(3,31),12,Palette.muted)
    description.AutomaticSize=Enum.AutomaticSize.Y description.TextWrapped=true description.Visible=false
    local function reflow()
        put(holder,"Size",UDim2.new(1,0,0,description.Visible and description.AbsoluteSize.Y+35 or 26))
    end
    connect(State.connections,description:GetPropertyChangedSignal("AbsoluteSize"),reflow)
    local control
    control=button(holder,"Como funciona",compact and UDim2.fromOffset(138,26) or UDim2.new(1,0,0,26),nil,function()
        description.Visible=not description.Visible
        control.Text=description.Visible and "Ocultar ajuda" or "Como funciona"
        reflow()
    end)
    control.TextSize=12 control.TextColor3=Palette.light
    if compact then
        local version=textLabel(holder,"Versão "..VERSION,UDim2.fromOffset(84,26),UDim2.new(1,-84,0,0),11,Palette.muted)
        version.TextXAlignment=Enum.TextXAlignment.Right version.Name="VersaoDoPainel"
    end
    tooltip(control,message)
    return control
end

function Build.shortcut(parent,label,kind,callback)
    local control=button(parent,"",UDim2.new(1,0,0,36),nil,callback)
    Build.buttonText(control,label,38,30,14)
    Build.icon(control,kind,19,UDim2.fromOffset(11,8))
    Build.icon(control,"right",12,UDim2.new(1,-22,0.5,-6))
    return control
end

function App.layout()
    if not UI.window then return end
    local area=UI.area.AbsoluteSize
    if area.X<=0 or area.Y<=0 then return end
    local width=math.min(Theme.width,math.max(1,area.X-20))
    local height=State.minimized and Theme.header or math.min(Theme.height,math.max(1,area.Y-20))
    UI.window.Size=UDim2.fromOffset(width,height)
    local x,y=UI.window.Position.X.Offset,UI.window.Position.Y.Offset
    if not State.positioned then x=(area.X-width)/2 y=math.max(10,(area.Y-height)/2) State.positioned=true end
    UI.window.Position=UDim2.fromOffset(math.clamp(x,0,math.max(0,area.X-width)),math.clamp(y,0,math.max(0,area.Y-height)))
    local wide=width>=650
    UI.sidebar.Visible=wide UI.mobileNav.Visible=not wide
    UI.tagline.Visible=width>=590
    local pageTop=wide and 14 or 58
    local pageReserved=pageTop+Theme.footer+14
    UI.pageArea.Position=UDim2.fromOffset(wide and Theme.sidebar+16 or 12,pageTop)
    UI.pageArea.Size=UDim2.new(1,wide and -Theme.sidebar-32 or -24,1,-pageReserved)
    if UI.sidebarBackground then UI.sidebarBackground.Visible=wide end
    if UI.sidebarDivider then UI.sidebarDivider.Visible=wide end
    if UI.floral then UI.floral.Visible=wide end
    for _,column in ipairs(State.columns) do App.reflowColumns(column) end
    for _,reflow in ipairs(State.responsive) do reflow() end
    if UI.list and not State.minimized then
        local pageHeight=height-Theme.header-pageReserved
        local listHeight=math.max(112,pageHeight-125)
        UI.list.Size=UDim2.new(1,-8,0,listHeight)
        State.pages.Jogadores.CanvasSize=UDim2.fromOffset(0,125+listHeight)
    end
    if UI.tooltip then UI.tooltip.Size=UDim2.fromOffset(math.min(330,math.max(120,area.X-12)),80) end
    if UI.socialDialog then UI.socialDialog.Size=UDim2.fromOffset(math.min(460,math.max(120,area.X-24)),math.min(290,math.max(120,area.Y-24))) end
    if App.refreshPreview then App.refreshPreview() end
    App.closePopup()
    if Movement.layoutFly then Movement.layoutFly() end
    if State.ready then App.guard("decor",Visual.refresh) end
end
function App.setVisible(visible)
    State.visible=visible UI.window.Visible=visible UI.launcher.Visible=not visible
    UI.modal.Visible=false
    if App.closeSocial then App.closeSocial() end
    App.endDrag() App.closePopup() App.hideTooltip()
    State.needsUpdate=true
    App.guard("decor",Visual.refresh)
end
function App.selectTab(name)
    if not State.pages[name] then return end
    local changed=State.activeTab~=name
    State.activeTab=name
    for tab,page in pairs(State.pages) do
        local active=tab==name
        page.Visible=active
        if State.tweens[page] then State.tweens[page]:Cancel() State.tweens[page]=nil State.tweenGoals[page]=nil end
        page.Position=UDim2.new()
        State.tabs[tab].BackgroundColor3=active and Palette.hover or Palette.background
        State.tabs[tab]:SetAttribute("Selecionado",active)
        State.tabs[tab].TextColor3=active and Palette.text or Palette.muted
        local caption=State.tabs[tab]:FindFirstChild("TextoBotao")
        if caption then caption.TextColor3=active and Palette.text or Palette.muted end
        local accent=State.tabs[tab]:FindFirstChild("PaginaAtiva")
        if accent then accent.Visible=active end
        Visual.feedback(State.tabs[tab])
    end
    if UI.mobileNav then UI.mobileNav.Text="Página: "..name end
    App.closePopup() App.hideTooltip() State.needsUpdate=true
    if App.refreshPreview then App.refreshPreview() end
    if State.ready then
        App.guard("decor",function()
            Visual.refresh()
            if changed and State.visible and not State.minimized and not Settings.reduceEffects then
                local page=State.pages[name]
                page.Position=UDim2.fromOffset(0,5)
                Visual.tween(page,{Position=UDim2.new()},0.16)
            end
        end)
    end
end
function App.confirmStop()
    App.closePopup() App.hideTooltip() Aim.release(false)
    if Movement.clearInputs then Movement.clearInputs() end
    if App.closeSocial then App.closeSocial() end
    UI.modal.Visible=true
end
function Build.shell()
    UI.area=create("Frame",{Name="AreaSegura",Size=UDim2.fromScale(1,1),BackgroundTransparency=1},UI.screen)
    UI.window=create("Frame",{Name="einzig xit",Size=UDim2.fromOffset(Theme.width,Theme.height),
        BackgroundTransparency=1,BorderSizePixel=0,ClipsDescendants=false,Active=true,ZIndex=2},UI.area)
    Build.chrome()
    local titlebar=create("Frame",{Name="Cabecalho",Position=UDim2.fromOffset(2,2),Size=UDim2.new(1,-4,0,Theme.header-2),
        BackgroundColor3=Color3.new(1,1,1),BorderSizePixel=0},UI.surface)
    corner(titlebar,Theme.corner-2)
    create("UIGradient",{Color=ColorSequence.new(Palette.cardTop,Palette.surfaceBottom),Rotation=12},titlebar)
    create("Frame",{Position=UDim2.new(0,14,1,-1),Size=UDim2.new(1,-28,0,1),BorderSizePixel=0,
        BackgroundColor3=Palette.border},titlebar)
    UI.dragHandle=create("TextButton",{Size=UDim2.new(1,-94,1,0),BackgroundTransparency=1,Text="",
        AutoButtonColor=false,AutoLocalize=false},titlebar)
    Build.emblem(UI.dragHandle,38,UDim2.fromOffset(10,5))
    local title=textLabel(UI.dragHandle,"einzig xit",UDim2.fromOffset(141,36),UDim2.fromOffset(55,6),25)
    title.Font=Enum.Font.Garamond
    UI.tagline=textLabel(UI.dragHandle,"SEU ESTILO. SUA VISÃO.",UDim2.fromOffset(260,24),UDim2.fromOffset(210,12),11,Palette.light)
    UI.minimize=button(titlebar,"−",UDim2.fromOffset(32,32),UDim2.new(1,-82,0,8),function()
        State.minimized=not State.minimized UI.body.Visible=not State.minimized
        UI.minimize.Text=State.minimized and "+" or "−"
        App.hideTooltip() App.layout() App.guard("decor",Visual.refresh)
    end)
    tooltip(UI.minimize,"Minimizar ou restaurar. As configurações são preservadas.")
    local close=button(titlebar,"",UDim2.fromOffset(32,32),UDim2.new(1,-42,0,8),App.confirmStop)
    Build.icon(close,"close",14,UDim2.fromOffset(9,9))
    tooltip(close,"Encerrar o einzig xit, liberar a câmera e remover as marcações.")
    UI.body=create("Frame",{Position=UDim2.fromOffset(0,Theme.header),Size=UDim2.new(1,0,1,-Theme.header),BackgroundTransparency=1},UI.surface)
    UI.floral=Build.floral(UI.body)
    UI.sidebarBackground=create("Frame",{Name="FundoDaNavegacao",Position=UDim2.fromOffset(2,2),
        Size=UDim2.new(0,Theme.sidebar-3,1,-Theme.footer-4),BackgroundColor3=Color3.new(1,1,1),BorderSizePixel=0,Active=false},UI.body)
    corner(UI.sidebarBackground,10)
    create("UIGradient",{Color=ColorSequence.new(Palette.cardBottom,Palette.surfaceBottom),Rotation=90},UI.sidebarBackground)
    UI.sidebar=create("ScrollingFrame",{Size=UDim2.new(0,Theme.sidebar,1,-Theme.footer),BackgroundTransparency=1,
        BorderSizePixel=0,CanvasSize=UDim2.fromOffset(0,434),ScrollBarThickness=2,
        ScrollBarImageColor3=Palette.primary,ScrollingDirection=Enum.ScrollingDirection.Y},UI.body)
    UI.sidebarDivider=create("Frame",{Position=UDim2.fromOffset(Theme.sidebar-1,12),Size=UDim2.new(0,1,1,-Theme.footer-24),
        BorderSizePixel=0,BackgroundColor3=Palette.border,Active=false},UI.body)
    create("UIGradient",{Transparency=NumberSequence.new(0,0.9),Rotation=90},UI.sidebarDivider)
    local names={"Início","Jogadores","ESP","Aimbot","Einzig Fly","Aparência","Configurações","Créditos"}
    local kinds={"home","users","mark","aim","fly","paint","settings","credits"}
    local pages={}
    for index,name in ipairs(names) do
        local nav=button(UI.sidebar,name,UDim2.new(1,-16,0,36),UDim2.fromOffset(8,12+(index-1)*39),function() App.selectTab(name) end)
        Build.buttonText(nav,name,37,4,13)
        nav:SetAttribute("BordaEmRepouso",0.72)
        nav:FindFirstChildOfClass("UIStroke").Transparency=0.72
        Build.icon(nav,kinds[index],19,UDim2.fromOffset(10,9),Palette.muted)
        local accent=create("Frame",{Name="PaginaAtiva",Position=UDim2.fromOffset(0,6),Size=UDim2.fromOffset(3,24),
            BackgroundColor3=Palette.primary,BorderSizePixel=0},nav) corner(accent,2)
        State.tabs[name]=nav pages[#pages+1]={label=name,value=name}
    end
    Build.seal(UI.sidebar,64,UDim2.fromOffset((Theme.sidebar-64)/2,337),true)
    textLabel(UI.sidebar,"SEU ESTILO. SUA VISÃO.",UDim2.new(1,-12,0,18),UDim2.fromOffset(6,410),10,Palette.light).TextXAlignment=Enum.TextXAlignment.Center
    UI.mobileNav=button(UI.body,"Página: Início",UDim2.new(1,-24,0,36),UDim2.fromOffset(12,10),function()
        App.dropdown(UI.mobileNav,pages,State.activeTab,App.selectTab)
    end)
    Build.icon(UI.mobileNav,"down",12,UDim2.new(1,-23,0.5,-6))
    UI.pageArea=create("Frame",{Size=UDim2.new(1,-Theme.sidebar-32,1,-Theme.footer-28),
        Position=UDim2.fromOffset(Theme.sidebar+16,14),BackgroundTransparency=1,ClipsDescendants=true},UI.body)
    for _,name in ipairs(names) do
        local page=create("ScrollingFrame",{Name=name,Size=UDim2.fromScale(1,1),BackgroundTransparency=1,
            BorderSizePixel=0,CanvasSize=UDim2.new(),ScrollBarThickness=3,ScrollBarImageColor3=Palette.primary,
            ScrollingDirection=Enum.ScrollingDirection.Y},UI.pageArea)
        if name~="Jogadores" then
            page.AutomaticCanvasSize=Enum.AutomaticSize.Y
            create("UIPadding",{PaddingLeft=UDim.new(0,1),PaddingRight=UDim.new(0,9),
                PaddingTop=UDim.new(0,2),PaddingBottom=UDim.new(0,8)},page)
            vertical(page,Theme.gap)
        else page.ScrollBarThickness=0 end
        State.pages[name]=page
    end
    local footer=create("Frame",{Name="Rodape",Position=UDim2.new(0,2,1,-Theme.footer),Size=UDim2.new(1,-4,0,Theme.footer-2),
        BackgroundColor3=Color3.new(1,1,1),BorderSizePixel=0},UI.body)
    corner(footer,Theme.corner-2)
    create("UIGradient",{Color=ColorSequence.new(Palette.cardBottom,Palette.surfaceBottom)},footer)
    create("Frame",{Position=UDim2.fromOffset(12,0),Size=UDim2.new(1,-24,0,1),BackgroundColor3=Palette.border,BorderSizePixel=0},footer)
    UI.footer=textLabel(footer,"",UDim2.new(1,-180,1,0),UDim2.fromOffset(12,0),11,Palette.muted)
    UI.footer.TextTruncate=Enum.TextTruncate.AtEnd tooltip(UI.footer,function() return UI.footer.Text end)
    local credit=textLabel(footer,"Discord @zerox_zl",UDim2.fromOffset(150,Theme.footer-2),UDim2.new(1,-162,0,0),11,Palette.light)
    credit.TextXAlignment=Enum.TextXAlignment.Right
    UI.launcher=button(UI.area,"einzig xit",UDim2.fromOffset(128,40),UDim2.new(1,-140,1,-54),function() App.setVisible(true) App.layout() end)
    UI.launcher.Visible=false UI.launcher.ZIndex=5
    UI.touchAim=button(UI.area,"Segurar mira",UDim2.fromOffset(136,40),UDim2.new(0,12,1,-54),function()
        if Settings.aimEnabled and Settings.aimMode=="toggle" then
            State.aim.toggled=not State.aim.toggled
            if not State.aim.toggled then Aim.release(false) end
        end
    end)
    UI.touchAim.Visible=false UI.touchAim.ZIndex=5
    UI.toast=textLabel(UI.area,"",UDim2.new(1,-24,0,54),UDim2.fromOffset(12,6),12)
    UI.toast.BackgroundColor3=Palette.card UI.toast.BackgroundTransparency=0.03 UI.toast.TextWrapped=true
    UI.toast.TextXAlignment=Enum.TextXAlignment.Center UI.toast.ZIndex=115 UI.toast.Visible=false
    corner(UI.toast,8) stroke(UI.toast,Palette.primary,0.2) padding(UI.toast,8)
    UI.tooltip=textLabel(UI.area,"",UDim2.fromOffset(330,80),nil,12)
    UI.tooltip.BackgroundColor3=Palette.card UI.tooltip.BackgroundTransparency=0.02 UI.tooltip.TextWrapped=true
    UI.tooltip.ZIndex=110 UI.tooltip.Visible=false corner(UI.tooltip,7) stroke(UI.tooltip,Palette.primary,0.2) padding(UI.tooltip,9)
    UI.modal=create("Frame",{Size=UDim2.fromScale(1,1),BackgroundColor3=Color3.new(0,0,0),
        BackgroundTransparency=0.25,ZIndex=100,Visible=false,Active=true},UI.area)
    local blocker=button(UI.modal,"",UDim2.fromScale(1,1),nil,function() UI.modal.Visible=false end)
    blocker.BackgroundTransparency=1 blocker:FindFirstChildOfClass("UIStroke").Enabled=false
    blocker:FindFirstChild("Realce").Visible=false
    local dialog=create("Frame",{AnchorPoint=Vector2.new(0.5,0.5),Position=UDim2.fromScale(0.5,0.5),
        Size=UDim2.new(1,-32,0,196),BackgroundColor3=Palette.background,BorderSizePixel=0,ZIndex=2,Active=true},UI.modal)
    create("UISizeConstraint",{MaxSize=Vector2.new(390,196)},dialog) corner(dialog,10) stroke(dialog,Palette.primary,0,1)
    textLabel(dialog,"Encerrar o einzig xit?",UDim2.new(1,-28,0,26),UDim2.fromOffset(14,15),17).Font=Enum.Font.GothamBold
    local description=textLabel(dialog,"O movimento e o No Recoil serão desligados, a câmera será liberada e as marcações serão removidas. Para abrir novamente, execute o script.",
        UDim2.new(1,-28,0,70),UDim2.fromOffset(14,49),13,Palette.muted) description.TextWrapped=true
    button(dialog,"Cancelar",UDim2.new(0.5,-21,0,38),UDim2.new(0,14,1,-53),function() UI.modal.Visible=false end)
    local stop=button(dialog,"Encerrar",UDim2.new(0.5,-21,0,38),UDim2.new(0.5,7,1,-53),function() App.stop(false) end)
    stop.TextColor3=Palette.red stop.BackgroundColor3=Color3.fromRGB(48,19,30)
    -- Camera viewport pixels use DeviceSafeInsets, with no Core UI/top-bar inset.
    UI.fovScreen=create("ScreenGui",{Name="EinzigXit_CampoDeVisao",ResetOnSpawn=false,DisplayOrder=40,
        ZIndexBehavior=Enum.ZIndexBehavior.Sibling},playerGui)
    UI.fovScreen.IgnoreGuiInset=true UI.fovScreen.ScreenInsets=Enum.ScreenInsets.DeviceSafeInsets
    UI.fovCircle=create("Frame",{Name="CampoDeVisao",AnchorPoint=Vector2.new(0.5,0.5),
        BackgroundTransparency=1,BorderSizePixel=0,Size=UDim2.fromOffset(240,240),Visible=false,Active=false},UI.fovScreen)
    create("UICorner",{CornerRadius=UDim.new(1,0)},UI.fovCircle)
    UI.fovStroke=stroke(UI.fovCircle,Settings.fovColor,0.25,1)
    App.selectTab("Início")
end

-- Convert automatic selection to an explicit snapshot before individual edits.
function App.manualSelection()
    if Settings.mode=="all" then
        for _,record in pairs(State.records) do record.selected=true end
        Settings.mode="selected"
        App.notice("Modo alterado para jogadores selecionados.")
    end
end
function App.selectAll(value)
    Settings.mode="selected"
    for _,record in pairs(State.records) do record.selected=value end
    App.changed()
    App.notice(value and "Jogadores atuais marcados. Novas entradas não serão marcadas automaticamente."
        or "Todas as marcações foram removidas.")
end
-- These embedded 32px alpha masks are rasterizations of the bundled Simple Icons
-- SVG assets. They keep the real platform logos available without external asset IDs.
function Build.logo(parent,platform,size,position)
    local holder=create("Frame",{Name="Logo_"..platform,Size=UDim2.fromOffset(size,size),
        Position=position,BackgroundTransparency=1},parent)
    local fallback=create("Frame",{Name="LogoIncorporado",Size=UDim2.fromScale(1,1),BackgroundTransparency=1},holder)
    for _,rect in ipairs(LogoMasks[string.lower(platform)] or {}) do
        create("Frame",{Position=UDim2.fromScale(rect[1]/32,rect[2]/32),Size=UDim2.fromScale(rect[3]/32,rect[4]/32),
            BackgroundColor3=Palette.light,BackgroundTransparency=1-rect[5]/4,BorderSizePixel=0},fallback)
    end
    Build.asset(holder,platform.."LogoAssetId",UDim2.fromScale(1,1),nil,Enum.ScaleType.Fit,fallback)
    return holder
end

function App.closeSocial()
    if UI.socialField and UI.socialField:IsFocused() then UI.socialField:ReleaseFocus() end
    if UI.socialModal then UI.socialModal.Visible=false end
    State.copyFocus=false
end
function App.selectSocialText()
    if not UI.socialModal.Visible then return end
    UI.socialField:CaptureFocus()
    UI.socialField.SelectionStart=1 UI.socialField.CursorPosition=#UI.socialField.Text+1
end
function App.showSocial(platform)
    local data=State.social[platform]
    if not data then return end
    local url=CONFIG[data.urlKey]
    if type(url)~="string" or not string.match(url,data.urlPattern) then
        App.diagnostic("social:"..platform,"Link de perfil inválido. Verifique a configuração.") return
    end
    App.closePopup() App.hideTooltip() Aim.release(true)
    UI.modal.Visible=false UI.socialModal.Visible=true
    UI.socialTitle.Text="Link do "..platform
    UI.socialField.Text=url
    State.copyFocus=true
    -- Native LocalScripts cannot write or confirm the system clipboard. Do not
    -- infer success from Ctrl+C, focus loss or selection. There is consequently
    -- no "Copiado!"/success timer in this environment; use the supported fallback.
    App.notice("Cópia manual: selecione o link e copie.")
end
function Build.socialDialog()
    UI.socialModal=create("Frame",{Name="CopiarPerfil",Size=UDim2.fromScale(1,1),BackgroundColor3=Color3.new(0,0,0),
        BackgroundTransparency=0.2,ZIndex=100,Visible=false,Active=true},UI.area)
    local blocker=button(UI.socialModal,"",UDim2.fromScale(1,1),nil,App.closeSocial)
    blocker.BackgroundTransparency=1 blocker:FindFirstChildOfClass("UIStroke").Enabled=false
    blocker:FindFirstChild("Realce").Visible=false
    UI.socialDialog=create("Frame",{Size=UDim2.fromOffset(460,290),AnchorPoint=Vector2.new(0.5,0.5),
        Position=UDim2.fromScale(0.5,0.5),BackgroundColor3=Palette.background,BorderSizePixel=0,ZIndex=2,Active=true},UI.socialModal)
    corner(UI.socialDialog,12) stroke(UI.socialDialog,Palette.primary,0)
    local content=create("ScrollingFrame",{Position=UDim2.fromOffset(14,14),Size=UDim2.new(1,-28,1,-28),
        BackgroundTransparency=1,BorderSizePixel=0,AutomaticCanvasSize=Enum.AutomaticSize.Y,CanvasSize=UDim2.new(),
        ScrollingDirection=Enum.ScrollingDirection.Y,ScrollBarThickness=3,ScrollBarImageColor3=Palette.primary},UI.socialDialog)
    vertical(content,10)
    UI.socialTitle=textLabel(content,"Link do perfil",UDim2.new(1,-6,0,26),nil,19)
    UI.socialTitle.Font=Enum.Font.GothamBold
    local instructions=paragraph(content,"Selecione o link completo e pressione Ctrl+C (ou Command+C no Mac). No celular, use o menu de seleção para copiar.",62)
    instructions.TextSize=12
    UI.socialField=textBox(content,"",UDim2.new(1,-7,0,52))
    UI.socialField.Name="LinkCompletoDoPerfil" UI.socialField.TextEditable=false
    UI.socialField.TextSize=12
    tooltip(UI.socialField,"O link completo está neste campo. Selecionar o texto não confirma uma cópia.")
    local actions=create("Frame",{Size=UDim2.new(1,-7,0,36),BackgroundTransparency=1},content)
    button(actions,"Selecionar link",UDim2.new(0.62,-5,1,0),nil,App.selectSocialText)
    button(actions,"Fechar",UDim2.new(0.38,-5,1,0),UDim2.new(0.62,5,0,0),App.closeSocial)
    paragraph(content,"A cópia automática não está disponível neste ambiente.",36).TextSize=11
end
function Build.socialButton(parent,platform,urlKey,urlPattern)
    local control=button(parent,"",UDim2.new(1,0,0,64),nil,function() App.showSocial(platform) end)
    control.Name="Perfil_"..platform
    local badge=create("Frame",{Name="FundoDoLogo",Size=UDim2.fromOffset(38,38),Position=UDim2.fromOffset(12,13),
        BackgroundColor3=Palette.hover,BackgroundTransparency=0.32,BorderSizePixel=0,Active=false},control)
    corner(badge,10) stroke(badge,Palette.primary,0.68)
    Build.logo(control,platform,26,UDim2.fromOffset(18,19))
    local label=textLabel(control,platform,UDim2.new(1,-97,0,22),UDim2.fromOffset(62,10),14)
    label.Font=Enum.Font.GothamMedium
    label.TextTruncate=Enum.TextTruncate.AtEnd
    local handle=textLabel(control,"@zerox_zl",UDim2.new(1,-97,0,18),UDim2.fromOffset(62,34),12,Palette.muted)
    handle.TextTruncate=Enum.TextTruncate.AtEnd
    Build.icon(control,"link",17,UDim2.new(1,-30,0.5,-8))
    tooltip(control,"Copiar link do "..platform)
    State.social[platform]={button=control,label=label,urlKey=urlKey,urlPattern=urlPattern}
    return control
end

function Build.players()
    local page=State.pages.Jogadores
    local heading=Build.heading(page,"Jogadores")
    heading.Size=UDim2.new(1,-8,0,32)
    UI.count=textLabel(heading,"",UDim2.new(1,-147,1,0),UDim2.fromOffset(147,0),12,Palette.muted)
    UI.count.TextXAlignment=Enum.TextXAlignment.Right UI.count.TextTruncate=Enum.TextTruncate.AtEnd
    tooltip(UI.count,function() return UI.count.Text end)
    UI.search=textBox(page,"Buscar jogador...",UDim2.new(1,-152,0,36),UDim2.fromOffset(0,40))
    tooltip(UI.search,"Busque pelo nome de exibição ou pelo nome de usuário.")
    connect(State.connections,UI.search:GetPropertyChangedSignal("Text"),function()
        State.query=fold(UI.search.Text) State.needsUpdate=true
        if State.ready then App.guard("esp",App.update,true) end
    end)
    local sortOptions={{label="Nome",value="name"},{label="Distância",value="distance"},{label="Vida",value="health"}}
    UI.sort=button(page,"Nome",UDim2.fromOffset(136,36),UDim2.new(1,-144,0,40),function()
        App.dropdown(UI.sort,sortOptions,Settings.sort,function(value) Settings.sort=value App.changed() end)
    end)
    UI.sortLabel=Build.buttonText(UI.sort,"Nome",9,28,13)
    Build.icon(UI.sort,"down",12,UDim2.new(1,-20,0.5,-6))
    tooltip(UI.sort,"Ordenar por nome, distância crescente ou vida atual crescente. Valores indisponíveis ficam no final.")
    State.controls[#State.controls+1]=function()
        for _,option in ipairs(sortOptions) do if option.value==Settings.sort then UI.sortLabel.Text=option.label end end
    end
    button(page,"Marcar todos",UDim2.new(0.5,-8,0,34),UDim2.fromOffset(0,84),function() App.selectAll(true) end)
    button(page,"Desmarcar todos",UDim2.new(0.5,-8,0,34),UDim2.new(0.5,0,0,84),function() App.selectAll(false) end)
    UI.list=create("ScrollingFrame",{Position=UDim2.fromOffset(0,125),Size=UDim2.new(1,-8,1,-125),
        BackgroundTransparency=1,BorderSizePixel=0,CanvasSize=UDim2.new(),AutomaticCanvasSize=Enum.AutomaticSize.Y,
        ScrollBarThickness=3,ScrollBarImageColor3=Palette.accent,ScrollingDirection=Enum.ScrollingDirection.Y},page)
    create("UIPadding",{PaddingLeft=UDim.new(0,1),PaddingRight=UDim.new(0,7),PaddingBottom=UDim.new(0,3),PaddingTop=UDim.new(0,1)},UI.list)
    vertical(UI.list,8)
    UI.empty=textLabel(UI.list,"Nenhum outro jogador nesta partida.",UDim2.new(1,0,0,80),nil,13,Palette.muted)
    UI.empty.TextWrapped=true UI.empty.TextXAlignment=Enum.TextXAlignment.Center
end

local function colorControl(parent,label,key)
    local colors={{"Violeta","#A855F7"},{"Roxo","#7C3AED"},{"Lilás","#D8B4FE"},{"Rosa","#FF7AB8"},
        {"Azul","#669DFF"},{"Ciano","#63E1EC"},{"Verde","#5AE092"},{"Branco","#FFFFFF"}}
    textLabel(parent,label,UDim2.new(1,0,0,20),nil,13)
    local swatches=create("Frame",{Size=UDim2.new(1,0,0,28),BackgroundTransparency=1},parent)
    local edges={}
    for index,preset in ipairs(colors) do
        local swatch=button(swatches,"",UDim2.fromOffset(22,22),UDim2.fromOffset((index-1)*27,3),function()
            Settings[key]=Color3.fromHex(preset[2]) App.changed()
        end)
        swatch.BackgroundColor3=Color3.fromHex(preset[2])
        local selected=create("Frame",{Size=UDim2.new(1,6,1,6),Position=UDim2.fromOffset(-3,-3),
            BackgroundTransparency=1,BorderSizePixel=0},swatch)
        corner(selected,8) edges[index]=stroke(selected,Palette.text,1,2)
        tooltip(swatch,preset[1].." · "..preset[2])
    end
    local function reflow()
        local count=math.max(1,math.floor((swatches.AbsoluteSize.X+5)/27))
        for i,child in ipairs(swatches:GetChildren()) do
            if child:IsA("TextButton") then
                local index=child:GetAttribute("CorIndice")
                if index then child.Position=UDim2.fromOffset(((index-1)%count)*27,math.floor((index-1)/count)*28+3) end
            end
        end
        swatches.Size=UDim2.new(1,0,0,math.ceil(#colors/count)*28)
    end
    local n=0 for _,child in ipairs(swatches:GetChildren()) do if child:IsA("TextButton") then n=n+1 child:SetAttribute("CorIndice",n) end end
    State.responsive[#State.responsive+1]=reflow
    connect(State.connections,swatches:GetPropertyChangedSignal("AbsoluteSize"),reflow)
    local row=create("Frame",{Size=UDim2.new(1,0,0,34),BackgroundTransparency=1},parent)
    local caption=textLabel(row,"Cor hexadecimal",UDim2.new(1,-108,1,0),nil,12,Palette.muted)
    caption.TextTruncate=Enum.TextTruncate.AtEnd tooltip(caption,"Cor hexadecimal")
    local hex=textBox(row,"#A855F7",UDim2.fromOffset(100,32),UDim2.new(1,-100,0,1)) hex.Name=key.."_hex"
    connect(State.connections,hex.FocusLost,function()
        local clean=string.gsub(string.gsub(hex.Text,"%s",""),"^#","")
        if #clean==6 and string.match(clean,"^%x+$") then Settings[key]=Color3.fromHex(clean) App.changed()
        else App.diagnostic("hex:"..key,"Use uma cor no formato #RRGGBB.") App.syncControls() end
    end)
    State.controls[#State.controls+1]=function()
        local value="#"..Settings[key]:ToHex():upper()
        for i,edge in ipairs(edges) do edge.Transparency=value==colors[i][2] and 0 or 1 end
        if not hex:IsFocused() then hex.Text=value end
    end
end

function App.selectAimTab(name)
    if not UI.aimSections[name] then return end
    State.subtab=name
    for key,page in pairs(UI.aimSections) do
        page.Visible=key==name
        UI.aimTabs[key].BackgroundColor3=key==name and Palette.hover or Palette.input
    end
    App.closePopup() App.hideTooltip()
end

function Build.preview(parent)
    local card=section(parent,"Prévia das marcações")
    UI.previewCaption=paragraph(card,"Exemplo ilustrativo · 156 × 41 px",24)
    UI.previewCaption.TextSize=11
    UI.previewStage=create("Frame",{Name="PreviaIlustrativa",Size=UDim2.new(1,0,0,190),BackgroundColor3=Color3.new(1,1,1),
        BorderSizePixel=0,ClipsDescendants=true},card) corner(UI.previewStage,7) stroke(UI.previewStage,Palette.border,0.1)
    create("UIGradient",{Color=ColorSequence.new(Palette.background,Palette.hover),Rotation=90},UI.previewStage)
    local avatar=create("Frame",{Name="PersonagemDeExemplo",Size=UDim2.fromOffset(90,112),
        AnchorPoint=Vector2.new(0.5,0),Position=UDim2.new(0.5,0,0,61),BackgroundTransparency=1},UI.previewStage)
    UI.previewAvatar=avatar UI.previewEdges={}
    local parts={{29,0,32,28},{24,32,42,42},{6,32,14,42},{70,32,14,42},{24,78,19,32},{47,78,19,32}}
    for i,p in ipairs(parts) do
        local part=create("Frame",{Position=UDim2.fromOffset(p[1],p[2]),Size=UDim2.fromOffset(p[3],p[4]),
            BackgroundColor3=i==1 and Color3.fromRGB(132,114,154) or Color3.fromRGB(31,20,46),BorderSizePixel=0},avatar)
        corner(part,i==1 and 8 or 3)
        UI.previewEdges[#UI.previewEdges+1]=stroke(part,Settings.color,0,1)
    end
    UI.previewCanvas=create("Frame",{Name="RotuloDemonstrativo",Size=UDim2.fromOffset(156,41),AnchorPoint=Vector2.new(0.5,1),
        Position=UDim2.new(0.5,0,0,53),BackgroundTransparency=1},UI.previewStage)
    UI.previewScale=create("UIScale",{Scale=1},UI.previewCanvas)
    UI.previewMarker=App.createMarkerVisual(UI.previewCanvas)
    UI.previewEmpty=textLabel(UI.previewStage,"Nenhuma informação selecionada",UDim2.new(1,-16,0,30),UDim2.fromOffset(8,12),11,Palette.muted)
    UI.previewEmpty.TextWrapped=true UI.previewEmpty.TextXAlignment=Enum.TextXAlignment.Center
    connect(State.connections,UI.previewStage:GetPropertyChangedSignal("AbsoluteSize"),function() App.refreshPreview() end)
    Build.help(card,"Dados fictícios para visualizar suas preferências. A prévia se ajusta ao espaço disponível e não altera o tamanho real dos rótulos no jogo.")
end

function App.refreshPreview()
    if not UI.previewMarker then return end
    local sample={health=100,maxHealth=100,ratio=1,distance=139}
    local geometry=App.paintMarkerVisual(UI.previewMarker,sample,"JogadorExemplo","usuario_exemplo")
    local fit=math.min(1,math.max(0.2,(UI.previewStage.AbsoluteSize.X-20)/geometry.width))
    local avatarY=math.max(61,math.ceil(geometry.height*fit)+20)
    put(UI.previewCanvas,"Size",UDim2.fromOffset(geometry.width,geometry.height))
    put(UI.previewCanvas,"Position",UDim2.new(0.5,0,0,avatarY-8))
    put(UI.previewScale,"Scale",fit)
    put(UI.previewCanvas,"Visible",geometry.hasContent)
    put(UI.previewEmpty,"Visible",not geometry.hasContent)
    put(UI.previewAvatar,"Position",UDim2.new(0.5,0,0,avatarY))
    put(UI.previewStage,"Size",UDim2.new(1,0,0,math.max(190,avatarY+124)))
    put(UI.previewCaption,"Text","Exemplo ilustrativo · "..geometry.width.." × "..geometry.height.." px"..(fit<1 and " · ajustado" or ""))
    for _,edge in ipairs(UI.previewEdges) do
        put(edge,"Enabled",Settings.showOutline) put(edge,"Color",Settings.color) put(edge,"Transparency",Settings.transparency/100)
    end
end

function Build.settings()
    local home=State.pages["Início"]
    local homeHeading=Build.heading(home,"Visão geral")
    local stateChip=textLabel(homeHeading,"Sessão ativa",UDim2.fromOffset(113,25),UDim2.new(1,-115,0,1),11,Palette.light)
    stateChip.TextXAlignment=Enum.TextXAlignment.Center stateChip.BackgroundColor3=Palette.card
    corner(stateChip,12) stroke(stateChip,Palette.border,0)
    Build.banner(home,120,"SEU ESTILO. SUA VISÃO.")
    local hl,hr=Build.columns(home)
    local esp=section(hl,"Visão dos jogadores")
    UI.homeEsp=paragraph(esp,"Nenhum jogador marcado.",20)
    toggle(esp,"Ativar marcações","enabled",true)
    Build.shortcut(esp,"Ver jogadores","users",function() App.selectTab("Jogadores") end)
    local aim=section(hr,"Aimbot")
    UI.homeAim=paragraph(aim,"Desativado",20) UI.homeAim.TextTruncate=Enum.TextTruncate.AtEnd
    toggle(aim,"Ativar mira automática","aimEnabled",true)
    Build.shortcut(aim,"Ajustar Aimbot","aim",function() App.selectTab("Aimbot") end)
    local ql,qr=Build.columns(home,430)
    Build.shortcut(ql,"Aparência","paint",function() App.selectTab("Aparência") end)
    Build.shortcut(qr,"Créditos","credits",function() App.selectTab("Créditos") end)

    Build.heading(State.pages["ESP"],"ESP","Informações úteis, sem ocupar a tela.")
    local ml,mr=Build.columns(State.pages["ESP"])
    local general=section(ml,"Controle do ESP")
    toggle(general,"Ativar marcações","enabled",true)
    dropdown(general,"Quem marcar","mode",{{label="Jogadores selecionados",value="selected"},{label="Todos automaticamente",value="all"}})
    dropdown(general,"Quem destacar","espAudience",{{label="Todos",value="all"},{label="Apenas inimigos",value="enemies"}})
    UI.espRelationshipStatus=paragraph(general,"Todos os jogadores são elegíveis.",36)
    UI.espRelationshipStatus.TextWrapped=true
    Build.help(general,"O filtro usa equipes do jogo. Neutros participam do modo livre. Uma relação indisponível é ocultada no modo Apenas inimigos. O filtro do Aimbot é independente.")
    Build.help(general,"O modo automático inclui novas entradas. Uma ação individual preserva os jogadores atuais e volta à seleção manual.")
    local visibility=section(ml,"Visibilidade")
    toggle(visibility,"Ocultar jogadores eliminados","hideDead",true)
    toggle(visibility,"Reduzir sobreposição","reduceOverlap",true)
    slider(visibility,"Distância máxima","maxDistance",50,10000,50,"un.")
    Build.help(visibility,"Rótulos próximos têm prioridade. Os contornos permanecem. A distância usa unidades nativas do jogo.")
    local content=section(mr,"Informações exibidas")
    toggle(content,"Mostrar nome","showName",true)
    toggle(content,"Mostrar usuário","showUsername",true)
    toggle(content,"Mostrar vida","showHealth",true)
    toggle(content,"Mostrar barra de vida","showBar",true)
    toggle(content,"Mostrar distância","showDistance",true)
    toggle(content,"Mostrar contorno","showOutline",true)
    Build.help(content,"O usuário fica oculto nos rótulos por padrão. A identificação completa continua na lista de jogadores.")

    local aimPage=State.pages["Aimbot"]
    local aimHeading=Build.heading(aimPage,"Aimbot") aimHeading.Size=UDim2.new(1,-2,0,54)
    UI.aimStatus=textLabel(aimHeading,"Desativado",UDim2.new(1,0,0,20),UDim2.fromOffset(0,32),12,Palette.light)
    UI.aimStatus.TextTruncate=Enum.TextTruncate.AtEnd
    UI.aimReason=textLabel(aimHeading,"",UDim2.new(),nil,1) UI.aimReason.Visible=false
    tooltip(UI.aimStatus,function() return State.aim.status..(State.aim.reason~="" and "\n"..State.aim.reason or "") end)
    UI.aimTabs={} UI.aimSections={}
    local navigation=create("Frame",{Size=UDim2.new(1,-2,0,34),BackgroundTransparency=1},aimPage)
    for i,name in ipairs({"Ajustes","Campo de visão"}) do
        UI.aimTabs[name]=button(navigation,name,UDim2.new(0.5,-6,1,0),UDim2.new((i-1)*0.5,(i-1)*6,0,0),function() App.selectAimTab(name) end)
        local pane=create("Frame",{Size=UDim2.new(1,-2,0,0),AutomaticSize=Enum.AutomaticSize.Y,BackgroundTransparency=1},aimPage)
        vertical(pane,Theme.gap) UI.aimSections[name]=pane
    end
    local al,ar=Build.columns(UI.aimSections.Ajustes)
    local activation=section(al,"Mira automática")
    toggle(activation,"Ativar mira automática","aimEnabled",true)
    dropdown(activation,"Parte do personagem","aimPart",{{label="Cabeça",value="head"},{label="Torso",value="torso"},{label="Centro do personagem",value="root"}})
    dropdown(activation,"Modo de ativação","aimMode",{{label="Sempre ativo",value="always"},{label="Segurar tecla",value="hold"},{label="Alternar por tecla",value="toggle"}})
    dropdown(activation,"Tecla de ativação","aimKey",{
        {label="Botão direito do mouse",value=Enum.UserInputType.MouseButton2},
        {label="Alt esquerdo",value=Enum.KeyCode.LeftAlt},{label="Alt direito",value=Enum.KeyCode.RightAlt},
        {label="Q",value=Enum.KeyCode.Q},{label="E",value=Enum.KeyCode.E},{label="F",value=Enum.KeyCode.F},
        {label="C",value=Enum.KeyCode.C},{label="V",value=Enum.KeyCode.V},
    })
    slider(activation,"Suavização","smoothing",0,100,1,"%")
    Build.help(activation,"0%: ajuste imediato. 100%: aproximação exponencial mais lenta, com constante de tempo de 0,45 s. A mira pausa ao usar o painel, digitar, abrir menus ou perder o foco.")
    local targets=section(ar,"Seleção de alvos")
    slider(targets,"Distância máxima","aimDistance",50,10000,50,"un.")
    toggle(targets,"Ignorar aliados","ignoreTeam",true)
    toggle(targets,"Verificar obstáculos","checkWalls",true)
    toggle(targets,"Apenas jogadores marcados","markedOnly",true)
    toggle(targets,"Manter alvo enquanto válido","retainTarget",true)
    Build.help(targets,"Prioridade: alvo válido mais próximo do centro. A parte escolhida precisa estar carregada e dentro do círculo. Não há troca automática por outra parte.")
    Build.shortcut(ar,"Personalizar círculo","circle",function() App.selectAimTab("Campo de visão") end)
    local recoil=section(ar,"No Recoil")
    toggle(recoil,"Ativar No Recoil","noRecoil",true)
    UI.recoilStatus=paragraph(recoil,"Desativado",36) UI.recoilStatus.TextWrapped=true
    Build.help(recoil,"Reduz o recuo somente em armas com integração compatível. Funciona independentemente do Aimbot e preserva o controle manual da câmera. Armas sem integração ficam indisponíveis.")
    local fl,fr=Build.columns(UI.aimSections["Campo de visão"])
    local fov=section(fl,"Campo de visão")
    toggle(fov,"Mostrar campo de visão","showFov",true)
    slider(fov,"Raio do campo de visão","fovRadius",30,400,5,"px")
    slider(fov,"Espessura do círculo","fovThickness",1,4,1,"px")
    slider(fov,"Transparência do círculo","fovTransparency",0,100,1,"%")
    local fovColors=section(fr,"Cor do círculo") colorControl(fovColors,"Selecione uma cor","fovColor")
    Build.help(fovColors,"O raio é medido em pixels no centro da tela e não altera o campo de visão da câmera. O círculo real aparece quando a mira está habilitada, mesmo com o painel oculto.")
    App.selectAimTab("Ajustes")

    Build.heading(State.pages["Aparência"],"Aparência","Seu painel, do seu jeito.")
    local pl,pr=Build.columns(State.pages["Aparência"])
    local compact=section(pl,"Rótulos do ESP")
    toggle(compact,"Modo compacto","compact",true)
    slider(compact,"Escala do ESP","espScale",75,160,5,"%")
    slider(compact,"Tamanho do texto","textSize",10,18,1,"px")
    slider(compact,"Opacidade do fundo","backgroundOpacity",0,100,1,"%")
    slider(compact,"Transparência do texto","transparency",0,100,1,"%")
    Build.help(compact,"Padrão: 156 × 41 px. O fundo tem opacidade independente. Ocultar informações reduz a altura. A escala do ESP não muda o painel.")
    Build.shortcut(pl,"Informações exibidas","mark",function() App.selectTab("ESP") end)
    Build.preview(pr)
    local colors=section(pr,"Identidade visual")
    colorControl(colors,"Cor da marcação","color")
    toggle(colors,"Reduzir efeitos visuais","reduceEffects",true)
    Build.help(colors,"Reduzir efeitos desliga as animações e transições. Vida: verde acima de 60%; amarelo de 30% a 60%; vermelho abaixo de 30%. Sem dados, a barra é ocultada.")

    Build.heading(State.pages["Configurações"],"Configurações","Preferências desta sessão.")
    local cl,cr=Build.columns(State.pages["Configurações"])
    local input=section(cl,"Painel e entrada")
    dropdown(input,"Atalho para mostrar ou ocultar","shortcut",{
        {label="Shift direito",value=Enum.KeyCode.RightShift},{label="F4",value=Enum.KeyCode.F4},
        {label="F6",value=Enum.KeyCode.F6},{label="F7",value=Enum.KeyCode.F7},{label="F8",value=Enum.KeyCode.F8},
        {label="P",value=Enum.KeyCode.P},{label="M",value=Enum.KeyCode.M},
    })
    button(input,"Ocultar painel",nil,nil,function() App.setVisible(false) end)
    Build.help(input,"Arraste a barra de título com mouse ou toque. O atalho e o botão flutuante einzig xit reabrem o painel. Minimizar preserva as funções ativas.")
    local performance=section(cl,"Atualização")
    dropdown(performance,"Frequência de atualização","interval",{
        {label="5 vezes por segundo",value=0.2},{label="10 vezes por segundo",value=0.1},{label="20 vezes por segundo",value=0.05},
    })
    Build.help(performance,"O ESP e a lista usam atualizações espaçadas. A mira ajusta a câmera durante a renderização. Valores inválidos são rejeitados; funções com erro são pausadas e podem ser reativadas.")
    local session=section(cr,"Sessão")
    local stop=button(session,"Encerrar",nil,nil,App.confirmStop)
    stop.TextColor3=Palette.red stop.BackgroundColor3=Color3.fromRGB(48,19,30)
    Build.help(session,"Encerrar libera a câmera e remove painel, círculo, marcações, conexões e animações. Dados não carregados ficam indisponíveis. As preferências não são salvas entre sessões.")

    local credits=State.pages["Créditos"]
    Build.heading(credits,"Créditos") Build.banner(credits,110,"Discord @zerox_zl")
    local credit=section(credits,"Criação e identidade")
    credit.Name="CartaoDoCriador"
    local identity=create("Frame",{Name="IdentidadeDoCriador",Size=UDim2.new(1,0,0,48),BackgroundTransparency=1},credit)
    Build.seal(identity,40,UDim2.fromOffset(2,4),false)
    local creator=textLabel(identity,"Feito por @zerox_zl",UDim2.new(1,-230,0,22),UDim2.fromOffset(54,1),14,Palette.text)
    creator.Font=Enum.Font.GothamMedium creator.TextTruncate=Enum.TextTruncate.AtEnd
    local role=textLabel(identity,"Criação e identidade visual",UDim2.new(1,-230,0,20),UDim2.fromOffset(54,25),12,Palette.muted)
    role.TextTruncate=Enum.TextTruncate.AtEnd
    local handle=textBox(identity,"",UDim2.fromOffset(156,32),UDim2.new(1,-156,0,8))
    handle.Text="@zerox_zl" handle.TextEditable=false handle.Name="CreditoDiscord"
    handle.TextSize=12
    tooltip(handle,"Selecione o identificador e copie com o teclado ou o menu de seleção do dispositivo.")
    local function reflowIdentity()
        local split=identity.AbsoluteSize.X>=440
        identity.Size=UDim2.new(1,0,0,split and 48 or 88)
        local textSize=UDim2.new(1,split and -230 or -54,0,22)
        creator.Size=textSize role.Size=UDim2.new(1,textSize.X.Offset,0,20)
        handle.Position=split and UDim2.new(1,-156,0,8) or UDim2.fromOffset(0,54)
        handle.Size=split and UDim2.fromOffset(156,32) or UDim2.new(1,0,0,32)
    end
    State.responsive[#State.responsive+1]=reflowIdentity
    connect(State.connections,identity:GetPropertyChangedSignal("AbsoluteSize"),reflowIdentity)
    reflowIdentity()
    local sl,sr=Build.columns(credit,440)
    Build.socialButton(sl,"Instagram","InstagramProfileUrl","^https://www%.instagram%.com/[%w_%.%-]+/$")
    Build.socialButton(sr,"Discord","DiscordProfileUrl","^https://discord%.com/users/%d+$")
    Build.help(credit,"Os botões mostram o link completo em um campo selecionável. No computador, use Ctrl+C ou Command+C; no celular, use o menu de seleção. A cópia automática não está disponível neste ambiente.",true)
    Build.socialDialog()
end

-- Integration boundaries. No arbitrary weapon modules are required or executed.
-- Custom factions: set CONFIG.RelationshipMode="custom" and implement this
-- non-yielding callback using your experience's replicated faction data.
-- Return exactly "ally", "enemy", "neutral" (explicit FFA), or "unknown".
Adapters.customRelationship = nil
function Adapters.relationship(other)
    if CONFIG.RelationshipMode=="custom" then
        if type(Adapters.customRelationship)~="function" then return "unknown" end
        local ok,value=pcall(Adapters.customRelationship,localPlayer,other)
        if ok and (value=="ally" or value=="enemy" or value=="neutral" or value=="unknown") then return value end
        App.diagnostic("relationship","Relação de equipes indisponível.")
        return "unknown"
    end
    if CONFIG.RelationshipMode~="teams" then return "unknown" end
    -- Neutral explicitly means unaffiliated in the standard Roblox team model.
    if localPlayer.Neutral or other.Neutral then return "neutral" end
    if not localPlayer.Team or not other.Team then return "unknown" end
    return localPlayer.Team==other.Team and "ally" or "enemy"
end
function Adapters.espEligible(player)
    if Settings.espAudience=="all" then return true end
    local relation=Adapters.relationship(player)
    if relation=="ally" then return false,"Aliado · oculto pelo filtro" end
    if relation=="unknown" then return false,"Equipe indisponível · oculto pelo filtro" end
    return true
end
function Adapters.recoil(tool)
    -- Explicit opt-in contract; the weapon's recoil producer must consume this
    -- NumberValue for EVERY recoil impulse. A matching name alone is insufficient.
    -- Replace this adapter when integrating a different supported weapon API.
    if not tool or tool:GetAttribute("EinzigRecoilAdapter")~="ScaleValueV1" then return nil end
    local scale=tool:FindFirstChild("RecoilScale")
    if scale and scale:IsA("NumberValue") and finite(scale.Value) and scale.Value>=0 then
        return scale,"Value",0
    end
    return nil
end

-- Compare-and-restore ownership: never restore a stale baseline over an external
-- change. Leases are tied to an exact instance, never transferred to a respawn.
function Ownership.release(lease)
    if not lease then return end
    local ok,err=pcall(function()
        if lease.object.Parent and lease.object[lease.key]==lease.applied and lease.applied~=lease.before then
            lease.object[lease.key]=lease.before
        end
    end)
    if not ok then App.diagnostic("restore:"..lease.key,"Não foi possível restaurar uma configuração do personagem.",err) end
end
function Ownership.releaseAll(bag)
    for key,lease in pairs(bag) do bag[key]=nil Ownership.release(lease) end
end
function Ownership.matches(lease)
    return lease and lease.object.Parent~=nil and lease.object[lease.key]==lease.applied
end
function Ownership.write(bag,slot,object,key,value)
    local lease=bag[slot]
    if lease and (lease.object~=object or lease.key~=key) then
        bag[slot]=nil Ownership.release(lease) lease=nil
    end
    if not lease then
        lease={object=object,key=key,before=object[key],applied=object[key]}
        bag[slot]=lease
    end
    if not Ownership.matches(lease) then return false end
    if lease.applied~=value then
        lease.applied=value -- register ownership before the property setter can fail
        object[key]=value
    end
    return Ownership.matches(lease)
end

-- Recoil owns a separate lease bag; it never writes camera transforms.
State.recoil.leases={}
function Recoil.stop(status)
    Ownership.releaseAll(State.recoil.leases)
    State.recoil.tool=nil
    State.recoil.status=status or "Desativado"
    if UI.recoilStatus then put(UI.recoilStatus,"Text",State.recoil.status) end
end
function Recoil.reconcile()
    local r=State.recoil
    if not Settings.noRecoil then
        if next(r.leases) then Recoil.stop() end
    else
        local character=localPlayer.Character
        local humanoid=character and character:FindFirstChildOfClass("Humanoid")
        local tool=character and character:FindFirstChildOfClass("Tool")
        if tool~=r.tool then Recoil.stop("Indisponível para esta arma") r.tool=tool end
        local object,key,value=Adapters.recoil(tool)
        if not character or not character:IsDescendantOf(Workspace) or not humanoid or humanoid.Health<=0 then
            Recoil.stop("Personagem indisponível")
        elseif not object then
            Ownership.releaseAll(r.leases) r.status="Indisponível para esta arma"
        elseif not Ownership.write(r.leases,"scale",object,key,value) then
            Values.noRecoil=false Recoil.stop("Alteração rejeitada pela arma")
            App.diagnostic("recoil-conflict","No Recoil desligado: a arma alterou a configuração.")
            App.syncControls()
        else r.status="Ativo" end
    end
    if UI.recoilStatus then put(UI.recoilStatus,"Text",r.status) end
end

function Movement.modeDescription(compact)
    if Settings.flightMode=="camera" then
        if compact then return "Avanço automático pela câmera. Pause para pairar e olhar ao redor." end
        return "Avança sozinho na direção da câmera, inclusive para cima e para baixo. Use Pausar avanço para olhar ao redor."
    end
    if compact then return "WASD ou toque. A direção inclui a inclinação da câmera." end
    return "WASD ou toque: siga a direção completa da câmera. Olhar para cima ou para baixo inclina o trajeto."
end

function Movement.pauseAdvance()
    local m=State.motion
    if Settings.flightMode~="camera" then return end
    m.followPaused=not m.followPaused
    Movement.clearInputs(false)
    if m.flight then App.guard("flight",Movement.step,0) end
    Movement.sync()
end

function Movement.hasForeignMover()
    local m=State.motion local flight=m.flight
    local classes={LinearVelocity=true,VectorForce=true,AlignPosition=true,AlignOrientation=true,AngularVelocity=true,
        BodyVelocity=true,BodyPosition=true,BodyGyro=true,BodyForce=true,BodyAngularVelocity=true}
    if not m.character or not m.root then return false end
    for _,object in ipairs(m.character:GetDescendants()) do
        if classes[object.ClassName] and not (flight and (object==flight.velocity or object==flight.orientation)) then
            local legacy=object.ClassName:sub(1,4)=="Body"
            local attachment=not legacy and object.Attachment0 or nil
            local part=attachment and attachment.Parent or object.Parent
            local sameAssembly=part==m.root or (part and part:IsA("BasePart") and m.root.AssemblyRootPart
                and part.AssemblyRootPart==m.root.AssemblyRootPart)
            if sameAssembly and (legacy or object.Enabled) then return true end
        end
    end
    return false
end

function Movement.forceBudget()
    local m=State.motion local cfg=CONFIG.FlightDynamics
    local mass,gravity=m.root.AssemblyMass,Workspace.Gravity
    if not finite(mass) or mass<=0 or not finite(gravity) or gravity<0 then return nil end
    local speed=math.max(Settings.flightSpeed,m.flight and m.flight.command.Magnitude or 0,
        m.flight and m.flight.brakingSpeed or 0)
    local acceleration=speed/math.min(cfg.accelerationTime,cfg.brakingTime,cfg.steeringTime)
    local budget=mass*(gravity+acceleration*2)*2
    if not finite(budget) or budget>cfg.maxForce then return nil end
    return math.max(10000,budget)
end

function Movement.applySpeed()
    local f=State.motion.flight
    if not f then return end
    local budget=Movement.forceBudget()
    if not budget then Movement.refuse("flight","Massa ou gravidade fora do limite do voo") return end
    f.velocity.MaxForce=budget
    f.grace=CONFIG.FlightDynamics.graceSeconds f.stalled=0
    Movement.step(0) Movement.sync()
end

function Movement.flightDirection(camera)
    local m=State.motion local actions={}
    for _,action in pairs(m.held) do actions[action]=true end
    local x=(actions.right and 1 or 0)-(actions.left and 1 or 0)
    local z=(actions.forward and 1 or 0)-(actions.back and 1 or 0)
    local y=(actions.up and 1 or 0)-(actions.down and 1 or 0)
    local look,right=camera.CFrame.LookVector,camera.CFrame.RightVector
    local native=m.humanoid.MoveDirection
    if native and finite(native.Magnitude) then
        if native.Magnitude<0.035 then m.nativeBlocked=false end
        if UserInputService.TouchEnabled and not m.nativeBlocked and x==0 and z==0 and native.Magnitude>=0.035 then
            local flatRight=Vector3.new(right.X,0,right.Z)
            if flatRight.Magnitude>0.05 then
                flatRight=flatRight/flatRight.Magnitude
                local flatForward=Vector3.new(flatRight.Z,0,-flatRight.X)
                x=math.clamp(native:Dot(flatRight),-1,1) z=math.clamp(native:Dot(flatForward),-1,1)
            end
        end
    end
    if Settings.flightMode=="camera" and not m.followPaused and math.abs(z)<0.01 then z=1 end
    local direction=look*z+right*x
    -- Os controles verticais têm prioridade sobre a inclinação: Subir sempre sobe.
    if y~=0 then direction=Vector3.new(direction.X,y,direction.Z) end
    if not finite(direction.Magnitude) then error("Direção da câmera inválida") end
    if direction.Magnitude>1 then direction=direction/direction.Magnitude end
    return direction
end

function Movement.ramp(current,target,dt)
    local delta=target-current local magnitude=delta.Magnitude
    local flight=State.motion.flight
    if magnitude<0.001 then
        if flight then flight.brakingSpeed=nil end
        return target
    end
    local currentSpeed,targetSpeed=current.Magnitude,target.Magnitude
    local cfg=CONFIG.FlightDynamics
    local braking=targetSpeed<currentSpeed-0.01 or current:Dot(target)<0
    local turning=currentSpeed>0.01 and targetSpeed>0.01 and current:Dot(target)<currentSpeed*targetSpeed*0.995
    local duration=braking and cfg.brakingTime or (turning and cfg.steeringTime or cfg.accelerationTime)
    -- Mantenha a referência inicial até concluir a frenagem, inclusive ao reduzir o ajuste.
    -- Recalcular pela velocidade restante a cada passo causaria uma cauda de desaceleração.
    if flight then
        flight.brakingSpeed=braking and math.max(currentSpeed,flight.brakingSpeed or 0) or nil
    end
    local rate=math.max(Settings.flightSpeed,currentSpeed,targetSpeed,flight and flight.brakingSpeed or 0)/duration
    local step=rate*math.max(0,dt)
    if magnitude<=step then
        if flight then flight.brakingSpeed=nil end
        return target
    end
    return current+delta*(step/magnitude)
end

function Movement.obstacleLimit(command,dt)
    local m=State.motion local f=m.flight local cfg=CONFIG.FlightDynamics
    local speed=command.Magnitude
    f.obstructed=false
    if speed<0.01 or dt<=0 then return command end
    local acceleration=math.max(Settings.flightSpeed,speed)/cfg.brakingTime
    local travel=speed*dt+speed*speed/(2*acceleration)+cfg.collisionMargin+0.5
    f.raycast.CollisionGroup=m.root.CollisionGroup
    -- Sondagem finita; não substitui colisões do motor nem detecta sobreposição inicial.
    local hit=Workspace:Spherecast(m.root.Position,f.radius,command/speed*math.min(1024,travel),f.raycast)
    if not hit then return command end
    if not finite(hit.Distance) or hit.Distance<0 then error("Distância de obstáculo inválida") end
    local distance=math.max(0,hit.Distance-cfg.collisionMargin)
    -- Reserva o próximo passo de simulação e a distância necessária para frear.
    local adt=acceleration*dt
    local safeSpeed=math.max(0,math.sqrt(adt*adt+2*acceleration*distance)-adt)
    if safeSpeed<speed then
        f.obstructed=true
        return command*(safeSpeed/speed)
    end
    return command
end

function Movement.steer(camera)
    local f=State.motion.flight
    local look,right=camera.CFrame.LookVector,camera.CFrame.RightVector
    local flatRight=Vector3.new(right.X,0,right.Z)
    -- Preserve o último rumo perto dos polos. A inclinação só altera o trajeto.
    if math.abs(look.Y)<0.985 and flatRight.Magnitude>0.05 then
        flatRight=flatRight/flatRight.Magnitude
        f.heading=Vector3.new(flatRight.Z,0,-flatRight.X)
    end
    f.orientation.CFrame=CFrame.lookAt(Vector3.new(),f.heading)
end

function Movement.measureFlight(dt)
    local m=State.motion local f=m.flight local cfg=CONFIG.FlightDynamics
    if dt<=0 then return end
    local position=m.root.Position
    local traveled=(position-f.lastPosition).Magnitude
    if not finite(traveled) then error("Posição do personagem inválida") end
    f.lastPosition=position
    local elapsedStep=f.previousDt f.previousDt=dt
    if not elapsedStep then return end
    f.grace=math.max(0,f.grace-elapsedStep)
    local plausible=math.max(16,math.max(Settings.flightSpeed,f.command.Magnitude,f.observed or 0)*elapsedStep*4)
    if traveled>plausible then
        f.elapsed=0 f.travel=0 f.observed=nil m.observedSpeed=nil
        f.grace=cfg.graceSeconds f.stalled=0
        m.statuses.flight="Deslocamento externo · medição reiniciada"
        Movement.sync() return
    end
    f.travel=f.travel+traveled f.elapsed=f.elapsed+elapsedStep
    if f.elapsed<cfg.sampleInterval then return end
    local elapsed=f.elapsed
    f.observed=f.travel/elapsed
    local alpha=1-math.exp(-elapsed/cfg.measurementTime)
    m.observedSpeed=m.observedSpeed and (m.observedSpeed+(f.observed-m.observedSpeed)*alpha) or f.observed
    f.elapsed=0 f.travel=0
    local wanted=f.desired.Magnitude
    if f.blocked then m.statuses.flight="Avanço pausado · interação com a interface"
    elseif f.obstructed then m.statuses.flight="Frenagem por obstáculo"
    elseif wanted<1 then
        m.statuses.flight=f.observed<3 and (m.followPaused and "Avanço pausado · pairando" or "Pairando") or "Freando"
    elseif f.observed>=wanted*0.6 then m.statuses.flight="Voando · movimento observado"
    else m.statuses.flight="Velocidade abaixo do solicitado" end
    -- O diagnóstico usa a amostra bruta; suavização existe somente na leitura da interface.
    if wanted>=10 and f.grace<=0 and not f.obstructed and not f.blocked and f.observed<wanted*0.25 then
        f.stalled=f.stalled+elapsed
        if f.stalled>=cfg.stallSeconds then Movement.refuse("flight","Voo sem resposta suficiente do personagem") return end
    else f.stalled=0 end
    local budget=Movement.forceBudget()
    if not budget then Movement.refuse("flight","Massa ou gravidade fora do limite do voo") return end
    put(f.velocity,"MaxForce",budget)
    if Movement.hasForeignMover() then Movement.refuse("flight","Outro controlador de movimento está ativo") return end
    Movement.sync()
end

function Movement.clearInputs(pauseAutomatic,brake)
    local m=State.motion
    for input,connection in pairs(m.inputConnections) do connection:Disconnect() m.inputConnections[input]=nil end
    table.clear(m.held) m.nativeBlocked=true
    if m.flight then
        if pauseAutomatic~=false and Settings.flightMode=="camera" then m.followPaused=true end
        if brake~=false then
            m.flight.command=Vector3.new() m.flight.desired=Vector3.new()
            if m.flight.velocity and m.flight.velocity.Parent then m.flight.velocity.VectorVelocity=Vector3.new() end
        end
        m.flight.stalled=0 m.flight.grace=CONFIG.FlightDynamics.graceSeconds
    end
end

function Movement.releaseInput(input)
    local m=State.motion
    if m.inputConnections[input] then m.inputConnections[input]:Disconnect() m.inputConnections[input]=nil end
    local had=m.held[input]~=nil
    m.held[input]=nil
    if had and m.flight then App.guard("flight",Movement.step,0) end
end
function Movement.hold(input,action)
    local m=State.motion
    if not m.flight or not State.focused or m.held[input] then return end
    m.held[input]=action
    -- InputObject end/cancel is observed even after a pointer leaves its button.
    m.inputConnections[input]=input:GetPropertyChangedSignal("UserInputState"):Connect(function()
        if input.UserInputState==Enum.UserInputState.End or input.UserInputState==Enum.UserInputState.Cancel then
            if State.alive then App.guard("flight",Movement.releaseInput,input) end
        end
    end)
    App.guard("flight",Movement.step,0)
end
function Movement.sync()
    local m=State.motion
    for _,pair in ipairs({{UI.flightStatus,m.statuses.flight},
        {UI.speedStatus,m.statuses.speed},{UI.flyStatus,m.statuses.flight}}) do
        if pair[1] then put(pair[1],"Text",pair[2]) end
    end
    if UI.flyModeHelp then put(UI.flyModeHelp,"Text",Movement.modeDescription(true)) end
    if UI.pageModeHelp then put(UI.pageModeHelp,"Text",Movement.modeDescription()) end
    if UI.flyModeBadge then put(UI.flyModeBadge,"Text",Settings.flightMode=="camera" and "Seguir câmera" or "Manual") end
    local measured=m.flight and (m.observedSpeed and ("Medida: "..round(m.observedSpeed).." un./s") or "Medida: aguardando movimento") or "Medida: voo desligado"
    for _,label in ipairs({UI.flyMeasured,UI.pageFlightMeasured}) do if label then put(label,"Text",measured) end end
    for _,pause in ipairs({UI.flyPause,UI.pageFlightPause}) do
        if pause then
            put(pause,"Visible",Settings.flightMode=="camera" and m.flight~=nil)
            put(pause,"Text",m.followPaused and "Retomar avanço" or "Pausar avanço")
            put(pause,"BackgroundColor3",m.followPaused and Palette.hover or Palette.input)
        end
    end
    for _,control in ipairs({UI.flyToggle,UI.pageFlightToggle}) do
        if control then
            put(control,"Text",Settings.flightEnabled and "Parar voo" or "Iniciar voo")
            put(control,"BackgroundColor3",Settings.flightEnabled and Palette.hover or Palette.primary)
        end
    end
    local flight=m.flight
    if UI.flyStatusDot then
        local color=not flight and Palette.muted or ((m.followPaused or (flight.observed or 0)<2) and Palette.yellow or Palette.green)
        put(UI.flyStatusDot,"BackgroundColor3",color)
    end
    if UI.flyManual then put(UI.flyManual,"Visible",m.manualExpanded) end
    if UI.flyManualToggle then put(UI.flyManualToggle,"Text",m.manualExpanded and "Recolher controles manuais" or "Controles manuais") end
    local layoutKey=Settings.flightMode..tostring(m.flight~=nil)..tostring(m.manualExpanded)..tostring(m.flyMinimized)
    if UI.flyBody and m.layoutKey~=layoutKey then m.layoutKey=layoutKey Movement.layoutFly() end
end

function Movement.stopFlight()
    local m=State.motion
    -- Disconnect simulation before any constraint or held input is released.
    disconnect(m.flightConnections)
    pcall(Movement.clearInputs)
    local flight=m.flight m.flight=nil m.observedSpeed=nil m.followPaused=false
    if flight then
        for _,key in ipairs({"velocity","orientation","attachment"}) do
            if flight[key] then pcall(function() flight[key]:Destroy() end) end
        end
        Ownership.releaseAll(flight.leases)
    end
end
function Movement.stopFeature(feature,status)
    local m=State.motion
    local key=({flight="flightEnabled",speed="speedEnabled"})[feature]
    if key then Values[key]=false end
    if feature=="flight" then Movement.stopFlight()
    else
        local lease=m.leases[feature] m.leases[feature]=nil Ownership.release(lease)
    end
    m.statuses[feature]=status or "Desativado"
    Movement.sync()
    if State.ready then App.syncControls() end
end
function Movement.reset(status)
    for _,feature in ipairs({"flight","speed"}) do Movement.stopFeature(feature,status) end
    Movement.clearInputs()
end
function Movement.bind(character)
    local m=State.motion
    Movement.reset("Desativado · reative no novo personagem")
    disconnect(m.characterConnections) disconnect(m.humanoidConnections)
    m.character,m.humanoid,m.root=character,nil,nil
    m.baseline=nil
    if character then
        local function changed() m.dirty=true end
        connect(m.characterConnections,character.ChildAdded,changed,"motion")
        connect(m.characterConnections,character.ChildRemoved,changed,"motion")
    end
end
function Movement.refreshCharacter()
    local m=State.motion
    local character=localPlayer.Character
    if character==State.localRemoving then character=nil end
    if character~=m.character then Movement.bind(character) end
    local loaded=character and character:IsDescendantOf(Workspace)
    local h=loaded and character:FindFirstChildOfClass("Humanoid") or nil
    local root=loaded and character:FindFirstChild("HumanoidRootPart") or nil
    if root and not root:IsA("BasePart") then root=nil end
    if h~=m.humanoid or root~=m.root then
        Movement.reset("Desativado · personagem atualizado")
        disconnect(m.humanoidConnections)
        m.humanoid,m.root=h,root
        -- Baseline is informational; each ownership lease captures the current
        -- property's latest value when it starts, including external changes while off.
        m.baseline=h and {WalkSpeed=h.WalkSpeed} or nil
        if h then
            connect(m.humanoidConnections,h.Died,function()
                Movement.reset("Desativado · personagem eliminado")
                Recoil.stop("Personagem indisponível")
            end,"motion")
        end
    end
    m.dirty=false
    return h and root and finite(h.Health) and h.Health>0
end
function Movement.ready()
    local m=State.motion
    if not m.character or m.character~=localPlayer.Character or not m.character:IsDescendantOf(Workspace)
        or not m.humanoid or not m.root or not m.root:IsDescendantOf(m.character) or not m.humanoid:IsDescendantOf(m.character)
        or not finite(m.humanoid.Health) or m.humanoid.Health<=0 then return false,"Personagem indisponível" end
    return true
end
function Movement.refuse(feature,reason)
    Movement.stopFeature(feature,reason)
    App.diagnostic("motion-limit:"..feature,reason..". Reative quando disponível.")
end
function Movement.ground()
    local m=State.motion
    if not Settings.speedEnabled then
        local lease=m.leases.speed m.leases.speed=nil Ownership.release(lease) return
    end
    local ready,reason=Movement.ready()
    if not ready then Movement.refuse("speed",reason) return end
    if m.flight then
        local lease=m.leases.speed m.leases.speed=nil Ownership.release(lease)
        m.statuses.speed="Suspenso durante o voo" return
    end
    local h=m.humanoid local lease=m.leases.speed
    if lease and lease.object~=h then
        m.leases.speed=nil Ownership.release(lease) lease=nil
    end
    if lease and not Ownership.matches(lease) then Movement.refuse("speed","Alteração rejeitada pelo jogo") return end
    local baseline=lease and lease.before or h.WalkSpeed
    if not finite(baseline) or baseline<0 then Movement.refuse("speed","Configuração do personagem indisponível") return end
    if not Ownership.write(m.leases,"speed",h,"WalkSpeed",Settings.groundSpeed) then
        Movement.refuse("speed","Alteração rejeitada pelo jogo") return
    end
    m.statuses.speed="Ativo"
end
function Movement.startFlight()
    local m=State.motion
    local ready,reason=Movement.ready()
    if not ready then Movement.refuse("flight",reason) return end
    if not Workspace.CurrentCamera then Movement.refuse("flight","Câmera indisponível") return end
    if m.root.Anchored then Movement.refuse("flight","Personagem imobilizado pelo jogo") return end
    if m.humanoid.Sit or m.humanoid.SeatPart then Movement.refuse("flight","Saia do assento para voar") return end
    if m.humanoid.PlatformStand or Movement.hasForeignMover() then
        Movement.refuse("flight","Outro controlador de movimento está ativo") return
    end
    local budget=Movement.forceBudget()
    if not budget then Movement.refuse("flight","Massa ou gravidade fora do limite do voo") return end
    Ownership.releaseAll(m.leases)
    Movement.clearInputs(false) m.followPaused=false m.observedSpeed=nil
    local flight={leases={},command=Vector3.new(),desired=Vector3.new(),observed=0,
        elapsed=0,travel=0,lastPosition=m.root.Position,stalled=0,grace=CONFIG.FlightDynamics.graceSeconds,
        radius=math.clamp(math.max(m.root.Size.X,m.root.Size.Z)*0.5+0.65,1.25,3.5)}
    m.flight=flight
    flight.raycast=RaycastParams.new() flight.raycast.FilterType=Enum.RaycastFilterType.Exclude
    flight.raycast.FilterDescendantsInstances={m.character} flight.raycast.RespectCanCollide=true
    flight.raycast.IgnoreWater=true flight.raycast.CollisionGroup=m.root.CollisionGroup
    flight.attachment=create("Attachment",{Name="EinzigFly_Anexo"},m.root)
    flight.velocity=create("LinearVelocity",{Name="EinzigFly_Velocidade",Attachment0=flight.attachment,
        RelativeTo=Enum.ActuatorRelativeTo.World,VelocityConstraintMode=Enum.VelocityConstraintMode.Vector,
        ForceLimitsEnabled=true,ForceLimitMode=Enum.ForceLimitMode.Magnitude,MaxForce=budget,
        VectorVelocity=Vector3.new(),Enabled=true},m.root)
    local facing=m.root.CFrame.LookVector
    facing=Vector3.new(facing.X,0,facing.Z)
    if facing.Magnitude<0.001 then facing=Vector3.new(0,0,-1) end
    flight.heading=facing/facing.Magnitude
    flight.orientation=create("AlignOrientation",{Name="EinzigFly_Orientacao",Attachment0=flight.attachment,
        Mode=Enum.OrientationAlignmentMode.OneAttachment,RigidityEnabled=false,
        MaxTorque=math.clamp(m.root.AssemblyMass*8000,10000,1000000),MaxAngularVelocity=7,Responsiveness=25,
        CFrame=CFrame.lookAt(Vector3.new(),facing),Enabled=true},m.root)
    if not Ownership.write(flight.leases,"rotate",m.humanoid,"AutoRotate",false)
        or not Ownership.write(flight.leases,"stand",m.humanoid,"PlatformStand",true) then
        Movement.refuse("flight","Alteração rejeitada pelo jogo") return
    end
    connect(m.flightConnections,RunService.PreSimulation,function(dt) App.guard("flight",Movement.step,dt) end,"flight")
    m.statuses.flight="Iniciando · aguardando medição"
    m.flyVisible=true
    if UI.fly then UI.fly.Visible=true Movement.layoutFly() end
end

function Movement.step(deltaTime)
    local m=State.motion local flight=m.flight
    if not flight then return end
    if not Settings.flightEnabled then Movement.stopFlight() return end
    local ready,reason=Movement.ready()
    if not ready then Movement.refuse("flight",reason) return end
    local camera=Workspace.CurrentCamera
    if not camera then Movement.refuse("flight","Câmera indisponível") return end
    if m.root.Anchored or m.humanoid.Sit or m.humanoid.SeatPart
        or not flight.velocity.Parent or not flight.velocity.Enabled or not flight.orientation.Parent
        or not flight.orientation.Enabled or not flight.attachment.Parent
        or not Ownership.matches(flight.leases.rotate) or not Ownership.matches(flight.leases.stand) then
        Movement.refuse("flight","Voo interrompido pelo jogo") return
    end
    local focus=UserInputService:GetFocusedTextBox()
    local editingSpeed=focus and (focus==UI.flySpeed or focus==UI.pageFlightSpeed)
    local draggingOther=State.dragging and not (State.dragging.kind=="slider" and State.dragging.key=="flightSpeed")
    local blocked=not State.focused or GuiService.MenuIsOpen or (focus and not editingSpeed)
        or draggingOther or UI.popup or UI.modal.Visible or (UI.socialModal and UI.socialModal.Visible)
    flight.blocked=not not blocked
    local dt=finite(deltaTime) and math.clamp(deltaTime,0,0.25) or 0
    if blocked then Movement.clearInputs(true) end
    local direction=blocked and Vector3.new() or Movement.flightDirection(camera)
    flight.desired=direction*Settings.flightSpeed
    flight.command=Movement.ramp(flight.command,flight.desired,dt)
    flight.command=Movement.obstacleLimit(flight.command,dt)
    flight.velocity.VectorVelocity=flight.command
    Movement.steer(camera)
    Movement.measureFlight(dt)
end

function Movement.reconcile()
    local m=State.motion
    Movement.refreshCharacter()
    if Settings.flightEnabled then
        if not m.flight then App.guard("flight",Movement.startFlight) end
    elseif m.flight then Movement.stopFlight() end
    App.guard("speed",Movement.ground)
    Movement.sync()
end
function Movement.shutdown()
    Movement.reset()
    disconnect(State.motion.characterConnections)
    disconnect(State.motion.humanoidConnections)
    State.motion.character,State.motion.humanoid,State.motion.root=nil,nil,nil
    State.motion.baseline=nil
end
function Movement.keyboard(input,processed)
    if processed or not Settings.flightEnabled or UserInputService:GetFocusedTextBox() then return end
    if input.UserInputType~=Enum.UserInputType.Keyboard then return end
    local map={[Enum.KeyCode.W]="forward",[Enum.KeyCode.S]="back",[Enum.KeyCode.A]="left",[Enum.KeyCode.D]="right",
        [Enum.KeyCode.Up]="forward",[Enum.KeyCode.Down]="back",[Enum.KeyCode.Left]="left",[Enum.KeyCode.Right]="right",
        [Enum.KeyCode.Space]="up",[Enum.KeyCode.LeftControl]="down"}
    if map[input.KeyCode] then Movement.hold(input,map[input.KeyCode]) end
end

function Movement.layoutFly()
    if not UI.fly or not UI.flyBody then return end
    local m=State.motion local area=UI.area.AbsoluteSize
    local width=math.min(340,math.max(1,area.X-20))
    local narrow=width<300
    local pinned=area.Y>=280
    UI.flyToggle.Parent=pinned and UI.flySurface or UI.flyBody
    UI.flyModeRow.Size=UDim2.new(1,-14,0,narrow and 76 or 36)
    for i,value in ipairs({"manual","camera"}) do
        local control=UI.flyModes[value]
        control.Size=narrow and UDim2.new(1,0,0,36) or UDim2.new(0.5,-3,1,0)
        control.Position=narrow and UDim2.fromOffset(0,(i-1)*40) or UDim2.new((i-1)*0.5,(i-1)*3,0,0)
    end
    UI.flyModeHelp.Position=UDim2.fromOffset(9,narrow and 103 or 63)
    local y=0
    local rows={{UI.flyModeCard,narrow and 140 or 100,true},{UI.flySpeedCard,96,true},{UI.flyToggle,44,not pinned},
        {UI.flyPause,38,Settings.flightMode=="camera" and m.flight~=nil},{UI.flyVertical,44,true},
        {UI.flyManualToggle,34,true},{UI.flyManual,48,m.manualExpanded}}
    for _,row in ipairs(rows) do
        local object,height,visible=row[1],row[2],row[3]
        if object then
            object.Visible=visible
            object.Position=UDim2.fromOffset(0,y) object.Size=UDim2.new(1,-4,0,height)
            if visible then y=y+height+7 end
        end
    end
    local contentHeight=math.max(0,y-7)
    UI.flyBody.CanvasSize=UDim2.fromOffset(0,contentHeight+4)
    local desiredHeight=82+contentHeight+(pinned and 81 or 30)
    local height=m.flyMinimized and 74 or math.min(desiredHeight,math.max(74,area.Y-20))
    UI.fly.Size=UDim2.fromOffset(width,height)
    UI.flyBody.Size=UDim2.new(1,-24,1,pinned and -160 or -110)
    if pinned then
        UI.flyToggle.Position=UDim2.new(0,12,1,-74) UI.flyToggle.Size=UDim2.new(1,-24,0,44)
    end
    UI.flyToggle.Visible=not m.flyMinimized
    UI.flyBody.Visible=not m.flyMinimized UI.flyCredit.Visible=not m.flyMinimized
    UI.flyMinimize.Text=m.flyMinimized and "+" or "−"
    if not m.flyPositioned then
        UI.fly.Position=UDim2.fromOffset(math.max(10,area.X-width-18),math.max(10,area.Y-height-18)) m.flyPositioned=true
    end
    UI.fly.Position=UDim2.fromOffset(math.clamp(UI.fly.Position.X.Offset,0,math.max(0,area.X-width)),
        math.clamp(UI.fly.Position.Y.Offset,0,math.max(0,area.Y-height)))
    UI.flyBody.CanvasPosition=Vector2.new(0,math.clamp(UI.flyBody.CanvasPosition.Y,0,
        math.max(0,contentHeight-UI.flyBody.AbsoluteSize.Y+4)))
end

function Movement.openFly()
    State.motion.flyVisible=true UI.fly.Visible=true Movement.layoutFly()
end
function Movement.closeFly()
    Settings.flightEnabled=false Movement.stopFeature("flight")
    Movement.clearInputs() App.endDrag()
    State.motion.flyVisible=false UI.fly.Visible=false
    App.changed()
end
function Build.flyController()
    UI.fly=create("Frame",{Name="EinzigFly",Size=UDim2.fromOffset(340,444),BackgroundTransparency=1,
        BorderSizePixel=0,Visible=false,Active=true,ZIndex=12},UI.area)
    for i=3,1,-1 do
        local shadow=create("Frame",{Name="Sombra",Position=UDim2.fromOffset(-i*2,i),Size=UDim2.new(1,i*4,1,i*2),
            BackgroundColor3=Palette.background,BackgroundTransparency=0.8+i*0.04,BorderSizePixel=0,Active=false},UI.fly)
        corner(shadow,14+i*2)
    end
    local surface=create("Frame",{Name="Superficie",Size=UDim2.fromScale(1,1),BackgroundColor3=Color3.new(1,1,1),
        BorderSizePixel=0,Active=false,ZIndex=2},UI.fly)
    UI.flySurface=surface
    corner(surface,14) stroke(surface,Palette.primary,0.25)
    create("UIGradient",{Color=ColorSequence.new(Palette.cardTop,Palette.surfaceBottom),Rotation=80},surface)
    local header=create("Frame",{Name="CabecalhoAnime",Position=UDim2.fromOffset(2,2),Size=UDim2.new(1,-4,0,70),
        BackgroundColor3=Palette.surfaceBottom,BorderSizePixel=0,ClipsDescendants=true},surface)
    corner(header,12)
    local fallback=create("Frame",{Size=UDim2.fromScale(1,1),BackgroundColor3=Color3.new(1,1,1),BorderSizePixel=0},header)
    corner(fallback,12) create("UIGradient",{Color=ColorSequence.new(Palette.surfaceBottom,Palette.hover)},fallback)
    local artwork=Build.asset(header,"HeaderArtworkAssetId",UDim2.fromScale(1,1),nil,Enum.ScaleType.Crop,fallback)
    if artwork then corner(artwork,12) artwork.ImageTransparency=0.35 end
    local shade=create("Frame",{Size=UDim2.fromScale(1,1),BackgroundColor3=Palette.background,BorderSizePixel=0},header)
    corner(shade,12) create("UIGradient",{Transparency=NumberSequence.new(0.06,0.65)},shade)
    local line=create("Frame",{Position=UDim2.new(0,12,1,-1),Size=UDim2.new(1,-24,0,1),BackgroundColor3=Palette.light,
        BorderSizePixel=0,BackgroundTransparency=0.3,Active=false},header)
    create("UIGradient",{Transparency=NumberSequence.new(0.25,0.95)},line)
    UI.flyDrag=create("TextButton",{Text="",AutoButtonColor=false,AutoLocalize=false,BackgroundTransparency=1,
        Size=UDim2.new(1,-80,1,0)},header)
    Build.seal(UI.flyDrag,40,UDim2.fromOffset(10,13),false)
    local title=textLabel(UI.flyDrag,"einzig fly",UDim2.new(1,-65,0,31),UDim2.fromOffset(60,8),26)
    title.Font=Enum.Font.Garamond title.TextTruncate=Enum.TextTruncate.AtEnd
    UI.flyStatusDot=create("Frame",{Size=UDim2.fromOffset(6,6),Position=UDim2.fromOffset(61,46),
        BackgroundColor3=Palette.muted,BorderSizePixel=0},UI.flyDrag) corner(UI.flyStatusDot,3)
    UI.flyStatus=textLabel(UI.flyDrag,"Desativado",UDim2.new(1,-74,0,24),UDim2.fromOffset(74,37),11,Palette.light)
    UI.flyStatus.TextTruncate=Enum.TextTruncate.AtEnd
    tooltip(UI.flyStatus,function() return State.motion.statuses.flight end)
    UI.flyMinimize=button(header,"−",UDim2.fromOffset(32,32),UDim2.new(1,-76,0,11),function()
        Movement.clearInputs(false,false) App.endDrag()
        State.motion.flyMinimized=not State.motion.flyMinimized Movement.layoutFly()
    end)
    tooltip(UI.flyMinimize,"Minimizar ou restaurar. O voo continua ativo, inclusive o avanço pela câmera.")
    local close=button(header,"",UDim2.fromOffset(32,32),UDim2.new(1,-38,0,11),Movement.closeFly)
    Build.icon(close,"close",14,UDim2.fromOffset(9,9)) tooltip(close,"Fechar os controles e parar o voo.")
    UI.flyModeBadge=textLabel(header,"Manual",UDim2.fromOffset(74,16),UDim2.new(1,-80,0,48),10,Palette.light)
    UI.flyModeBadge.TextXAlignment=Enum.TextXAlignment.Right
    tooltip(UI.flyModeBadge,function() return "Modo de voo: "..(Settings.flightMode=="camera" and "Seguir câmera" or "Manual") end)
    UI.flyBody=create("ScrollingFrame",{Name="ControlesDeVoo",Position=UDim2.fromOffset(12,82),Size=UDim2.new(1,-24,1,-110),
        BackgroundTransparency=1,BorderSizePixel=0,ScrollBarThickness=2,CanvasSize=UDim2.new(),
        ScrollingDirection=Enum.ScrollingDirection.Y,ScrollBarImageColor3=Palette.accent,CanvasPosition=Vector2.new()},surface)
    local function card(name)
        local frame=create("Frame",{Name=name,BackgroundColor3=Palette.card,BorderSizePixel=0},UI.flyBody)
        corner(frame,9) stroke(frame,Palette.border,0.35) return frame
    end
    UI.flyModeCard=card("ModoDeVoo")
    textLabel(UI.flyModeCard,"Modo de voo",UDim2.new(1,-18,0,16),UDim2.fromOffset(9,5),11,Palette.muted)
    local modeRow=create("Frame",{Position=UDim2.fromOffset(7,23),Size=UDim2.new(1,-14,0,36),BackgroundTransparency=1},UI.flyModeCard)
    local modes={} UI.flyModes=modes UI.flyModeRow=modeRow
    for i,mode in ipairs({{label="Manual",value="manual",icon="fly"},{label="Seguir câmera",value="camera",icon="camera"}}) do
        local control=button(modeRow,"",UDim2.new(0.5,-3,1,0),UDim2.new((i-1)*0.5,(i-1)*3,0,0),function()
            Settings.flightMode=mode.value App.changed()
        end)
        Build.buttonText(control,mode.label,27,3,12) Build.icon(control,mode.icon,15,UDim2.fromOffset(7,10))
        tooltip(control,mode.value=="manual" and "Mova com as teclas ou o toque, na direção completa da câmera."
            or "Ao iniciar, avance automaticamente para onde a câmera aponta. Use a pausa para pairar.")
        modes[mode.value]=control
    end
    local function refreshModes()
        for value,control in pairs(modes) do
            local selected=Settings.flightMode==value
            control:SetAttribute("Selecionado",selected) control.BackgroundColor3=selected and Palette.hover or Palette.input
            Visual.feedback(control)
        end
    end
    State.controls[#State.controls+1]=refreshModes refreshModes()
    UI.flyModeHelp=textLabel(UI.flyModeCard,"",UDim2.new(1,-18,0,34),UDim2.fromOffset(9,63),11,Palette.muted)
    UI.flyModeHelp.TextWrapped=true
    UI.flySpeedCard=card("VelocidadeDoVoo")
    local speedHost=create("Frame",{Position=UDim2.fromOffset(8,5),Size=UDim2.new(1,-16,0,70),BackgroundTransparency=1},UI.flySpeedCard)
    local r=Ranges.flightSpeed
    local speedFrame,speedBox,speedHit=slider(speedHost,"Velocidade do voo","flightSpeed",r[1],r[2],r[3],"un./s",
        {wide=true,logarithmic=true,increment=CONFIG.FlightSpeedIncrement})
    UI.flySpeed=speedBox speedFrame.Size=UDim2.new(1,0,0,70)
    speedHit.Size=UDim2.new(1,-92,0,40) speedHit.Position=UDim2.fromOffset(46,28)
    for _,control in ipairs(speedFrame:GetChildren()) do
        if control:IsA("TextButton") and (control.Text=="−" or control.Text=="+") then
            control.Size=UDim2.fromOffset(40,40)
            control.Position=control.Text=="−" and UDim2.fromOffset(0,28) or UDim2.new(1,-40,0,28)
        end
    end
    UI.flyMeasured=textLabel(UI.flySpeedCard,"",UDim2.new(1,-18,0,18),UDim2.fromOffset(9,76),11,Palette.light)
    tooltip(UI.flyMeasured,"Deslocamento local por segundo, com suavização breve para leitura. Colisões e o servidor podem limitar a velocidade solicitada.")
    UI.flyToggle=button(UI.flyBody,"Iniciar voo",nil,nil,function()
        Settings.flightEnabled=not Settings.flightEnabled App.changed()
    end)
    UI.flyToggle.Font=Enum.Font.GothamMedium
    UI.flyPause=button(UI.flyBody,"Pausar avanço",nil,nil,Movement.pauseAdvance)
    tooltip(UI.flyPause,"Pausa somente o avanço automático. Você pode olhar ao redor e usar os controles manuais.")
    UI.flyVertical=create("Frame",{BackgroundTransparency=1},UI.flyBody)
    local function holdButton(parent,label,action,size,position)
        local b=button(parent,label,size,position)
        tooltip(b,"Segure para "..({up="subir",down="descer",forward="avançar",back="recuar",left="ir à esquerda",right="ir à direita"})[action]
            ..((action=="up" or action=="down") and ". Tem prioridade sobre a inclinação vertical da câmera." or ". Solte para frear essa direção."))
        connect(State.connections,b.InputBegan,function(input)
            if input.UserInputType==Enum.UserInputType.Touch or input.UserInputType==Enum.UserInputType.MouseButton1 then Movement.hold(input,action) end
        end,"flight")
        connect(State.connections,b.InputEnded,Movement.releaseInput,"flight") return b
    end
    holdButton(UI.flyVertical,"Subir","up",UDim2.new(0.5,-4,1,0),UDim2.new())
    holdButton(UI.flyVertical,"Descer","down",UDim2.new(0.5,-4,1,0),UDim2.new(0.5,4,0,0))
    UI.flyManualToggle=button(UI.flyBody,"Controles manuais",nil,nil,function()
        State.motion.manualExpanded=not State.motion.manualExpanded
        if not State.motion.manualExpanded then Movement.clearInputs(false,false) end
        Movement.layoutFly() Movement.sync()
    end)
    UI.flyManualToggle.TextSize=12
    tooltip(UI.flyManualToggle,"Expandir ou recolher os botões de direção. O teclado continua disponível.")
    UI.flyManual=create("Frame",{BackgroundTransparency=1,Visible=false},UI.flyBody)
    for i,item in ipairs({{"Esq.","left"},{"Frente","forward"},{"Trás","back"},{"Dir.","right"}}) do
        local control=holdButton(UI.flyManual,item[1],item[2],UDim2.new(0.25,-4,1,0),UDim2.new((i-1)*0.25,0,0,0))
        control.TextSize=12
    end
    UI.flyCredit=textLabel(surface,"@zerox_zl",UDim2.new(1,-24,0,20),UDim2.new(0,12,1,-24),10,Palette.muted)
    UI.flyCredit.TextXAlignment=Enum.TextXAlignment.Right
    connect(State.connections,UI.flyDrag.InputBegan,function(input)
        if input.UserInputType==Enum.UserInputType.MouseButton1 or input.UserInputType==Enum.UserInputType.Touch then
            App.endDrag() Movement.clearInputs() Aim.release(false)
            State.dragging={kind="window",window=UI.fly,input=input,start=input.Position,position=UI.fly.Position}
            App.watchDrag(input)
        end
    end)
    State.controls[#State.controls+1]=Movement.sync
    Movement.layoutFly() Movement.sync()
end

function Build.movement()
    local page=State.pages["Einzig Fly"]
    Build.heading(page,"Einzig Fly","Movimento sob seu controle.")
    local left,right=Build.columns(page,490)
    local flight=section(left,"Voo")
    dropdown(flight,"Modo de voo","flightMode",{{label="Manual",value="manual"},{label="Seguir câmera",value="camera"}})
    UI.pageModeHelp=paragraph(flight,Movement.modeDescription(),66) UI.pageModeHelp.TextWrapped=true
    toggle(flight,"Ativar voo","flightEnabled",true)
    local r=Ranges.flightSpeed
    local _,pageSpeed=slider(flight,"Velocidade do voo","flightSpeed",r[1],r[2],r[3],"un./s",
        {wide=true,logarithmic=true,increment=CONFIG.FlightSpeedIncrement})
    UI.pageFlightSpeed=pageSpeed
    UI.flightStatus=paragraph(flight,"Desativado",34) UI.flightStatus.TextWrapped=true
    UI.pageFlightMeasured=paragraph(flight,"Medida: voo desligado",20)
    UI.pageFlightPause=button(flight,"Pausar avanço",UDim2.new(1,0,0,38),nil,Movement.pauseAdvance)
    tooltip(UI.pageFlightPause,"Pause para pairar e olhar ao redor. Retome quando quiser avançar pela câmera.")
    Build.shortcut(flight,"Abrir controles de voo","fly",Movement.openFly)
    Build.help(flight,"Manual: WASD, setas ou toque; a inclinação da câmera também conduz o voo. Espaço sobe; Ctrl esquerdo desce. Seguir câmera avança sozinho e suspende o Aimbot para você conduzir. Após perder foco ou usar menus, retome o avanço pelo botão.")
    local speed=section(right,"Velocidade")
    tooltip(toggle(speed,"Ativar velocidade personalizada","speedEnabled",true),"Altera a caminhada. A velocidade do voo possui um ajuste separado.")
    r=Ranges.groundSpeed slider(speed,"Velocidade de movimento","groundSpeed",r[1],r[2],r[3],"un./s")
    UI.speedStatus=paragraph(speed,"Desativado",34) UI.speedStatus.TextWrapped=true
    Build.help(speed,"A caminhada fica suspensa durante o voo e volta ao parar, se continuar habilitada. Ao morrer ou trocar de personagem, os recursos de movimento são desligados e exigem nova ativação. Os valores escolhidos são preservados.")
    Build.help(flight,"A velocidade solicitada é independente da medida. Obstáculos provocam frenagem preventiva; o motor do jogo ainda controla as colisões. Velocidades altas precisam de teste nesta experiência. Movimento sem resposta é interrompido, sem reativação automática.")
    Build.flyController()
end


-- Data adapter: all values come from replicated characters, never estimates.
-- For a custom health system, replace only this adapter with your replicated data.
function App.snapshot(player, removing)
    local result={character=nil,root=nil,anchor=nil,health=nil,maxHealth=nil,ratio=nil,dead=false}
    local character=player.Character
    if not character or character==removing or not character:IsDescendantOf(Workspace) then
        result.reason="Personagem não carregado"
        return result
    end
    result.character=character
    local root=character:FindFirstChild("HumanoidRootPart") or character.PrimaryPart
        or character:FindFirstChild("Torso") or character:FindFirstChild("UpperTorso")
        or character:FindFirstChild("Head")
    if root and root:IsA("BasePart") and root:IsDescendantOf(Workspace) then result.root=root end
    local head=character:FindFirstChild("Head")
    result.anchor=(head and head:IsA("BasePart") and head:IsDescendantOf(Workspace)) and head or result.root
    local humanoid=character:FindFirstChildOfClass("Humanoid")
    if humanoid then
        if finite(humanoid.Health) then result.health=humanoid.Health result.dead=humanoid.Health<=0 end
        if finite(humanoid.MaxHealth) then result.maxHealth=humanoid.MaxHealth end
        if result.health and result.maxHealth and result.maxHealth>0 then
            result.ratio=math.clamp(result.health/result.maxHealth,0,1)
        end
    end
    if not result.root then result.reason="Posição indisponível"
    elseif result.dead then result.reason="Eliminado"
    elseif result.health==nil or result.maxHealth==nil then result.reason="Vida indisponível" end
    return result
end
local function healthNumber(value)
    if value==math.floor(value) then return tostring(value) end
    return string.gsub(string.format("%.2f",value),"%.",",")
end
local function healthText(snapshot)
    if snapshot.health==nil or snapshot.maxHealth==nil then return "Vida indisponível" end
    return "Vida: "..healthNumber(snapshot.health).."/"..healthNumber(snapshot.maxHealth)
end
local function distanceText(snapshot)
    if snapshot.distance~=nil then return "Distância: "..round(snapshot.distance).." unidades" end
    return "Distância indisponível"
end
local function healthColor(ratio)
    if ratio==nil then return Palette.muted end
    if ratio>0.6 then return Palette.green end
    if ratio>=0.3 then return Palette.yellow end
    return Palette.red
end
function App.addPlayer(player)
    if player==localPlayer or State.records[player.UserId] or not State.alive then return end
    local record={player=player,selected=false,connections={},snapshot={},removing=nil}
    State.records[player.UserId]=record
    record.searchName=fold(player.DisplayName)
    record.searchUser=fold(player.Name)
    local row=create("Frame",{Name="Jogador_"..player.UserId,Size=UDim2.new(1,0,0,64),
        BackgroundColor3=Palette.card,BorderSizePixel=0},UI.list)
    record.row=row corner(row,9)
    row.BackgroundColor3=Color3.new(1,1,1)
    create("UIGradient",{Color=ColorSequence.new(Palette.cardTop,Palette.cardBottom),Rotation=85},row)
    record.border=stroke(row,Palette.border,0.4)
    record.name=textLabel(row,player.DisplayName,UDim2.new(1,-115,0,18),UDim2.fromOffset(10,5),14)
    record.name.Font=Enum.Font.GothamMedium record.name.TextTruncate=Enum.TextTruncate.AtEnd
    record.username=textLabel(row,"@"..player.Name,UDim2.new(1,-115,0,16),UDim2.fromOffset(10,23),12,Palette.muted)
    record.username.TextTruncate=Enum.TextTruncate.AtEnd
    tooltip(record.name,function() return player.DisplayName.."\n@"..player.Name end,record.connections)
    tooltip(record.username,"@"..player.Name,record.connections)
    record.healthLabel=textLabel(row,"Vida indisponível",UDim2.new(1,-115,0,17),UDim2.fromOffset(10,42),12,Palette.muted)
    record.healthLabel.TextTruncate=Enum.TextTruncate.AtEnd
    record.distanceLabel=record.healthLabel
    tooltip(row,function()
        local s=record.snapshot
        return player.DisplayName.."\n@"..player.Name.." · "..healthText(s).."\n"..distanceText(s)
            ..(s.reason and " · "..s.reason or "")
    end,record.connections)
    record.action=button(row,"Marcar",UDim2.fromOffset(92,32),UDim2.new(1,-102,0,7),function()
        App.manualSelection()
        record.selected=not record.selected
        App.changed()
    end,record.connections)
    record.markStatus=textLabel(row,"Não marcado",UDim2.fromOffset(92,16),UDim2.new(1,-102,0,42),11,Palette.muted)
    record.markStatus.TextXAlignment=Enum.TextXAlignment.Center
    connect(record.connections,player.CharacterAdded,function()
        record.removing=nil App.clearMarker(record) State.needsUpdate=true
    end)
    connect(record.connections,player.CharacterRemoving,function(character)
        record.removing=character App.clearMarker(record) State.needsUpdate=true
        if State.aim.target==record then Aim.release(false) end
    end)
    connect(record.connections,player:GetPropertyChangedSignal("DisplayName"),function()
        record.searchName=fold(player.DisplayName) State.needsUpdate=true
    end)
    for _,property in ipairs({"Team","Neutral"}) do
        connect(record.connections,player:GetPropertyChangedSignal(property),function()
            State.needsUpdate=true
            if State.aim.target==record then Aim.release(false) end
            if State.ready then App.guard("esp",App.update,true) end
        end)
    end
    State.needsUpdate=true
end
function App.removePlayer(player)
    local record=State.records[player.UserId]
    if not record then return end
    if State.aim.target==record then Aim.release(false) end
    disconnect(record.connections)
    App.clearMarker(record)
    record.row:Destroy()
    State.records[player.UserId]=nil
    App.hideTooltip()
    State.needsUpdate=true
end
function App.markerGeometry(snapshot)
    local scale=Settings.espScale/100
    local pad=Settings.compact and 4 or 7
    local line=Settings.textSize+(Settings.compact and 2 or 5)
    local y=pad
    local rows={}
    local function add(key,visible)
        if visible then rows[key]={y=y,height=line} y=y+line end
    end
    add("name",Settings.showName)
    add("username",Settings.showUsername)
    if Settings.compact then add("details",Settings.showHealth or Settings.showDistance)
    else add("health",Settings.showHealth) add("distance",Settings.showDistance) end
    local hasBar=Settings.showBar and snapshot.ratio~=nil
    local barY,barHeight
    if hasBar then barY=y+3 barHeight=Settings.compact and 2 or 3 y=barY+barHeight end
    return {scale=scale,pad=round(pad*scale),width=round((Settings.compact and 156 or 232)*scale),
        height=round((y+pad)*scale),rows=rows,hasContent=y>pad,
        barY=barY and round(barY*scale),barHeight=barHeight and math.max(1,round(barHeight*scale)),
        textSize=math.max(8,round(Settings.textSize*scale)),
        detailSize=math.max(8,round((Settings.compact and math.max(10,Settings.textSize-1) or Settings.textSize)*scale))}
end
function App.createMarkerVisual(parent,character)
    local card=create("Frame",{Size=UDim2.fromScale(1,1),BackgroundColor3=Palette.background,BorderSizePixel=0},parent)
    corner(card,3)
    local marker={card=card,border=stroke(card,Settings.color,0.72),labels={},character=character}
    for _,key in ipairs({"name","username","details","health","distance"}) do
        local label=textLabel(card,"",nil,nil,Settings.textSize)
        label.TextStrokeColor3=Color3.new(0,0,0) label.TextTruncate=Enum.TextTruncate.AtEnd
        label.TextWrapped=false label.TextYAlignment=Enum.TextYAlignment.Center
        marker.labels[key]=label
    end
    marker.labels.name.Font=Enum.Font.GothamMedium
    marker.labels.username.TextColor3=Palette.muted
    marker.bar=create("Frame",{Size=UDim2.new(1,-8,0,2),BackgroundColor3=Palette.input,BorderSizePixel=0},card)
    corner(marker.bar,1)
    marker.fill=create("Frame",{Size=UDim2.fromScale(1,1),BackgroundColor3=Palette.green,BorderSizePixel=0},marker.bar)
    corner(marker.fill,1)
    return marker
end
function App.paintMarkerVisual(marker,snapshot,displayName,username)
    local geometry=App.markerGeometry(snapshot)
    local alpha=Settings.transparency/100
    local details={}
    if Settings.showHealth then details[#details+1]=healthText(snapshot) end
    if Settings.showDistance then details[#details+1]=snapshot.distance and (round(snapshot.distance).." un.") or "Dist. indisponível" end
    local text={name=displayName,username="@"..username,
        details=table.concat(details," · "),health=healthText(snapshot),
        distance=snapshot.distance and (round(snapshot.distance).." un.") or "Distância indisponível"}
    for key,label in pairs(marker.labels) do
        local row=geometry.rows[key]
        put(label,"Visible",row~=nil)
        if row then
            put(label,"Position",UDim2.fromOffset(geometry.pad,round(row.y*geometry.scale)))
            put(label,"Size",UDim2.new(1,-geometry.pad*2,0,round(row.height*geometry.scale)))
            put(label,"Text",text[key])
            put(label,"TextSize",key=="name" and geometry.textSize or geometry.detailSize)
            put(label,"TextTransparency",alpha)
            put(label,"TextStrokeTransparency",0.3+0.7*alpha)
        end
    end
    put(marker.labels.health,"TextColor3",healthColor(snapshot.ratio))
    put(marker.bar,"Visible",geometry.barY~=nil)
    if geometry.barY then
        put(marker.bar,"Position",UDim2.fromOffset(geometry.pad,geometry.barY))
        put(marker.bar,"Size",UDim2.new(1,-geometry.pad*2,0,geometry.barHeight))
        put(marker.bar,"BackgroundTransparency",0.45)
        put(marker.fill,"Size",UDim2.fromScale(snapshot.ratio,1))
        put(marker.fill,"BackgroundColor3",healthColor(snapshot.ratio))
        put(marker.fill,"BackgroundTransparency",alpha)
    end
    marker.width,marker.height=geometry.width,geometry.height
    -- Background opacity deliberately has no dependency on text transparency.
    put(marker.card,"BackgroundTransparency",1-Settings.backgroundOpacity/100)
    put(marker.border,"Color",Settings.color)
    put(marker.border,"Transparency",0.72)
    return geometry
end
function App.makeMarker(record)
    record.billboard=create("BillboardGui",{Name="EinzigXit_Marcacao_"..record.player.UserId,
        ResetOnSpawn=false,AlwaysOnTop=true,LightInfluence=0,MaxDistance=0,
        Size=UDim2.fromOffset(156,41),SizeOffset=Vector2.new(0,0.5),Enabled=false,
        ClipsDescendants=true,ZIndexBehavior=Enum.ZIndexBehavior.Sibling},playerGui)
    record.marker=App.createMarkerVisual(record.billboard,record.snapshot.character)
end
function App.paintMarker(record)
    if record.marker and record.marker.character~=record.snapshot.character then App.clearMarker(record) end
    if not record.billboard then App.makeMarker(record) end
    local marker,snapshot=record.marker,record.snapshot
    local geometry=App.paintMarkerVisual(marker,snapshot,record.player.DisplayName,record.player.Name)
    marker.offset=snapshot.anchor.Size.Y/2+(Settings.compact and 0.3 or 0.6)
    put(record.billboard,"Size",UDim2.fromOffset(geometry.width,geometry.height))
    put(record.billboard,"Adornee",snapshot.anchor)
    put(record.billboard,"StudsOffsetWorldSpace",Vector3.new(0,marker.offset,0))
    return geometry.hasContent
end

-- Spatial hashing bounds overlap work; labels are considered nearest-first.
-- The engine tracks world positions each frame, without a Lua RenderStepped loop.
local function reserveLabel(grid,camera,record)
    if not camera then return false end
    local marker=record.marker
    local point,onScreen=camera:WorldToViewportPoint(record.snapshot.anchor.Position+Vector3.new(0,marker.offset,0))
    if point.Z<=0 or not onScreen then return false end
    local rectangle={left=point.X-marker.width/2-3,right=point.X+marker.width/2+3,
        top=point.Y-marker.height-3,bottom=point.Y+3}
    local x0,x1=math.floor(rectangle.left/160),math.floor(rectangle.right/160)
    local y0,y1=math.floor(rectangle.top/64),math.floor(rectangle.bottom/64)
    for x=x0,x1 do
        for y=y0,y1 do
            local bucket=grid[x..":"..y]
            if bucket then
                for _,other in ipairs(bucket) do
                    if rectangle.left<other.right and rectangle.right>other.left
                        and rectangle.top<other.bottom and rectangle.bottom>other.top then return false end
                end
            end
        end
    end
    for x=x0,x1 do
        for y=y0,y1 do
            local key=x..":"..y
            if not grid[key] then grid[key]={} end
            table.insert(grid[key],rectangle)
        end
    end
    return true
end
function App.updateList(total,markedCount)
    if not State.visible or State.minimized or State.activeTab~="Jogadores" then return end
    local sorted={}
    for _,record in pairs(State.records) do
        local matches=State.query=="" or string.find(record.searchName,State.query,1,true)
            or string.find(record.searchUser,State.query,1,true)
        put(record.row,"Visible",not not matches)
        if matches then sorted[#sorted+1]=record end
    end
    table.sort(sorted,function(a,b)
        if Settings.sort=="distance" or Settings.sort=="health" then
            local key=Settings.sort=="distance" and "distance" or "health"
            local av,bv=a.snapshot[key],b.snapshot[key]
            if av==nil and bv~=nil then return false end
            if av~=nil and bv==nil then return true end
            if av~=nil and bv~=nil and av~=bv then return av<bv end
        end
        if a.searchName~=b.searchName then return a.searchName<b.searchName end
        if a.searchUser~=b.searchUser then return a.searchUser<b.searchUser end
        return a.player.UserId<b.player.UserId
    end)
    for index,record in ipairs(sorted) do
        local isMarked=marked(record)
        local snapshot=record.snapshot
        put(record.row,"LayoutOrder",index)
        put(record.name,"Text",record.player.DisplayName)
        local health=snapshot.health~=nil and snapshot.maxHealth~=nil and healthText(snapshot) or "Vida indisponível"
        local distance=snapshot.distance and (round(snapshot.distance).." un.") or "Dist. indisponível"
        if snapshot.reason and snapshot.reason~="Vida indisponível" then distance=snapshot.reason end
        if snapshot.distance and snapshot.distance>Settings.maxDistance and isMarked then
            distance=distance.." · Fora do alcance"
        end
        put(record.healthLabel,"Text",health.." · "..distance)
        put(record.healthLabel,"TextColor3",healthColor(snapshot.ratio))
        put(record.action,"Text",isMarked and "Desmarcar" or "Marcar")
        put(record.action,"BackgroundColor3",isMarked and Palette.hover or Palette.input)
        put(record.markStatus,"Text",isMarked and "Marcado" or "Não marcado")
        put(record.markStatus,"TextColor3",isMarked and Palette.accent or Palette.muted)
        put(record.border,"Color",isMarked and Palette.accent or Palette.border)
    end
    put(UI.count,"Text",total.." jogadores · "..markedCount.." marcados")
    put(UI.empty,"Visible",#sorted==0)
    put(UI.empty,"Text",total==0 and "Nenhum outro jogador nesta partida."
        or "Nenhum jogador encontrado.\nTente outro nome ou usuário.")
end
function App.update(refreshList)
    if not State.alive then return end
    local origin=App.snapshot(localPlayer,State.localRemoving)
    local total,markedCount,unknownRelations=0,0,0
    local candidates={}
    for _,record in pairs(State.records) do
        total=total+1
        local selected=marked(record)
        if selected then markedCount=markedCount+1 end
        local snapshot=App.snapshot(record.player,record.removing)
        if origin.root and snapshot.root then
            local distance=(origin.root.Position-snapshot.root.Position).Magnitude
            if finite(distance) then snapshot.distance=distance end
        elseif snapshot.root then
            snapshot.reason="Seu personagem não está carregado"
        end
        local teamEligible,teamReason=Adapters.espEligible(record.player)
        if not teamEligible then
            snapshot.reason=teamReason
            if teamReason=="Equipe indisponível · oculto pelo filtro" then unknownRelations=unknownRelations+1 end
        end
        record.snapshot=snapshot
        local eligible=selected and Settings.enabled and snapshot.anchor and snapshot.distance
            and snapshot.distance<=Settings.maxDistance and not (Settings.hideDead and snapshot.dead)
            and Workspace.CurrentCamera~=nil and teamEligible
        record.eligible=not not eligible
        if eligible then
            candidates[#candidates+1]=record
        else
            if not selected or not snapshot.character or not snapshot.anchor or not teamEligible then
                App.clearMarker(record)
            else
                if record.billboard then put(record.billboard,"Enabled",false) end
                -- Disabled Highlights still occupy engine slots; destroy unused ones.
                if record.highlight then record.highlight:Destroy() record.highlight=nil end
            end
        end
    end
    table.sort(candidates,function(a,b)
        if a.snapshot.distance~=b.snapshot.distance then return a.snapshot.distance<b.snapshot.distance end
        return a.player.UserId<b.player.UserId
    end)
    -- Roblox currently budgets 255 Highlights per client, shared with the game.
    -- Release old slots first, then allocate the nearest eligible characters.
    for index,record in ipairs(candidates) do
        if (not Settings.showOutline or index>255) and record.highlight then
            record.highlight:Destroy() record.highlight=nil
        end
    end
    local grid,camera={},Workspace.CurrentCamera
    local visibleLabels=0
    for index,record in ipairs(candidates) do
        local showLabel=App.paintMarker(record)
        if showLabel and Settings.reduceOverlap then showLabel=reserveLabel(grid,camera,record) end
        put(record.billboard,"Enabled",showLabel)
        if showLabel then visibleLabels=visibleLabels+1 end
        if Settings.showOutline and index<=255 then
            if not record.highlight then
                record.highlight=create("Highlight",{Name="Contorno_"..record.player.UserId,
                    DepthMode=Enum.HighlightDepthMode.AlwaysOnTop,FillTransparency=1,
                    Enabled=true},UI.world)
            end
            put(record.highlight,"Adornee",record.snapshot.character)
            put(record.highlight,"OutlineColor",Settings.color)
            put(record.highlight,"OutlineTransparency",Settings.transparency/100)
        end
    end
    local status=Settings.enabled and "Marcações ativas" or "Marcações pausadas"
    if Settings.enabled and not origin.root then status="Seu personagem está indisponível" end
    if Settings.enabled and not Workspace.CurrentCamera then status="Câmera indisponível" end
    put(UI.footer,"Text",status.." · "..markedCount.." marcados · "..visibleLabels.." rótulos"
        ..(#candidates>255 and Settings.showOutline and " · Limite de contornos" or ""))
    if UI.homeEsp then put(UI.homeEsp,"Text",markedCount.." marcados · "..visibleLabels.." rótulos visíveis") end
    if UI.espRelationshipStatus then
        put(UI.espRelationshipStatus,"Text",Settings.espAudience=="all" and "Todos os jogadores são elegíveis."
            or (unknownRelations>0 and (unknownRelations.." jogadores com equipe indisponível; ocultos.") or "Aliados ocultos. Neutros elegíveis no modo livre."))
    end
    if refreshList then App.updateList(total,markedCount) end
    State.needsUpdate=false
end

function Aim.status(status,reason)
    State.aim.status=status State.aim.reason=reason or ""
    if UI.aimStatus then put(UI.aimStatus,"Text",status) end
    if UI.homeAim then put(UI.homeAim,"Text",status) end
    if UI.aimReason then put(UI.aimReason,"Text",reason or "") end
end
function Aim.release(clearInput)
    State.aim.target=nil State.aim.elapsed=0.1
    if clearInput then State.aim.held=false State.aim.toggled=false State.aim.touchInput=nil end
    -- We never change CameraType, CameraSubject, MouseBehavior or FieldOfView.
    -- Releasing means no more camera writes, not rewinding to an old CFrame.
    if not Settings.aimEnabled then
        if State.aim.bound then RunService:UnbindFromRenderStep(RENDER_NAME) State.aim.bound=false end
        if UI.fovCircle then UI.fovCircle.Visible=false end
        Aim.status("Desativado",State.faults.aim and "Mira pausada por erro. Ative novamente para tentar." or "")
    end
end
function Aim.viewport(camera)
    if not camera or not camera:IsA("Camera") then return nil end
    local size=camera.ViewportSize
    if not finite(size.X) or not finite(size.Y) or size.X<2 or size.Y<2 then return nil end
    return Vector2.new(size.X/2,size.Y/2),size
end
function Aim.drawFov(camera)
    local center=Aim.viewport(camera)
    local visible=center~=nil and Settings.aimEnabled and Settings.showFov and not State.faults.aim
    put(UI.fovCircle,"Visible",visible)
    if visible then
        put(UI.fovCircle,"Position",UDim2.fromOffset(center.X,center.Y))
        put(UI.fovCircle,"Size",UDim2.fromOffset(Settings.fovRadius*2,Settings.fovRadius*2))
        put(UI.fovStroke,"Color",State.aim.target and Settings.fovColor:Lerp(Palette.light,0.3) or Settings.fovColor)
        put(UI.fovStroke,"Thickness",Settings.fovThickness)
        put(UI.fovStroke,"Transparency",Settings.fovTransparency/100)
    end
end
function Aim.pointInPanel(position)
    local point=App.uiPoint(position)
    for _,window in ipairs({UI.window,UI.fly}) do
        if window and window.Visible then
            local p,size=window.AbsolutePosition,window.AbsoluteSize
            if point.X>=p.X and point.X<=p.X+size.X and point.Y>=p.Y and point.Y<=p.Y+size.Y then return true end
        end
    end
    return false
end
function Aim.blocked()
    if State.motion.flight and Settings.flightMode=="camera" then
        return true,"Aimbot suspenso para você conduzir o voo pela câmera."
    end
    if not State.focused or GuiService.MenuIsOpen then return true,"Janela sem foco ou menu aberto." end
    if UserInputService:GetFocusedTextBox() then return true,"Digite à vontade; a mira está suspensa." end
    if State.dragging or UI.popup or UI.modal.Visible or (UI.socialModal and UI.socialModal.Visible) or next(State.uiPointers) then return true,"Interação com o painel." end
    if UserInputService.MouseEnabled and Aim.pointInPanel(UserInputService:GetMouseLocation()) then
        return true,"Mova o cursor para fora do painel para usar a mira."
    end
    return false,""
end
function Aim.resolvePart(snapshot)
    local character=snapshot.character
    if not character then return nil end
    local part
    if Settings.aimPart=="head" then part=character:FindFirstChild("Head")
    elseif Settings.aimPart=="torso" then part=character:FindFirstChild("UpperTorso") or character:FindFirstChild("Torso")
    else part=character:FindFirstChild("HumanoidRootPart") end
    if part and part:IsA("BasePart") and part:IsDescendantOf(Workspace) then return part end
    return nil
end
function Aim.candidate(record,camera,origin,center,size)
    if not record or record.player==localPlayer or record.player.Parent~=Players then return nil end
    if Settings.markedOnly and not marked(record) then return nil end
    if Settings.ignoreTeam then
        local relation=Adapters.relationship(record.player)
        if relation=="ally" or relation=="unknown" then return nil end
    end
    local snapshot=App.snapshot(record.player,record.removing)
    if not snapshot.character or snapshot.health==nil or snapshot.health<=0 then return nil end
    local part=Aim.resolvePart(snapshot)
    if not part then return nil end
    local distance=(part.Position-origin.root.Position).Magnitude
    if not finite(distance) or distance>Settings.aimDistance then return nil end
    local point,onScreen=camera:WorldToViewportPoint(part.Position)
    if not onScreen or not finite(point.X) or not finite(point.Y) or not finite(point.Z)
        or point.Z<=0 or point.X<0 or point.X>size.X or point.Y<0 or point.Y>size.Y then return nil end
    local dx,dy=point.X-center.X,point.Y-center.Y
    local pixels=dx*dx+dy*dy
    if pixels>Settings.fovRadius*Settings.fovRadius then return nil end
    local direction=part.Position-camera.CFrame.Position
    if not finite(direction.Magnitude) or direction.Magnitude<0.001 then return nil end
    if Settings.checkWalls then
        State.raycast.FilterDescendantsInstances={origin.character,camera}
        local hit=Workspace:Raycast(camera.CFrame.Position,direction,State.raycast)
        if hit and not hit.Instance:IsDescendantOf(snapshot.character) then return nil end
    end
    return {record=record,part=part,pixels=pixels}
end
function Aim.step(deltaTime)
    if not Settings.aimEnabled then Aim.release(true) return end
    local camera=Workspace.CurrentCamera
    if camera~=State.aim.camera then
        Aim.release(true) State.aim.camera=camera
    end
    local center,size=Aim.viewport(camera)
    if not center then
        Aim.release(true) Aim.status("Aguardando ativação","Câmera indisponível.") Aim.drawFov(nil) return
    end
    Aim.drawFov(camera)
    local blocked,reason=Aim.blocked()
    local active=Settings.aimMode=="always" or (Settings.aimMode=="hold" and State.aim.held)
        or (Settings.aimMode=="toggle" and State.aim.toggled)
    if blocked or not active then
        Aim.release(false) Aim.status("Aguardando ativação",reason) Aim.drawFov(camera) return
    end
    local origin=App.snapshot(localPlayer,State.localRemoving)
    if not origin.root or origin.health==nil or origin.health<=0 then
        Aim.release(true) Aim.status("Aguardando ativação","Aguardando seu personagem.") Aim.drawFov(camera) return
    end
    local dt=finite(deltaTime) and math.clamp(deltaTime,0,1) or 0
    local candidate=Aim.candidate(State.aim.target,camera,origin,center,size)
    if State.aim.target and not candidate then Aim.release(false) end
    State.aim.elapsed=State.aim.elapsed+dt
    if (not candidate or not Settings.retainTarget) and State.aim.elapsed>=0.1 then
        State.aim.elapsed=0
        local best=nil
        for _,record in pairs(State.records) do
            local nextCandidate=Aim.candidate(record,camera,origin,center,size)
            if nextCandidate and (not best or nextCandidate.pixels<best.pixels
                or (nextCandidate.pixels==best.pixels and record.player.UserId<best.record.player.UserId)) then best=nextCandidate end
        end
        candidate=best State.aim.target=best and best.record or nil
    end
    if not candidate then
        Aim.status("Procurando alvo","") Aim.drawFov(camera) return
    end
    State.aim.target=candidate.record
    Aim.status("Alvo: "..candidate.record.player.DisplayName,"")
    local current=camera.CFrame
    local desired=CFrame.lookAt(current.Position,candidate.part.Position)
    local tau=Settings.smoothing/100*0.45
    local alpha=tau==0 and 1 or (1-math.exp(-dt/tau))
    if Workspace.CurrentCamera==camera and Settings.aimEnabled then camera.CFrame=current:Lerp(desired,alpha) end
    Aim.drawFov(camera)
end
function Aim.reconcile()
    if not Settings.aimEnabled then Aim.release(true)
    elseif not State.aim.bound then
        State.aim.camera=Workspace.CurrentCamera State.aim.elapsed=0.1
        RunService:BindToRenderStep(RENDER_NAME,Enum.RenderPriority.Camera.Value+1,function(dt)
            App.guard("aim",Aim.step,dt)
        end)
        State.aim.bound=true
        Aim.status("Procurando alvo","")
    end
    if UI.touchAim then
        UI.touchAim.Visible=UserInputService.TouchEnabled and Settings.aimEnabled and Settings.aimMode~="always"
        UI.touchAim.Text=Settings.aimMode=="hold" and "Segurar mira" or "Alternar mira"
    end
    if UI.fovCircle then Aim.drawFov(Workspace.CurrentCamera) end
end
function Aim.matches(input)
    if Settings.aimKey==Enum.UserInputType.MouseButton2 then return input.UserInputType==Enum.UserInputType.MouseButton2 end
    return input.UserInputType==Enum.UserInputType.Keyboard and input.KeyCode==Settings.aimKey
end

function App.endDrag()
    local drag=State.dragging State.dragging=nil
    if drag then
        if drag.cancelConnection then drag.cancelConnection:Disconnect() end
        if drag.scroll and drag.scroll.Parent then drag.scroll.ScrollingEnabled=true end
    end
end
function App.watchDrag(input)
    local drag=State.dragging
    if not drag or typeof(input)~="Instance" then return end
    drag.cancelConnection=input:GetPropertyChangedSignal("UserInputState"):Connect(function()
        if input.UserInputState==Enum.UserInputState.End or input.UserInputState==Enum.UserInputState.Cancel then
            if State.dragging==drag then
                App.endDrag()
                if input.UserInputState==Enum.UserInputState.Cancel and State.alive then
                    App.guard("flight",Movement.clearInputs)
                end
            end
        end
    end)
end
function Build.events()
    connect(State.connections,UI.area:GetPropertyChangedSignal("AbsoluteSize"),App.layout)
    connect(State.connections,UI.dragHandle.InputBegan,function(input)
        if input.UserInputType==Enum.UserInputType.MouseButton1 or input.UserInputType==Enum.UserInputType.Touch then
            App.closePopup() App.hideTooltip()
            Aim.release(false)
            State.dragging={kind="window",input=input,start=input.Position,position=UI.window.Position}
            App.watchDrag(input)
        end
    end)
    connect(State.connections,UserInputService.InputChanged,function(input)
        if not State.alive then return end
        local drag=State.dragging
        if drag then
            local isMouse=drag.input.UserInputType==Enum.UserInputType.MouseButton1
                and input.UserInputType==Enum.UserInputType.MouseMovement
            if isMouse or input==drag.input then
                if drag.kind=="window" then
                    local delta=input.Position-drag.start
                    local area=UI.area.AbsoluteSize
                    local window=drag.window or UI.window
                    local size=window.AbsoluteSize
                    window.Position=UDim2.fromOffset(
                        math.clamp(drag.position.X.Offset+delta.X,0,math.max(0,area.X-size.X)),
                        math.clamp(drag.position.Y.Offset+delta.Y,0,math.max(0,area.Y-size.Y)))
                else drag.move(input.Position) end
            end
        elseif input.UserInputType==Enum.UserInputType.MouseMovement then App.placeTooltip() end
    end)
    connect(State.connections,UserInputService.InputEnded,function(input)
        App.guard("flight",Movement.releaseInput,input)
        State.uiPointers[input]=nil
        if Aim.matches(input) or State.aim.touchInput==input then
            State.aim.held=false State.aim.touchInput=nil
            if Settings.aimMode=="hold" then Aim.release(false) end
        end
        local drag=State.dragging
        if drag and (input==drag.input or (input.UserInputType==Enum.UserInputType.MouseButton1
            and drag.input.UserInputType==Enum.UserInputType.MouseButton1)) then App.endDrag() end
    end)
    connect(State.connections,UserInputService.WindowFocusReleased,function()
        State.focused=false table.clear(State.uiPointers)
        Movement.clearInputs()
        Aim.release(true) App.endDrag() App.hideTooltip()
    end)
    connect(State.connections,UserInputService.WindowFocused,function() State.focused=true end)
    connect(State.connections,UserInputService.TextBoxFocused,function(box)
        Aim.release(true)
        if box==UI.flySpeed or box==UI.pageFlightSpeed then Movement.clearInputs(false,false)
        else Movement.clearInputs() end
    end)
    connect(State.connections,GuiService.MenuOpened,function() Aim.release(true) Movement.clearInputs() end)
    connect(State.connections,UserInputService.InputBegan,function(input,processed)
        App.guard("flight",Movement.keyboard,input,processed)
        local pointer=input.UserInputType==Enum.UserInputType.MouseButton1 or input.UserInputType==Enum.UserInputType.Touch
        if pointer and Aim.pointInPanel(input.Position) then State.uiPointers[input]=true Aim.release(false) end
        if input.UserInputType==Enum.UserInputType.Keyboard and input.KeyCode==Enum.KeyCode.Escape and UI.socialModal.Visible then
            App.closeSocial() return
        end
        if processed or UserInputService:GetFocusedTextBox() then return end
        if input.UserInputType==Enum.UserInputType.Keyboard and input.KeyCode==Settings.shortcut then
            App.endDrag() App.setVisible(not State.visible)
            if State.visible then App.layout() end
            return
        elseif input.UserInputType==Enum.UserInputType.Keyboard and input.KeyCode==Enum.KeyCode.Escape then
            if UI.modal.Visible then UI.modal.Visible=false else App.closePopup() end
            return
        end
        if Settings.aimEnabled and Aim.matches(input) and not Aim.blocked() then
            if Settings.aimMode=="hold" then State.aim.held=true
            elseif Settings.aimMode=="toggle" then
                State.aim.toggled=not State.aim.toggled
                if not State.aim.toggled then Aim.release(false) end
            end
        end
    end)
    connect(State.connections,UI.touchAim.InputBegan,function(input)
        if Settings.aimEnabled and Settings.aimMode=="hold" and input.UserInputType==Enum.UserInputType.Touch then
            State.aim.touchInput=input State.aim.held=true
        end
    end)
    connect(State.connections,Workspace:GetPropertyChangedSignal("CurrentCamera"),function()
        App.guard("motion",Movement.clearInputs)
        if not Workspace.CurrentCamera and State.motion.flight then Movement.refuse("flight","Câmera indisponível") end
        Aim.release(true) State.aim.camera=Workspace.CurrentCamera
        if UI.fovCircle then Aim.drawFov(Workspace.CurrentCamera) end
        State.needsUpdate=true
    end)
    connect(State.connections,localPlayer.CharacterRemoving,function(character)
        State.localRemoving=character Aim.release(true) State.needsUpdate=true
        App.guard("motion",Movement.bind,nil) App.guard("recoil",Recoil.stop,"Personagem indisponível")
    end)
    connect(State.connections,localPlayer.CharacterAdded,function(character)
        State.localRemoving=nil Aim.release(true) State.needsUpdate=true
        App.guard("motion",Movement.bind,character) App.guard("recoil",Recoil.stop,"Aguardando arma")
    end)
    for _,property in ipairs({"Team","Neutral"}) do
        connect(State.connections,localPlayer:GetPropertyChangedSignal(property),function()
            Aim.release(false) State.needsUpdate=true
            if State.ready then App.guard("esp",App.update,true) end
        end)
    end
    connect(State.connections,Players.PlayerAdded,App.addPlayer)
    connect(State.connections,Players.PlayerRemoving,App.removePlayer)
    for _,player in ipairs(Players:GetPlayers()) do App.addPlayer(player) end
    connect(State.connections,RunService.Heartbeat,function(deltaTime)
        if not State.alive then return end
        State.markerElapsed=State.markerElapsed+deltaTime
        State.listElapsed=State.listElapsed+deltaTime
        State.motion.elapsed=State.motion.elapsed+deltaTime
        if State.motion.elapsed>=0.1 or State.motion.dirty then
            State.motion.elapsed=0
            App.guard("motion",Movement.reconcile)
            App.guard("recoil",Recoil.reconcile)
        end
        if UI.toast.Visible and os.clock()>=State.toastUntil then UI.toast.Visible=false end
        if State.copyFocus then State.copyFocus=false App.guard("ui",App.selectSocialText) end
        if State.needsUpdate or State.markerElapsed>=Settings.interval then
            State.markerElapsed=0
            local refreshList=State.needsUpdate or State.listElapsed>=0.35
            if refreshList then State.listElapsed=0 end
            App.guard("esp",App.update,refreshList)
            App.guard("decor",Visual.sweep)
        end
    end)
end

-- Startup is protected so a partial initialization cannot leave orphaned UI.
local ok, failure=xpcall(function()
    assert(type(CONFIG.FlightDynamics)=="table","Dinâmica de voo inválida")
    for key,range in pairs({accelerationTime={0.03,0.35},brakingTime={0.02,0.2},steeringTime={0.02,0.2},maxForce={10000,20000000},
        sampleInterval={0.1,0.5},measurementTime={0.05,0.6},graceSeconds={0.4,3},stallSeconds={0.5,5},collisionMargin={0.1,3}}) do
        local value=CONFIG.FlightDynamics[key]
        assert(finite(value) and value>=range[1] and value<=range[2],"Dinâmica de voo inválida: "..key)
    end
    for key,range in pairs(CONFIG.MovementLimits) do
        assert(Ranges[key]==range and type(range)=="table" and finite(range[1]) and finite(range[2])
            and finite(range[3]) and range[1]>=0 and range[2]>range[1] and range[3]>0
            and range[2]<=(key=="flightSpeed" and 5000 or 1000) and (range[2]-range[1])/range[3]<=5000
            and math.abs((range[2]-range[1])/range[3]-round((range[2]-range[1])/range[3]))<0.00001,
            "Limites de movimento inválidos: "..tostring(key))
    end
    assert(finite(CONFIG.FlightSpeedIncrement) and CONFIG.FlightSpeedIncrement>=1
        and CONFIG.FlightSpeedIncrement<=250 and CONFIG.FlightSpeedIncrement%1==0,"Incremento de voo inválido")
    assert(Ranges.flightSpeed[1]>=1,"Velocidade mínima de voo inválida")
    assert(CONFIG.RelationshipMode=="teams" or CONFIG.RelationshipMode=="custom","Modo de equipes inválido")
    for key,value in pairs(Values) do assert(validSetting(key,value),"Configuração inicial inválida: "..key) end
    State.assets={}
    for _,key in ipairs({"HeaderArtworkAssetId","MonogramAssetId","InstagramLogoAssetId","DiscordLogoAssetId"}) do
        local raw=CONFIG[key]
        if key=="HeaderArtworkAssetId" and (raw==nil or raw=="") then raw=CONFIG.ArtworkAssetId end
        local asset=type(raw)=="string" and raw or tostring(raw or "")
        local id=string.match(asset,"^rbxassetid://(%d+)$") or string.match(asset,"^(%d+)$")
        State.assets[key]=id and tonumber(id)>0 and ("rbxassetid://"..id) or ""
        if asset~="" and State.assets[key]=="" then warn("einzig xit: Id de imagem inválido; usando visual alternativo.") end
    end
    State.raycast=RaycastParams.new()
    State.raycast.FilterType=Enum.RaycastFilterType.Exclude State.raycast.IgnoreWater=true
    Build.shell()
    Build.players()
    Build.settings()
    Build.movement()
    Build.events()
    Movement.reconcile()
    App.syncControls()
    App.refreshPreview()
    State.ready=true
    Visual.preloadAssets()
    App.layout()
    App.guard("esp",App.update,true)
    App.guard("aim",Aim.reconcile)
    App.guard("decor",Visual.refresh)
end,debug.traceback)
if not ok then
    App.stop(false)
    warn("einzig xit: falha ao iniciar. "..(string.match(tostring(failure),"[^\r\n]+") or "Verifique a instalação."):sub(1,150))
end
