class_name Enemy
extends CapsuleCharacter

#region exports
@export_group("Detection")
@export_subgroup("Collision shapes")
@export var _detection_area: Area3D
@export var _vision_area: Area3D
@export_subgroup("Debug")
@export var _detection_mesh: MeshInstance3D
@export var _vision_mesh: MeshInstance3D
@export var _debug_colour_lerp_speed: float = 5.0
#endregion exports

#region onready
@onready var _detection_material: StandardMaterial3D = (_detection_mesh.mesh as PrimitiveMesh).material
@onready var _vision_material: StandardMaterial3D = (_vision_mesh.mesh as PrimitiveMesh).material

@onready var _target_detection_colour: Color = _detection_material.albedo_color
@onready var _target_vision_colour: Color = _vision_material.albedo_color
#endregion onready

#region events
func _ready() -> void:
	init_capsule_character()

	_detection_area.connect("body_entered", _on_detection_body_entered)
	_detection_area.connect("body_exited", _on_detection_body_exited)

	_vision_area.connect("body_entered", _on_vision_body_entered)
	_vision_area.connect("body_exited", _on_vision_body_exited)

func _process(delta: float) -> void:
	lerp_capsule_character_colours(delta)
	_update_debug_colours(delta)

func _physics_process(delta: float) -> void:
	capsule_character_physics_process(delta)
#endregion events

#region signal events
func _on_detection_body_entered(body: Node3D) -> void:
	_target_detection_colour = Color.WHEAT
	prints("Detection body entered:", body)

func _on_detection_body_exited(body: Node3D) -> void:
	_target_detection_colour = Color.WHITE
	prints("Detection body exited:", body)

func _on_vision_body_entered(body: Node3D) -> void:
	_target_vision_colour = Color.WHEAT
	prints("Vision body entered:", body)

func _on_vision_body_exited(body: Node3D) -> void:
	_target_vision_colour = Color.WHITE
	prints("Vision body exited:", body)
#endregion signal events

#region private functions
func _update_debug_colours(delta: float) -> void:
	_detection_material.albedo_color = lerp(_detection_material.albedo_color, _target_detection_colour, _debug_colour_lerp_speed * delta)
	_detection_material.albedo_color.a = 0.5

	_vision_material.albedo_color = lerp(_vision_material.albedo_color, _target_vision_colour, _debug_colour_lerp_speed * delta)
	_vision_material.albedo_color.a = 0.5
#endregion private functions
