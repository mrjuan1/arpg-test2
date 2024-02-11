class_name Jumping

#region constants
const DEFAULT_JUMP_HEIGHT: float = 8.0
const DEFAULT_DOUBLE_JUMP_MIN_VELOCITY: float = 3.0
const DEFAULT_DOUBLE_JUMP_SCALE: float = 0.75
#endregion constants

#region privates
var _character: Character

var _jump_height: float
var _double_jump_min_velocity: float
var _double_jump_height: float

var _has_double_jumped: bool
#endregion privates

#region constructor
func _init(
	character: Character,

	jump_height: float = DEFAULT_JUMP_HEIGHT,
	double_jump_min_velocity: float = DEFAULT_DOUBLE_JUMP_MIN_VELOCITY,
	double_jump_scale: float = DEFAULT_DOUBLE_JUMP_SCALE,
) -> void:
	_character = character

	_jump_height = jump_height
	_double_jump_min_velocity = double_jump_min_velocity
	_double_jump_height = _jump_height * double_jump_scale

	_has_double_jumped = false
#endregion constructor

#region functions
func jump() -> void:
	if _character.is_on_floor():
		_character.velocity.y = _jump_height
		_has_double_jumped = false
	elif not _has_double_jumped and _character.velocity.y < _double_jump_min_velocity:
		_character.velocity.y = _double_jump_height
		_has_double_jumped = true
#endregion functions
