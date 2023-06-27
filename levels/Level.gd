extends Node2D

signal score_changed

var Collectible = preload('res://items/Collectible.tscn')
onready var pickups = $Pickups
onready var HUD = $CanvasLayer/HUD
var score

func _ready():
	$Player.connect('life_changed', $CanvasLayer/HUD, '_on_Player_life_changed') # Savieno signālu 'life_changed' no objekta Player ar metodi '_on_Player_life_changed' objektā HUD scēnā CanvasLayer.
	$Player.connect('dead', self, '_on_Player_dead')
	connect('score_changed', $CanvasLayer/HUD, '_on_score_changed') # Savieno signālu 'score_changed' no objekta Level ar metodi '_on_score_changed' objektā HUD scēnā CanvasLayer.
	score = GameState.get_score() 
	emit_signal('score_changed', score) # Izraisa signālu 'score_changed', nododot pašreizējo spēles rezultātu kā argumentu.
	pickups.hide()
	$Player.start($PlayerSpawn.position) # Iestāda spēlētāja pozīciju uz starta pozīciju objektā PlayerSpawn.
	set_camera_limits()
	spawn_pickups()

func set_camera_limits():
	var map_size = $World.get_used_rect() # Iegūst izmantojamās telpas robežas no objekta World un saglabā to mainīgajā map_size.
	var cell_size = $World.cell_size # Iegūst šūnas izmēru no objekta World un saglabā to mainīgajā cell_size.
	$Player/Camera2D.limit_left = (map_size.position.x - 5) * cell_size.x # Iestata kamerai ierobežojumu pa kreisi, pamatojoties uz izmantojamās telpas kreisās robežas.
	$Player/Camera2D.limit_right = (map_size.end.x + 5) * cell_size.x # Iestata kamerai ierobežojumu pa labi, pamatojoties uz izmantojamās telpas labās robežas.

func spawn_pickups():
	for cell in pickups.get_used_cells(): # Iterē caur visām izmantotajām šūnām objektā pickups.
		var id = pickups.get_cellv(cell) # Iegūst šūnas identifikatoru, izmantojot objektu pickups un šūnas koordinātes.
		var type = pickups.tile_set.tile_get_name(id) # Iegūst šūnas veidu, izmantojot objekta pickups tile_set un šūnas identifikatoru.
		if type in ['gem', 'cherry']: # Pārbauda, vai šūnas veids atbilst 'gem' vai 'cherry'.
			var c = Collectible.instance() # Izveido jaunu savācamo objektu, izmantojot savācamās klases instanci.
			var pos = pickups.map_to_world(cell) # Pārvērš šūnas koordinātas pasaules koordinātās, izmantojot objektu pickups.
			c.init(type, pos + pickups.cell_size/2) # Inicializē savācamo objektu, nosakot veidu un pozīciju telpā.
			add_child(c) # Pievieno savācamo objektu kā bērnu pašreizējam objektam (Level).
			c.connect('pickup', self, '_on_Collectible_pickup') # Savieno signālu 'pickup' no savācamā objekta ar metodi '_on_Collectible_pickup' pašreizējā objektā (Level).

func _on_Collectible_pickup():
	score += 1
	emit_signal('score_changed', score)
	GameState.set_score(score) 

func _on_Player_dead():
	GameState.restart()

func _on_Door_body_entered(body):
	GameState.next_level()

func _on_Ladder_body_entered(body):
	if body.name == "Player":
		body.is_on_ladder = true

func _on_Ladder_body_exited(body):
	if body.name == "Player":
		body.is_on_ladder = false
