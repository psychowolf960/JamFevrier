extends CanvasLayer

@onready var _main_panel: VBoxContainer = $Control/MainPanel
@onready var _credits_panel: Control = $Control/CreditsPanel
@onready var _larry: TextureRect = $Control/Larry
@onready var _disaster_popup: TextureRect = $Control/DisasterPopup

var _larry_normal: Texture2D = preload("res://assets/textures/larry.png")
var _larry_menacing: Texture2D = preload("res://assets/textures/larry_menacing.png")

const _DISASTER_PATHS: Array[String] = [
	"res://assets/textures/godzilla_button.png",
	"res://assets/textures/tornado_button.png",
	"res://assets/textures/alien_button.png",
	"res://assets/textures/infestation_button.png",
]
var _disaster_textures: Array[Texture2D] = []

var _idle_tween: Tween
var _popup_tween: Tween
var _larry_base_y: float

func _ready() -> void:
	for path in _DISASTER_PATHS:
		var tex := load(path) as Texture2D
		if tex:
			_disaster_textures.append(tex)

	%PlayButton.pressed.connect(_on_play_pressed)
	%CreditsButton.pressed.connect(_on_credits_pressed)
	%QuitButton.pressed.connect(_on_quit_pressed)
	%BackButton.pressed.connect(_on_back_pressed)

	%PlayButton.mouse_entered.connect(_on_regular_hover)
	%PlayButton.mouse_exited.connect(_on_hover_exit)
	%CreditsButton.mouse_entered.connect(_on_regular_hover)
	%CreditsButton.mouse_exited.connect(_on_hover_exit)
	%QuitButton.mouse_entered.connect(_on_quit_hover)
	%QuitButton.mouse_exited.connect(_on_hover_exit)

	_disaster_popup.pivot_offset = _disaster_popup.size / 2.0
	_larry_base_y = _larry.position.y
	_start_idle()

func _start_idle() -> void:
	if _idle_tween:
		_idle_tween.kill()
	_idle_tween = create_tween().set_loops()
	_idle_tween.tween_property(_larry, "position:y", _larry_base_y - 16.0, 1.0) \
		.set_ease(Tween.EASE_IN_OUT).set_trans(Tween.TRANS_SINE)
	_idle_tween.tween_property(_larry, "position:y", _larry_base_y, 1.0) \
		.set_ease(Tween.EASE_IN_OUT).set_trans(Tween.TRANS_SINE)

func _on_regular_hover() -> void:
	_larry.texture = _larry_normal
	_show_random_disaster()

func _on_quit_hover() -> void:
	_larry.texture = _larry_menacing
	_hide_disaster()

func _on_hover_exit() -> void:
	_larry.texture = _larry_normal
	_hide_disaster()

func _show_random_disaster() -> void:
	if _disaster_textures.is_empty():
		return
	_disaster_popup.texture = _disaster_textures[randi() % _disaster_textures.size()]
	_disaster_popup.show()
	_disaster_popup.scale = Vector2.ZERO
	if _popup_tween:
		_popup_tween.kill()
	_popup_tween = create_tween()
	_popup_tween.tween_property(_disaster_popup, "scale", Vector2.ONE, 0.28) \
		.set_ease(Tween.EASE_OUT).set_trans(Tween.TRANS_BACK)

func _hide_disaster() -> void:
	if _popup_tween:
		_popup_tween.kill()
	_popup_tween = create_tween()
	_popup_tween.tween_property(_disaster_popup, "scale", Vector2.ZERO, 0.15) \
		.set_ease(Tween.EASE_IN).set_trans(Tween.TRANS_BACK)
	_popup_tween.tween_callback(_disaster_popup.hide)

func _on_play_pressed() -> void:
	GameManager.reset()
	TaskManager.reset()
	PersistentScene.change_scene("res://scenes/main/main.tscn")

func _on_credits_pressed() -> void:
	_main_panel.hide()
	_larry.hide()
	_disaster_popup.hide()
	_credits_panel.show()

func _on_quit_pressed() -> void:
	get_tree().quit()

func _on_back_pressed() -> void:
	_credits_panel.hide()
	_main_panel.show()
	_larry.show()
