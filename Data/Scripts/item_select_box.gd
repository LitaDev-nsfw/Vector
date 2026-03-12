extends VBoxContainer
class_name ItemSelectBox



var item: Item
var color: Color:
	set(value):
		color = value
		frame_texture.modulate = color

@onready var icon_texture: TextureRect = find_child("IconTexture")
@onready var frame_texture: TextureRect = find_child("FrameTexture")
@onready var player: Player = get_tree().get_first_node_in_group("Player")
@onready var select_button: Button = find_child("Button")


func _ready():
	if !item:
		push_error("NO ITEM")
		pass
	$ItemName.text = D.get_entry_name_string(item.entry)
	$Description.text = item.entry.description
	if FileAccess.file_exists("Assets/Sprites/Item Icons/"+item.id+".png"):
		icon_texture.texture = load("Assets/Sprites/Item Icons/"+item.id+".png")
	else:
		push_error("No icon for: "+item.id+", using placeholder.png")
	
