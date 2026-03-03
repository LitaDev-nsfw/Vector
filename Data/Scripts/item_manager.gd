extends Node
class_name ItemManager

enum Rarities {
	COMMON,
	UNCOMMON,
	RARE,
	LEGENDARY
}
var items: Array[Item] = []
var static_effects: Array[Dictionary] = []


@onready var player: Player = get_parent()

func get_all_static_of_subtype(subtype: String) -> Array[Dictionary]:
	var effects: Array[Dictionary] = []
	for effect in static_effects:
		if effect.subtypes.has(subtype):
			effects.append(effect)
	return effects

func match_item_rarity(rarity_string: String) -> Rarities:
	match rarity_string:
		"COMMON": return Rarities.COMMON
		"UNCOMMON": return Rarities.UNCOMMON
		"RARE": return Rarities.RARE
		"LEGENDARY": return Rarities.LEGENDARY
	return Rarities.COMMON


func check_for_item(item_id: String) -> bool:
	print("Checking for item: "+item_id)
	print(items)
	for item: Item in items:
		print(item.id)
		print(item_id)
		if item.id == item_id:
			print("true")
			return true
	return false

func _ready():
	E.acquire_item.connect(_on_get_item)

func _on_get_item(item: Item):
	_sort_items()
	if !items:
		_apply_item(item)
		items.append(item)
		return
	static_effects = []
	for previous_item: Item in items:
		if previous_item.entry.priority <= item.entry.priority and previous_item.entry.number < item.entry.number:
			_apply_item(previous_item, true)
		else:
			_apply_item(item)
	items.append(item)
	print("Items: "+str(items))

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
		if static_only and !effect.subtypes.has("STATIC"):
			return
		if effect.subtypes.has("STATIC"):
			static_effects.append(effect)
			match effect.id:
				"shot_type": player.shot_type = player.ShotTypes[effect.type]
		else:
			match effect.id:
				"fire_rate_bonus":
					player.fire_rate_bonus += effect.amount
				"fire_rate_mult":
					player.fire_rate_mult *= effect.amount
				"kill_time_bonus":
					player.kill_time_bonus += effect.amount
				"kill_time_mult":
					player.kill_time_mult *= effect.amount
				_: push_error("Effect doesn't exist: "+effect.id)
