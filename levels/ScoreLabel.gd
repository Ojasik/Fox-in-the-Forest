extends Node

onready var scoreLabel = $ScoreLabel

func _ready():
	update_score()

func update_score():
	var gameState = get_node("/root/GameState")
	var score = gameState.get_score()
	scoreLabel.text = "Score: " + str(score)
