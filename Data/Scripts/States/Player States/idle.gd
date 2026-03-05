extends State

@export var animation_player: AnimationPlayer

@onready var player: Player = get_parent().get_parent()


func begin_state():
	var input_vector = player.input_vector
	if input_vector != Vector2():
		state_machine.change_state("move")
		return
	animation_player.play("idle")
	

func physics_update(delta: float):
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
	if Input.is_action_just_pressed("dash"):
		player.input_vector = Vector2.from_angle(player.rotation)
		state_machine.change_state("dash")
	if Input.is_action_just_pressed("parry"):
		player.aim_vector =  Vector2.from_angle(player.rotation)
		state_machine.change_state("parry")
