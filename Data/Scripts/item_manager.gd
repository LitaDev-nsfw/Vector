extends Node
class_name ItemManager

var items: Array[Item] = []

@onready var player: Player = get_parent()

func _ready():
	_on_get_item(D.create_item("crying_onion"))

func _on_get_item(item: Item):
	_sort_items()
	if !items:
		_apply_item(item)
		return
	for previous_item: Item in items:
		if previous_item.entry.priority <= item.entry.priority and previous_item.entry.number < item.entry.number:
			_apply_item(previous_item, true)
		else:
			_apply_item(item)

func _sort_items():
	var hold_items = items.duplicate()
	while true:
		var swapped = false
		for item in hold_items:
			if item != hold_items.back():
				var index = hold_items.find(item)
				if item.entry.priority > hold_items[index+1].entry.priority or item.entry.number > hold_items[index+1].entry.number:
					hold_items.erase(item)
					hold_items.insert(index+1, item)
					swapped = true
		if !swapped: break
	items = hold_items
	

func _apply_item(item: Item, static_only = false):
	for effect in item.entry.effects:
		match effect:
			"fire_rate_bonus": 
				if static_only:
					return
				player.fire_rate_bonus += item.entry.effects[effect].amount
			_: push_error("Effect doesn't exist: "+effect)
