extends Control


var just_pressed := false

@onready var default_page = find_child("DefaultPage")
@onready var options_page = find_child("OptionsPage")



func unpause():
	get_tree().paused = false
	self.visible = false
	default_page.visible = true
	options_page.visible = false

func _process(_delta):
	if Input.is_action_just_pressed("pause") and !just_pressed:
		unpause()
	if just_pressed:
		just_pressed = false

func _on_resume_pressed() -> void:
	unpause()

func _on_options_pressed() -> void:
	options_page.visible = true
	default_page.visible = false


func _on_mouse_controls_toggled(toggled_on: bool) -> void:
	G.mouse_controls = toggled_on


func _on_back_pressed() -> void:
	options_page.visible = false
	default_page.visible = true
