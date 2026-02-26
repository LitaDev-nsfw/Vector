extends State

@export var thruster_sprite: AnimatedSprite2D

@onready var player: Player = get_parent().get_parent()



func do_move(delta):
	if G.halt_actions or player.frozen:
		return
	#print("Test")
	player.velocity = player.velocity.move_toward(player.input_vector * player.get_attribute(player.Attributes.MOVE_SPEED), player.GROUND_ACCELERATION*delta)
	#print(player.velocity)
	player.rotation = player.input_vector.angle()
	thruster_sprite.visible = false
	thruster_sprite.global_rotation = player.input_vector.angle()
	player.move_and_slide()

func begin_state():
	pass

func physics_update(delta: float):
	if G.halt_actions or player.frozen:
		return
	if player.input_vector == Vector2():
		state_machine.change_state("Idle")
	else:
		do_move(delta)
	if player.aim_vector:
		state_machine.change_state("shoot")
	if Input.is_action_just_pressed("dash"):
		state_machine.change_state("dash")
	if Input.is_action_just_pressed("parry"):
		player.aim_vector = Vector2.from_angle(player.rotation)
		state_machine.change_state("parry")
