extends Node

var halt_actions = false
var timer_active = true

##Remaining time in seconds
var remaining_time := 180.0

func _ready():
	E.enemy_died.connect(_on_enemy_died)

func _process(delta: float) -> void:
	if timer_active:
		remaining_time -= delta

func _on_enemy_died(_enemy: Enemy):
	remaining_time += 5
