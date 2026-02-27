extends State

@export var detection_hitbox: Area2D
@export var line_of_sight: RayCast2D

@onready var player: Player = get_tree().get_first_node_in_group("Player")


func begin_state():
	pass

func update(_delta: float):
	#print(detection_hitbox)
	if line_of_sight:
		line_of_sight.target_position = line_of_sight.global_position - player.global_position
		line_of_sight.force_raycast_update()
		if not line_of_sight.get_collider() is Player:
			return
	if detection_hitbox:
		if !detection_hitbox.has_overlapping_bodies():
			return
		var player: Player
		for body in detection_hitbox.get_overlapping_bodies():
			if body is Player:
				player = body
				break
		if !player: return
	#print("test")
	if state_machine.states.has("chase"):
		state_machine.change_state("chase")
	else:
		state_machine.change_state("attack")
