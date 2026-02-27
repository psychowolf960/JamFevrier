extends Node

@onready var interaction_controller: Node = %InteractionController
@onready var interaction_raycast: RayCast3D = %InteractionRaycast
@onready var player_camera: Camera3D = %Camera3D
@onready var hand: Marker3D = %Hand
@onready var note_hand: Marker3D = %NoteHand
@onready var item_hand: Marker3D = %ItemHand
@onready var interactable_check: Area3D = $"../InteractableCheck"
@onready var note_overlay: Control = %NoteOverlay
@onready var note_content: RichTextLabel = %NoteContent
@onready var inventory_controller: InventoryController = %InventoryController/CanvasLayer/InventoryUI
@onready var interaction_textbox: Label = %InteractionTextbox
@onready var outline_material: Material = preload("res://materials/item_highlighter.tres")

@onready var default_reticle: TextureRect = %DefaultReticle
@onready var highlight_reticle: TextureRect = %HighlightReticle
@onready var interacting_reticle: TextureRect = %InteractingReticle
@onready var use_reticle: TextureRect = %UseReticle
enum Reticle {
	DEFAULT,
	HIGHLIGHT,
	INTERACTING,
	USE_ITEM
}

signal invent_on_item_collected(item)

var item_equipped: bool = false
var equipped_item: Node3D
var equipped_item_interaction_component: AbstractInteraction

var current_object: Object
var potential_interaction_component: AbstractInteraction
var potential_object: Object
var interaction_component: AbstractInteraction

var current_note: StaticBody3D
var note_interaction_component: InspectableInteraction
var is_note_overlay_display: bool = false

var interact_failure_player: AudioStreamPlayer
var interact_failure_sound_effect: AudioStreamWAV = load("res://assets/sound_effects/key_use_failure.wav")
var interact_success_player: AudioStreamPlayer
var interact_success_sound_effect: AudioStreamOggVorbis = load("res://assets/sound_effects/key_use_success.ogg")
var equip_item_player: AudioStreamPlayer
var equip_item_sound_effect: AudioStreamOggVorbis = load("res://assets/sound_effects/key_equip.ogg")

func _ready() -> void:
	interactable_check.body_entered.connect(_collectable_item_entered_range)
	interactable_check.body_exited.connect(_collectable_item_exited_range)
	invent_on_item_collected.connect(inventory_controller.pickup_item)

	interact_failure_player = AudioStreamPlayer.new()
	interact_failure_player.volume_db = -25.0
	interact_failure_player.stream = interact_failure_sound_effect
	add_child(interact_failure_player)
	interact_success_player = AudioStreamPlayer.new()
	interact_success_player.volume_db = -10.0
	interact_success_player.stream = interact_success_sound_effect
	add_child(interact_success_player)
	equip_item_player = AudioStreamPlayer.new()
	equip_item_player.volume_db = -20.0
	equip_item_player.stream = equip_item_sound_effect
	add_child(equip_item_player)

func _process(_delta: float) -> void:
	if item_equipped:
		return

	if current_object:
		if interaction_component:
			if interaction_component.is_interacting:
				_update_reticle_state()

			if player_camera.global_transform.origin.distance_to(interaction_raycast.get_collision_point()) > 5.0:
				interaction_component.post_interact()
				current_object = null
				_unfocus()
				return

			if Input.is_action_just_pressed("secondary"):
				interaction_component.aux_interact()
				current_object = null
				_unfocus()
			elif Input.is_action_pressed("primary"):
				if not interaction_component is CollectableInteraction or not inventory_controller.inventory_full:
					interaction_component.interact()
				else:
					if not interact_failure_player.playing:
						_show_interaction_text("Hotbar Full...", 1.0)
						interact_failure_player.play()
			else:
				interaction_component.post_interact()
				current_object = null
				_unfocus()
		else:
			current_object = null
			_unfocus()
	else:
		potential_object = interaction_raycast.get_collider()

		if potential_object and potential_object is Node:
			potential_interaction_component = find_interaction_component(potential_object)
			if potential_interaction_component:
				if potential_interaction_component.can_interact == false:
					return

				_focus()
				if Input.is_action_just_pressed("primary"):
					interaction_component = potential_interaction_component
					current_object = potential_object

					if interaction_component is TypeableInteraction:
						interaction_component.set_target_button(current_object)

					interaction_component.pre_interact()

					if interaction_component is GrabbableInteraction:
						interaction_component.set_player_hand_position(hand)

					if interaction_component is ConsumableInteraction or interaction_component is EquippableInteraction:
						if not interaction_component.is_connected("item_collected", Callable(self, "_on_item_collected")):
							interaction_component.connect("item_collected", Callable(self, "_on_item_collected"))

					if interaction_component is InspectableInteraction:
						if not interaction_component.is_connected("note_inspected", Callable(self, "on_note_inspected")):
							interaction_component.connect("note_inspected", Callable(self, "on_note_inspected"))

					if interaction_component is DoorInteraction:
						interaction_component.set_direction(current_object.to_local(interaction_raycast.get_collision_point()))

			else:
				current_object = null
				_unfocus()
		else:
			_unfocus()

func _input(event: InputEvent) -> void:
	if is_note_overlay_display and event.is_action_pressed("primary"):
		_on_note_collected()

	if item_equipped and Input.is_action_just_pressed("primary"):
		_use_equipped_item()

func isCameraLocked() -> bool:
	if interaction_component:
		if interaction_component.lock_camera and interaction_component.is_interacting:
			return true
	return false

func _focus() -> void:
	_update_reticle_state()

func _unfocus() -> void:
	_update_reticle_state()

func on_note_inspected(note: Node3D) -> void:
	if current_note != null:
		_on_note_collected()
	current_note = note
	note_interaction_component = find_interaction_component(current_note) as InspectableInteraction
	_play_sound_effect(note_interaction_component.collect_sound_effect)
	if current_note.get_parent() != null:
		current_note.get_parent().remove_child(current_note)
	note_hand.add_child(current_note)
	_change_mesh_layer(note_interaction_component.meshes, 2)
	_remove_collision_shapes(note_interaction_component.collision_shapes)
	current_note.transform.origin = note_hand.transform.origin
	current_note.position = Vector3(0.0, 0.0, 0.0)
	current_note.rotation_degrees = Vector3(90, 10, 0)
	note_overlay.visible = true
	is_note_overlay_display = true
	note_content.bbcode_enabled = true
	note_content.text = note_interaction_component.content

func _on_note_collected() -> void:
	note_overlay.visible = false
	is_note_overlay_display = false
	_add_item_to_inventory(note_interaction_component.item_data)
	_play_sound_effect(note_interaction_component.put_away_sound_effect)
	current_note.queue_free()
	current_note = null
	note_interaction_component = null

func _on_item_collected(item: Node3D) -> void:
	var ic: CollectableInteraction = find_interaction_component(item)
	if not ic:
		return
	_add_item_to_inventory(ic.item_data)
	_play_sound_effect(ic.collect_sound_effect)
	item.queue_free()

func on_item_equipped(item: Node3D) -> void:
	equipped_item = item
	item_equipped = true
	equipped_item_interaction_component = find_interaction_component(equipped_item)
	if item is RigidBody3D:
		item.freeze = true
		item.linear_velocity = Vector3.ZERO
		item.angular_velocity = Vector3.ZERO
		item.gravity_scale = 0.0
	if item.get_parent() != null:
		item.get_parent().remove_child(item)
	item_hand.add_child(item)
	_change_mesh_layer(equipped_item_interaction_component.meshes, 2)
	_remove_collision_shapes(equipped_item_interaction_component.collision_shapes)
	item.transform.origin = item_hand.transform.origin
	item.position = Vector3(0.0, 0.0, 0.0)
	item.rotation_degrees = Vector3(0, 180, -90)
	equip_item_player.play()

func _use_equipped_item() -> void:
	var target_object: Object = interaction_raycast.get_collider()
	if target_object and target_object is Node:
		var target_component: AbstractInteraction = find_interaction_component(target_object as Node)
		if target_component != null and target_component.has_method("use_item") \
				and target_component.use_item(equipped_item_interaction_component.item_data):
			var action: EquippableAction = equipped_item_interaction_component.item_data.action_data as EquippableAction
			if action and action.use_sound:
				_play_sound_effect(action.use_sound)
			else:
				interact_success_player.play()
			_show_interaction_text(action.success_text if action else "Done!", 1.0)
			if action and action.one_time_use:
				equipped_item.queue_free()
				equipped_item = null
				item_equipped = false
			return

	_show_interaction_text("Nothing interesting happens...", 1.0)
	interact_failure_player.play()
	inventory_controller.pickup_item(equipped_item_interaction_component.item_data)
	equipped_item.queue_free()
	equipped_item = null
	item_equipped = false
	current_object = null
	potential_interaction_component = null

func _add_item_to_inventory(item_data: ItemData) -> void:
	if item_data != null:
		invent_on_item_collected.emit(item_data)
		return
	print("Item not found")

func _collectable_item_entered_range(body: Node3D) -> void:
	if body.name != "Player":
		var ic: AbstractInteraction = find_interaction_component(body)
		if ic and ic is ConsumableInteraction or ic is EquippableInteraction:
			var mesh: MeshInstance3D = body.find_child("MeshInstance3D", true, false)
			if mesh:
				mesh.material_overlay = outline_material

func _collectable_item_exited_range(body: Node3D) -> void:
	if body.name != "Player":
		var ic: AbstractInteraction = find_interaction_component(body)
		if ic and ic is ConsumableInteraction or ic is EquippableInteraction:
			var mesh: MeshInstance3D = body.find_child("MeshInstance3D", true, false)
			if mesh:
				mesh.material_overlay = null

func find_interaction_component(node: Node) -> AbstractInteraction:
	while node:
		for child in node.get_children():
			if child is AbstractInteraction:
				return child
		node = node.get_parent()
	return null

func _show_interaction_text(text: String, duration: float) -> void:
	interaction_textbox.text = text
	interaction_textbox.visible = true
	await get_tree().create_timer(duration).timeout
	interaction_textbox.visible = false

func _play_sound_effect(sound_effect: AudioStream) -> void:
	if not sound_effect:
		return
	var audio_player := AudioStreamPlayer.new()
	add_child(audio_player)
	audio_player.stream = sound_effect
	audio_player.finished.connect(audio_player.queue_free)
	audio_player.play()

func _change_mesh_layer(meshes: Array[MeshInstance3D], layer: int) -> void:
	for mesh in meshes:
		mesh.layers = layer

func _remove_collision_shapes(collision_shapes: Array[CollisionShape3D]) -> void:
	for collision_shape in collision_shapes:
		collision_shape.queue_free()

func _update_reticle_state() -> void:
	default_reticle.visible = false
	highlight_reticle.visible = false
	interacting_reticle.visible = false
	use_reticle.visible = false

	if item_equipped:
		use_reticle.visible = true
		return

	if current_object and interaction_component:
		if interaction_component.is_interacting:
			interacting_reticle.visible = true
			return
		elif interaction_component.can_interact:
			highlight_reticle.visible = true
			return
		else:
			default_reticle.visible = true
			return

	if potential_object:
		if potential_interaction_component and potential_interaction_component.can_interact:
			highlight_reticle.visible = true
			return

	default_reticle.visible = true
