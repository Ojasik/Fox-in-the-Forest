extends Control

func _input(event):
	if event.is_action_pressed('ui_select'):
		var gameState = get_node("/root/GameState")
		gameState.restart()
