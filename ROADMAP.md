# Roadmap

Hitos por fases, tal como los define el dossier de aprendizaje. Cada fase tiene un
objetivo de Godot explícito — no se pasa a la siguiente sin que la anterior esté
jugable/probada. Las fases 4 y 5 son opcionales: las fases 0-3 ya cubren el aprendizaje
necesario para atacar el primer prototipo digital de SPQR.

Leyenda: `[ ]` pendiente · `[~]` en curso · `[x]` completado

**Checkpoint actual (2026-07-22):** Fase 6 completa — deploy en Vercel, público en
https://rock-paper-scissor-godot.vercel.app (proyecto `rock-paper-scissor`). itch.io se
descartó a propósito (ver detalle en esa fase). De paso se encontró y corrigió un bug
real: varios iconos (mapa, botones de combate) usaban glifos Unicode que dependen del
font fallback del sistema operativo y se rompían en el export Web — sustituidos por
caracteres ASCII simples. Antes de eso, Fase 5 completa. El enemigo ya no es un roll
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
- [~] **CI/CD (GitHub Actions → Vercel) — bloqueado por un bug de Vercel, no nuestro.**
      `.github/workflows/deploy.yml` existe (export con `firebelley/godot-export` +
      `vercel deploy --prod --token=...`) pero su trigger de `push` está desactivado a
      propósito: todo deploy autenticado con el token de la API (como hace el Action)
      responde con un 404 real en todos sus alias, mientras el mismo comando exacto
      corrido a mano desde una sesión logueada (`vercel --prod -y`) funciona al
      instante. Se comparó identidad de cuenta, ajustes del proyecto, protección de
      deployment y conteo de archivos entre un deploy roto y uno bueno — todo idéntico.
      El deploy manual sigue siendo el camino fiable; el workflow solo se dispara con
      `workflow_dispatch` y **hay que verificar con `curl` la URL real, no solo el
      check verde de la Action**, antes de fiarse de un run. Reactivar el trigger de
      `push` solo si esto se resuelve (o se confirma como bug conocido de Vercel).
      Se probaron 7 vías distintas (versión de CLI, receta oficial `--prebuilt`,
      builder explícito `@vercel/static`, `package.json` mínimo, y la action mantenida
      `amondnet/vercel-action`) — mismo 404 en todas. También se descartó
      "Trusted Sources"/OIDC: leyendo la documentación oficial resulta que es para que
      un servicio externo *lea* un deployment ya protegido (tests e2e contra un
      preview), no para autenticar la *creación* del deploy — no aplica a este bug.
      Único camino que queda: ticket a soporte de Vercel.

## Infraestructura (fuera de las fases del dossier)

- [x] Godot 4.7 instalado
- [x] `gh` CLI instalado y autenticado
- [x] Repositorio en GitHub (público, `main`)
- [x] `CLAUDE.md` con convenciones de desarrollo
