extends Node

var num_levels = 4
var current_level = 1

var game_scene = 'res://Main.tscn'
var title_screen = 'res://ui/TitleScreen.tscn'
var score = 0

func _ready():
	score = 0

func restart():
	current_level = 1
	score = 0  
	get_tree().change_scene(title_screen)

func next_level():
	current_level += 1
	if current_level <= num_levels:
		get_tree().reload_current_scene()
	else:
		var endScreen = preload("res://levels/Level04.tscn").instance()
		get_tree().get_root().add_child(endScreen)

func get_score() -> int:
	return score

func set_score(new_score: int):
	score = new_score

func decrease_life():
	score -= 1
	if score < 0:
		score = 0  
