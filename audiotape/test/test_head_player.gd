extends Node3D
@export var sensitivity := 0.25
@onready var camera := $Camera3D
@onready var ray_cast_3d: RayCast3D = $Camera3D/RayCast3D
@onready var world_environment: WorldEnvironment = $"../WorldEnvironment"
@onready var items: Node3D = $"../items"


func _ready():
	Input.mouse_mode = Input.MOUSE_MODE_CAPTURED

func _unhandled_input(event: InputEvent):
	if event is InputEventMouseMotion:
		rotate_y(deg_to_rad(-event.relative.x * sensitivity))
		camera.rotate_x(deg_to_rad(-event.relative.y * sensitivity))
		camera.rotation.x = clamp(camera.rotation.x, deg_to_rad(-89), deg_to_rad(89))

	if event.is_action_pressed(&"ui_cancel"):
		if Input.mouse_mode == Input.MOUSE_MODE_CAPTURED:
			Input.mouse_mode = Input.MOUSE_MODE_VISIBLE
		else:
			Input.mouse_mode = Input.MOUSE_MODE_CAPTURED

	elif event.is_action_pressed(&"primary"):
		var o : Object = ray_cast_3d.get_collider()
		if o is CollectionableNode:
			AudioTape.collect(o)
	elif event.is_action_pressed(&"ui_accept"):
		AudioTape.clear()
		for x : Node in items.get_children():
			x.enable()
