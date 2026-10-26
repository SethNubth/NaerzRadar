
Changelog - NaerzRadar

All notable changes to this project will be documented here.
Formato basado en Keep a Changelog - WoW 3.3.5a Edition.

---

[0.1.0] - Origen - 2026-05-10
Inicial
- Idea base: Port de NodeRadar (Seth) Retail → WotLK 3.3.5a
- Problema: Nodos de herb/mine no se renderizan lejos en cliente 3.3.5a vanilla
- Solución encontrada: `patch-l.mpq` 158kB Extended Render (Forever @ Warmane)
- Primer test: Sonido funciona, visual no sin patch

Bugs conocidos
- `patch-l.mpq` mal instalado en `Interface\AddOns` (debe ir en `Data\`)
- Sin detección de profesiones

---

[1.0.0] - Primera versión pública
Añadido
- Frame sonar básico con `CreateTexture`
- Sonido `PlaySound(12867)`
- Detección por `UnitBuff("player", i)` para herb/mine
- Comando `/nr on/off`

Bugs Críticos
- ❌ `msg:trim()` → No existe en Lua 5.1 / WoW 3.3.5a → `/nr` no respondía
- ❌ `OnUpdate` cada frame → 40 buffs check + `HasHerb()` + `HasMine()` + `math.random()` → Lag / CPU alto
- ❌ `CreateAnimationGroup()` nuevo en cada ping → Memory leak + anims acumuladas
- ❌ Sin nil guards en `GetProfessionInfo(idx)`

---

[1.1.0] - Fix Copilot #1 - Anti Crash
Corregido (Crítico)
- ✅ `msg:trim()` → `strtrim((msg or ""):lower())` - Fix 30300
- ✅ Añadido `if name then` guard en `GetProfessionInfo`
- ✅ `NaerzRadarDB = NaerzRadarDB or {}` con defaults

Mejora
- Comando `/nr prof` para debug
- Print de estado al login

Pendiente
- OnUpdate aún pesado
- Detección por buffs inestable (falsos positivos)

---

[2.0.0] - Refactor Tracking Real - Recomendación Copilot v2
Cambiado (Arquitectura)
- ❌ Eliminado `UnitBuff("player")` → Falsos positivos
- ✅ Nuevo `RefreshTrackingState()` con 2 fuentes de verdad:
    - Prioridad 1: `GetTrackingInfo(i)` - Tracking real del minimapa
    - Prioridad 2: `GetProfessions()` + `GetProfessionInfo()` - Profesión del PJ
- ✅ `GetNumTrackingTypes()` loop para detectar "herb/hierba" y "mine/mena"

Optimizado
- ✅ `OnUpdate` de cada frame → 0.7s con `elapsedTotal` + early returns
- ✅ `DoPing` con cooldown `GetTime() - lastPing < 5` anti-spam
- ✅ Sin `math.random()` agresivo
- ✅ Sin `print` spam cada segundo, solo en login y `/nr prof`

Añadido
- Eventos: `PLAYER_LOGIN`, `SKILL_LINES_CHANGED`, `PLAYER_ENTERING_WORLD`, `MINIMAP_UPDATE_TRACKING`
- Soporte ES: "hierba", "herbor", "mena", "mineral"
- Color dinámico: Verde Hierba / Dorado Mena
- `NaerzRadar.toc` Interface: 30300

---

[2.1.0] - Anti-Fallas - Animación + pcall
Corregido
- ✅ Animación: `sonar.anim` ahora reutilizable
- ✅ `if sonar.anim then sonar.anim:Stop() end` antes de crear nueva
- ✅ `pcall(PlaySound, 12867)` - Resistente a fallos de entorno
- ✅ Guardas `if not NaerzRadarDB or not NaerzRadarDB.enabled` en todo

Optimizado
- ✅ `OnUpdate` 0.5s mínimo (no menor a 0.4s)
- ✅ `DoPing` valida `radarState.herb/mine` antes de sonar
- ✅ `type(name)=="string"` check extra

Técnico
- Estructura `radarState = {herb, mine, herbActive, mineActive}` separada

---

[2.2.0] - ESTABLE FINAL - v2.2 Anti-Fallas Estable
Corregido (Definitivo)
- ✅ Animación extra segura: `Stop() + nil`
  ```lua
  if sonar.anim then
    sonar.anim:Stop()
    sonar.anim = nil
  end
- ✅ Textura/frame guard: `if not sonar or not tex then return end`
- ✅ SavedVariables limpio: `local DB = DB or {} + _G.DB = DB` (sin conflicto global)
- ✅ `debug=false` por defecto, 0 print spam en producción

Añadido
- ✅ Eventos zona: `ZONE_CHANGED` + `ZONE_CHANGED_NEW_AREA` para estabilidad al cambiar mapa
- ✅ Changelog y README PRO 2026
- ✅ Nota instalación `patch-l.mpq` clara: `Data\` no `AddOns`

Estado
- 🟢 No crash reportado en 3.3.5a
- 🟢 CPU 0% cuando OFF o sin profesión
- 🟢 Compatible Warmane Icecrown/Lordaeron/Frostmourne
- 🟢 Listo para Release

Instalación Final
World of Warcraft\Data\patch-l.mpq (158kB)
World of Warcraft\Interface\AddOns\NaerzRadar\
Comandos Finales
- `/nr on/off` - Toggle
- `/nr test / test herb / test mine` - Test visual
- `/nr prof` - Estado cache
- `/nr debug` - Debug opcional

---

- v2.3 Ideas (No prioritario)
- [ ] Slider distancia en opciones
- [ ] Icono minimapa LDB
- [ ] Filtro solo raras (Titanio, Loto)
- [ ] Sonido custom por tipo de nodo
- [ ] Versión Retail 11.0 port[Futuro]

---

*Créditos:* NodeRadar SethNubth → → Port Naerz x Copilot x Meta AI
*Video Demo:* https://www.youtube.com/watch?v=BP9VhO7XOmE
