class_name Recruit
extends Resource

enum ActionType { ATTACK, HEAL }

@export var display_name: String
@export var attack_bonus: int = 0
@export var max_hp_bonus: int = 0
@export var action_label: String = ""
@export var action_type: ActionType = ActionType.ATTACK
@export var action_choice: int = 0
@export var heal_amount: int = 0
