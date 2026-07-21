extends Control

const NODE_ICONS := {
	"combate": "†",
	"descanso": "♥",
	"jefe": "★",
}
const GOLD := Color(0.878, 0.698, 0.235)
const CURRENT_BG := Color(0.310, 0.639, 0.820)
const CURRENT_BORDER := Color(0.173, 0.243, 0.314)
const CURRENT_TEXT := Color(0.08, 0.12, 0.16)
const NODE_FONT_SIZE := 20
const SEPARATOR_FONT_SIZE := 16
const CURRENT_BADGE_SIZE := Vector2(36, 36)
const SEPARATOR_TEXT := " → "

@onready var path_container: HBoxContainer = %PathContainer


func _ready() -> void:
	_build_path()


func _build_path() -> void:
	var history: Array = RunState.path_history
	for i in range(history.size()):
		var entry: Dictionary = history[i]
		var is_current := i == history.size() - 1
		path_container.add_child(_make_node_label(entry["node_type"], is_current))

		if not is_current:
			var separator_label := Label.new()
			separator_label.text = SEPARATOR_TEXT
			separator_label.add_theme_font_size_override("font_size", SEPARATOR_FONT_SIZE)
			path_container.add_child(separator_label)


func _make_node_label(node_type: String, is_current: bool) -> Control:
	var label := Label.new()
	label.text = NODE_ICONS.get(node_type, "?")
	label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	label.vertical_alignment = VERTICAL_ALIGNMENT_CENTER
	label.add_theme_font_size_override("font_size", NODE_FONT_SIZE)

	if not is_current:
		label.add_theme_color_override("font_color", GOLD)
		return label

	label.add_theme_color_override("font_color", CURRENT_TEXT)

	var badge := PanelContainer.new()
	badge.custom_minimum_size = CURRENT_BADGE_SIZE
	var style := StyleBoxFlat.new()
	style.bg_color = CURRENT_BG
	style.border_color = CURRENT_BORDER
	style.set_border_width_all(2)
	style.set_corner_radius_all(int(CURRENT_BADGE_SIZE.x / 2))
	badge.add_theme_stylebox_override("panel", style)
	badge.add_child(label)
	return badge
