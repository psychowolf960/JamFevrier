class_name AbstractInteraction
extends Node

"""
AbstractInteraction is the base class for all interactable objects in the game.
It defines the common interface (preInteract, interact, auxInteract, postInteract)
and shared state (can_interact, is_interacting, lock_camera, nodes_to_affect).
Concrete interaction types (e.g. doors, switches, notes, keypads) should extend
this class and implement their own interaction-specific behavior while reusing
the common logic provided here.
"""

@export var nodes_to_affect: Array[Node]

var object_ref: Node3D

var can_interact: bool = true

var is_interacting: bool = false

var lock_camera: bool = false

func _ready() -> void:
	object_ref = get_parent()

func pre_interact() -> void:
	is_interacting = true

func interact() -> void: return

func aux_interact() -> void: return

func post_interact() -> void:
	is_interacting = false
	lock_camera = false
	Input.mouse_mode = Input.MOUSE_MODE_CAPTURED

func notify_nodes(percentage: float) -> void:
	for node in nodes_to_affect:
		if node and node.has_method("execute"):
			node.call("execute", percentage)

func use_item(_item_data: ItemData) -> bool:
	return false
