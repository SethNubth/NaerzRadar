-- NaerzRadar v1.1 Clean - WoW 3.3.5a (30300) - patch-l.mpq 158kB Edition
-- Fixes: strtrim, cache profs, SKILL_LINES_CHANGED, CPU opt
-- Verde = Hierba / Dorado = Mena

local frame = CreateFrame("Frame")
local lastPing = 0
NaerzRadarDB = NaerzRadarDB or {enabled=true, sound=true, sonar=true}

-- Cache de profesiones - se actualiza solo en eventos
local radarState = {herb=false, mine=false}

local function RefreshProfessions()
    local herb, mine = false, false
    local profs = {GetProfessions()}
    for _, idx in pairs(profs) do
        if idx then
            local name = GetProfessionInfo(idx)
            if name then
                local lower = name:lower()
                if lower:find("herb") or lower:find("herbor") then herb = true end
                if lower:find("mine") or lower:find("miner") then mine = true end
            end
        end
    end
    radarState.herb = herb
    radarState.mine = mine
    return herb, mine
end

local function HasHerb() return radarState.herb end
local function HasMine() return radarState.mine end

-- Sonar
local sonar = CreateFrame("Frame","NaerzRadarSonar",UIParent)
sonar:SetSize(220,220)
sonar:SetPoint("CENTER",0,0)
sonar:Hide()
local tex = sonar:CreateTexture(nil,"OVERLAY")
tex:SetAllPoints()
tex:SetTexture("Interface\\Cooldown\\ping4")
tex:SetBlendMode("ADD")

local function DoPing(nodeType)
    if not NaerzRadarDB.enabled then return end
    if GetTime() - lastPing < 4 then return end
    
    -- Usa cache, no GetProfessions() cada vez
    local herb = HasHerb()
    local mine = HasMine()
    
    if nodeType == "herb" and not herb then return end
    if nodeType == "mine" and not mine then return end
    
    if not nodeType then
        if not herb and not mine then return end
        nodeType = herb and "herb" or "mine"
    end

    lastPing = GetTime()

    local color, vertexColor, icon
    if nodeType == "mine" then
        color = "|cFFFFD700"
        vertexColor = {1,0.84,0,0.9}
        icon = "[MENA]"
    else
        color = "|cFF00FF99"
        vertexColor = {0,1,0.6,0.9}
        icon = "[HIERBA]"
    end

    tex:SetVertexColor(unpack(vertexColor))

    if NaerzRadarDB.sound then
        PlaySound(12867)
    end

    local profText = ""
    if herb and mine then profText = "Herb + Mine"
    elseif herb then profText = "Herboristeria"
    elseif mine then profText = "Mineria"
    end

    print(color.."[NaerzRadar] "..icon.." ¡Nodo cerca! |r|cFFAAAAAA("..profText..")|r")

    if NaerzRadarDB.sonar then
        sonar:SetAlpha(0.9)
        sonar:SetScale(0.2)
        sonar:Show()
        local ag = sonar:CreateAnimationGroup()
        local s1 = ag:CreateAnimation("Scale")
        s1:SetScale(3,3)
        s1:SetDuration(0.7)
        local a1 = ag:CreateAnimation("Alpha")
        a1:SetChange(-0.9)
        a1:SetDuration(0.7)
        ag:SetScript("OnFinished", function() sonar:Hide() end)
        ag:Play()
    end
end

-- Eventos: LOGIN + cambio de profesion
frame:RegisterEvent("PLAYER_LOGIN")
frame:RegisterEvent("SKILL_LINES_CHANGED")
local elapsedTotal = 0

frame:SetScript("OnEvent", function(self, event)
    if event == "PLAYER_LOGIN" or event == "SKILL_LINES_CHANGED" then
        local herb, mine = RefreshProfessions()
        if event == "PLAYER_LOGIN" then
            if herb and mine then
                print("|cFF00FF99[NaerzRadar]|r v1.1 Clean - |cFF00FF99Herb|r + |cFFFFD700Mine|r")
            elseif herb then
                print("|cFF00FF99[NaerzRadar]|r v1.1 Clean - Solo Herboristeria (VERDE)")
            elseif mine then
                print("|cFFFFD700[NaerzRadar]|r v1.1 Clean - Solo Mineria (DORADO)")
            else
                print("|cFFFF0000[NaerzRadar]|r v1.1 - Sin profesion Herb/Mine")
            end
            print("|cFFAAAAAA/nr test herb | /nr test mine | /nr on/off|r")
        end
    end
end)

-- OnUpdate optimizado - sale rapido si disabled
frame:SetScript("OnUpdate", function(self, elapsed)
    if not NaerzRadarDB.enabled then return end
    
    elapsedTotal = elapsedTotal + elapsed
    if elapsedTotal < 1 then return end
    elapsedTotal = 0

    -- Solo mira tracking si hay profesion
    if not HasHerb() and not HasMine() then return end

    local tracking = nil
    for i=1,40 do
        local buff = UnitBuff("player",i)
        if buff then
            local bl = buff:lower()
            if bl:find("herb") or bl:find("hierba") or bl:find("herbs") then tracking="herb" break end
            if bl:find("mine") or bl:find("mena") or bl:find("miner") then tracking="mine" break end
        end
    end

    if not tracking then
        if HasHerb() then tracking="herb"
        elseif HasMine() then tracking="mine"
        end
    end

    if tracking then
        DoPing(tracking)
    end
end)

-- Comandos FIX: strtrim en lugar de :trim()
SLASH_NAERZRADAR1="/nr"
SLASH_NAERZRADAR2="/naerzradar"
SlashCmdList["NAERZRADAR"]=function(msg)
    msg = strtrim((msg or ""):lower())
    if msg=="on" then NaerzRadarDB.enabled=true print("[NaerzRadar] ON")
    elseif msg=="off" then NaerzRadarDB.enabled=false print("[NaerzRadar] OFF")
    elseif msg=="test herb" then DoPing("herb")
    elseif msg=="test mine" then DoPing("mine")
    elseif msg=="test" then DoPing(HasMine() and "mine" or "herb")
    elseif msg=="prof" then print("Herb:"..tostring(HasHerb()).." Mine:"..tostring(HasMine()))
    else
        print("|cFF00FF99NaerzRadar v1.1 Clean:|r")
        print("/nr test herb - Sonar VERDE")
        print("/nr test mine - Sonar DORADO")
        print("/nr on/off - Activar/Desactivar")
        print("/nr prof - Ver profesiones cacheadas")
    end
end
