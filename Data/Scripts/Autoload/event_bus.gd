extends Node

signal room_exited(room:Room, direction: Room.Directions)


func _on_room_exited(room: Room, direction: Room.Directions):
	room_exited.emit(room,direction)
