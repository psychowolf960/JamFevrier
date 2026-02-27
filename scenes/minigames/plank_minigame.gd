extends CanvasLayer

signal minigame_completed
signal minigame_cancelled

@export var plank_count: int = 4
@export var screws_per_plank: int = 2
@export var spawn_radius: float = 200.0

var _plank_scene: PackedScene = preload("res://scenes/minigames/plank_piece.tscn")

@onready var _screw_audio: AudioStreamPlayer = $ScrewAudioPlayer
@onready var _success_audio: AudioStreamPlayer = $SuccessAudioPlayer
@onready var _game_area: Node2D = $GameArea

var _planks: Array[Node] = []
var _completed: bool = false

func _ready() -> void:
	_spawn_planks()

func _spawn_planks() -> void:
	var screen_center: Vector2 = get_viewport().get_visible_rect().size * 0.5
	for _i: int in plank_count:
		var plank: Node = _plank_scene.instantiate()
		_game_area.add_child(plank)
		plank.screws_required = screws_per_plank
		plank.screw_placed.connect(_on_screw_placed)
		var angle: float = randf_range(0.0, TAU)
		var radius: float = randf_range(0.0, spawn_radius)
		plank.position = screen_center + Vector2(cos(angle), sin(angle)) * radius
		plank.rotation = randf_range(-PI * 0.45, PI * 0.45)
		_planks.append(plank)

func _on_screw_placed() -> void:
	_screw_audio.play()
	_check_completion()

func _check_completion() -> void:
	if _completed:
		return
	for plank in _planks:
		if not plank.is_validated():
			return
	_completed = true
	_success_audio.play()
	await get_tree().create_timer(0.8).timeout
	minigame_completed.emit()

func _input(event: InputEvent) -> void:
	if event.is_action_pressed("ui_cancel"):
		minigame_cancelled.emit()
