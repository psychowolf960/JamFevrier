extends Control

@export var slide_duration: float = 0.35
@export var slide_distance: float = 90.0
@export var hold_duration: float = 1.8

@onready var _label: Label = $Label
@onready var _check: Label = $CheckLabel

func show_task(task_label: String) -> void:
	_label.text = task_label
	_check.text = "☐"

	position.y = -size.y - 10.0
	visible = true

	var tween: Tween = create_tween()
	tween.set_trans(Tween.TRANS_CUBIC).set_ease(Tween.EASE_OUT)

	tween.tween_property(self, "position:y", slide_distance, slide_duration)

	tween.tween_callback(_mark_checked)
	tween.tween_interval(hold_duration)

	tween.set_ease(Tween.EASE_IN)
	tween.tween_property(self, "position:y", -size.y - 10.0, slide_duration)

	tween.tween_callback(queue_free)

func _mark_checked() -> void:
	_check.text = "✅"
