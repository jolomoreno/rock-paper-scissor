extends Control

signal phase_changed(phase: TurnPhase)
signal round_resolved(player_choice: CombatResolver.Choice, enemy_choice: CombatResolver.Choice, result: CombatResolver.Result)
signal combat_ended(player_won: bool)

enum TurnPhase { PLAYER, RESOLUTION, ENEMY }

const CombatResolver := preload("res://scripts/combat_resolver.gd")
const ROUND_DELAY_SECONDS := 1.2
const COMBAT_WIN_CHISPA_REWARD := 2
const CHOICE_NAMES := {
	CombatResolver.Choice.ROCK: "Piedra",
	CombatResolver.Choice.PAPER: "Papel",
	CombatResolver.Choice.SCISSORS: "Tijera",
}

@export var player_max_hp: int = 3
@export var enemy_max_hp: int = 3

var current_phase: TurnPhase = TurnPhase.PLAYER
var player_hp: int
var enemy_hp: int

var _resolver := CombatResolver.new()
var _rng := RandomNumberGenerator.new()

@onready var chispa_label: Label = %ChispaLabel
@onready var player_health_bar: ProgressBar = %PlayerHealthBar
@onready var enemy_health_bar: ProgressBar = %EnemyHealthBar
@onready var action_buttons_container: HBoxContainer = %ActionButtonsContainer
@onready var rock_button: Button = %RockButton
@onready var paper_button: Button = %PaperButton
@onready var scissors_button: Button = %ScissorsButton
@onready var result_label: Label = %ResultLabel


func _ready() -> void:
	_rng.randomize()
	player_max_hp += Chispa.player_hp_bonus()
	player_hp = player_max_hp
	enemy_hp = enemy_max_hp

	chispa_label.text = "Chispa: %d" % Chispa.chispa
	Chispa.chispa_changed.connect(_on_chispa_changed)

	player_health_bar.max_value = player_max_hp
	player_health_bar.value = player_hp
	enemy_health_bar.max_value = enemy_max_hp
	enemy_health_bar.value = enemy_hp

	rock_button.pressed.connect(_on_action_button_pressed.bind(CombatResolver.Choice.ROCK))
	paper_button.pressed.connect(_on_action_button_pressed.bind(CombatResolver.Choice.PAPER))
	scissors_button.pressed.connect(_on_action_button_pressed.bind(CombatResolver.Choice.SCISSORS))

	_set_phase(TurnPhase.PLAYER)


func _on_action_button_pressed(choice: CombatResolver.Choice) -> void:
	if current_phase != TurnPhase.PLAYER:
		return
	_play_round(choice)


func _on_chispa_changed(new_amount: int) -> void:
	chispa_label.text = "Chispa: %d" % new_amount


func _play_round(player_choice: CombatResolver.Choice) -> void:
	_set_phase(TurnPhase.RESOLUTION)

	var enemy_choice: CombatResolver.Choice = _roll_enemy_choice()
	var result: CombatResolver.Result = _resolver.resolve_round(player_choice, enemy_choice)

	match result:
		CombatResolver.Result.WINS_A:
			enemy_hp -= 1
		CombatResolver.Result.WINS_B:
			player_hp -= 1

	player_health_bar.value = player_hp
	enemy_health_bar.value = enemy_hp
	result_label.text = _describe_result(player_choice, enemy_choice, result)
	round_resolved.emit(player_choice, enemy_choice, result)

	if player_hp <= 0 or enemy_hp <= 0:
		_end_combat(enemy_hp <= 0)
		return

	await get_tree().create_timer(ROUND_DELAY_SECONDS).timeout
	_set_phase(TurnPhase.ENEMY)
	_set_phase(TurnPhase.PLAYER)


func _end_combat(player_won: bool) -> void:
	action_buttons_container.visible = false

	if not player_won:
		result_label.text += "\nPerdiste el combate."
		combat_ended.emit(player_won)
		return

	var reward := COMBAT_WIN_CHISPA_REWARD + Chispa.combat_win_chispa_bonus()
	Chispa.add_chispa(reward)
	result_label.text += "\n¡Ganaste el combate! (+%d Chispa)" % reward
	combat_ended.emit(player_won)


func _roll_enemy_choice() -> CombatResolver.Choice:
	var choices: Array = CombatResolver.Choice.values()
	return choices[_rng.randi_range(0, choices.size() - 1)] as CombatResolver.Choice


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
	phase_changed.emit(phase)
