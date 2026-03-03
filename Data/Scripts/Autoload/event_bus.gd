extends Node
## The event bus handles all signal traffic. All emitted signals connect to the Event bus, and all listener nodes connect to its signals.
# The event bus uses the E identifier, as single letter initials are standard for Autoloads.

## The outgoing signals. Each signal should have its args explicitly defined and typed.
#region Outgoing Signals
signal room_exited(room:Room, direction: Room.Directions)
signal enemy_died(enemy: Enemy)
signal next_floor(new_floor: int)
signal health_changed(new_health: int)
signal change_halt_actions(halt: bool)
signal show_selection(pool: ItemSelection.Pools)
signal acquire_item(item: Item)
signal room_cleared(room: Room)
signal acquire_token(amount: int)
#endregion

#region Listener Functions
## Emitted by Room nodes when the player leaves them
func _on_room_exited(room: Room, direction: Room.Directions):
	room_exited.emit(room,direction)

## Emitted by Enemy nodes when they die.
func _on_enemy_died(enemy: Enemy):
	enemy_died.emit(enemy)

## Emitted by the Level handler node when the player leaves the boss room.
func _on_next_floor(new_floor: int):
	next_floor.emit(new_floor)

## Emitted by the Player node when its health value changes
func _on_health_changed(new_health: int):
	health_changed.emit(new_health)

## Emitted by the Globals autoload when G.halt_actions value is changed.
func _on_change_halt_actions(halt: bool):
	change_halt_actions.emit(halt)

## Emitted by various nodes, but primarily the Level node when the player leaves the boss room.
func _on_show_selection(pool: ItemSelection.Pools):
	show_selection.emit(pool)

## Emitted by the item choice screen when the player selects an item.
func _on_acquire_item(item: Item):
	acquire_item.emit(item)

## Emitted by Room nodes once all enemies in the room die.
func _on_room_cleared(room: Room):
	room_cleared.emit(room)

## Emitted by various nodes, gives the player an amount of tokens which boost item rarity
func _on_acquire_token(amount: int):
	if amount != 0:
		acquire_token.emit(amount)
#endregion
