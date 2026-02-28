class_name CollectionableNode extends Node3D

## Unique id defined by dev, used for custom order and unique key in collection.
@export var uid : int = 0
## Serializable path of the resource. (this can be ommited if resource is defined)
@export var resource_path : String = ""
## Reference Object for play. (this can be ommited if resource path is defined)
@export var resource : Resource = null

func _ready() -> void:
	if !resource:
		assert(ResourceLoader.exists(resource_path))
		resource = ResourceLoader.load(resource_path)
	else:
		resource_path = resource.resource_path
		assert(!resource_path.is_empty(), "Error!, resource path of collectionable is empty!")

	# Disable is already collected.
	if AudioTape.is_collected(uid):
		disable()
		
func disable() -> void:
	#queue_free() # you can use this.
	# or
	visible = false
	process_mode = Node.PROCESS_MODE_DISABLED
	
func enable() -> void:
	visible = true
	process_mode = Node.PROCESS_MODE_INHERIT
	
