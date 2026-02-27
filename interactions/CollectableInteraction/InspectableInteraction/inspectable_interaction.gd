class_name InspectableInteraction
extends CollectableInteraction

"""
InspectableInteraction handles objects that the player can pick up and examine, such as notes or documents.
It extends AbstractInteraction to reuse common interaction logic while adding inspection-specific behavior
like playing a sound when the object is picked up for inspection put away after inspection, removing the
object's collision and adjusting its rendering layer to prevent clipping with walls, emitting a
`note_collected`  signal to notify the game that the object is being inspected, and preventing further
interaction while the object is being held by the player

This class is suitable for any inspectable object that the player can pick up to read, examine, or otherwise interact
with without immediately adding it to their inventory.
"""

@export var content: String

@export var put_away_sound_effect: AudioStreamOggVorbis = preload("res://assets/sound_effects/drawKnife3.ogg")

signal note_inspected(note: Node3D)

func _ready() -> void:
	super()
	collect_sound_effect = load("res://assets/sound_effects/drawKnife2.ogg")

	content = content.replace("\\n", "\n")

	_collect_mesh_and_collision_nodes()

func pre_interact() -> void:
	super()

func interact() -> void:
	super()

	if not can_interact:
		return

	note_inspected.emit(get_parent())

	can_interact = false

func aux_interact() -> void:
	super()

func post_interact() -> void:
	super()
