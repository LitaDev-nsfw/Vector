extends State

@export var animation_player: AnimationPlayer
@export var attack_timer: Timer
@export var move_state: State

@onready var player: Player = get_parent().get_parent()


func begin_state():
	var shoot_delay_time = player.BASE_FIRE_DELAY/player.get_attribute(Player.Attributes.FIRE_RATE)
	print(shoot_delay_time)
	animation_player.play("shoot",-1,1/shoot_delay_time)
	attack_timer.start(shoot_delay_time)
	#player.spawn_attack(Player.AttackTypes.SMALL_SLASH,player.get_attribute(Player.Attributes.STRENGTH))

func update(delta):
	if attack_timer.is_stopped():
		state_machine.change_state("idle")
	if player.input_vector:
		move_state.do_move(delta)
	if Input.is_action_just_pressed("dash"):
		state_machine.change_state("dash")
	if Input.is_action_just_pressed("parry"):
		state_machine.change_state("parry")
