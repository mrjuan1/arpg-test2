class_name Enemy
extends CapsuleCharacter

#region exports
@export_group("Detection")
@export_subgroup("Collision shapes")
@export var _detection_area: Area3D
@export var _vision_area: Area3D
@export_subgroup("Detection")
@export var _target_detection_velocity: float = 0.1
@export var _detection_ray: RayCast3D
@export_subgroup("Debug")
@export var _detection_mesh: MeshInstance3D
@export var _vision_mesh: MeshInstance3D
@export var _debug_colour_lerp_speed: float = 5.0
#endregion exports

#region private variables
var _target_character: Character
var _target_position: Vector3

var _in_detection_area: bool = false
var _in_vision_area: bool = false

var _track_target_position: bool = false
var _target_was_on_floor: bool = true

var _detection_material: StandardMaterial3D
var _target_detection_colour: Color

var _vision_material: StandardMaterial3D
var _target_vision_colour: Color
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

	if _detection_mesh:
		_detection_material = (_detection_mesh.mesh as PrimitiveMesh).material
		_target_detection_colour = _detection_material.albedo_color

	if _vision_mesh:
		_vision_material = (_vision_mesh.mesh as PrimitiveMesh).material
		_target_vision_colour = _vision_material.albedo_color

func _process(delta: float) -> void:
	lerp_capsule_character_colours(delta)
	_update_debug_colours(delta)

	if _in_vision_area:
		_track_target_position = true
	elif _in_detection_area:
		if _target_character.is_on_floor() != _target_was_on_floor or \
			(_target_character.is_on_floor() and \
			(absf(_target_character.velocity.x) > _target_detection_velocity or \
			absf(_target_character.velocity.z) > _target_detection_velocity)):
				_track_target_position = true
		else:
			_track_target_position = false
		_target_was_on_floor = _target_character.is_on_floor()
	else:
		_track_target_position = false

	if _track_target_position:
		if _target_character.position.is_equal_approx(_target_position):
			pass # TODO: Move to target_position along the navmesh
		else:
			_detection_ray.target_position = _target_character.position - position
			_detection_ray.force_raycast_update()
			if _detection_ray.is_colliding() and \
				_detection_ray.get_collider().get_instance_id() == _target_character.get_instance_id():
					_target_position = _target_character.position

func _physics_process(delta: float) -> void:
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
			_target_detection_colour = Color.WHEAT

func _on_detection_body_exited(body: Node3D) -> void:
	if body is Player:
		var character: Character = body as Character

		if _target_character and character.get_instance_id() == _target_character.get_instance_id():
			_in_detection_area = false
			_target_detection_colour = Color.WHITE

		if not _in_detection_area and not _in_vision_area:
			_target_character = null

func _on_vision_body_entered(body: Node3D) -> void:
	if body is Player:
		var character: Character = body as Character

		if not _target_character:
			_target_character = character

		if not _in_vision_area and character.get_instance_id() == _target_character.get_instance_id():
			_in_vision_area = true
			_target_vision_colour = Color.WHEAT

func _on_vision_body_exited(body: Node3D) -> void:
	if body is Player:
		var character: Character = body as Character

		if _target_character and character.get_instance_id() == _target_character.get_instance_id():
			_in_vision_area = false
			_target_vision_colour = Color.WHITE

		if not _in_detection_area and not _in_vision_area:
			_target_character = null
#endregion signal events

#region private functions
func _update_debug_colours(delta: float) -> void:
	if _detection_mesh:
		_detection_material.albedo_color = lerp(_detection_material.albedo_color, _target_detection_colour, _debug_colour_lerp_speed * delta)
		_detection_material.albedo_color.a = 0.5

	if _vision_mesh:
		_vision_material.albedo_color = lerp(_vision_material.albedo_color, _target_vision_colour, _debug_colour_lerp_speed * delta)
		_vision_material.albedo_color.a = 0.5
#endregion private functions
