extends Node

var _disasters: Array[DisasterData] = []
var _used_ids: Array[String] = []

var _ambient_player: AudioStreamPlayer = null

func _ready() -> void:
	_load_disasters()
	GameManager.disaster_set.connect(_on_disaster_set)

func _on_disaster_set(disaster: DisasterData) -> void:
	if disaster.ambient_audio_path == "":
		return
	if _ambient_player == null:
		_ambient_player = AudioStreamPlayer.new()
		add_child(_ambient_player)
	_ambient_player.stream = load(disaster.ambient_audio_path)
	_ambient_player.play()

func _load_disasters() -> void:
	var dir: DirAccess = DirAccess.open("res://resources/disasters/")
	if dir == null:
		push_error("DisasterManager: cannot open res://resources/disasters/")
		return
	dir.list_dir_begin()
	var file_name: String = dir.get_next()
	while file_name != "":
		if file_name.ends_with(".tres"):
			var res: Resource = load("res://resources/disasters/" + file_name)
			if res is DisasterData:
				_disasters.append(res as DisasterData)
		file_name = dir.get_next()
	dir.list_dir_end()

func select_random_disaster() -> DisasterData:
	if _disasters.is_empty():
		push_error("DisasterManager: no disasters loaded.")
		return null
	var available := _disasters.filter(func(d: DisasterData) -> bool:
		return d.disaster_id not in _used_ids
	)
	if available.is_empty():
		_used_ids.clear()
		available = _disasters.duplicate()
	var picked: DisasterData = available[randi() % available.size()]
	_used_ids.append(picked.disaster_id)
	GameManager.set_current_disaster(picked)
	return picked

func reset_used() -> void:
	_used_ids.clear()

func stop_ambient_audio() -> void:
	if _ambient_player and _ambient_player.playing:
		_ambient_player.stop()

func get_disasters() -> Array[DisasterData]:
	var sorted: Array[DisasterData] = _disasters.duplicate()
	sorted.sort_custom(func(a: DisasterData, b: DisasterData) -> bool:
		return a.disaster_name < b.disaster_name
	)
	return sorted
