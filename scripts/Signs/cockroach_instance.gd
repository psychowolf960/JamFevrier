extends Node3D
class_name CockroachInstance

@export var crush_sound: AudioStream

@onready var _area: Area3D = $Area3D

func _ready() -> void:
	_area.input_ray_pickable = true
	_area.input_event.connect(_on_input_event)

func _on_input_event(_camera: Node, event: InputEvent, _pos: Vector3, _normal: Vector3, _shape: int) -> void:
	if event is InputEventMouseButton and event.pressed and event.button_index == MOUSE_BUTTON_LEFT:
		_crush()

func _crush() -> void:
	if crush_sound:
		var player := AudioStreamPlayer3D.new()
		get_parent().add_child(player)
		player.global_position = global_position
		player.stream = crush_sound
		player.play()
		player.finished.connect(player.queue_free)
	queue_free()
