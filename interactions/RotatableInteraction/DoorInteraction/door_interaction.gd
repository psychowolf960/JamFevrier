class_name DoorInteraction
extends RotatableInteraction

@export var pivot_point: Node3D
@export var flip_pivot: bool = false
@export var open_degrees: float = 90.0
@export var swing_time: float = 0.7

@export var shut_sound: AudioStreamOggVorbis = preload("res://assets/sound_effects/DoorClose2.ogg")

var _open: bool = false
var _tween: Tween
var _shut_player: AudioStreamPlayer3D
var _base_y: float

func _ready() -> void:
	movement_sound = preload("res://assets/sound_effects/DoorCreak.ogg")
	super()
	_base_y             = pivot_point.rotation.y
	_shut_player        = AudioStreamPlayer3D.new()
	_shut_player.stream = shut_sound
	add_child(_shut_player)

func pre_interact() -> void:
	_toggle()

func interact() -> void:
	pass

func post_interact() -> void:
	pass

func set_direction(_normal: Vector3) -> void:
	pass

func _toggle() -> void:
	_open = not _open
	var dir    := -1.0 if flip_pivot else 1.0
	var target := _base_y + deg_to_rad(open_degrees) * dir if _open else _base_y
	if _tween:
		_tween.kill()
	_tween = create_tween()
	movement_audio_player.play()
	_tween.tween_property(pivot_point, "rotation:y", target, swing_time) \
		.set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_IN_OUT)
	_tween.tween_callback(func() -> void:
		movement_audio_player.stop()
		if not _open:
			_shut_player.play()
	)
