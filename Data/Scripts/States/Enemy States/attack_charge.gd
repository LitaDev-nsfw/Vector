extends State


@export var attack_delay_timer: Timer
@export var attack_windup_timer: Timer
@export var attack_windup: float = 1.0

var finished_attack = false
var line

@onready var state_owner: Enemy = get_parent().get_parent()
@onready var player: Player = get_tree().get_first_node_in_group("Player")

func begin_state():
	attack_windup_timer.start(attack_windup)
	state_owner.play_animation("charge", 1.0/attack_windup)
	state_owner.velocity = Vector2()
	

func update(_delta: float):
	if G.halt_actions or state_owner.frozen:
		return
	if state_owner.optional_weapon_sprite:
		state_owner.weapon_sprite_container.rotation = snapped(state_owner.global_position.angle_to_point(player.global_position),0.01)
		
	if !attack_delay_timer.is_stopped():
		return
	if attack_windup_timer and !attack_windup_timer.is_stopped():
		return
	if !line:
		line = [state_owner.global_position, player.global_position]
	if !finished_attack:
		state_owner.velocity = (line[1] - line[0]).normalized() * state_owner.move_speed
		state_owner.move_and_slide()
		if snapped(state_owner.velocity.angle(),.001) != snapped((line[1]-line[0]).angle(),.001):
			finished_attack = true
			state_owner.velocity = Vector2()
			state_owner.play_animation("stunned")
			attack_delay_timer.start(state_owner.attack_delay)
	if finished_attack and attack_delay_timer.is_stopped():
		state_machine.change_state("idle")
