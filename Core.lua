-- NaerzRadar FINAL v1.0 - Profesion Auto + Colores GOD - Patch-l.mpq 158kB Edition
-- Verde = Hierba / Dorado = Mena

local frame=CreateFrame("Frame")
local lastPing=0
NaerzRadarDB=NaerzRadarDB or {enabled=true,sound=true,sonar=true}

local function HasHerb()
    for _, idx in pairs({GetProfessions()}) do
        if idx then
            local name = select(1, GetProfessionInfo(idx))
            if name then
                name=name:lower()
                if name:find("herb") or name:find("herbor") then return true end
            end
        end
    end
    return false
end

local function HasMine()
    for _, idx in pairs({GetProfessions()}) do
        if idx then
            local name = select(1, GetProfessionInfo(idx))
            if name then
                name=name:lower()
                if name:find("mine") or name:find("miner") then return true end
            end
        end
    end
    return false
end

local sonar=CreateFrame("Frame","NaerzRadarSonar",UIParent)
sonar:SetSize(220,220)
sonar:SetPoint("CENTER",0,0)
sonar:Hide()
local tex=sonar:CreateTexture(nil,"OVERLAY")
tex:SetAllPoints()
tex:SetTexture("Interface\\Cooldown\\ping4")
tex:SetBlendMode("ADD")

local function DoPing(nodeType)
    if GetTime()-lastPing < 4 then return end
    if not NaerzRadarDB.enabled then return end
    lastPing=GetTime()

    local herb=HasHerb()
    local mine=HasMine()
    if nodeType=="herb" and not herb then return end
    if nodeType=="mine" and not mine then return end
    if not nodeType then
        if not herb and not mine then return end
        nodeType = herb and "herb" or "mine"
    end

    local color, vertexColor, icon
    if nodeType=="mine" then
        color="|cFFFFD700"
        vertexColor={1,0.84,0,0.9}
        icon="[MENA ⛏️]"
    else
        color="|cFF00FF99"
        vertexColor={0,1,0.6,0.9}
        icon="[HIERBA 🌿]"
    end

    tex:SetVertexColor(unpack(vertexColor))

    if NaerzRadarDB.sound then
        PlaySound(12867)
        PlaySound(8959)
    end

    local profText=""
    if herb and mine then profText="Herb + Mine"
    elseif herb then profText="Herboristeria"
    elseif mine then profText="Mineria"
    end

    print(color.."[NaerzRadar] "..icon.." ¡Nodo cerca! |r|cFFAAAAAA("..profText..")|r")

    if NaerzRadarDB.sonar then
        sonar:SetAlpha(0.9)
        sonar:SetScale(0.2)
        sonar:Show()
        local ag=sonar:CreateAnimationGroup()
        local s1=ag:CreateAnimation("Scale")
        s1:SetScale(3,3)
        s1:SetDuration(0.7)
        local a1=ag:CreateAnimation("Alpha")
        a1:SetChange(-0.9)
        a1:SetDuration(0.7)
        ag:SetScript("OnFinished",function() sonar:Hide() end)
        ag:Play()
    end
end

frame:RegisterEvent("PLAYER_LOGIN")
frame:SetScript("OnEvent",function(self, event)
    if event=="PLAYER_LOGIN" then
        local herb=HasHerb()
        local mine=HasMine()
        if herb and mine then
            print("|cFF00FF99[NaerzRadar]|r Cargado - |cFF00FF99Herb|r + |cFFFFD700Mine|r - Colores GOD activos")
        elseif herb then
            print("|cFF00FF99[NaerzRadar]|r Cargado - Solo Herboristeria - Sonar VERDE")
        elseif mine then
            print("|cFFFFD700[NaerzRadar]|r Cargado - Solo Mineria - Sonar DORADO")
        else
            print("|cFFFF0000[NaerzRadar]|r Sin profesion - Aprende Herb o Mine")
        end
        print("|cFFAAAAAAComandos: /nr test herb | /nr test mine | /nr on/off|r")
    end
end)

local elapsedTotal=0
frame:SetScript("OnUpdate",function(self, elapsed)
    elapsedTotal=elapsedTotal+elapsed
    if elapsedTotal < 1 then return end
    elapsedTotal=0

    local tracking=nil
    for i=1,40 do
        local buff=UnitBuff("player",i)
        if buff then
            local bl=buff:lower()
            if bl:find("herb") or bl:find("hierba") or bl:find("herbs") then tracking="herb" break end
            if bl:find("mine") or bl:find("mena") or bl:find("miner") then tracking="mine" break end
        end
    end

    if not tracking then
        if HasHerb() then tracking="herb"
        elseif HasMine() then tracking="mine"
        end
    end

    if not tracking then return end

    if math.random() < 0.15 then
        DoPing(tracking)
    end
end)

SLASH_NAERZRADAR1="/nr"
SLASH_NAERZRADAR2="/naerzradar"
SlashCmdList["NAERZRADAR"]=function(msg)
    msg=(msg or ""):lower():trim()
    if msg=="on" then NaerzRadarDB.enabled=true print("[NaerzRadar] ON")
    elseif msg=="off" then NaerzRadarDB.enabled=false print("[NaerzRadar] OFF")
    elseif msg=="test herb" then DoPing("herb")
    elseif msg=="test mine" then DoPing("mine")
    elseif msg=="test" then DoPing(HasMine() and "mine" or "herb")
    elseif msg=="prof" then print("Herb:"..tostring(HasHerb()).." Mine:"..tostring(HasMine()))
    else
        print("|cFF00FF99NaerzRadar:|r")
        print("/nr test herb - Sonar VERDE")
        print("/nr test mine - Sonar DORADO")
        print("/nr on/off - Activar/Desactivar")
        print("/nr prof - Ver profesiones")
    end
end
