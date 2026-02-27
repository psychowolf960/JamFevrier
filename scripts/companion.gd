extends CharacterBody3D

## Assign in the inspector
@export var player: CharacterBody3D

## Distance at which the companion starts walking toward the player
@export var follow_distance: float = 4.0
## Distance at which the companion stops walking
@export var stop_distance: float = 2.0
## Walking speed (should roughly match or slightly exceed the player's walk speed)
@export var move_speed: float = 3.5
## How fast the companion rotates to face the player
@export var rotation_speed: float = 8.0

## Probability per second of triggering a salute while idle (0.0–1.0)
@export var salute_chance: float = 0.5
## Minimum seconds between two salutes
@export var salute_cooldown: float = 12.0

@onready var anim_player: AnimationPlayer = $AnimationPlayer

enum State { IDLE, WALK, SALUTE }
var _state: State = State.IDLE
var _salute_cooldown_remaining: float = 0.0


func _ready() -> void:
	if not player:
		push_warning("Companion: no player assigned. Drag the player node into the 'Player' export.")


func _physics_process(delta: float) -> void:
	if not player:
		return

	_salute_cooldown_remaining = maxf(0.0, _salute_cooldown_remaining - delta)

	# Apply gravity so the companion stays grounded
	if not is_on_floor():
		velocity += get_gravity() * delta
	else:
		velocity.y = 0.0

	var dist: float = global_position.distance_to(player.global_position)

	match _state:
		State.IDLE:
			velocity.x = 0.0
			velocity.z = 0.0
			_play_anim("idle")

			# Start following if player moves away
			if dist > follow_distance:
				_state = State.WALK

			# Random salute chance while idle and not on cooldown
			elif _salute_cooldown_remaining <= 0.0 and randf() < salute_chance * delta:
				_state = State.SALUTE
				_play_anim("salute")

		State.WALK:
			_face_player(delta)
			var dir := _flat_direction_to_player()
			velocity.x = dir.x * move_speed
			velocity.z = dir.z * move_speed
			_play_anim("walk")

			if dist <= stop_distance:
				_state = State.IDLE

		State.SALUTE:
			velocity.x = 0.0
			velocity.z = 0.0
			# Wait for the salute animation to finish, then go idle
			if not anim_player.is_playing():
				_salute_cooldown_remaining = salute_cooldown
				_state = State.IDLE

	move_and_slide()


# ── Helpers ────────────────────────────────────────────────────────────────────

func _flat_direction_to_player() -> Vector3:
	var dir := player.global_position - global_position
	dir.y = 0.0
	return dir.normalized()


func _face_player(delta: float) -> void:
	var dir := _flat_direction_to_player()
	if dir.length_squared() < 0.01:
		return
	var target_angle := atan2(dir.x, dir.z)
	rotation.y = lerp_angle(rotation.y, target_angle, rotation_speed * delta)


func _play_anim(anim_name: String) -> void:
	if anim_player.current_animation == anim_name:
		return
	anim_player.play(anim_name)
