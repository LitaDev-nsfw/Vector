extends Node



var mouse_controls = false
var halt_actions = false:
	set(value):
		halt_actions = value
		change_halt_actions.emit(halt_actions)
var timer_active = true

##Remaining time in seconds
var remaining_time := 180.0

signal change_halt_actions(halt: bool)

func _ready():
	change_halt_actions.connect(E._on_change_halt_actions)

func _process(delta: float) -> void:
	if timer_active:
		remaining_time -= delta
