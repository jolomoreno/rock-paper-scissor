# PPT Roguelite

Un roguelite 1v1 resuelto por rondas de piedra-papel-tijera, con dos monedas (una
permanente entre partidas, otra temporal dentro de cada run) y un mapa de nodos simple.

## Por qué existe este proyecto

No es un juego pensado para publicarse. Es un **ejercicio de aprendizaje de Godot 4**
que sirve de banco de pruebas para [SPQR: Punic Wars](https://github.com/jolomoreno),
un roguelike táctico ambientado en la Segunda Guerra Púnica que está en fase de diseño.
La regla que gobierna todo lo que se construye aquí: **cada sistema debe practicar algo
que luego se necesita en SPQR** — mapa de nodos, dos monedas con vida distinta,
resolución de una matriz de contras, persistencia entre sesiones, IA de enemigos.
Si un sistema no transfiere ese aprendizaje, no se construye, aunque "quedaría bien".

## Estado actual

Fase 5 completa (última del roadmap): el enemigo ya no juega con un roll uniforme puro.
`scripts/enemy_pattern.gd` define un `Resource` `EnemyPattern` con 3 instancias en
`resources/enemy_patterns/` — Aleatorio, Telegráfico (anuncia su jugada en pantalla antes
de que el jugador elija) y Reactivo (contraataca la última jugada del jugador) — y
`scripts/enemy_ai.gd` decide la jugada según el patrón activo. El Jefe siempre usa
Reactivo; cualquier otro combate sortea entre Aleatorio y Telegráfico. Verificado por
consola en `--headless` y confirmado visualmente en el editor.

Fase 4 extendió el motor de resolución (`scripts/combat_resolver.gd`): ya no es solo
piedra-papel-tijera, resuelve las 5 elecciones de RPSLS (+ Lagarto y Spock) con una
matriz de contras `Choice -> Array[Choice]`, probada por las 25 combinaciones en el test
headless. La escena de combate tiene los 5 botones de acción correspondientes.

De paso se pulió la experiencia del mapa y el Hub heredados de la Fase 3: el mapa ya no
permite encadenar solo nodos de Descanso hasta el Jefe (la primera capa nunca ofrece
Descanso, no se puede Descansar dos capas seguidas, y no se ofrece con la vida por
encima del 85%); las barras de vida muestran el porcentaje; y la mejora de Chispa se
renombró de "Vida extra" a "Vida máxima +1" con una etiqueta "(ya comprada)" explícita,
para dejar claro que es +1 HP máximo permanente, no una vida de repuesto.

Autoload `RunState` (`autoloads/run_state.gd`) sostiene el estado de la run en curso
(capa del mapa, HP del jugador entre combates). El Hub (`scenes/main/hub.tscn`, ahora la
escena de arranque) permite comprar las mejoras de la Fase 2 y lanzar una run; el mapa
(`scenes/map/map.tscn`) ofrece 4 capas — 3 de elección Combate/Descanso y una capa final
de Jefe — construidas dinámicamente; el nodo de Descanso (`scenes/map/descanso.tscn`)
cura al máximo. Bucle completo (Hub → Mapa → Combate/Descanso → Jefe → Hub) verificado
por consola en `--headless` y confirmado visualmente en el editor. Pendiente: exportación
HTML5 (bloqueada por falta de export templates instalados localmente). Ver
[ROADMAP.md](ROADMAP.md) para el desglose completo de fases.

## Stack técnico

- **Motor:** Godot 4.7 (stable), GDScript — sin C#/.NET.
- **Export objetivo:** HTML5/WASM sin threads, para poder servirse como sitio estático
  (pensado para desplegarse en Vercel más adelante, como pieza de portfolio).
- **Sin arte propio:** formas geométricas/texto (círculo=piedra, cuadrado=papel,
  triángulo=tijera). Sin música ni sonido elaborado.

## Cómo se desarrolla este repo

Desarrollo asistido por Claude Code: todo el código lo escribe y prueba Claude, con el
autor del repo en el rol de QA/producto — confirmando comportamiento, no escribiendo
GDScript. Las convenciones de código, arquitectura y control de versiones que sigue todo
el proyecto están documentadas en [CLAUDE.md](CLAUDE.md); es lectura obligatoria antes de
tocar cualquier script o escena de este repo, humano o no.

## Estructura del repo

```
.
├── README.md          # Este archivo
├── ROADMAP.md          # Hitos y fases, con estado de cada uno
├── CLAUDE.md            # Guía de desarrollo Godot (arquitectura, estilo, convenciones)
├── LICENSE              # PolyForm Noncommercial 1.0.0
├── project.godot        # Proyecto Godot 4.7
├── autoloads/           # Singletons (Fase 2+)
├── scenes/              # main/ combat/ map/
├── scripts/             # Scripts sueltos (motor de resolución, etc.)
└── resources/           # Datos compartidos (.tres)
```

`0-documentation/` (dossiers de diseño de SPQR y de este ejercicio) existe en local pero
no está versionado — es material de referencia, no parte del repo público.

## Licencia

Este repo es público como pieza de portfolio, pero **no** es de código abierto para
reutilización libre: se distribuye bajo
[PolyForm Noncommercial 1.0.0](LICENSE), que permite ver, estudiar y usar el código con
fines no comerciales, pero prohíbe explícitamente cualquier uso comercial del proyecto o
de sus derivados.
