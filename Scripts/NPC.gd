class_name NPC
extends CapsuleCharacter

func _ready() -> void:
	init_capsule_character()

func _process(delta: float) -> void:
	lerp_capsule_character_colours(delta)

func _physics_process(delta: float) -> void:
	capsule_character_physics_process(delta)
