extends CanvasLayer

signal minigame_completed
signal minigame_cancelled

@export var has_money: bool = false

@export var browser_texture_no_money: Texture2D
@export var browser_texture_money: Texture2D

@onready var _desktop: TextureRect = $Desktop
@onready var _browser: TextureRect = $Browser
@onready var _browser_button: Button = $Desktop/BrowserButton
@onready var _buy_button: Button = $Browser/BuyButton
@onready var _close_button: Button = $Browser/CloseButton

func _ready() -> void:
	_browser.visible = false
	_buy_button.visible = has_money
	if has_money:
		_browser.texture = browser_texture_money
	else:
		_browser.texture = browser_texture_no_money
	_browser_button.pressed.connect(_on_browser_button_pressed)
	_buy_button.pressed.connect(_on_buy_button_pressed)
	_close_button.pressed.connect(_on_browser_button_pressed)

func _on_browser_button_pressed() -> void:
	_browser.visible = not _browser.visible

func _on_buy_button_pressed() -> void:
	minigame_completed.emit()

func _input(event: InputEvent) -> void:
	if event.is_action_pressed("ui_cancel"):
		minigame_cancelled.emit()
