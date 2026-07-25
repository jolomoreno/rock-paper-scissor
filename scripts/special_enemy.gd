class_name SpecialEnemy
extends Resource

const CombatResolver := preload("res://scripts/combat_resolver.gd")
const EnemyPattern := preload("res://scripts/enemy_pattern.gd")

@export var display_name: String
@export var weak_class: CombatResolver.Choice
@export var pattern: EnemyPattern
