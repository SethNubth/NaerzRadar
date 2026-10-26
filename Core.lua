-- NaerzRadar v2.2 Anti-Fallas Estable - WoW 3.3.5a 30300
-- Final: strtrim, nil guards, anim reuse + nil, pcall, ZONE_CHANGED

-- SavedVariables limpio (local + global persistente)
local NaerzRadarDB = NaerzRadarDB or {enabled=true, sound=true, sonar=true, debug=false}
_G.NaerzRadarDB = NaerzRadarDB

local frame = CreateFrame("Frame")
local radarState = {herb=false, mine=false, herbActive=false, mineActive=false}
local lastPing = 0
local elapsedTotal = 0

local function RefreshTrackingState()
    local herbProf, mineProf = false, false
    local herbTrack, mineTrack = false, false

    local profs = {GetProfessions()}
    if profs then
        for _, idx in pairs(profs) do
            if idx then
                local name = select(1, GetProfessionInfo(idx))
                if name and type(name)=="string" then
                    local n = name:lower()
                    if n:find("herb") or n:find("herbor") then herbProf = true end
                    if n:find("mine") or n:find("miner") then mineProf = true end
                end
            end
        end
    end

    if GetNumTrackingTypes then
        for i=1, GetNumTrackingTypes() do
            local name, _, active = GetTrackingInfo(i)
            if active and name and type(name)=="string" then
                local n = name:lower()
                if n:find("herb") or n:find("hierba") then herbTrack = true end
                if n:find("mine") or n:find("mena") then mineTrack = true end
            end
        end
    end

    radarState.herb = herbProf
    radarState.mine = mineProf
    -- prioridad 1 tracking, prioridad 2 profesion
    radarState.herbActive = herbTrack or herbProf
    radarState.mineActive = mineTrack or mineProf
end

-- Sonar + textura con guardas anti-fallas
local sonar = CreateFrame("Frame","NaerzRadarSonar",UIParent)
sonar:SetSize(220,220)
sonar:SetPoint("CENTER",0,0)
sonar:Hide()
sonar.anim = nil

local tex = sonar:CreateTexture(nil,"OVERLAY")
tex:SetAllPoints()
tex:SetTexture("Interface\\Cooldown\\ping4")
tex:SetBlendMode("ADD")

local function DoPing(nodeType)
    if not sonar or not tex then return end
    if not NaerzRadarDB or not NaerzRadarDB.enabled then return end
    if GetTime() - lastPing < 5 then return end

    if nodeType=="herb" and not radarState.herb then return end
    if nodeType=="mine" and not radarState.mine then return end
    if not radarState.herb and not radarState.mine then return end
    if not radarState.herbActive and not radarState.mineActive then return end

    if not nodeType then
        nodeType = radarState.herbActive and "herb" or "mine"
    end

    lastPing = GetTime()

    local vertex = (nodeType=="mine") and {1,0.84,0,0.9} or {0,1,0.6,0.9}
    tex:SetVertexColor(unpack(vertex))

    if NaerzRadarDB.sound then pcall(PlaySound, 12867) end

    -- Anti-fallas extra: Stop + nil
    if sonar.anim then
        sonar.anim:Stop()
        sonar.anim = nil
    end

    sonar:SetAlpha(0.9)
    sonar:SetScale(0.2)
    sonar:Show()
    local ag = sonar:CreateAnimationGroup()
    local s1 = ag:CreateAnimation("Scale") s1:SetScale(3,3) s1:SetDuration(0.7)
    local a1 = ag:CreateAnimation("Alpha") a1:SetChange(-0.9) a1:SetDuration(0.7)
    ag:SetScript("OnFinished", function() if sonar then sonar:Hide() end end)
    sonar.anim = ag
    ag:Play()
end

-- Eventos completos + ZONE_CHANGED
frame:RegisterEvent("PLAYER_LOGIN")
frame:RegisterEvent("SKILL_LINES_CHANGED")
frame:RegisterEvent("PLAYER_ENTERING_WORLD")
frame:RegisterEvent("MINIMAP_UPDATE_TRACKING")
frame:RegisterEvent("ZONE_CHANGED")
frame:RegisterEvent("ZONE_CHANGED_NEW_AREA")

frame:SetScript("OnEvent", function(self, event)
    RefreshTrackingState()
    if event=="PLAYER_LOGIN" and not NaerzRadarDB.debug then
        local h,m = radarState.herb, radarState.mine
        if h and m then print("|cFF00FF99[NaerzRadar]|r v2.2 Estable - Herb+Mine")
        elseif h then print("|cFF00FF99[NaerzRadar]|r v2.2 - Herboristeria")
        elseif m then print("|cFFFFD700[NaerzRadar]|r v2.2 - Mineria")
        end
    end
end)

-- OnUpdate 0.5s anti-lag
frame:SetScript("OnUpdate", function(self, elapsed)
    if not NaerzRadarDB.enabled then return end
    elapsedTotal = elapsedTotal + (elapsed or 0)
    if elapsedTotal < 0.5 then return end
    elapsedTotal = 0
    if not radarState.herbActive and not radarState.mineActive then return end
    if radarState.herbActive then DoPing("herb")
    elseif radarState.mineActive then DoPing("mine") end
end)

-- Comandos con strtrim
SLASH_NAERZRADAR1="/nr"
SLASH_NAERZRADAR2="/naerzradar"
SlashCmdList["NAERZRADAR"]=function(msg)
    msg = strtrim((msg or ""):lower())
    if msg=="on" then NaerzRadarDB.enabled=true RefreshTrackingState() print("[NaerzRadar] ON")
    elseif msg=="off" then NaerzRadarDB.enabled=false print("[NaerzRadar] OFF")
    elseif msg=="test herb" then DoPing("herb")
    elseif msg=="test mine" then DoPing("mine")
    elseif msg=="test" then DoPing(radarState.mine and "mine" or "herb")
    elseif msg=="prof" then print("Herb:"..tostring(radarState.herb).." Mine:"..tostring(radarState.mine).." Active H:"..tostring(radarState.herbActive).." M:"..tostring(radarState.mineActive))
    elseif msg=="debug" then NaerzRadarDB.debug = not NaerzRadarDB.debug print("Debug "..(NaerzRadarDB.debug and "ON" or "OFF"))
    else print("|cFF00FF99NaerzRadar v2.2 Estable:|r /nr on/off | /nr test | /nr prof | /nr debug")
    end
end
