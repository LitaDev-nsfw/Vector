extends State

@export var detection_hitbox: Area2D
@export var line_of_sight: RayCast2D
@export var teleport_checker: Area2D
@export var teleport_radius: float
@export var teleport_cooldown: float = 1.0

var target_point: Vector2
var current_teleport_cooldown: float = 0

@onready var player: Player = get_tree().get_first_node_in_group("Player")
@onready var state_owner: Enemy = get_parent().get_parent()



func update(delta: float):
	if G.halt_actions or state_owner.frozen:
		return
	if current_teleport_cooldown > 0:
		print("Running out cooldown")
		state_owner.play_animation("idle")
		current_teleport_cooldown -= delta
	elif target_point == Vector2():
		print("Selecting point")
		var vector: Vector2 = Vector2(randf_range(max(0,min(20,teleport_radius-20)),teleport_radius),0)
		vector = vector.rotated(randf_range(0,TAU))
		target_point = state_owner.position + vector
		var room: Room = state_owner.get_parent()#.get_parent()
		teleport_checker.position = vector
		await get_tree().create_timer(.01).timeout
		if room.is_inside_room(target_point) and !teleport_checker.has_overlapping_bodies():
			state_owner.position = target_point
			current_teleport_cooldown = teleport_cooldown
		target_point = Vector2()
		
	#print(detection_hitbox)
	if detection_hitbox:
		if !detection_hitbox.has_overlapping_bodies():
			return
		var player_found = false
		for body in detection_hitbox.get_overlapping_bodies():
			if body is Player:
				player_found = true
				break
		if !player_found: return
	if line_of_sight:
		line_of_sight.target_position = player.global_position - line_of_sight.global_position
		line_of_sight.force_raycast_update()
		if not line_of_sight.get_collider() is Player:
			return
	#print("test")
	if state_machine.states.has("chase"):
		state_machine.change_state("chase")
	elif state_machine.states.has("attack"):
		state_machine.change_state("attack")
