class_name Enemy
extends CapsuleCharacter

signal target_character_reached

#region exports
@export_group("Detection")
@export_subgroup("Collision shapes")
@export var _detection_area: Area3D
@export var _vision_area: Area3D
@export_subgroup("Detection")
@export var _target_detection_velocity: float = 0.1
@export var _detection_ray: RayCast3D

@export_group("Movement")
@export var _nav_agent: NavigationAgent3D
@export var _target_distance_threshold: float = 1.0
#endregion exports

#region private variables
var _target_character: Character

var _in_detection_area: bool = false
var _in_vision_area: bool = false

var _track_target_position: bool = false
var _target_was_on_floor: bool = true

var _is_chasing: bool = false # TODO: Replace with behaviour action
#endregion private variables

#region events
func _ready() -> void:
	init_capsule_character()

	if _detection_area:
		_detection_area.connect("body_entered", _on_detection_body_entered)
		_detection_area.connect("body_exited", _on_detection_body_exited)

	if _vision_area:
		_vision_area.connect("body_entered", _on_vision_body_entered)
		_vision_area.connect("body_exited", _on_vision_body_exited)

	if _nav_agent:
		_nav_agent.velocity_computed.connect(_on_nav_agent_velocity_computed)
		_nav_agent.navigation_finished.connect(_on_nav_agent_navigation_finished)

	target_character_reached.connect(_on_target_character_reached)

func _process(delta: float) -> void:
	lerp_capsule_character_colours(delta)

	if _in_vision_area:
		_track_target_position = true
	elif _in_detection_area:
		_track_target_position = _target_character.is_on_floor() != _target_was_on_floor or \
			(_target_character.is_on_floor() and \
			(absf(_target_character.velocity.x) > _target_detection_velocity or \
			absf(_target_character.velocity.z) > _target_detection_velocity))
		_target_was_on_floor = _target_character.is_on_floor()
	else:
		_track_target_position = false

	if _track_target_position and \
		not _target_character.position.is_equal_approx(_nav_agent.target_position):
			if _in_detection_area:
				_nav_agent.target_position = _target_character.position
				_is_chasing = true
			elif _in_vision_area:
				_detection_ray.rotation.y = -rotation.y
				_detection_ray.target_position = _target_character.position - position
				_detection_ray.force_raycast_update()
				if _detection_ray.is_colliding() and \
					_detection_ray.get_collider().get_instance_id() == _target_character.get_instance_id():
						_nav_agent.target_position = _target_character.position
						_is_chasing = true

func _physics_process(delta: float) -> void:
	if _is_chasing:
		_nav_agent.velocity = (_nav_agent.get_next_path_position() - position).normalized()

	capsule_character_physics_process(delta)
#endregion events

#region signal events
func _on_detection_body_entered(body: Node3D) -> void:
	if body is Player:
		var character: Character = body as Character

		if not _target_character:
			_target_character = character
			_target_was_on_floor = _target_character.is_on_floor()

		if not _in_detection_area and character.get_instance_id() == _target_character.get_instance_id():
			_in_detection_area = true

func _on_detection_body_exited(body: Node3D) -> void:
	if body is Player:
		var character: Character = body as Character

		if _target_character and character.get_instance_id() == _target_character.get_instance_id():
			_in_detection_area = false

		if not _in_detection_area and not _in_vision_area:
			_target_character = null

func _on_vision_body_entered(body: Node3D) -> void:
	if body is Player:
		var character: Character = body as Character

		if not _target_character:
			_target_character = character

		if not _in_vision_area and character.get_instance_id() == _target_character.get_instance_id():
			_in_vision_area = true

func _on_vision_body_exited(body: Node3D) -> void:
	if body is Player:
		var character: Character = body as Character

		if _target_character and character.get_instance_id() == _target_character.get_instance_id():
			_in_vision_area = false

		if not _in_detection_area and not _in_vision_area:
			_target_character = null

func _on_nav_agent_velocity_computed(safe_velocity: Vector3) -> void:
	if _is_chasing:
		var angle: float = -atan2(safe_velocity.x, safe_velocity.z) + Movement.HALF_PI
		movement.direction = Vector2.from_angle(angle)
		movement.moving = true

func _on_nav_agent_navigation_finished() -> void:
	movement.moving = false
	_is_chasing = false

	if _target_character and position.distance_squared_to(_nav_agent.target_position) < _target_distance_threshold:
		target_character_reached.emit(_target_character)

func _on_target_character_reached(target_character: Character) -> void:
	prints("Target character reached:", target_character)
#endregion signal events
