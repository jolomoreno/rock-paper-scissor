extends SceneTree

const CombatResolver := preload("res://scripts/combat_resolver.gd")
const Choice := CombatResolver.Choice
const Result := CombatResolver.Result


func _initialize() -> void:
	var resolver := CombatResolver.new()

	_check(resolver, Choice.ROCK, Choice.ROCK, Result.DRAW)
	_check(resolver, Choice.ROCK, Choice.PAPER, Result.WINS_B)
	_check(resolver, Choice.ROCK, Choice.SCISSORS, Result.WINS_A)
	_check(resolver, Choice.ROCK, Choice.LIZARD, Result.WINS_A)
	_check(resolver, Choice.ROCK, Choice.SPOCK, Result.WINS_B)

	_check(resolver, Choice.PAPER, Choice.ROCK, Result.WINS_A)
	_check(resolver, Choice.PAPER, Choice.PAPER, Result.DRAW)
	_check(resolver, Choice.PAPER, Choice.SCISSORS, Result.WINS_B)
	_check(resolver, Choice.PAPER, Choice.LIZARD, Result.WINS_B)
	_check(resolver, Choice.PAPER, Choice.SPOCK, Result.WINS_A)

	_check(resolver, Choice.SCISSORS, Choice.ROCK, Result.WINS_B)
	_check(resolver, Choice.SCISSORS, Choice.PAPER, Result.WINS_A)
	_check(resolver, Choice.SCISSORS, Choice.SCISSORS, Result.DRAW)
	_check(resolver, Choice.SCISSORS, Choice.LIZARD, Result.WINS_A)
	_check(resolver, Choice.SCISSORS, Choice.SPOCK, Result.WINS_B)

	_check(resolver, Choice.LIZARD, Choice.ROCK, Result.WINS_B)
	_check(resolver, Choice.LIZARD, Choice.PAPER, Result.WINS_A)
	_check(resolver, Choice.LIZARD, Choice.SCISSORS, Result.WINS_B)
	_check(resolver, Choice.LIZARD, Choice.LIZARD, Result.DRAW)
	_check(resolver, Choice.LIZARD, Choice.SPOCK, Result.WINS_A)

	_check(resolver, Choice.SPOCK, Choice.ROCK, Result.WINS_A)
	_check(resolver, Choice.SPOCK, Choice.PAPER, Result.WINS_B)
	_check(resolver, Choice.SPOCK, Choice.SCISSORS, Result.WINS_A)
	_check(resolver, Choice.SPOCK, Choice.LIZARD, Result.WINS_B)
	_check(resolver, Choice.SPOCK, Choice.SPOCK, Result.DRAW)

	print("CombatResolver: las 25 combinaciones resuelven como se esperaba.")
	quit()


func _check(resolver: CombatResolver, a: Choice, b: Choice, expected: Result) -> void:
	var actual := resolver.resolve_round(a, b)
	assert(actual == expected, "resolve_round(%s, %s) esperaba %s, obtuvo %s" % [a, b, expected, actual])
