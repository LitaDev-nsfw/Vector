extends Node2D
class_name Level

@export var current_room = 0
@export var current_room_node: Room
@export var current_floor = 1
@export var level_camera: Camera2D

var remaining_rooms_normal: Array[PackedScene]
var remaining_rooms_inverted: Array[PackedScene]
var inverted = false


const ROOM_OFFSET = Vector2(623,353)

signal next_floor(new_floor: int)
signal show_selection(pool: ItemSelection.Pools)


func get_remaining_rooms(boss_rooms := false, inverted_rooms := false) -> Array[PackedScene]:
	var array: Array[PackedScene] = []
	var folder_path: String
	
	folder_path = "Scenes/Rooms/Floor "+str(current_floor)
	if inverted_rooms:
		folder_path += " Inverted"
	if boss_rooms:
		folder_path += "/Bosses"
	print(folder_path)
	var folder := DirAccess.open(folder_path)
	for file_name in folder.get_files():
		array.append(load(folder_path+"/"+file_name))
	return array

func _ready():
	remaining_rooms_normal = get_remaining_rooms()
	remaining_rooms_inverted = get_remaining_rooms(false, true)
	E.room_exited.connect(_on_room_exited)
	next_floor.connect(E._on_next_floor)
	E.next_floor.connect(_on_next_floor)
	show_selection.connect(E._on_show_selection)


func _on_room_exited(room: Room, direction: Room.Directions):
	print("On Room Exit")
	if direction == room.special_exit_direction:
		var player: Player = find_child("Player")
		player.reset_current_combo_life()
	elif direction == room.entrance_direction:
		inverted = !inverted
	current_room += 1
	var new_room: Room
	if current_room == 7:
		current_room = 1
		next_floor.emit(current_floor + 1)
		print('signal emitted')
	if current_room == 3 and !inverted:
		var new_room_scene = load("res://Scenes/Rooms/healing.tscn")
		new_room = new_room_scene.instantiate()
	elif current_room == 6:
		var potential_bosses: Array[PackedScene] = get_remaining_rooms(true, inverted)
		new_room = potential_bosses.pick_random().instantiate()
	else:
		var array = remaining_rooms_normal
		if inverted:
			array = remaining_rooms_inverted
		if !array:
			push_error("OUT OF ROOMS")
		var new_room_scene = array.pick_random()
		new_room = new_room_scene.instantiate()
		array.erase(new_room_scene)
		
		
		#print(direction)
		#print("New direction "+str(direction + 2 % 4))
	if inverted:
		new_room.tokens_on_clear += 1
		new_room.inverted = true
	new_room.entrance_direction = (direction + 2) % 4 as Room.Directions
	call_deferred("add_child",new_room)
	var point_vector: Vector2
	match direction:
		Room.Directions.NORTH: point_vector = Vector2.UP
		Room.Directions.SOUTH: point_vector = Vector2.DOWN
		Room.Directions.EAST: point_vector = Vector2.RIGHT
		Room.Directions.WEST: point_vector = Vector2.LEFT
	new_room.position = current_room_node.position + ROOM_OFFSET*point_vector
	current_room_node.leave()
	current_room_node = new_room
	var tween = create_tween()
	tween.set_ease(Tween.EASE_IN_OUT)
	tween.tween_property(level_camera,"global_position",level_camera.global_position + ROOM_OFFSET*point_vector,1.0)
	

func _on_next_floor(new_floor: int):
	print('signal received at level')
	current_floor = new_floor
	remaining_rooms_normal = get_remaining_rooms()
	remaining_rooms_inverted = get_remaining_rooms(false, true)
	show_selection.emit(ItemSelection.Pools.POOL_BOSS)
