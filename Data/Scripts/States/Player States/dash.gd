extends State


const DASH_TIME = .6
const DASH_LENGTH = 400

var tween: Tween

@onready var player: Player = get_parent().get_parent()


func begin_state():
	var animation_speed = 1.0/DASH_TIME
	print(animation_speed)
	player.animation_player.play("dash",-1,animation_speed)
	tween = create_tween()
	tween.set_ease(Tween.EASE_IN)
	#tween.set_trans(Tween.TRANS_SINE)
	tween.tween_property(player,"velocity",player.input_vector*DASH_LENGTH,DASH_TIME/2)
	tween.set_ease(Tween.EASE_OUT)
	tween.tween_property(player,"velocity",player.input_vector*player.get_attribute(Player.Attributes.MOVE_SPEED), DASH_TIME/2)
	tween.finished.connect(_on_tween_finished)

func update(_delta):
	if !tween and !player.animation_player.is_playing():
		state_machine.change_state("idle")
	if !G.halt_actions:
		player.move_and_slide()
	if player.frozen:
		tween.kill()
		state_machine.change_state("idle")


func _on_tween_finished():
	tween = null
