extends Node2D
class_name Room

enum Directions {
	NORTH,
	EAST,
	SOUTH,
	WEST
}

@export var has_enemies := true



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
@onready var player: Player = get_tree().get_first_node_in_group("Player")
@onready var enemies: Node2D = find_child("Enemies")

const TRANSITION_TIME = 1.0
const ENTRANCE_PLACEMENT_OFFSET = 20

signal room_exited(room: Room,direction: Room.Directions)

func leave():
	queue_free()

func _ready():
	room_exited.connect(E._on_room_exited)
	E.enemy_died.connect(_on_enemy_died)
	if !entrance_direction: return
	var entrance_player_position: Vector2
	match entrance_direction:
		Directions.NORTH: entrance_player_position = find_child("NorthExitArea").global_position + Vector2.DOWN * ENTRANCE_PLACEMENT_OFFSET
		Directions.SOUTH: entrance_player_position = find_child("SouthExitArea").global_position + Vector2.UP * ENTRANCE_PLACEMENT_OFFSET
		Directions.WEST: entrance_player_position = find_child("WestExitArea").global_position + Vector2.RIGHT * ENTRANCE_PLACEMENT_OFFSET
		Directions.EAST: entrance_player_position = find_child("EastExitArea").global_position + Vector2.LEFT * ENTRANCE_PLACEMENT_OFFSET
	G.halt_actions = true
	entrance_tween = create_tween()
	entrance_tween.set_ease(Tween.EASE_OUT)
	entrance_tween.tween_property(player,"global_position",entrance_player_position,TRANSITION_TIME)
	entrance_tween.tween_property(G,"halt_actions",false,0)
	var usable_directions: Array[Directions] = [Directions.NORTH,Directions.SOUTH,Directions.EAST,Directions.WEST]
	usable_directions.erase(entrance_direction)
	special_exit_direction = usable_directions.pick_random()
	if player.item_manager.check_for_item("contract"):
		#print('has item')
		_contract_effect()
	

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
