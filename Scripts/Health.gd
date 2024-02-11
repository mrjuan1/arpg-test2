class_name Health

signal damaged
signal killed

#region constants
const DEFAULT_HP: float = 5.0
const DEFAULT_MAX_HP: float = 5.0
#endregion constants

#region privates
var _hp: float
var _max_hp: float
#endregion privates

#region constructor
func _init(
	hp: float = DEFAULT_HP,
	max_hp: float = DEFAULT_MAX_HP,
) -> void:
	_hp = hp
	_max_hp = max_hp
#endregion constructor

var current: float:
	get:
		return _hp
	set(value):
		var last_hp: float = _hp
		_hp = clampf(value, 0.0, _max_hp)

		if _hp == 0.0:
			killed.emit()
		elif _hp < last_hp:
			damaged.emit(last_hp - _hp)

var maximum: float:
	get:
		return _max_hp

#region functions
func increase_max_hp(amount: float) -> void:
	if amount > 0.0:
		_max_hp += amount
#endregion functions
