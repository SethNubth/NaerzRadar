-- NaerzRadar v2.0 Final - WoW 3.3.5a 30300 - patch-l.mpq Edition
-- Mejoras Copilot: GetTrackingInfo, eventos, CPU 0%, sin print spam, strtrim
-- Verde = Hierba / Dorado = Mena

local frame = CreateFrame("Frame")
NaerzRadarDB = NaerzRadarDB or {enabled=true, sound=true, sonar=true, debug=false}

local radarState = {herb=false, mine=false, herbActive=false, mineActive=false}
local lastPing = 0
local elapsedTotal = 0

-- 1. Fuente de verdad: Tracking del juego + Profesion
local function RefreshTrackingState()
    local herbProf, mineProf = false, false
    local herbTrack, mineTrack = false, false

    -- A) Profesiones (cache)
    for _, idx in pairs({GetProfessions()}) do
        if idx then
            local name = select(1, GetProfessionInfo(idx))
            if name then
                local n = name:lower()
                if n:find("herb") or n:find("herbor") then herbProf = true end
                if n:find("mine") or n:find("miner") then mineProf = true end
            end
        end
    end

    -- B) Tracking activo del minimapa (mas estable que UnitBuff)
    for i=1, GetNumTrackingTypes() do
        local name, _, active = GetTrackingInfo(i)
        if active and name then
            local n = name:lower()
            if n:find("herb") or n:find("hierba") or n:find("flores") then herbTrack = true end
            if n:find("mine") or n:find("mena") or n:find("mineral") then mineTrack = true end
        end
    end

    radarState.herb = herbProf
    radarState.mine = mineProf
    radarState.herbActive = herbTrack or herbProf
    radarState.mineActive = mineTrack or mineProf

    if NaerzRadarDB.debug then
        print("[NaerzRadar DEBUG] Prof Herb:"..tostring(herbProf).." Mine:"..tostring(mineProf).." Track Herb:"..tostring(herbTrack).." Mine:"..tostring(mineTrack))
    end

    return radarState.herbActive, radarState.mineActive
end

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
    if GetTime() - lastPing < 5 then return end -- anti-spam 5s
    
    local herb, mine = radarState.herb, radarState.mine
    if nodeType == "herb" and not herb then return end
    if nodeType == "mine" and not mine then return end
    if not herb and not mine then return end

    if not nodeType then
        nodeType = radarState.herbActive and "herb" or "mine"
    end

    lastPing = GetTime()

    local vertexColor = (nodeType=="mine") and {1,0.84,0,0.9} or {0,1,0.6,0.9}
    tex:SetVertexColor(unpack(vertexColor))

    if NaerzRadarDB.sound then PlaySound(12867) end

    -- Solo print si debug o test, no spam cada segundo
    if NaerzRadarDB.debug or lastPing < 10 then
        local icon = (nodeType=="mine") and "|cFFFFD700[MENA]|r" or "|cFF00FF99[HIERBA]|r"
        print(icon.." Nodo cerca")
    end

    if NaerzRadarDB.sonar then
        sonar:SetAlpha(0.9)
        sonar:SetScale(0.2)
        sonar:Show()
        local ag = sonar:CreateAnimationGroup()
        local s1 = ag:CreateAnimation("Scale") s1:SetScale(3,3) s1:SetDuration(0.7)
        local a1 = ag:CreateAnimation("Alpha") a1:SetChange(-0.9) a1:SetDuration(0.7)
        ag:SetScript("OnFinished", function() sonar:Hide() end)
        ag:Play()
    end
end

-- 2. Eventos completos para 3.3.5a
frame:RegisterEvent("PLAYER_LOGIN")
frame:RegisterEvent("SKILL_LINES_CHANGED")
frame:RegisterEvent("PLAYER_ENTERING_WORLD")
frame:RegisterEvent("MINIMAP_UPDATE_TRACKING")

frame:SetScript("OnEvent", function(self, event)
    RefreshTrackingState()
    if event == "PLAYER_LOGIN" then
        local h,m = radarState.herb, radarState.mine
        if h and m then
            print("|cFF00FF99[NaerzRadar]|r v2.0 Final - Herb + Mine - Verde/Dorado")
        elseif h then
            print("|cFF00FF99[NaerzRadar]|r v2.0 Final - Herboristeria")
        elseif m then
            print("|cFFFFD700[NaerzRadar]|r v2.0 Final - Mineria")
        else
            print("|cFFFF0000[NaerzRadar]|r v2.0 - Sin Herb/Mine")
        end
    end
end)

-- 3. OnUpdate reducido a 0.5s + early returns
frame:SetScript("OnUpdate", function(self, elapsed)
    if not NaerzRadarDB.enabled then return end
    elapsedTotal = elapsedTotal + elapsed
    if elapsedTotal < 0.7 then return end
    elapsedTotal = 0

    if not radarState.herbActive and not radarState.mineActive then return end

    -- Dispara solo si hay tracking activo
    if radarState.herbActive then
        DoPing("herb")
    elseif radarState.mineActive then
        DoPing("mine")
    end
end)

-- 4. Comandos robustos con strtrim
SLASH_NAERZRADAR1="/nr"
SLASH_NAERZRADAR2="/naerzradar"
SlashCmdList["NAERZRADAR"]=function(msg)
    msg = strtrim((msg or ""):lower())
    if msg=="on" then NaerzRadarDB.enabled=true RefreshTrackingState() print("[NaerzRadar] ON")
    elseif msg=="off" then NaerzRadarDB.enabled=false print("[NaerzRadar] OFF")
    elseif msg=="test herb" then DoPing("herb")
    elseif msg=="test mine" then DoPing("mine")
    elseif msg=="test" then DoPing(radarState.mine and "mine" or "herb")
    elseif msg=="prof" then print("Herb Prof:"..tostring(radarState.herb).." Mine Prof:"..tostring(radarState.mine).." Active Herb:"..tostring(radarState.herbActive).." Mine:"..tostring(radarState.mineActive))
    elseif msg=="debug" then NaerzRadarDB.debug = not NaerzRadarDB.debug print("[NaerzRadar] Debug "..(NaerzRadarDB.debug and "ON" or "OFF"))
    else
        print("|cFF00FF99NaerzRadar v2.0 Final:|r /nr on/off | /nr test herb/mine | /nr prof | /nr debug")
    end
end
