# Roadmap

Hitos por fases, tal como los define el dossier de aprendizaje. Cada fase tiene un
objetivo de Godot explícito — no se pasa a la siguiente sin que la anterior esté
jugable/probada. Las fases 4 y 5 son opcionales: las fases 0-3 ya cubren el aprendizaje
necesario para atacar el primer prototipo digital de SPQR.

Leyenda: `[ ]` pendiente · `[~]` en curso · `[x]` completado

**Checkpoint actual (2026-07-21):** Fase 4 completa (export HTML5 de la Fase 1 sigue
pendiente por falta de templates, ver detalle en esa fase). `combat_resolver.gd` resuelve
las 5 elecciones de RPSLS (piedra-papel-tijera-lagarto-Spock) con una matriz
`Choice -> Array[Choice]` en vez del 1-a-1 de PPT; las 25 combinaciones están cubiertas
por el test headless de `scripts/main.gd`. La escena de combate tiene los 5 botones de
acción y confirmación visual del usuario.

De paso se pulieron tres cosas de UX descubiertas al probar: el mapa (`RunState`) ya no
deja encadenar solo nodos de Descanso hasta el Jefe — la capa 1 nunca ofrece Descanso, no
se puede Descansar dos capas seguidas, y no se ofrece si la vida supera el 85% del
máximo; las barras de vida de jugador y enemigo muestran ahora el porcentaje; y la mejora
de Chispa "Vida extra" se renombró a "Vida máxima +1" con etiqueta "(ya comprada)" en vez
de un "✓" poco visible, para dejar claro que es +1 HP máximo de una sola vez, no una
vida de repuesto.

Autoload `RunState` (`autoloads/run_state.gd`) gestiona la run en curso (capa actual,
tipo de nodo elegido, HP del jugador que se traslada entre combates). Hub
(`scenes/main/hub.tscn`) con compra de mejoras y botón "Empezar Run"; mapa
(`scenes/map/map.tscn`) de 4 capas (3 de Combate/Descanso ramificadas + Jefe final)
construido dinámicamente desde `RunState.available_node_types()`; nodo de Descanso
(`scenes/map/descanso.tscn`) que cura al máximo. `combat_manager.gd` navega él mismo al
terminar el combate (mapa si gana y quedan capas, Hub si gana el Jefe o si pierde),
leyendo/escribiendo `RunState` para el HP y para saber si el enemigo es el Jefe. Bucle
completo verificado por consola en `--headless` y confirmado visualmente por el usuario
en el editor. Siguiente hito: Fase 5 (opcional) o pulir el export HTML5 pendiente.

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

- [ ] Patrón aleatorio
- [ ] Patrón telegráfico (anuncia su jugada)
- [ ] Patrón reactivo (responde a tu última jugada)

## Infraestructura (fuera de las fases del dossier)

- [x] Godot 4.7 instalado
- [x] `gh` CLI instalado y autenticado
- [x] Repositorio en GitHub (público, `main`)
- [x] `CLAUDE.md` con convenciones de desarrollo
- [ ] Despliegue del build HTML5 en Vercel (a partir de que exista un build de la Fase 1)
