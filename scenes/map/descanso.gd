extends Control

@onready var continue_button: Button = %ContinueButton


func _ready() -> void:
	continue_button.pressed.connect(_on_continue_pressed)


func _on_continue_pressed() -> void:
	RunState.heal_full()
	RunState.advance()
	get_tree().change_scene_to_file("res://scenes/map/map.tscn")
