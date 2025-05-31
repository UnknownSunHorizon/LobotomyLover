extends CollisionShape3D

signal is_hit(where)

func _hit():
	is_hit.emit(name)
