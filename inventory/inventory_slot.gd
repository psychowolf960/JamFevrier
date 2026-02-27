extends Control
class_name InventorySlot

@onready var icon_slot: TextureRect = %TextureRect

var inventory_slot_id: int = -1
var slot_filled: bool = false
var slot_data: ItemData = null

var _style_normal: StyleBoxFlat
var _style_selected: StyleBoxFlat

signal on_item_swapped(from_slot_id: int, to_slot_id: int)
signal on_item_double_clicked(slot_id: int)
signal on_item_right_clicked(slot_id: int)

func _ready() -> void:
	_style_normal = StyleBoxFlat.new()
	_style_normal.bg_color = Color(0.04, 0.05, 0.07, 0.6)
	_style_normal.border_width_left = 2
	_style_normal.border_width_top = 2
	_style_normal.border_width_right = 2
	_style_normal.border_width_bottom = 2
	_style_normal.border_color = Color(0.5, 0.5, 0.5, 0.5)
	_style_normal.corner_radius_top_left = 3
	_style_normal.corner_radius_top_right = 3
	_style_normal.corner_radius_bottom_right = 3
	_style_normal.corner_radius_bottom_left = 3

	_style_selected = StyleBoxFlat.new()
	_style_selected.bg_color = Color(0.08, 0.08, 0.04, 0.85)
	_style_selected.border_width_left = 3
	_style_selected.border_width_top = 3
	_style_selected.border_width_right = 3
	_style_selected.border_width_bottom = 3
	_style_selected.border_color = Color(1.0, 0.85, 0.1, 1.0)
	_style_selected.corner_radius_top_left = 3
	_style_selected.corner_radius_top_right = 3
	_style_selected.corner_radius_bottom_right = 3
	_style_selected.corner_radius_bottom_left = 3
	_style_selected.expand_margin_left = 2.0
	_style_selected.expand_margin_top = 2.0
	_style_selected.expand_margin_right = 2.0
	_style_selected.expand_margin_bottom = 2.0

	set_selected(false)

func set_selected(is_selected: bool) -> void:
	add_theme_stylebox_override("normal", _style_selected if is_selected else _style_normal)

func fill_slot(item_data: ItemData) -> void:
	slot_data = item_data
	if (slot_data != null):
		slot_filled = true
		icon_slot.texture = item_data.item_icon
	else:
		slot_filled = false
		icon_slot.texture = null

func _get_drag_data(_at_position: Vector2) -> Variant:
	if (slot_filled):
		var preview: TextureRect = TextureRect.new()
		preview.expand_mode = TextureRect.EXPAND_IGNORE_SIZE
		preview.size = icon_slot.size
		preview.pivot_offset = icon_slot.size / 2.0
		preview.texture = icon_slot.texture
		set_drag_preview(preview)
		return inventory_slot_id
	else:
		return false

func _can_drop_data(_at_position: Vector2, data: Variant) -> bool:
	return typeof(data) == TYPE_INT

func _drop_data(_at_position: Vector2, data: Variant) -> void:
	on_item_swapped.emit(data as int, inventory_slot_id)

func _gui_input(event: InputEvent) -> void:
	if not slot_filled:
		return

	if event is InputEventMouseButton:
		if event.button_index == MOUSE_BUTTON_LEFT and event.double_click:
			on_item_double_clicked.emit(inventory_slot_id)
		elif event.button_index == MOUSE_BUTTON_RIGHT and event.pressed:
			on_item_right_clicked.emit(inventory_slot_id)
