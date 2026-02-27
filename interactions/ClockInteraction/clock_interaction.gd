class_name ClockInteraction
extends AbstractInteraction

## Seconds removed from the preparation timer on each use.
@export var time_skip: float = 10.0

## How many times the player can use this clock per round.
## Set to 0 for unlimited uses.
@export var max_uses: int = 3

var _uses_left: int
var _audio: AudioStreamPlayer3D

func _ready() -> void:
	super()
	_uses_left = max_uses
	_audio = AudioStreamPlayer3D.new()
	_audio.stream = preload("res://assets/sound_effects/handleCoins2.ogg")
	add_child(_audio)

func pre_interact() -> void:
	if GameManager.current_phase != GameManager.GamePhase.PREPARATION:
		return
	if max_uses > 0 and _uses_left <= 0:
		return

	if max_uses > 0:
		_uses_left -= 1
		can_interact = _uses_left > 0

	_audio.play()
	GameManager.skip_time(time_skip)

func interact() -> void:
	pass

func post_interact() -> void:
	pass
