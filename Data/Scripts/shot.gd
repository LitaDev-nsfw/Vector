extends AnimatedSprite2D
class_name Shot

enum ShotEffects {
	FREEZE,
}

enum BulletTypes {
	STANDARD,
	SHOTGUN,
}

enum Teams {
	PLAYER,
	ENEMY
}

var debug = false
var debug_line: Line2D
var team: Teams = Teams.PLAYER
var damages_self: bool = false
var bullet_type: BulletTypes = BulletTypes.STANDARD
var was_parried = false
var vector: Vector2
var shot_speed: float

var shot_owner: CharacterBody2D



var on_hit_effects: Array[Dictionary] = []

func _ready():
	if debug:
		debug_line = Line2D.new()
		debug_line.add_point(Vector2())
		debug_line.add_point(vector*1000)
		debug_line.width = 1
		get_parent().add_child(debug_line)
		debug_line.global_position = global_position
	var anim_name = BulletTypes.find_key(bullet_type).to_lower() + "_"
	if team == Teams.ENEMY:
		anim_name += "enemy"
	else:
		anim_name += "friendly"
	print(anim_name)
	play(anim_name)

func _process(delta: float) -> void:
	global_rotation = vector.angle()
	if G.halt_actions:
		return
	position += vector.normalized() * shot_speed * delta
	#print(vector.angle())
	

func _on_hitbox_body_entered(body: Node2D) -> void:
	var ignore_team = false
	var body_was_hit = false
	print("Body: " +body.name)
	if body == shot_owner:
		print("Body is owner")
		if !damages_self:
			return
		else:
			ignore_team = true
	print("Body is not owner")
	if body is Player and (team == Teams.ENEMY or ignore_team):
		print("Body is Player")
		body_was_hit = true
		body.take_damage()
	if body is Enemy:
		print("Body is Enemy")
		if (team == Teams.PLAYER):
			if !shot_owner.is_inside_tree():
				return
			var shot_multiplier = shot_owner.current_combo
			if was_parried:
				shot_multiplier += 1
			body.take_damage(shot_owner.get_attribute(Player.Attributes.DAMAGE)*shot_multiplier)
			body_was_hit = true
		elif ignore_team:
			body.take_damage(shot_owner.health / 4)
			body_was_hit = true
	if body_was_hit:
		for effect in on_hit_effects:
			match effect.id:
				"freeze_shots":
					if randi_range(1,100) <= effect.chance:
						body.inflict_effect(ShotEffects.FREEZE,effect.duration)
	if debug:
		debug_line.queue_free()
	queue_free()
