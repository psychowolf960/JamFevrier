extends Resource
class_name DisasterData

@export var disaster_id: String = ""
@export var disaster_name: String = ""
@export var signs: Array[String] = []
@export var solutions: Array[String] = []
@export var sky_color: Color = Color(0.1, 0.1, 0.15)
@export var fog_density: float = 0.0
@export var is_night: bool = false
@export_file("*.ogg", "*.wav", "*.mp3") var ambient_audio_path: String = ""
@export_file("*.ogg", "*.wav", "*.mp3") var soundtrack_path: String = ""
@export var enabled_signs: Array[String] = []
@export var required_task_ids: Array[String] = []
@export var illustration: Texture2D
