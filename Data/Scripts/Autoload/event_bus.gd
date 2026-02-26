extends Node

signal room_exited(room:Room, direction: Room.Directions)
signal enemy_died(enemy: Enemy)
signal next_floor(new_floor: int)
signal health_changed(new_health: int)
signal change_halt_actions(halt: bool)
signal show_selection(pool: ItemSelection.Pools)
signal acquire_item(item: Item)

func _on_room_exited(room: Room, direction: Room.Directions):
	room_exited.emit(room,direction)

func _on_enemy_died(enemy: Enemy):
	enemy_died.emit(enemy)

func _on_next_floor(new_floor: int):
	next_floor.emit(new_floor)

func _on_health_changed(new_health: int):
	health_changed.emit(new_health)

func _on_change_halt_actions(halt: bool):
	change_halt_actions.emit(halt)

func _on_show_selection(pool: ItemSelection.Pools):
	show_selection.emit(pool)

func _on_acquire_item(item: Item):
	acquire_item.emit(item)
