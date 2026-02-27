extends StaticBody3D
class_name Poster

@export var textures: Array[Texture2D] = []
@onready var _mesh: MeshInstance3D = $MeshInstance3D

func _ready() -> void:
	var mat := StandardMaterial3D.new()
	mat.albedo_texture = textures[randi() % textures.size()]
	_mesh.material_override = mat
