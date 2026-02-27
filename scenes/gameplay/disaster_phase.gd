extends Node

@onready var _disaster_label: Label = %DisasterLabel
@onready var _solutions_label: Label = %SolutionsLabel

func _ready() -> void:
	Input.set_mouse_mode(Input.MOUSE_MODE_VISIBLE)

	var disaster: DisasterData = GameManager.current_disaster
	if disaster == null:
		_disaster_label.text = "CATASTROPHE INCONNUE"
		return

	_disaster_label.text = disaster.disaster_name

	var txt: String = ""
	for solution: String in disaster.solutions:
		txt += "• " + solution + "\n"
		_solutions_label.text = txt

	GameManager.game_won.connect(func() -> void:
		PersistentScene.change_scene("res://scenes/gameplay/win.tscn")
	)
	GameManager.game_lost.connect(func() -> void:
		PersistentScene.change_scene("res://scenes/gameplay/lose.tscn")
	)

func _on_win_pressed() -> void:
	GameManager.resolve_disaster(true)

func _on_lose_pressed() -> void:
	GameManager.resolve_disaster(false)
