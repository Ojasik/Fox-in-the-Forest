extends Control

onready var scoreLabel = $ScoreLabel

func _ready():
	var gameState = get_node("/root/GameState")
	var score = gameState.get_score()
	scoreLabel.text = "Score: " + str(score)
	gameState.save_score_to_file()

func _input(event):
	if event.is_action_pressed('ui_select'):
		var gameState = get_node("/root/GameState")
		gameState.restart()
	
	if event.is_action_pressed('ui_cancel'):
		get_tree().quit()
