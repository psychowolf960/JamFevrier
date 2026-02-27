extends Node2D
class_name PlankPiece

signal screw_placed

@export var screws_required: int = 2

var _screw_count: int = 0
var _validated: bool = false

var _screw_anim_scene: PackedScene = preload("res://scenes/minigames/screw_anim.tscn")

@onready var _area: Area2D = $Area2D

func _ready() -> void:
	_area.input_pickable = true
	_area.input_event.connect(_on_area_input_event)

func _on_area_input_event(_viewport: Viewport, event: InputEvent, _shape_idx: int) -> void:
	if _validated:
		return
	if event is InputEventMouseButton \
			and event.button_index == MOUSE_BUTTON_LEFT \
			and event.pressed:
		_place_screw(to_local(get_viewport().get_mouse_position()))
		get_viewport().set_input_as_handled()

func _place_screw(local_pos: Vector2) -> void:
	_screw_count += 1
	var anim: Node2D = _screw_anim_scene.instantiate()
	add_child(anim)
	anim.position = local_pos
	anim.start()
	if _screw_count >= screws_required:
		_validated = true
	screw_placed.emit()

func is_validated() -> bool:
	return _validated
