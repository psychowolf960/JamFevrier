extends AbstractInteraction

@export var saw_item_name: String = "Saw"
@export var uses_required: int = 5

var _uses: int = 0
var _completed: bool = false

func _ready() -> void:
	super()
	add_to_group(&"CLIMBEABLE") # Used by raycast for climb.

func use_item(item_data: ItemData) -> bool:
	if _completed:
		return false
	if item_data.item_name != saw_item_name:
		return false
	_uses += 1
	var percentage: float = float(_uses) / float(uses_required) * 100.0
	notify_nodes(percentage)
	if _uses >= uses_required:
		$tree.queue_free()
		_completed = true
		can_interact = false
		TaskManager.complete_task("cut_tree")
	return true
