extends State

@export var animation_speed: float = 1.0

@onready var state_owner: Enemy = get_parent().get_parent()

func begin_state():
	var previous_state_name = state_machine.states.find_key(state_machine.previous_state)
	if previous_state_name == "idle":
		state_owner.animation_player.play("transition_attack")
		state_owner.animation_player.queue("attack")
	else:
		state_owner.animation_player.play("transition_idle")
		state_owner.animation_player.queue("idle")
	if !state_owner.animation_player.animation_changed.is_connected(_on_animation_changed):
		state_owner.animation_player.animation_changed.connect(_on_animation_changed)

func _on_animation_changed(_old_name: StringName, new_name: StringName):
	state_machine.change_state(new_name)
