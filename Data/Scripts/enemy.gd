extends CharacterBody2D
class_name Enemy

enum AimTypes {
	AIMED,
	FORWARDED,
	ONE_WAY,
	AIMED_SPLIT,
	TWO_WAY,
	FOUR_WAY,
}


@export var health: float = 20:
	set(value):
		health = value
		if health <= 0:
			is_alive = false
			enemy_died.emit(self)
			queue_free()
@export var invincible: bool = false
@export var attack_delay: float = 3
@export var shot_speed: float = 350
@export var aim_type: AimTypes = AimTypes.AIMED
@export var grant_combo_on_death := 0.0
@export var sprite_sheet_dimensions := Vector2(1,1)
@export var flags: Array[String] = []
@export var bullet_spread: float = .125*PI

var is_alive = true


##Effects
var frozen := false

@onready var player: Player = get_tree().get_first_node_in_group("Player")
@onready var character_sprite: AnimatedSprite2D = find_child("Sprite")
@onready var shot_scene = preload("res://Scenes/shot.tscn")

signal enemy_died(enemy: Enemy)

func shoot(target: CharacterBody2D):
	if G.halt_actions or !$NewRoomCooldown.is_stopped():
		return
	match aim_type:
		AimTypes.AIMED:
			if !target: return
			var shot_node: Shot = _create_shot()
			shot_node.vector = (target.global_position - global_position).normalized()
			get_tree().root.add_child(shot_node)
		AimTypes.FORWARDED:
			if !target: return
			var shot_node: Shot = _create_shot()
			var distance_vector = (target.global_position - global_position)
			shot_node.vector = (distance_vector+(target.velocity*distance_vector.length()/shot_speed)).normalized()
			get_tree().root.add_child(shot_node)
		AimTypes.ONE_WAY:
			var shot_node: Shot = _create_shot()
			shot_node.vector = Vector2.UP.normalized().rotated(rotation)
			get_tree().root.add_child(shot_node)
		AimTypes.AIMED_SPLIT:
			var shot_node: Shot = _create_shot()
			var direction = (target.global_position - global_position).normalized()
			shot_node.vector = direction
			get_tree().root.add_child(shot_node)
			shot_node = _create_shot()
			shot_node.vector = direction.rotated(-bullet_spread)
			get_tree().root.add_child(shot_node)
			shot_node = _create_shot()
			shot_node.vector = direction.rotated(bullet_spread)
			get_tree().root.add_child(shot_node)
		AimTypes.TWO_WAY:
			var shot_node: Shot = _create_shot()
			shot_node.vector = Vector2.UP.normalized().rotated(rotation)
			get_tree().root.add_child(shot_node)
			shot_node = _create_shot()
			shot_node.vector = Vector2.UP.normalized().rotated(rotation+PI)
			get_tree().root.add_child(shot_node)
		AimTypes.FOUR_WAY:
			var shot_node: Shot = _create_shot()
			shot_node.vector = Vector2.UP.normalized().rotated(rotation)
			get_tree().root.add_child(shot_node)
			shot_node = _create_shot()
			shot_node.vector = Vector2.UP.normalized().rotated(rotation+PI)
			get_tree().root.add_child(shot_node)
			shot_node = _create_shot()
			shot_node.vector = Vector2.UP.normalized().rotated(rotation+0.5*PI)
			get_tree().root.add_child(shot_node)
			shot_node = _create_shot()
			shot_node.vector = Vector2.UP.normalized().rotated(rotation-0.5*PI)
			get_tree().root.add_child(shot_node)



func inflict_effect(effect: Shot.ShotEffects, duration = 0):
	match effect:
		Shot.ShotEffects.FREEZE:
			print("FROZEN")
			var tween = create_tween()
			frozen = true
			tween.tween_property(self,"frozen",false,duration)

func take_damage(damage: float):
	health -= damage

func _create_shot() -> Shot:
	var shot_node: Shot = shot_scene.instantiate()
	shot_node.shot_owner = self
	shot_node.shot_speed = shot_speed
	shot_node.team = Shot.Teams.ENEMY
	shot_node.global_position = global_position
	return shot_node

func _ready(	):
	enemy_died.connect(E._on_enemy_died)
	E.enemy_died.connect(_on_enemy_died)

func _on_enemy_died(enemy: Enemy):
	if flags.has("CONTRACT") and enemy != self:
		print("Rwemoving contract")
		var shader_material: ShaderMaterial = character_sprite.material
		shader_material.set_shader_parameter("outline_width", 0.0)
		grant_combo_on_death -= 1.0
		flags.erase("CONTRACT")
