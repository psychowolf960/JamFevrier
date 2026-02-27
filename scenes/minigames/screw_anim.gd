extends Node2D

const ANIM_DURATION: float = 0.3
const ROTATIONS: float = 4.0

@export var end_scale: float = 0.6

@onready var _screw_sprite: Sprite2D = $ScrewSprite

func start() -> void:
	var tween: Tween = create_tween()
	tween.set_parallel(true)

	tween.tween_property(
		self, "scale",
		Vector2(end_scale, end_scale), ANIM_DURATION
	).set_trans(Tween.TRANS_CUBIC).set_ease(Tween.EASE_OUT)

	tween.tween_property(
		self, "rotation",
		TAU * ROTATIONS, ANIM_DURATION
	).set_trans(Tween.TRANS_QUAD).set_ease(Tween.EASE_OUT)
