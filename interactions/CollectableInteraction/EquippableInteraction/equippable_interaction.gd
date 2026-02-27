class_name EquippableInteraction
extends CollectableInteraction

"""
ConsumableInteraction handles objects that the player can pick up in the world.
...
"""

signal item_collected(item: Node)

func _ready() -> void:
	super()
	if not collect_sound_effect:
		collect_sound_effect = load("res://assets/sound_effects/handleCoins2.ogg")
	_collect_mesh_and_collision_nodes()

func pre_interact() -> void:
	super()

func interact() -> void:
	super()
	if not can_interact:
		return
	item_collected.emit(get_parent())
	can_interact = false

func aux_interact() -> void:
	super()

func post_interact() -> void:
	super()
