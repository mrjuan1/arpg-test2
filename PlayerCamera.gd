class_name PlayerCamera

#region constants
const DEFAULT_CAMERA_LERP_SPEED: float = 5.0
#endregion constants

#region privates
var _character: Character

var _camera: Camera3D
var _camera_offset: Vector3
var _camera_lerp_speed: float
#endregion privates

#region constructor
func _init(
	character: Character,

	camera: Camera3D,
	camera_lerp_speed: float = DEFAULT_CAMERA_LERP_SPEED
) -> void:
	_character = character

	_camera = camera
	_camera_offset = _camera.position
	_camera_lerp_speed = camera_lerp_speed
#endregion constructor

#region functions
func physics_process(delta: float) -> void:
	var target_position: Vector3 = _character.position + _camera_offset
	var lerp_speed: float = _camera_lerp_speed * delta

	_camera.position = lerp(_camera.position, target_position, lerp_speed)
#endregion functions
