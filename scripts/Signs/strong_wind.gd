extends Node3D
class_name StrongWind

@onready var _audio: AudioStreamPlayer3D = $Rain
@onready var _particles: GPUParticles3D = $GPUParticles3D

func _ready() -> void:
	_particles.emitting = false
	GameManager.disaster_set.connect(_on_disaster_set)

func _on_disaster_set(_disaster: DisasterData) -> void:
	GameManager.disaster_set.disconnect(_on_disaster_set)
	if DisasterAware.sign_enabled("strong_wind"):
		_audio.play()
		_particles.emitting = true
