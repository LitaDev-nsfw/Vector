extends CharacterBody2D
class_name Enemy

enum AimTypes {
	AIMED,
	FORWARDED,
	ONE_WAY,
	AIMED_SPLIT,
	TWO_WAY,
	FOUR_WAY,
	FOUR_WAY_DIAGONAL,
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
@export var shot_angle: float = 0.0
@export_category("Laser ShotType Vars")
@export var fires_lasers: bool = false
@export var charge_up: float = 1.0
@export var laser_duration: float = 2.5
@export_category("Visual Tweaks")
##How much to offset bullet spawn by. This is applied to bullets equally, regardless of bullet direction
@export var overall_bullet_spawn_offset: Vector2
##How much to offset an individual bullet spawn by. This offset is rotated towards bullet direction.
@export var individual_bullet_spawn_offset: Vector2
## This value can be used to squish the offset vertically, to account for the skew created by the perspective
@export var vertical_skew: float = 1.0

var lasers: Array[Laser] = []
var is_alive = true
var target = CharacterBody2D
var damage_indicator_tween: Tween
var weapon_sprite_damage_indicator_tween: Tween
##Effects
var frozen := false

@onready var player: Player = get_tree().get_first_node_in_group("Player")
@onready var character_sprite: AnimatedSprite2D = find_child("Sprite")
@onready var shot_scene = preload("res://Scenes/shot.tscn")
@onready var laser_scene = preload("res://Scenes/laser.tscn")
@onready var damage_number_label_scene = preload("res://Scenes/damage_number_label.tscn")
@onready var animation_player: AnimationPlayer = find_child("AnimationPlayer")
@onready var weapon_sprite_container: Node2D = find_child("WeaponSpriteContainer")

const BASE_FIRE_DELAY = 5.0

signal enemy_died(enemy: Enemy)
signal transition_finished(transition_to: String)

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
				if sprite_frames.has_animation("shoot_two_way"):
					character_sprite.animation = "shoot_two_way"
					animation_set = true
			AimTypes.FOUR_WAY:
				if sprite_frames.has_animation("shoot_four_way"):
					character_sprite.animation = "shoot_four_way"
					animation_set = true
			AimTypes.FOUR_WAY_DIAGONAL:
				if sprite_frames.has_animation("shoot_four_way"):
					character_sprite.animation = "shoot_four_way"
					animation_set = true
		if !animation_set:
			if sprite_frames.has_animation("shoot"):
				character_sprite.animation = "shoot"
		if !fires_lasers:
			play_animation("shoot",1/shoot_delay_time)
		else:
			play_animation("shoot",charge_up)
			shoot()
	else:
		if !fires_lasers:
			play_animation("shoot_head",1/shoot_delay_time)
		else:
			play_animation("shoot_head",charge_up)
			shoot()
	return true

func shoot() -> bool:
	print("Firing")
	match aim_type:
		AimTypes.AIMED:
			if !target: return false
			if !fires_lasers:
				_create_shot((target.global_position - global_position).normalized())
			else:
				_create_laser((target.global_position - global_position)*1000)
		AimTypes.FORWARDED:
			if !target: return false
			if !fires_lasers:
				
				var distance_vector = (target.global_position - global_position)
				_create_shot((distance_vector+(target.velocity*distance_vector.length()/shot_speed)).normalized())
			else:
				var distance_vector = (target.global_position - global_position)
				_create_laser((distance_vector+(target.velocity*distance_vector.length()/(charge_up*60)))*1000)
		AimTypes.ONE_WAY:
			if !fires_lasers:
				_create_shot(Vector2.UP.normalized().rotated(shot_angle))
			else:
				_create_laser(Vector2.UP.rotated(shot_angle)*1000)
		AimTypes.AIMED_SPLIT:
			if !fires_lasers:
				var direction = (target.global_position - global_position).normalized()
				_create_shot(direction)
				_create_shot(direction.rotated(-bullet_spread))
				_create_shot(direction.rotated(bullet_spread))
			else:
				
				var direction = (target.global_position - global_position).normalized()
				_create_laser(direction)
				_create_laser(direction.rotated(bullet_spread))
				_create_laser(direction.rotated(-bullet_spread))
		AimTypes.TWO_WAY:
			if !fires_lasers:
				_create_shot(Vector2.UP.normalized().rotated(shot_angle))
				_create_shot(Vector2.UP.normalized().rotated(shot_angle+PI))
			else:
				_create_laser(Vector2.UP.rotated(shot_angle)*1000)
				_create_laser(Vector2.UP.rotated(shot_angle+PI)*1000)
		AimTypes.FOUR_WAY:
			if !fires_lasers:
				_create_shot(Vector2.UP.normalized().rotated(shot_angle))
				_create_shot(Vector2.UP.normalized().rotated(rotation+PI))
				_create_shot(Vector2.UP.normalized().rotated(rotation+0.5*PI))
				_create_shot(Vector2.UP.normalized().rotated(rotation-0.5*PI))
			else:
				print("Making Lasers")
				_create_laser(Vector2.UP.rotated(shot_angle)*1000)
				_create_laser(Vector2.UP.rotated(shot_angle+PI)*1000)
				_create_laser(Vector2.UP.rotated(shot_angle+0.5*PI)*1000)
				_create_laser(Vector2.UP.rotated(shot_angle-0.5*PI)*1000)
	target = null
	return true

func play_animation(animation_name: StringName, custom_speed: float = 1.0):
	animation_player.play(animation_name, -1, custom_speed)
	character_sprite.speed_scale = custom_speed
	if animation_name == "shoot_head" and optional_weapon_sprite:
		optional_weapon_sprite.speed_scale = custom_speed
		optional_weapon_sprite.play(optional_weapon_sprite.animation)

func inflict_effect(effect: Shot.ShotEffects, duration = 0):
	match effect:
		Shot.ShotEffects.FREEZE:
			print("FROZEN")
			var tween = create_tween()
			frozen = true
			tween.tween_property(self,"frozen",false,duration)

func take_damage(damage: float):
	health -= damage
	if !damage_indicator_tween or !damage_indicator_tween.is_running():
		damage_indicator_tween = create_tween()
		damage_indicator_tween.tween_property(character_sprite,"modulate",Color.RED,0.1)
		damage_indicator_tween.set_trans(Tween.TRANS_SINE)
		damage_indicator_tween.set_ease(Tween.EASE_IN)
		damage_indicator_tween.tween_property(character_sprite,"modulate",character_sprite.modulate,0.1)
	if optional_weapon_sprite and (!weapon_sprite_damage_indicator_tween or !weapon_sprite_damage_indicator_tween.is_running()):
		weapon_sprite_damage_indicator_tween = create_tween()
		weapon_sprite_damage_indicator_tween.tween_property(optional_weapon_sprite,"modulate",Color.RED,0.1)
		weapon_sprite_damage_indicator_tween.set_trans(Tween.TRANS_SINE)
		weapon_sprite_damage_indicator_tween.set_ease(Tween.EASE_IN)
		weapon_sprite_damage_indicator_tween.tween_property(optional_weapon_sprite,"modulate",optional_weapon_sprite.modulate,0.1)
	var damage_label: DamageNumberLabel = damage_number_label_scene.instantiate()
	damage_label.number = int(damage)
	get_tree().root.add_child(damage_label)
	damage_label.global_position = global_position
	damage_label.initialize()

func _create_shot(new_vector: Vector2) -> Shot:
	var shot_node: Shot = shot_scene.instantiate()
	shot_node.shot_owner = self
	shot_node.shot_speed = shot_speed
	shot_node.team = Shot.Teams.ENEMY
	get_tree().root.add_child(shot_node)
	var position_to_place_at = overall_bullet_spawn_offset + individual_bullet_spawn_offset.rotated(new_vector.angle())
	position_to_place_at = Vector2(position_to_place_at.x, position_to_place_at.y * vertical_skew)
	shot_node.global_position = to_global(position_to_place_at)
	shot_node.vector = new_vector
	return shot_node

func _create_laser(laser_target: Vector2) -> Laser:
	var laser_node: Laser = laser_scene.instantiate()
	laser_node.shot_owner = self
	laser_node.team = Shot.Teams.ENEMY
	var position_to_place_at = overall_bullet_spawn_offset + individual_bullet_spawn_offset.rotated(to_local(laser_target).angle())
	position_to_place_at = Vector2(position_to_place_at.x, position_to_place_at.y * vertical_skew)
	print("Position Placement: "+str(position_to_place_at))
	laser_node.global_position = to_global(position_to_place_at)
	
	laser_node.charge_time = charge_up
	laser_node.duration = laser_duration
	lasers.append(laser_node)
	get_tree().root.add_child(laser_node)
	laser_node.set_target(laser_target)
	return laser_node

func _transition_finished(transition_to):
	transition_finished.emit(transition_to)

func _ready(	):
	enemy_died.connect(E._on_enemy_died)
	E.enemy_died.connect(_on_enemy_died)
	character_sprite.sprite_frames = sprite_frames
	var shader: ShaderMaterial = character_sprite.material
	shader.set_shader_parameter("normal_map",normal_sheet)
	if optional_weapon_sprite:
		weapon_sprite_container.visible = true

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
