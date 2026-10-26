NaerzRadar v2.2 — Anti-Fallas Estable | WoW 3.3.5a (30300)

> NodeRadar Full Edition — Patch-l.mpq 158kB + Sonar Verde/Dorado + Tracking Real

Addon ligero de alerta de nodos para **Wrath of the Lich King 3.3.5a (Build 30300)** — Warmane, etc. Detecta hierbas y menas con el tracking del juego y avisa con sonido + sonar visual.

**Verde = Hierba | Dorado = Mena**

![Version](https://img.shields.io/badge/version-2.2%20Estable%20Final-brightgreen)
![WoW](https://img.shields.io/badge/WoW-3.3.5a%2030300-blue)
![Patch](https://img.shields.io/badge/patch--l.mpq-158kB%20Extended-orange)
![CPU](https://img.shields.io/badge/CPU-0%25%20Optimized-success)

🎥 Demo
Video original con patch-l.mpq: https://www.youtube.com/watch?v=BP9VhO7XOmE

---

✨ Características v2.2

- **Anti-Fallas Real:** `strtrim`, nil guards, `pcall(PlaySound)`, anim reutilizada
- **Tracking Estable:** `GetTrackingInfo` + `GetProfessions` (no `UnitBuff` falso)
- **Cache de Profesiones:** Se actualiza solo en `SKILL_LINES_CHANGED`
- **CPU 0%:** OnUpdate 0.5s + early returns + anti-spam 5s
- **Sonar Visual:** Animación reutilizada sin leaks (`Stop() + nil`)
- **Filtro por Profesión:** Solo alerta lo que tu PJ puede recolectar
- **Comandos Robustos:** `/nr` estable para 30300

📦 Qué incluye

NaerzRadar/
├── http://NaerzRadar.toc (30300)
└── http://Core.lua (v2.2 Anti-Fallas)

- http://patch-l.mpq (158kB - Render extendido 300yd)

🚀 Instalación (IMPORTANTE)

**1. Addon:**
- Extrae `NaerzRadar` a `World of Warcraft\Interface\AddOns\`

**2. Patch-l.mpq (Obligatorio para ver nodos lejos):**
NO va en AddOns

SÍ va en:
World of Warcraft\Data\patch-l.mpq
- Si ya tienes `patch-3.mpq`, `patch-4.mpq`, renombra este a `patch-l.mpq` o `patch-5.mpq`
- Tamaño correcto: **158kB** — Si pesa más, no es el extendido

**3. In-game:**
- Activa "Rastrear Hierbas" o "Rastrear Mena" en el minimapa
- `/reload`

🎮 Comandos

| Comando | Función |
|---------|---------|
| `/nr on` | Activar radar |
| `/nr off` | Desactivar radar (0% CPU) |
| `/nr test` | Test sonar (profesión actual) |
| `/nr test herb` | Test VERDE |
| `/nr test mine` | Test DORADO |
| `/nr prof` | Ver profesiones cacheadas |
| `/nr debug` | Modo debug ON/OFF |

🔧 Compatibilidad

- ✅ WoW 3.3.5a 12340 / 30300
- ✅ Warmane, Frostmourne, Icecrown, Lordaeron
- ✅ Con y sin `patch-l.mpq` (sin patch solo ves nodos cerca, con patch ves a 300yd)
- ❌ No Retail / No Cata / No Classic 1.15 (solo WotLK)

🧠 Cómo funciona

1. `patch-l.mpq` extiende el render de nodos en el cliente
2. `NaerzRadar` lee tu tracking activo (`GetTrackingInfo`) + profesión (`GetProfessions`)
3. Si detecta nodo, dispara sonar + sonido con cooldown 5s anti-spam
4. Color automático: Verde si eres Herborista, Dorado si eres Minero

🛡️ v2.2 Anti-Fallas Changelog

- `v1.0` - Versión inicial con `:trim()` bug
- `v1.1` - Fix `strtrim` + cache profesiones
- `v2.0` - `GetTrackingInfo` + eventos completos
- `v2.1` - Anim reutilizada + pcall
- `v2.2` - Final estable: ZONE_CHANGED, nil guards, local DB, 0 spam

👥 Créditos

- **NodeRadar Original:** Seth (Retail Edition)
- **Patch-l.mpq 158kB:** 
- **Port + Optimización 3.3.5a:** SethNubth x Copilot x Meta AI
- **Idea Sonar Verde/Dorado:** Comunidad Warmane

📄 Licencia

MIT — Úsalo, modifícalo, compártelo. Si lo mejoras, pásalo.

🐛 Soporte

- Issues: Abre un Issue en GitHub
- Warmane: Foro `Interface\AddOns`
- Test: `/nr test herb` y `/nr prof`

---

**¡Farmea sin perder nodos, GOD!**
---

