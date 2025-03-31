extends CharacterBody3D

@export var hp: int
@export var head_damage: float
@export var body_damage: float

func _on_body_collision_is_hit(where) -> void:
	hp -= body_damage
	print("My name is " + name + ", and my hp has become " + str(hp) + " thanks to hit to " + str(where))
	_is_dead()

func _on_head_collision_is_hit(where) -> void:
	hp -= head_damage
	print("My name is " + name + ", and my hp has become " + str(hp) + " thanks to hit to " + str(where))
	_is_dead()

func _is_dead() -> void:
	if hp <= 0:
		queue_free()
