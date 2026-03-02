extends State

@export var detection_hitbox: Area2D
@export var line_of_sight: RayCast2D
@export var initial_direction: Vector2 = Vector2(1,1)

var direction = initial_direction

@onready var state_owner: Enemy = get_parent().get_parent()
@onready var player: Player = get_tree().get_first_node_in_group("Player")


func begin_state():
	pass

func update(_delta: float):
	if G.halt_actions or state_owner.frozen:
		return
	#print(detection_hitbox)
	if state_owner.get_last_slide_collision():
		direction = direction.bounce(state_owner.get_last_slide_collision().get_normal())
	state_owner.velocity = direction.normalized() * state_owner.move_speed
	state_owner.move_and_slide()
	
	if line_of_sight:
		line_of_sight.target_position = player.global_position - line_of_sight.global_position
		line_of_sight.force_raycast_update()
		if not line_of_sight.get_collider() is Player:
			return
	if detection_hitbox:
		if !detection_hitbox.has_overlapping_bodies():
			return
		var player_found = false
		for body in detection_hitbox.get_overlapwdasping_bodies():
			if body is Player:
				player_found = body
				break
		if !player_found: return
	#print("test")
	if state_machine.states.has("chase"):
		state_machine.change_state("chase")
	elif state_machine.states.has("attack"):
		state_machine.change_state("attack")
