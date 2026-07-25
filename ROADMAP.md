# Roadmap

Hitos por fases, tal como los define el dossier de aprendizaje. Cada fase tiene un
objetivo de Godot explícito — no se pasa a la siguiente sin que la anterior esté
jugable/probada. Las fases 4 y 5 son opcionales: las fases 0-3 ya cubren el aprendizaje
necesario para atacar el primer prototipo digital de SPQR.

Leyenda: `[ ]` pendiente · `[~]` en curso · `[x]` completado

**Checkpoint actual (2026-07-25):** Fase 7 completa (10/10 puntos) y cerrada. Esta misma
sesión se añadió la **Fase 8**, un backlog sin empezar de mecánicas del dossier de SPQR
que la Fase 7 dejó fuera a propósito (combate multi-enemigo, esquiva, robo de turno,
entre otras — ver esa sección), y una sección final **"Aprendizajes para SPQR"** que
consolida en un solo sitio lo aprendido en todo el proyecto, técnico y de diseño, para
releer antes de arrancar el desarrollo real de SPQR. Ninguna de las dos cosas es código
nuevo — son notas y backlog. Antes de eso: Fase 7 completa, los 10 puntos (Puntos de Acción,
Escuadrón de reclutas, Árbol de habilidades, Equipo del héroe, Bonus de clase débil,
Nodos de mapa extra, Veterancía de reclutas, Crítico, Enemigos especiales, Respec del
árbol) — ver detalle en esa sección. El mapa pasó de 4 a 5 capas para dar sitio a la capa
"Especial" garantizada del punto 9; de paso se corrigió un bug real en la Tienda (la
opción "Ninguno" del desplegable de equipo desequipaba sin devolver el Oro gastado y sin
confirmación). Antes de eso,
Fase 6 completa, incluido CI/CD — cada push a
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

## Fase 7 — Mecánicas de SPQR a prototipar (opcional, completa)

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
      usuario en el editor ("Funciona a la perfección"). **Pulido en el punto 4:** los
      8 botones ya no caben en una columna con todo lo demás en pantalla — se
      reagruparon en 2 filas horizontales (una por rama) con botones pequeños
      (solo el número de nivel, detalle completo en tooltip), y los nodos ya comprados
      se distinguen con un tinte verde (`Button.modulate`, no iconos Unicode — la
      lección de la Fase 6 sobre glifos que rompen en el export Web sigue aplicando).
- [x] 4. Equipo del héroe — **completo (2026-07-23), alcance reducido a propósito.**
      No hay Oro/Tienda/Cofres todavía (punto 6), así que el equipo se elige libre y
      sin coste en el Hub como un "loadout" — no es aún el sistema de obtención real
      de SPQR. 3 slots (Arma/Armadura/Accesorio) × 2 tiers, nuevo `Resource`
      `EquipmentItem` (`class_name`, como `EnemyPattern`) con 6 `.tres` en
      `resources/equipment/`: Gladio veterano (común, +1 daño al ganar) / Falcata de
      Sagunto (legendaria, duplica el daño al ganar — **adaptada del dossier**, que la
      liga a un crítico que no existe todavía, punto 8); Lorica de recluta (común, -1
      daño recibido) / Coraza del general (legendaria, +3 Vida máxima, **sin
      defense_bonus** — un rasgo distinto, no más Defensa, a propósito); Talismán del
      mercader (común, +1 Chispa al ganar) / Reserva de hierro (legendaria, cura 2 HP
      la primera vez que la vida baja del 25% en el combate). `RunState` guarda qué
      hay equipado por slot (persiste entre runs hasta que se cambie en el Hub, no se
      resetea al empezar una — otra simplificación explícita). El Hub tiene 3
      `OptionButton` nuevos; el combate muestra un `%EquipmentLabel` con qué llevas y
      su efecto en texto llano.
      **Bug real encontrado y corregido en esta sesión:** el daño base del enemigo
      era `1` fijo, así que la Lorica de recluta (-1 Defensa) lo anulaba por completo
      solo con equiparla — el jugador se volvía invulnerable sin gastar nada. Subido
      el daño base a `2`; ahora la armadura reduce pero no anula por sí sola, y solo
      llega a 0 si además se gasta PA en Bloquear (sinergia intencional, no bug).
      Verificado por consola en `--headless` para cada bono de cada objeto, incluida
      la Coraza del general confirmando que no reduce daño (`defense_bonus == 0`) —
      con backup/restore del `user://savegame.json` real en cada tanda de pruebas.
      También se comprimió el layout de la pantalla de combate (etiquetas de estado
      agrupadas en un `StatusContainer` con separación mínima, separación general de
      24→12) porque con todas las etiquetas nuevas (Escuadrón, Equipo, Fase) los
      botones de abajo dejaban de caber en pantalla — mismo síntoma que en el Hub.
      Confirmado visualmente por el usuario en el editor.
- [x] 5. Bonus de daño por clase débil (RPSLS) — **completo (2026-07-23).**
      `RunState.weak_class_target` sortea una de las 5 elecciones al empezar la run
      (`start_run()`, con `RandomNumberGenerator` propio en el autoload, no `randi()`
      global) y se mantiene fija durante toda ella. Ganar una ronda contra esa
      elección da +1 de daño extra (`_damage_dealt_on_win()` ahora recibe la jugada
      del enemigo). Se anuncia al empezar cada combate reutilizando `%ResultLabel`
      (vacío hasta la primera ronda) — **sin nodos nuevos en la escena**, a petición
      explícita del usuario tras los cortes de layout de los puntos 3 y 4. Si el
      patrón es Telegráfico, el aviso de intención añade "(clase débil)" cuando
      aplica. Verificado por consola en `--headless` (aleatoriedad entre runs — 5/5
      valores distintos en 20 runs —, fijación dentro de la run, bonus aplicado solo
      contra la elección correcta).
      **Nota de diseño abierta, señalada por el usuario:** en SPQR "tu clase débil" es
      la identidad fija de una unidad enemiga (un Vélite es Vélite todo el combate);
      aquí "clase" se mapeó sobre la tirada RPSLS, una elección libre cada ronda, no
      una identidad. Un agente que optimizara (humano, o una IA no trivial) evitaría
      tirar la clase débil una vez revelada, vaciando el bonus de efecto — arreglarlo
      de verdad exigiría que el enemigo tuviera una clase fija por combate en vez de
      tirar libre cada ronda, que ya no es un cambio pequeño. No rompe nada hoy porque
      `EnemyAI` (Aleatorio/Telegráfico/Reactivo) no tiene lógica que evite nada, pero
      es una pregunta real para cuando se diseñe el combate de SPQR de verdad.
- [x] 6. Nodos de mapa extra (Élite, Tienda, Reclutamiento) — **completo (2026-07-23).**
      `map.gd` asumía exactamente 2 huecos fijos por capa (arriba: Combate/Jefe; abajo:
      siempre Descanso) — se generalizó para que **qué tipo** ocupa cada hueco varíe
      por capa (`_pick_type()`), sin rediseñar la cuadrícula. Nuevo reparto de las 4
      capas: Combate/Reclutamiento → Élite/Descanso → Combate/Tienda → Jefe. Iconos
      ASCII nuevos (E, $, R — nada de Unicode, lección de la Fase 6).
      **Élite:** reutiliza `combat.tscn` sin contenido nuevo — más HP
      (`ELITE_ENEMY_HP=4`), patrón Reactivo (antes solo el Jefe) y +2 Chispa extra al
      ganar.
      **Tienda:** escena nueva, cambia de equipo gratis a mitad de run (sin Oro).
      **Reclutamiento:** escena nueva — el héroe **empieza sin recluta** (fiel al
      dossier: "cada run empieza siempre con el héroe solo"), y esta es la única
      oportunidad de la run para conseguir uno. Elegir entre Hastatus (ya existía) o
      **Triario** (nuevo: pasiva +1 Vida máxima, acción "Última Línea" cura 1 HP por
      1 PA) fija `RunState.recruit_id` para el resto de la run.
      **Refactor necesario:** los datos de recluta, antes consts sueltas en
      `combat_manager.gd`, pasaron a un `Resource` `Recruit` (como `EquipmentItem`) con
      catálogo en `RunState`, para poder elegir entre dos. `RunState.set_recruit()` y
      `set_equipment()` ajustan la vida máxima al instante si cambian a mitad de run
      (delta, no solo al recalcular en `start_run()`).
      **Bug real encontrado y corregido en esta sesión (dos veces):**
      1. El equipo **no se reseteaba entre runs** — contradecía al dossier
         ("temporal... perdido al terminar la run"), arrastre de cuando el punto 4 se
         construyó sin Tienda todavía. Ahora `equipped_weapon_id/armor_id/accessory_id`
         se resetean a vacío en `start_run()`, igual que el recluta, y se quitó el
         selector de equipo del Hub por completo — el único sitio para equiparse es la
         Tienda, en paralelo exacto a como el único sitio para reclutar es
         Reclutamiento.
      2. `path_strip.gd` tiene su propio diccionario de iconos, duplicado del de
         `map.gd` — no se actualizó con los 3 tipos nuevos, así que el resumen de
         camino sobre Combate/Descanso mostraba "?" en vez del icono real. Corregido.
      **Pulido de UX, a petición del usuario:** con el selector de equipo fuera, el
      árbol de habilidades del Hub se ensanchó para ocupar el espacio libre
      (`SIZE_EXPAND_FILL`, botones de 56px). Bloquear y "Última Línea" (la acción de
      Triario) se capan a una vez por turno — el botón se deshabilita tras el primer
      uso y se reactiva en el turno siguiente, en vez de dejar que gastar más PA en
      ellos desperdicie el resto sin avisar. "Terminar turno" también se deshabilita
      con 3/3 PA sin gastar, para no permitir un turno sin ninguna acción.
      **Nota de diseño abierta, señalada por el usuario:** Bloquear (acción del héroe)
      y Última Línea (acción de Triario) hacen esencialmente lo mismo — mitigar/evitar
      daño, una vez por turno. Puede que en el diseño real de SPQR deban fusionarse o
      diferenciarse mejor en vez de ser dos botones distintos con el mismo efecto.
      Verificado por consola en `--headless` en cada pieza (capas, iconos, HP y
      recompensa de Élite, swap de equipo en Tienda, elección y reseteo de recluta en
      Reclutamiento, tope de una vez por turno en Bloquear/Última Línea, gating de
      Terminar turno, iconos corregidos en `path_strip`) y confirmado visualmente por
      el usuario en el editor tras varias rondas de ajuste ("Funciona perfectamente").
- [x] 7. Veterancía de reclutas — **completo (2026-07-23).** Primer punto de la lista
      que no se pudo simplificar quitando la economía — "comprada con Oro" es el propio
      mecanismo a probar. Se introdujo Oro mínimo: contador temporal en `RunState`
      (se resetea a 0 cada run, a diferencia de la Chispa permanente), +5 por cada
      combate ganado. Se gasta en la Tienda (reutilizada, no se creó un nodo nuevo) en
      dos cosas:
      **Veterancía** — Posterior (base) → Prior (5 Oro) → Primus Pilus (+10 Oro más),
      un único `RunState.recruit_veterancy` (0-2) que se suma directo al campo
      relevante del recluta ya existente (`attack_bonus` para Hastatus, `max_hp_bonus`
      y `heal_amount` para Triario a la vez) — sin duplicar `.tres` por nivel.
      **Equipo, ahora con coste real** — nuevo campo `cost` en `EquipmentItem` (común 4,
      legendario 10, por objeto en vez de un precio fijo por tier). Regla acordada con
      el usuario: solo se puede comprar una categoría **superior** a la que ya tienes
      en ese slot — ni repetir la misma ni bajar de legendario a común — y cada compra
      cobra el precio completo sin importar si tuviste ese objeto antes esa run (sin
      inventario persistente, interpretación razonada de "sin reembolso" del dossier,
      no una cita literal — se lo confirmé al usuario antes de construirlo). Un intento
      inválido (categoría no superior, o Oro insuficiente) revierte el desplegable a lo
      que ya tenías y avisa en pantalla, sin cobrar nada.
      **Excepción anotada:** Reclutamiento sigue siendo gratis aunque el dossier diga
      que reclutar también cuesta Oro — es la capa 0, antes de cualquier combate, con
      0 Oro en el bolsillo; cobrarlo ahí dejaría al recluta inalcanzable en un mapa de
      4 capas.
      **Bug real encontrado y corregido en esta sesión:** la recompensa de Oro se sumaba
      *después* de `Chispa.add_chispa()`, así que la etiqueta combinada ("Chispa: X |
      Oro: Y") se refrescaba con el Oro todavía sin actualizar. Se invirtió el orden.
      Verificado por consola en `--headless` (escalado de veterancía para ambos
      reclutas, reseteo al cambiar de recluta y de run, gating de categoría/Oro en la
      Tienda con reversión de la selección, recompensa de Oro y etiqueta combinada) y
      confirmado visualmente por el usuario en el editor. El usuario señaló que el Oro
      da para poco en un mapa de prueba de 4 capas — esperado y aceptado: el mapa real
      de SPQR tendrá muchas más capas y dará más margen económico.
- [x] 8. Crítico como valor aparte — **completo (2026-07-24), bidireccional.** El
      dossier define el crítico como "valor fuera de las 6 estadísticas", base 5%, y
      señala que en el diseño completo enemigos y héroe comparten el mismo marco de
      estadísticas — así que a diferencia del punto 5 (clase débil, unidireccional a
      propósito) aquí sí se implementó bidireccional desde el principio, a petición
      explícita del usuario ("al final es una tirada random antes de atacar").
      `CRIT_CHANCE := 0.05` y `CRIT_DAMAGE_MULTIPLIER := 2` en `combat_manager.gd`; en
      `_resolve_turn()`, cada vez que una ronda tiene ganador (`WINS_A` o `WINS_B`) se
      tira con la instancia propia de `RandomNumberGenerator` del combate y, si acierta,
      el daño de ese golpe se duplica — para cualquiera de los dos bandos. El
      `result_label` añade "¡Golpe crítico!" cuando ocurre. Alcance reducido a
      propósito: el dossier liga el crítico a dos nodos de árbol (Golpe doble, Sangre
      fría) y a la Falcata de Sagunto, todos parte de la rama Ars Belli que este
      proyecto no construyó (solo existen las ramas Vigor/Botín) — no se tocó el árbol
      ni el equipo existente.
      **Lección de proceso (no de diseño):** verificar esto por consola en `--headless`
      llevó más intentos de los habituales por dos gotchas de Godot al margen del
      crítico en sí — un `preload()` a nivel de script de una escena que referencia un
      autoload (`RunState`) falla si se evalúa antes de que el motor registre los
      autoloads (hay que usar `load()` diferido dentro de una función, no un `const`
      a nivel de archivo); y `await` sobre una señal que ya se emitió de forma síncrona
      antes de que el `await` empezara a escuchar se queda colgado para siempre — hay
      que leer el estado inmediatamente después de la llamada síncrona que la dispara,
      no esperar la señal. Verificado con 6 asserts (crítico dobla daño ganando y
      perdiendo, mensaje aparece solo cuando corresponde, sin crítico el daño es
      normal), usando un patrón de enemigo no-telegráfico con RNG propio sembrado para
      forzar de forma determinista tanto el resultado de la ronda como el roll de
      crítico.
- [x] 9. Enemigos especiales mapeados sobre clase existente — **completo (2026-07-25).**
      A petición explícita del usuario, "garantizado" se interpretó como una capa nueva
      dedicada (la run pasa de 4 a 5 capas), no como una 3ª opción dentro de una capa ya
      existente — y colocada en el índice 2, empujando la Tienda/Combate antigua y el
      Jefe una posición hacia atrás:
      `combate/reclutamiento → elite/descanso → especial → combate/tienda → jefe`.
      Sin IA ni sistema de combate nuevo — "heredan matriz" se tradujo literalmente en
      reutilizar lo que ya existía: nuevo `Resource` `SpecialEnemy`
      (`scripts/special_enemy.gd`) con `display_name`, `weak_class` (una elección RPSLS,
      reutiliza el bonus de daño por clase débil del punto 5 pero fijo a este enemigo en
      vez de al azar por run) y `pattern` (reutiliza directamente uno de los 3
      `EnemyPattern` ya existentes de la Fase 5). 2 instancias en
      `resources/special_enemies/`: Contrabandista Céltiba (débil a Lagarto, patrón
      Telegráfico) y Mercenario Cartaginés (débil a Spock, patrón Reactivo). HP igualada
      a Élite (`SPECIAL_ENEMY_HP = 4`, sin inventar un tercer número). `map.gd` y
      `path_strip.gd` ya eran genéricos sobre `RunState.LAYERS`, así que solo hizo falta
      añadir el icono ASCII nuevo (`S`) y meter `"especial"` en `TOP_TYPES` para que se
      dibuje en la fila de combate, igual que `"jefe"`. Verificado por consola en
      `--headless`: 5 capas, capa 2 ofrece solo `especial`, catálogo con los 2 enemigos y
      sus datos correctos, recorrido completo de una run pasando por la capa nueva, y
      (instanciando `combat.tscn` de verdad) que `enemy_max_hp`, el `SpecialEnemy`
      asignado y la clase débil sobreescrita cuadran. Confirmado indirectamente por el
      usuario, que jugó una run completa hasta la Tienda (capa 3, la siguiente después de
      Especial) sin problemas.
      **Bug real encontrado y corregido en esta sesión, al probar la Tienda en esa
      misma run:** la opción "Ninguno" del desplegable de equipo no tenía ninguna de las
      restricciones de común/legendario — siempre se podía seleccionar, y desequipaba lo
      ya comprado sin devolver el Oro gastado ni pedir confirmación. Un clic accidental
      después de comprar bastaba para perder el objeto y el Oro de golpe, sin deshacerlo.
      `tienda.gd` ahora deshabilita la opción "Ninguno" del desplegable
      (`OptionButton.set_item_disabled(0, true)`) en cuanto se compra algo en ese hueco
      esa run — coherente con la regla ya acordada de "sin reembolso, solo se sube de
      categoría", sin diálogos de confirmación nuevos. Verificado por consola en
      `--headless` (deshabilitada tras comprar, habilitada antes).
- [x] 10. Respec del árbol — **completo (2026-07-25).**
      Reembolso del 75% de la Chispa gastada, redondeado hacia abajo, sobre el árbol
      completo (ambas ramas, Vigor + Botín, a la vez — no hay respec parcial por rama).
      `Chispa.respec_tree()` suma el `cost` de cada id en `unlocked_upgrades`, devuelve
      `int(floor(gasto * 0.75))` a `chispa` y vacía el array; `Chispa.respec_refund_amount()`
      expone el mismo cálculo sin ejecutar nada, para mostrarlo antes de confirmar. Sin
      huecos que resolver por la dependencia lineal (`requires`) — vaciar el array
      entero funciona igual aunque una rama esté a medio comprar.
      Botón "Respec" en el Hub, visible desde el principio junto a "Empezar Run",
      deshabilitado si `unlocked_upgrades` está vacío. Único punto de la Fase 7 con
      diálogo de confirmación (`ConfirmationDialog`) antes de ejecutar — decisión
      explícita del usuario: a diferencia de las acciones inválidas de la Tienda (que
      revierten solas sin diálogo), esta es una acción válida y deliberada que cuesta
      Chispa real, y un misclick no debe poder vaciar el árbol sin querer.
      Verificado por consola en `--headless` (reembolso exacto sobre el save real del
      usuario — 149 Chispa gastadas en las 8 mejoras → 111 de vuelta —, no-op sobre
      árbol vacío, redondeo hacia abajo con una suma impar) y confirmado visualmente por
      el usuario en el editor. El save real se respaldó y se restauró tal cual antes y
      después de la prueba, para no perder progreso de verdad por una prueba de humo.
      **Cierra la lista de 10 puntos de la Fase 7.**

## Fase 8 — Candidatas a prototipar (backlog, sin empezar)

No es una fase decidida — es la lista de mecánicas del dossier de SPQR que la Fase 7 dejó
fuera a propósito (por reducción de alcance) o que directamente nunca entró en esa lista,
revisada en sesión el 2026-07-25 comparando el dossier
(`0-documentation/SPQR_Punic_Wars_Dossier_v07_18072026.html`) contra los 10 puntos ya
cerrados de la Fase 7. Ninguno de estos puntos tiene plan aprobado todavía. Si se retoma
este repo, el primer paso es decidir con el usuario si se ataca alguno — con el mismo
proceso de la Fase 7: plan → validación → implementación → comprobación → commit, un
punto a la vez.

| # | Mecánica | Por qué no está probada | Valor de aprendizaje |
|---|---|---|---|
| 1 | Combate multi-enemigo (Fase Enemigos: cada unidad enemiga actúa una vez, en bucle, en vez de un único roll) | Todo combate del repo es 1 vs 1; ya anotado como limitación aceptada en el punto 1 de Fase 7 (con 3 PA de cola el jugador puede triplicar daño contra un solo enemigo) | Alto — prerrequisito real de facto de los puntos 3 y 4 de esta tabla |
| 2 | Esquiva como estadística aparte (probabilidad plana de esquivar del todo, distinta de Defensa que reduce y de Bloquear que mitiga 1 vez) | No existe hoy | Medio — barato de construir, como el Crítico del punto 8 de Fase 7 |
| 3 | Robo de turno (acción de Eques en el dossier: actúa una vez extra al empezar la Fase Enemigos, robando el turno al primer enemigo) | Ningún recluta probado hasta ahora toca el orden de turno, solo números (daño/mitigación) | Medio — es un tipo de interacción nuevo, no solo otro modificador |
| 4 | Área / ataque multi-objetivo (pasivo de Vélite en el dossier: Descarga golpea a 2 enemigos a la vez) | Depende del punto 1 — no tiene sentido probarlo con un solo enemigo en pantalla | Medio, bloqueado por el punto 1 |
| 5 | Niebla de mapa (tipos de nodo ocultos más allá de una capa de visibilidad, revelados por nodos de la rama Ingenium) | El mapa actual siempre muestra todas las capas y tipos | Bajo — es más generación/UI de datos que combate, pero la técnica de mostrar/ocultar nodos generados sí transfiere |
| 6 | Draft de escuadrón (3 de 5 huecos desbloqueados permanentemente con Gloria, C(5,3) = 10 combinaciones por run) | Hoy hay 1 solo hueco de recluta, elegido 1-de-2 en el nodo de Reclutamiento | Bajo-medio — ver nota de diseño abierta abajo antes de tocar esto |

**Nota de diseño abierta, sin resolver — el punto 6 y la tercera moneda:** el draft de
escuadrón del dossier depende de **Gloria**, una moneda permanente distinta de la
Chispa (Gloria financia el árbol de habilidades + los huecos de escuadrón; Oro sigue
siendo el temporal de dentro de la run). Añadirla tal cual chocaría con la regla
explícita de este mismo `CLAUDE.md` de no meter "una tercera moneda". Si algún día se
quiere probar el draft de verdad, hay que decidir antes si Gloria sustituye a Chispa
(renombrar el concepto, no añadir una moneda nueva) o si se acepta romper esa regla por
esta vez de forma consciente — no es una decisión que deba tomarse sin el usuario.

**Recomendación de Claude (2026-07-25), no una decisión tomada:** de toda la lista, el
punto 1 (combate multi-enemigo) es el que más transfiere a SPQR directamente — nunca es
1 vs 1 — y el único que le da sentido real a los puntos 3 y 4. El resto se puede dejar
anotado sin construir sin perder aprendizaje relevante.

## Infraestructura (fuera de las fases del dossier)

- [x] Godot 4.7 instalado
- [x] `gh` CLI instalado y autenticado
- [x] Repositorio en GitHub (público, `main`)
- [x] `CLAUDE.md` con convenciones de desarrollo

## Aprendizajes para SPQR (retrospectiva, 2026-07-25)

Con la Fase 7 cerrada (10/10 puntos), esta sección consolida en un solo sitio los
aprendizajes que ya estaban dispersos por el detalle fase a fase de este documento, más
los que solo se ven mirando el conjunto. Pensada para releerse antes de escribir la
primera línea de código del SPQR real, no solo como archivo histórico de este repo.

### Técnicos (Godot)

- **`--headless` + autoloads es una trampa sutil, ya repetida en fases distintas (Fase 5
  y Fase 7 punto 8):** un `preload()` a nivel de script que referencia un autoload puede
  evaluarse antes de que el motor registre los autoloads y falla — hace falta `load()`
  diferido dentro de una función, no una `const` a nivel de archivo. Y un `await` sobre
  una señal que ya se emitió de forma síncrona antes de que el `await` empezara a
  escuchar se cuelga para siempre — hay que leer el estado justo después de la llamada
  síncrona que la dispara, no esperar la señal. (Ver también `CLAUDE.md`, sección
  "Probar sin abrir el editor".)
- **Cualquier icono como texto debe limitarse a ASCII**, o exige una fuente propia
  embebida con fallback — los glifos Unicode (`♥ ★ ▼`) funcionan en el editor pero
  rompen en el export Web sin avisar (Fase 6, horas de depuración).
- **El pipeline de CI/export es donde se esconden los bugs de verdad, no el motor en
  sí** — el 404 de producción durante horas en Fase 6 no era un bug de Vercel, era que
  la action de export anidaba el build una carpeta más adentro de lo esperado. Antes de
  sospechar de un servicio externo, comparar el contenido real subido (manifiesto de
  archivos), no solo la config o el comportamiento "a mano".
- **Verificar sistemas de persistencia por consola exige backup/restore explícito del
  `user://savegame.json` real** cada vez, para no pisar progreso real del usuario —
  rutina ya establecida aquí, que en SPQR con un savegame más grande probablemente pida
  un savegame de test dedicado en vez de tocar siempre el real.

### Diseño (solo visible construyendo, no en el papel)

- **Mecánicas que en el dossier parecen distintas colisionan en la práctica:** Bloquear
  (acción del héroe) y Última Línea (acción de Triario) resultaron ser, jugando, lo
  mismo — mitigar daño una vez por turno. Señal real de que hay que vigilar el solape
  entre acciones de héroe y pasivos/acciones de recluta al añadir las 5 clases completas
  de SPQR.
- **"Clase débil" necesita ser una identidad fija de unidad, no una tirada libre:**
  mapear el bonus sobre una elección RPSLS libre cada ronda (en vez de sobre la
  identidad fija de una unidad enemiga, como en el diseño real) permite que un agente
  que optimice evite la clase débil una vez revelada, vaciando el bonus. No rompe nada
  aquí porque la IA actual no tiene esa lógica, pero es una pregunta abierta real para
  el combate de SPQR.
- **La curva de coste del árbol debe crecer casi exponencial, no lineal:** confirmado
  con datos reales de playtesting (149 Chispa gastadas en solo 8 nodos de 2 ramas de
  prueba, sobrando Chispa al final del recorrido). Con 29 nodos y 4 ramas reales en
  SPQR, una curva plana dejaría el árbol vacío en pocas runs.
- **Ningún número de este repo debe copiarse literalmente a SPQR** — son cifras de
  prueba para validar el mecanismo, no el balance (regla ya explícita en `CLAUDE.md`,
  confirmada empíricamente por la escasez de Oro en un mapa de prueba de 4-5 capas: se
  espera que un mapa de campaña real con más capas dé más margen económico, no que la
  cifra en sí sea correcta).
- **Los bugs reales aparecen jugando, no diseñando:** el desplegable "Ninguno" de la
  Tienda desequipaba sin devolver el Oro gastado; la Lorica de recluta anulaba el daño
  del todo porque el daño base enemigo era `1` fijo. Ninguno se habría visto sin una run
  completa jugada de verdad — el paso de "confirmado visualmente por el usuario" no es
  un trámite, es donde salen los bugs reales.

### Proceso de trabajo

- **Un punto a la vez, con validación del usuario entre cada uno** (plan → implementar →
  verificar por consola → confirmar visualmente → commit) evitó que un mecanismo mal
  entendido se propagara a los siguientes puntos de la lista — con 29 nodos de árbol y 5
  clases reales en SPQR, este ritmo importa más, no menos.
- **Reducir alcance a propósito y anotar el corte** ("1 recluta fijo en vez de 3
  huecos", "equipo sin coste hasta que exista Tienda") permitió probar el mecanismo sin
  construir el sistema completo de golpe, dejando escrito exactamente qué falta para
  retomarlo — patrón directamente reutilizable en SPQR.
- **El dossier de diseño (v_07, 18/07/2026) es anterior a estos hallazgos** (sesiones
  del 23 al 25/07/2026) — ninguno de los puntos de diseño de esta sección está todavía
  incorporado al documento real. Antes de empezar el desarrollo real de SPQR, vale la
  pena una pasada explícita de "retroalimentar el dossier con lo aprendido aquí", para
  no perder estas notas sueltas en el ROADMAP de un repo distinto.
