extends VBoxContainer

func _ready() -> void:
	var audio_tape : AudioTape = await AudioTape.get_singleton()
	audio_tape.on_collection_changed.connect(_on_new_collection)
	_on_new_collection()
	
func _on_new_collection() -> void:
	for node : Node in get_children():
		node.queue_free()
	
	var collections : Dictionary = AudioTape.get_collection_in_order()
	
	for uid : int in collections.keys():
		var label : Label = Label.new()
		label.text = "{0}: {1}".format([uid, str(collections[uid]).get_file().rsplit(".", false, 1)[0].capitalize()])
		add_child(label)
