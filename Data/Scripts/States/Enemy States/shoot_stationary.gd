extends State


@export var detection_area: Area2D
@export var attack_delay_timer: Timer
@export var attack_windup_timer: Timer
@export var attack_windup: float = 1.0
@export var line_of_sight: RayCast2D
@export var attack_once: bool = false

var has_attacked: bool = false

@onready var state_owner: Enemy = get_parent().get_parent()
@onready var player: Player = get_tree().get_first_node_in_group("Player")

func begin_state():
	has_attacked = false
	if attack_windup_timer:
		attack_windup_timer.start(attack_windup)
	state_owner.velocity = Vector2()

func update(_delta: float):
	if G.halt_actions or state_owner.frozen:
		return
	if detection_area:
		if !detection_area.has_overlapping_bodies():
			state_machine.change_state("idle")
		var player_found = false
		for body in detection_area.get_overlapping_bodies():
			if body is Player:
				player_found = true
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
	if attack_windup_timer and !attack_windup_timer.is_stopped():
		return
	if !attack_once or !has_attacked:
		state_owner.target = player
		if state_owner.pre_shoot():
			attack_delay_timer.start(state_owner.BASE_FIRE_DELAY/state_owner.attack_delay)
			has_attacked = true
	if attack_once:
		if state_owner.fires_lasers:
			if state_owner.lasers.is_empty():
				state_machine.change_state("idle")
		else:
			state_machine.change_state("idle")
