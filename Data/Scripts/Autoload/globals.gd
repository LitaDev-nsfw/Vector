extends Node


## Determines how aiming is handled in non-controller setups
var mouse_controls = false
## Stops most animations and player input.
var halt_actions = false:
	set(value):
		halt_actions = value
		change_halt_actions.emit(halt_actions)

## Determines whether the timer will continue to decrement
var timer_active = true

## Remaining time in seconds
var remaining_time := 180.0

## Emitted when the value of halt_actions changes 
signal change_halt_actions(halt: bool)

func _ready():
	change_halt_actions.connect(E._on_change_halt_actions)

func _process(delta: float) -> void:
	if timer_active:
		remaining_time -= delta
