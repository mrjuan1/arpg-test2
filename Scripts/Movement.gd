class_name Movement

#region constants
const HALF_PI: float = PI / 2.0

const DEFAULT_GRAVITY_MULTIPLIER: float = 2.0

const DEFAULT_INITIAL_MOVEMENT_SPEED: float = 5.0
const DEFAULT_MOVEMENT_SPEED_LERP_SPEED: float = 10.0
const DEFAULT_MOVEMENT_SPEED_AIR_DAMPENING: float = 0.1
const DEFAULT_MAX_AIR_MOVEMENT_MULTIPLIER: float = 2.0

const DEFAULT_VELOCITY_LERP_SPEED: float = 10.0
const DEFAULT_VELOCITY_AIR_DAMPENING: float = 0.1

const DEFAULT_Y_ROTATION_LERP_SPEED: float = 10.0
const DEFAULT_Y_ROTATION_AIR_DAMPENING: float = 0.5

const DEFAULT_VELOCITY_TO_TARGET_Y_ROTATION: bool = false
const DEFAULT_Y_RESET: float = -30.0

const DEFAULT_FALL_DAMAGE_Y_DISTANCE: float = -4.0
const DEFAULT_FALL_DAMAGE_Y_VELOCITY: float = -14.0
#endregion constants

#region private variables
var _character: Character
var _gravity: float

var _movement_speed: float
var _movement_speed_lerp_speed: float
var _movement_speed_air_dampening: float
var _max_air_movement_multiplier: float

var _target_velocity: Vector2
var _velocity_lerp_speed: float
var _velocity_air_dampening: float

var _target_y_rotation: float
var _y_rotation_lerp_speed: float
var _y_rotation_air_dampening: float

var _velocity_to_target_y_rotation: bool
var _y_reset: float

var _fall_damage_y_distance: float
var _fall_damage_y_velocity: float

var _last_floored_y_position: float
var _last_y_velocity: float = 0.0
#endregion private variables

#region public variables
var movement_speed: float
var moving: bool = false

var reset_position: Vector3
#endregion public variables

#region constructor
func _init(
	character: Character,
	gravity_multiplier: float = DEFAULT_GRAVITY_MULTIPLIER,

	initial_movement_speed: float = DEFAULT_INITIAL_MOVEMENT_SPEED,
	movement_speed_lerp_speed: float = DEFAULT_MOVEMENT_SPEED_LERP_SPEED,
	movement_speed_air_dampening: float = DEFAULT_MOVEMENT_SPEED_AIR_DAMPENING,
	max_air_movement_multiplier: float = DEFAULT_MAX_AIR_MOVEMENT_MULTIPLIER,

	velocity_lerp_speed: float = DEFAULT_VELOCITY_LERP_SPEED,
	velocity_air_dampening: float = DEFAULT_VELOCITY_AIR_DAMPENING,

	y_rotation_lerp_speed: float = DEFAULT_Y_ROTATION_LERP_SPEED,
	y_rotation_air_dampening: float = DEFAULT_Y_ROTATION_AIR_DAMPENING,

	velocity_to_target_y_rotation: bool = DEFAULT_VELOCITY_TO_TARGET_Y_ROTATION,
	y_reset: float = DEFAULT_Y_RESET,

	fall_damage_y_distance: float = DEFAULT_FALL_DAMAGE_Y_DISTANCE,
	fall_damage_y_velocity: float = DEFAULT_FALL_DAMAGE_Y_VELOCITY,
) -> void:
	_character = character
	_gravity = ProjectSettings.get_setting("physics/3d/default_gravity") * gravity_multiplier

	_movement_speed = initial_movement_speed
	movement_speed = _movement_speed
	_movement_speed_lerp_speed = movement_speed_lerp_speed
	_movement_speed_air_dampening = movement_speed_air_dampening
	_max_air_movement_multiplier = max_air_movement_multiplier

	_target_velocity = Vector2.ZERO
	_velocity_lerp_speed = velocity_lerp_speed
	_velocity_air_dampening = velocity_air_dampening

	_target_y_rotation = -_character.rotation.y + HALF_PI
	_y_rotation_lerp_speed = y_rotation_lerp_speed
	_y_rotation_air_dampening = y_rotation_air_dampening

	_velocity_to_target_y_rotation = velocity_to_target_y_rotation
	_y_reset = y_reset
	reset_position = _character.position

	_fall_damage_y_distance = fall_damage_y_distance
	_fall_damage_y_velocity = fall_damage_y_velocity

	_last_floored_y_position = _character.position.y
	_last_y_velocity = _character.velocity.y
#endregion constructor

#region functions
var direction: Vector2:
	get:
		if _velocity_to_target_y_rotation:
			return Vector2.from_angle(_target_y_rotation)
		else:
			return Vector2.from_angle(-_character.rotation.y + HALF_PI)
	set(value):
		_target_y_rotation = atan2(value.y, value.x)

func physics_process(delta: float) -> void:
	var is_on_floor: bool = _character.is_on_floor()

	var movement_speed_lerp_speed: float = _movement_speed_lerp_speed * delta
	var velocity_lerp_speed: float = _velocity_lerp_speed * delta
	var y_rotation_lerp_speed: float = _y_rotation_lerp_speed * delta

	if _character.health and is_on_floor:
		var y_distance: float = _character.position.y - _last_floored_y_position
		if y_distance < _fall_damage_y_distance and _last_y_velocity < _fall_damage_y_velocity:
			var distance_damage: float = _fall_damage_y_distance - y_distance
			var velocity_damage: float = _fall_damage_y_velocity - _last_y_velocity
			if distance_damage < velocity_damage:
				_character.health.current -= distance_damage
			else:
				_character.health.current -= velocity_damage
		_last_floored_y_position = _character.position.y
	elif not is_on_floor:
		_character.velocity.y -= _gravity * delta
		movement_speed_lerp_speed *= _movement_speed_air_dampening
		velocity_lerp_speed *= _velocity_air_dampening
		y_rotation_lerp_speed *= _y_rotation_air_dampening
		_last_y_velocity = _character.velocity.y

	movement_speed = lerpf(movement_speed, _movement_speed, movement_speed_lerp_speed)
	_character.rotation.y = lerp_angle(_character.rotation.y, -_target_y_rotation + HALF_PI, y_rotation_lerp_speed)

	if moving:
		if _velocity_to_target_y_rotation:
			_target_velocity = Vector2.from_angle(_target_y_rotation)
		else:
			_target_velocity = Vector2.from_angle(-_character.rotation.y + HALF_PI)
		_target_velocity *= movement_speed
	else:
		_target_velocity = Vector2.ZERO

	_character.velocity.x = lerpf(_character.velocity.x, _target_velocity.x, velocity_lerp_speed)
	_character.velocity.z = lerpf(_character.velocity.z, _target_velocity.y, velocity_lerp_speed)

	if not is_on_floor:
		var max_air_movement: float = movement_speed * _max_air_movement_multiplier
		_character.velocity.x = clampf(_character.velocity.x, -max_air_movement, max_air_movement)
		_character.velocity.z = clampf(_character.velocity.z, -max_air_movement, max_air_movement)

	if _character.position.y < _y_reset:
		_character.position = reset_position
		printerr("Character \"%s\" fell off the map, resetting their position..." % _character.name)

	_character.move_and_slide()
#endregion functions
