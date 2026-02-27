extends Node3D

var mesh_instance: MeshInstance3D
var original_mat: StandardMaterial3D
var emission_mat: StandardMaterial3D

func _ready() -> void:
	for child in get_children():
		if child is MeshInstance3D:
			mesh_instance = child
			break

	original_mat = mesh_instance.get_active_material(0)

func execute(percentage: float) -> void:
	if percentage >= 99.0:
		if original_mat == null:
			return

		if emission_mat == null:
			emission_mat = original_mat.duplicate()
			emission_mat.emission_enabled = true
			emission_mat.emission_energy_multiplier = 1.0

		mesh_instance.set_surface_override_material(0, emission_mat)
		return

	restore_original()

func restore_original() -> void:
	if original_mat:
		mesh_instance.set_surface_override_material(0, original_mat)
