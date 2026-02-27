class_name ConsumableInteraction
extends CollectableInteraction

"""
ConsumableInteraction handles objects that the player can pick up in the world.
It extends AbstractInteraction to reuse common interaction logic while adding
pickup-specific behavior like sound effects when the item is picked up, emitting
an `item_collected` signal to notify inventory systems, preventing further interaction
while the item is being collected, and removing the item from the scene once the
collection is complete

This class is suitable for any item the player can grab and add to their inventory
or trigger collection events.
"""

signal item_collected(item: Node)

func _ready() -> void:
	super()
	collect_sound_effect = load("res://assets/sound_effects/handleCoins2.ogg")

func pre_interact() -> void:
	super()

func interact() -> void:
	super()

	if not can_interact:
		return

	emit_signal("item_collected", get_parent())

func aux_interact() -> void:
	super()

func post_interact() -> void:
	super()
