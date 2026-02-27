extends Control
class_name InventoryController

@onready var player_camera: Camera3D = $"../../../Head/Eyes/Camera3D"
@onready var interaction_controller: Node = $"../../../InteractionController"
@onready var hotbar_container: HBoxContainer = %HotbarContainer

const SLOT_COUNT: int = 5

var inventory_slot_prefab: PackedScene = load("res://inventory/inventory_slot.tscn")
var swap_slot_player: AudioStreamPlayer
var swap_slot_sound_effect: AudioStreamOggVorbis = load("res://assets/sound_effects/menu_swap.ogg")

var inventory_slots: Array[InventorySlot] = []
var selected_slot: int = 0
var inventory_full: bool = false

func _ready() -> void:
	swap_slot_player = AudioStreamPlayer.new()
	swap_slot_player.volume_db = -12.0
	swap_slot_player.stream = swap_slot_sound_effect
	add_child(swap_slot_player)

	for i: int in SLOT_COUNT:
		var slot: InventorySlot = inventory_slot_prefab.instantiate()
		hotbar_container.add_child(slot)
		slot.inventory_slot_id = i
		slot.on_item_double_clicked.connect(_on_item_double_clicked)
		slot.on_item_right_clicked.connect(_on_slot_right_click)
		inventory_slots.append(slot)

	_update_selection()

func _input(event: InputEvent) -> void:
	if event is InputEventMouseButton and event.pressed:
		if event.button_index == MOUSE_BUTTON_WHEEL_UP:
			_select_slot((selected_slot - 1 + SLOT_COUNT) % SLOT_COUNT)
		elif event.button_index == MOUSE_BUTTON_WHEEL_DOWN:
			_select_slot((selected_slot + 1) % SLOT_COUNT)

	if event is InputEventKey and event.pressed and not event.echo:
		match event.keycode:
			KEY_1: _select_slot(0)
			KEY_2: _select_slot(1)
			KEY_3: _select_slot(2)
			KEY_4: _select_slot(3)
			KEY_5: _select_slot(4)

func _select_slot(index: int) -> void:
	selected_slot = index
	_update_selection()
	equip_selected()

func _update_selection() -> void:
	for i: int in SLOT_COUNT:
		inventory_slots[i].set_selected(i == selected_slot)

func has_free_slot() -> bool:
	for slot in inventory_slots:
		if slot.slot_data == null:
			return true
	return false

func pickup_item(item_data: ItemData) -> void:
	for slot in inventory_slots:
		if not slot.slot_filled:
			slot.fill_slot(item_data)
			inventory_full = not has_free_slot()
			swap_slot_player.play()
			return
	inventory_full = true

func equip_selected() -> void:
	var slot: InventorySlot = inventory_slots[selected_slot]
	if slot.slot_data == null:
		return
	match _get_item_action_type(slot.slot_data):
		ActionData.ActionType.EQUIPPABLE:
			equip_collectable(selected_slot)
		ActionData.ActionType.CONSUMABLE:
			use_collectable(selected_slot)
		ActionData.ActionType.INSPECTABLE:
			view_inspectable(selected_slot)

func _on_item_double_clicked(slot_id: int) -> void:
	var slot: InventorySlot = inventory_slots[slot_id]
	if slot.slot_data == null:
		return
	match _get_item_action_type(slot.slot_data):
		ActionData.ActionType.CONSUMABLE:
			use_collectable(slot_id)
		ActionData.ActionType.EQUIPPABLE:
			equip_collectable(slot_id)
		ActionData.ActionType.INSPECTABLE:
			view_inspectable(slot_id)

func _on_slot_right_click(slot_id: int) -> void:
	drop_collectable(slot_id)

func use_collectable(slot_id: int) -> void:
	var slot: InventorySlot = inventory_slots[slot_id]
	if slot.slot_data == null:
		return
	slot.fill_slot(null)
	inventory_full = false

func drop_collectable(slot_id: int) -> void:
	var slot: InventorySlot = inventory_slots[slot_id]
	var item_data: ItemData = slot.slot_data
	if item_data == null:
		return

	var instance: PhysicsBody3D = item_data.item_model_prefab.instantiate() as PhysicsBody3D
	get_tree().current_scene.add_child(instance)

	var space_state: PhysicsDirectSpaceState3D = player_camera.get_world_3d().direct_space_state
	var forward_dir: Vector3 = -player_camera.global_transform.basis.z.normalized()
	var target_pos: Vector3 = player_camera.global_transform.origin + forward_dir * 2.0

	var obstacle_params := PhysicsRayQueryParameters3D.new()
	obstacle_params.from = player_camera.global_transform.origin
	obstacle_params.to = target_pos
	obstacle_params.exclude = [player_camera]
	if not space_state.intersect_ray(obstacle_params).is_empty():
		interaction_controller.interact_failure_player.play()
		instance.queue_free()
		return

	var ground_params := PhysicsRayQueryParameters3D.new()
	ground_params.from = target_pos + Vector3.UP * 2.0
	ground_params.to = target_pos - Vector3.UP * 5.0
	ground_params.exclude = [player_camera]
	var ground_hit: Dictionary = space_state.intersect_ray(ground_params)
	if not ground_hit:
		instance.queue_free()
		return

	if instance is RigidBody3D:
		instance.global_transform.origin = ground_hit.position + Vector3.UP * 0.7
		instance.freeze = false
		instance.gravity_scale = 1.0
		instance.rotation_degrees.x = randf() * 360.0
		instance.rotation_degrees.z = randf() * 360.0
	else:
		instance.global_transform.origin = ground_hit.position + Vector3.UP * 0.0001
	instance.rotation_degrees.y = randf() * 360.0

	swap_slot_player.play()
	slot.fill_slot(null)
	inventory_full = false

func equip_collectable(slot_id: int) -> void:
	if interaction_controller.item_equipped:
		return
	var slot: InventorySlot = inventory_slots[slot_id]
	var item_data: ItemData = slot.slot_data
	if item_data == null:
		return
	var instance: PhysicsBody3D = item_data.item_model_prefab.instantiate() as PhysicsBody3D
	interaction_controller.on_item_equipped(instance)
	slot.fill_slot(null)
	inventory_full = false

func view_inspectable(slot_id: int) -> void:
	var slot: InventorySlot = inventory_slots[slot_id]
	var item_data: ItemData = slot.slot_data
	if item_data == null:
		return
	var instance: PhysicsBody3D = item_data.item_model_prefab.instantiate() as PhysicsBody3D
	interaction_controller.on_note_inspected(instance)
	slot.fill_slot(null)
	inventory_full = false

func _get_item_action_type(item_data: ItemData) -> ActionData.ActionType:
	if not item_data or not item_data.item_model_prefab:
		return ActionData.ActionType.INVALID
	return item_data.action_data.action_type
