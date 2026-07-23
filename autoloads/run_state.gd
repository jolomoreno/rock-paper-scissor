extends Node

signal run_started
signal run_ended(victory: bool)

const EquipmentItem := preload("res://scripts/equipment_item.gd")
const Recruit := preload("res://scripts/recruit.gd")
const CombatResolver := preload("res://scripts/combat_resolver.gd")

const LAYERS: Array = [
	["combate", "reclutamiento"],
	["elite", "descanso"],
	["combate", "tienda"],
	["jefe"],
]
const JEFE_ENEMY_HP := 5
const ELITE_ENEMY_HP := 4
const REST_HEALTH_THRESHOLD := 0.85
const VETERANCY_NAMES := ["Posterior", "Prior", "Primus Pilus"]
const VETERANCY_COSTS := [5, 10]
const MAX_VETERANCY := 2
const EQUIPMENT_CATALOG: Dictionary = {
	"gladio_veterano": preload("res://resources/equipment/gladio_veterano.tres"),
	"falcata_de_sagunto": preload("res://resources/equipment/falcata_de_sagunto.tres"),
	"lorica_de_recluta": preload("res://resources/equipment/lorica_de_recluta.tres"),
	"coraza_del_general": preload("res://resources/equipment/coraza_del_general.tres"),
	"talisman_del_mercader": preload("res://resources/equipment/talisman_del_mercader.tres"),
	"reserva_de_hierro": preload("res://resources/equipment/reserva_de_hierro.tres"),
}
const RECRUIT_CATALOG: Dictionary = {
	"hastatus": preload("res://resources/recruits/hastatus.tres"),
	"triario": preload("res://resources/recruits/triario.tres"),
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
var recruit_id: String = ""
var recruit_veterancy: int = 0
var oro: int = 0
var weak_class_target: CombatResolver.Choice = CombatResolver.Choice.ROCK

var _rng := RandomNumberGenerator.new()


func _ready() -> void:
	_rng.randomize()


func start_run() -> void:
	in_run = true
	current_layer = 0
	chosen_node_type = ""
	recruit_id = ""
	recruit_veterancy = 0
	oro = 0
	equipped_weapon_id = ""
	equipped_armor_id = ""
	equipped_accessory_id = ""
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


func set_equipment(slot_id: String, item_id: String) -> void:
	var old_bonus := armor_max_hp_bonus() if slot_id == "armor" else 0
	match slot_id:
		"weapon":
			equipped_weapon_id = item_id
		"armor":
			equipped_armor_id = item_id
		"accessory":
			equipped_accessory_id = item_id
	if slot_id == "armor":
		_apply_max_hp_delta(armor_max_hp_bonus() - old_bonus)


func equipment_tier_rank(slot_id: String) -> int:
	var item: EquipmentItem = equipped_item(slot_id)
	return item.tier if item != null else -1


func buy_equipment(slot_id: String, item_id: String) -> String:
	if item_id == "":
		set_equipment(slot_id, "")
		return "ok"
	var item: EquipmentItem = EQUIPMENT_CATALOG.get(item_id, null)
	if item == null:
		return "ok"
	if item.tier <= equipment_tier_rank(slot_id):
		return "tier"
	if oro < item.cost:
		return "oro"
	oro -= item.cost
	set_equipment(slot_id, item_id)
	return "ok"


func armor_max_hp_bonus() -> int:
	var item: EquipmentItem = equipped_item("armor")
	return item.max_hp_bonus if item != null else 0


func recruit() -> Recruit:
	return RECRUIT_CATALOG.get(recruit_id, null)


func set_recruit(new_recruit_id: String) -> void:
	var old_bonus := recruit_max_hp_bonus()
	recruit_id = new_recruit_id
	recruit_veterancy = 0
	_apply_max_hp_delta(recruit_max_hp_bonus() - old_bonus)


func recruit_max_hp_bonus() -> int:
	var r: Recruit = recruit()
	if r == null or r.max_hp_bonus <= 0:
		return 0
	return r.max_hp_bonus + recruit_veterancy


func recruit_effective_attack_bonus() -> int:
	var r: Recruit = recruit()
	if r == null or r.attack_bonus <= 0:
		return 0
	return r.attack_bonus + recruit_veterancy


func recruit_effective_heal_amount() -> int:
	var r: Recruit = recruit()
	if r == null or r.heal_amount <= 0:
		return 0
	return r.heal_amount + recruit_veterancy


func veterancy_name() -> String:
	return VETERANCY_NAMES[recruit_veterancy]


func veterancy_upgrade_cost() -> int:
	if recruit_veterancy >= MAX_VETERANCY:
		return -1
	return VETERANCY_COSTS[recruit_veterancy]


func upgrade_veterancy() -> bool:
	var cost := veterancy_upgrade_cost()
	if cost < 0 or oro < cost or recruit() == null:
		return false
	oro -= cost
	var old_bonus := recruit_max_hp_bonus()
	recruit_veterancy += 1
	_apply_max_hp_delta(recruit_max_hp_bonus() - old_bonus)
	return true


func _apply_max_hp_delta(delta: int) -> void:
	if delta == 0:
		return
	player_max_hp += delta
	player_hp += delta


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
