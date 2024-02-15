class_name Player
extends CapsuleCharacter

#region exports
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
@export var _str_label: Label
@export var _def_label: Label
#endregion exports

#region private variables
var _input_vec: Vector2 = Vector2.ZERO
var _last_stamina: float = 0.0
var _melee_charge_state: Melee.ChargeState = Melee.ChargeState.RELEASED
#endregion private variables

#region onready
@onready var player_camera: PlayerCamera = PlayerCamera.new(
	self,
	_camera,

	_camera_xz_lerp_speed,
	_camera_y_lerp_speed,

	_camera_y_positive_follow_distance,
	_camera_y_negative_follow_distance,
)

#@onready var _player_ray: RayCast3D = $PlayerRay

@onready var _game_over_res: PackedScene = preload("res://GameOver.tscn")
#endregion onready

#region events
func _ready() -> void:
	init_capsule_character()

	capsule_character_damaged.connect(_on_capsule_character_damaged)
	capsule_character_killed.connect(_on_capsule_character_killed)
	melee.attack_released.connect(_on_melee_attack_released)

	_update_hp_label()
	_str_label.text = "STR: %.0f" % strdef.strength
	_def_label.text = "DEF: %.0f" % strdef.defence

func _process(delta: float) -> void:
	lerp_capsule_character_colours(delta)

	if health.current > 0.0:
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
	capsule_character_physics_process(delta)
	player_camera.physics_process(delta)
#endregion events

#region signal events
func _on_capsule_character_damaged(_amount: float) -> void:
	_update_hp_label()

func _on_capsule_character_killed() -> void:
	var game_over: ColorRect = _game_over_res.instantiate()
	add_child(game_over)

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

	#if _player_ray.is_colliding():
		#var collider: Object = _player_ray.get_collider()

	prints("Melee attack released with", strength, "strength and", combo, "combos")
#endregion signal events

#region private functions
func _update_hp_label() -> void:
	if _hp_label:
		_hp_label.text = "HP: %.0f/%.0f" % [ceilf(health.current), health.maximum]

func _update_stamina_label() -> void:
	if _stamina_label and stamina.current != _last_stamina:
		_stamina_label.text = "Stamina: %.1f/%.1f" % [stamina.current, stamina.maximum]
		_last_stamina = stamina.current
#endregion private functions
