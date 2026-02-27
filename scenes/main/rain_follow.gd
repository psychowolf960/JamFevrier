extends GPUParticles3D
# Player target
@export var target : Node3D = null:
	set(new_target):
		target = new_target
		set_process(target != null)

func _ready() -> void:
	# set_process(target != null and emitting) ## As you want.-
	set_process(target != null)
	
# Only when use directly set(emitting, true | false)
func _set(property: StringName, value: Variant) -> bool:
	if property == &"emitting":
		set_process(value and target != null)
	return false

func _process(_delta: float) -> void:
	var target_position : Vector3 = target.global_position
	global_position.x = target_position.x
	global_position.z = target_position.z
