extends RayCast2D
class_name Laser


var team: Shot.Teams = Shot.Teams.PLAYER
var shot_owner: CharacterBody2D
var charge_time: float
var duration: float
var color: Color

var on_hit_effects: Array[Dictionary] = []

var active = false
@onready var line: Line2D = find_child("Line2D")
@onready var charge_up_timer: Timer = find_child("ChargeUpTimer")
@onready var duration_timer: Timer = find_child("DurationTimer")
@onready var hitbox: Area2D = find_child("Hitbox")
@onready var hitbox_segment: SegmentShape2D = find_child("HitboxSegment").shape

func _ready():
	charge_up_timer.start(charge_time)
	if team == Shot.Teams.PLAYER:
		color = Color(.4,.7,1,.5)
	else:
		color = Color(1,.4,.4,.5)
	modulate = color
	color = Color(color.r,color.g,color.b,.75)
	var tween := create_tween()
	tween.set_ease(Tween.EASE_OUT)
	tween.tween_property(self,'modulate',color,charge_time)
	color = Color(color.r,color.g,color.b,1)

func set_target(new_target: Vector2):
	print("Target: "+str(new_target))
	target_position = new_target
	force_raycast_update()
	if get_collision_point():
		line.points[1] = get_collision_point()
	else:
		line.points[1] = new_target

func _process(_delta: float) -> void:
	if !active:
		return
	for body in hitbox.get_overlapping_bodies():
		if body == shot_owner:
			continue
		if body is Enemy and team == Shot.Teams.PLAYER:
			var enemy: Enemy = body
			enemy.take_damage(shot_owner.get_attribute(Player.Attributes.DAMAGE)*shot_owner.current_combo)
		if body is Player and team == Shot.Teams.ENEMY:
			body.take_damage()

func _on_charge_up_timer_timeout() -> void:
	print("charge up timeout")
	duration_timer.start(duration)
	active = true
	modulate = color
	if get_collision_point():
		hitbox_segment.b = get_collision_point()
	else:
		hitbox_segment.b = target_position


func _on_duration_timer_timeout() -> void:
	print("duration timeout")
	active = false
	var fade_out_tween: Tween = create_tween()
	fade_out_tween.tween_property(self,"modulate",Color(color.r,color.g,color.b,0),0.5)
	fade_out_tween.tween_callback(get_parent().remove_child.bind(self))
	if shot_owner and shot_owner.get("lasers"):
		fade_out_tween.tween_callback(shot_owner.lasers.erase.bind(self))
	fade_out_tween.tween_callback(queue_free)
