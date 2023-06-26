extends Node

var num_levels = 4
var current_level = 1
var player_name = ""
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

func get_score() -> int:
	return score

func set_score(new_score: int):
	score = new_score

func decrease_life():
	score -= 1
	if score < 0:
		score = 0

func set_player_name(name: String):
	player_name = name

func save_score_to_file():
	var contents = ""
	var file = File.new()
	if file.open("user_scores.txt", File.READ) == OK:
		contents = file.get_as_text()
		file.close()

	if file.open("user_scores.txt", File.WRITE) == OK:
		file.store_string(contents)
		file.store_line("Player Name: " + player_name)
		file.store_line("Score: " + str(score))
		file.store_line("")  
		file.store_string("\n") 
		file.close()
