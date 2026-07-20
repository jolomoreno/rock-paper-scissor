# Rock Paper Scissor — guía de desarrollo en Godot

Este archivo se carga automáticamente en cualquier sesión de Claude Code abierta en este
repo, en cualquier máquina. Es la referencia de convenciones para todo el código Godot
de este proyecto — léelo antes de escribir o revisar GDScript aquí.

## Qué es este proyecto

Banco de pruebas de aprendizaje de Godot 4 ("PPT Roguelite"), documentado en
`0-documentation/PPT_Roguelite_Dossier_Aprendizaje_Godot.pdf` (no versionado, solo local).
Criterio de diseño: **todo sistema que se construya aquí debe transferir a SPQR: Punic
Wars**; si no transfiere, se corta. Fases de desarrollo: 0 (motor de resolución PPT sin
UI) → 1 (combate con UI mínima) → 2 (persistencia) → 3 (mapa de nodos) → 4-5 (opcional:
RPSLS, IA).

Motor: **Godot 4.7 (stable)**, GDScript (sin C#/.NET). Export objetivo: HTML5/WASM
sin threads, para servir como estático en Vercel sin cabeceras COOP/COEP especiales.

## Estructura de carpetas

Godot no impone estructura, pero para que el proyecto no se convierta en una carpeta
plana ingobernable:

```
res://
├── autoloads/       # Scripts de singletons (ver sección Autoloads)
├── scenes/
│   ├── main/         # Punto de entrada, hub
│   ├── combat/        # Escenas de combate
│   └── map/           # Mapa de nodos de la run
├── scripts/          # Scripts sueltos que no son dueños de una escena (helpers, class_name)
└── resources/        # .tres/.res compartidos (datos de enemigos, cartas, etc.)
```

Agrupa los assets lo más cerca posible de la escena que los usa en vez de separarlos
todos por tipo — más mantenible a medida que crece el proyecto.
[Godot Docs — Project organization](https://docs.godotengine.org/en/stable/tutorials/best_practices/project_organization.html)

## Convenciones de nombres

| Elemento | Estilo | Ejemplo |
|---|---|---|
| Archivos y carpetas | `snake_case` | `combat_manager.gd` |
| Nodos en el árbol de escena | `PascalCase` | `HealthBar`, `EnemySlot` |
| Clases (`class_name`) | `PascalCase` | `class_name CombatResolver` |
| Funciones y variables | `snake_case` | `resolve_round()`, `player_hp` |
| Constantes | `CONSTANT_CASE` | `MAX_ROUNDS` |
| Señales | `snake_case`, en pasado | `round_resolved`, `run_ended` |
| Miembros privados | prefijo `_` | `_internal_state`, `_recalculate()` |
| Enums | tipo en `PascalCase`, miembros en `CONSTANT_CASE` | `enum Choice { ROCK, PAPER, SCISSORS }` |

Usa siempre minúsculas y `snake_case` en nombres de archivo — Windows/macOS son
case-insensitive por defecto pero Linux no, y el `.pck` de exportación de Godot sí es
case-sensitive: un desajuste de mayúsculas funciona en desarrollo y rompe en la build
exportada.
[GDScript style guide](https://docs.godotengine.org/en/stable/tutorials/scripting/gdscript/gdscript_styleguide.html)

## Tipado estático

Usa tipos siempre que el valor se conozca en tiempo de escritura: `var hp: int = 10`,
`func resolve_round(a: Choice, b: Choice) -> int:`. No es opcional-opcional en este
proyecto — es la versión GDScript de la "política de cero automatismos" del dossier de
SPQR: si el tipo está declarado, Godot te avisa en el editor antes de que el bug llegue
a ejecutarse, en vez de descubrirlo jugando. Activa en el editor
`Text Editor > Completion > Add Type Hints` para que autocomplete ya proponga tipos.
[Godot Docs — Static typing in GDScript](https://docs.godotengine.org/en/stable/tutorials/scripting/gdscript/static_typing.html)

## Referenciar nodos sin rutas frágiles

- Evita `get_node("UI/HUD/HealthBar")`: si mueves un nodo en el editor, rompe en
  silencio.
- Para nodos internos de tu propia escena: márcalos como **Scene Unique Name** (icono %
  en el editor) y accede con `%HealthBar`. Godot cachea la referencia, así que también
  es más rápido que buscar por ruta.
- Para nodos que se resuelven una vez al cargar la escena: variable `@onready` al
  principio del script, no dentro de una función.
- Los unique names solo resuelven dentro de la misma escena — si necesitas cruzar a otra
  escena, eso es exactamente el caso para una señal, no para una ruta.
[Godot Docs — Scene Unique Nodes](https://docs.godotengine.org/en/stable/tutorials/scripting/scene_unique_nodes.html)

## Datos: `Resource` personalizados en vez de diccionarios sueltos

Cuando un dato tiene forma fija y se repite (un enemigo, un patrón de IA, una carta de
equipo el día que lleguemos a esa fase), defínelo como una clase que extiende
`Resource` con `class_name`, no como un `Dictionary` armado a mano. Un `Dictionary`
no avisa si le falta una clave o si el tipo cambia; un `Resource` tipado sí, y además se
edita desde el inspector del editor como un asset (`.tres`) versionable en texto.
Ejemplo de la forma, no del contenido final:

```gdscript
class_name EnemyPattern
extends Resource

@export var display_name: String
@export var hp: int
@export var move_weights: Dictionary  # Choice -> float
```

[Godot Docs — Data preferences](https://docs.godotengine.org/en/stable/tutorials/best_practices/data_preferences.html)

## Persistencia (Fase 2 — la Chispa entre sesiones)

- Los datos de partida van en **`user://`**, nunca en `res://`. `res://` es el propio
  proyecto/build — en una build exportada es de solo lectura, así que escribir ahí no
  falla en el editor pero sí falla (en silencio, si no compruebas el resultado) en el
  juego exportado. `user://` es la carpeta de datos de usuario del sistema operativo,
  pensada exactamente para esto.
- Para algo tan simple como un par de enteros (Chispa acumulada, mejoras desbloqueadas),
  lo más directo es `FileAccess` + `JSON.stringify()` / `JSON.parse_string()`. No hace
  falta `ConfigFile` (pensado más para ajustes tipo opciones de usuario) ni serialización
  binaria (pensada para árboles de objetos complejos) a esta escala.
- Comprueba siempre que `FileAccess.open()` no devuelve `null` antes de usarlo — si el
  archivo no existe todavía (primera vez que se abre el juego), es un caso normal, no un
  error.
[Godot Docs — Saving games](https://docs.godotengine.org/en/stable/tutorials/io/saving_games.html)

## Aleatoriedad determinista

Para la resolución de rondas y los patrones de IA (Fase 5), usa una instancia propia de
`RandomNumberGenerator` en vez de las funciones globales `randi()`/`randf()` — así puedes
fijarle una semilla (`rng.seed = 12345`) y conseguir la misma secuencia de tiradas en
cada ejecución. Esto es lo que te permite escribir un test tipo "con esta semilla, el
motor de resolución debe dar X" sin depender de verdadera aleatoriedad. Si más adelante
separas la aleatoriedad de combate de otra (p. ej. de qué enemigo toca en el mapa), usa
una instancia de `RandomNumberGenerator` distinta para cada una — así cambiar una no
descoloca la otra.
[Godot Docs — Random number generation](https://docs.godotengine.org/en/stable/tutorials/math/random_number_generation.html)

## Entrada del jugador

Aunque el grueso de la interacción va a ser clicar botones de la UI (que ya llega
resuelto por las señales `pressed` de `Button`), define cualquier atajo de teclado como
**acción en el Input Map** (Project Settings → Input Map) y compruébalo con
`Input.is_action_pressed("nombre_accion")` — nunca compares contra una tecla concreta
(`KEY_SPACE`) directamente en el código. Así, si más adelante quieres remapear teclas o
añadir mando, cambias la acción en un sitio y no en cada script que la usa.
[Godot Docs — InputMap](https://docs.godotengine.org/en/stable/classes/class_inputmap.html)

## Interfaz de combate (Fase 1) — Containers, no posición absoluta

Para la barra de vida y los botones de acción, usa nodos `Container`
(`HBoxContainer`/`VBoxContainer`/`GridContainer`) en vez de fijar `position` a mano en
cada `Control`. Un contenedor se encarga de colocar y redimensionar a sus hijos por ti —
en cuanto metes un Container, deja de tener sentido mover manualmente a sus hijos desde
el editor (el contenedor lo sobreescribe). Para algo puntual y simple como centrar la
barra de vida sola, los anchors bastan; en cuanto haya más de dos o tres elementos
relacionados (los botones de acción del HUD de combate), un Container ahorra tener que
recalcular posiciones a mano cada vez que cambia algo.
[Godot Docs — Using Containers](https://docs.godotengine.org/en/stable/tutorials/ui/gui_containers.html)

## Un par de hábitos de rendimiento/orden que cuestan poco y evitan sorpresas

- Configura las propiedades de un nodo **antes** de añadirlo al árbol (`add_child()`),
  no después — los setters de propiedades pueden disparar trabajo extra una vez el nodo
  ya está dentro del árbol, y en generación procedural (el mapa de nodos, la Fase 3) eso
  se nota.
- Usa `preload()` para lo que sabes que vas a necesitar sí o sí (escenas de enemigo, la
  UI de combate); reserva `load()` para lo que depende de una condición en tiempo de
  ejecución.
[Godot Docs — Logic preferences](https://docs.godotengine.org/en/stable/tutorials/best_practices/logic_preferences.html)

## Probar sin abrir el editor

La Fase 0 del dossier es deliberadamente "prints en consola, sin UI" — puedes ejecutarla
sin ni siquiera abrir la ventana del editor:

```bash
/Applications/Godot.app/Contents/MacOS/Godot --headless --path . -s res://scripts/main.gd
```

`--headless` desactiva ventana y audio; útil también más adelante si montamos algo de
integración continua. Si en algún momento queremos tests de verdad en vez de asserts a
ojo en consola, la opción estándar de la comunidad es el addon **GUT** (Godot Unit
Test), ejecutable también en modo headless — no hace falta para la Fase 0, es una nota
para cuando el motor de resolución crezca lo suficiente como para que merezca la pena.
[Godot Docs — Command line tutorial](https://docs.godotengine.org/en/stable/tutorials/editor/command_line_tutorial.html)

## Formato de código

El editor de Godot ya aplica gran parte de esto automáticamente:

- Tabulaciones para indentar, no espacios.
- Máx. ~100 caracteres por línea (80 si vas a comparar diffs lado a lado).
- Comillas dobles por defecto; simples solo para evitar escapar comillas dentro de un string.
- `and` / `or` / `not` en vez de `&&` / `||` / `!`.
- Un `blank line` dentro de funciones para separar bloques lógicos; dos entre funciones.
- Orden dentro de un script: anotaciones (`@tool`) → `class_name`/`extends` → señales →
  enums → constantes → `@export` → variables → `@onready` → `_init()` → `_ready()` →
  resto de callbacks virtuales → métodos públicos → métodos privados.

## Arquitectura: decisiones que ya tomamos aquí

**Autoloads (singletons) — solo para estado verdaderamente global.**
Úsalos para lo que persiste entre escenas y no tiene sentido como nodo del árbol: la
"Chispa" (moneda permanente) y su guardado/carga son candidatos claros a partir de la
Fase 2. No los uses como cajón de sastre para lógica que en realidad pertenece a una
escena concreta — eso genera acoplamiento invisible.
[Godot Docs — Autoloads vs regular nodes](https://docs.godotengine.org/en/stable/tutorials/best_practices/autoloads_versus_internal_nodes.html)

**Escenas sin dependencias externas duras.**
Cada escena (el combate, un nodo del mapa) debe poder probarse sola. Si necesita algo
de fuera, pásaselo por fuera (una variable exportada, un método de inicialización, una
señal) en vez de que la escena busque un `NodePath` fijo hacia arriba del árbol. Esto es
justo lo que necesitamos para poder reusar la escena de combate contra distintos
enemigos/patrones de IA sin tocar su código interno.
[Godot Docs — Scene organization](https://docs.godotengine.org/en/stable/tutorials/best_practices/scene_organization.html)

**Señales para comunicar hacia arriba/afuera, llamadas directas hacia abajo/adentro.**
Un nodo hijo no debe conocer a su padre ni buscarlo — emite una señal y que quien esté
interesado se conecte. La llamada directa (`$Nodo.metodo()`) es aceptable cuando un nodo
controla directamente a algo que posee (p. ej. el gestor de combate controlando la
barra de vida). La máquina de estados de turno (Fase Jugador → Resolución → Fase
Enemigos) es la candidata natural a modelarse con señales de cambio de estado.

Conecta señales **por código** (`signal.connect(callback)` en `_ready()`), no arrastrando
en el editor — una conexión hecha en el editor vive en el `.tscn` y no se ve en un diff
de git ni al leer el script; una conexión por código se ve en la revisión del código
exactamente donde se declara.

Tipa los parámetros de tus señales igual que los de una función:
`signal round_resolved(winner: int)`.

**Máquina de estados de turno.** Con solo 3 estados (Fase Jugador → Resolución → Fase
Enemigos) no hace falta el patrón "un nodo/escena por estado" que verás recomendado para
FSMs grandes (útil cuando cada estado tiene mucho comportamiento propio, p. ej. un
personaje con Idle/Run/Jump/Attack). Para esto, un `enum` + `match` dentro del propio
gestor de combate es la complejidad correcta — no te compliques de más:

```gdscript
enum TurnPhase { PLAYER, RESOLUTION, ENEMY }
var current_phase: TurnPhase = TurnPhase.PLAYER

func _set_phase(phase: TurnPhase) -> void:
    current_phase = phase
    phase_changed.emit(phase)
```

Si más adelante (SPQR, no aquí) un estado necesita su propia lógica compleja y transición
condicional, ahí sí vale la pena mirar el patrón de estado-por-objeto.
[Godot Docs — State design pattern](https://docs.godotengine.org/en/stable/tutorials/misc/state_design_pattern.html)

**Formato de escena: texto (`.tscn`), no binario.**
Es el formato por defecto en Godot 4 y el único que da diffs legibles en git — importante
porque vamos a revisar cambios de escena en PRs/commits igual que código.

## Control de versiones

- `.godot/` y las carpetas de export están en `.gitignore` — nunca se versionan
  (son caché regenerable, no fuente de verdad).
- No hace falta Git LFS en este proyecto: sin arte propio (formas geométricas/texto),
  no debería haber binarios pesados. Si en algún momento entra un asset pesado, es señal
  para pararse y reconsiderar antes de commitearlo directamente.
- `0-documentation/` no se versiona (decisión explícita: son dossiers de referencia
  local, no parte del repo público de portfolio).
- Mensajes de commit: en inglés, imperativo, describiendo el qué+por qué — es un repo
  público pensado para portfolio.
[Godot Docs — Version control systems](https://docs.godotengine.org/en/stable/tutorials/best_practices/version_control_systems.html)

## Qué NO hacer en este proyecto

Recordatorio del dossier de aprendizaje — si algo de esto aparece, es una señal de que
nos estamos desviando del objetivo de aprendizaje:

- Arte propio, música o sonido elaborado.
- Sistemas decorativos que no estén en la hoja de ruta de fases (0-5).
- Balanceo numérico fino — usa cifras de prueba y sigue adelante.
- Una tercera moneda, un árbol de habilidades ramificado, más de un personaje jugable.
