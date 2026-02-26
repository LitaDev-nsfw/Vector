extends CanvasLayer

@onready var timer_label: Label = find_child("Timer")
@onready var combo_label: Label = find_child("Combo")
@onready var combo_meter: TextureProgressBar = find_child("ComboMeter")
@onready var combo_history_vbox: VBoxContainer = find_child("ComboHistory")
@onready var player: Player = get_tree().get_first_node_in_group("Player")


func _process(_delta: float):
	@warning_ignore("integer_division")
	var minutes = str(int(G.remaining_time)/60)
	var seconds = str(int(G.remaining_time) % 60)
	if seconds.length() == 1:
		seconds = "0"+seconds
	timer_label.text = str(minutes)+":"+str(seconds)
	combo_label.text = str(player.current_combo)+"x"
	if player.current_combo == 1.0:
		combo_meter.visible = false
	else:
		combo_meter.visible = true
		combo_meter.max_value = player.get_current_combo_life()
		combo_meter.value = player.current_combo_life
