extends Node

const _MAIN_THEME: String  = "res://assets/audio/soundtrack/main.mp3"
const _WIN_THEME: String   = "res://assets/audio/soundtrack/win_theme.mp3"
const _LOSE_THEME: String  = "res://assets/audio/soundtrack/loose_theme.mp3"

var _player: AudioStreamPlayer = null

func _ready() -> void:
	_player = AudioStreamPlayer.new()
	_player.bus = "Master"
	add_child(_player)

	GameManager.disaster_set.connect(_on_disaster_set)
	GameManager.game_won.connect(_on_game_won)
	GameManager.game_lost.connect(_on_game_lost)

	_play(_MAIN_THEME)

func _play(path: String) -> void:
	if path == "":
		return
	_player.stream = load(path)
	_player.play()

func _on_disaster_set(disaster: DisasterData) -> void:
	if disaster.soundtrack_path != "":
		_play(disaster.soundtrack_path)

func _on_game_won() -> void:
	_play(_WIN_THEME)

func _on_game_lost() -> void:
	_play(_LOSE_THEME)
