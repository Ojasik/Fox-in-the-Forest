extends KinematicBody2D  # Šis objekts paplašina KinematicBody2D klasi.

signal life_changed  # Signāls, kas tiek izsaukts, kad mainās dzīvības vērtība.
signal dead  # Signāls, kas tiek izsaukts, kad objekts nomirst.

export (int) var run_speed  # Publiskais mainīgais "run_speed" norāda uz objekta skriešanas ātrumu.
export (int) var jump_speed  # Publiskais mainīgais "jump_speed" norāda uz objekta lēciena ātrumu.
export (int) var gravity  # Publiskais mainīgais "gravity" norāda uz objekta gravitācijas spēku.
export (int) var climb_speed  # Publiskais mainīgais "climb_speed" norāda uz objekta kāpšanas ātrumu.

enum {IDLE, RUN, JUMP, HURT, DEAD, CROUCH, CLIMB}  # Stāvokļu pārskaitļošanas tips, kas norāda objekta iespējamos stāvokļus.
var state  # Pašreizējais objekta stāvoklis.
var anim  # Pašreizējā animācija.
var new_anim  # Jaunā animācija.
var velocity = Vector2()  # Objekta ātrums.
var life  # Dzīvību skaits.
var max_jumps = 2  # Maksimālais lēcienus skaits, ko var veikt.
var jump_count = 0  # Pašreizējais lēcienus skaits.
var is_on_ladder = false  # Norāda, vai objekts atrodas uz kāpnēm.

func _ready():  # Funkcija, kas tiek izsaukta, kad objekts ir gatavs.
	change_state(IDLE)  # Maina objekta stāvokli uz IDLE.

func start(pos):  # Funkcija, kas sāk objekta pozīcijas iestatīšanu.
	position = pos  # Iestata objekta pozīciju.
	show()  # Parāda objektu.
	life = 3  # Iestata dzīvību skaitu.
	emit_signal('life_changed', life)  # Izsauc signālu "life_changed" ar dzīvību skaitu kā parametru.
	change_state(IDLE)  # Maina objekta stāvokli uz IDLE.

func change_state(new_state):  # Funkcija, kas maina objekta stāvokli.
	state = new_state  # Iestata jauno stāvokli.
	match state:  # Pārbauda jaunā stāvokļa vērtību.
		IDLE:
			new_anim = 'idle'  # Iestata jaunu animāciju "idle".
		RUN:
			new_anim = 'run'  # Iestata jaunu animāciju "run".
		CROUCH:
			new_anim = 'crouch'  # Iestata jaunu animāciju "crouch".
		HURT:
			new_anim = 'hurt'  # Iestata jaunu animāciju "hurt".
			velocity.y = -200  # Iestata objekta ātrumu "y" ass virzienā uz augšu.
			velocity.x = -100 * sign(velocity.x)  # Iestata objekta ātrumu "x" ass virzienā atkarībā no tās pašreizējā ātruma.
			life -= 1  # Samazina dzīvību skaitu par 1.
			emit_signal('life_changed', life)  # Izsauc signālu "life_changed" ar jauno dzīvību skaitu kā parametru.
			yield(get_tree().create_timer(0.5), 'timeout')  # Pauze uz 0.5 sekundēm.
			change_state(IDLE)  # Maina objekta stāvokli uz IDLE.
			if life <= 0:  # Ja dzīvību skaits ir mazāks vai vienāds ar 0.
				change_state(DEAD)  # Maina objekta stāvokli uz DEAD.
		JUMP:
			new_anim = 'jump_up'  # Iestata jaunu animāciju "jump_up".
			jump_count = 1  # Iestata pašreizējo lēcienus skaitu uz 1.
		CLIMB:
			new_anim = 'climb'  # Iestata jaunu animāciju "climb".
		DEAD:
			hide()  # Paslēpj objektu.
			emit_signal('dead')  # Izsauc signālu "dead".

func get_input():  # Funkcija, kas iegūst lietotāja ievadi.
	if state == HURT:  # Ja objekta stāvoklis ir HURT.
		return  # Iziet no funkcijas.
	velocity.x = 0  # Iestata objekta ātrumu "x" ass virzienā uz 0.
	var right = Input.is_action_pressed('right')  # Pārbauda, vai tiek nospiesta taustiņa darbība "right".
	var left = Input.is_action_pressed('left')  # Pārbauda, vai tiek nospiesta taustiņa darbība "left".
	var jump = Input.is_action_just_pressed('jump')  # Pārbauda, vai tiek nospiesta taustiņa darbība "jump".
	var down = Input.is_action_pressed('crouch')  # Pārbauda, vai tiek nospiesta taustiņa darbība "crouch".
	var climb = Input.is_action_pressed('climb')  # Pārbauda, vai tiek nospiesta taustiņa darbība "climb".

	if climb and state != CLIMB and is_on_ladder:  # Ja tiek nospiesta taustiņa darbība "climb" un objekta stāvoklis nav CLIMB un objekts atrodas uz kāpnēm.
		change_state(CLIMB)  # Maina objekta stāvokli uz CLIMB.
	if state == CLIMB:  # Ja objekta stāvoklis ir CLIMB.
		if climb:  # Ja tiek nospiesta taustiņa darbība "climb".
			velocity.y = -climb_speed  # Iestata objekta ātrumu "y" ass virzienā uz augšu ar kāpšanas ātrumu.
		elif down:  # Ja tiek nospiesta taustiņa darbība "crouch".
			velocity.y = climb_speed  # Iestata objekta ātrumu "y" ass virzienā uz leju ar kāpšanas ātrumu.
		else:
			velocity.y = 0  # Iestata objekta ātrumu "y" ass virzienā uz 0.
			$AnimationPlayer.play("climb")  # Atskaņo animāciju "climb".
	if state == CLIMB and not is_on_ladder:  # Ja objekta stāvoklis ir CLIMB un tas neatrodas uz kāpnēm.
		change_state(IDLE)  # Maina objekta stāvokli uz IDLE.
	if down and is_on_floor():  # Ja tiek nospiesta taustiņa darbība "crouch" un objekts atrodas uz grīdas.
		change_state(CROUCH)  # Maina objekta stāvokli uz CROUCH.
	if !down and state == CROUCH:  # Ja taustiņa darbība "crouch" nav nospiesta un objekta stāvoklis ir CROUCH.
		change_state(IDLE)  # Maina objekta stāvokli uz IDLE.
	if right:  # Ja tiek nospiesta taustiņa darbība "right".
		velocity.x += run_speed  # Palielina objekta ātrumu "x" ass virzienā par skriešanas ātrumu.
		$Sprite.flip_h = false  # Izgriež objekta vizuālo reprezentāciju horizontāli pa labi.
	if left:  # Ja tiek nospiesta taustiņa darbība "left".
		velocity.x -= run_speed  # Samazina objekta ātrumu "x" ass virzienā par skriešanas ātrumu.
		$Sprite.flip_h = true  # Izgriež objekta vizuālo reprezentāciju horizontāli pa kreisi.
	if jump and state == JUMP and jump_count < max_jumps:  # Ja tiek nospiesta taustiņa darbība "jump", objekta stāvoklis ir JUMP un lēcienus skaits ir mazāks par maksimālo lēcienus skaitu.
		new_anim = 'jump_up'  # Iestata jaunu animāciju "jump_up".
		velocity.y = jump_speed / 1.5  # Iestata objekta ātrumu "y" ass virzienā uz augšu ar lēciena ātrumu, sadalot to ar 1.5.
		jump_count += 1  # Palielina pašreizējo lēcienus skaitu par 1.
	if jump and is_on_floor():  # Ja tiek nospiesta taustiņa darbība "jump" un objekts atrodas uz grīdas.
		change_state(JUMP)  # Maina objekta stāvokli uz JUMP.
		velocity.y = jump_speed  # Iestata objekta ātrumu "y" ass virzienā uz augšu ar lēciena ātrumu.
	if state in [IDLE, CROUCH] and velocity.x != 0:  # Ja objekta stāvoklis ir IDLE vai CROUCH un objekta ātrums "x" ass virzienā nav 0.
		change_state(RUN)  # Maina objekta stāvokli uz RUN.
	if state == RUN and velocity.x == 0:  # Ja objekta stāvoklis ir RUN un objekta ātrums "x" ass virzienā ir 0.
		change_state(IDLE)  # Maina objekta stāvokli uz IDLE.
	if state in [IDLE, RUN] and !is_on_floor():  # Ja objekta stāvoklis ir IDLE vai RUN un objekts neatrodas uz grīdas.
		change_state(JUMP)  # Maina objekta stāvokli uz JUMP.

func _physics_process(delta):  # Funkcija, kas tiek izsaukta fizikas procesa laikā.
	if state != CLIMB:  # Ja objekta stāvoklis nav CLIMB.
		velocity.y += gravity * delta  # Pieliek gravitācijas spēku objekta ātrumam "y" ass virzienā, reizinot to ar laika soli.
	get_input()  # Iegūst lietotāja ievadi.
	if new_anim != anim:  # Ja jaunā animācija nav vienāda ar pašreizējo animāciju.
		anim = new_anim  # Iestata pašreizējo animāciju uz jauno animāciju.
		$AnimationPlayer.play(anim)  # Atskaņo animāciju.

	velocity = move_and_slide(velocity, Vector2(0, -1))  # Pārvieto objektu, izmantojot slīdēšanas kustību un objekta ātrumu.
	if state == HURT:  # Ja objekta stāvoklis ir HURT.
		return  # Iziet no funkcijas.
	for idx in range(get_slide_count()):  # Ciklē cauri visiem slīdēšanas sadursmei.
		var collision = get_slide_collision(idx)  # Iegūst slīdēšanas sadursmes informāciju.
		if collision.collider.name == 'Danger':  # Ja sadursmes objekts ir nosaukts "Danger".
			hurt()  # Izsauc funkciju "hurt()".
		if collision.collider.is_in_group('enemies'):  # Ja sadursmes objekts ir grupā "enemies".
			var player_feet = (position + $CollisionShape2D.shape.extents).y  # Iegūst spēlētāja kāju pozīciju.
			if player_feet < collision.collider.position.y:  # Ja spēlētāja kājas atrodas zem sadursmes objekta.
				collision.collider.take_damage()  # Izsauc funkciju "take_damage()" sadursmes objektam.
				velocity.y = -200  # Iestata objekta ātrumu "y" ass virzienā uz augšu.
			else:
				hurt()  # Izsauc funkciju "hurt()".

	if state == JUMP and velocity.y > 0:  # Ja objekta stāvoklis ir JUMP un objekta ātrums "y" ass virzienā ir lielāks par 0.
		new_anim = 'jump_down'  # Iestata jaunu animāciju "jump_down".
	if state == JUMP and is_on_floor():  # Ja objekta stāvoklis ir JUMP un objekts atrodas uz grīdas.
		change_state(IDLE)  # Maina objekta stāvokli uz IDLE.
		$Dust.emitting = true  # Ieslēdz putekļu emisiju.
	if position.y > 1000:  # Ja objekta pozīcija "y" ass virzienā ir lielāka par 1000.
		change_state(DEAD)  # Maina objekta stāvokli uz DEAD.

func hurt():  # Funkcija, kas tiek izsaukta, ja objekts tiek ievainots.
	if state != HURT:  # Ja objekta stāvoklis nav HURT.
		change_state(HURT)  # Maina objekta stāvokli uz HURT.
