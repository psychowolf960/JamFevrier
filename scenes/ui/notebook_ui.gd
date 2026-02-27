extends CanvasLayer

signal close_requested

@onready var _left_vbox: VBoxContainer = %LeftVBox
@onready var _right_vbox: VBoxContainer = %RightVBox
@onready var _page_label: Label = %PageLabel
@onready var _prev_btn: Button = %PrevButton
@onready var _next_btn: Button = %NextButton

var _current_spread: int = 0
var _disasters: Array[DisasterData] = []

func _ready() -> void:
	visible = false

func open() -> void:
	_disasters = DisasterManager.get_disasters()
	_current_spread = 0
	_populate_spread()
	visible = true

func close() -> void:
	visible = false

func _populate_spread() -> void:
	_clear_vbox(_left_vbox)
	_clear_vbox(_right_vbox)

	if _disasters.is_empty():
		_page_label.text = "- / -"
		_prev_btn.disabled = true
		_next_btn.disabled = true
		return

	var spread_count := ceili(_disasters.size() / 2.0)
	_page_label.text = "%d / %d" % [_current_spread + 1, spread_count]
	_prev_btn.disabled = _current_spread <= 0
	_next_btn.disabled = _current_spread >= spread_count - 1

	var left_idx := _current_spread * 2
	var right_idx := left_idx + 1

	if left_idx < _disasters.size():
		_fill_page(_left_vbox, _disasters[left_idx])

	if right_idx < _disasters.size():
		_fill_page(_right_vbox, _disasters[right_idx])

func _fill_page(vbox: VBoxContainer, disaster: DisasterData) -> void:
	var encountered := NotebookManager.has_encountered(disaster.disaster_id)

	var name_lbl := Label.new()
	name_lbl.text = disaster.disaster_name if encountered else "???"
	name_lbl.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	vbox.add_child(name_lbl)

	vbox.add_child(HSeparator.new())

	if not encountered:
		var locked_lbl := Label.new()
		locked_lbl.text = "Unknown catastrophe.\nEncounter it to unlock."
		locked_lbl.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
		locked_lbl.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
		vbox.add_child(locked_lbl)
		return

	if not disaster.signs.is_empty():
		var signs_title := Label.new()
		signs_title.text = "Signs:"
		vbox.add_child(signs_title)

		for sign in disaster.signs:
			var sign_lbl := Label.new()
			sign_lbl.text = "- " + sign
			sign_lbl.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
			vbox.add_child(sign_lbl)

		vbox.add_child(HSeparator.new())

	var sol_title := Label.new()
	sol_title.text = "Solutions:"
	vbox.add_child(sol_title)

	for solution in disaster.solutions:
		var cb := CheckBox.new()
		cb.text = solution
		vbox.add_child(cb)

func _clear_vbox(vbox: VBoxContainer) -> void:
	for child in vbox.get_children():
		child.queue_free()

func _on_prev_pressed() -> void:
	if _current_spread > 0:
		_current_spread -= 1
		_populate_spread()

func _on_next_pressed() -> void:
	var spread_count := ceili(_disasters.size() / 2.0)
	if _current_spread < spread_count - 1:
		_current_spread += 1
		_populate_spread()

func _on_close_pressed() -> void:
	close_requested.emit()
