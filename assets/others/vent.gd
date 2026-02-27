extends AbstractInteraction

@export var particles: GPUParticles3D

# on finish complete interaction just change to cleaned = true
@export var cleaned : bool = false:
	set(value):
		cleaned = value
		if particles:
			particles.emitting = !cleaned

func _ready() -> void:
	super()
	if particles:
		particles.emitting = !cleaned
