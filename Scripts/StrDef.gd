class_name StrDef

const DEFAULT_STRENGTH: float = 3.0
const DEFAULT_DEFENCE: float = 2.0

var _strength: float
var _defence: float

func _init(
	initial_strength: float = DEFAULT_STRENGTH,
	initial_defence: float = DEFAULT_DEFENCE,
) -> void:
	_strength = initial_strength
	_defence = initial_defence

var strength: float:
	get:
		return _strength

var defence: float:
	get:
		return _defence

func increase_strength(amount: float) -> void:
	if amount > 0.0:
		_strength += amount

func increase_defence(amount: float) -> void:
	if amount > 0.0:
		_defence += amount
