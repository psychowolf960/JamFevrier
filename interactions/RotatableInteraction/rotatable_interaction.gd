class_name RotatableInteraction
extends AbstractInteraction

"""
RotatableInteraction is an intermediary interaction class that defines rotation
related properties and setup.

This class does not implement the full rotation behavior itself; child classes
should handle the actual rotation logic and interaction mechanics.  Use this as
a base for doors, wheels, switches, or any other rotatable objects in the game.
"""

@export var movement_sound: AudioStreamOggVorbis
var movement_audio_player: AudioStreamPlayer3D

@export var maximum_rotation: float

var starting_rotation: float = 0.0

var current_angle: float = 0.0

var previous_angle: float = 0.0

var angular_velocity: float = 0.0

var creak_velocity_threshold: float

var fade_speed: float

var volume_scale: float

var smoothing_coefficient: float

var allow_movement_sound: bool = false

var input_active: bool = false

func _ready() -> void:
	super()
	maximum_rotation = deg_to_rad(rad_to_deg(starting_rotation)+maximum_rotation)

	movement_audio_player = AudioStreamPlayer3D.new()
	movement_audio_player.stream = movement_sound
	add_child(movement_audio_player)

func pre_interact() -> void:
	super()
	lock_camera = true
	previous_angle = current_angle

func interact() -> void:
	super()
	_play_movement_sounds(get_process_delta_time())

func aux_interact() -> void:
	super()

func post_interact() -> void:
	super()

func get_rotation_percentage() -> float:
	return (object_ref.rotation.z - starting_rotation) / (maximum_rotation - starting_rotation)

func _play_movement_sounds(delta: float) -> void:
	var velocity = abs(current_angle - previous_angle)

	var target_volume: float = 0.0
	if velocity > creak_velocity_threshold:
		target_volume = clamp((velocity - creak_velocity_threshold) * volume_scale, 0.0, 1.5)

	if movement_audio_player and not movement_audio_player.playing and target_volume > 0.0:
		movement_audio_player.volume_db = -15.0
		movement_audio_player.play()

	if movement_audio_player.playing:
		var current_vol = db_to_linear(movement_audio_player.volume_db)
		var new_vol = lerp(current_vol, target_volume, delta * fade_speed)
		movement_audio_player.volume_db = linear_to_db(clamp(new_vol, 0.0, 1.5))

		if new_vol < 0.001 and target_volume == 0.0:
			movement_audio_player.stop()

func _stop_movement_sounds(delta: float) -> void:
	if allow_movement_sound:
		if movement_audio_player and movement_audio_player.playing:
			var current_vol = db_to_linear(movement_audio_player.volume_db)
			var new_vol = lerp(current_vol, 0.0, delta * fade_speed)
			movement_audio_player.volume_db = linear_to_db(clamp(new_vol, 0.0, 1.0))

			if new_vol < 0.001:
				movement_audio_player.stop()
