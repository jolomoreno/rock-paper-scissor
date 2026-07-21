extends Control

const NODE_SIZE := Vector2(90, 90)
const NODE_RADIUS := 45
const MARKER_SIZE := Vector2(90, 36)
const NODE_ICONS := {
	"combate": "†",
	"descanso": "♥",
	"jefe": "★",
}

const GOLD := Color(0.878, 0.698, 0.235)
const GOLD_TEXT := Color(0.227, 0.165, 0.02)
const CURRENT_BG := Color(0.310, 0.639, 0.820)
const CURRENT_BORDER := Color(0.173, 0.243, 0.314)
const CURRENT_TEXT := Color(0.08, 0.12, 0.16)
const DIM_BORDER := Color(0.533, 0.533, 0.533, 0.4)
const DIM_TEXT := Color(0.667, 0.667, 0.667, 0.4)
const JEFE_DIM_BORDER := Color(0.788, 0.416, 0.416, 0.4)
const TRANSPARENT := Color(0, 0, 0, 0)
const PATH_LINE_WIDTH := 4.0

@onready var title_label: Label = %TitleLabel
@onready var marker_row: HBoxContainer = %MarkerRow
@onready var combat_row: HBoxContainer = %CombatRow
@onready var rest_row: HBoxContainer = %RestRow
@onready var path_overlay: Control = %PathOverlay
@onready var legend_recorrido: Label = %LegendRecorrido
@onready var legend_actual: Label = %LegendActual
@onready var legend_por_venir: Label = %LegendPorVenir

var _slot_nodes: Dictionary = {}


func _ready() -> void:
	title_label.text = "Capa %d de %d" % [RunState.current_layer + 1, RunState.LAYERS.size()]
	_style_legend()
	_build_map()
	path_overlay.draw.connect(_on_path_overlay_draw)
	await get_tree().process_frame
	path_overlay.queue_redraw()


func _style_legend() -> void:
	legend_recorrido.add_theme_color_override("font_color", GOLD)
	legend_actual.add_theme_color_override("font_color", CURRENT_BORDER)
	legend_por_venir.add_theme_color_override("font_color", Color(0.667, 0.667, 0.667))


func _build_map() -> void:
	for layer_idx in range(RunState.LAYERS.size()):
		var layer_types: Array = RunState.LAYERS[layer_idx]
		var top_type: String = "jefe" if "jefe" in layer_types else "combate"
		marker_row.add_child(_make_marker_cell(layer_idx))
		combat_row.add_child(_make_slot_cell(layer_idx, top_type, layer_types))
		rest_row.add_child(_make_slot_cell(layer_idx, "descanso", layer_types))


func _make_marker_cell(layer_idx: int) -> Control:
	var label := Label.new()
	label.custom_minimum_size = MARKER_SIZE
	label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	label.add_theme_font_size_override("font_size", 26)
	label.text = "▼" if layer_idx == RunState.current_layer else ""
	return label


func _make_slot_cell(layer_idx: int, node_type: String, layer_types: Array) -> Control:
	if not (node_type in layer_types):
		var spacer := Control.new()
		spacer.custom_minimum_size = NODE_SIZE
		return spacer

	var button := Button.new()
	button.custom_minimum_size = NODE_SIZE
	button.text = NODE_ICONS.get(node_type, "?")
	button.add_theme_font_size_override("font_size", 34)
	_style_slot_button(button, layer_idx, node_type)
	_slot_nodes["%d:%s" % [layer_idx, node_type]] = button
	return button


func _style_slot_button(button: Button, layer_idx: int, node_type: String) -> void:
	if layer_idx < RunState.current_layer:
		if _chosen_node_type_for_layer(layer_idx) == node_type:
			_apply_node_style(button, GOLD, GOLD, GOLD_TEXT)
		else:
			_apply_node_style(button, TRANSPARENT, DIM_BORDER, DIM_TEXT)
		button.disabled = true
		return

	if layer_idx == RunState.current_layer:
		if node_type in RunState.available_node_types():
			_apply_interactive_node_style(button, CURRENT_BG, CURRENT_BORDER, CURRENT_TEXT)
			button.pressed.connect(_on_node_button_pressed.bind(node_type))
		else:
			_apply_node_style(button, TRANSPARENT, DIM_BORDER, DIM_TEXT)
			button.disabled = true
		return

	var future_border: Color = JEFE_DIM_BORDER if node_type == "jefe" else DIM_BORDER
	_apply_node_style(button, TRANSPARENT, future_border, future_border)
	button.disabled = true


func _circle_style(bg_color: Color, border_color: Color) -> StyleBoxFlat:
	var style := StyleBoxFlat.new()
	style.bg_color = bg_color
	style.border_color = border_color
	style.set_border_width_all(3)
	style.set_corner_radius_all(NODE_RADIUS)
	return style


func _apply_node_style(button: Button, bg_color: Color, border_color: Color, text_color: Color) -> void:
	var style := _circle_style(bg_color, border_color)
	button.add_theme_stylebox_override("normal", style)
	button.add_theme_stylebox_override("disabled", style)
	button.add_theme_color_override("font_color", text_color)
	button.add_theme_color_override("font_disabled_color", text_color)


func _apply_interactive_node_style(button: Button, bg_color: Color, border_color: Color, text_color: Color) -> void:
	button.add_theme_stylebox_override("normal", _circle_style(bg_color, border_color))
	button.add_theme_stylebox_override("hover", _circle_style(bg_color.lightened(0.15), border_color))
	button.add_theme_stylebox_override("pressed", _circle_style(bg_color.darkened(0.15), border_color))
	button.add_theme_stylebox_override("focus", StyleBoxEmpty.new())
	button.add_theme_color_override("font_color", text_color)
	button.add_theme_color_override("font_hover_color", text_color)
	button.add_theme_color_override("font_pressed_color", text_color)


func _chosen_node_type_for_layer(layer_idx: int) -> String:
	for entry: Dictionary in RunState.path_history:
		if entry["layer"] == layer_idx:
			return entry["node_type"]
	return ""


func _on_node_button_pressed(node_type: String) -> void:
	RunState.choose_node(node_type)
	if node_type == "descanso":
		get_tree().change_scene_to_file("res://scenes/map/descanso.tscn")
	else:
		get_tree().change_scene_to_file("res://scenes/combat/combat.tscn")


func _on_path_overlay_draw() -> void:
	var history: Array = RunState.path_history
	for i in range(history.size() - 1):
		_draw_segment(_history_key(history[i]), _history_key(history[i + 1]))

	if not history.is_empty() and RunState.current_layer < RunState.LAYERS.size():
		var current_layer_types: Array = RunState.LAYERS[RunState.current_layer]
		var current_top_type: String = "jefe" if "jefe" in current_layer_types else "combate"
		var current_key := "%d:%s" % [RunState.current_layer, current_top_type]
		_draw_segment(_history_key(history[-1]), current_key)


func _draw_segment(from_key: String, to_key: String) -> void:
	var from_node: Control = _slot_nodes.get(from_key)
	var to_node: Control = _slot_nodes.get(to_key)
	if from_node == null or to_node == null:
		return
	var overlay_transform: Transform2D = path_overlay.get_global_transform().affine_inverse()
	var from_center: Vector2 = overlay_transform * from_node.get_global_rect().get_center()
	var to_center: Vector2 = overlay_transform * to_node.get_global_rect().get_center()

	var direction: Vector2 = (to_center - from_center).normalized()
	var from_point: Vector2 = from_center + direction * NODE_RADIUS
	var to_point: Vector2 = to_center - direction * NODE_RADIUS
	path_overlay.draw_line(from_point, to_point, GOLD, PATH_LINE_WIDTH)


func _history_key(entry: Dictionary) -> String:
	return "%d:%s" % [entry["layer"], entry["node_type"]]
