extends Control

@onready var title_label: Label = %TitleLabel
@onready var node_buttons_container: HBoxContainer = %NodeButtonsContainer


func _ready() -> void:
	title_label.text = "Capa %d de %d" % [RunState.current_layer + 1, RunState.LAYERS.size()]
	_build_node_buttons()


func _build_node_buttons() -> void:
	var node_types: Array = RunState.available_node_types()
	for node_type: String in node_types:
		var button := Button.new()
		button.text = node_type.capitalize()
		button.pressed.connect(_on_node_button_pressed.bind(node_type))
		node_buttons_container.add_child(button)


func _on_node_button_pressed(node_type: String) -> void:
	RunState.chosen_node_type = node_type
	if node_type == "descanso":
		get_tree().change_scene_to_file("res://scenes/map/descanso.tscn")
	else:
		get_tree().change_scene_to_file("res://scenes/combat/combat.tscn")
