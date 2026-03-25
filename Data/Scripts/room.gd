extends Node2D
class_name Room

enum Directions {
	NORTH,
	EAST,
	SOUTH,
	WEST
}

@export var has_enemies := true

var door_atlas_coords: Dictionary[Directions, Vector2i] = {
	Directions.NORTH: Vector2i(3,3),
	Directions.SOUTH: Vector2i(3,2),
	Directions.WEST: Vector2i(2,2),
	Directions.EAST: Vector2i(2,3),
}
var door_tile_coords: Dictionary[Directions, Vector2i] = {
	Directions.NORTH: Vector2i(-1,-7),
	Directions.SOUTH: Vector2i(-1,3),
	Directions.WEST: Vector2i(-10,-2),
	Directions.EAST: Vector2i(8,-2),
}
var tokens_on_clear: int = 0
var inverted := false
var entrance_direction: Directions:
	set(value):
		print("Entrance: "+Directions.find_key(value))
		entrance_direction = value
var entrance_tween: Tween
var special_exit_direction: Directions:
	set(value):
		special_exit_direction = value
		var marker_name = Directions.find_key(special_exit_direction).capitalize()+"Marker"
		find_child(marker_name).visible = true

@onready var wall_tilemap: TileMapLayer = find_child("OuterWall")
@onready var player: Player = get_tree().get_first_node_in_group("Player")
@onready var enemies: Node2D = find_child("Enemies")
@onready var bounds: Polygon2D = find_child("Bounds")

const TRANSITION_TIME = 1.0
const ENTRANCE_PLACEMENT_OFFSET = 32

signal room_exited(room: Room,direction: Room.Directions)
signal room_cleared(room: Room)
signal acquire_token(amount: int)

func leave():
	queue_free()

func close_doors():
	for direction in Directions:
		direction = Directions[direction]
		if !wall_tilemap.get_cell_tile_data(door_tile_coords[direction]):
			wall_tilemap.set_cell(door_tile_coords[direction],0,door_atlas_coords[direction])

func open_doors():
	for direction in Directions:
		direction = Directions[direction]
		if wall_tilemap.get_cell_atlas_coords(door_tile_coords[direction]) == door_atlas_coords[direction]:
			wall_tilemap.erase_cell(door_tile_coords[direction])

func is_inside_room(point: Vector2):
	print("Point: "+str(point))
	print("Polygon: "+str(bounds.polygon))
	return Geometry2D.is_point_in_polygon(point,bounds.polygon)

func _ready():
	room_exited.connect(E._on_room_exited)
	room_cleared.connect(E._on_room_cleared)
	acquire_token.connect(E._on_acquire_token)
	E.enemy_died.connect(_on_enemy_died)
	if entrance_direction == null or name == "StartingRoom":  
		return
	var entrance_player_position: Vector2
	match entrance_direction:
		Directions.NORTH: entrance_player_position = find_child("NorthExitArea").global_position + Vector2.DOWN * ENTRANCE_PLACEMENT_OFFSET
		Directions.SOUTH: entrance_player_position = find_child("SouthExitArea").global_position + Vector2.UP * ENTRANCE_PLACEMENT_OFFSET
		Directions.WEST: entrance_player_position = find_child("WestExitArea").global_position + Vector2.RIGHT * ENTRANCE_PLACEMENT_OFFSET
		Directions.EAST: entrance_player_position = find_child("EastExitArea").global_position + Vector2.LEFT * ENTRANCE_PLACEMENT_OFFSET
	print("Player Position: "+str(player.global_position))
	print("Entrance Player Position: "+str(entrance_player_position))
	G.halt_actions = true
	entrance_tween = create_tween()
	entrance_tween.set_ease(Tween.EASE_OUT)
	entrance_tween.tween_property(player,"global_position",entrance_player_position,TRANSITION_TIME)
	if has_enemies:
		entrance_tween.tween_callback(close_doors)
	entrance_tween.tween_property(G,"halt_actions",false,0)
	var usable_directions: Array[Directions] = [Directions.NORTH,Directions.SOUTH,Directions.EAST,Directions.WEST]
	usable_directions.erase(entrance_direction)
	special_exit_direction = usable_directions.pick_random()
	if player.item_manager.check_for_item("contract"):
		#print('has item')
		_contract_effect()
	

func _room_cleared():
	room_cleared.emit(self)
	if tokens_on_clear != 0:
		acquire_token.emit(tokens_on_clear)
	open_doors()

func _contract_effect():
	print("Contract Effect")
	if !enemies.get_children():
		return
	var contract_enemy: Enemy = enemies.get_children().pick_random()
	var shader_material: ShaderMaterial = contract_enemy.character_sprite.material.duplicate()
	shader_material.set_shader_parameter("outline_width", 1.0)
	shader_material.set_shader_parameter("outline_color", Color.DARK_RED)
	shader_material.set_shader_parameter("outline_number_of_images", contract_enemy.sprite_sheet_dimensions)
	contract_enemy.flags.append("CONTRACT")
	contract_enemy.character_sprite.material = shader_material
	contract_enemy.grant_combo_on_death += 0.6
	


func _on_exit_body_entered(body: Node2D, direction: Directions) -> void:
	print("Room Exit Body Entered"+str(Directions.find_key(direction)))
	if entrance_tween and entrance_tween.is_running():
		return
	if has_enemies or !body is Player:
		return
	print("Exiting")
	room_exited.emit(self,direction)

func _on_enemy_died(_enemy: Enemy):
	for enemy: Enemy in enemies.get_children():
		if enemy.is_alive:
			return
	has_enemies = false
	_room_cleared()
