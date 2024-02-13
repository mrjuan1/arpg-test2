class_name PlayerCamera

#region constants
const DEFAULT_CAMERA_XZ_LERP_SPEED: float = 5.0
const DEFAULT_CAMERA_Y_LERP_SPEED: float = 2.5

const DEFAULT_CAMERA_Y_POSITIVE_FOLLOW_DISTANCE: float = 2.0
const DEFAULT_CAMERA_Y_NEGATIVE_FOLLOW_DISTANCE: float = -8.0
#endregion constants

#region private variables
var _character: Character

var _camera: Camera3D
var _camera_offset: Vector3

var _camera_xz_lerp_speed: float
var _camera_y_lerp_speed: float

var _camera_y_positive_follow_distance: float
var _camera_y_negative_follow_distance: float
var _camera_target_y: float
#endregion private variables

#region constructor
func _init(
	character: Character,
	camera: Camera3D,

	camera_xz_lerp_speed: float = DEFAULT_CAMERA_XZ_LERP_SPEED,
	camera_y_lerp_speed: float = DEFAULT_CAMERA_Y_LERP_SPEED,

	camera_y_positive_follow_distance: float = DEFAULT_CAMERA_Y_POSITIVE_FOLLOW_DISTANCE,
	camera_y_negative_follow_distance: float = DEFAULT_CAMERA_Y_NEGATIVE_FOLLOW_DISTANCE,
) -> void:
	_character = character

	_camera = camera
	_camera_offset = _camera.position

	_camera_xz_lerp_speed = camera_xz_lerp_speed
	_camera_y_lerp_speed = camera_y_lerp_speed

	_camera_y_positive_follow_distance = camera_y_positive_follow_distance
	_camera_y_negative_follow_distance = camera_y_negative_follow_distance
	_camera_target_y = _camera.position.y - _camera_offset.y
#endregion constructor

#region functions
func physics_process(delta: float) -> void:
	var position_xz_lerp_speed: float = _camera_xz_lerp_speed * delta
	var position_y_lerp_speed: float = _camera_xz_lerp_speed * delta

	var target_position: Vector3 = _character.position + _camera_offset

	var base_y: float = _camera.position.y - _camera_offset.y
	var y_diff: float = absf(base_y - _character.position.y)
	if _character.is_on_floor() or y_diff > _camera_y_positive_follow_distance or _character.velocity.y < _camera_y_negative_follow_distance:
		_camera_target_y = _character.position.y + _camera_offset.y

	_camera.position.x = lerpf(_camera.position.x, target_position.x, position_xz_lerp_speed)
	_camera.position.z = lerpf(_camera.position.z, target_position.z, position_xz_lerp_speed)
	_camera.position.y = lerpf(_camera.position.y, _camera_target_y, position_y_lerp_speed)
#endregion functions
