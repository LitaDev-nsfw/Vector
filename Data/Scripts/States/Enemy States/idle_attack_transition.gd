extends State

@export var animation_speed: float = 1.0

@onready var state_owner: Enemy = get_parent().get_parent()

func begin_state():
	var previous_state_name = state_machine.states.find_key(state_machine.previous_state)
	if previous_state_name == "idle":
		state_owner.play_animation("transition_attack", animation_speed)
	else:
		state_owner.play_animation("transition_idle", animation_speed)
	if !state_owner.transition_finished.is_connected(_on_transition_finished):
		state_owner.transition_finished.connect(_on_transition_finished)

func _on_transition_finished(transition_to: StringName):
	state_machine.change_state(transition_to)
