extends State


const DASH_TIME = 0.2
const DASH_LENGTH = 1200

var tween: Tween

@onready var player: Player = get_parent().get_parent()

func begin_state():
	tween = create_tween()
	tween.set_ease(Tween.EASE_IN_OUT)
	tween.set_trans(Tween.TRANS_SINE)
	tween.tween_property(player,"velocity",player.input_vector*DASH_LENGTH,DASH_TIME)
	tween.tween_property(player,"velocity",player.input_vector*player.get_attribute(Player.Attributes.MOVE_SPEED),DASH_TIME/2)

func update(_delta):
	if !tween.is_running():
		state_machine.change_state("idle")
	player.move_and_slide()
