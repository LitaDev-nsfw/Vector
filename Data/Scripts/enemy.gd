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

@export_category("Necessary")
@export var sprite_frames: SpriteFrames
@export var normal_sheet: CompressedTexture2D
@export var optional_weapon_sprite: AnimatedSprite2D
@export_category("Stats")
@export var health: float = 20:
	set(value):
		health = value
		if health <= 0:
			is_alive = false
			enemy_died.emit(self)
			if lasers:
				for laser: Laser in lasers.duplicate():
					laser.queue_free()
					lasers.erase(laser)
			queue_free()
@export var invincible: bool = false
@export var attack_delay: float = 3
@export var move_speed: float = 100
@export var shot_speed: float = 350
@export var aim_type: AimTypes = AimTypes.AIMED
@export var grant_combo_on_death := 0.0
@export var sprite_sheet_dimensions := Vector2(1,1)
@export var flags: Array[String] = []
@export var bullet_spread: float = .125*PI
@export_category("Laser ShotType Vars")
@export var fires_lasers: bool = false
@export var charge_up: float = 1.0
@export var laser_duration: float = 2.5

var lasers: Array[Laser] = []
var is_alive = true
var target = CharacterBody2D

##Effects
var frozen := false

@onready var player: Player = get_tree().get_first_node_in_group("Player")
@onready var character_sprite: AnimatedSprite2D = find_child("Sprite")
@onready var shot_scene = preload("res://Scenes/shot.tscn")
@onready var laser_scene = preload("res://Scenes/laser.tscn")
@onready var animation_player: AnimationPlayer = find_child("AnimationPlayer")
@onready var weapon_sprite_container: Node2D = find_child("WeaponSpriteContainer")

const BASE_FIRE_DELAY = 5.0

signal enemy_died(enemy: Enemy)

func pre_shoot() -> bool:
	if G.halt_actions or !$NewRoomCooldown.is_stopped():
		return false
	if fires_lasers and !lasers.is_empty():
		return false
	var shoot_delay_time = BASE_FIRE_DELAY/attack_delay
	var animation_set = false
	if !optional_weapon_sprite:
		match aim_type:
			AimTypes.TWO_WAY:
				if sprite_frames.get_animation_names().has("shoot_two_way"):
					character_sprite.animation = "shoot_two_way"
					animation_set = true
			AimTypes.FOUR_WAY:
				if sprite_frames.get_animation_names().has("shoot_four_way"):
					character_sprite.animation = "shoot_four_way"
					animation_set = true
		if !animation_set:
			if sprite_frames.get_animation_names().has("shoot"):
				character_sprite.animation = "shoot"
		if !fires_lasers:
			animation_player.play("shoot",-1,1/shoot_delay_time)
		else:
			animation_player.play("shoot",-1,charge_up)
			shoot()
	else:
		if !fires_lasers:
			animation_player.play("shoot_head",-1,1/shoot_delay_time)
		else:
			animation_player.play("shoot_head",-1,charge_up)
			shoot()
	return true

func shoot() -> bool:
	print("Firing")
	match aim_type:
		AimTypes.AIMED:
			if !target: return false
			if !fires_lasers:
				var shot_node: Shot = _create_shot()
				shot_node.vector = (target.global_position - global_position).normalized()
				get_tree().root.add_child(shot_node)
			else:
				var laser_node: Laser = _create_laser()
				get_tree().root.add_child(laser_node)
				laser_node.set_target((target.global_position - global_position)*1000)
		AimTypes.FORWARDED:
			if !target: return false
			if !fires_lasers:
				var shot_node: Shot = _create_shot()
				var distance_vector = (target.global_position - global_position)
				shot_node.vector = (distance_vector+(target.velocity*distance_vector.length()/shot_speed)).normalized()
				get_tree().root.add_child(shot_node)
			else:
				var laser_node: Laser = _create_laser()
				var distance_vector = (target.global_position - global_position)
				get_tree().root.add_child(laser_node)
				laser_node.set_target((distance_vector+(target.velocity*distance_vector.length()/(charge_up*60)))*1000)
		AimTypes.ONE_WAY:
			if !fires_lasers:
				var shot_node: Shot = _create_shot()
				shot_node.vector = Vector2.UP.normalized().rotated(rotation)
				get_tree().root.add_child(shot_node)
			else:
				var laser_node: Laser = _create_laser()
				get_tree().root.add_child(laser_node)
				laser_node.set_target(Vector2.UP*1000)
		AimTypes.AIMED_SPLIT:
			if !fires_lasers:
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
			else:
				var laser_node: Laser = _create_laser()
				var direction = (target.global_position - global_position).normalized()
				get_tree().root.add_child(laser_node)
				laser_node.set_target(direction)
				laser_node = _create_laser()
				get_tree().root.add_child(laser_node)
				laser_node.set_target(direction.rotated(bullet_spread))
				laser_node = _create_laser()
				get_tree().root.add_child(laser_node)
				laser_node.set_target(direction.rotated(-bullet_spread))
		AimTypes.TWO_WAY:
			if !fires_lasers:
				var shot_node: Shot = _create_shot()
				shot_node.vector = Vector2.UP.normalized().rotated(rotation)
				get_tree().root.add_child(shot_node)
				shot_node = _create_shot()
				shot_node.vector = Vector2.UP.normalized().rotated(rotation+PI)
				get_tree().root.add_child(shot_node)
			else:
				var laser_node: Laser = _create_laser()
				get_tree().root.add_child(laser_node)
				laser_node.set_target(Vector2.UP.rotated(rotation)*1000)
				laser_node = _create_laser()
				get_tree().root.add_child(laser_node)
				laser_node.set_target(Vector2.UP.rotated(rotation+PI)*1000)
		AimTypes.FOUR_WAY:
			if !fires_lasers:
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
			else:
				print("Making Lasers")
				var laser_node: Laser = _create_laser()
				get_tree().root.add_child(laser_node)
				laser_node.set_target(Vector2.UP.rotated(rotation)*1000)
				laser_node = _create_laser()
				get_tree().root.add_child(laser_node)
				laser_node.set_target(Vector2.UP.rotated(rotation+PI)*1000)
				laser_node = _create_laser()
				get_tree().root.add_child(laser_node)
				laser_node.set_target(Vector2.UP.rotated(rotation+0.5*PI)*1000)
				laser_node = _create_laser()
				get_tree().root.add_child(laser_node)
				laser_node.set_target(Vector2.UP.rotated(rotation-0.5*PI)*1000)
	target = null
	return true



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

func _create_laser() -> Laser:
	var laser_node: Laser = laser_scene.instantiate()
	laser_node.shot_owner = self
	laser_node.team = Shot.Teams.ENEMY
	laser_node.global_position = global_position
	laser_node.charge_time = charge_up
	laser_node.duration = laser_duration
	lasers.append(laser_node)
	return laser_node

func _ready(	):
	enemy_died.connect(E._on_enemy_died)
	E.enemy_died.connect(_on_enemy_died)
	character_sprite.sprite_frames = sprite_frames
	var shader: ShaderMaterial = character_sprite.material
	shader.set_shader_parameter("normal_map",normal_sheet)

func _process(_delta: float) -> void:
	if optional_weapon_sprite:
		var pi_removed_rotation = weapon_sprite_container.rotation
		if pi_removed_rotation < 0:
			pi_removed_rotation += TAU
		pi_removed_rotation /= PI
		print(pi_removed_rotation)
		if pi_removed_rotation > 1.75 or pi_removed_rotation < .25:
			optional_weapon_sprite.animation = "shoot_down"
		elif pi_removed_rotation > 1.25:
			optional_weapon_sprite.animation = "shoot_right"
		elif pi_removed_rotation > .75:
			optional_weapon_sprite.animation = "shoot_up"
		elif pi_removed_rotation > .25:
			optional_weapon_sprite.animation = "shoot_left"

func _on_enemy_died(enemy: Enemy):
	if flags.has("CONTRACT") and enemy != self:
		print("Rwemoving contract")
		var shader_material: ShaderMaterial = character_sprite.material
		shader_material.set_shader_parameter("outline_width", 0.0)
		grant_combo_on_death -= 1.0
		flags.erase("CONTRACT")
