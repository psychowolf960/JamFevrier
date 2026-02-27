extends Node
class_name DisasterAware

static func sign_enabled(sign_id: String) -> bool:
	var disaster: DisasterData = GameManager.current_disaster
	if disaster == null:
		return false
	return sign_id in disaster.enabled_signs
