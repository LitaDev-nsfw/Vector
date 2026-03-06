extends Node
class_name StateMachine


var current_state: State
var previous_state: State
var states: Dictionary[String, State] = {}


@export var default_state: State

func change_state(new_state: String):
	print("Changing State: "+new_state)
	var new_state_node: State = states.get(new_state.to_lower())
	if !new_state_node:
		push_error("Nonexistent State: "+new_state)
	if current_state:
		current_state.end_state()
	previous_state = current_state
	current_state = new_state_node
	new_state_node.begin_state()

func _ready():
	await get_parent().ready
	for state: State in get_children():
		states[state.name.to_lower()] = state
	if default_state:
		default_state.begin_state()
		current_state = default_state

func _process(delta: float) -> void:
	if current_state: current_state.update(delta)

func _physics_process(delta: float) -> void:
	if current_state: current_state.physics_update(delta)
