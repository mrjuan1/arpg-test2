class_name Stamina

#region constants
const DEFAULT_STAMINA: float = 3.0
const DEFAULT_MAX_STAMINA: float = 3.0

const DEFAULT_STAMINA_RECHARGE_RATE: float = 1.0
#endregion constants

#region privates
var _stamina: float
var _max_stamina: float

var _stamina_recharge_rate: float
#endregion privates

#region constructor
func _init(
	stamina: float = DEFAULT_STAMINA,
	max_stamina: float = DEFAULT_MAX_STAMINA,

	stamina_recharge_rate: float = DEFAULT_STAMINA_RECHARGE_RATE,
) -> void:
	_stamina = stamina
	_max_stamina = max_stamina

	_stamina_recharge_rate = stamina_recharge_rate
#endregion constructor

var current: float:
	get:
		return _stamina

var max: float:
	get:
		return _max_stamina

var recharge_rate: float:
	get:
		return _stamina_recharge_rate
	set(value):
		if value < 0.0:
			_stamina_recharge_rate = 0.0
		else:
			_stamina_recharge_rate = value

#region functions
func use_stamina(amount: float) -> bool:
	if _stamina >= amount:
		_stamina -= amount
		return true

	return false

func give_stamina(amount: float) -> void:
	_stamina += amount
	if _stamina > _max_stamina:
		_stamina = _max_stamina

func recharge_stamina(delta: float) -> void:
	if _stamina < _max_stamina:
		give_stamina(_stamina_recharge_rate * delta)

func increase_max_stamina(amount: float) -> void:
	if amount > 0.0:
		_max_stamina += amount
#endregion functions
