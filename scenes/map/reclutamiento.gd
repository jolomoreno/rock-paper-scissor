extends Control

const Recruit := preload("res://scripts/recruit.gd")

@onready var hastatus_button: Button = %HastatusButton
@onready var triario_button: Button = %TriarioButton


func _ready() -> void:
	var hastatus: Recruit = RunState.RECRUIT_CATALOG["hastatus"]
	var triario: Recruit = RunState.RECRUIT_CATALOG["triario"]

	hastatus_button.text = "%s — ofensivo: +%d daño al ganar, acción %s" % [
		hastatus.display_name, hastatus.attack_bonus, hastatus.action_label,
	]
	triario_button.text = "%s — defensivo: +%d Vida máxima, acción %s" % [
		triario.display_name, triario.max_hp_bonus, triario.action_label,
	]

	hastatus_button.pressed.connect(_on_recruit_chosen.bind("hastatus"))
	triario_button.pressed.connect(_on_recruit_chosen.bind("triario"))


func _on_recruit_chosen(recruit_id: String) -> void:
	RunState.set_recruit(recruit_id)
	RunState.advance()
	get_tree().change_scene_to_file("res://scenes/map/map.tscn")
