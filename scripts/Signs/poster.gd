extends StaticBody3D
class_name Poster

@export var textures: Array[Texture2D] = []
@onready var _mesh: MeshInstance3D = $MeshInstance3D

func _ready() -> void:
	if textures.is_empty():
		push_warning("Poster: no textures assigned in the inspector.")
		return
	var mat := StandardMaterial3D.new()
	mat.albedo_texture = textures[randi() % textures.size()]
	_mesh.material_override = mat
