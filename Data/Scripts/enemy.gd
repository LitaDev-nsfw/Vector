extends CharacterBody2D
class_name Enemy

enum AimTypes {
	AIMED,
	FORWARDED,
	ONE_WAY,
	AIMED_FOUR_WAY,
	AIMED_FOUR_WAY_DIAGONAL,
	TWO_WAY,
	FOUR_WAY,
}


@export var health: float = 20
@export var invincible: bool = false
