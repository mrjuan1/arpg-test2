class_name Enemy
extends CapsuleCharacter

enum BehaviourAction {
	NONE,
	MOVING,
	OBSERVING,
	PURSUING,
	CHARGING,
	RELEASING,
}

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

@export_group("Behaviour")
@export var _behaviour_timer: Timer
@export var _path: Path3D
#endregion exports

#region private variables
var _target_character: Character

var _in_detection_area: bool = false
var _in_vision_area: bool = false

var _target_was_on_floor: bool = true

var _behaviour_action: BehaviourAction = BehaviourAction.NONE
var _path_target_point: int = 0
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

	if _behaviour_timer:
		_behaviour_timer.timeout.connect(_on_behaviour_timer_timeout)
		_on_behaviour_timer_timeout()

	if _path:
		_nav_agent.target_position = _path.curve.get_point_position(_path_target_point)
	else:
		_nav_agent.target_position = position

func _process(delta: float) -> void:
	lerp_capsule_character_colours(delta)

	if _behaviour_action < BehaviourAction.CHARGING and _aware_of_target():
		_update_chase_state()

func _physics_process(delta: float) -> void:
	if _behaviour_action == BehaviourAction.MOVING or \
		_behaviour_action == BehaviourAction.PURSUING:
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
	if _behaviour_action == BehaviourAction.MOVING or \
		_behaviour_action == BehaviourAction.PURSUING:
			var angle: float = -atan2(safe_velocity.x, safe_velocity.z) + Movement.HALF_PI
			movement.direction = Vector2.from_angle(angle)
			movement.moving = true

func _on_nav_agent_navigation_finished() -> void:
	if _behaviour_action == BehaviourAction.MOVING:
		if _path:
			_path_target_point += 1
			if _path_target_point == _path.curve.point_count:
				_path_target_point = 0
			_nav_agent.target_position = _path.curve.get_point_position(_path_target_point)
		else:
			# If there's no path assigned, move randomly
			if randf() < 0.5:
				_nav_agent.target_position.x = position.x - randf_range(2.0, 5.0)
			else:
				_nav_agent.target_position.x = position.x + randf_range(2.0, 5.0)
			if randf() < 0.5:
				_nav_agent.target_position.z = position.z - randf_range(2.0, 5.0)
			else:
				_nav_agent.target_position.z = position.z + randf_range(2.0, 5.0)
	elif _behaviour_action == BehaviourAction.PURSUING:
		movement.moving = false

		if _target_character and position.distance_squared_to(_nav_agent.target_position) < _target_distance_threshold:
			target_character_reached.emit(_target_character)
		else:
			_behaviour_action = BehaviourAction.OBSERVING

func _on_target_character_reached(target_character: Character) -> void:
	_behaviour_action = BehaviourAction.CHARGING
	prints("Target character reached:", target_character)

func _on_behaviour_timer_timeout() -> void:
	if _behaviour_action < BehaviourAction.PURSUING:
		var last_action: BehaviourAction = _behaviour_action
		while _behaviour_action == last_action:
			_behaviour_action = randi_range(BehaviourAction.NONE, BehaviourAction.OBSERVING) as BehaviourAction

		if _behaviour_action == BehaviourAction.NONE or \
			_behaviour_action == BehaviourAction.OBSERVING:
				movement.moving = false

		_behaviour_timer.wait_time = randf_range(1.0, 4.0) # TODO: Define as exports?
		_behaviour_timer.start()
#endregion signal events

#region private functions
func _aware_of_target() -> bool:
	if _in_vision_area:
		return true

	if _in_detection_area:
		var result: bool = _target_character.is_on_floor() != _target_was_on_floor or \
			(_target_character.is_on_floor() and \
			(absf(_target_character.velocity.x) > _target_detection_velocity or \
			absf(_target_character.velocity.z) > _target_detection_velocity))
		_target_was_on_floor = _target_character.is_on_floor()

		return result

	return false

func _update_chase_state() -> void:
	if not _target_character.position.is_equal_approx(_nav_agent.target_position):
		if _in_detection_area:
			_nav_agent.target_position = _target_character.position
			_behaviour_action = BehaviourAction.PURSUING
		elif _in_vision_area:
			_detection_ray.rotation.y = -rotation.y
			_detection_ray.target_position = _target_character.position - position
			_detection_ray.force_raycast_update()

			if _detection_ray.is_colliding() and \
				_detection_ray.get_collider().get_instance_id() == _target_character.get_instance_id():
					_nav_agent.target_position = _target_character.position
					_behaviour_action = BehaviourAction.PURSUING
#endregion private functions
