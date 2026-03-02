extends CanvasLayer

@onready var timer_label: Label = find_child("Timer")
@onready var combo_label: Label = find_child("Combo")
@onready var combo_meter: TextureProgressBar = find_child("ComboMeter")
@onready var combo_history_vbox: VBoxContainer = find_child("ComboHistory")
@onready var player: Player = get_tree().get_first_node_in_group("Player")
@onready var health_bar: HBoxContainer = find_child("HealthBar")
@onready var health_pip_scene = preload("res://Scenes/health_pip.tscn")

func _ready():
	E.health_changed.connect(_on_health_changed)
	_on_health_changed(player.health)

func _process(_delta: float):
	@warning_ignore("integer_division")
	var minutes = str(int(G.remaining_time)/60)
	var seconds = str(int(G.remaining_time) % 60)
	if seconds.length() == 1:
		seconds = "0"+seconds
	timer_label.text = str(minutes)+":"+str(seconds)
d	combo_label.text = str(player.current_combo)+"x"
	if player.current_combo == 1.0:
		combo_meter.visible = false
	else:
		combo_meter.visible = true
		combo_meter.max_value = player.get_current_combo_life()
		combo_meter.value = player.current_combo_life
	if Input.is_action_just_pressed("pause"):
		print("Test")
		$PauseMenu.just_pressed = true
		$PauseMenu.visible = true
		get_tree().paused = true

func _on_health_changed(new_health:int):
	for child in health_bar.get_children():
		health_bar.remove_child(child)
		child.queue_free()
	@warning_ignore("integer_division")
	var health_pips = player.max_health/2
	for i in health_pips:
		i += 1
		var health_pip = health_pip_scene.instantiate()
		if i * 2 <= new_health:
			health_pip.find_child("Sprite").frame = 0
		elif new_health % 2 == 1 and i == ceil(float(new_health)/2):
			health_pip.find_child("Sprite").frame = 1
		health_bar.add_child(health_pip)
