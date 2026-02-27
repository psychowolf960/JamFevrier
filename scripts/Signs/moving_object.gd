extends RigidBody3D
class_name MovingObject

@export var impulse_strength: float = 0.8
@export var interval_min: float = 3.0
@export var interval_max: float = 9.0

func _ready() -> void:
	GameManager.disaster_set.connect(_on_disaster_set)

func _on_disaster_set(_disaster: DisasterData) -> void:
	GameManager.disaster_set.disconnect(_on_disaster_set)
	if DisasterAware.sign_enabled("moving_objects"):
		_schedule_next()

func _schedule_next() -> void:
	var delay: float = randf_range(interval_min, interval_max)
	await get_tree().create_timer(delay).timeout
	if not is_inside_tree():
		return
	_apply_random_impulse()
	_schedule_next()

func _apply_random_impulse() -> void:
	var dir: Vector3 = Vector3(
		randf_range(-1.0, 1.0),
		randf_range(0.1, 0.4),
		randf_range(-1.0, 1.0)
	).normalized()
	apply_central_impulse(dir * impulse_strength)
