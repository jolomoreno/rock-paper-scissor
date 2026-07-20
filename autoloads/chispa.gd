extends Node

signal chispa_changed(new_amount: int)
signal upgrade_purchased(upgrade_id: String)

const SAVE_PATH := "user://savegame.json"
const UPGRADES := {
	"vida_extra_jugador": {
		"display_name": "Vida extra",
		"cost": 5,
		"player_hp_bonus": 1,
	},
	"chispa_extra_combate": {
		"display_name": "Botín extra",
		"cost": 8,
		"chispa_win_bonus": 1,
	},
}

var chispa: int = 0
var unlocked_upgrades: Array[String] = []


func _ready() -> void:
	_load_from_disk()


func add_chispa(amount: int) -> void:
	chispa += amount
	chispa_changed.emit(chispa)
	_save_to_disk()


func has_upgrade(upgrade_id: String) -> bool:
	return unlocked_upgrades.has(upgrade_id)


func can_afford(upgrade_id: String) -> bool:
	return not has_upgrade(upgrade_id) and chispa >= UPGRADES[upgrade_id]["cost"]


func buy_upgrade(upgrade_id: String) -> bool:
	if not can_afford(upgrade_id):
		return false

	chispa -= UPGRADES[upgrade_id]["cost"]
	unlocked_upgrades.append(upgrade_id)
	chispa_changed.emit(chispa)
	upgrade_purchased.emit(upgrade_id)
	_save_to_disk()
	return true


func player_hp_bonus() -> int:
	return _sum_upgrade_field("player_hp_bonus")


func combat_win_chispa_bonus() -> int:
	return _sum_upgrade_field("chispa_win_bonus")


func _sum_upgrade_field(field: String) -> int:
	var total := 0
	for upgrade_id: String in unlocked_upgrades:
		total += UPGRADES.get(upgrade_id, {}).get(field, 0)
	return total


func _save_to_disk() -> void:
	var data := {
		"chispa": chispa,
		"unlocked_upgrades": unlocked_upgrades,
	}
	var file := FileAccess.open(SAVE_PATH, FileAccess.WRITE)
	if file == null:
		push_error("No se pudo abrir %s para guardar (error %d)" % [SAVE_PATH, FileAccess.get_open_error()])
		return

	file.store_string(JSON.stringify(data))
	file.close()


func _load_from_disk() -> void:
	var file := FileAccess.open(SAVE_PATH, FileAccess.READ)
	if file == null:
		return

	var content := file.get_as_text()
	file.close()

	var parsed: Variant = JSON.parse_string(content)
	if typeof(parsed) != TYPE_DICTIONARY:
		return

	chispa = parsed.get("chispa", 0)

	var loaded_upgrades: Array = parsed.get("unlocked_upgrades", [])
	unlocked_upgrades.assign(loaded_upgrades)
