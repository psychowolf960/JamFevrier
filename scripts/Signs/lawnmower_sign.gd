extends Node3D
class_name LawnmowerSign

@export var animation_player: AnimationPlayer
@export var animation_name: String = "run"

func _ready() -> void:
	GameManager.disaster_set.connect(_on_disaster_set)

func _on_disaster_set(_disaster: DisasterData) -> void:
	GameManager.disaster_set.disconnect(_on_disaster_set)
	if DisasterAware.sign_enabled("lawnmower"):
		if animation_player == null:
			push_warning("LawnmowerSign: no animation_player assigned.")
			return
		animation_player.play(animation_name)
