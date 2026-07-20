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

Fase 2 completa: Autoload `Chispa` (`autoloads/chispa.gd`) con la moneda permanente,
guardado/carga en `user://savegame.json` vía `FileAccess`+JSON, y dos mejoras fijas
comprables (vida extra, botín extra de combate). El combate de la Fase 1 ya otorga
Chispa al ganar y aplica el bonus de vida de las mejoras compradas. Verificado por
consola en modo `--headless`. Pendiente: exportación HTML5 de la Fase 1 (bloqueada por
falta de export templates instalados localmente). Siguiente hito: Fase 3 (mapa de nodos
+ hub). Ver [ROADMAP.md](ROADMAP.md) para el desglose completo de fases.

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
