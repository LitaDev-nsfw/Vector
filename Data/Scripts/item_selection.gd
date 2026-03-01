extends Control
class_name ItemSelection

enum Pools {
	POOL_BOSS,
}



var weights = {
	ItemManager.Rarities.COMMON: 50,
	ItemManager.Rarities.UNCOMMON: 30,
	ItemManager.Rarities.RARE: 15,
	ItemManager.Rarities.LEGENDARY: 5,
}

var selections_to_make: int
var skip_attempted = false


@onready var item_selections: HBoxContainer = find_child("Items")
@onready var item_select_box_scene = preload("res://Scenes/item_select_box.tscn")
@onready var player: Player = get_tree().get_first_node_in_group("Player")
@onready var skip_button: Button = find_child("SkipButton")


const BASE_CHOICES = 3
const BASE_SELECTIONS = 1

signal acquire_item(item: Item)

func _ready():
	E.show_selection.connect(_on_show_selection)
	acquire_item.connect(E._on_acquire_item)
	_on_show_selection(Pools.POOL_BOSS)


func _split_rarities(items: Array[Item])-> Dictionary[ItemManager.Rarities,Array]:
	var dict: Dictionary[ItemManager.Rarities,Array] = {
		ItemManager.Rarities.COMMON: [],
		ItemManager.Rarities.UNCOMMON: [],
		ItemManager.Rarities.RARE: [],
		ItemManager.Rarities.LEGENDARY: [],
	}
	for item in items:
		dict[player.item_manager.match_item_rarity(item.entry.rarity)].append(item)
	return dict

func _on_show_selection(pool: Pools):
	for node in item_selections.get_children():
		item_selections.remove_child(node)
		node.queue_free()
	visible = true
	selections_to_make = BASE_SELECTIONS
	var item_ids = D.get_all_subtype(Pools.find_key(pool))
	var items: Array[Item] = []
	for item_id in item_ids:
		items.append(D.create_item(item_id))
	var items_by_rarity: Dictionary[ItemManager.Rarities,Array] = _split_rarities(items)
	var choices_modifier = 0
	var modified_weights = weights.duplicate()
	for effect in player.item_manager.static_effects:
		if effect.id == "item_choice_count":
			choices_modifier += effect.amount
		if effect.id == "item_rarity_mult":
			for rarity in effect.rarities:
				modified_weights[player.item_manager.match_item_rarity(rarity)] *= effect.amount
	var weight_sum = 0
	for weight in modified_weights:
		weight_sum += modified_weights[weight]
	var choices: Array[Item] = []
	for i in (BASE_CHOICES + choices_modifier):
		print("Generating Choice")
		var rng = randi_range(1,weight_sum)
		for weight in modified_weights:
			if rng > modified_weights[weight]:
				rng -= modified_weights[weight]
			else:
				var item = items_by_rarity[weight].pick_random()
				choices.append(item)
				#items_by_rarity[weight].erase(item)
				break
	print("Choices" + str(choices))
	for choice:Item in choices:
		print(choice.entry.name)
		var item_select_box_node: ItemSelectBox = item_select_box_scene.instantiate()
		item_select_box_node.item = choice
		item_selections.add_child(item_select_box_node)
		item_select_box_node.select_button.pressed.connect(_on_item_selected.bind(choice))

func _on_item_selected(item: Item):
	if selections_to_make > 1:
		selections_to_make -= 1
	else:
		visible = false
	skip_attempted = false
	acquire_item.emit(item)


func _on_skip_button_pressed() -> void:
	if skip_attempted:
		skip_attempted = false
		visible = false
	else:
		skip_button.text = "Confirm?"
		skip_attempted = true
