extends Node

@export var reticle_max_distance := 100

var target_rotation: float

@onready var ray_cast: RayCast2D = find_child("RayCast2D")
@onready var reticle_sprite: Sprite2D = find_child("Reticle")

func _ready():
	ray_cast.target_position = Vector2(reticle_max_distance*1.15, 0)

func _process(_delta: float) -> void:
	if !get_parent().aim_vector:
		reticle_sprite.visible = false
		return
	reticle_sprite.visible = true
	ray_cast.global_position = get_parent().global_position
	ray_cast.rotation = get_parent().aim_vector.angle()
	if ray_cast.is_colliding():
		reticle_sprite.global_position = get_parent().global_position + (ray_cast.get_collision_point() - get_parent().global_position)*.9
	else:
		reticle_sprite.global_position = get_parent().global_position + get_parent().aim_vector * reticle_max_distance
