extends CharacterBody2D
class_name Player

enum Attributes {
	MOVE_SPEED,
	SHOT_SPEED,
	FIRE_RATE,
	HEALTH,
	DAMAGE,
	BULLET_SIZE,
	BURST_COUNT,
	KILL_TIME,
	DAMAGE_COMBO_METER_LOSS
}

enum Expressions {
	HAPPY,
	NEUTRAL
}

enum ShotTypes {
	SINGLE,
	DOUBLE,
	TRIPLE,
	QUAD,
}

enum WeaponTypes {
	PISTOL,
	SHOTGUN,
	LASER,
	MINIGUN,
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
			get_tree().change_scene_to_file("res://Scenes/main_menu.tscn")
		if is_node_ready():
			update_sprite_health_colors()
		
@export var damage_bonus: int = 10
@export var damage_mult: float = 1.0
@export var bullet_size_mult: float = 1.0
@export var bullet_spread_mult: float = 1.0
@export var burst_count: int = 1
@export var kill_time_bonus: int = 3
@export var kill_time_mult: float = 1.0
@export var damage_combo_meter_loss_modifier: float = 1.0

@export_category("Weapon and Shot")
@export var shot_type: ShotTypes = ShotTypes.SINGLE
@export var weapon_type: WeaponTypes = WeaponTypes.PISTOL


var input_vector: Vector2
var aim_vector: Vector2
var current_combo: float = 1.0:
	set(value):
		current_combo = max(value,1.0)
		if current_combo > 1.0:
			reset_current_combo_life()
var current_combo_life: float = 0.0
var invuln_time_modifier: float = 0.0
var tokens: int = 0
var token_tween: Tween
var current_expression: Expressions = Expressions.NEUTRAL
##Effects
var frozen := false


@onready var shot_scene = preload("res://Scenes/shot.tscn")
@onready var item_manager: ItemManager = find_child("ItemManager")
@onready var invuln_timer: Timer = find_child("InvulnTimer")
@onready var tokens_counter: Label = find_child("Tokens")
@onready var character_sprite: AnimatedSprite2D = find_child("CharacterSprite")
@onready var expression_sprite: AnimatedSprite2D = find_child("ExpressionSprite")
@onready var weapon_sprite_container: Node2D = find_child("WeaponSpriteContainer")
@onready var weapon_sprite: AnimatedSprite2D = find_child("WeaponSprite")
@onready var animation_player: AnimationPlayer = find_child("AnimationPlayer")

const BASE_FIRE_DELAY = 5
const BASE_MOVE_SPEED = 150
const BASE_SHOT_SPEED = 400
const BASE_DAMAGE_COMBO_METER_LOSS = 1
const GROUND_ACCELERATION = 10000000
const BASE_INVULN_TIME = 1.0
const DOUBLE_SHOT_SPREAD = 5.0
const FLASH_RATE = 6

signal health_changed(new_health: int)

func get_centered_position() -> Vector2:
	print("Centered Position: "+str(global_position + character_sprite.offset))
	return global_position + character_sprite.offset

func update_sprite_health_colors():
	var max_health_color = Color.LIME
	var mid_health_color = Color(1.0,.7,0,1)
	var low_health_color = Color.RED
	@warning_ignore("integer_division")
	if health >= max_health/2:
		expression_sprite.modulate = mid_health_color.lerp(max_health_color,float(health-0.5*max_health)/(0.5*max_health))
	else:
		expression_sprite.modulate = low_health_color.lerp(mid_health_color,float(health)/(0.5*max_health))

func create_shot(new_aim_vector: Vector2) -> Shot:
	var shot: Shot
	shot = shot_scene.instantiate()
	shot.shot_owner = self
	shot.shot_speed = get_attribute(Attributes.SHOT_SPEED)
	shot.team = Shot.Teams.PLAYER
	match weapon_type:
		WeaponTypes.PISTOL: shot.bullet_type = Shot.BulletTypes.STANDARD
		WeaponTypes.SHOTGUN: shot.bullet_type = Shot.BulletTypes.SHOTGUN
	get_tree().root.add_child(shot)
	shot.global_position = weapon_sprite.global_position+aim_vector*5
	shot.vector = new_aim_vector
	##Shot Modifiers
	var shot_modifiers = item_manager.get_all_static_of_subtype("SHOT_MODIFIER")
	if !shot_modifiers:
		return shot
	for effect in shot_modifiers:
		match effect.id:
			"freeze_shots":
				shot.on_hit_effects.append(effect)
	return shot

func shoot():
	if G.halt_actions:
		return
	if !aim_vector: return
	var shots: Array[Shot] = []
	match shot_type:
		ShotTypes.SINGLE:
			var shot: Shot = create_shot(aim_vector)
			shots.append(shot)
		ShotTypes.DOUBLE:
			var shot: Shot = create_shot(aim_vector)
			shot.global_position += (aim_vector.rotated(.5*PI)*DOUBLE_SHOT_SPREAD)
			shots.append(shot)
			shot = create_shot(aim_vector)
			shot.global_position -= (aim_vector.rotated(.5*PI)*DOUBLE_SHOT_SPREAD)
			shots.append(shot)
		ShotTypes.TRIPLE:
			var shot: Shot = create_shot(aim_vector)
			shots.append(shot)
			shot = create_shot(aim_vector.rotated(0.15*PI))
			shots.append(shot)
			shot = create_shot(aim_vector.rotated(-0.15*PI))
			shots.append(shot)
		ShotTypes.QUAD:
			var shot: Shot = create_shot(aim_vector.rotated(0.05*PI))
			shots.append(shot)
			shot = create_shot(aim_vector.rotated(-0.05*PI))
			shots.append(shot)
			shot = create_shot(aim_vector.rotated(0.15*PI))
			shots.append(shot)
			shot = create_shot(aim_vector.rotated(-0.15*PI))
			shots.append(shot)
			
	

func get_attribute(attribute: Attributes):
	match attribute:
		Attributes.MOVE_SPEED: return BASE_MOVE_SPEED * clamp(move_speed_mult,move_speed_min,move_speed_max)
		Attributes.FIRE_RATE: return fire_rate_bonus * fire_rate_mult
		Attributes.SHOT_SPEED: return (BASE_SHOT_SPEED + shot_speed_bonus) * shot_speed_mult
		Attributes.DAMAGE: return damage_bonus * damage_mult
		Attributes.KILL_TIME: return kill_time_bonus * kill_time_mult
		Attributes.DAMAGE_COMBO_METER_LOSS: return BASE_DAMAGE_COMBO_METER_LOSS * damage_combo_meter_loss_modifier

func inflict_effect(effect: Shot.ShotEffects, duration = 0):
	match effect:
		Shot.ShotEffects.FREEZE:
			frozen = true
			var tween = create_tween()
			tween.tween_property(self,"frozen",false,duration)

func take_damage():
	print("Invuln Timer: "+str(invuln_timer))
	if !invuln_timer.is_stopped():
		return
	var life_to_lose = 1.0
	for effect in item_manager.static_effects:
		if effect.id == "incoming_damage_mult":
			life_to_lose *= effect.amount
	health -= roundi(life_to_lose)
	current_combo_life -= get_attribute(Attributes.DAMAGE_COMBO_METER_LOSS)
	invuln_timer.start(BASE_INVULN_TIME+invuln_time_modifier)
	var tween = create_tween()
	tween.tween_method(_flash,0,FLASH_RATE*BASE_INVULN_TIME+invuln_time_modifier,BASE_INVULN_TIME+invuln_time_modifier)
	tween.tween_property(self,"visible",true,0)

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

func _flash(interval: float):
	var do_flash = floori(interval) % 2
	if do_flash:
		visible = false
	else:
		visible = true

func _ready():
	E.acquire_token.connect(_on_acquire_token)
	E.enemy_died.connect(_on_enemy_died)
	health_changed.connect(E._on_health_changed)
	update_sprite_health_colors()


func _process(delta: float) -> void:
	expression_sprite.animation = Expressions.find_key(current_expression).to_lower() +"_"+character_sprite.animation
	expression_sprite.frame = character_sprite.frame
	expression_sprite.flip_h = character_sprite.flip_h
	
	input_vector = Input.get_vector("move_left","move_right","move_up","move_down")
	$TokensContainer.global_rotation = 0
	if input_vector.length() > 1:
		input_vector = input_vector.normalized()
	if !G.mouse_controls:
		aim_vector = Input.get_vector("aim_left","aim_right","aim_up","aim_down").normalized()
	else:
		aim_vector = weapon_sprite.global_position.direction_to(get_global_mouse_position())
	#print("Combo: "+str(current_combo)+" Life: "+str(current_combo_life))
	##Halt Actions Early Return
	if G.halt_actions:
		return
	if aim_vector:
		weapon_sprite_container.rotation = aim_vector.angle()
	var pi_removed_rotation = weapon_sprite_container.rotation
	if pi_removed_rotation < 0:
		pi_removed_rotation += TAU
	pi_removed_rotation /= PI
	if pi_removed_rotation > 1.75 or pi_removed_rotation < .25:
		weapon_sprite.animation = str(WeaponTypes.find_key(weapon_type).to_lower())+"_right"
	elif pi_removed_rotation > 1.25:
		weapon_sprite.animation = str(WeaponTypes.find_key(weapon_type).to_lower())+"_up"
	elif pi_removed_rotation > .75:
		weapon_sprite.animation = str(WeaponTypes.find_key(weapon_type).to_lower())+"_left"
	elif pi_removed_rotation > .25:
		weapon_sprite.animation = str(WeaponTypes.find_key(weapon_type).to_lower())+"_down"
	if current_combo_life > 0:
		current_combo_life -= delta
	if current_combo_life <= 0 and current_combo > 1.0:
		current_combo -= 1.0

func _on_enemy_died(enemy: Enemy):
	reset_current_combo_life()
	G.remaining_time += get_attribute(Attributes.KILL_TIME)
	if enemy.grant_combo_on_death > 0:
		current_combo += enemy.grant_combo_on_death

func _on_acquire_token(amount: int):
	print("Token Acquired")
	if token_tween:
		token_tween.kill()
	token_tween = create_tween()
	token_tween.tween_property(tokens_counter, "modulate", Color(1,1,1,0.5),Vector4(1,1,1,tokens_counter.modulate.a).distance_to(Vector4(1,1,1,.5)))
	for i in amount:
		token_tween.tween_property(tokens_counter, "text", str(tokens+1+i),.5)
	token_tween.tween_property(tokens_counter, "modulate", Color(1,1,1,0),1)
	tokens += amount
