class_name Character
extends CharacterBody3D

#region exports
#region stats
@export_group("Stats")
@export var _has_health: bool = false
@export var _has_stamina: bool = false
@export_subgroup("Health")
@export var _hp: float = Health.DEFAULT_HP
@export var _max_hp: float = Health.DEFAULT_MAX_HP
@export_subgroup("Stamina")
@export var _stamina: float = Stamina.DEFAULT_STAMINA
@export var _max_stamina: float = Stamina.DEFAULT_MAX_STAMINA
@export var _stamina_recharge_rate: float = Stamina.DEFAULT_STAMINA_RECHARGE_RATE
#endregion stats

#region movement
@export_group("Movement")
@export var _gravity_multiplier: float = Movement.DEFAULT_GRAVITY_MULTIPLIER
@export_subgroup("Movement")
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
@export_subgroup("Fall damage")
@export var _fall_damage_y_distance: float = Movement.DEFAULT_FALL_DAMAGE_Y_DISTANCE
@export var _fall_damage_y_velocity: float = Movement.DEFAULT_FALL_DAMAGE_Y_VELOCITY
#endregion movement

#region abilities
@export_group("Abilities")
@export var _can_jump: bool = false
@export var _can_dodge: bool = false
@export var _can_attack: bool = false

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
@export_subgroup("Speed")
@export var _floor_dodge_speed: float = Dodging.DEFAULT_FLOOR_DODGE_SPEED
@export var _air_dodge_speed: float = Dodging.DEFAULT_AIR_DODGE_SPEED
@export_subgroup("")
@export var _min_directional_speed: float = Dodging.DEFAULT_MIN_DIRECTIONAL_SPEED
@export var _stationary_air_dampening: float = Dodging.DEFAULT_STATIONARY_AIR_DAMPENING
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
#endregion abilities
#endregion exports

#region public variables
var health: Health
var stamina: Stamina
var jumping: Jumping
var dodging: Dodging
var melee: Melee
#endregion public variables

#region onready variables
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

	_fall_damage_y_distance,
	_fall_damage_y_velocity,
)
#endregion onready variables

#region public functions
func init_character() -> void:
	if _has_health:
		health = Health.new(
			_hp,
			_max_hp,
		)

	if _has_stamina:
		stamina = Stamina.new(
			_stamina,
			_max_stamina,

			_stamina_recharge_rate,
		)

		if _can_jump:
			jumping = Jumping.new(
				self,
				_jump_height,

				_double_jump_min_velocity,
				_double_jump_scale,

				_jump_stamina,
				_double_jump_stamina,
			)

		if _can_dodge:
			dodging = Dodging.new(
				self,
				_dodge_timer,

				_floor_dodge_speed,
				_air_dodge_speed,

				_min_directional_speed,
				_stationary_air_dampening,

				_floor_dodge_stamina,
				_air_dodge_stamina,
			)

		if _can_attack:
			melee = Melee.new(
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
#endregion public functions
