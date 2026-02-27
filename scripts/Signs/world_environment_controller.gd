extends WorldEnvironment
class_name WorldEnvironmentController

@export var sun: DirectionalLight3D

@export_group("Mist")
@export var mist_clouds_cutoff: float = 0.05
@export var mist_clouds_weight: float = 0.55
@export var mist_horizon_color: Color = Color(0.72, 0.74, 0.76)
@export var mist_fog_density: float = 0.04

@export_group("Clear Sky")
@export var clear_clouds_cutoff: float = 0.3
@export var clear_clouds_weight: float = 0.0
@export var clear_horizon_color: Color = Color(0.0, 0.7, 0.8)

func _ready() -> void:
	GameManager.disaster_set.connect(_on_disaster_set)

func _on_disaster_set(disaster: DisasterData) -> void:
	GameManager.disaster_set.disconnect(_on_disaster_set)
	_apply_environment(disaster)

func _apply_environment(disaster: DisasterData) -> void:
	if environment == null:
		push_warning("WorldEnvironmentController: no Environment resource assigned.")
		return

	environment.background_mode = Environment.BG_SKY

	if sun != null:
		if DisasterAware.sign_enabled("night"):
			sun.light_energy = 0.15
			sun.rotation_degrees.x = -150.0
		else:
			sun.light_energy = 1.0
			sun.rotation_degrees.x = -45.0
	else:
		push_warning("WorldEnvironmentController: no sun assigned.")

	var has_mist: bool = DisasterAware.sign_enabled("mist")
	environment.fog_enabled = has_mist
	if has_mist:
		var density: float = disaster.fog_density if disaster.fog_density > 0.0 else mist_fog_density
		environment.fog_density = density

	var mat: ShaderMaterial = _get_sky_material()
	if mat == null:
		return
	if has_mist:
		mat.set_shader_parameter("clouds_cutoff", mist_clouds_cutoff)
		mat.set_shader_parameter("clouds_weight", mist_clouds_weight)
		mat.set_shader_parameter("horizon_color", Vector3(mist_horizon_color.r, mist_horizon_color.g, mist_horizon_color.b))
	else:
		mat.set_shader_parameter("clouds_cutoff", clear_clouds_cutoff)
		mat.set_shader_parameter("clouds_weight", clear_clouds_weight)
		mat.set_shader_parameter("horizon_color", Vector3(clear_horizon_color.r, clear_horizon_color.g, clear_horizon_color.b))

func _get_sky_material() -> ShaderMaterial:
	if environment.sky == null:
		push_warning("WorldEnvironmentController: no Sky resource in Environment.")
		return null
	if environment.sky.sky_material is ShaderMaterial:
		return environment.sky.sky_material as ShaderMaterial
	push_warning("WorldEnvironmentController: Sky material is not a ShaderMaterial — assign sky.gdshader.")
	return null
