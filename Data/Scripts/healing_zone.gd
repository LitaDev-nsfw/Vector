extends Area2D

var used = false

const HEAL_ANIM_LENGTH = 1.0

func _on_body_entered(body: Node2D) -> void:
	if not body is Player or used:
		return
	var player: Player = body
	G.halt_actions = true
	var heal_tween: Tween = create_tween()
	heal_tween.tween_property(player,"health",player.max_health, HEAL_ANIM_LENGTH)
	var combo_deplete_tween: Tween = create_tween()
	combo_deplete_tween.tween_property(player,"current_combo_life",0,HEAL_ANIM_LENGTH)
	combo_deplete_tween.tween_property(G,"halt_actions",false,0)
	used = true
