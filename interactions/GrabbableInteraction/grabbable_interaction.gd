class_name GrabbableInteraction
extends AbstractInteraction

"""
GrabbableInteraction handles objects that the player can pick up, carry, and throw.
It extends AbstractInteraction to reuse common interaction logic while adding
pickup-specific behavior such as following the player’s hand, applying physics-based
movement, and playing collision sound effects when the object hits other surfaces.

This class is suitable for any interactable object that should respond to grab-and-throw
mechanics in the game world.
"""

@export var collision_sound_effect: AudioStreamOggVorbis = preload("res://assets/sound_effects/impactPlank_medium_003.ogg")
var collision_audio_player: AudioStreamPlayer3D

var player_hand: Marker3D

var last_velocity: Vector3 = Vector3.ZERO

var contact_velocity_threshold: float = 1.0

func _ready() -> void:
	super()
	collision_audio_player = AudioStreamPlayer3D.new()
	collision_audio_player.stream = collision_sound_effect
	add_child(collision_audio_player)

	object_ref.connect("body_entered", Callable(self, "_fire_collision"))
	object_ref.contact_monitor = true
	object_ref.max_contacts_reported = 1

func pre_interact() -> void:
	super()

func interact() -> void:
	super()

	if not can_interact:
		return

	var rigid_body_3d: RigidBody3D = object_ref as RigidBody3D
	if rigid_body_3d:
		rigid_body_3d.set_linear_velocity((_calculate_object_distance())*(5/rigid_body_3d.mass))

func aux_interact() -> void:
	super()

	if not can_interact:
		return

	var rigid_body_3d: RigidBody3D = object_ref as RigidBody3D
	if rigid_body_3d:
		var throw_direction: Vector3 = -player_hand.global_transform.basis.z.normalized()
		var throw_strength: float = (20.0/rigid_body_3d.mass)
		rigid_body_3d.set_linear_velocity(throw_direction*throw_strength)

		can_interact = false
		await get_tree().create_timer(0.5).timeout
		can_interact = true

func _physics_process(_delta: float) -> void:
	last_velocity = object_ref.linear_velocity

func post_interact() -> void:
	super()

func set_player_hand_position(hand: Marker3D) -> void:
	player_hand = hand

func _fire_collision(_node: Node) -> void:
	var impact_strength = (last_velocity - object_ref.linear_velocity).length()
	if impact_strength > contact_velocity_threshold:
		_play_collision_sound_effect()

func _play_collision_sound_effect() -> void:
	collision_audio_player.play()
	await collision_audio_player.finished

func _calculate_object_distance() -> Vector3:
	return (player_hand.global_transform.origin)-(object_ref.global_transform.origin)
