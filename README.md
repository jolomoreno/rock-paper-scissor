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

Con las 6 fases del dossier de aprendizaje y el deploy ya cerrados, el proyecto entró en
una fase extra sin numerar en el dossier original: probar aquí, uno a uno, mecánicas del
diseño cerrado de SPQR: Punic Wars que este ejercicio todavía no había tocado (ver
"Fase 7" en [ROADMAP.md](ROADMAP.md) para la lista completa y el orden). El primer punto,
un sistema de Puntos de Acción (PA), ya está construido: en combate, cada turno da hasta
3 PA para repartir entre Atacar (los 5 botones RPSLS) y Bloquear, sin resolver nada al
pulsar — las acciones se encolan y se muestran en pantalla, y el turno entero se resuelve
de una vez (al agotar el PA o al pulsar "Terminar turno") comparando esa cola, en orden,
contra una única jugada del enemigo. Quedó anotado a propósito, sin resolver todavía, un
desequilibrio real: con una sola unidad enemiga, el jugador puede intentar hasta 3 veces
por 1 del enemigo.

El segundo punto de esa lista, un escuadrón de reclutas, también está construido — con
alcance reducido a propósito: en vez de los 3 huecos seleccionables de SPQR (que
necesitan economía de Oro y un nodo de Tienda que no existen todavía aquí), hay 1 recluta
fijo (Hastatus) siempre presente en combate, con una pasiva (+1 de daño en cualquier
ataque que gane, tuyo o suyo) y una acción "Carga" que compite por el mismo PA que tus
propios ataques. Esto forzó a que el daño infligido al enemigo dejara de ser un `-1`
fijo y pasara a calcularse — la pieza que le faltaba al sistema de PA para que una
pasiva tuviera algo real que modificar.

El tercer punto, un árbol de habilidades con dependencia lineal, sustituyó la lista
plana de 2 mejoras sueltas del Hub por 2 ramas de 4 nodos cada una (Vigor y Botín),
donde cada nodo exige tener comprado el anterior de su misma rama
(`Chispa.is_dependency_met()`). Sin árbol radial visual — para 8 nodos de prueba habría
sido decoración — pero el Hub explica en el propio botón si algo está bloqueado por
precio o por dependencia, y qué nodo falta.

Antes de eso, Fase 6 completa (última del roadmap, deploy incluido): el enemigo ya no juega con un
roll uniforme puro.
`scripts/enemy_pattern.gd` define un `Resource` `EnemyPattern` con 3 instancias en
`resources/enemy_patterns/` — Aleatorio, Telegráfico (anuncia su jugada en pantalla antes
de que el jugador elija) y Reactivo (contraataca la última jugada del jugador) — y
`scripts/enemy_ai.gd` decide la jugada según el patrón activo. El Jefe siempre usa
Reactivo; cualquier otro combate sortea entre Aleatorio y Telegráfico. Verificado por
consola en `--headless` y confirmado visualmente en el editor.

El mapa de nodos también recibió la visualización de pathing que había quedado pendiente
de la Fase 3: `RunState.path_history` registra capa + tipo de nodo elegido en cada
decisión, y `scenes/map/map.tscn`/`map.gd` dibujan las 4 capas a la vez como nodos
circulares — el camino recorrido en dorado y conectado con una línea, un marcador sobre
la capa actual, capas futuras atenuadas, y una franja compacta (`path_strip.tscn`) con el
mismo resumen arriba de Combate y Descanso.

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
por consola en `--headless` y confirmado visualmente en el editor. Fase 6 (deploy)
completa: build HTML5 público en https://rock-paper-scissor-godot.vercel.app. Ver
[ROADMAP.md](ROADMAP.md) para el desglose completo de fases.

## Stack técnico

- **Motor:** Godot 4.7 (stable), GDScript — sin C#/.NET.
- **Export objetivo:** HTML5/WASM sin threads, servido como sitio estático en Vercel
  (https://rock-paper-scissor-godot.vercel.app) como pieza de portfolio.
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
