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

var vector: Vector2
var shot_speed: float

var shot_owner

func _ready():
	var anim_name = BulletTypes.find_key(bullet_type).to_lower() + "_"
	if team == Teams.ENEMY:
		anim_name += "enemy"
	else:
		anim_name += "friendly"

func _process(delta: float) -> void:
	position += vector * shot_speed * delta
	#print(vector.angle())
	global_rotation = vector.angle() + (.5*PI)

func _on_hitbox_body_entered(body: Node2D) -> void:
	var ignore_team = false
	print(body)
	if body == shot_owner:
		if !damages_self:
			return
		else:
			ignore_team = true
	if body is Player and (team == Teams.ENEMY or ignore_team):
		body.take_damage()
	if body is Enemy:
		if (team == Teams.PLAYER):
			body.take_damage(shot_owner.get_attribute(Player.Attributes.DAMAGE))
		elif ignore_team:
			body.take_damage(shot_owner.health / 4)
	print("Removing Shot")
	queue_free()
