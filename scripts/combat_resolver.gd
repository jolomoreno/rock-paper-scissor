class_name CombatResolver
extends RefCounted

enum Choice { ROCK, PAPER, SCISSORS }
enum Result { DRAW, WINS_A, WINS_B }

const BEATS := {
	Choice.ROCK: Choice.SCISSORS,
	Choice.PAPER: Choice.ROCK,
	Choice.SCISSORS: Choice.PAPER,
}


func resolve_round(a: Choice, b: Choice) -> Result:
	if a == b:
		return Result.DRAW
	if BEATS[a] == b:
		return Result.WINS_A
	return Result.WINS_B
