extends Node

func _ready():
	var currentLevelNum = str(GameState.current_level).pad_zeros(2)
	var levelPath = 'res://levels/Level%s.tscn' % currentLevelNum
	var levelScene = load(levelPath).instance()
	add_child(levelScene)
