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
@export var max_health: int = 10:
	set(value):
		max_health = value
		if health > max_health:
			health = max_health
		else:
			health_changed.emit(health)

@export_category("Stat Modifiers")
@export var move_speed_mult: float = 1.0
@export var shot_speed_bonus: int = 10
@export var shot_speed_mult: float = 1.0
@export var fire_rate_bonus: int = 10
@export var fire_rate_mult: float = 1.0
@export var health: int = 6:
	set(value):
		health = value
		health_changed.emit(health)
		if health <= 0:
			queue_free()
@export var damage_bonus: int = 10
@export var damage_mult: float = 1.0
@export var bullet_size_mult: float = 1.0
@export var bullet_spread_mult: float = 1.0
@export var burst_count: int = 1

var input_vector: Vector2
var aim_vector: Vector2
var shot_type: ShotTypes = ShotTypes.SINGLE
var current_combo: float = 1.0:
	set(value):
		current_combo = max(value,1.0)
		if current_combo > 1.0:
			reset_current_combo_life()
var current_combo_life: float = 0.0

@onready var shot_scene = preload("res://Scenes/shot.tscn")

const BASE_FIRE_DELAY = 5
const BASE_MOVE_SPEED = 150
const BASE_SHOT_SPEED = 400
const GROUND_ACCELERATION = 10000000

signal health_changed(new_health: int)

func shoot():
	if G.halt_actions:
		return
	if !aim_vector: return
	match shot_type:
		ShotTypes.SINGLE:
			var shot: Shot = shot_scene.instantiate()
			shot.shot_owner = self
			shot.shot_speed = get_attribute(Attributes.SHOT_SPEED)
			shot.team = Shot.Teams.PLAYER
			shot.bullet_type = Shot.BulletTypes.STANDARD
			get_parent().add_child(shot)
			shot.global_position = global_position
			shot.vector = aim_vector

func get_attribute(attribute: Attributes):
	match attribute:
		Attributes.MOVE_SPEED: return BASE_MOVE_SPEED * clamp(move_speed_mult,move_speed_min,move_speed_max)
		Attributes.FIRE_RATE: return fire_rate_bonus * fire_rate_mult
		Attributes.SHOT_SPEED: return (BASE_SHOT_SPEED + shot_speed_bonus) * shot_speed_mult
		Attributes.DAMAGE: return damage_bonus * damage_mult

func take_damage():
	health -= 1

func reset_current_combo_life():
	current_combo_life = get_current_combo_life()

func get_current_combo_life() -> float:
	if current_combo == 1.0:
		return 0
	if current_combo >= 3.0:
		return 3/(floor(current_combo)-2.5)
	elif current_combo > 2.0:
		return 10
	else:
		return 15

func _ready():
	E.enemy_died.connect(_on_enemy_died)
	health_changed.connect(E._on_health_changed)


func _process(delta: float) -> void:
	input_vector = Input.get_vector("move_left","move_right","move_up","move_down")
	if input_vector.length() > 1:
		input_vector = input_vector.normalized()
	aim_vector = Input.get_vector("aim_left","aim_right","aim_up","aim_down").normalized()
	#print("Combo: "+str(current_combo)+" Life: "+str(current_combo_life))
	
	##Halt Actions Early Return
	if G.halt_actions:
		return
	if current_combo_life > 0:
		current_combo_life -= delta
	if current_combo_life <= 0 and current_combo > 1.0:
		current_combo -= 1.0

func _on_enemy_died(_enemy: Enemy):
	reset_current_combo_life()
