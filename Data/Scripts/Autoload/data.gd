@tool
extends Node

## Autoload for all JSON Data handling and queries.
# Uses the reference "D", in similar scheme to all autoloads.

## Holds all stored JSON data
var json: Dictionary[String,Dictionary] = {}

## Creates an item from the provided Item ID
func create_item(item_id: String):
	var item := Item.new()
	item.id = item_id
	item.entry = get_entry(item_id)
	return item

#region Fetching Functions
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

## Returns all ids possessing a certain subtype, from a list of ids. This should be used over get_all_subtype as its quicker than iterating over the entire json dict
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
	# A given entry can have a "copy-from" field which means to inherit all values from the id, and to override the defined values. That copy-from can have its own copy-from. This variable contains the list of each copy-from's copy-from until the final copy-from is reached
	var copy_from_list = []
	var current_check_id = id
	# This for loop iterates down until the final base copy-from is reached
	while true:
		copy_from_list.append(current_check_id)
		if not json.has(current_check_id):
			push_error("Invalid Copy_from ID at "+str(copy_from_list)+" "+str(id))
		if json[current_check_id].has("copy_from"):
			current_check_id = json[current_check_id].copy_from
		else:
			break
	# The list is reversed so that the entry can be built up, starting with the deepest copy-from
	copy_from_list.reverse()
	var constructed_entry = {}
	# The final entry is built up entry by entry
	for entry:String in copy_from_list:
		# Iterates key by key, adding, subtracting, or overriding.
		for key:String in json[entry]:
			# A key beginning with + can only correlate to an array, and it means to add the values listed to the inherited array, rather than overwrite the original array completely
			if key.left(1) == "+":
				if constructed_entry.has(key.right(-1)):
					constructed_entry[key.right(-1)].append_array(json[entry][key])
					print(key.right(-1) + ": " + str(constructed_entry[key.right(-1)]))
				else:
					constructed_entry[key.right(-1)] = json[entry][key].duplicate()
			# The same is true for - but it subtracts from the inherited array instead of adding
			elif key.left(1) == "-":
				if constructed_entry.has(key.right(-1)):
					for item in json[entry][key]:
						constructed_entry[key.right(-1)].erase(item)
			# This simply overrides the original value, if it exists.
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
#endregion


## Imports the json data
func _ready():
	if json == {}:
		_initialize_json()


## iterates through the Data/Json folder and reads all json files into a single json dict.
# This means that any entry can be anywhere in the json files. An item need not be in items.json, but it should be!
# But an item in another file will still be imported with no issues, as long as its type is "ITEM", etc.
func _initialize_json():
	var json_dir := DirAccess.open("res://Data/Json/")
	# It can search through sub-folders, so tracking the current directory is necessary
	var current_dir = "res://Data/Json/"
	# Completed directories need to be tracked as well. Once the highest, base directory is added to the completed list, the while loop breaks.
	var completed_dirs = []
	while true:
		if completed_dirs.has("res://Data/Json/"):
			break
		# Bounce means jump out of the current folder and go back up a level
		var bounce = false
		# Hold means keep the current folder, and check for new sub-directories. Hold = false means process the files in the current folder
		var hold = false
		# Gets an array of all files and directories
		var files = json_dir.get_files()
		var dirs = json_dir.get_directories()
		# Starts by processing each dir into an absolute dir string.
		for dir in dirs:
			var dir_string = current_dir+dir+"/"
			# If the dir has not been searched, it becomes the new directory.
			if not dir_string in completed_dirs:
				#print("Step 2")
				json_dir = DirAccess.open(dir_string)
				current_dir = json_dir.get_current_dir()
				hold = true
		#Hold being false means there were no subdirectories, or we've just bounced out of a completed dir, so files in the current folder are processed
		if not hold:
			#print("Step 3")
			for file in files:
				#print("Step 3a")
				#print(current_dir+file)
				file = FileAccess.open(current_dir+file,FileAccess.READ)
				var raw_json = JSON.parse_string(file.get_as_text())
				for key in raw_json:
					json[key.id] = key
			completed_dirs.append(current_dir)
			# Bounce is set to true since the current folder has been fully processed
			bounce = true
		# Bounce being true means all files processed, which requires no unexplored sub-directories, meaning its safe to go back to the parent level
		if bounce:
			#A slightly hacky way of cutting off the last subfolder and its "/"
			var dir_string_array = current_dir.split("/")
			dir_string_array.remove_at(dir_string_array.size()-1)
			dir_string_array.remove_at(dir_string_array.size()-1)
			# The chopped string is reconstructed
			var constructed_dir_string = ""
			for folder in dir_string_array:
				constructed_dir_string += folder+"/"
			json_dir = DirAccess.open(constructed_dir_string)
			current_dir = json_dir.get_current_dir()
