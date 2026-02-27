extends CharacterBody3D
class_name CockroachInstance

@export var crush_sound: AudioStream
@export var speed: float = 0.4
@export var direction_change_time: float = 1.5

@onready var _area: Area3D = $Area3D

var _timer: float = 0.0

var GRAVITY: float = ProjectSettings.get_setting("physics/3d/default_gravity")

func _ready() -> void:
	_area.input_ray_pickable = true
	_area.input_event.connect(_on_input_event)
	_timer = randf() * direction_change_time
	_pick_new_direction()

func _physics_process(delta: float) -> void:
	if not is_on_floor():
		velocity.y -= GRAVITY * delta
	_timer -= delta
	if _timer <= 0.0:
		_pick_new_direction()
	move_and_slide()

func _pick_new_direction() -> void:
	_timer = direction_change_time + randf_range(-0.5, 0.5)
	if randf() < 0.2:
		velocity.x = 0.0
		velocity.z = 0.0
		return
	var angle := randf() * TAU
	velocity.x = cos(angle) * speed
	velocity.z = sin(angle) * speed
	rotation.y = atan2(-velocity.x, -velocity.z)

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
