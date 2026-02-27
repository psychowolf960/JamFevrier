extends Node

signal timer_updated(time_left: float)
signal disaster_set(disaster: DisasterData)
signal disaster_revealed()
signal game_won()
signal game_lost()

enum GamePhase {
	NONE,
	PREPARATION,
	DISASTER,
	WIN,
	LOSE
}

const PREPARATION_DURATION: float = 50

var current_disaster: DisasterData = null
var current_phase: GamePhase = GamePhase.NONE

var _timer: Timer = null

func _ready() -> void:
	_timer = Timer.new()
	_timer.wait_time = PREPARATION_DURATION
	_timer.one_shot = true
	_timer.timeout.connect(_on_timer_timeout)
	add_child(_timer)

func _process(_delta: float) -> void:
	if current_phase == GamePhase.PREPARATION:
		timer_updated.emit(_timer.time_left)

func start_preparation_phase() -> void:
	current_phase = GamePhase.PREPARATION
	_timer.start()

func get_time_left() -> float:
	return _timer.time_left

func set_current_disaster(disaster: DisasterData) -> void:
	current_disaster = disaster
	disaster_set.emit(disaster)

func resolve_disaster(won: bool) -> void:
	if won:
		current_phase = GamePhase.WIN
		game_won.emit()
	else:
		current_phase = GamePhase.LOSE
		game_lost.emit()

func reset() -> void:
	current_disaster = null
	current_phase = GamePhase.NONE
	_timer.stop()
	TaskManager.reset()

func _on_timer_timeout() -> void:
	current_phase = GamePhase.DISASTER
	var result: Dictionary = TaskManager.evaluate_run()
	if result["won"]:
		current_phase = GamePhase.WIN
		game_won.emit()
	else:
		current_phase = GamePhase.LOSE
		game_lost.emit()
