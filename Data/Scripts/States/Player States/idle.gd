extends State

@export var thruster_sprite: AnimatedSprite2D

@onready var player: Player = get_parent().get_parent()


func begin_state():
	pass

func physics_update(_delta: float):
	var input_vector = player.input_vector
	if input_vector != Vector2():
		state_machine.change_state("move")
	else:
		thruster_sprite.visible = false
		player.velocity = Vector2()
		player.move_and_slide()
	if player.aim_vector:
		state_machine.change_state("shoot")
