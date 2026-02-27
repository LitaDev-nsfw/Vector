extends State




@export var detection_area: Area2D
@export var line_of_sight: RayCast2D
@export var attack_delay_timer: Timer

@export var wander_radius: float
@export var wander_cooldown: float = 1.0

var target_point: Vector2
var current_wander_cooldown: float = 0
var starting_position: Vector2
var previous_position: Vector2

@onready var owner_node: Enemy = get_parent().get_parent()
@onready var player: Player = get_tree().get_first_node_in_group("Player")

func begin_state():
	starting_position = owner_node.global_position


func update(delta: float):
	if G.halt_actions or owner_node.frozen:
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
	elif target_point == owner_node.global_position or (previous_position != Vector2() and previous_position.distance_squared_to(owner_node.global_position) < .1):
		print(previous_position.distance_squared_to(owner_node.global_position))
		print("Starting Wander Cooldown")
		current_wander_cooldown = wander_cooldown
		owner_node.velocity = Vector2()
		target_point = Vector2()
	else:
		print("Wandering")
		previous_position = owner_node.global_positiond
		var direction = target_point - owner_node.global_position
		if direction.length() > 1:
			direction = direction.normalized()
		owner_node.velocity = direction * owner_node.move_speed * .8
		owner_node.move_and_slide()
	
	
	if detection_area:
		if !detection_area.has_overlapping_bodies():
			state_machine.change_state("idle")
		var player_found = false
		for body in detection_area.get_overlapping_bodies():
			if body is Player:
				player_found = body
				break
		if !player_found:
			state_machine.change_state("idle")
	if line_of_sight:
		line_of_sight.target_position = player.global_position - line_of_sight.global_position
		line_of_sight.force_raycast_update()
		if not line_of_sight.get_collider() is Player:
			state_machine.change_state("idle")
	if !attack_delay_timer.is_stopped():
		return
	owner_node.shoot(player)
	attack_delay_timer.start(owner_node.attack_delay)
