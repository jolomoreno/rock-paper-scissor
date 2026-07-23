extends Control

const EquipmentItem := preload("res://scripts/equipment_item.gd")
const Recruit := preload("res://scripts/recruit.gd")
const EQUIPMENT_SLOTS := [
	{"slot_id": "weapon", "common_id": "gladio_veterano", "legendary_id": "falcata_de_sagunto"},
	{"slot_id": "armor", "common_id": "lorica_de_recluta", "legendary_id": "coraza_del_general"},
	{"slot_id": "accessory", "common_id": "talisman_del_mercader", "legendary_id": "reserva_de_hierro"},
]

@onready var oro_label: Label = %OroLabel
@onready var weapon_option_button: OptionButton = %WeaponOptionButton
@onready var armor_option_button: OptionButton = %ArmorOptionButton
@onready var accessory_option_button: OptionButton = %AccessoryOptionButton
@onready var message_label: Label = %MessageLabel
@onready var veterancy_label: Label = %VeterancyLabel
@onready var veterancy_button: Button = %VeterancyButton
@onready var continue_button: Button = %ContinueButton


func _ready() -> void:
	continue_button.pressed.connect(_on_continue_pressed)
	veterancy_button.pressed.connect(_on_veterancy_button_pressed)
	_setup_equipment_option_buttons()
	_update_oro_label()
	_update_veterancy_section()


func _on_continue_pressed() -> void:
	RunState.advance()
	get_tree().change_scene_to_file("res://scenes/map/map.tscn")


func _update_oro_label() -> void:
	oro_label.text = "Oro: %d" % RunState.oro


func _setup_equipment_option_buttons() -> void:
	var option_buttons: Array[OptionButton] = [weapon_option_button, armor_option_button, accessory_option_button]
	for i in EQUIPMENT_SLOTS.size():
		var slot_data: Dictionary = EQUIPMENT_SLOTS[i]
		var option_button: OptionButton = option_buttons[i]
		var common_item: EquipmentItem = RunState.EQUIPMENT_CATALOG[slot_data["common_id"]]
		var legendary_item: EquipmentItem = RunState.EQUIPMENT_CATALOG[slot_data["legendary_id"]]

		option_button.clear()
		option_button.add_item("Ninguno")
		option_button.add_item("%s (común, %d Oro)" % [common_item.display_name, common_item.cost])
		option_button.add_item("%s (legendario, %d Oro)" % [legendary_item.display_name, legendary_item.cost])

		option_button.select(_current_index(slot_data))
		option_button.item_selected.connect(_on_equipment_selected.bind(slot_data, option_button))


func _current_index(slot_data: Dictionary) -> int:
	var rank := RunState.equipment_tier_rank(slot_data["slot_id"])
	if rank == EquipmentItem.Tier.COMMON:
		return 1
	if rank == EquipmentItem.Tier.LEGENDARY:
		return 2
	return 0


func _on_equipment_selected(index: int, slot_data: Dictionary, option_button: OptionButton) -> void:
	var chosen_id := ""
	if index == 1:
		chosen_id = slot_data["common_id"]
	elif index == 2:
		chosen_id = slot_data["legendary_id"]

	var status := RunState.buy_equipment(slot_data["slot_id"], chosen_id)
	if status == "tier":
		message_label.text = "Ya tienes algo de igual o mejor categoría en ese hueco."
		option_button.select(_current_index(slot_data))
	elif status == "oro":
		message_label.text = "No tienes suficiente Oro para eso."
		option_button.select(_current_index(slot_data))
	else:
		message_label.text = ""
		_update_oro_label()


func _update_veterancy_section() -> void:
	var recruit: Recruit = RunState.recruit()
	if recruit == null:
		veterancy_label.text = "Veterancía: sin recluta, nada que mejorar."
		veterancy_button.visible = false
		return

	veterancy_label.text = "Veterancía de %s: %s" % [recruit.display_name, RunState.veterancy_name()]
	var cost := RunState.veterancy_upgrade_cost()
	if cost < 0:
		veterancy_button.text = "Veterancía al máximo"
		veterancy_button.disabled = true
	else:
		veterancy_button.text = "Subir a %s (%d Oro)" % [RunState.VETERANCY_NAMES[RunState.recruit_veterancy + 1], cost]
		veterancy_button.disabled = RunState.oro < cost
	veterancy_button.visible = true


func _on_veterancy_button_pressed() -> void:
	RunState.upgrade_veterancy()
	_update_oro_label()
	_update_veterancy_section()
