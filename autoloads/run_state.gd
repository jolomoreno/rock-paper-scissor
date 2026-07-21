extends Node

signal run_started
signal run_ended(victory: bool)

const LAYERS: Array = [
	["combate", "descanso"],
	["combate", "descanso"],
	["combate", "descanso"],
	["jefe"],
]
const JEFE_ENEMY_HP := 5

var in_run: bool = false
var current_layer: int = 0
var chosen_node_type: String = ""
var player_max_hp: int = 0
var player_hp: int = 0


func start_run() -> void:
	in_run = true
	current_layer = 0
	chosen_node_type = ""
	player_max_hp = 3 + Chispa.player_hp_bonus()
	player_hp = player_max_hp
	run_started.emit()


func heal_full() -> void:
	player_hp = player_max_hp


func advance() -> void:
	current_layer += 1


func is_last_layer() -> bool:
	return current_layer >= LAYERS.size() - 1


func end_run(victory: bool) -> void:
	in_run = false
	run_ended.emit(victory)
