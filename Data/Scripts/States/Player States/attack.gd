extends State

@export var animation_player: AnimationPlayer
@export var attack_timer: Timer
@export var move_state: State
@export var thruster_sprite: AnimatedSprite2D

@onready var player: Player = get_parent().get_parent()


func begin_state():
	var shoot_delay_time = player.BASE_FIRE_DELAY/player.get_attribute(Player.Attributes.FIRE_RATE)
	print(shoot_delay_time)
	animation_player.play("shoot",-1,1/shoot_delay_time)
	attack_timer.start(shoot_delay_time)
	#player.spawn_attack(Player.AttackTypes.SMALL_SLASH,player.get_attribute(Player.Attributes.STRENGTH))

func update(_delta):
	if attack_timer.is_stopped():
		state_machine.change_state("idle")
	if player.input_vector:
		move_state.do_move()
	else:
		thruster_sprite.visible = false
	if player.aim_vector:
		player.rotation = player.aim_vector.angle()+(.5*PI)
