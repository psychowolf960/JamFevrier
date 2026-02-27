class_name CollectableInteraction
extends AbstractInteraction

"""
CollectableInteraction is a base interaction component meant for objects
that can be picked up and stored in the player's inventory.

This includes items like notes, consumables, keys, or any other
pickupable object in the world.

It provides a place to store relevant action data (e.g., type,
one-time use, modifiers) and can be attached to the item prefab
to define how the inventory should handle it when collected.
"""

@export var collect_sound_effect: AudioStream

@export var item_data: ItemData

var meshes: Array[MeshInstance3D] = []
var collision_shapes: Array[CollisionShape3D] = []

func _ready() -> void:
	super()

	var scene_path: String = get_parent().scene_file_path
	item_data.item_model_prefab = load(scene_path)

func pre_interact() -> void:
	super()

func interact() -> void:
	super()

func aux_interact() -> void:
	super()

func post_interact() -> void:
	super()

func _collect_mesh_and_collision_nodes() -> void:
	meshes = get_mesh_instance_children_recursive(get_parent())

	collision_shapes = get_collision_shape_children_recursive(get_parent())

func get_mesh_instance_children_recursive(parent: Node) -> Array:
	var result: Array[MeshInstance3D] = []

	if parent is MeshInstance3D:
		result.append(parent)

	for child in parent.get_children():
		result += get_mesh_instance_children_recursive(child)

	return result

func get_collision_shape_children_recursive(parent: Node) -> Array:
	var result: Array[CollisionShape3D] = []

	if parent is CollisionShape3D:
		result.append(parent)

	for child in parent.get_children():
		result += get_collision_shape_children_recursive(child)

	return result
