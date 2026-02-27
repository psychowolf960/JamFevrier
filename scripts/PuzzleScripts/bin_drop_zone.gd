extends Area3D

@export var bins_required: int = 2
@export var bin_group: String = "bin"

var _bins_deposited: int = 0
var _completed: bool = false

func _ready() -> void:
	body_entered.connect(_on_body_entered)

func _on_body_entered(body: Node3D) -> void:
	if _completed:
		return
	if not body.is_in_group(bin_group):
		return
	_bins_deposited += 1
	if _bins_deposited >= bins_required:
		_completed = true
		TaskManager.complete_task("take_out_bins")
