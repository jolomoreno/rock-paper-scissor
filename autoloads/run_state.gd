extends Node

signal run_started
signal run_ended(victory: bool)

const EquipmentItem := preload("res://scripts/equipment_item.gd")
const CombatResolver := preload("res://scripts/combat_resolver.gd")

const LAYERS: Array = [
	["combate", "descanso"],
	["combate", "descanso"],
	["combate", "descanso"],
	["jefe"],
]
const JEFE_ENEMY_HP := 5
const REST_HEALTH_THRESHOLD := 0.85
const EQUIPMENT_CATALOG: Dictionary = {
	"gladio_veterano": preload("res://resources/equipment/gladio_veterano.tres"),
	"falcata_de_sagunto": preload("res://resources/equipment/falcata_de_sagunto.tres"),
	"lorica_de_recluta": preload("res://resources/equipment/lorica_de_recluta.tres"),
	"coraza_del_general": preload("res://resources/equipment/coraza_del_general.tres"),
	"talisman_del_mercader": preload("res://resources/equipment/talisman_del_mercader.tres"),
	"reserva_de_hierro": preload("res://resources/equipment/reserva_de_hierro.tres"),
}

var in_run: bool = false
var current_layer: int = 0
var chosen_node_type: String = ""
var player_max_hp: int = 0
var player_hp: int = 0
var path_history: Array = []
var equipped_weapon_id: String = ""
var equipped_armor_id: String = ""
var equipped_accessory_id: String = ""
var weak_class_target: CombatResolver.Choice = CombatResolver.Choice.ROCK

var _rng := RandomNumberGenerator.new()


func _ready() -> void:
	_rng.randomize()


func start_run() -> void:
	in_run = true
	current_layer = 0
	chosen_node_type = ""
	player_max_hp = 3 + Chispa.player_hp_bonus() + armor_max_hp_bonus()
	player_hp = player_max_hp
	path_history = []
	weak_class_target = _rng.randi_range(0, 4) as CombatResolver.Choice
	run_started.emit()


func equipped_item(slot_id: String) -> EquipmentItem:
	match slot_id:
		"weapon":
			return EQUIPMENT_CATALOG.get(equipped_weapon_id, null)
		"armor":
			return EQUIPMENT_CATALOG.get(equipped_armor_id, null)
		"accessory":
			return EQUIPMENT_CATALOG.get(equipped_accessory_id, null)
	return null


func armor_max_hp_bonus() -> int:
	var item: EquipmentItem = equipped_item("armor")
	return item.max_hp_bonus if item != null else 0


func choose_node(node_type: String) -> void:
	chosen_node_type = node_type
	path_history.append({"layer": current_layer, "node_type": node_type})


func heal_full() -> void:
	player_hp = player_max_hp


func advance() -> void:
	current_layer += 1


func is_last_layer() -> bool:
	return current_layer >= LAYERS.size() - 1


func available_node_types() -> Array:
	var node_types: Array = LAYERS[current_layer].duplicate()
	if not _can_offer_rest():
		node_types.erase("descanso")
	return node_types


func _can_offer_rest() -> bool:
	if current_layer == 0:
		return false
	if chosen_node_type == "descanso":
		return false
	if player_hp > player_max_hp * REST_HEALTH_THRESHOLD:
		return false
	return true


func end_run(victory: bool) -> void:
	in_run = false
	run_ended.emit(victory)
