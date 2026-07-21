# Roadmap

Hitos por fases, tal como los define el dossier de aprendizaje. Cada fase tiene un
objetivo de Godot explícito — no se pasa a la siguiente sin que la anterior esté
jugable/probada. Las fases 4 y 5 son opcionales: las fases 0-3 ya cubren el aprendizaje
necesario para atacar el primer prototipo digital de SPQR.

Leyenda: `[ ]` pendiente · `[~]` en curso · `[x]` completado

**Checkpoint actual (2026-07-21):** Fase 5 completa (export HTML5 de la Fase 1 sigue
pendiente por falta de templates, ver detalle en esa fase). El enemigo ya no es un roll
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
- [ ] Primer build exportable a HTML5 para verificación visual — bloqueado: no hay
      export templates de Godot instalados localmente todavía

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

## Infraestructura (fuera de las fases del dossier)

- [x] Godot 4.7 instalado
- [x] `gh` CLI instalado y autenticado
- [x] Repositorio en GitHub (público, `main`)
- [x] `CLAUDE.md` con convenciones de desarrollo
- [ ] Despliegue del build HTML5 en Vercel (a partir de que exista un build de la Fase 1)
