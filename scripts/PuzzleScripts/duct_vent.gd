class_name DuctVent
extends AbstractInteraction

@export var disinfectant_item_name: String = "Disinfectant"

var _treated: bool = false

func _ready() -> void:
	super()
	add_to_group("duct_vent_interaction")

func use_item(item_data: ItemData) -> bool:
	print("trat")
	if _treated:
		return false
	if item_data.item_name != disinfectant_item_name:
		return false
	_treated = true
	can_interact = false
	_check_all_vents_treated()
	return true

func _check_all_vents_treated() -> void:
	var all_vents: Array[Node] = get_tree().get_nodes_in_group("duct_vent_interaction")
	for vent_node in all_vents:
		var vent: DuctVent = vent_node as DuctVent
		if vent == null or not vent._treated:
			return
	TaskManager.complete_task("disinfect_ducts")
