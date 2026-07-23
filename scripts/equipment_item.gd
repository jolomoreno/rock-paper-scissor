class_name EquipmentItem
extends Resource

enum Slot { WEAPON, ARMOR, ACCESSORY }
enum Tier { COMMON, LEGENDARY }

@export var display_name: String
@export var slot: Slot
@export var tier: Tier
@export var cost: int = 0
@export var attack_bonus: int = 0
@export var defense_bonus: int = 0
@export var max_hp_bonus: int = 0
@export var chispa_win_bonus: int = 0
@export var double_damage_on_win: bool = false
@export var heal_on_low_hp: int = 0
