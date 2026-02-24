extends State

@export var idle_walk_time_min: float = 2.0
@export var idle_walk_time_max: float = 5.0
@export var idle_walk_speed: float = 15.0
@export var max_idle_range: float = 60.0
@export var robotic_idle: bool = false

var idle_target: Vector2
var wander_time: float = 0.0
var previous_position: Vector2
@onready var enemy: Enemy = get_parent().get_parent()


func update(delta):
	if !previous_position:
		previous_position = enemy.position
	if wander_time <= 0.0 or (enemy.spawn_position-enemy.position).length() > max_idle_range or (enemy.position - previous_position).length() < .9*idle_walk_speed*delta:
		print("New Direction")
		var vector = Vector2(randf_range(.5*max_idle_range,max_idle_range),0.0)
		vector = vector.rotated(randf_range(0,TAU))
		idle_target = enemy.spawn_position+vector
		wander_time = randf_range(idle_walk_time_min,idle_walk_time_max)
	var difference = idle_target-enemy.position
	if difference.length() > .5:
		enemy.velocity = difference.normalized()*idle_walk_speed
		previous_position = enemy.position
		enemy.move_and_slide()
	wander_time -= delta
	print("Distance from spawn: "+str((enemy.spawn_position-enemy.position).length()))
	for body in enemy.detection_area.get_overlapping_bodies():
		if (body is Player or body is NPC) and not body is Enemy:
			pass
