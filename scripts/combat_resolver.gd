class_name CombatResolver
extends RefCounted

enum Choice { ROCK, PAPER, SCISSORS, LIZARD, SPOCK }
enum Result { DRAW, WINS_A, WINS_B }

const BEATS := {
	Choice.ROCK: [Choice.SCISSORS, Choice.LIZARD],
	Choice.PAPER: [Choice.ROCK, Choice.SPOCK],
	Choice.SCISSORS: [Choice.PAPER, Choice.LIZARD],
	Choice.LIZARD: [Choice.SPOCK, Choice.PAPER],
	Choice.SPOCK: [Choice.SCISSORS, Choice.ROCK],
}


func resolve_round(a: Choice, b: Choice) -> Result:
	if a == b:
		return Result.DRAW
	if b in BEATS[a]:
		return Result.WINS_A
	return Result.WINS_B
