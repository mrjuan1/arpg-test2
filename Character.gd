class_name Character
extends CharacterBody3D

#region exports
@export var gravity_multiplier: float = Movement.DEFAULT_GRAVITY_MULTIPLIER

@export_group("Movement speed")
@export var initial_movement_speed: float = Movement.DEFAULT_INITIAL_MOVEMENT_SPEED
@export var movement_speed_lerp_speed: float = Movement.DEFAULT_MOVEMENT_SPEED_LERP_SPEED
@export var movement_speed_air_dampening: float = Movement.DEFAULT_MOVEMENT_SPEED_AIR_DAMPENING

@export_group("Velocity")
@export var velocity_lerp_speed: float = Movement.DEFAULT_VELOCITY_LERP_SPEED
@export var velocity_air_dampening: float = Movement.DEFAULT_VELOCITY_AIR_DAMPENING

@export_group("Rotation")
@export var y_rotation_lerp_speed: float = Movement.DEFAULT_Y_ROTATION_LERP_SPEED
@export var y_rotation_air_dampening: float = Movement.DEFAULT_Y_ROTATION_AIR_DAMPENING

@export_group("Movement")
@export var velocity_to_target_y_rotation: bool = Movement.DEFAULT_VELOCITY_TO_TARGET_Y_ROTATION
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

func _physics_process(delta: float) -> void:
	movement.physics_process(delta)
#endregion processing
