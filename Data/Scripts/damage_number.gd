extends Label
class_name DamageNumberLabel


var number: int

const LIFE_TIME = 1
const ANGLE_RANGE = Vector2(0.1*PI,0.35*PI)
const MAGNITUDE_SCALAR = 0.1

func initialize():
	if !number:
		push_error("Damage Number Label Without Number")
	text = str(number)
	var vector = (Vector2.UP*clamp(number*2,20,120)).rotated(randf_range(ANGLE_RANGE.x,ANGLE_RANGE.y))
	var position_tween_x = create_tween()
	position_tween_x.tween_property(self,"position:x", position.x + vector.x*2,LIFE_TIME*number*MAGNITUDE_SCALAR)
	var position_tween_y = create_tween()
	position_tween_y.set_trans(Tween.TRANS_QUAD)
	position_tween_y.set_ease(Tween.EASE_OUT)
	position_tween_y.tween_property(self, "position:y", position.y + vector.y,LIFE_TIME*number*MAGNITUDE_SCALAR/2)
	position_tween_y.set_ease(Tween.EASE_IN)
	position_tween_y.tween_property(self, "position:y", position.y, LIFE_TIME*number*MAGNITUDE_SCALAR/2)
	var modulate_tween = create_tween()
	modulate_tween.tween_property(self,"modulate:a",0,LIFE_TIME*number*MAGNITUDE_SCALAR)
	modulate_tween.tween_callback(queue_free)
