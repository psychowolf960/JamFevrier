class_name ComputerScreen
extends AbstractInteraction

@export var minigame_scene: String = "res://scenes/minigames/tank_minigame.tscn"

var _completed: bool = false

func pre_interact() -> void:
	super()
	if _completed:
		return
	var main: Node = get_tree().get_first_node_in_group("main")
	if main == null or not main.has_method("open_minigame"):
		return
	main.open_minigame(minigame_scene, "tank")
	_completed = true
	can_interact = false
