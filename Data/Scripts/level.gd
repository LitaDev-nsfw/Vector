extends Node2D
class_name Level

@export var current_room = 0
@export var current_room_node: Room
@export var current_floor = 1
@export var level_camera: Camera2D

var remaining_rooms: Array[PackedScene]
var remaining_boss_rooms: Array[PackedScene]

const ROOM_OFFSET = Vector2(623,353)

func get_remaining_rooms(boss_rooms := false):
	if !boss_rooms:
		var folder_path = "Scenes/Rooms/Floor "+str(current_floor)
		print(folder_path)
		var folder := DirAccess.open(folder_path)
		for file_name in folder.get_files():
			remaining_rooms.append(load(folder_path+"/"+file_name))

func _ready():
	get_remaining_rooms()
	get_remaining_rooms(true)
	E.room_exited.connect(_on_room_exited)


func _on_room_exited(room: Room, direction: Room.Directions):
	print("On Room Exit")
	if direction == room.special_exit_direction:
		var player: Player = find_child("Player")
		player.reset_current_combo_life()
	current_room += 1
	if current_room == 3:
		pass
	elif current_room == 6:
		pass
	else:
		if !remaining_rooms:
			push_error("OUT OF ROOMS")
		var new_room_scene = remaining_rooms.pick_random()
		var new_room: Room = new_room_scene.instantiate()
		remaining_rooms.erase(new_room_scene)
		print(direction)
		print("New direction "+str(direction + 2 % 4))
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
