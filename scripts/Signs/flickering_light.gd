extends Light3D
class_name FlickeringLight

@export var base_energy: float = 0.0
@export var min_energy: float = 0.0
@export var interval_min: float = 2.0
@export var interval_max: float = 8.0
@export var flicker_count_min: int = 1
@export var flicker_count_max: int = 4

func _ready() -> void:
	base_energy = light_energy
	GameManager.disaster_set.connect(_on_disaster_set)

func _on_disaster_set(_disaster: DisasterData) -> void:
	GameManager.disaster_set.disconnect(_on_disaster_set)
	if DisasterAware.sign_enabled("flickering_lights"):
		_schedule_next()

func _schedule_next() -> void:
	var delay: float = randf_range(interval_min, interval_max)
	await get_tree().create_timer(delay).timeout
	if not is_inside_tree():
		return
	await _do_flicker_sequence()
	_schedule_next()

func _do_flicker_sequence() -> void:
	var count: int = randi_range(flicker_count_min, flicker_count_max)
	for _i: int in count:
		var off_duration: float = randf_range(0.03, 0.18)
		light_energy = min_energy
		await get_tree().create_timer(off_duration).timeout
		if not is_inside_tree():
			return
		var on_duration: float = randf_range(0.02, 0.12)
		light_energy = base_energy
		await get_tree().create_timer(on_duration).timeout
		if not is_inside_tree():
			return
