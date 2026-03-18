extends Control

@export var is_main_menu = false

var just_pressed := false

@onready var default_page = find_child("DefaultPage")
@onready var options_page = find_child("OptionsPage")
@onready var main_game_scene = preload("res://Scenes/game.tscn")


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
	if !is_main_menu:
		unpause()
	else:
		var game_node = main_game_scene.instantiate()
		get_tree().change_scene_to_node(game_node)

func _on_options_pressed() -> void:
	options_page.visible = true
	default_page.visible = false


func _on_mouse_controls_toggled(toggled_on: bool) -> void:
	G.mouse_controls = toggled_on


func _on_back_pressed() -> void:
	options_page.visible = false
	default_page.visible = true


func _on_quit_pressed() -> void:
	if !is_main_menu:
		get_tree().change_scene_to_file("res://Scenes/main_menu.tscn")
	else:
		get_tree().quit()
