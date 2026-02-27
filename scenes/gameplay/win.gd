extends Control

func _ready() -> void:
	Input.set_mouse_mode(Input.MOUSE_MODE_VISIBLE)
	if GameManager.current_disaster != null:
		NotebookManager.record_disaster(GameManager.current_disaster.disaster_id)
	_build_summary()

func _build_summary() -> void:
	var result: Dictionary = TaskManager.evaluate_run()
	var lines: PackedStringArray = []
	for task_id: String in result.correct:
		lines.append("✔  " + TaskManager.get_task_label(task_id))
	%SummaryLabel.text = "\n".join(lines)

func _on_restart_pressed() -> void:
	GameManager.reset()
	TaskManager.reset()
	get_tree().change_scene_to_file("res://scenes/main/main.tscn")
