class_name DishTarget
extends Node

@export var target_percentage: float = 0.5
@export var tolerance: float = 0.05
@export var max_beep_interval: float = 2.0
@export var min_beep_interval: float = 0.08
@export var hold_duration: float = 2.0
@export var still_threshold: float = 0.001

var _beep_sound: AudioStream = preload("res://assets/sound_effects/keypad_press.ogg")
var _success_sound: AudioStream = preload("res://assets/audio/validate.mp3")

@onready var _beep_player: AudioStreamPlayer3D = $"../AudioStreamPlayer3D"
var _beep_timer: float = 0.0
var _hold_timer: float = 0.0
var _locked: bool = false
var _wheel: WheelInteraction

func _ready() -> void:
	for child in get_parent().get_children():
		if child is WheelInteraction:
			_wheel = child
			break

	if _wheel == null:
		push_warning("DishTarget: aucun WheelInteraction trouvé dans les siblings de %s" % get_parent().name)

func _process(delta: float) -> void:
	if _locked or _wheel == null:
		return

	var percentage: float = _wheel.get_rotation_percentage()
	var distance: float = abs(percentage - target_percentage)
	var is_still: bool = abs(_wheel.angular_velocity) < still_threshold
	var in_range: bool = distance <= tolerance

	_beep_timer -= delta
	if _beep_timer <= 0.0:
		var t: float = clamp(1.0 - distance / 0.5, 0.0, 1.0)
		_beep_timer = lerpf(max_beep_interval, min_beep_interval, t)
		_beep_player.play()

	if in_range and is_still:
		_hold_timer += delta
		if _hold_timer >= hold_duration:
			_validate()
	else:
		_hold_timer = 0.0

func _validate() -> void:
	_locked = true
	_beep_player.stream = _success_sound
	_beep_player.play()
	_wheel.queue_free()
	TaskManager.complete_task("orient_dish")
