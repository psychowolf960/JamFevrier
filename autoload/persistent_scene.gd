extends Control

@export var _persistent_foreground_scene : PackedScene = preload("res://scenes/persistent_foreground_scene.tscn")

var _foreground_canvas : CanvasLayer
var _foreground_scene : Control
var _transition_effect : ColorRect
var _transition_tween : Tween

func _ready():
	get_tree().scene_changed.connect(_scene_changed_callback)
	_foreground_canvas = CanvasLayer.new()
	_foreground_canvas.layer = 1000
	add_child(_foreground_canvas)
	_foreground_scene = _persistent_foreground_scene.instantiate()
	_foreground_canvas.add_child(_foreground_scene)
	_transition_effect = _foreground_scene.get_node_or_null("%TransitionEffect")
	if _transition_effect:
		_transition_effect.set_visible(false)

var _transition_effect_parameter_call = func(value : float):
	_transition_effect.material.set_shader_parameter(
		"progress",
		value
	)
	_transition_effect.material.set_shader_parameter(
		"background_threshold",
		abs(1.0 - value*2.0) - 0.5
	)
	_transition_effect.material.set_shader_parameter(
		"color_threshold",
		min(1.0,abs(-4.0+value*8.0)) * 0.48
	)

func change_scene(scene_path : String):
	if _transition_effect == null:
		push_warning("Transition effect not found.")
		get_tree().change_scene_to_file(scene_path)
		return

	if _transition_tween != null:
		_transition_tween.kill()
		_transition_tween = null

	_transition_effect.material.set_shader_parameter("seed", randf())
	_transition_effect.set_visible(true)
	_transition_tween = create_tween()
	_transition_tween.tween_method(_transition_effect_parameter_call, 0.0, 0.5, 0.5)
	_transition_tween.tween_callback(get_tree().change_scene_to_file.bind(scene_path))

func _scene_changed_callback():
	if _transition_tween != null:
		_transition_tween.kill()
		_transition_tween = null

	_transition_tween = create_tween()
	_transition_tween.tween_method(_transition_effect_parameter_call, 0.5, 1.0, 0.5)
	_transition_tween.tween_callback(_transition_effect.set_visible.bind(false))
