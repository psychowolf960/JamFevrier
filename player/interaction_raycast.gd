extends RayCast3D
const CLIMBEABLE_GROUP_KEY : StringName = &"CLIMBEABLE"

@export var foot_cast : RayCast3D

var can_climb : bool = false

func _ready() -> void:
	assert(foot_cast, "Not valid reference!")
	foot_cast.enabled = false
	
func enable_check_climbing(value : bool) -> void:
	foot_cast.enabled = value

func _physics_process(_delta: float) -> void:
	var object : Object = get_collider()
	can_climb = object is Node and object.is_in_group(CLIMBEABLE_GROUP_KEY)

	if foot_cast.enabled and !can_climb:
		object = foot_cast.get_collider()
		can_climb = object is Node and object.is_in_group(CLIMBEABLE_GROUP_KEY)
		
