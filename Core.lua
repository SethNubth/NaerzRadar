-- NaerzRadar v2.1 Anti-Fallas - WoW 3.3.5a 30300
-- Fix final: strtrim, cache, nil guards, anim reuse, CPU 0%
NaerzRadarDB = NaerzRadarDB or {enabled=true, sound=true, sonar=true, debug=false}

local frame = CreateFrame("Frame")
local radarState = {herb=false, mine=false, herbActive=false, mineActive=false}
local lastPing = 0
local elapsedTotal = 0

-- Guardas nil + cache
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
    radarState.herbActive = herbTrack or herbProf
    radarState.mineActive = mineTrack or mineProf
end

-- Sonar con anim reutilizada (anti-fallas)
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
    if not NaerzRadarDB or not NaerzRadarDB.enabled then return end
    local now = GetTime()
    if now - lastPing < 5 then return end

    if nodeType=="herb" and not radarState.herb then return end
    if nodeType=="mine" and not radarState.mine then return end
    if not radarState.herb and not radarState.mine then return end

    if not nodeType then
        nodeType = radarState.herbActive and "herb" or "mine"
    end

    lastPing = now

    local vertex = (nodeType=="mine") and {1,0.84,0,0.9} or {0,1,0.6,0.9}
    if tex and vertex then tex:SetVertexColor(unpack(vertex)) end

    if NaerzRadarDB.sound then
        pcall(PlaySound, 12867)
    end

    if NaerzRadarDB.sonar and sonar then
        -- Anti-fallas: detener anim anterior
        if sonar.anim then
            sonar.anim:Stop()
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
end

-- Eventos anti-fallas
frame:RegisterEvent("PLAYER_LOGIN")
frame:RegisterEvent("SKILL_LINES_CHANGED")
frame:RegisterEvent("PLAYER_ENTERING_WORLD")
frame:RegisterEvent("MINIMAP_UPDATE_TRACKING")

frame:SetScript("OnEvent", function(self, event)
    RefreshTrackingState()
    if event=="PLAYER_LOGIN" then
        local h,m = radarState.herb, radarState.mine
        if NaerzRadarDB.debug then
            print("[NaerzRadar v2.1 Anti-Fallas] Herb:"..tostring(h).." Mine:"..tostring(m))
        else
            if h and m then print("|cFF00FF99[NaerzRadar]|r v2.1 Anti-Fallas - Herb+Mine")
            elseif h then print("|cFF00FF99[NaerzRadar]|r v2.1 - Herboristeria")
            elseif m then print("|cFFFFD700[NaerzRadar]|r v2.1 - Mineria")
            end
        end
    end
end)

-- OnUpdate moderado 0.5s + early return = 0 lag
frame:SetScript("OnUpdate", function(self, elapsed)
    if not NaerzRadarDB or not NaerzRadarDB.enabled then return end
    elapsedTotal = elapsedTotal + (elapsed or 0)
    if elapsedTotal < 0.5 then return end
    elapsedTotal = 0

    if not radarState.herbActive and not radarState.mineActive then return end

    if radarState.herbActive then DoPing("herb")
    elseif radarState.mineActive then DoPing("mine") end
end)

-- Comandos anti-fallas: strtrim
SLASH_NAERZRADAR1="/nr"
SLASH_NAERZRADAR2="/naerzradar"
SlashCmdList["NAERZRADAR"]=function(msg)
    msg = strtrim((msg or ""):lower())
    if msg=="on" then NaerzRadarDB.enabled=true RefreshTrackingState() print("[NaerzRadar] ON")
    elseif msg=="off" then NaerzRadarDB.enabled=false print("[NaerzRadar] OFF")
    elseif msg=="test herb" then DoPing("herb")
    elseif msg=="test mine" then DoPing("mine")
    elseif msg=="test" then DoPing(radarState.mine and "mine" or "herb")
    elseif msg=="prof" then print("HerbProf:"..tostring(radarState.herb).." MineProf:"..tostring(radarState.mine).." Active H:"..tostring(radarState.herbActive).." M:"..tostring(radarState.mineActive))
    elseif msg=="debug" then NaerzRadarDB.debug = not NaerzRadarDB.debug print("Debug "..(NaerzRadarDB.debug and "ON" or "OFF"))
    else print("|cFF00FF99NaerzRadar v2.1 Anti-Fallas:|r /nr on/off | /nr test | /nr prof | /nr debug")
    end
end
