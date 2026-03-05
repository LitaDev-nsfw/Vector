extends State

@onready var player: Player = get_parent().get_parent()


func begin_state():
	var input_vector = player.input_vector
	if input_vector != Vector2():
		state_machine.change_state("move")
		return
	print('play idle animation')
	player.character_sprite.play("idle")
	

func physics_update(delta: float):
	if !player.animation_player.is_playing():
		player.animation_player.play("idle")
	if G.halt_actions or player.frozen:
		return
	var input_vector = player.input_vector
	if input_vector != Vector2():
		state_machine.change_state("move")
	else:
		player.velocity = player.velocity.move_toward(Vector2(),player.GROUND_ACCELERATION*delta)
		player.move_and_slide()
	if player.aim_vector:
		state_machine.change_state("shoot")
