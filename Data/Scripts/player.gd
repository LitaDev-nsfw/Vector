extends CharacterBody2D
class_name Player

enum Attributes {
	MOVE_SPEED,
	SHOT_SPEED,
	FIRE_RATE,
	HEALTH,
	DAMAGE,
	BULLET_SIZE,
	BURST_COUNT
}

enum ShotTypes {
	SINGLE,
	DOUBLE,
	TRIPLE,
	SHOTGUN,
	DOUBLE_SHOTGUN,
	TRIPLE_SHOTGUN,
}

@export_category("Limits")
@export var move_speed_min: float = 0.25
@export var move_speed_max: float = 3.0
@export var bullet_size_min: float = 0.25
@export var bullet_size_max: float = 4.0
@export var max_health: int = 10

@export_category("Stat Modifiers")
@export var move_speed_mult: float = 1.0
@export var shot_speed_bonus: int = 10
@export var shot_speed_mult: float = 1.0
@export var fire_rate_bonus: int = 10
@export var fire_rate_mult: float = 1.0
@export var health: int = 3
@export var damage_bonus: int = 10
@export var damage_mult: float = 1.0
@export var bullet_size_mult: float = 1.0
@export var bullet_spread_mult: float = 1.0
@export var burst_count: int = 1

var input_vector: Vector2
var aim_vector: Vector2
var shot_type: ShotTypes = ShotTypes.SINGLE

@onready var shot_scene = preload("res://Scenes/shot.tscn")

const BASE_FIRE_DELAY = 15
const BASE_MOVE_SPEED = 100
const BASE_SHOT_SPEED = 100

func shoot():
	if !aim_vector: return
	match shot_type:
		ShotTypes.SINGLE:
			var shot: Shot = shot_scene.instantiate()
			shot.shot_owner = self
			shot.shot_speed = get_attribute(Attributes.SHOT_SPEED)
			get_parent().add_child(shot)
			shot.global_position = global_position
			shot.vector = aim_vector

func get_attribute(attribute: Attributes):
	match attribute:
		Attributes.MOVE_SPEED: return BASE_MOVE_SPEED * clamp(move_speed_mult,move_speed_min,move_speed_max)
		Attributes.FIRE_RATE: return fire_rate_bonus * fire_rate_mult
		Attributes.SHOT_SPEED: return (BASE_SHOT_SPEED + shot_speed_bonus) * shot_speed_mult

func _process(delta: float) -> void:
	input_vector = Input.get_vector("move_left","move_right","move_up","move_down")
	if input_vector.length() > 1:
		input_vector = input_vector.normalized()
	aim_vector = Input.get_vector("aim_left","aim_right","aim_up","aim_down").normalized()
