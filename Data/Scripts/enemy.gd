extends CharacterBody2D
class_name Enemy

enum AimTypes {
	AIMED,
	FORWARDED,
	ONE_WAY,
	AIMED_FOUR_WAY,
	AIMED_FOUR_WAY_DIAGONAL,
	TWO_WAY,
	FOUR_WAY,
}


@export var health: float = 20:
	set(value):
		health = value
		if health <= 0:
			queue_free()
@export var invincible: bool = false
@export var attack_delay: float = 3
@export var shot_speed: float = 350
@export var aim_type: AimTypes = AimTypes.AIMED

@onready var player: Player = get_tree().get_first_node_in_group("Player")
@onready var shot_scene = preload("res://Scenes/shot.tscn")

func shoot(target: CharacterBody2D):
	if G.halt_actions:
		return
	match aim_type:
		AimTypes.AIMED:
			if !target: return
			var shot_node: Shot = shot_scene.instantiate()
			shot_node.shot_owner = self
			shot_node.shot_speed = shot_speed
			shot_node.team = Shot.Teams.ENEMY
			shot_node.vector = (target.global_position - global_position).normalized()
			get_parent().add_child(shot_node)
			shot_node.global_position = global_position

func take_damage(damage: float):
	health -= damage
