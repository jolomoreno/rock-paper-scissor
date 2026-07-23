extends Control

signal phase_changed(phase: TurnPhase)
signal round_resolved(player_choice: CombatResolver.Choice, enemy_choice: CombatResolver.Choice, result: CombatResolver.Result)
signal combat_ended(player_won: bool)

enum TurnPhase { PLAYER, RESOLUTION, ENEMY }

const CombatResolver := preload("res://scripts/combat_resolver.gd")
const EnemyAI := preload("res://scripts/enemy_ai.gd")
const EnemyPattern := preload("res://scripts/enemy_pattern.gd")
const ROUND_DELAY_SECONDS := 1.2
const COMBAT_WIN_CHISPA_REWARD := 2
const MAX_PA_PER_TURN := 3
const BASE_DAMAGE := 1
const CHOICE_NAMES := {
	CombatResolver.Choice.ROCK: "Piedra",
	CombatResolver.Choice.PAPER: "Papel",
	CombatResolver.Choice.SCISSORS: "Tijera",
	CombatResolver.Choice.LIZARD: "Lagarto",
	CombatResolver.Choice.SPOCK: "Spock",
}
const REACTIVE_PATTERN: EnemyPattern = preload("res://resources/enemy_patterns/reactivo.tres")
const RANDOM_PATTERNS: Array[EnemyPattern] = [
	preload("res://resources/enemy_patterns/aleatorio.tres"),
	preload("res://resources/enemy_patterns/telegrafico.tres"),
]

@export var player_max_hp: int = 3
@export var enemy_max_hp: int = 3

var current_phase: TurnPhase = TurnPhase.PLAYER
var player_hp: int
var enemy_hp: int
var player_pa: int = MAX_PA_PER_TURN
var _blocking_next_loss: bool = false
var _queued_actions: Array[Dictionary] = []

var _resolver := CombatResolver.new()
var _rng := RandomNumberGenerator.new()
var _enemy_ai: EnemyAI
var _last_player_choice: CombatResolver.Choice
var _has_player_history: bool = false
var _pending_enemy_choice: CombatResolver.Choice
var _has_pending_enemy_choice: bool = false

@onready var chispa_label: Label = %ChispaLabel
@onready var player_health_bar: ProgressBar = %PlayerHealthBar
@onready var enemy_health_bar: ProgressBar = %EnemyHealthBar
@onready var enemy_intent_label: Label = %EnemyIntentLabel
@onready var phase_label: Label = %PhaseLabel
@onready var pa_label: Label = %PALabel
@onready var queue_label: Label = %QueueLabel
@onready var action_buttons_container: HBoxContainer = %ActionButtonsContainer
@onready var rock_button: Button = %RockButton
@onready var paper_button: Button = %PaperButton
@onready var scissors_button: Button = %ScissorsButton
@onready var lizard_button: Button = %LizardButton
@onready var spock_button: Button = %SpockButton
@onready var secondary_actions_container: HBoxContainer = %SecondaryActionsContainer
@onready var block_button: Button = %BlockButton
@onready var end_turn_button: Button = %EndTurnButton
@onready var result_label: Label = %ResultLabel


func _ready() -> void:
	_rng.randomize()

	if RunState.in_run:
		player_max_hp = RunState.player_max_hp
		player_hp = RunState.player_hp
		if RunState.chosen_node_type == "jefe":
			enemy_max_hp = RunState.JEFE_ENEMY_HP
	else:
		player_max_hp += Chispa.player_hp_bonus()
		player_hp = player_max_hp

	enemy_hp = enemy_max_hp

	_enemy_ai = EnemyAI.new(_pick_enemy_pattern())
	enemy_intent_label.text = "Enemigo: %s" % _enemy_ai.pattern.display_name

	chispa_label.text = "Chispa: %d" % Chispa.chispa
	Chispa.chispa_changed.connect(_on_chispa_changed)

	player_health_bar.max_value = player_max_hp
	player_health_bar.value = player_hp
	enemy_health_bar.max_value = enemy_max_hp
	enemy_health_bar.value = enemy_hp

	rock_button.pressed.connect(_on_action_button_pressed.bind(CombatResolver.Choice.ROCK))
	paper_button.pressed.connect(_on_action_button_pressed.bind(CombatResolver.Choice.PAPER))
	scissors_button.pressed.connect(_on_action_button_pressed.bind(CombatResolver.Choice.SCISSORS))
	lizard_button.pressed.connect(_on_action_button_pressed.bind(CombatResolver.Choice.LIZARD))
	spock_button.pressed.connect(_on_action_button_pressed.bind(CombatResolver.Choice.SPOCK))
	block_button.pressed.connect(_on_block_button_pressed)
	end_turn_button.pressed.connect(_on_end_turn_button_pressed)

	_update_pa_label()
	_update_queue_label()
	_set_phase(TurnPhase.PLAYER)


func _on_action_button_pressed(choice: CombatResolver.Choice) -> void:
	if current_phase != TurnPhase.PLAYER or player_pa <= 0:
		return
	_queue_action({"type": "attack", "choice": choice})


func _on_block_button_pressed() -> void:
	if current_phase != TurnPhase.PLAYER or player_pa <= 0:
		return
	_queue_action({"type": "block"})


func _on_end_turn_button_pressed() -> void:
	if current_phase != TurnPhase.PLAYER:
		return
	_resolve_turn()


func _queue_action(action: Dictionary) -> void:
	_queued_actions.append(action)
	player_pa = max(player_pa - 1, 0)
	_update_pa_label()
	_update_queue_label()
	if player_pa <= 0:
		_resolve_turn()


func _update_pa_label() -> void:
	pa_label.text = "PA: %d/%d" % [player_pa, MAX_PA_PER_TURN]


func _update_queue_label() -> void:
	if _queued_actions.is_empty():
		queue_label.text = "Cola: (vacía)"
		return
	var parts: Array[String] = []
	for action: Dictionary in _queued_actions:
		if action["type"] == "attack":
			parts.append(CHOICE_NAMES[action["choice"]])
		else:
			parts.append("Bloquear")
	queue_label.text = "Cola: %s" % ", ".join(parts)


func _damage_taken_on_loss() -> int:
	if _blocking_next_loss:
		_blocking_next_loss = false
		return int(floor(BASE_DAMAGE / 2.0))
	return BASE_DAMAGE


func _start_enemy_phase() -> void:
	_set_phase(TurnPhase.ENEMY)
	player_pa = MAX_PA_PER_TURN
	_update_pa_label()
	_set_phase(TurnPhase.PLAYER)


func _on_chispa_changed(new_amount: int) -> void:
	chispa_label.text = "Chispa: %d" % new_amount


func _resolve_turn() -> void:
	_set_phase(TurnPhase.RESOLUTION)

	var enemy_choice: CombatResolver.Choice
	if _has_pending_enemy_choice:
		enemy_choice = _pending_enemy_choice
		_has_pending_enemy_choice = false
	else:
		enemy_choice = _enemy_ai.choose(_last_player_choice, _has_player_history)

	for action: Dictionary in _queued_actions:
		if action["type"] == "block":
			_blocking_next_loss = true
			result_label.text = "Bloqueas el siguiente golpe."
			await get_tree().create_timer(ROUND_DELAY_SECONDS).timeout
			continue

		var player_choice: CombatResolver.Choice = action["choice"]
		var result: CombatResolver.Result = _resolver.resolve_round(player_choice, enemy_choice)

		_last_player_choice = player_choice
		_has_player_history = true

		match result:
			CombatResolver.Result.WINS_A:
				enemy_hp -= 1
			CombatResolver.Result.WINS_B:
				player_hp -= _damage_taken_on_loss()

		player_health_bar.value = player_hp
		enemy_health_bar.value = enemy_hp
		result_label.text = _describe_result(player_choice, enemy_choice, result)
		round_resolved.emit(player_choice, enemy_choice, result)

		if player_hp <= 0 or enemy_hp <= 0:
			_queued_actions.clear()
			_update_queue_label()
			_end_combat(enemy_hp <= 0)
			return

		await get_tree().create_timer(ROUND_DELAY_SECONDS).timeout

	_queued_actions.clear()
	_update_queue_label()
	_start_enemy_phase()


func _end_combat(player_won: bool) -> void:
	action_buttons_container.visible = false
	secondary_actions_container.visible = false

	if not player_won:
		result_label.text += "\nPerdiste el combate."
		combat_ended.emit(player_won)
		if RunState.in_run:
			RunState.end_run(false)
			await get_tree().create_timer(ROUND_DELAY_SECONDS).timeout
			get_tree().change_scene_to_file("res://scenes/main/hub.tscn")
		return

	var reward := COMBAT_WIN_CHISPA_REWARD + Chispa.combat_win_chispa_bonus()
	Chispa.add_chispa(reward)
	result_label.text += "\n¡Ganaste el combate! (+%d Chispa)" % reward
	combat_ended.emit(player_won)

	if RunState.in_run:
		await get_tree().create_timer(ROUND_DELAY_SECONDS).timeout
		if RunState.is_last_layer():
			RunState.end_run(true)
			get_tree().change_scene_to_file("res://scenes/main/hub.tscn")
		else:
			RunState.player_hp = player_hp
			RunState.advance()
			get_tree().change_scene_to_file("res://scenes/map/map.tscn")


func _pick_enemy_pattern() -> EnemyPattern:
	if RunState.in_run and RunState.chosen_node_type == "jefe":
		return REACTIVE_PATTERN
	return RANDOM_PATTERNS[_rng.randi_range(0, RANDOM_PATTERNS.size() - 1)]


func _prepare_enemy_turn() -> void:
	if _enemy_ai.pattern.pattern_type != EnemyPattern.Type.TELEGRAPHED:
		return
	_pending_enemy_choice = _enemy_ai.choose(_last_player_choice, _has_player_history)
	_has_pending_enemy_choice = true
	enemy_intent_label.text = "Enemigo: %s — jugará %s" % [
		_enemy_ai.pattern.display_name,
		CHOICE_NAMES[_pending_enemy_choice],
	]


func _describe_result(player_choice: CombatResolver.Choice, enemy_choice: CombatResolver.Choice, result: CombatResolver.Result) -> String:
	var line := "Tú: %s — Enemigo: %s" % [CHOICE_NAMES[player_choice], CHOICE_NAMES[enemy_choice]]
	match result:
		CombatResolver.Result.DRAW:
			return line + "\nEmpate."
		CombatResolver.Result.WINS_A:
			return line + "\n¡Ganas la ronda!"
		CombatResolver.Result.WINS_B:
			return line + "\nPierdes la ronda."
	return line


func _set_phase(phase: TurnPhase) -> void:
	current_phase = phase
	var buttons_enabled := phase == TurnPhase.PLAYER
	rock_button.disabled = not buttons_enabled
	paper_button.disabled = not buttons_enabled
	scissors_button.disabled = not buttons_enabled
	lizard_button.disabled = not buttons_enabled
	spock_button.disabled = not buttons_enabled
	block_button.disabled = not buttons_enabled
	end_turn_button.disabled = not buttons_enabled
	match phase:
		TurnPhase.PLAYER:
			phase_label.text = "Fase Jugador — elige hasta 3 acciones"
		TurnPhase.RESOLUTION:
			phase_label.text = "Resolviendo turno..."
		TurnPhase.ENEMY:
			phase_label.text = "Fase Enemigos"
	if phase == TurnPhase.PLAYER:
		_prepare_enemy_turn()
	phase_changed.emit(phase)
