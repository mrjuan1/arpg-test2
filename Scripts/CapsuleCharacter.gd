class_name CapsuleCharacter
extends Character

signal capsule_character_damaged
signal capsule_character_killed

@export_group("Mesh colours")
@export var _meshes: Array[MeshInstance3D]
@export var _colour_lerp_speed: float = 5.0
@export_subgroup("Colours")
@export var _damage_colour: Color = Color.RED

var _mesh_materials: Array[StandardMaterial3D]
var _mesh_original_colours: Array[Color]

@onready var _rigid_capsule: PackedScene = preload("res://RigidCapsule.tscn")

#region public functions
func init_capsule_character() -> void:
	_init_mesh_materials_colours()

	init_character()
	if health:
		health.damaged.connect(_on_health_damaged)
		health.killed.connect(_on_health_killed)

func lerp_capsule_character_colours(delta: float) -> void:
	for i: int in len(_mesh_materials):
		_mesh_materials[i].albedo_color = lerp(_mesh_materials[i].albedo_color, _mesh_original_colours[i], _colour_lerp_speed * delta)

func capsule_character_physics_process(delta: float) -> void:
	if health:
		if health.current > 0.0:
			movement.physics_process(delta)
	else:
		movement.physics_process(delta)
#endregion public functions

#region signal events
func _on_health_damaged(amount: float) -> void:
	for i: int in len(_mesh_materials):
		_mesh_materials[i].albedo_color = _damage_colour

	capsule_character_damaged.emit(amount)

func _on_health_killed() -> void:
	for i: int in len(_mesh_materials):
		_mesh_materials[i].albedo_color = _mesh_original_colours[i]

	var children: Array[Node] = get_children()
	for child: Node in children:
		child.queue_free()

	var rigid_capsule: RigidBody3D = _rigid_capsule.instantiate()
	rigid_capsule.linear_velocity = Vector3(randf_range(-0.5, 0.5), randf_range(0.0, 1.0), randf_range(-0.5, 0.5)) * 5.0
	rigid_capsule.angular_velocity = Vector3(randf_range(-PI, PI), randf_range(-PI, PI), randf_range(-PI, PI)) * 2.0
	add_child(rigid_capsule)

	capsule_character_killed.emit()
#endregion signal events

#region private functions
func _init_mesh_materials_colours() -> void:
	for mesh: MeshInstance3D in _meshes:
		var material: StandardMaterial3D = (mesh.mesh as PrimitiveMesh).material

		_mesh_materials.append(material)
		_mesh_original_colours.append(material.albedo_color)
#endregion private functions
