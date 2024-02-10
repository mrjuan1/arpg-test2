class_name Character
extends CharacterBody3D

#region exports
@export_group("Movement")
@export var gravity_multiplier: float = Movement.DEFAULT_GRAVITY_MULTIPLIER
@export_subgroup("Movement speed")
@export var initial_movement_speed: float = Movement.DEFAULT_INITIAL_MOVEMENT_SPEED
@export var movement_speed_lerp_speed: float = Movement.DEFAULT_MOVEMENT_SPEED_LERP_SPEED
@export var movement_speed_air_dampening: float = Movement.DEFAULT_MOVEMENT_SPEED_AIR_DAMPENING
@export_subgroup("Velocity")
@export var velocity_lerp_speed: float = Movement.DEFAULT_VELOCITY_LERP_SPEED
@export var velocity_air_dampening: float = Movement.DEFAULT_VELOCITY_AIR_DAMPENING
@export_subgroup("Rotation")
@export var y_rotation_lerp_speed: float = Movement.DEFAULT_Y_ROTATION_LERP_SPEED
@export var y_rotation_air_dampening: float = Movement.DEFAULT_Y_ROTATION_AIR_DAMPENING
@export_subgroup("Misc")
@export var velocity_to_target_y_rotation: bool = Movement.DEFAULT_VELOCITY_TO_TARGET_Y_ROTATION
@export var y_reset: float = Movement.DEFAULT_Y_RESET

@export_group("Jumping")
@export var jump_height: float = Jumping.DEFAULT_JUMP_HEIGHT
@export_subgroup("Double-jumping")
@export var double_jump_min_velocity: float = Jumping.DEFAULT_DOUBLE_JUMP_MIN_VELOCITY
@export var double_jump_scale: float = Jumping.DEFAULT_DOUBLE_JUMP_SCALE

@export_group("Camera")
@export var camera: Camera3D
@export var camera_lerp_speed: float = PlayerCamera.DEFAULT_CAMERA_LERP_SPEED
#endregion exports

#region variables
var input_vec: Vector2 = Vector2.ZERO

@onready var movement: Movement = Movement.new(
	self,
	gravity_multiplier,

	initial_movement_speed,
	movement_speed_lerp_speed,
	movement_speed_air_dampening,

	velocity_lerp_speed,
	velocity_air_dampening,

	y_rotation_lerp_speed,
	y_rotation_air_dampening,

	velocity_to_target_y_rotation,
	y_reset,
)

@onready var jumping: Jumping = Jumping.new(
	self,

	jump_height,
	double_jump_min_velocity,
	double_jump_scale,
)

@onready var player_camera: PlayerCamera = PlayerCamera.new(
	self,

	camera,
	camera_lerp_speed,
)
#endregion variables

#region processing
func _process(_delta: float) -> void:
	input_vec = Input.get_vector("left", "right", "up", "down")
	if input_vec:
		movement.set_direction(input_vec)
		movement.moving = true
	else:
		movement.moving = false

	if Input.is_action_just_pressed("jump"):
		jumping.jump()

func _physics_process(delta: float) -> void:
	movement.physics_process(delta)
	player_camera.physics_process(delta)
#endregion processing
