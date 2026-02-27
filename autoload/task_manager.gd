extends Node

signal task_completed(task_id: String)

const TASK_LABELS: Dictionary = {
	"barricade_planks": "Barricader la fenêtre",
	"disinfect_ducts": "Désinfecter les conduits",
	"orient_dish": "Orienter l'antenne",
	"restore_power": "Rétablir le courant",
	"tank": "Commander le tank",
	"cut_tree": "Couper l'arbre",
	"take_out_bins":"Sortir les poubelles",
}

var _completed_tasks: Array[String] = []

func get_task_label(task_id: String) -> String:
	return TASK_LABELS.get(task_id, task_id)

func complete_task(task_id: String) -> void:
	if task_id in _completed_tasks:
		return
	_completed_tasks.append(task_id)
	task_completed.emit(task_id)
	print(task_id)

func get_completed_tasks() -> Array[String]:
	return _completed_tasks.duplicate()

func evaluate_run() -> Dictionary:
	var disaster: DisasterData = GameManager.current_disaster
	var required: Array[String] = disaster.required_task_ids.duplicate()
	var completed: Array[String] = _completed_tasks.duplicate()

	var correct: Array[String] = []
	var wrong: Array[String] = []
	var missing: Array[String] = []

	for task_id: String in completed:
		if task_id in required:
			correct.append(task_id)
		else:
			wrong.append(task_id)

	for task_id: String in required:
		if task_id not in completed:
			missing.append(task_id)

	var won: bool = wrong.is_empty() and missing.is_empty()

	if not won:
		if not wrong.is_empty():
			print("TaskManager | wrong tasks: ", wrong)
		if not missing.is_empty():
			print("TaskManager | missing tasks: ", missing)

	return {"won": won, "correct": correct, "wrong": wrong, "missing": missing}

func reset() -> void:
	_completed_tasks.clear()
