class_name NPC
extends Character

@export_group("Colours")
@export var _meshes: Array[MeshInstance3D]
@export var _colour_lerp_speed: float = 5.0

var _mesh_materials: Array[StandardMaterial3D]
var _mesh_original_colours: Array[Color]

@onready var _rigid_capsule: PackedScene = preload("res://RigidCapsule.tscn")

func _ready() -> void:
	_init_mesh_materials_colours()
	init_character()

	health.damaged.connect(_on_health_damaged)
	health.killed.connect(_on_health_killed)

func _process(delta: float) -> void:
	_lerp_mesh_colours(delta)

func _physics_process(delta: float) -> void:
	if health.current > 0.0:
		movement.physics_process(delta)

func _on_health_damaged(amount: float) -> void:
	_set_mesh_colours(Color.RED)
	prints("NPC Damaged:", amount)

func _on_health_killed() -> void:
	_set_mesh_colours(Color.WHITE)

	var children: Array[Node] = get_children()
	for child: Node in children:
		child.queue_free()

	var rigid_capsule: RigidBody3D = _rigid_capsule.instantiate()
	rigid_capsule.linear_velocity = Vector3(randf_range(-0.5, 0.5), randf_range(0.0, 1.0), randf_range(-0.5, 0.5)) * 5.0
	rigid_capsule.angular_velocity = Vector3(randf_range(-PI, PI), randf_range(-PI, PI), randf_range(-PI, PI)) * 2.0
	add_child(rigid_capsule)

func _init_mesh_materials_colours() -> void:
	for mesh: MeshInstance3D in _meshes:
		var material: StandardMaterial3D = (mesh.mesh as PrimitiveMesh).material
		_mesh_materials.push_back(material)
		_mesh_original_colours.push_back(material.albedo_color)

func _lerp_mesh_colours(delta: float) -> void:
	for i: int in len(_mesh_materials):
		_mesh_materials[i].albedo_color = lerp(_mesh_materials[i].albedo_color, _mesh_original_colours[i], _colour_lerp_speed * delta)

func _set_mesh_colours(colour: Color) -> void:
	for i: int in len(_mesh_materials):
		_mesh_materials[i].albedo_color = colour
