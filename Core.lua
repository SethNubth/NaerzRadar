-- NaerzRadar FINAL - Colores por Profesión - Patch-l Edition
local frame=CreateFrame("Frame") local lastPing=0
NaerzRadarDB=NaerzRadarDB or {enabled=true,sound=true,sonar=true}

local function HasHerb() 
    for _,i in pairs({GetProfessions()}) do if i then 
        local n=select(1,GetProfessionInfo(i)) 
        if n and (n:lower():find("herb") or n:lower():find("herbor")) then return true end 
    end end return false 
end
local function HasMine() 
    for _,i in pairs({GetProfessions()}) do if i then 
        local n=select(1,GetProfessionInfo(i)) 
        if n and (n:lower():find("mine") or n:lower():find("miner")) then return true end 
    end end return false 
end

-- SONAR con colores
local sonar=CreateFrame("Frame","NaerzRadarSonar",UIParent) 
sonar:SetSize(220,220) sonar:SetPoint("CENTER") sonar:Hide()
local tex=sonar:CreateTexture(nil,"OVERLAY") tex:SetAllPoints() 
tex:SetTexture("Interface\\Cooldown\\ping4") 
tex:SetBlendMode("ADD")

local function DoPing(t)
    if GetTime()-lastPing<4 then return end
    if not NaerzRadarDB.enabled then return end
    lastPing=GetTime()
    
    local h=HasHerb() local m=HasMine()
    if t=="herb" and not h then return end
    if t=="mine" and not m then return end

    -- COLORES GOD
    local color, texColor, icon
    if t=="mine" then
        color="|cFFFFD700" -- ORO
        texColor={1,0.84,0,0.9} -- RGB Dorado
        icon="[MENA ⛏️]"
    else
        color="|cFF00FF99" -- VERDE Forever
        texColor={0,1,0.6,0.9} -- RGB Verde
        icon="[HIERBA 🌿]"
    end

    tex:SetVertexColor(unpack(texColor))

    if NaerzRadarDB.sound then 
        PlaySound(12867) -- MAP_PING
        PlaySound(8959)  -- SONAR
    end

    print(color.."[NaerzRadar] "..icon.." ¡Nodo cerca!|r")
    
    if NaerzRadarDB.sonar then
        sonar:SetAlpha(0.9) sonar:SetScale(0.2) sonar:Show()
        local ag=sonar:CreateAnimationGroup()
        local s1=ag:CreateAnimation("Scale") s1:SetScale(3,3) s1:SetDuration(0.7)
        local a1=ag:CreateAnimation("Alpha") a1:SetChange(-0.9) a1:SetDuration(0.7)
        ag:SetScript("OnFinished",function() sonar:Hide() end)
        ag:Play()
    end
end

frame:RegisterEvent("PLAYER_LOGIN")
frame:SetScript("OnEvent",function()
    local h=HasHerb() local m=HasMine()
    if h and m then print("|cFF00FF99[NaerzRadar]|r |cFF00FF99Herb|r + |cFFFFD700Mine|r detectado - Colores activos")
    elseif h then print("|cFF00FF99[NaerzRadar]|r Solo Herboristeria - Sonar |cFF00FF99VERDE|r")
    elseif m then print("|cFFFFD700[NaerzRadar]|r Solo Mineria - Sonar |cFFFFD700DORADO|r")
    end
end)

local el=0
frame:SetScript("OnUpdate",function(_,e)
    el=el+e if el<1 then return end el=0
    local t=nil
    for i=1,40 do local b=UnitBuff("player",i) if b then local bl=b:lower() if bl:find("herb") or bl:find("hierba") then t="herb" break end if bl:find("mine") or bl:find("mena") or bl:find("miner") then t="mine" break end end end
    if not t then if HasHerb() then t="herb" elseif HasMine() then t="mine" end end
    if t and math.random()<0.15 then DoPing(t) end
end)

SLASH_NAERZRADAR1="/nr" SlashCmdList["NAERZRADAR"]=function(msg)
    msg=(msg or ""):lower()
    if msg=="test herb" then DoPing("herb")
    elseif msg=="test mine" then DoPing("mine")
    elseif msg=="test" then DoPing(HasMine() and "mine" or "herb")
    elseif msg=="on" then NaerzRadarDB.enabled=true
    elseif msg=="off" then NaerzRadarDB.enabled=false
    else print("|cFF00FF99/nr test herb|r - Probar verde |cFFFFD700/nr test mine|r - Probar dorado") end
end
