extends State

@export var detection_hitbox: Area2D
@export var wander_radius: float
@export var wander_cooldown: float = 1.0

var target_point: Vector2
var current_wander_cooldown: float = 0
var starting_position: Vector2
var previous_position: Vector2

@onready var state_owner: Enemy = get_parent().get_parent()


func begin_state():
	starting_position = state_owner.global_position

func update(delta: float):
	if G.halt_actions or state_owner.frozen:
		return
	if current_wander_cooldown > 0:
		print("Running out cooldown")
		current_wander_cooldown -= delta
	elif target_point == Vector2():
		print("Selecting point")
		var vector: Vector2 = Vector2(randf_range(max(0,min(20,wander_radius-20)),wander_radius),0)
		vector = vector.rotated(randf_range(0,TAU))
		target_point = starting_position + vector
		previous_position = Vector2()
	elif target_point == state_owner.global_position or (previous_position != Vector2() and previous_position.distance_squared_to(state_owner.global_position) < .1):
		print(previous_position.distance_squared_to(state_owner.global_position))
		print("Starting Wander Cooldown")
		current_wander_cooldown = wander_cooldown
		state_owner.velocity = Vector2()
		target_point = Vector2()
	else:
		print("Wandering")
		previous_position = state_owner.global_position
		var direction = target_point - state_owner.global_position
		if direction.length() > 1:
			direction = direction.normalized()
		state_owner.velocity = direction * state_owner.move_speed * .8
		state_owner.move_and_slide()
		
	#print(detection_hitbox)
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
