class_name EnemyPattern
extends Resource

enum Type { RANDOM, TELEGRAPHED, REACTIVE }

@export var display_name: String
@export var pattern_type: Type
