extends Node

signal room_exited(room:Room, direction: Room.Directions)
signal enemy_died(enemy: Enemy)

func _on_room_exited(room: Room, direction: Room.Directions):
	room_exited.emit(room,direction)

func _on_enemy_died(enemy: Enemy):
	enemy_died.emit(enemy)
