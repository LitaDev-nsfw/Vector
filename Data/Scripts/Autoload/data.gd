@tool
extends Node

## Autoload for all JSON Data handling and queries.
# Uses the reference "D", in similar scheme to all autoloads.


var json = {}

func create_item(item_id: String):
	var item := Item.new()
	item.id = item_id
	item.entry = get_entry(item_id)
	return item

## Returns all ids of a given type
func get_all_type(type: String, include_base = false) -> Array[String]:
	var ids: Array[String] = []
	for item in json:
		if include_base or item.left(1) != "_":
			if get_entry(item).type == type:
				ids.append(json[item].id)
	return ids

## Returns all ids of a given subtype
func get_all_subtype(subtype: String, include_base = false) -> Array[String]:
	var ids: Array[String] = []
	for item in json:
		if include_base or item.left(1) != "_":
			if get_entry(item).subtypes.has(subtype):
				ids.append(json[item].id)
	return ids

func get_all_subtype_from_list(subtype: String, list: Array[String], include_base = false) -> Array[String]:
	var ids: Array[String] = []
	for item in list:
		if get_entry(item).subtypes.has(subtype):
			if include_base or item.left(1) != "_":
				ids.append(item)
	return ids

## Returns the entry for a given id.
# These entries are static, and a local copy can be safely written to a var.  
func get_entry(id:String):
	if json == {}:
		_initialize_json()
	if not json.has(id):
		push_error("Invalid ID: " + id)
		return null
	var copy_from_list = []
	var current_check_id = id
	while true:
		copy_from_list.append(current_check_id)
		if not json.has(current_check_id):
			push_error("Invalid Copy_from ID at "+str(copy_from_list)+" "+str(id))
		if json[current_check_id].has("copy_from"):
			current_check_id = json[current_check_id].copy_from
		else:
			break
	#print("Copy from list: " + str(copy_from_list))
	copy_from_list.reverse()
	var constructed_entry = {}
	for entry:String in copy_from_list:
		#print("Processing Entry: "+entry)
		for key:String in json[entry]:
			if key.left(1) == "+":
				if constructed_entry.has(key.right(-1)):
					constructed_entry[key.right(-1)].append_array(json[entry][key])
					print(key.right(-1) + ": " + str(constructed_entry[key.right(-1)]))
				else:
					constructed_entry[key.right(-1)] = json[entry][key].duplicate()
			elif key.left(1) == "-":
				if constructed_entry.has(key.right(-1)):
					for item in json[entry][key]:
						constructed_entry[key.right(-1)].erase(item)
			else:
				if json[entry][key] is Array:
					constructed_entry[key] = json[entry][key].duplicate()
				else:
					constructed_entry[key] = json[entry][key]
	print(constructed_entry)
	return constructed_entry

## This handles the special "name" key handling
# The three types are "str" for a simple singular, "str_p" for a special pluralization that isn't just str+s, such as "Battery" -> "Batteries"
# and a special "str_sp" for instances where the singular and plural are the same. Mostly used for things that shouldn't be pluralized like abilities.
func get_entry_name_string(entry: Dictionary, plural = false) -> String:
	if entry.name.has("str_sp"):
		return entry.name["str_sp"]
	if !plural:
		return entry.name["str"]
	if plural:
		if entry.name.has("str_p"):
			return entry.name["str_p"]
		else:
			return entry.name["str"]+"s"
	return "No name"

## Imports the json data
func _ready():
	if json == {}:
		_initialize_json()


## iterates through the Data/Json folder and reads all json files into a single json dict.
# This means that any entry can be anywhere in the json files. A gun need not be in ranged_weapons.json, but it should be!
# But a gun in abilities.json will still be imported with no issues, as long as its "type" is "weapon", etc.
func _initialize_json():
	var json_dir := DirAccess.open("res://Data/Json/")
	var current_dir = "res://Data/Json/"
	var completed_dirs = []
	while true:
		if completed_dirs.has("res://Data/Json/"):
			break
		var bounce = false
		var hold = false
		#print(json_dir.get_current_dir())
		var files = json_dir.get_files()
		var dirs = json_dir.get_directories()
		#print(str(dirs)+str(files))
		for dir in dirs:
			var dir_string = current_dir+dir+"/"
			#print("Step 1")
			#print(dir_string + str(completed_dirs))
			if not dir_string in completed_dirs:
				#print("Step 2")
				json_dir = DirAccess.open(dir_string)
				current_dir = json_dir.get_current_dir()
				hold = true
		#print("breaks out")
		if not hold:
			#print("Step 3")
			for file in files:
				#print("Step 3a")
				#print(current_dir+file)
				file = FileAccess.open(current_dir+file,FileAccess.READ)
				var raw_json = JSON.parse_string(file.get_as_text())
				for key in raw_json:
					json[key.id] = key
			#print("Step 4")
			completed_dirs.append(current_dir)
			#print("help: "+current_dir+str(completed_dirs))
			bounce = true
		if bounce:
			#print(current_dir)
			var dir_string_array = current_dir.split("/")
			dir_string_array.remove_at(dir_string_array.size()-1)
			dir_string_array.remove_at(dir_string_array.size()-1)
			var constructed_dir_string = ""
			#print(dir_string_array)
			for folder in dir_string_array:
				constructed_dir_string += folder+"/"
			#print(constructed_dir_string)
			json_dir = DirAccess.open(constructed_dir_string)
			current_dir = json_dir.get_current_dir()
			#print("current_dir: "+ current_dir)
