extends KinematicBody2D # Šis objekts paplašina KinematicBody2D klasi.

export (Vector2) var velocity # Publiskais mainīgais "velocity" norāda uz ātrumu, ar kuru objekts pārvietojas.

func _physics_process(delta): # Fizikālās apstrādes funkcija, kas tiek izsaukta katrā kadra apstrādes laikā.
	var collision = move_and_collide(velocity * delta) # Pārvieto objektu, pamatojoties uz tā ātrumu un laika starpību starp kadriem. Rezultātā iegūst kolīzijas informāciju.
	if collision: # Ja ir notikusi kolīzija.
		velocity = velocity.bounce(collision.normal) # Nomaina objekta ātrumu, veicot atlēcienu no kolīzijas normāles virzienā.
