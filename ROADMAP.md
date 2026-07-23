# Roadmap

Hitos por fases, tal como los define el dossier de aprendizaje. Cada fase tiene un
objetivo de Godot explícito — no se pasa a la siguiente sin que la anterior esté
jugable/probada. Las fases 4 y 5 son opcionales: las fases 0-3 ya cubren el aprendizaje
necesario para atacar el primer prototipo digital de SPQR.

Leyenda: `[ ]` pendiente · `[~]` en curso · `[x]` completado

**Checkpoint actual (2026-07-23):** Fase 7, puntos 1 (Puntos de Acción), 2 (Escuadrón de
reclutas) y 3 (Árbol de habilidades) completos — ver detalle en esa sección. Antes de
eso, Fase 6 completa, incluido CI/CD — cada push a
`main` exporta con Godot y despliega a Vercel automáticamente
(https://rock-paper-scissor-godot.vercel.app, proyecto `rock-paper-scissor`). itch.io se
descartó a propósito (ver detalle en esa fase). De paso se encontraron y corrigieron dos
bugs reales: varios iconos (mapa, botones de combate) usaban glifos Unicode que dependen
del font fallback del sistema operativo y se rompían en el export Web — sustituidos por
caracteres ASCII simples; y la action de export anidaba el build en una subcarpeta
extra, haciendo que todo deploy por CI diera 404 (ver Fase 6 para el detalle — costó
horas de depuración por comparar mal contra deploys manuales que nunca pasaban por la
misma action). Antes de eso, Fase 5 completa. El enemigo ya no es un roll
uniforme puro: `scripts/enemy_pattern.gd` define un `Resource` `EnemyPattern`
(`display_name` + `pattern_type`) con 3 instancias en `resources/enemy_patterns/`
(Aleatorio, Telegráfico, Reactivo), y `scripts/enemy_ai.gd` decide la jugada del enemigo
según el patrón activo. El Jefe siempre usa Reactivo (contraataca la última jugada del
jugador); cualquier otro combate sortea entre Aleatorio y Telegráfico (este último anuncia
su jugada en pantalla antes de que el jugador elija, vía la nueva etiqueta
`%EnemyIntentLabel` en `combat.tscn`). Verificado por consola en `--headless` (patrón
Reactivo siempre contraataca, Telegráfico no re-rollea tras anunciar) y confirmado
visualmente por el usuario en el editor.

Además, el mapa de nodos (Fase 3) recibió la visualización de pathing que había quedado
pendiente de una sesión anterior: `RunState` ahora guarda `path_history` (capa + tipo de
nodo elegido en cada una), y `map.tscn`/`map.gd` muestran las 4 capas a la vez como
círculos — el camino recorrido resaltado en dorado y conectado con una línea, un marcador
▼ sobre la capa actual, capas futuras atenuadas (el Jefe en un tono distinto), y una
leyenda de colores. Una franja compacta (`scenes/map/path_strip.tscn`) con el mismo
camino resumido se añadió arriba de las pantallas de Combate y Descanso. También se
añadió una sección `[display]` a `project.godot` (ventana de depuración más grande +
`stretch mode` "canvas_items"/"expand") para que la ventana de juego no se vea diminuta
en pantallas grandes, y para dejar el proyecto listo de cara al export HTML5 pendiente.

De paso, en Fase 4 se pulieron tres cosas de UX descubiertas al probar: el mapa
(`RunState`) ya no deja encadenar solo nodos de Descanso hasta el Jefe — la capa 1 nunca
ofrece Descanso, no se puede Descansar dos capas seguidas, y no se ofrece si la vida
supera el 85% del máximo; las barras de vida de jugador y enemigo muestran ahora el
porcentaje; y la mejora de Chispa "Vida extra" se renombró a "Vida máxima +1" con
etiqueta "(ya comprada)" en vez de un "✓" poco visible, para dejar claro que es +1 HP
máximo de una sola vez, no una vida de repuesto.

Autoload `RunState` (`autoloads/run_state.gd`) gestiona la run en curso (capa actual,
tipo de nodo elegido, HP del jugador que se traslada entre combates). Hub
(`scenes/main/hub.tscn`) con compra de mejoras y botón "Empezar Run"; mapa
(`scenes/map/map.tscn`) de 4 capas (3 de Combate/Descanso ramificadas + Jefe final)
construido dinámicamente desde `RunState.available_node_types()`; nodo de Descanso
(`scenes/map/descanso.tscn`) que cura al máximo. `combat_manager.gd` navega él mismo al
terminar el combate (mapa si gana y quedan capas, Hub si gana el Jefe o si pierde),
leyendo/escribiendo `RunState` para el HP y para saber si el enemigo es el Jefe. Bucle
completo verificado por consola en `--headless` y confirmado visualmente por el usuario
en el editor. Siguiente hito: pulir el export HTML5 pendiente (ver Infraestructura).

## Fase 0 — Motor de resolución (sin UI)

Objetivo Godot: estructurar un proyecto desde cero, scripts, señales básicas.

- [x] Crear el proyecto Godot y la estructura de carpetas
- [x] Script de resolución de una ronda PPT (piedra/papel/tijera), tipado
- [x] Probado por consola en modo `--headless`, sin abrir ventana

## Fase 1 — Combate jugable con UI mínima

Objetivo Godot: Control nodes, máquina de estados de turno.

- [x] Escena de combate: barra de vida compartida + botones de acción
- [x] Máquina de estados: Fase Jugador → Resolución → Fase Enemigos
- [x] Enemigo con vida propia; combate dura varias rondas hasta llegar a 0
- [x] Verificación visual en el editor (F5) — confirmada por el usuario (2026-07-20)
- [x] Primer build exportable a HTML5 para verificación visual — hecho en la Fase 6
      (2026-07-22), templates instalados y build desplegado en Vercel

## Fase 2 — Persistencia entre sesiones

Objetivo Godot: `FileAccess`/JSON, Autoload para datos persistentes.

- [x] Autoload de la moneda permanente ("Chispa")
- [x] Guardado/carga en `user://` entre ejecuciones
- [x] Un puñado de mejoras fijas compradas con la moneda permanente

## Fase 3 — Mapa de nodos + hub

Objetivo Godot: gestión de escenas, transición entre pantallas.

- [x] Mapa lineal/ligeramente ramificado (5-8 nodos: Combate/Descanso/Jefe)
- [x] Hub con acceso a las mejoras compradas
- [x] Bucle completo: hub → run → combate(s) → fin de run → vuelta al hub

## Fase 4 — Extensión a 5 elementos (opcional)

Objetivo Godot: resolución de matriz de contras — transferencia directa al pentagrama
RPSLS de SPQR.

- [x] Ampliar el motor de resolución a piedra-papel-tijera-lagarto-Spock

## Fase 5 — Patrones de IA enemiga (opcional)

Objetivo Godot: nociones de comportamiento/IA simple.

- [x] Patrón aleatorio
- [x] Patrón telegráfico (anuncia su jugada)
- [x] Patrón reactivo (responde a tu última jugada)

## Fase 6 — Deploy (Vercel)

No es una fase del dossier original (0-5), pero es justo el tipo de infraestructura que
debe transferir directo a SPQR: validar aquí el pipeline completo de export/deploy con
un proyecto pequeño, antes de necesitarlo con uno grande.

- [x] Instalar los export templates de Godot 4.7.1 que faltan (descargados e instalados
      en `~/Library/Application Support/Godot/export_templates/4.7.1.stable/`)
- [x] Crear preset de export "Web" en `export_presets.cfg`, variante **sin Threads**
      (`variant/thread_support=false`) — imprescindible para poder servirlo como
      estático en Vercel sin cabeceras COOP/COEP especiales
- [x] Exportar build HTML5 de la escena de combate a `export/web/` (ignorado en git,
      build regenerable)
- [x] Verificar el build localmente sirviéndolo con `python3 -m http.server` antes de
      subirlo — abrirlo directo con `file://` falla por CORS/WASM
- [x] Deploy a Vercel (`vercel --prod` desde `export/web/`) — público en
      **https://rock-paper-scissor-godot.vercel.app**, proyecto `rock-paper-scissor` en la
      cuenta de Vercel
- [x] Confirmado visualmente en producción (Vercel) que el build carga y el combate es
      jugable
- [x] Bug encontrado y corregido en el proceso: los iconos del mapa y de los botones de
      combate usaban glifos Unicode fuera de ASCII (`♥ ★ ▼ ● ○ ■ ▲ ◆`) que dependen del
      *font fallback* del sistema operativo — funcionan en el editor pero se rompen en
      el export Web (sin ese fallback, se ven como caja+código hex). Sustituidos por
      caracteres ASCII simples en `map.gd`, `path_strip.gd`, `map.tscn` y `combat.tscn`.
      Lección para SPQR: cualquier icono como texto debe limitarse a lo que cubre la
      fuente por defecto de Godot, o requiere una fuente propia embebida con fallback.
- [x] **itch.io descartado** (2026-07-22): decisión consciente del usuario — el
      pipeline de export/deploy (la parte que de verdad transfiere a SPQR) ya quedó
      validado con Vercel; duplicar el deploy en itch.io solo para completar la casilla
      no aportaba aprendizaje adicional relevante para un proyecto de prueba. Si SPQR
      alguna vez se publica en itch.io, el ajuste de viewport dentro de su iframe (ver
      `project.godot [display]`) es la única pieza no validada aquí.
- [x] **CI/CD (GitHub Actions → Vercel) — funcionando.** `.github/workflows/deploy.yml`
      exporta con `firebelley/godot-export` y despliega con `vercel deploy --prod` en
      cada push a `main`. La causa real de todos los 404 anteriores: la action
      `firebelley/godot-export` copia el export dentro de una carpeta con el nombre del
      preset (`export/web/Web/`, mayúscula, porque el preset se llama "Web" en
      `export_presets.cfg`) en vez de aplanarlo en `export/web/` — Vercel servía bien,
      pero `index.html` estaba un nivel más adentro de lo esperado y todo devolvía 404.
      Nunca fue un bug de Vercel (el ticket de soporte se abrió sin necesidad, aunque su
      IA sí encontró la pista correcta comparando el manifiesto de archivos del
      deployment). El fix: un paso que localiza dinámicamente dónde quedó `index.html`
      con `find` en vez de asumir la ruta, así no depende de que el comportamiento de
      copia de la action coincida con lo esperado. **Lección grande:** todas las
      comparaciones "funciona a mano pero no en CI" durante horas de depuración estaban
      mal planteadas — los deploys manuales nunca pasaron por esta action (exportaba
      con Godot directo en local), así que nunca reproducían de verdad lo que hacía CI.
      Antes de sospechar de un servicio externo, comparar el *contenido real subido*
      (`vercel inspect --files` o la API `/v13/deployments/{id}/files`), no solo
      metadata/config — se podría haber encontrado esto en minutos, no horas.

## Fase 7 — Mecánicas de SPQR a prototipar (opcional, pendiente)

No es una fase del dossier de aprendizaje original (0-5) — es la lista de mecánicas del
diseño cerrado de **SPQR: Punic Wars**
(`0-documentation/SPQR_Punic_Wars_Dossier_v07_18072026.html`) que este proyecto
todavía no ha probado, decidida en sesión el 2026-07-23. Criterio: transfer-or-cut,
igual que el resto del roadmap. Orden recomendado por dependencia — no por número de
la tabla — porque el sistema de PA (1) es prerrequisito de facto de Escuadrón (2) y
Veterancía (7).

| # | Mecánica | Importancia | Valor de aprendizaje | Tiempo | Nota |
|---|---|---|---|---|---|
| 1 | Puntos de Acción (PA) — hasta 3/turno, combinando acción héroe/recluta/bloquear/objeto | Alta | Alto | Grande | Toca `combat_manager.gd` a fondo; prerrequisito de 2 y 7 |
| 2 | Escuadrón de reclutas (hasta 3 huecos, pasiva + acción cada uno) | Alta | Alto | Grande | Depende de 1. Ver nota de diseño abajo — necesita antes una capa mínima de daño variable |
| 3 | Árbol de habilidades con dependencia lineal (nodo N requiere N-1, por rama) | Media-alta | Medio | Medio | Sustituye la lista plana actual de mejoras de Chispa |
| 4 | Equipo del héroe (3 slots: Arma/Armadura/Accesorio, tier común/legendario) | Media | Medio | Medio | Independiente de las demás |
| 5 | Bonus de daño por atacar tu clase débil (pentagrama RPSLS) | Media | Bajo-medio | Pequeño | Extensión barata del resolver de Fase 4 |
| 6 | Nodos de mapa extra (Élite, Tienda, Reclutamiento) | Media | Bajo-medio | Pequeño | El patrón de tipo de nodo ya lo resuelve `RunState` |
| 7 | Veterancía de reclutas (comprada con Oro, escala pasiva/acción) | Media | Medio | Medio | Bloqueada por 2 |
| 8 | Crítico como valor aparte de las 6 stats | Baja-media | Bajo | Pequeño | Un roll de probabilidad más |
| 9 | Enemigos especiales mapeados sobre una clase existente (heredan matriz) | Baja | Bajo | Pequeño | Ya es el mismo patrón de dato que `EnemyPattern` (Fase 5) |
| 10 | Respec del árbol (reinicio total + reembolso %) | Baja | Bajo | Pequeño | Cola de la lista |

**Nota de diseño — reclutas (punto 2):** hoy `combat_resolver.gd` no tiene
estadísticas — cada ronda ganada resta un HP fijo (`combat_manager.gd`). Antes de que
una pasiva de recluta tenga algo que modificar, hace falta una capa mínima de daño
variable (el daño base deja de ser `1` fijo y pasa a ser una variable). Con eso puesto,
3 pasivas bastan para probar el concepto sin construir las 6 estadísticas de SPQR:
+1 daño en ronda ganada (análogo Ataque/Hastatus), +1 HP máximo (análogo HP/Triario),
% de anular daño en ronda perdida (análogo Esquiva/Eques) — más una acción alternativa
que cuesta 1 PA (depende del punto 1) y compite por el turno contra tu propia tirada,
que es la tensión real que SPQR quiere validar.

- [x] 1. Sistema de Puntos de Acción (PA) — **completo (2026-07-23).** Modelo de cola
      diferida, no resolución instantánea: en Fase Jugador, cada pulsación de
      Atacar/Bloquear gasta 1 PA (hasta 3) y se añade a una cola visible
      (`%QueueLabel`), sin resolver nada todavía. El turno se resuelve de una sola vez —
      al agotar el PA o al pulsar "Terminar turno" (`%EndTurnButton`) — comparando en
      orden cada acción encolada contra una única jugada del enemigo (`_resolve_turn()`
      en `combat_manager.gd`). Bloquear reduce a la mitad (redondeo a favor del
      jugador) el daño de la siguiente pérdida de esa cola; con el daño fijo actual de
      1 HP eso equivale a anularlo por completo hasta que exista daño variable (ver
      punto 2). Nueva etiqueta de fase (`%PhaseLabel`) explícita en cada transición.
      Verificado por consola en `--headless` (cola, PA, fin de turno con cola parcial y
      con cola vacía) y confirmado visualmente por el usuario en el editor.
      **Limitaciones conocidas, aceptadas a propósito para esta primera versión:**
      el enemigo elige una sola jugada por turno mientras el jugador puede encolar
      hasta 3 — con solo 1 unidad enemiga hoy es equivalente a "cada enemigo actúa una
      vez", pero si tienes suerte en la resolución puedes multiplicar el daño hasta x3
      en un turno; encolar Bloquear más de una vez desperdicia PA porque el flag de
      bloqueo no acumula. Ninguna de las dos se resuelve ahora — quedan anotadas para
      revisar cuando el punto 2 (Escuadrón) añada más de una unidad por bando, que es
      cuando este desequilibrio importará de verdad también en SPQR.
- [x] 2. Escuadrón de reclutas — **completo (2026-07-23), alcance reducido a propósito.**
      No los 3 huecos seleccionables de SPQR — eso necesita el nodo de
      Tienda/Reclutamiento (punto 6) y la economía de Oro, que todavía no existen aquí.
      En su lugar, 1 recluta fijo siempre presente (Hastatus, Escudero Íbero) para
      probar el mecanismo en sí: una pasiva (+1 de daño en cualquier ataque que gane su
      ronda, tuyo o del recluta — esto resolvió el prerrequisito de daño variable vía
      `_damage_dealt_on_win()`) y una acción "Carga" que cuesta 1 PA y compite por el
      mismo pool que tus propios ataques, encolando un ataque con Piedra fija (sin RNG
      ni elección de símbolo, a petición explícita del usuario). La cola distingue
      origen ("Carga (Hastatus)" vs. el nombre del símbolo) para que se vea quién actuó.
      Verificado por consola en `--headless` (pasiva aplicada a ambos orígenes de
      ataque, cola distinguiendo recluta/héroe) y confirmado visualmente por el usuario.
      Ampliar a 2-3 reclutas seleccionables queda para cuando el punto 6 (nodos de
      mapa) o el 7 (veterancía) lo requieran de verdad.
- [x] 3. Árbol de habilidades con dependencia lineal — **completo (2026-07-23).**
      Las 2 mejoras planas de antes se convirtieron en 2 ramas de 4 nodos cada una —
      Vigor I-IV (+1 Vida máxima cada uno, coste 5/10/18/30) y Botín I-IV (+1 Chispa
      por combate ganado cada uno, coste 8/14/24/40) — sin árbol radial visual (fuera
      de alcance para 8 nodos de prueba, era decoración). Cada nodo tiene un campo
      `requires` apuntando al nodo previo de su rama en `Chispa.UPGRADES`;
      `can_afford()` exige ahora también `is_dependency_met()`. El Hub
      (`scenes/main/hub.gd`, generado dinámicamente, no tocó el `.tscn`) muestra rama y
      nivel en cada botón y, si está bloqueado por dependencia, qué nodo falta —
      distinto de estar bloqueado solo por precio. Verificado por consola en
      `--headless` (dependencia dentro de una rama, independencia entre las dos ramas,
      rechazo de compra fuera de orden, suma correcta de bonus por rama) — con cuidado
      de hacer backup/restore del `user://savegame.json` real del usuario antes/después
      de las pruebas, para no pisar su partida guardada. Confirmado visualmente por el
      usuario en el editor ("Funciona a la perfección").
- [ ] 4. Equipo del héroe (3 slots, tiers)
- [ ] 5. Bonus de daño por clase débil (RPSLS)
- [ ] 6. Nodos de mapa extra (Élite, Tienda, Reclutamiento)
- [ ] 7. Veterancía de reclutas
- [ ] 8. Crítico como valor aparte
- [ ] 9. Enemigos especiales mapeados sobre clase existente
- [ ] 10. Respec del árbol

## Infraestructura (fuera de las fases del dossier)

- [x] Godot 4.7 instalado
- [x] `gh` CLI instalado y autenticado
- [x] Repositorio en GitHub (público, `main`)
- [x] `CLAUDE.md` con convenciones de desarrollo
