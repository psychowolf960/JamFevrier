extends Control

@export var video_godzilla: VideoStream
@export var video_bug: VideoStream
@export var video_alien: VideoStream
@export var video_tornade: VideoStream

@onready var _video: VideoStreamPlayer = $VideoStreamPlayer
@onready var _ui: Control = $UI

func _get_disaster_video() -> VideoStream:
	var id := GameManager.current_disaster.disaster_id if GameManager.current_disaster else ""
	match id:
		"godzilla": return video_godzilla
		"bug":      return video_bug
		"alien":    return video_alien
		"tornade":  return video_tornade
	return null

func _ready() -> void:
	Input.set_mouse_mode(Input.MOUSE_MODE_VISIBLE)
	if GameManager.current_disaster != null:
		NotebookManager.record_disaster(GameManager.current_disaster.disaster_id)

	var stream := _get_disaster_video()
	if stream != null:
		_video.stream = stream
		_video.visible = true
		_video.play()
		_video.finished.connect(func() -> void: _video.visible = false)

	_show_summary()

func _show_summary() -> void:
	_ui.visible = true
	_build_summary()

func _build_summary() -> void:
	var result: Dictionary = TaskManager.evaluate_run()
	var lines: PackedStringArray = []
	for task_id: String in result.correct:
		lines.append("✔  " + TaskManager.get_task_label(task_id))
	for task_id: String in result.missing:
		lines.append("✘  " + TaskManager.get_task_label(task_id))
	for task_id: String in result.wrong:
		lines.append("⚠  " + TaskManager.get_task_label(task_id) + " (inutile)")
	%SummaryLabel.text = "\n".join(lines)

func _on_restart_pressed() -> void:
	GameManager.reset()
	TaskManager.reset()
	PersistentScene.change_scene("res://scenes/main/main.tscn")
