extends Control

const EquipmentItem := preload("res://scripts/equipment_item.gd")
const EQUIPMENT_SLOTS := [
	{"slot_id": "weapon", "common_id": "gladio_veterano", "legendary_id": "falcata_de_sagunto"},
	{"slot_id": "armor", "common_id": "lorica_de_recluta", "legendary_id": "coraza_del_general"},
	{"slot_id": "accessory", "common_id": "talisman_del_mercader", "legendary_id": "reserva_de_hierro"},
]

@onready var weapon_option_button: OptionButton = %WeaponOptionButton
@onready var armor_option_button: OptionButton = %ArmorOptionButton
@onready var accessory_option_button: OptionButton = %AccessoryOptionButton
@onready var continue_button: Button = %ContinueButton


func _ready() -> void:
	continue_button.pressed.connect(_on_continue_pressed)
	_setup_equipment_option_buttons()


func _on_continue_pressed() -> void:
	RunState.advance()
	get_tree().change_scene_to_file("res://scenes/map/map.tscn")


func _setup_equipment_option_buttons() -> void:
	var option_buttons: Array[OptionButton] = [weapon_option_button, armor_option_button, accessory_option_button]
	for i in EQUIPMENT_SLOTS.size():
		var slot_data: Dictionary = EQUIPMENT_SLOTS[i]
		var option_button: OptionButton = option_buttons[i]
		var common_item: EquipmentItem = RunState.EQUIPMENT_CATALOG[slot_data["common_id"]]
		var legendary_item: EquipmentItem = RunState.EQUIPMENT_CATALOG[slot_data["legendary_id"]]

		option_button.clear()
		option_button.add_item("Ninguno")
		option_button.add_item("%s (común)" % common_item.display_name)
		option_button.add_item("%s (legendario)" % legendary_item.display_name)

		var current_item: EquipmentItem = RunState.equipped_item(slot_data["slot_id"])
		if current_item == common_item:
			option_button.select(1)
		elif current_item == legendary_item:
			option_button.select(2)
		else:
			option_button.select(0)

		option_button.item_selected.connect(_on_equipment_selected.bind(slot_data))


func _on_equipment_selected(index: int, slot_data: Dictionary) -> void:
	var chosen_id := ""
	if index == 1:
		chosen_id = slot_data["common_id"]
	elif index == 2:
		chosen_id = slot_data["legendary_id"]
	RunState.set_equipment(slot_data["slot_id"], chosen_id)
