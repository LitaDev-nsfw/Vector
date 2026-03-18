extends VBoxContainer

signal mouse_controls_toggle(toggled_on: bool)
signal back_button


func _on_mouse_controls_toggled(toggled_on: bool) -> void:
	mouse_controls_toggle.emit(toggled_on)


func _on_back_pressed() -> void:
	back_button.emit()
