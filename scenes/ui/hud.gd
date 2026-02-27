extends CanvasLayer

@onready var _aiguille: Sprite2D = %Aiguille
@onready var _counter: Label = %Counter

var _notif_scene: PackedScene = preload("res://scenes/ui/task_notification.tscn")
const NOTIF_X: float = 16.0
const NOTIF_STACK_OFFSET: float = 56.0

func _ready() -> void:
	TaskManager.task_completed.connect(_on_task_completed)
	GameManager.disaster_set.connect(_on_disaster_set)
	_update_journal_counter()

func update_timer(time_left: float) -> void:
	var elapsed: float = GameManager.PREPARATION_DURATION - time_left
	_aiguille.rotation = (elapsed / GameManager.PREPARATION_DURATION) * TAU

func _on_disaster_set(disaster: DisasterData) -> void:
	NotebookManager.record_disaster(disaster.disaster_id)
	_update_journal_counter()

func _update_journal_counter() -> void:
	var discovered: int = NotebookManager.get_encountered().size()
	var total: int = DisasterManager.get_disasters().size()
	_counter.text = "%d / %d" % [discovered, total]

func _on_task_completed(task_id: String) -> void:
	_spawn_notification(TaskManager.get_task_label(task_id))

func _spawn_notification(label: String) -> void:
	var notif: Control = _notif_scene.instantiate()
	add_child(notif)
	var stack_index: int = 0
	for child in get_children():
		if child != notif and child is Control and child.visible and child.has_method("show_task"):
			stack_index += 1
	notif.position = Vector2(NOTIF_X, 0.0)
	notif.slide_distance = 16.0 + stack_index * NOTIF_STACK_OFFSET
	notif.show_task(label)
