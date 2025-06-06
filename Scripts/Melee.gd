class_name Melee

signal attack_released

enum ChargeState {
	CHARGING,
	RELEASED,
	COOLING_OFF,
}

#region constants
const DEFAULT_INITIAL_STRENGTH: float = 3.0
const DEFAULT_INITIAL_STRENGTH_REDUCTION_FACTOR: float = 0.9
const DEFAULT_STRENGTH_REDUCTION_DECREMENT: float = 0.1

const DEFAULT_INITIAL_CHARGE_RATE: float = 0.25
const DEFAULT_INITIAL_CHARGE_RATE_REDUCTION_FACTOR: float = 0.9
const DEFAULT_CHARGE_RATE_REDUCTION_DECREMENT: float = 0.1

const DEFAULT_INITIAL_MAX_CHARGE: float = 0.5
const DEFAULT_INITIAL_MAX_CHARGE_REDUCTION_FACTOR: float = 0.9
const DEFAULT_MAX_CHARGE_REDUCTION_DECREMENT: float = 0.1

const DEFAULT_RELEASE_STRENGTH_CUTOFF: float = 0.1
const DEFAULT_MAX_COMBOS: int = 3

const DEFAULT_INITIAL_ATTACK_STAMINA: float = 0.5
const DEFAULT_INITIAL_ATTACK_STAMINA_INCREMEMNT_FACTOR: float = 1.25
const DEFAULT_ATTACK_STAMINA_INCREMEMNT: float = 0.1
const DEFAULT_CHARGE_STAMINA_THRESHOLD: float = 0.05
const DEFAULT_AIR_ATTACK_STAMINA_FACTOR: float = 2.0
#endregion constants

#region private variables
var _character: Character
var _combo_timer: Timer

var _initial_strength: float
var _initial_strength_reduction_factor: float
var _strength_reduction_decrement: float

var _initial_charge_rate: float
var _initial_charge_rate_reduction_factor: float
var _charge_rate_reduction_decrement: float

var _initial_max_charge: float
var _initial_max_charge_reduction_factor: float
var _max_charge_reduction_decrement: float

var _release_strength_cutoff: float
var _max_combos: int

var _initial_attack_stamina: float
var _initial_attack_stamina_incrememnt_factor: float
var _attack_stamina_incrememnt: float
var _charge_stamina_threshold: float
var _air_attack_stamina_factor: float

var _may_attack: bool = true
var _combo: int = 0
var _charge: float = 0.0

var _strength: float
var _strength_reduction_factor: float

var _charge_rate: float
var _charge_rate_reduction_factor: float

var _max_charge: float
var _max_charge_reduction_factor: float

var _attack_stamina: float
var _attack_stamina_reduction_factor: float
#endregion private variables

#region constructor
func _init(
	character: Character,
	combo_timer: Timer,

	initial_strength: float = DEFAULT_INITIAL_STRENGTH,
	initial_strength_reduction_factor: float = DEFAULT_INITIAL_STRENGTH_REDUCTION_FACTOR,
	strength_reduction_decrement: float = DEFAULT_STRENGTH_REDUCTION_DECREMENT,

	initial_charge_rate: float = DEFAULT_INITIAL_CHARGE_RATE,
	initial_charge_rate_reduction_factor: float = DEFAULT_INITIAL_CHARGE_RATE_REDUCTION_FACTOR,
	charge_rate_reduction_decrement: float = DEFAULT_CHARGE_RATE_REDUCTION_DECREMENT,

	initial_max_charge: float = DEFAULT_INITIAL_MAX_CHARGE,
	initial_max_charge_reduction_factor: float = DEFAULT_INITIAL_MAX_CHARGE_REDUCTION_FACTOR,
	max_charge_reduction_decrement: float = DEFAULT_MAX_CHARGE_REDUCTION_DECREMENT,

	release_strength_cutoff: float = DEFAULT_RELEASE_STRENGTH_CUTOFF,
	max_combos: int = DEFAULT_MAX_COMBOS,

	initial_attack_stamina: float = DEFAULT_INITIAL_ATTACK_STAMINA,
	initial_attack_stamina_incrememnt_factor: float = DEFAULT_INITIAL_ATTACK_STAMINA_INCREMEMNT_FACTOR,
	attack_stamina_incrememnt: float = DEFAULT_ATTACK_STAMINA_INCREMEMNT,
	charge_stamina_threshold: float = DEFAULT_CHARGE_STAMINA_THRESHOLD,
	air_attack_stamina_factor: float = DEFAULT_AIR_ATTACK_STAMINA_FACTOR,
) -> void:
	_character = character

	_combo_timer = combo_timer
	_combo_timer.connect("timeout", _on_combo_timer_timeout)

	_initial_strength = initial_strength
	_initial_strength_reduction_factor = initial_strength_reduction_factor
	_strength_reduction_decrement = strength_reduction_decrement

	_initial_charge_rate = initial_charge_rate
	_initial_charge_rate_reduction_factor = initial_charge_rate_reduction_factor
	_charge_rate_reduction_decrement = charge_rate_reduction_decrement

	_initial_max_charge = initial_max_charge
	_initial_max_charge_reduction_factor = initial_max_charge_reduction_factor
	_max_charge_reduction_decrement = max_charge_reduction_decrement

	_release_strength_cutoff = release_strength_cutoff
	_max_combos = max_combos

	_initial_attack_stamina = initial_attack_stamina
	_initial_attack_stamina_incrememnt_factor = initial_attack_stamina_incrememnt_factor
	_attack_stamina_incrememnt = attack_stamina_incrememnt
	_charge_stamina_threshold = charge_stamina_threshold
	_air_attack_stamina_factor = air_attack_stamina_factor
#endregion constructor

#region private functions
func _prepare_attack() -> bool:
	if _may_attack:
		if not _combo_timer.is_stopped():
			_combo_timer.stop()

		if _combo == 0 and _charge == 0.0:
			_strength = _initial_strength
			_strength_reduction_factor = _initial_strength_reduction_factor

			_charge_rate = _initial_charge_rate
			_charge_rate_reduction_factor = _initial_charge_rate_reduction_factor

			_max_charge = _initial_max_charge
			_max_charge_reduction_factor = _initial_max_charge_reduction_factor

			_attack_stamina = _initial_attack_stamina
			_attack_stamina_reduction_factor = _initial_attack_stamina_incrememnt_factor

		return not is_zero_approx(_character.stamina.current)

	return false

func _on_combo_timer_timeout() -> void:
	if _combo > 0:
		_combo = 0
	else:
		_may_attack = true
#endregion private functions

#region public functions
func charge_attack(delta: float) -> ChargeState:
	if _prepare_attack():
		if _character.stamina.use_stamina(_attack_stamina * delta):
			_charge += _charge_rate * delta
			if _charge > _max_charge:
				_charge = _max_charge
				release_attack()
				return ChargeState.RELEASED
			else:
				return ChargeState.CHARGING
		else:
			release_attack()
			return ChargeState.RELEASED

	return ChargeState.COOLING_OFF

func release_attack() -> void:
	if _prepare_attack():
		var release_strength: float = _strength + _charge
		if release_strength < _release_strength_cutoff:
			release_strength = _release_strength_cutoff

		var can_attack: bool = true
		if absf(release_strength - _strength) < _charge_stamina_threshold:
			var required_stamina: float = _attack_stamina
			if not _character.is_on_floor():
				required_stamina *= _air_attack_stamina_factor

			if not _character.stamina.use_stamina(required_stamina):
				can_attack = false

		if can_attack:
			attack_released.emit(release_strength, _combo)

		_charge = 0.0

		_combo += 1
		if not can_attack or (_max_combos > 0 and _combo == _max_combos) or release_strength == _release_strength_cutoff:
			_combo = 0
			_may_attack = false
		else:
			_strength *= _strength_reduction_factor
			_strength_reduction_factor -= _strength_reduction_decrement

			_charge_rate *= _charge_rate_reduction_factor
			_charge_rate_reduction_factor -= _charge_rate_reduction_decrement

			_max_charge *= _max_charge_reduction_factor
			_max_charge_reduction_factor -= _max_charge_reduction_decrement

			_attack_stamina *= _attack_stamina_reduction_factor
			_attack_stamina_reduction_factor += _attack_stamina_incrememnt

		_combo_timer.start()
#endregion public functions
