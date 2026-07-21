class_name EnemyAI
extends RefCounted

const CombatResolver := preload("res://scripts/combat_resolver.gd")
const EnemyPattern := preload("res://scripts/enemy_pattern.gd")

var pattern: EnemyPattern
var rng := RandomNumberGenerator.new()


func _init(p_pattern: EnemyPattern) -> void:
	pattern = p_pattern
	rng.randomize()


func choose(player_last_choice: CombatResolver.Choice, has_history: bool) -> CombatResolver.Choice:
	if pattern.pattern_type == EnemyPattern.Type.REACTIVE and has_history:
		var counters: Array = _choices_that_beat(player_last_choice)
		return counters[rng.randi_range(0, counters.size() - 1)]
	return _roll_uniform()


func _roll_uniform() -> CombatResolver.Choice:
	var choices: Array = CombatResolver.Choice.values()
	return choices[rng.randi_range(0, choices.size() - 1)] as CombatResolver.Choice


func _choices_that_beat(choice: CombatResolver.Choice) -> Array:
	var counters: Array = []
	for candidate in CombatResolver.Choice.values():
		if choice in CombatResolver.BEATS[candidate]:
			counters.append(candidate)
	return counters
