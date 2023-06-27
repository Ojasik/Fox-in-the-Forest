extends KinematicBody2D

export (int) var speed
export (int) var gravity

var velocity = Vector2()
var facing = 1

func _physics_process(delta):
	# Atjauno Spraita horizontālo atspoguļošanu, pamatojoties uz x ātrumu
	$Sprite.flip_h = velocity.x > 0
	# Pievieno y ātrumam gravitāciju, reizinot ar delta laiku
	velocity.y += gravity * delta
	# Iestata x ātrumu, pamatojoties uz virziena un ātruma vērtībām
	velocity.x = facing * speed
	# Pārvieto un slīd, izmantojot aprēķināto ātrumu
	velocity = move_and_slide(velocity, Vector2(0, -1))
	# Iterē cauri visām sadursmēm, kas notikušas slīdes laikā
	for idx in range(get_slide_count()):
		# Iegūst sadursmes informāciju pašreizējai indeksei
		var collision = get_slide_collision(idx)
		# Pārbauda, vai sadursmes objekta nosaukums ir "Player"
		if collision.collider.name == "Player":
			# Izsauc "hurt()" funkciju uz sadursmes objekta (ja tāda funkcija ir pieejama)
			collision.collider.hurt()
		# Pārbauda, vai sadursmes normāles x vērtība nav nulle
		if collision.normal.x != 0:
			# Iestata virziena vērtību, pamatojoties uz sadursmes normāles x vērtības zīmi
			facing = sign(collision.normal.x)
			# Iestata y ātrumu ar negatīvu vērtību (piemēram, atspoguļojoties no sienas)
			velocity.y = -100
	# Pārbauda, vai objekta y pozīcija ir augstāka par 1000
	if position.y > 1000:
		# Atbrīvo objektu no atmiņas (iznīcina to)
		queue_free()

func take_damage():
	$AnimationPlayer.play('death')
	$CollisionShape2D.disabled = true
	set_physics_process(false)

func _on_AnimationPlayer_animation_finished(anim_name):
	if anim_name == 'death':
		queue_free()
