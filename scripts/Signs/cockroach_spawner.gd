extends Node3D
class_name CockroachSpawner

@export var cockroach_scene: PackedScene
@export var count: int = 6
@export var spawn_radius: float = 2.0

func _ready() -> void:
	GameManager.disaster_set.connect(_on_disaster_set)

func _on_disaster_set(_disaster: DisasterData) -> void:
	GameManager.disaster_set.disconnect(_on_disaster_set)
	if DisasterAware.sign_enabled("cockroaches"):
		_spawn_cockroaches()

func _spawn_cockroaches() -> void:
	if cockroach_scene == null:
		push_warning("CockroachSpawner: no cockroach_scene assigned.")
		return
	for _i: int in count:
		var instance: Node3D = cockroach_scene.instantiate()
		add_child(instance)
		var angle: float = randf() * TAU
		var dist: float = randf_range(0.0, spawn_radius)
		instance.position = Vector3(cos(angle) * dist, 0.0, sin(angle) * dist)
		instance.rotation.y = randf() * TAU
