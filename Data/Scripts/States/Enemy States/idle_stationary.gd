extends State

@export var detection_hitbox: Area2D
@export var line_of_sight: RayCast2D
@export var head_rotation_speed: float = 1.0

var target_head_rotation

@onready var player: Player = get_tree().get_first_node_in_group("Player")
@onready var state_owner: Enemy = get_parent().get_parent()

func begin_state():
	target_head_rotation = randf_range(0, TAU)

func update(_delta: float):
	#print(detection_hitbox)
	var line_of_sight_satisfied = false
	if line_of_sight:
		line_of_sight.target_position = player.global_position - line_of_sight.global_position
		line_of_sight.force_raycast_update()
		if line_of_sight.get_collider() is Player:
			line_of_sight_satisfied = true
	if detection_hitbox:
		if detection_hitbox.has_overlapping_bodies():
			var player_found = false
			for body in detection_hitbox.get_overlapping_bodies():
				if body is Player:
					player_found = body
					break
			if player_found and (!line_of_sight or line_of_sight_satisfied): move_to_attack()
	if state_owner.optional_weapon_sprite:
		state_owner.weapon_sprite_container.rotation = move_toward(state_owner.weapon_sprite_container.rotation, target_head_rotation, head_rotation_speed)
		if state_owner.weapon_sprite_container.rotation == target_head_rotation:
			target_head_rotation = randf_range(0,TAU)

func move_to_attack():
	if state_machine.states.has("chase"):
		state_machine.change_state("chase")
	elif state_machine.states.has("attack"):
		state_machine.change_state("attack")
