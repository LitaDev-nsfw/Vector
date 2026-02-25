extends State

@export var parry_icon: Sprite2D
@export var parry_area: Area2D
@export var parry_length := 15
@export var parry_distance = 20

var remaining_parry_time
var parry_icon_relative_position: Vector2
var parried_projectiles: Array[Shot] = []


@onready var player: Player = get_parent().get_parent()



func begin_state():
	parry_icon.visible = true
	parry_icon_relative_position = player.aim_vector*parry_distance
	parry_icon.global_position = player.global_position + parry_icon_relative_position
	parry_icon.global_rotation = 0
	parried_projectiles = []
	print(parry_icon_relative_position)
	for shot_area in parry_area.get_overlapping_areas():
		var shot: Shot
		if not shot_area.get_parent() is Shot:
			continue
		else:
			shot = shot_area.get_parent()
		if shot.shot_owner != player:
			parried_projectiles.append(shot)
	if !parried_projectiles:
		var tween = create_tween()
		tween.tween_interval(parry_length*(1.0/60))
		tween.tween_property(parry_icon,"visible",false, 0)
		state_machine.change_state("idle")
	else:
		print("PARRIED")
		remaining_parry_time = parry_length*(1.0/60)
		G.halt_actions = true
		for shot in parried_projectiles:
			shot.shot_owner = player
			shot.team = Shot.Teams.PLAYER
			shot.vector = player.aim_vector
			shot.was_parried = true
			player.current_combo += .2

func update(delta: float):
	print(parry_icon.position)
	remaining_parry_time -= delta
	if remaining_parry_time <= 0:
		if player.aim_vector:
			for shot:Shot in parried_projectiles:
				shot.vector = player.aim_vector
		G.halt_actions = false
		state_machine.change_state("idle")
		parry_icon.visible = false
