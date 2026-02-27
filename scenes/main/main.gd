extends Node3D

@onready var _hud: CanvasLayer = $Hud

var _active_minigame: Node = null
var _notebook: CanvasLayer = null
var _sign_timers: Array[Timer] = []

func _ready() -> void:
	add_to_group("main")
	DisasterManager.select_random_disaster()
	_setup_sign_effects()

	_notebook = preload("res://scenes/ui/notebook_ui.tscn").instantiate()
	add_child(_notebook)
	_notebook.close_requested.connect(_close_notebook)

	GameManager.timer_updated.connect(_on_timer_updated)
	GameManager.game_won.connect(func() -> void:
		PersistentScene.change_scene("res://scenes/gameplay/win.tscn")
	)
	GameManager.game_lost.connect(func() -> void:
		PersistentScene.change_scene("res://scenes/gameplay/lose.tscn")
	)

	GameManager.start_preparation_phase()

func _setup_sign_effects() -> void:
	var disaster: DisasterData = GameManager.current_disaster
	if disaster == null:
		return
	for sign: String in disaster.enabled_signs:
		match sign:
			"tremors":
				_start_tremor_effect()

func _start_tremor_effect() -> void:
	var player := AudioStreamPlayer.new()
	player.stream = preload("res://assets/audio/earthquack.mp3")
	player.volume_db = 0.0
	add_child(player)

	var timer := Timer.new()
	timer.one_shot = true
	add_child(timer)
	_sign_timers.append(timer)

	timer.timeout.connect(func() -> void:
		player.play()
		_shake_player_camera(0.2, 0.08)
		timer.start(randf_range(8.0, 22.0))
	)
	timer.start(randf_range(3.0, 10.0))

func _unhandled_input(event: InputEvent) -> void:
	if event.is_action_pressed("show_hint"):
		_toggle_notebook()

func _toggle_notebook() -> void:
	if _notebook.visible:
		_close_notebook()
	else:
		_open_notebook()

func _open_notebook() -> void:
	if _active_minigame != null:
		return
	_notebook.open()
	Input.mouse_mode = Input.MOUSE_MODE_VISIBLE
	_set_player_camera_locked(true)

func _close_notebook() -> void:
	if not _notebook.visible:
		return
	_notebook.close()
	Input.mouse_mode = Input.MOUSE_MODE_CAPTURED
	_set_player_camera_locked(false)

func open_minigame(scene_path: String, task_id: String) -> void:
	if _active_minigame != null:
		return
	var packed: PackedScene = load(scene_path)
	if packed == null:
		return
	_active_minigame = packed.instantiate()
	add_child(_active_minigame)
	Input.mouse_mode = Input.MOUSE_MODE_VISIBLE
	_set_player_camera_locked(true)
	if _active_minigame.has_signal("minigame_completed"):
		_active_minigame.minigame_completed.connect(func() -> void:
			TaskManager.complete_task(task_id)
			close_minigame()
		)
	if _active_minigame.has_signal("minigame_cancelled"):
		_active_minigame.minigame_cancelled.connect(close_minigame)

func close_minigame() -> void:
	if _active_minigame == null:
		return
	_active_minigame.queue_free()
	_active_minigame = null
	Input.mouse_mode = Input.MOUSE_MODE_CAPTURED
	_set_player_camera_locked(false)

func _shake_player_camera(intensity: float, decay: float) -> void:
	var players: Array[Node] = get_tree().get_nodes_in_group("player")
	if players.is_empty():
		return
	if players[0].has_method("shake_camera"):
		players[0].shake_camera(intensity, decay)

func _set_player_camera_locked(locked: bool) -> void:
	var players: Array[Node] = get_tree().get_nodes_in_group("player")
	if players.is_empty():
		return
	var player: Node = players[0]
	if player.has_method("set_camera_locked"):
		player.set_camera_locked(locked)

func _on_timer_updated(time_left: float) -> void:
	_hud.update_timer(time_left)
