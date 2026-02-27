extends Node

var _encountered: Array[String] = []

func record_disaster(disaster_id: String) -> void:
	if disaster_id not in _encountered:
		_encountered.append(disaster_id)

func has_encountered(disaster_id: String) -> bool:
	return disaster_id in _encountered

func get_encountered() -> Array[String]:
	return _encountered.duplicate()
