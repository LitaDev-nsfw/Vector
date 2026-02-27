extends State


@export var detection_area: Area2D
@export var attack_delay_timer: Timer
@export var attack_windup_timer: Timer
@export var attack_windup: float = 1.0


@onready var owner_node: Enemy = get_parent().get_parent()

func begin_state():
	if attack_windup_timer:
		attack_windup_timer.start(attack_windup)

func update(_delta: float):
	if G.halt_actions or owner_node.frozen:
		return
	var player: Player
	if detection_area:
		if !detection_area.has_overlapping_bodies():
			state_machine.change_state("idle")
		for body in detection_area.get_overlapping_bodies():
			if body is Player:
				player = body
				break
		if !player:
			state_machine.change_state("idle")
	if !attack_delay_timer.is_stopped():
		return
	if attack_windup_timer and !attack_windup_timer.is_stopped():
		return
	if !player:
		player = get_tree().get_first_node_in_group("Player")
	owner_node.shoot(player)
	attack_delay_timer.start(owner_node.attack_delay)
