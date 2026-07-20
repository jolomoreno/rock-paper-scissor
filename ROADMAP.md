# Roadmap

Hitos por fases, tal como los define el dossier de aprendizaje. Cada fase tiene un
objetivo de Godot explícito — no se pasa a la siguiente sin que la anterior esté
jugable/probada. Las fases 4 y 5 son opcionales: las fases 0-3 ya cubren el aprendizaje
necesario para atacar el primer prototipo digital de SPQR.

Leyenda: `[ ]` pendiente · `[~]` en curso · `[x]` completado

**Checkpoint actual (2026-07-20):** Fase 1 completa (lógica y escena; verificación visual
y export HTML5 pendientes, ver detalle en la fase). Escena de combate jugable con barra
de vida, botones de acción y máquina de estados de turno, verificada por consola en
`--headless`. Siguiente paso: Fase 2 (persistencia entre sesiones).

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

- [ ] Autoload de la moneda permanente ("Chispa")
- [ ] Guardado/carga en `user://` entre ejecuciones
- [ ] Un puñado de mejoras fijas compradas con la moneda permanente

## Fase 3 — Mapa de nodos + hub

Objetivo Godot: gestión de escenas, transición entre pantallas.

- [ ] Mapa lineal/ligeramente ramificado (5-8 nodos: Combate/Descanso/Jefe)
- [ ] Hub con acceso a las mejoras compradas
- [ ] Bucle completo: hub → run → combate(s) → fin de run → vuelta al hub

## Fase 4 — Extensión a 5 elementos (opcional)

Objetivo Godot: resolución de matriz de contras — transferencia directa al pentagrama
RPSLS de SPQR.

- [ ] Ampliar el motor de resolución a piedra-papel-tijera-lagarto-Spock

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
