class_name AudioTape extends Node

const SAVE_ON_EXIT : bool = true

const AUDIO_STREAM = preload("uid://c830t858g44mi")

const FILE : String = "user://user_game.cfg"
const SECTION : String = "COLLECTION"
const KEY : String = "TAPE"

## Emmited when collect new item or clear list.
signal on_collection_changed()

#region internal_use
static var _collected : Dictionary = {}
static var _singleton : AudioTape = null
#endregion

# AudioPlayer3D reference
var _player : AudioStreamPlayer = null

func _ready() -> void:
	_player = AUDIO_STREAM.instantiate()
	add_child(_player)

static func _static_init() -> void:
	#load from file
	var cfg : ConfigFile = ConfigFile.new()
	cfg.load_encrypted_pass(FILE, "FooAnyPassword")
	
	var value : Variant = cfg.get_value(SECTION, KEY, {})
	if value is Dictionary:
		_collected.merge(value)
	
	cfg = null

static func get_singleton() -> AudioTape:
	if _singleton == null:
		var root : Node = Engine.get_main_loop().root
		
		if !root.is_node_ready():
			await root.ready
			
		_singleton = AudioTape.new()
		root.add_child(_singleton)
	return _singleton

## Get ordered collection dictionary. [uid : int, resource_path : String]	
static func get_collection_in_order() -> Dictionary:
	_collected.sort()
	return _collected
	
static func save_collections() -> void:
	var cfg : ConfigFile = ConfigFile.new()
	cfg.set_value(SECTION, KEY, _collected)
	cfg.save_encrypted_pass(FILE, "FooAnyPassword")
	cfg = null
	
func _notification(what: int) -> void:
	if what == NOTIFICATION_PREDELETE:
		if SAVE_ON_EXIT:
			save_collections()
		_singleton = null
		
## Collect a collision object typeof collectionableNode
static func collect(object : CollectionableNode, play_now : bool = true) -> void:
	# Use object.scene_file_path if you want re-instante scene of the node for replay purporses or set only audio path.
	_collected[object.uid] = object.resource_path # dirty flag
	
	if play_now:
		assert(ResourceLoader.exists(object.resource_path))
		
		var res : Resource = ResourceLoader.load(object.resource_path)
		if res is AudioStream:
			play(res)
			
	object.disable()
	
	(await get_singleton()).on_collection_changed.emit()
			
static func play(res : AudioStream) -> void:
	var singleton : AudioTape = await get_singleton()
	if singleton._player.playing:
		stop()
	singleton._player.stream = res
	singleton._player.play()
	
## Stop current _player
static func stop() -> void:
	var singleton : AudioTape = await get_singleton()
	if singleton._player.playing:
		singleton._player.stop()
	
## Clear buffer of collection.
static func clear() -> void:
	_collected.clear()
	(await get_singleton()).on_collection_changed.emit()
	
## Clear and overwrite now user data of collections.
static func clear_hard() -> void:
	clear()
	save_collections()
	
## Used for check if a current uid is already collected.
static func is_collected(uid : int) -> bool:
	return _collected.has(uid)
		
#func _input(event: InputEvent) -> void:
	#if event.is_action_pressed(&"stop_audio_tape"):
		#stop()
