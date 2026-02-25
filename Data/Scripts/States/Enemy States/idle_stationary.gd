extends State

@export var detection_hitbox: Area2D


func begin_state():
	pass

func update(_delta: float):
	print(detection_hitbox)
	if detection_hitbox:
		if !detection_hitbox.has_overlapping_bodies():
			return
		var player: Player
		for body in detection_hitbox.get_overlapping_bodies():
			if body is Player:
				player = body
				break
		if !player: return
	print("test")
	if state_machine.states.has("chase"):
		state_machine.change_state("chase")
	else:
		state_machine.change_state("attack")
