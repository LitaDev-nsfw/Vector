extends State

@export var thruster_sprite: AnimatedSprite2D

@onready var player: Player = get_parent().get_parent()


func do_move():
	player.velocity = player.input_vector * player.get_attribute(player.Attributes.MOVE_SPEED)
	if !player.aim_vector:
		player.rotation = player.input_vector.angle()+(.5*PI)
	thruster_sprite.visible = true
	thruster_sprite.global_rotation = player.input_vector.angle()+(.5*PI)
	player.move_and_slide()

func begin_state():
	pass

func physics_update(_delta: float):
	if player.input_vector == Vector2():
		state_machine.change_state("Idle")
	else:
		do_move()
	if player.aim_vector:
		state_machine.change_state("shoot")
