extends ColorRect

@export var _fade_in_speed: float = 1.0

@onready var _target_colour: Color = modulate

func _ready() -> void:
	_target_colour.a = 1.0

func _process(delta: float) -> void:
	modulate = lerp(modulate, _target_colour, _fade_in_speed * delta)
