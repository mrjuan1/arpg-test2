class_name Character
extends CharacterBody3D

#region exports
@export_group("Stats")
@export_subgroup("Stamina")
@export var _stamina: float = Stamina.DEFAULT_STAMINA
@export var _max_stamina: float = Stamina.DEFAULT_MAX_STAMINA
@export var _stamina_recharge_rate: float = Stamina.DEFAULT_STAMINA_RECHARGE_RATE
@export_subgroup("Labels")
@export var _stamina_label: Label

@export_group("Movement")
@export var _gravity_multiplier: float = Movement.DEFAULT_GRAVITY_MULTIPLIER
@export_subgroup("Movement speed")
@export var _initial_movement_speed: float = Movement.DEFAULT_INITIAL_MOVEMENT_SPEED
@export var _movement_speed_lerp_speed: float = Movement.DEFAULT_MOVEMENT_SPEED_LERP_SPEED
@export var _movement_speed_air_dampening: float = Movement.DEFAULT_MOVEMENT_SPEED_AIR_DAMPENING
@export var _max_air_movement_multiplier: float = Movement.DEFAULT_MAX_AIR_MOVEMENT_MULTIPLIER
@export_subgroup("Velocity")
@export var _velocity_lerp_speed: float = Movement.DEFAULT_VELOCITY_LERP_SPEED
@export var _velocity_air_dampening: float = Movement.DEFAULT_VELOCITY_AIR_DAMPENING
@export_subgroup("Rotation")
@export var _y_rotation_lerp_speed: float = Movement.DEFAULT_Y_ROTATION_LERP_SPEED
@export var _y_rotation_air_dampening: float = Movement.DEFAULT_Y_ROTATION_AIR_DAMPENING
@export_subgroup("")
@export var _velocity_to_target_y_rotation: bool = Movement.DEFAULT_VELOCITY_TO_TARGET_Y_ROTATION
@export var _y_reset: float = Movement.DEFAULT_Y_RESET

@export_group("Jumping")
@export var _jump_height: float = Jumping.DEFAULT_JUMP_HEIGHT
@export_subgroup("Double-jumping")
@export var _double_jump_min_velocity: float = Jumping.DEFAULT_DOUBLE_JUMP_MIN_VELOCITY
@export var _double_jump_scale: float = Jumping.DEFAULT_DOUBLE_JUMP_SCALE
@export_subgroup("Stamina")
@export var _jump_stamina: float = Jumping.DEFAULT_JUMP_STAMINA
@export var _double_jump_stamina: float = Jumping.DEFAULT_DOUBLE_JUMP_STAMINA

@export_group("Dodging")
@export var _dodge_timer: Timer
@export_subgroup("Dodging speed")
@export var _floor_dodge_speed: float = Dodging.DEFAULT_FLOOR_DODGE_SPEED
@export var _air_dodge_speed: float = Dodging.DEFAULT_AIR_DODGE_SPEED
@export_subgroup("")
@export var _dodging_min_directional_speed: float = Dodging.DEFAULT_MIN_DIRECTIONAL_SPEED
@export var _dodging_stationary_air_dampening: float = Dodging.DEFAULT_STATIONARY_AIR_DAMPENING
@export_subgroup("Stamina")
@export var _floor_dodge_stamina: float = Dodging.DEFAULT_FLOOR_DODGE_STAMINA
@export var _air_dodge_stamina: float = Dodging.DEFAULT_AIR_DODGE_STAMINA

@export_group("Melee")
@export var _combo_timer: Timer
@export_subgroup("Strength")
@export var _initial_strength: float = Melee.DEFAULT_INITIAL_STRENGTH
@export var _initial_strength_reduction_factor: float = Melee.DEFAULT_INITIAL_STRENGTH_REDUCTION_FACTOR
@export var _strength_reduction_decrement: float = Melee.DEFAULT_STRENGTH_REDUCTION_DECREMENT
@export_subgroup("Charge rate")
@export var _initial_charge_rate: float = Melee.DEFAULT_INITIAL_CHARGE_RATE
@export var _initial_charge_rate_reduction_factor: float = Melee.DEFAULT_INITIAL_CHARGE_RATE_REDUCTION_FACTOR
@export var _charge_rate_reduction_decrement: float = Melee.DEFAULT_CHARGE_RATE_REDUCTION_DECREMENT
@export_subgroup("Max charge")
@export var _initial_max_charge: float = Melee.DEFAULT_INITIAL_MAX_CHARGE
@export var _initial_max_charge_reduction_factor: float = Melee.DEFAULT_INITIAL_MAX_CHARGE_REDUCTION_FACTOR
@export var _max_charge_reduction_decrement: float = Melee.DEFAULT_MAX_CHARGE_REDUCTION_DECREMENT
@export_subgroup("")
@export var _release_strength_cutoff: float = Melee.DEFAULT_RELEASE_STRENGTH_CUTOFF
@export var _max_combos: int = Melee.DEFAULT_MAX_COMBOS
@export_subgroup("Stamina")
@export var _initial_attack_stamina: float = Melee.DEFAULT_INITIAL_ATTACK_STAMINA
@export var _initial_attack_stamina_incrememnt_factor: float = Melee.DEFAULT_INITIAL_ATTACK_STAMINA_INCREMEMNT_FACTOR
@export var _attack_stamina_incrememnt: float = Melee.DEFAULT_ATTACK_STAMINA_INCREMEMNT
@export var _charge_stamina_threshold: float = Melee.DEFAULT_CHARGE_STAMINA_THRESHOLD
@export var _air_attack_stamina_factor: float = Melee.DEFAULT_AIR_ATTACK_STAMINA_FACTOR

@export_group("Camera")
@export var _camera: Camera3D
@export_subgroup("Lerp speeds")
@export var _camera_xz_lerp_speed: float = PlayerCamera.DEFAULT_CAMERA_XZ_LERP_SPEED
@export var _camera_y_lerp_speed: float = PlayerCamera.DEFAULT_CAMERA_Y_LERP_SPEED
@export_subgroup("Y follow distances")
@export var _camera_y_positive_follow_distance: float = PlayerCamera.DEFAULT_CAMERA_Y_POSITIVE_FOLLOW_DISTANCE
@export var _camera_y_negative_follow_distance: float = PlayerCamera.DEFAULT_CAMERA_Y_NEGATIVE_FOLLOW_DISTANCE
#endregion exports

var input_vec: Vector2 = Vector2.ZERO
var charging_melee: bool = false

#region onready
@onready var stamina: Stamina = Stamina.new(
	_stamina,
	_max_stamina,

	_stamina_recharge_rate,
)

@onready var movement: Movement = Movement.new(
	self,
	_gravity_multiplier,

	_initial_movement_speed,
	_movement_speed_lerp_speed,
	_movement_speed_air_dampening,
	_max_air_movement_multiplier,

	_velocity_lerp_speed,
	_velocity_air_dampening,

	_y_rotation_lerp_speed,
	_y_rotation_air_dampening,

	_velocity_to_target_y_rotation,
	_y_reset,
)

@onready var jumping: Jumping = Jumping.new(
	self,

	_jump_height,

	_double_jump_min_velocity,
	_double_jump_scale,

	_jump_stamina,
	_double_jump_stamina,
)

@onready var dodging: Dodging = Dodging.new(
	self,
	_dodge_timer,

	_floor_dodge_speed,
	_air_dodge_speed,

	_dodging_min_directional_speed,
	_dodging_stationary_air_dampening,

	_floor_dodge_stamina,
	_air_dodge_stamina,
)

@onready var melee: Melee = Melee.new(
	self,
	_combo_timer,

	_initial_strength,
	_initial_strength_reduction_factor,
	_strength_reduction_decrement,

	_initial_charge_rate,
	_initial_charge_rate_reduction_factor,
	_charge_rate_reduction_decrement,

	_initial_max_charge,
	_initial_max_charge_reduction_factor,
	_max_charge_reduction_decrement,

	_release_strength_cutoff,
	_max_combos,

	_initial_attack_stamina,
	_initial_attack_stamina_incrememnt_factor,
	_attack_stamina_incrememnt,
	_charge_stamina_threshold,
	_air_attack_stamina_factor,
)

@onready var player_camera: PlayerCamera = PlayerCamera.new(
	self,
	_camera,

	_camera_xz_lerp_speed,
	_camera_y_lerp_speed,

	_camera_y_positive_follow_distance,
	_camera_y_negative_follow_distance,
)

func _ready() -> void:
	melee.attack_released.connect(_on_melee_attack_released)
#endregion onready

#region processing
func _process(delta: float) -> void:
	if charging_melee:
		var charge_state: Melee.ChargeState = melee.charge_attack(delta)

		if charge_state == Melee.ChargeState.CHARGING and Input.is_action_just_released("attack"):
			melee.release_attack()
			charging_melee = false
		elif charge_state == Melee.ChargeState.RELEASED or charge_state == Melee.ChargeState.COOLING_OFF:
			charging_melee = false
	else:
		input_vec = Input.get_vector("left", "right", "up", "down")
		if input_vec:
			movement.direction = input_vec
			movement.moving = true
		else:
			movement.moving = false

		if Input.is_action_just_pressed("jump"):
			jumping.jump()
		elif Input.is_action_just_pressed("dodge"):
			dodging.dodge()
		elif Input.is_action_just_pressed("attack"):
			if is_on_floor():
				charging_melee = true
			else:
				melee.release_attack()

		stamina.recharge_stamina(delta)

	_update_stamina_label()

func _physics_process(delta: float) -> void:
	if charging_melee:
		var reverse_vec: Vector2 = Vector2.from_angle(rotation.y + (PI / 2.0)) * 0.5
		velocity.x = reverse_vec.x
		velocity.z = -reverse_vec.y

	movement.physics_process(delta)
	player_camera.physics_process(delta)
#endregion processing

func _on_melee_attack_released(_strength: float, _combo: int) -> void:
	var lunge_speed: float
	if is_on_floor():
		lunge_speed = 10.0
	else:
		lunge_speed = 3.0
		velocity.y = 2.0

	var lunge_vec: Vector2 = Vector2.from_angle(rotation.y + Movement.HALF_PI) * lunge_speed
	velocity.x = -lunge_vec.x
	velocity.z = lunge_vec.y

func _update_stamina_label() -> void:
	_stamina_label.text = ("Stamina: %.1f/%.1f" % [stamina.current, stamina.maximum])
