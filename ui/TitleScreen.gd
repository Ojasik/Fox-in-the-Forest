extends Control

onready var nameInput = $NameInput

func _ready():
	nameInput.grab_focus()

func _input(event):
	if event.is_action_pressed('ui_select'):
		var gameState = get_node("/root/GameState")
		var name = nameInput.text
		get_tree().change_scene(GameState.game_scene)
		gameState.set_player_name(name)
	
	if event.is_action_pressed('ui_cancel'):
		get_tree().quit()
