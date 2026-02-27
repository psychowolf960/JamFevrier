class_name WindowInteraction
extends AbstractInteraction

@export var plank_item_name: String = "Plank"
@export var minigame_scene: String = "res://scenes/minigames/plank_minigame.tscn"

var _completed: bool = false

func use_item(item_data: ItemData) -> bool:
	if _completed:
		return false
	if item_data.item_name != plank_item_name:
		return false
	var main: Node = get_tree().get_first_node_in_group("main")
	if main == null or not main.has_method("open_minigame"):
		return false
	main.open_minigame(minigame_scene, "barricade_planks")
	_completed = true
	can_interact = false
	return true
