extends VBoxContainer
class_name ItemSelectBox



var item: Item
var color: Color:
	set(value):
		color = value
		ascii_label.add_theme_color_override("default_color",color)

@onready var ascii_label: RichTextLabel = find_child("ASCII")
@onready var player: Player = get_tree().get_first_node_in_group("Player")
@onready var select_button: Button = find_child("Button")


func _ready():
	if !item:
		push_error("NO ITEM")
		pass
	$ItemName.text = D.get_entry_name_string(item.entry)
	$Description.text = item.entry.description
	var text_file := FileAccess.open("Assets/Sprites/Item Icons/"+item.id+".txt",FileAccess.READ)
	if text_file:
		ascii_label.text = text_file.get_as_text()
		text_file.close()
	else:
		push_error("NO ASCII SPRITE FOR: "+item.id)
	
