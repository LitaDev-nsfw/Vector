extends AnimatedSprite2D
class_name Shot

enum BulletTypes {
	STANDARD,
	SHOTGUN,
}

enum Teams {
	PLAYER,
	ENEMY
}

var team: Teams = Teams.PLAYER
var damages_self: bool = false
var bullet_type: BulletTypes = BulletTypes.STANDARD
var was_parried = false
var vector: Vector2
var shot_speed: float

var shot_owner: CharacterBody2D

func _ready():
	var anim_name = BulletTypes.find_key(bullet_type).to_lower() + "_"
	if team == Teams.ENEMY:
		anim_name += "enemy"
	else:
		anim_name += "friendly"
	play(anim_name)

func _process(delta: float) -> void:
	global_rotation = vector.angle()
	if G.halt_actions:
		return
	position += vector.normalized() * shot_speed * delta
	#print(vector.angle())
	

func _on_hitbox_body_entered(body: Node2D) -> void:
	var ignore_team = false
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
		elif ignore_team:
			body.take_damage(shot_owner.health / 4)
	print("Removing Shot")
	queue_free()
