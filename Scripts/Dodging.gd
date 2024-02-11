class_name Dodging

#region constants
const DEFAULT_FLOOR_DODGE_SPEED: float = 30.0
const DEFAULT_AIR_DODGE_SPEED: float = 15.0

const DEFAULT_MIN_DIRECTIONAL_SPEED: float = 1.0
const DEFAULT_STATIONARY_AIR_DAMPENING: float = 0.5

const DEFAULT_FLOOR_DODGE_STAMINA: float = 1.0
const DEFAULT_AIR_DODGE_STAMINA: float = 2.0
#endregion constants

#region privates
var _character: Character
var _dodge_timer: Timer

var _floor_dodge_speed: float
var _air_dodge_speed: float

var _min_directional_speed: float
var _stationary_air_dampening: float

var _floor_dodge_stamina: float
var _air_dodge_stamina: float

var _is_dodging: bool
#endregion privates

#region constructor
func _init(
	character: Character,
	dodge_timer: Timer,

	floor_dodge_speed: float = DEFAULT_FLOOR_DODGE_SPEED,
	air_dodge_speed: float = DEFAULT_AIR_DODGE_SPEED,

	min_directional_speed: float = DEFAULT_MIN_DIRECTIONAL_SPEED,
	stationary_air_dampening: float = DEFAULT_STATIONARY_AIR_DAMPENING,

	floor_dodge_stamina: float = DEFAULT_FLOOR_DODGE_STAMINA,
	air_dodge_stamina: float = DEFAULT_AIR_DODGE_STAMINA,
) -> void:
	_character = character

	_dodge_timer = dodge_timer
	_dodge_timer.connect("timeout", _on_dodge_timer_timeout)

	_floor_dodge_speed = floor_dodge_speed
	_air_dodge_speed = air_dodge_speed

	_min_directional_speed = min_directional_speed
	_stationary_air_dampening = stationary_air_dampening

	_floor_dodge_stamina = floor_dodge_stamina
	_air_dodge_stamina = air_dodge_stamina

	_is_dodging = false
#endregion constructor

#region functions
func _on_dodge_timer_timeout() -> void:
	_is_dodging = false

func dodge() -> void:
	if not _is_dodging:
		var is_on_floor: bool = _character.is_on_floor()

		var can_dodge: bool = false
		if is_on_floor:
			can_dodge = _character.stamina.use_stamina(_floor_dodge_stamina)
		else:
			can_dodge = _character.stamina.use_stamina(_air_dodge_stamina)

		if can_dodge:
			var xz_velocity: Vector2 = Vector2(_character.velocity.x, _character.velocity.z)
			var dodge_velocity: Vector3

			if xz_velocity.length_squared() > _min_directional_speed:
				dodge_velocity = _character.velocity.normalized()
				dodge_velocity.y = 0.0
			else:
				var direction: Vector2 = Vector2.from_angle(randf_range(0.0, TAU))
				dodge_velocity = Vector3(direction.x, 0.0, direction.y)
				if not is_on_floor:
					dodge_velocity *= _stationary_air_dampening
				_character.movement.direction = -direction

			if is_on_floor:
				dodge_velocity *= _floor_dodge_speed
			else:
				dodge_velocity *= _air_dodge_speed
				if _character.velocity.y < 0.0:
					dodge_velocity.y = 0.0
				else:
					dodge_velocity.y = _character.velocity.y

			_character.velocity = dodge_velocity
			_is_dodging = true

			_dodge_timer.start()
#endregion functions
