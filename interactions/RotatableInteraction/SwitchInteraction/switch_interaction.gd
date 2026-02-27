class_name SwitchInteraction
extends RotatableInteraction

"""
SwitchInteraction handles all player interactions with lever-style switches.

Features:
- Detects player input to rotate the switch.
- Applies smooth snapping to either the starting or maximum rotation when the
  player releases the switch.
- Plays movement sounds while the switch is being dragged, with dynamic volume
  scaling based on angular velocity.
- Plays a snapping/impact sound once when the switch reaches its final
  position.

Use this class for interactive levers or any switch object that
rotates within a limited range.
"""

@export var snap_sound_effect: AudioStreamOggVorbis = preload("res://assets/sound_effects/lever_snap.ogg")
var snap_audio_player: AudioStreamPlayer3D

var is_switch_snapping: bool = false

var switch_moved: bool = false

var switch_kickback_triggered: bool = false

var switch_target_rotation: float = 0.0

func _ready() -> void:
	super()
	object_ref = get_parent()
	starting_rotation = object_ref.rotation.z

	snap_audio_player = AudioStreamPlayer3D.new()
	snap_audio_player.stream = snap_sound_effect
	add_child(snap_audio_player)

	creak_velocity_threshold = 0.0001
	fade_speed = 50.0
	volume_scale = 1000.0
	smoothing_coefficient = 8.0

func _enter_tree() -> void:
	movement_sound = preload("res://assets/sound_effects/lever_pull.ogg")

func pre_interact() -> void:
	super()
	switch_moved = false

func interact() -> void:
	super()

func aux_interact() -> void:
	super()

func post_interact() -> void:
	super()
	var percent: float = get_rotation_percentage()
	if percent < 0.3:
		switch_target_rotation = starting_rotation
		is_switch_snapping = true
	elif percent > 0.7:
		switch_target_rotation = maximum_rotation
		is_switch_snapping = true

func _process(delta: float) -> void:
	previous_angle = current_angle
	allow_movement_sound = true
	if is_interacting:
		_play_movement_sounds(delta)

		if switch_moved:
			if abs(object_ref.rotation.z - maximum_rotation) < 0.01 or abs(object_ref.rotation.z - starting_rotation) < 0.01:
				_play_snap_sound(delta)
				switch_moved = false
	else:
		_stop_movement_sounds(delta)
	if is_switch_snapping:
		if not switch_kickback_triggered:
			switch_kickback_triggered = true
			if not snap_audio_player.playing:
				snap_audio_player.stop()
				snap_audio_player.volume_db = 0.0
				snap_audio_player.play()
		object_ref.rotation.z = lerp(object_ref.rotation.z, switch_target_rotation, delta * smoothing_coefficient)

		if abs(object_ref.rotation.z - switch_target_rotation) < 0.01:
			object_ref.rotation.z = switch_target_rotation
			is_switch_snapping = false

		var percentage: float = (object_ref.rotation.z - starting_rotation) / (maximum_rotation - starting_rotation)
		notify_nodes(percentage)
	else:
		switch_kickback_triggered = false

	current_angle = object_ref.rotation.z
	angular_velocity = current_angle - previous_angle

func _input(event: InputEvent) -> void:
	if is_interacting:
		if event is InputEventMouseMotion:
			var prev_angle = object_ref.rotation.z
			object_ref.rotate_z(event.relative.y * .001)
			object_ref.rotation.z = clamp(object_ref.rotation.z, starting_rotation, maximum_rotation)
			var percentage: float = (object_ref.rotation.z - starting_rotation) / (maximum_rotation - starting_rotation)

			if abs(object_ref.rotation.z - prev_angle) > 0.01:
				switch_moved = true

			notify_nodes(percentage)

func _play_snap_sound(delta: float) -> void:
	snap_audio_player.volume_db = 0.0
	snap_audio_player.play()
