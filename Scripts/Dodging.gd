class_name Dodging

#region constants
const DEFAULT_FLOOR_DODGE_SPEED: float = 30.0
const DEFAULT_AIR_DODGE_SPEED: float = 15.0

const DEFAULT_MIN_DIRECTIONAL_SPEED: float = 1.0
const DEFAULT_STATIONARY_AIR_DAMPENING: float = 0.5
#endregion constants

#region privates
var _movement: Movement
var _dodge_timer: Timer

var _floor_dodge_speed: float
var _air_dodge_speed: float

var _min_directional_speed: float
var _stationary_air_dampening: float

var _is_dodging: bool
#endregion privates

#region constructor
func _init(
	movement: Movement,
	dodge_timer: Timer,

	floor_dodge_speed: float = DEFAULT_FLOOR_DODGE_SPEED,
	air_dodge_speed: float = DEFAULT_AIR_DODGE_SPEED,

	min_directional_speed: float = DEFAULT_MIN_DIRECTIONAL_SPEED,
	stationary_air_dampening: float = DEFAULT_STATIONARY_AIR_DAMPENING,
) -> void:
	_movement = movement

	_dodge_timer = dodge_timer
	_dodge_timer.connect("timeout", _on_dodge_timer_timeout)

	_floor_dodge_speed = floor_dodge_speed
	_air_dodge_speed = air_dodge_speed

	_min_directional_speed = min_directional_speed
	_stationary_air_dampening = stationary_air_dampening

	_is_dodging = false
#endregion constructor

#region functions
func _on_dodge_timer_timeout() -> void:
	_is_dodging = false

func dodge() -> void:
	if not _is_dodging:
		var character: Character = _movement.assigned_character
		var xz_velocity: Vector2 = Vector2(character.velocity.x, character.velocity.z)

		var dodge_velocity: Vector3

		if xz_velocity.length_squared() > _min_directional_speed:
			dodge_velocity = character.velocity.normalized()
			dodge_velocity.y = 0.0
		else:
			var direction: Vector2 = Vector2.from_angle(randf_range(0.0, TAU))
			dodge_velocity = Vector3(direction.x, 0.0, direction.y)
			if not character.is_on_floor():
				dodge_velocity *= _stationary_air_dampening
			_movement.direction = -direction

		if character.is_on_floor():
			dodge_velocity *= _floor_dodge_speed
		else:
			dodge_velocity *= _air_dodge_speed
			if character.velocity.y < 0.0:
				dodge_velocity.y = 0.0
			else:
				dodge_velocity.y = character.velocity.y

		character.velocity = dodge_velocity

		_is_dodging = true
		_dodge_timer.start()
#endregion functions
