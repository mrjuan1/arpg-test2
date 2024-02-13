class_name Player
extends Character

#region exports
@export_group("Colours")
@export var _meshes: Array[MeshInstance3D]
@export var _colour_lerp_speed: float = 5.0

@export_group("Camera")
@export var _camera: Camera3D
@export_subgroup("Speed")
@export var _camera_xz_lerp_speed: float = PlayerCamera.DEFAULT_CAMERA_XZ_LERP_SPEED
@export var _camera_y_lerp_speed: float = PlayerCamera.DEFAULT_CAMERA_Y_LERP_SPEED
@export_subgroup("Follow distance")
@export var _camera_y_positive_follow_distance: float = PlayerCamera.DEFAULT_CAMERA_Y_POSITIVE_FOLLOW_DISTANCE
@export var _camera_y_negative_follow_distance: float = PlayerCamera.DEFAULT_CAMERA_Y_NEGATIVE_FOLLOW_DISTANCE

@export_group("Stat labels")
@export var _hp_label: Label
@export var _stamina_label: Label
#endregion exports

#region private variables
var _mesh_materials: Array[StandardMaterial3D]
var _mesh_original_colours: Array[Color]

var _input_vec: Vector2 = Vector2.ZERO
var _last_stamina: float = 0.0
var _melee_charge_state: Melee.ChargeState = Melee.ChargeState.RELEASED
#endregion private variables

#region public variables
@onready var _rigid_capsule: PackedScene = preload("res://RigidCapsule.tscn")

@onready var player_camera: PlayerCamera = PlayerCamera.new(
	self,
	_camera,

	_camera_xz_lerp_speed,
	_camera_y_lerp_speed,

	_camera_y_positive_follow_distance,
	_camera_y_negative_follow_distance,
)

@onready var _player_ray: RayCast3D = $PlayerRay
#endregion public variables

#region events
func _ready() -> void:
	_init_mesh_materials_colours()

	init_character()

	health.damaged.connect(_on_health_damaged)
	health.killed.connect(_on_health_killed)

	melee.attack_released.connect(_on_melee_attack_released)

	_update_hp_label()

func _process(delta: float) -> void:
	if health.current > 0.0:
		_lerp_mesh_colours(delta)

		if _melee_charge_state == Melee.ChargeState.CHARGING:
			if Input.is_action_just_released("attack"):
				melee.release_attack()
				_melee_charge_state = Melee.ChargeState.RELEASED
			else:
				velocity = -Vector3(movement.direction.x, 0.0, movement.direction.y) * 0.5
				_melee_charge_state = melee.charge_attack(delta)
		else:
			_input_vec = Input.get_vector("left", "right", "up", "down")
			if _input_vec:
				movement.direction = _input_vec
				movement.moving = true
			else:
				movement.moving = false

			if Input.is_action_just_pressed("jump"):
				jumping.jump()
			elif Input.is_action_just_pressed("dodge"):
				dodging.dodge()
			elif Input.is_action_just_pressed("attack"):
				if is_on_floor():
					movement.moving = false
					_melee_charge_state = Melee.ChargeState.CHARGING
				else:
					melee.release_attack()

			stamina.recharge_stamina(delta)

		_update_stamina_label()

	if Input.is_action_just_pressed("action"):
		get_tree().reload_current_scene()

func _physics_process(delta: float) -> void:
	if health.current > 0.0:
		movement.physics_process(delta)

	player_camera.physics_process(delta)
#endregion events

#region signal events
func _on_health_damaged(amount: float) -> void:
	_set_mesh_colours(Color.RED)

	_update_hp_label()
	prints("Damaged:", amount)

func _on_health_killed() -> void:
	_set_mesh_colours(Color.WHITE)

	var children: Array[Node] = get_children()
	for child: Node in children:
		child.queue_free()

	var rigid_capsule: RigidBody3D = _rigid_capsule.instantiate()
	rigid_capsule.linear_velocity = Vector3(randf_range(-0.5, 0.5), randf_range(0.0, 1.0), randf_range(-0.5, 0.5)) * 5.0
	rigid_capsule.angular_velocity = Vector3(randf_range(-PI, PI), randf_range(-PI, PI), randf_range(-PI, PI)) * 2.0
	add_child(rigid_capsule)

func _on_melee_attack_released(strength: float, combo: int) -> void:
	if is_on_floor():
		velocity = Vector3(movement.direction.x, 0.0, movement.direction.y) * 10.0
	else:
		const VELOCITY_SCALE: float = 5.0
		velocity.x = movement.direction.x * VELOCITY_SCALE
		velocity.z = movement.direction.y * VELOCITY_SCALE

		if velocity.y > 0.0:
			if velocity.y > VELOCITY_SCALE:
				velocity.y = VELOCITY_SCALE
		else:
			if velocity.y < -VELOCITY_SCALE:
				velocity.y = -VELOCITY_SCALE
			else:
				velocity.y *= -1.0

	if _player_ray.is_colliding():
		var collider: Object = _player_ray.get_collider()
		if collider is NPC:
			var npc: NPC = collider as NPC
			npc.health.current -= strength

	prints("Melee attack released with", strength, "strength and", combo, "combos")
#endregion signal events

#region private functions
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

func _update_hp_label() -> void:
	if _hp_label:
		_hp_label.text = "HP: %.0f/%.0f" % [ceilf(health.current), health.maximum]

func _update_stamina_label() -> void:
	if _stamina_label and stamina.current != _last_stamina:
		_stamina_label.text = "Stamina: %.1f/%.1f" % [stamina.current, stamina.maximum]
		_last_stamina = stamina.current
#endregion private functions
