extends GPUParticles3D

func _ready() -> void:
	set_process(false)
	add_to_group(&"WOOD_PARTICLES")
	
func play_particles() -> bool:
	if !emitting:
		emitting = true
		return true
	return false
